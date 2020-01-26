
#=================================================
# COMMON VARIABLES
#=================================================

pkg_dependencies="imagemagick acl tar smbclient at"

php_version="7.2"
extra_pkg_dependencies="php${php_version}-bz2 php${php_version}-imap php${php_version}-smbclient php${php_version}-gmp php${php_version}-gd php${php_version}-json php${php_version}-intl php${php_version}-curl php${php_version}-apcu php${php_version}-redis php${php_version}-ldap php${php_version}-imagick php${php_version}-zip php${php_version}-mbstring php${php_version}-xml php${php_version}-mysql"

#=================================================
# EXPERIMENTAL HELPERS
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

#=================================================

# Check if an URL is already handled
# usage: is_url_handled URL
is_url_handled() {
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [u]=url= )
    local url
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    # Try to get the url with curl, and keep the http code and an eventual redirection url.
    local curl_output="$(curl --insecure --silent --output /dev/null \
      --write-out '%{http_code};%{redirect_url}' "$url")"

    # Cut the output and keep only the first part to keep the http code
    local http_code="${curl_output%%;*}"
    # Do the same thing but keep the second part, the redirection url
    local redirection="${curl_output#*;}"

    # Return 1 if the url isn't handled.
    # Which means either curl got a 404 (or the admin) or the sso.
    # A handled url should redirect to a publicly accessible url.
    # Return 1 if the url has returned 404
    if [ "$http_code" = "404" ] || [[ $redirection =~ "/yunohost/admin" ]]; then
        return 1
    # Return 1 if the url is redirected to the SSO
    elif [[ $redirection =~ "/yunohost/sso" ]]; then
        return 1
    fi
}

#=================================================

# Make the main steps to migrate an app to its fork.
#
# This helper has to be used for an app which needs to migrate to a new name or a new fork
# (like owncloud to nextcloud or zerobin to privatebin).
#
# This helper will move the files of an app to its new name
# or recreate the things it can't move.
#
# To specify which files it has to move, you have to create a "migration file", stored in ../conf
# This file is a simple list of each file it has to move,
# except that file names must reference the $app variable instead of the real name of the app,
# and every instance-specific variables (like $domain).
# $app is especially important because it's this variable which will be used to identify the old place and the new one for each file.
#
# If a database exists for this app, it will be dumped and then imported in a newly created database, with a new name and new user.
# Don't forget you have to then apply these changes to application-specific settings (depends on the packaged application)
#
# Same things for an existing user, a new one will be created.
# But the old one can't be removed unless it's not used. See below.
#
# If you have some dependencies for your app, it's possible to change the fake debian package which manages them.
# You have to fill the $pkg_dependencies variable, and then a new fake package will be created and installed,
# and the old one will be removed.
# If you don't have a $pkg_dependencies variable, the helper can't know what the app dependencies are.
#
# The app settings.yml will be modified as follows:
# - finalpath will be changed according to the new name (but only if the existing $final_path contains the old app name)
# - The checksums of php-fpm and nginx config files will be updated too.
# - If there is a $db_name value, it will be changed.
# - And, of course, the ID will be changed to the new name too.
#
# Finally, the $app variable will take the value of the new name.
# The helper will set the $migration_process variable to 1 if a migration has been successfully handled.
#
# You have to handle by yourself all the migrations not done by this helper, like configuration or special values in settings.yml
# Also, at the end of the upgrade script, you have to add a post_migration script to handle all the things the helper can't do during YunoHost upgrade (mostly for permission reasons),
# especially remove the old user, move some hooks and remove the old configuration directory
# To launch this script, you have to move it elsewhere and start it after the upgrade script.
# `cp ../conf/$script_post_migration /tmp`
# `(cd /tmp; echo "/tmp/$script_post_migration" | at now + 2 minutes)`
#
# usage: ynh_handle_app_migration migration_id migration_list
# | arg: migration_id  - ID from which to migrate
# | arg: migration_list - File specifying every file to move (one file per line)
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
    # Check that there is not already an app installed for this id.
    (yunohost app list --installed -f "$new_app" | grep -q id) \
    && ynh_die "$new_app is already installed"

    #=================================================
    # CHECK THE LIST OF FILES TO MOVE
    #=================================================

    local temp_migration_list="$(tempfile)"

    # Build the list by removing blank lines and comment lines
    sed '/^#.*\|^$/d' "../conf/$migration_list" > "$temp_migration_list"

    # Check if there is no file in the destination
    local file_to_move=""
    while read file_to_move
    do
        # Replace all occurences of $app by $new_app in each file to move.
        local move_to_destination="${file_to_move//\$app/$new_app}"
        test -e "$move_to_destination" && ynh_die "A file named $move_to_destination already exists."
    done < "$temp_migration_list"

    #=================================================
    # COPY YUNOHOST SETTINGS FOR THIS APP
    #=================================================

    local settings_dir="/etc/yunohost/apps"
    cp -a "$settings_dir/$old_app" "$settings_dir/$new_app"

    # Replace the old id by the new one
    ynh_replace_string "\(^id: .*\)$old_app" "\1$new_app" "$settings_dir/$new_app/settings.yml"
    # INFO: There a special behavior with yunohost app setting:
    # if the id given in argument does not match with the id
    # stored in the config file, the config file will be purged.
    # That's why we use sed instead of app setting here.
    # https://github.com/YunoHost/yunohost/blob/c6b5284be8da39cf2da4e1036a730eb5e0515096/src/yunohost/app.py#L1316-L1321

    # Change the label if it's simply the name of the app
    old_label=$(ynh_app_setting_get $new_app label)
    if [ "${old_label,,}" == "$old_app_id" ]
    then
        # Build the new label from the id of the app. With the first character as upper case
        new_label=$(echo $new_app_id | cut -c1 | tr [:lower:] [:upper:])$(echo $new_app_id | cut -c2-)
        ynh_app_setting_set $new_app label $new_label
    fi

    #=================================================
    # MOVE FILES TO THE NEW DESTINATION
    #=================================================

    while read file_to_move
    do
        # Replace all occurence of $app by $new_app in each file to move.
        move_to_destination="$(eval echo "${file_to_move//\$app/$new_app}")"
        local real_file_to_move="$(eval echo "${file_to_move//\$app/$old_app}")"
        echo "Move file $real_file_to_move to $move_to_destination" >&2
        mv "$real_file_to_move" "$move_to_destination"
    done < "$temp_migration_list"

    #=================================================
    # UPDATE SETTINGS KNOWN ENTRIES
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

    # Check if a database exists before trying to move it
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

    # Check if a variable $pkg_dependencies exists
    # If this variable doesn't exist, this part shall be managed in the upgrade script.
    if [ -n "${pkg_dependencies:-}" ]
    then
      # Define the name of the package
      local old_package_name="${old_app//_/-}-ynh-deps"
      local new_package_name="${new_app//_/-}-ynh-deps"

      if ynh_package_is_installed "$old_package_name"
      then
        # Install a new fake package
        app=$new_app
        ynh_install_app_dependencies $pkg_dependencies
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

#=================================================

# Check available space before creating a temp directory.
#
# usage: ynh_smart_mktemp --min_size="Min size"
#
# | arg: -s, --min_size= - Minimal size needed for the temporary directory, in Mb
ynh_smart_mktemp () {
        # Declare an array to define the options of this helper.
        declare -Ar args_array=( [s]=min_size= )
        local min_size
        # Manage arguments with getopts
        ynh_handle_getopts_args "$@"

        min_size="${min_size:-300}"
        # Transform the minimum size from megabytes to kilobytes
        min_size=$(( $min_size * 1024 ))

        # Check if there's enough free space in a directory
        is_there_enough_space () {
                local free_space=$(df --output=avail "$1" | sed 1d)
                test $free_space -ge $min_size
        }

        if is_there_enough_space /tmp; then
                local tmpdir=/tmp
        elif is_there_enough_space /var; then
                local tmpdir=/var
        elif is_there_enough_space /; then
                local tmpdir=/   
        elif is_there_enough_space /home; then
                local tmpdir=/home
        else
                ynh_die "Insufficient free space to continue..."
        fi

        echo "$(sudo mktemp --directory --tmpdir="$tmpdir")"
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

#=================================================
# YUNOHOST MULTIMEDIA INTEGRATION
#=================================================

# Install or update the main directory yunohost.multimedia
#
# usage: ynh_multimedia_build_main_dir
ynh_multimedia_build_main_dir () {
        local ynh_media_release="v1.2"
        local checksum="806a827ba1902d6911095602a9221181"

        # Download yunohost.multimedia scripts
        wget -nv https://github.com/YunoHost-Apps/yunohost.multimedia/archive/${ynh_media_release}.tar.gz

        # Check the control sum
        echo "${checksum} ${ynh_media_release}.tar.gz" | md5sum -c --status \
                || ynh_die "Corrupt source"

        # Check if the package acl is installed. Or install it.
        ynh_package_is_installed 'acl' \
                || ynh_package_install acl

        # Extract
        mkdir yunohost.multimedia-master
        tar -xf ${ynh_media_release}.tar.gz -C yunohost.multimedia-master --strip-components 1
        ./yunohost.multimedia-master/script/ynh_media_build.sh
}

# Grant write access to multimedia directories to a specified user
#
# usage: ynh_multimedia_addaccess user_name
#
# | arg: user_name - User to be granted write access
ynh_multimedia_addaccess () {
        local user_name=$1
        groupadd -f multimedia
        usermod -a -G multimedia $user_name
}

# Install another version of php.
#
# usage: ynh_install_php --phpversion=phpversion [--package=packages]
# | arg: -v, --phpversion - Version of php to install. Can be one of 7.1, 7.2 or 7.3
# | arg: -p, --package - Additionnal php packages to install
ynh_install_php () {
	# Declare an array to define the options of this helper.
	local legacy_args=vp
	declare -Ar args_array=( [v]=phpversion= [p]=package= )
	local phpversion
	local package
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	package=${package:-}

	# Store php_version into the config of this app
	ynh_app_setting_set $app php_version $phpversion

	if [ "$phpversion" == "7.0" ]
	then
		ynh_die --message="Do not use ynh_install_php to install php7.0"
	fi

	# Store the ID of this app and the version of php requested for it
	echo "$YNH_APP_INSTANCE_NAME:$phpversion" | tee --append "/etc/php/ynh_app_version"

	# Add an extra repository for those packages
	ynh_install_extra_repo --repo="https://packages.sury.org/php/ $(lsb_release -sc) main" --key="https://packages.sury.org/php/apt.gpg" --priority=995 --name=extra_php_version

	# Install requested dependencies from this extra repository.
	# Install php-fpm first, otherwise php will install apache as a dependency.
	ynh_add_app_dependencies --package="php${phpversion}-fpm"
	ynh_add_app_dependencies --package="php$phpversion php${phpversion}-common $package"

	# Set php7.0 back as the default version for php-cli.
	update-alternatives --set php /usr/bin/php7.0

	# Remove this extra repository after packages are installed
	ynh_remove_extra_repo --name=extra_php_version

	# Advertise service in admin panel
	yunohost service add php${phpversion}-fpm --log "/var/log/php${phpversion}-fpm.log"
}

ynh_remove_php () {
	# Get the version of php used by this app
	local phpversion=$(ynh_app_setting_get $app php_version)

	if [ "$phpversion" == "7.0" ] || [ -z "$phpversion" ]
	then
		if [ "$phpversion" == "7.0" ]
		then
			ynh_print_err "Do not use ynh_remove_php to install php7.0"
		fi
		return 0
	fi

	# Remove the line for this app
	sed --in-place "/$YNH_APP_INSTANCE_NAME:$phpversion/d" "/etc/php/ynh_app_version"

	# If no other app uses this version of php, remove it.
	if ! grep --quiet "$phpversion" "/etc/php/ynh_app_version"
	then
		# Purge php dependences for this version.
		ynh_package_autopurge "php$phpversion php${phpversion}-fpm php${phpversion}-common"
		# Remove the service from the admin panel
		yunohost service remove php${phpversion}-fpm
	fi

	# If no other app uses alternate php versions, remove the extra repo for php
	if [ ! -s "/etc/php/ynh_app_version" ]
	then
		ynh_secure_remove /etc/php/ynh_app_version
	fi
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
# Pin a repository.
#
# usage: ynh_pin_repo --package=packages --pin=pin_filter [--priority=priority_value] [--name=name] [--append]
# | arg: -p, --package - Packages concerned by the pin. Or all, *.
# | arg: -i, --pin - Filter for the pin.
# | arg: -p, --priority - Priority for the pin
# | arg: -n, --name - Name for the files for this repo, $app as default value.
# | arg: -a, --append - Do not overwrite existing files.
#
# See https://manpages.debian.org/stretch/apt/apt_preferences.5.en.html for information about pinning.
#
ynh_pin_repo () {
	# Declare an array to define the options of this helper.
	local legacy_args=pirna
	declare -Ar args_array=( [p]=package= [i]=pin= [r]=priority= [n]=name= [a]=append )
	local package
	local pin
	local priority
	local name
	local append
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	package="${package:-*}"
	priority=${priority:-50}
	name="${name:-$app}"
	append=${append:-0}

	if [ $append -eq 1 ]
	then
		append="tee -a"
	else
		append="tee"
	fi

	mkdir -p "/etc/apt/preferences.d"
	echo "Package: $package
Pin: $pin
Pin-Priority: $priority" \
	| $append "/etc/apt/preferences.d/$name"
}

# Add a repository.
#
# usage: ynh_add_repo --uri=uri --suite=suite --component=component [--name=name] [--append]
# | arg: -u, --uri - Uri of the repository.
# | arg: -s, --suite - Suite of the repository.
# | arg: -c, --component - Component of the repository.
# | arg: -n, --name - Name for the files for this repo, $app as default value.
# | arg: -a, --append - Do not overwrite existing files.
#
# Example for a repo like deb http://forge.yunohost.org/debian/ stretch stable
#                             uri                               suite   component
# ynh_add_repo --uri=http://forge.yunohost.org/debian/ --suite=stretch --component=stable
#
ynh_add_repo () {
	# Declare an array to define the options of this helper.
	local legacy_args=uscna
	declare -Ar args_array=( [u]=uri= [s]=suite= [c]=component= [n]=name= [a]=append )
	local uri
	local suite
	local component
	local name
	local append
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	name="${name:-$app}"
	append=${append:-0}

	if [ $append -eq 1 ]
	then
		append="tee -a"
	else
		append="tee"
	fi

	mkdir -p "/etc/apt/sources.list.d"
	# Add the new repo in sources.list.d
	echo "deb $uri $suite $component" \
		| $append "/etc/apt/sources.list.d/$name.list"
}

# Add an extra repository correctly, pin it and get the key.
#
# usage: ynh_install_extra_repo --repo="repo" [--key=key_url] [--priority=priority_value] [--name=name] [--append]
# | arg: -r, --repo - Complete url of the extra repository.
# | arg: -k, --key - url to get the public key.
# | arg: -p, --priority - Priority for the pin
# | arg: -n, --name - Name for the files for this repo, $app as default value.
# | arg: -a, --append - Do not overwrite existing files.
ynh_install_extra_repo () {
	# Declare an array to define the options of this helper.
	local legacy_args=rkpna
	declare -Ar args_array=( [r]=repo= [k]=key= [p]=priority= [n]=name= [a]=append )
	local repo
	local key
	local priority
	local name
	local append
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	name="${name:-$app}"
	append=${append:-0}
	key=${key:-0}
	priority=${priority:-}

	if [ $append -eq 1 ]
	then
		append="--append"
		wget_append="tee -a"
	else
		append=""
		wget_append="tee"
	fi

	# Split the repository into uri, suite and components.
	# Remove "deb " at the beginning of the repo.
	repo="${repo#deb }"

	# Get the uri
	local uri="$(echo "$repo" | awk '{ print $1 }')"

	# Get the suite
	local suite="$(echo "$repo" | awk '{ print $2 }')"

	# Get the components
	local component="${repo##$uri $suite }"

	# Add the repository into sources.list.d
	ynh_add_repo --uri="$uri" --suite="$suite" --component="$component" --name="$name" $append

	# Pin the new repo with the default priority, so it won't be used for upgrades.
	# Build $pin from the uri without http and any sub path
	local pin="${uri#*://}"
	pin="${pin%%/*}"
	# Set a priority only if asked
	if [ -n "$priority" ]
	then
		priority="--priority=$priority"
	fi
	ynh_pin_repo --package="*" --pin="origin \"$pin\"" $priority --name="$name" $append

	# Get the public key for the repo
	if [ -n "$key" ]
	then
		mkdir -p "/etc/apt/trusted.gpg.d"
		wget -q "$key" -O - | gpg --dearmor | $wget_append /etc/apt/trusted.gpg.d/$name.gpg > /dev/null
	fi

	# Update the list of package with the new repo
	ynh_package_update
}

# Remove an extra repository and the assiociated configuration.
#
# usage: ynh_remove_extra_repo [--name=name]
# | arg: -n, --name - Name for the files for this repo, $app as default value.
ynh_remove_extra_repo () {
	# Declare an array to define the options of this helper.
	local legacy_args=n
	declare -Ar args_array=( [n]=name= )
	local name
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	name="${name:-$app}"

	ynh_secure_remove "/etc/apt/sources.list.d/$name.list"
	ynh_secure_remove "/etc/apt/preferences.d/$name"
	ynh_secure_remove "/etc/apt/trusted.gpg.d/$name.gpg"
	ynh_secure_remove "/etc/apt/trusted.gpg.d/$name.asc"

	# Update the list of package to exclude the old repo
	ynh_package_update
}

# Install packages from an extra repository properly.
#
# usage: ynh_install_extra_app_dependencies --repo="repo" --package="dep1 dep2" [--key=key_url] [--name=name]
# | arg: -r, --repo - Complete url of the extra repository.
# | arg: -p, --package - The packages to install from this extra repository
# | arg: -k, --key - url to get the public key.
# | arg: -n, --name - Name for the files for this repo, $app as default value.
ynh_install_extra_app_dependencies () {
	# Declare an array to define the options of this helper.
	local legacy_args=rpkn
	declare -Ar args_array=( [r]=repo= [p]=package= [k]=key= [n]=name= )
	local repo
	local package
	local key
	local name
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	name="${name:-$app}"
	key=${key:-0}

	# Set a key only if asked
	if [ -n "$key" ]
	then
		key="--key=$key"
	fi
	# Add an extra repository for those packages
	ynh_install_extra_repo --repo="$repo" $key --priority=995 --name=$name

	# Install requested dependencies from this extra repository.
	ynh_add_app_dependencies --package="$package"

	# Remove this extra repository after packages are installed
	ynh_remove_extra_repo --name=$app
}

#=================================================

# patched version of ynh_install_app_dependencies to be used with ynh_add_app_dependencies

# Define and install dependencies with a equivs control file
# This helper can/should only be called once per app
#
# usage: ynh_install_app_dependencies dep [dep [...]]
# | arg: dep - the package name to install in dependence
#   You can give a choice between some package with this syntax : "dep1|dep2"
#   Example : ynh_install_app_dependencies dep1 dep2 "dep3|dep4|dep5"
#   This mean in the dependence tree : dep1 & dep2 & (dep3 | dep4 | dep5)
#
# Requires YunoHost version 2.6.4 or higher.
ynh_install_app_dependencies () {
    local dependencies=$@
    dependencies="$(echo "$dependencies" | sed 's/\([^\<=\>]\)\ \([^(]\)/\1, \2/g')"
    dependencies=${dependencies//|/ | }
    local manifest_path="../manifest.json"
    if [ ! -e "$manifest_path" ]; then
    	manifest_path="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
    fi

    local version=$(grep '\"version\": ' "$manifest_path" | cut -d '"' -f 4)	# Retrieve the version number in the manifest file.
    if [ ${#version} -eq 0 ]; then
        version="1.0"
    fi
    local dep_app=${app//_/-}	# Replace all '_' by '-'

    # Handle specific versions
    if [[ "$dependencies" =~ [\<=\>] ]]
    then
        # Replace version specifications by relationships syntax
        # https://www.debian.org/doc/debian-policy/ch-relationships.html
        # Sed clarification
        # [^(\<=\>] ignore if it begins by ( or < = >. To not apply twice.
        # [\<=\>] matches < = or >
        # \+ matches one or more occurence of the previous characters, for >= or >>.
        # [^,]\+ matches all characters except ','
        # Ex: package>=1.0 will be replaced by package (>= 1.0)
        dependencies="$(echo "$dependencies" | sed 's/\([^(\<=\>]\)\([\<=\>]\+\)\([^,]\+\)/\1 (\2 \3)/g')"
    fi

    cat > /tmp/${dep_app}-ynh-deps.control << EOF	# Make a control file for equivs-build
Section: misc
Priority: optional
Package: ${dep_app}-ynh-deps
Version: ${version}
Depends: ${dependencies}
Architecture: all
Description: Fake package for $app (YunoHost app) dependencies
 This meta-package is only responsible of installing its dependencies.
EOF
    ynh_package_install_from_equivs /tmp/${dep_app}-ynh-deps.control \
        || ynh_die --message="Unable to install dependencies"	# Install the fake package and its dependencies
    rm /tmp/${dep_app}-ynh-deps.control
    ynh_app_setting_set --app=$app --key=apt_dependencies --value="$dependencies"
}

ynh_add_app_dependencies () {
	# Declare an array to define the options of this helper.
	local legacy_args=pr
	declare -Ar args_array=( [p]=package= [r]=replace)
	local package
	local replace
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	replace=${replace:-0}

	local current_dependencies=""
	if [ $replace -eq 0 ]
	then
		local dep_app=${app//_/-}	# Replace all '_' by '-'
		if ynh_package_is_installed --package="${dep_app}-ynh-deps"
		then
			current_dependencies="$(dpkg-query --show --showformat='${Depends}' ${dep_app}-ynh-deps) "
		fi

		current_dependencies=${current_dependencies// | /|}
	fi

	ynh_install_app_dependencies "${current_dependencies}${package}"
}
