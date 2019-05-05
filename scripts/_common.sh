
#=================================================
# COMMON VARIABLES
#=================================================

pkg_dependencies="php-gd php-json php-intl php-mcrypt php-curl php-apcu php-redis php-ldap php-imagick php-zip php-mbstring php-xml imagemagick acl tar smbclient at"

#=================================================
# UNSTABLE HELPERS
#=================================================

# Start (or other actions) a service,  print a log in case of failure and optionnaly wait until the service is completely started
#
# usage: ynh_systemd_action [-n service_name] [-a action] [ [-l "line to match"] [-p log_path] [-t timeout] [-e length] ]
# | arg: -n, --service_name= - Name of the service to start. Default : $app
# | arg: -a, --action=       - Action to perform with systemctl. Default: start
# | arg: -l, --line_match=   - Line to match - The line to find in the log to attest the service have finished to boot.
#                              If not defined it don't wait until the service is completely started.
#                              WARNING: When using --line_match, you should always add `ynh_clean_check_starting` into your
#                                `ynh_clean_setup` at the beginning of the script. Otherwise, tail will not stop in case of failure
#                                of the script. The script will then hang forever.
# | arg: -p, --log_path=     - Log file - Path to the log file. Default : /var/log/$app/$app.log
# | arg: -t, --timeout=      - Timeout - The maximum time to wait before ending the watching. Default : 300 seconds.
# | arg: -e, --length=       - Length of the error log : Default : 20
ynh_systemd_action() {
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [n]=service_name= [a]=action= [l]=line_match= [p]=log_path= [t]=timeout= [e]=length= )
    local service_name
    local action
    local line_match
    local length
    local log_path
    local timeout

    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    local service_name="${service_name:-$app}"
    local action=${action:-start}
    local log_path="${log_path:-/var/log/$service_name/$service_name.log}"
    local length=${length:-20}
    local timeout=${timeout:-300}

    # Start to read the log
    if [[ -n "${line_match:-}" ]]
    then
        local templog="$(mktemp)"
        # Following the starting of the app in its log
        if [ "$log_path" == "systemd" ] ; then
            # Read the systemd journal
            journalctl --unit=$service_name --follow --since=-0 --quiet > "$templog" &
            # Get the PID of the journalctl command
            local pid_tail=$!
        else
            # Read the specified log file
            tail -F -n0 "$log_path" > "$templog" 2>&1 &
            # Get the PID of the tail command
            local pid_tail=$!
        fi
    fi

    ynh_print_info --message="${action^} the service $service_name"

    # Use reload-or-restart instead of reload. So it wouldn't fail if the service isn't running.
    if [ "$action" == "reload" ]; then
        action="reload-or-restart"
    fi

    systemctl $action $service_name \
        || ( journalctl --no-pager --lines=$length -u $service_name >&2 \
        ; test -e "$log_path" && echo "--" >&2 && tail --lines=$length "$log_path" >&2 \
        ; false )

    # Start the timeout and try to find line_match
    if [[ -n "${line_match:-}" ]]
    then
        local i=0
        for i in $(seq 1 $timeout)
        do
            # Read the log until the sentence is found, that means the app finished to start. Or run until the timeout
            if grep --quiet "$line_match" "$templog"
            then
                ynh_print_info --message="The service $service_name has correctly started."
                break
            fi
            if [ $i -eq 3 ]; then
                echo -n "Please wait, the service $service_name is ${action}ing" >&2
            fi
            if [ $i -ge 3 ]; then
                echo -n "." >&2
            fi
            sleep 1
        done
        if [ $i -ge 3 ]; then
            echo "" >&2
        fi
        if [ $i -eq $timeout ]
        then
            ynh_print_warn --message="The service $service_name didn't fully started before the timeout."
            ynh_print_warn --message="Please find here an extract of the end of the log of the service $service_name:"
            journalctl --no-pager --lines=$length -u $service_name >&2
            test -e "$log_path" && echo "--" >&2 && tail --lines=$length "$log_path" >&2
        fi
        ynh_clean_check_starting
    fi
}

# Create a dedicated fail2ban config (jail and filter conf files)
#
# usage 1: ynh_add_fail2ban_config --logpath=log_file --failregex=filter [--max_retry=max_retry] [--ports=ports]
# | arg: -l, --logpath=   - Log file to be checked by fail2ban
# | arg: -r, --failregex= - Failregex to be looked for by fail2ban
# | arg: -m, --max_retry= - Maximum number of retries allowed before banning IP address - default: 3
# | arg: -p, --ports=     - Ports blocked for a banned IP address - default: http,https
#
# -----------------------------------------------------------------------------
#
# usage 2: ynh_add_fail2ban_config --use_template [--others_var="list of others variables to replace"]
# | arg: -t, --use_template - Use this helper in template mode
# | arg: -v, --others_var=  - List of others variables to replace separeted by a space
# |                           for example : 'var_1 var_2 ...'
#
# This will use a template in ../conf/f2b_jail.conf and ../conf/f2b_filter.conf
#   __APP__      by  $app
#
#  You can dynamically replace others variables by example :
#   __VAR_1__    by $var_1
#   __VAR_2__    by $var_2
#
# Generally your template will look like that by example (for synapse):
#
# f2b_jail.conf:
#     [__APP__]
#     enabled = true
#     port = http,https
#     filter = __APP__
#     logpath = /var/log/__APP__/logfile.log
#     maxretry = 3
#
# f2b_filter.conf:
#     [INCLUDES]
#     before = common.conf
#     [Definition]
#
#     # Part of regex definition (just used to make more easy to make the global regex)
#     __synapse_start_line = .? \- synapse\..+ \-
#
#    # Regex definition.
#    failregex = ^%(__synapse_start_line)s INFO \- POST\-(\d+)\- <HOST> \- \d+ \- Received request\: POST /_matrix/client/r0/login\??<SKIPLINES>%(__synapse_start_line)s INFO \- POST\-\1\- Got login request with identifier: \{u'type': u'm.id.user', u'user'\: u'(.+?)'\}, medium\: None, address: None, user\: u'\5'<SKIPLINES>%(__synapse_start_line)s WARNING \- \- (Attempted to login as @\5\:.+ but they do not exist|Failed password login for user @\5\:.+)$
#
#     ignoreregex =
#
# -----------------------------------------------------------------------------
#
# Note about the "failregex" option:
#          regex to match the password failure messages in the logfile. The
#          host must be matched by a group named "host". The tag "<HOST>" can
#          be used for standard IP/hostname matching and is only an alias for
#          (?:::f{4,6}:)?(?P<host>[\w\-.^_]+)
#
#          You can find some more explainations about how to make a regex here :
#          https://www.fail2ban.org/wiki/index.php/MANUAL_0_8#Filters
#
# Note that the logfile need to exist before to call this helper !!
#
# To validate your regex you can test with this command:
# fail2ban-regex /var/log/YOUR_LOG_FILE_PATH /etc/fail2ban/filter.d/YOUR_APP.conf
#
# Requires YunoHost version 3.?.? or higher.
ynh_add_fail2ban_config () {
  # Declare an array to define the options of this helper.
  local legacy_args=lrmptv
  declare -Ar args_array=( [l]=logpath= [r]=failregex= [m]=max_retry= [p]=ports= [t]=use_template [v]=others_var=)
  local logpath
  local failregex
  local max_retry
  local ports
  local others_var
  local use_template
  # Manage arguments with getopts
  ynh_handle_getopts_args "$@"
  use_template="${use_template:-0}"
  max_retry=${max_retry:-3}
  ports=${ports:-http,https}

  finalfail2banjailconf="/etc/fail2ban/jail.d/$app.conf"
  finalfail2banfilterconf="/etc/fail2ban/filter.d/$app.conf"
  ynh_backup_if_checksum_is_different "$finalfail2banjailconf"
  ynh_backup_if_checksum_is_different "$finalfail2banfilterconf"

  if [ $use_template -eq 1 ]
  then
    # Usage 2, templates
    cp ../conf/f2b_jail.conf $finalfail2banjailconf
    cp ../conf/f2b_filter.conf $finalfail2banfilterconf

    if [ -n "${app:-}" ]
    then
      ynh_replace_string "__APP__" "$app" "$finalfail2banjailconf"
      ynh_replace_string "__APP__" "$app" "$finalfail2banfilterconf"
    fi

    # Replace all other variable given as arguments
    for var_to_replace in ${others_var:-}; do
      # ${var_to_replace^^} make the content of the variable on upper-cases
      # ${!var_to_replace} get the content of the variable named $var_to_replace
      ynh_replace_string --match_string="__${var_to_replace^^}__" --replace_string="${!var_to_replace}" --target_file="$finalfail2banjailconf"
      ynh_replace_string --match_string="__${var_to_replace^^}__" --replace_string="${!var_to_replace}" --target_file="$finalfail2banfilterconf"
    done

  else
    # Usage 1, no template. Build a config file from scratch.
    test -n "$logpath" || ynh_die "ynh_add_fail2ban_config expects a logfile path as first argument and received nothing."
    test -n "$failregex" || ynh_die "ynh_add_fail2ban_config expects a failure regex as second argument and received nothing."

    tee $finalfail2banjailconf <<EOF
[$app]
enabled = true
port = $ports
filter = $app
logpath = $logpath
maxretry = $max_retry
EOF

    tee $finalfail2banfilterconf <<EOF
[INCLUDES]
before = common.conf
[Definition]
failregex = $failregex
ignoreregex =
EOF
  fi

  # Common to usage 1 and 2.
  ynh_store_file_checksum "$finalfail2banjailconf"
  ynh_store_file_checksum "$finalfail2banfilterconf"

  systemctl try-reload-or-restart fail2ban

  local fail2ban_error="$(journalctl -u fail2ban | tail -n50 | grep "WARNING.*$app.*")"
  if [[ -n "$fail2ban_error" ]]; then
    ynh_print_err --message="Fail2ban failed to load the jail for $app"
    ynh_print_warn --message="${fail2ban_error#*WARNING}"
  fi
}

# Remove the dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_remove_fail2ban_config
#
# Requires YunoHost version 3.?.? or higher.
ynh_remove_fail2ban_config () {
  ynh_secure_remove "/etc/fail2ban/jail.d/$app.conf"
  ynh_secure_remove "/etc/fail2ban/filter.d/$app.conf"
  systemctl try-reload-or-restart fail2ban
}

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

ynh_smart_mktemp () {
        local min_size="${1:-300}"
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

ynh_smart_mktemp () {
        local min_size="${1:-300}"
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
