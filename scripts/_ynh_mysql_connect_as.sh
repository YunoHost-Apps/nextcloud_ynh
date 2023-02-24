#!/bin/bash

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