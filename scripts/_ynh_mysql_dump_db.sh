#!/bin/bash

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