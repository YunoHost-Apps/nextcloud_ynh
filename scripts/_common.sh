
#=================================================
# COMMON VARIABLES
#=================================================

pkg_dependencies="php-gd php-json php-intl php-curl php-apcu php-redis php-ldap php-imagick php-zip php-mbstring php-xml imagemagick acl tar smbclient at"

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

# Check the amount of available RAM
#
# usage: ynh_check_ram [--required=RAM required in Mb] [--no_swap|--only_swap] [--free_ram]
# | arg: -r, --required= - Amount of RAM required in Mb. The helper will return 0 is there's enough RAM, or 1 otherwise.
# If --required isn't set, the helper will print the amount of RAM, in Mb.
# | arg: -s, --no_swap   - Ignore swap
# | arg: -o, --only_swap - Ignore real RAM, consider only swap.
# | arg: -f, --free_ram  - Count only free RAM, not the total amount of RAM available.
ynh_check_ram () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [r]=required= [s]=no_swap [o]=only_swap [f]=free_ram )
	local required
	local no_swap
	local only_swap
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	required=${required:-}
	no_swap=${no_swap:-0}
	only_swap=${only_swap:-0}

	local total_ram=$(vmstat --stats --unit M | grep "total memory" | awk '{print $1}')
	local total_swap=$(vmstat --stats --unit M | grep "total swap" | awk '{print $1}')
	local total_ram_swap=$(( total_ram + total_swap ))

	local free_ram=$(vmstat --stats --unit M | grep "free memory" | awk '{print $1}')
	local free_swap=$(vmstat --stats --unit M | grep "free swap" | awk '{print $1}')
	local free_ram_swap=$(( free_ram + free_swap ))

	# Use the total amount of ram
	local ram=$total_ram_swap
	if [ $free_ram -eq 1 ]
	then
		# Use the total amount of free ram
		ram=$free_ram_swap
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$free_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$free_swap
		fi
	else
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$total_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$total_swap
		fi
	fi

	if [ -n "$required" ]
	then
		# Return 1 if the amount of ram isn't enough.
		if [ $ram -lt $required ]
		then
			return 1
		else
			return 0
		fi

	# If no RAM is required, return the amount of available ram.
	else
		echo $ram
	fi
}

#=================================================

# Define the values to configure php-fpm
#
# usage: ynh_get_scalable_phpfpm --usage=usage --footprint=footprint [--print]
# | arg: -f, --footprint      - Memory footprint of the service (low/medium/high).
# low    - Less than 20Mb of ram by pool.
# medium - Between 20Mb and 40Mb of ram by pool.
# high   - More than 40Mb of ram by pool.
# Or specify exactly the footprint, the load of the service as Mb by pool instead of having a standard value.
# To have this value, use the following command and stress the service.
# watch -n0.5 ps -o user,cmd,%cpu,rss -u APP
#
# | arg: -u, --usage     - Expected usage of the service (low/medium/high).
# low    - Personal usage, behind the sso.
# medium - Low usage, few people or/and publicly accessible.
# high   - High usage, frequently visited website.
#
# | arg: -p, --print - Print the result
#
#
#
# The footprint of the service will be used to defined the maximum footprint we can allow, which is half the maximum RAM.
# So it will be used to defined 'pm.max_children'
# A lower value for the footprint will allow more children for 'pm.max_children'. And so for
#    'pm.start_servers', 'pm.min_spare_servers' and 'pm.max_spare_servers' which are defined from the
#    value of 'pm.max_children'
# NOTE: 'pm.max_children' can't exceed 4 times the number of processor's cores.
#
# The usage value will defined the way php will handle the children for the pool.
# A value set as 'low' will set the process manager to 'ondemand'. Children will start only if the
#   service is used, otherwise no child will stay alive. This config gives the lower footprint when the
#   service is idle. But will use more proc since it has to start a child as soon it's used.
# Set as 'medium', the process manager will be at dynamic. If the service is idle, a number of children
#   equal to pm.min_spare_servers will stay alive. So the service can be quick to answer to any request.
#   The number of children can grow if needed. The footprint can stay low if the service is idle, but
#   not null. The impact on the proc is a little bit less than 'ondemand' as there's always a few
#   children already available.
# Set as 'high', the process manager will be set at 'static'. There will be always as many children as
#   'pm.max_children', the footprint is important (but will be set as maximum a quarter of the maximum
#   RAM) but the impact on the proc is lower. The service will be quick to answer as there's always many
#   children ready to answer.
ynh_get_scalable_phpfpm () {
    local legacy_args=ufp
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [u]=usage= [f]=footprint= [p]=print )
    local usage
    local footprint
    local print
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    # Set all characters as lowercase
    footprint=${footprint,,}
    usage=${usage,,}
    print=${print:-0}

    if [ "$footprint" = "low" ]
    then
        footprint=20
    elif [ "$footprint" = "medium" ]
    then
        footprint=35
    elif [ "$footprint" = "high" ]
    then
        footprint=50
    fi

    # Define the way the process manager handle child processes.
    if [ "$usage" = "low" ]
    then
        php_pm=ondemand
    elif [ "$usage" = "medium" ]
    then
        php_pm=dynamic
    elif [ "$usage" = "high" ]
    then
        php_pm=static
    else
        ynh_die --message="Does not recognize '$usage' as an usage value."
    fi

    # Get the total of RAM available, except swap.
    local max_ram=$(ynh_check_ram --no_swap)

    less0() {
        # Do not allow value below 1
        if [ $1 -le 0 ]
        then
            echo 1
        else
            echo $1
        fi
    }

    # Define pm.max_children
    # The value of pm.max_children is the total amount of ram divide by 2 and divide again by the footprint of a pool for this app.
    # So if php-fpm start the maximum of children, it won't exceed half of the ram.
    php_max_children=$(( $max_ram / 2 / $footprint ))
    # If process manager is set as static, use half less children.
    # Used as static, there's always as many children as the value of pm.max_children
    if [ "$php_pm" = "static" ]
    then
        php_max_children=$(( $php_max_children / 2 ))
    fi
    php_max_children=$(less0 $php_max_children)

    # To not overload the proc, limit the number of children to 4 times the number of cores.
    local core_number=$(nproc)
    local max_proc=$(( $core_number * 4 ))
    if [ $php_max_children -gt $max_proc ]
    then
        php_max_children=$max_proc
    fi

    if [ "$php_pm" = "dynamic" ]
    then
        # Define pm.start_servers, pm.min_spare_servers and pm.max_spare_servers for a dynamic process manager
        php_min_spare_servers=$(( $php_max_children / 8 ))
        php_min_spare_servers=$(less0 $php_min_spare_servers)

        php_max_spare_servers=$(( $php_max_children / 2 ))
        php_max_spare_servers=$(less0 $php_max_spare_servers)

        php_start_servers=$(( $php_min_spare_servers + ( $php_max_spare_servers - $php_min_spare_servers ) /2 ))
        php_start_servers=$(less0 $php_start_servers)
    else
        php_min_spare_servers=0
        php_max_spare_servers=0
        php_start_servers=0
    fi

    if [ $print -eq 1 ]
    then
        ynh_debug --message="Footprint=${footprint}Mb by pool."
        ynh_debug --message="Process manager=$php_pm"
        ynh_debug --message="Max RAM=${max_ram}Mb"
        if [ "$php_pm" != "static" ]; then
            ynh_debug --message="\nMax estimated footprint=$(( $php_max_children * $footprint ))"
            ynh_debug --message="Min estimated footprint=$(( $php_min_spare_servers * $footprint ))"
        fi
        if [ "$php_pm" = "dynamic" ]; then
            ynh_debug --message="Estimated average footprint=$(( $php_max_spare_servers * $footprint ))"
        elif [ "$php_pm" = "static" ]; then
            ynh_debug --message="Estimated footprint=$(( $php_max_children * $footprint ))"
        fi
        ynh_debug --message="\nRaw php-fpm values:"
        ynh_debug --message="pm.max_children = $php_max_children"
        if [ "$php_pm" = "dynamic" ]; then
            ynh_debug --message="pm.start_servers = $php_start_servers"
            ynh_debug --message="pm.min_spare_servers = $php_min_spare_servers"
            ynh_debug --message="pm.max_spare_servers = $php_max_spare_servers"
        fi
    fi
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
