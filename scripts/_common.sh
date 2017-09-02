
#=================================================
# COMMON VARIABLES
#=================================================

dependencies="php5-gd php5-json php5-intl php5-mcrypt php5-curl php5-apcu php5-imagick acl tar smbclient"

#=================================================
# COMMON HELPERS
#=================================================

# Execute a command with occ
exec_occ() {
  (cd "$final_path" && exec_as "$app" \
      php occ --no-interaction --no-ansi "$@")
}

# Create the external storage for the home folders and enable sharing
create_home_external_storage() {
  local mount_id=`exec_occ files_external:create --output=json \
      'Home' 'local' 'null::null' -c 'datadir=/home/$user' || true`
  ! [[ $mount_id =~ ^[0-9]+$ ]] \
    && echo "Unable to create external storage" >&2 \
    || exec_occ files_external:option "$mount_id" enable_sharing true
}

# Rename a MySQL database and user
# Usage: rename_mysql_db DBNAME DBUSER DBPASS NEW_DBNAME_AND_USER
rename_mysql_db() {
    local db_name=$1 db_user=$2 db_pwd=$3 new_db_name=$4
    local sqlpath="/tmp/${db_name}-$(date '+%s').sql"

    # Dump the old database
    mysqldump -u "$db_user" -p"$db_pwd" --no-create-db "$db_name" > "$sqlpath"

    # Create the new database and user
    ynh_mysql_create_db "$new_db_name" "$new_db_name" "$db_pwd"
    ynh_mysql_connect_as "$new_db_name" "$db_pwd" "$new_db_name" < "$sqlpath"

    # Remove the old database
    ynh_mysql_remove_db $db_name $db_name
    ynh_secure_remove "$sqlpath"
}

#=================================================
# COMMON HELPERS -- SHOULD BE ADDED TO YUNOHOST
#=================================================

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    sudo -u "$USER" "$@"
  fi
}

# Check if an URL is already handled
# usage: is_url_handled URL
is_url_handled() {
  local output=($(curl -k -s -o /dev/null \
      -w 'x%{redirect_url} %{http_code}' "$1"))
  # It's handled if it does not redirect to the SSO nor return 404
  [[ ! ${output[0]} =~ \/yunohost\/sso\/ && ${output[1]} != 404 ]]
}

# Make the main steps to migrate an app to its fork.
#
# This helper have to be used for an app who need to migrate to a new name or a new fork.
# Like owncloud to nextcloud or zerobin to privatebin
#
# This helper will move the files of an app to its new name
# Or recreate the things it can't moves.
#
# To know which files it have to moves. You have to give a "migration file", stored in ../conf
# This file is simply a list of each file it have to moves.
# Except that you have to add all variables as variable. That mean you have to add $app instead of the real name of the app.
# And the same for domain or anything else like that.
# $app is espcially important because it's this variable which be used to identify the old place and the new one for each file.
#
# If a database exist for this app, it will be dump then reload to a new database name, with a new user.
# You have to forward this change in the settings of your app.
#
# Same things for an existing user, a new one will be create.
# But the old one can't be remove unless it's not using. See below.
#
# If you have some dependencies for your app, it's possible to changed the fake package who manage them.
# You have to fill the variable $dependencies, and then a new fake package will be created and installed.
# And the old one will be removed.
# If you don't have a variable $dependencies, the helper can't know what's the dependencies of the app.
#
# The settings.yml of the app will be modified as following:
# - finalpath will be changed, according to the new name. If it can find the old name in the existing $final_path
# - The checksum of php-fpm and nginx config file will be changed too.
# - If there a $db_name value, it will be changed.
# - And, of course, the ID will be changed to the new name too.
#
# Finally, the $app variable will take the value of the new name.
# The helper will set the variable $migration_process at 1 if a migration has been proceed.
#
# You have to handle all the migrations not done by this helper for your app, like configuration or special values in settings.yml
# Also, at the end of upgrade script, you have to add a post_migration script to handle all the things the helper can't do during YunoHost use your app.
# Especially remove the old user, move some hooks and remove the old configuration directory
# To launch this script, you have to move it elsewhere and start it after the upgrade script.
# `cp ../conf/$script_post_migration /tmp`
# `(cd /tmp; echo "/tmp/$script_post_migration" | at now + 2 minutes)`
#
# usage: ynh_handle_app_migration migration_id migration_list
# | arg: migration_id  - ID from which to migrate
# | arg: migration_list - List of file to move.
ynh_handle_app_migration ()  {
    #=================================================
    # LOAD SETTINGS
    #=================================================

    old_app=$YNH_APP_INSTANCE_NAME
    local old_app_id=$YNH_APP_ID
    local old_app_number=$YNH_APP_INSTANCE_NUMBER

    # Get the id from which to migrate
    local migration_id="$1"
    # And the file with the paths to move
    local migration_list="$2"

    # Get the new app id in the manifest
    local new_app_id=$(grep \"id\": ../manifest.json | cut -d\" -f4)
    if [ $old_app_number -eq 1 ]; then
	local new_app=$new_app_id
    else
	local new_app=${new_app_id}__${old_app_number}
    fi

    #=================================================
    # CHECK IF IT HAS TO MIGRATE 
    #=================================================

    migration_process=0

    if [ "$old_app_id" == "$new_app_id" ]
    then
	# If the 2 id are the same
	# No migration to do.
	echo 0
	return 0
    else
	if [ "$old_app_id" != "$migration_id" ]
	then
	    # If the new app is not the authorized id, fail.
	    ynh_die "Incompatible application for migration from $old_app_id to $new_app_id"
	fi

	echo "Migrate from $old_app_id to $new_app_id" >&2

	#=================================================
	# CHECK IF THE MIGRATION CAN BE DONE
	#=================================================

	# TODO Handle multi instance apps...
	# Check that there not already an app installed for this id.
	(yunohost app list --installed -f "$new_app" | grep -q id) \
	&& ynh_die "$new_app is already installed"

	#=================================================
	# CHECK THE LIST OF FILES TO MOVE
	#=================================================

	local temp_migration_list="$(tempfile)"

	# Build the list by removing blank lines and comment lines
	sed '/^#.*\|^$/d' "../conf/$migration_list" > "$temp_migration_list"

	# Check if there no files in the destination
	local file_to_move=""
	while read file_to_move
	do
	    # Replace all occurence of $app by $new_app in each file to move.
	    local move_to_destination="${file_to_move//\$app/$new_app}"
	    test -e "$move_to_destination" && ynh_die "A file named $move_to_destination already exist."
	done < "$temp_migration_list"

	#=================================================
	# COPY THE YUNOHOST SETTINGS FOR THIS APP
	#=================================================

	local settings_dir="/etc/yunohost/apps"
	cp -a "$settings_dir/$old_app" "$settings_dir/$new_app"

	# Replace the old id by the new one
	ynh_replace_string "\(^id: .*\)$old_app" "\1$new_app" "$settings_dir/$new_app/settings.yml"
	# INFO: There a special behavior with yunohost app setting
	# if the id given in argument does not match with the id
	# stored in the config file. The config file will be purged.
	# That's why we use sed instead of app setting here.
	# https://github.com/YunoHost/yunohost/blob/c6b5284be8da39cf2da4e1036a730eb5e0515096/src/yunohost/app.py#L1316-L1321

	#=================================================
	# MOVE FILES TO THE NEW DESTINATION
	#=================================================

	while read file_to_move
	do
	    # Replace all occurence of $app by $new_app in each file to move.
	    move_to_destination="$(eval echo "${file_to_move//\$app/$new_app}")"
	    local real_file_to_move="$(eval echo "${file_to_move//\$app/$old_app}")"
	    echo "Move the file $real_file_to_move to $move_to_destination" >&2
	    mv "$real_file_to_move" "$move_to_destination"
	done < "$temp_migration_list"

	#=================================================
	# UPDATE KNOWN FILES IN THE SETTINGS
	#=================================================

	# Replace nginx checksum
	ynh_replace_string "\(^checksum__etc_nginx.*\)_$old_app" "\1_$new_app/" "$settings_dir/$new_app/settings.yml"

	# Replace php5-fpm checksums
	ynh_replace_string "\(^checksum__etc_php5.*[-_]\)$old_app" "\1$new_app/" "$settings_dir/$new_app/settings.yml"

	# Replace final_path
	ynh_replace_string "\(^final_path: .*\)$old_app" "\1$new_app" "$settings_dir/$new_app/settings.yml"

	#=================================================
	# MOVE THE DATABASE
	#=================================================

	db_pwd=$(ynh_app_setting_get $old_app mysqlpwd)
	db_name=$(ynh_app_setting_get $old_app db_name)

	# Check if a database exist before trying to move it
	local mysql_root_password=$(cat $MYSQL_ROOT_PWD_FILE)
	if [ -n "$db_name" ] && mysqlshow -u root -p$mysql_root_password | grep -q "^| $db_name"
	then
	    new_db_name=$(ynh_sanitize_dbid $new_app)
	    echo "Rename the database $db_name to $new_db_name" >&2

	    local sql_dump="/tmp/${db_name}-$(date '+%s').sql"

	    # Dump the old database
	    ynh_mysql_dump_db "$db_name" > "$sql_dump"

	    # Create a new database
	    ynh_mysql_setup_db $new_db_name $new_db_name $db_pwd
	    # Then restore the old one into the new one
	    ynh_mysql_connect_as $new_db_name $db_pwd $new_db_name < "$sql_dump"

	    # Remove the old database
	    ynh_mysql_remove_db $db_name $db_name
	    # And the dump
	    ynh_secure_remove "$sql_dump"

	    # Update the value of $db_name
	    db_name=$new_db_name
	    ynh_app_setting_set $new_app db_name $db_name
	fi

	#=================================================
	# CREATE A NEW USER
	#=================================================

	# Check if the user exists on the system
	if ynh_system_user_exists "$old_app"
	then
		echo "Create a new user $new_app to replace $old_app" >&2
		ynh_system_user_create $new_app
	fi

	#=================================================
	# CHANGE THE FAKE DEPENDENCIES PACKAGE
	#=================================================

	# Check if a variable $dependencies exists
	# If this variable doesn't exist, this part shall be manage in the upgrade script.
	if [ -n "${dependencies:-}" ]
	then
	    # Define the name of the package
	    local old_package_name="${old_app//_/-}-ynh-deps"
	    local new_package_name="${new_app//_/-}-ynh-deps"

	    if ynh_package_is_installed "$old_package_name"
	    then
		# Install a new fake package
		app=$new_app
		ynh_install_app_dependencies $dependencies
		# Then remove the old one
		app=$old_app
		ynh_remove_app_dependencies
	    fi
	fi

	#=================================================
	# UPDATE THE ID OF THE APP
	#=================================================

	app=$new_app


	# Set migration_process to 1 to inform that an upgrade has been made
	migration_process=1
    fi
}
