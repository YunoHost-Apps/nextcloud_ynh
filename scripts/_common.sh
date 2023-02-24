#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

YNH_PHP_VERSION="8.1"

php_dependencies="php${YNH_PHP_VERSION}-fpm php${YNH_PHP_VERSION}-bz2 php${YNH_PHP_VERSION}-imap php${YNH_PHP_VERSION}-gmp php${YNH_PHP_VERSION}-gd php${YNH_PHP_VERSION}-intl php${YNH_PHP_VERSION}-curl php${YNH_PHP_VERSION}-apcu php${YNH_PHP_VERSION}-redis php${YNH_PHP_VERSION}-ldap php${YNH_PHP_VERSION}-imagick php${YNH_PHP_VERSION}-zip php${YNH_PHP_VERSION}-mbstring php${YNH_PHP_VERSION}-xml php${YNH_PHP_VERSION}-mysql php${YNH_PHP_VERSION}-igbinary php${YNH_PHP_VERSION}-bcmath"

pkg_dependencies="imagemagick libmagickcore-6.q16-6-extra acl tar smbclient at $php_dependencies"

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Check if an URL is already handled
# usage: is_url_handled --domain=DOMAIN --path=PATH_URI
is_url_handled() {
    # Declare an array to define the options of this helper.
    local legacy_args=dp
    declare -Ar args_array=( [d]=domain= [p]=path= )
    local domain
    local path
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    # Try to get the url with curl, and keep the http code and an eventual redirection url.
    local curl_output="$(curl --insecure --silent --output /dev/null \
      --write-out '%{http_code};%{redirect_url}' https://127.0.0.1$path --header "Host: $domain" --resolve $domain:443:127.0.0.1)"

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

        echo "$(mktemp --directory --tmpdir="$tmpdir")"
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

# Open a connection as a user
#
# example: ynh_mysql_connect_as --user="user" --password="pass" <<< "UPDATE ...;"
# example: ynh_mysql_connect_as --user="user" --password="pass" --default_character_set="utf8mb4" < /path/to/file.sql
#
# usage: ynh_mysql_connect_as --user=user --password=password [--database=database] [--default_character_set=character-set]
# | arg: -u, --user=                        - the user name to connect as
# | arg: -p, --password=                    - the user password
# | arg: -d, --database=                    - the database to connect to
# | arg: -c, --default_character_set=       - the charset to use
#
# Requires YunoHost version 2.2.4 or higher.
ynh_mysql_connect_as() {
    # Declare an array to define the options of this helper.
    local legacy_args=updc
    local -A args_array=( [u]=user= [p]=password= [d]=database= [c]=default_character_set= )
    local user
    local password
    local database
    local default_character_set
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    database="${database:-}"
    default_character_set="${default_character_set:-}"

    if [ -n "$default_character_set" ]
    then
        default_character_set="--default-character-set=$default_character_set"
    else
        default_character_set="--default-character-set=latin1"
    fi

    mysql --user="$user" --password="$password" "$default_character_set" --batch "$database"
}



# Dump a database
#
# example: ynh_mysql_dump_db --database=roundcube --default_character_set="utf8mb4" > ./dump.sql
#
# usage: ynh_mysql_dump_db --database=database
# | arg: -d, --database=                    - the database name to dump
# | arg: -c, --default_character_set=       - the charset to use
# | ret: the mysqldump output
#
# Requires YunoHost version 2.2.4 or higher.
ynh_mysql_dump_db() {
    # Declare an array to define the options of this helper.
    local legacy_args=dc
    local -A args_array=( [d]=database= [c]=default_character_set= )
    local database
    local default_character_set
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    default_character_set="${default_character_set:-}"
    MYSQL_ROOT_PWD_FILE=/etc/yunohost/mysql

    if [ -n "$default_character_set" ]
    then
        default_character_set="--default-character-set=$default_character_set"
    else
        # By default, default character set is "latin1"
        default_character_set="--default-character-set=latin1"
    fi
    
    if [ -f "$MYSQL_ROOT_PWD_FILE" ]; then
        mysqldump --user="root" --password="$(cat $MYSQL_ROOT_PWD_FILE)" --single-transaction --skip-dump-date "$default_character_set" "$database"
    else
        mysqldump --single-transaction --skip-dump-date "$default_character_set" "$database"
    fi
}
