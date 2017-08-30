#!/bin/bash

# Prepare the migration from owncloud to nextcloud

#=================================================
# GENERIC START
#=================================================
# IMPORT GENERIC HELPERS
#=================================================

source _common.sh
source /usr/share/yunohost/helpers

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST
#=================================================

app=$YNH_APP_INSTANCE_NAME

domain=$(ynh_app_setting_get $app domain)
oc_dbpass=$(ynh_app_setting_get $app mysqlpwd)
oc_dbname=$app
oc_dbuser=$app

#=================================================
# CHECK IF THE MIGRATION CAN BE DONE
#=================================================

# check that Nextcloud is not already installed
(yunohost app list --installed -f "$app" | grep -q id) \
&& ynh_die "Nextcloud is already installed"

echo "Migration to nextcloud." >&2

#=================================================
# REMOVE NGINX AND PHP-FPM CONFIG FILES
#=================================================

ynh_remove_nginx_config
ynh_remove_fpm_config

#=================================================
# REMOVE OLD DEPENDENCIES
#=================================================

ynh_package_remove owncloud-deps || true

#=================================================
# DELETE NEXTCLOUD DIRECTORIES
#=================================================

# Clean new destination and data directories
nextcloud_path="/var/www/$migration_name"
nextcloud_data="/home/yunohost.app/$migration_name/data"
ynh_secure_remove "$nextcloud_path"
ynh_secure_remove "/home/yunohost.app/$migration_name"

#=================================================
# RENAME OWNCLOUD DIRECTORIES
#=================================================

mv "/var/www/$app" "$nextcloud_path"
mv "/home/yunohost.app/$app" "/home/yunohost.app/$migration_name"

#=================================================
# CHANGE THE OWNCLOUD CONFIG
#=================================================

oc_conf=$nextcloud_path/config/config.php
# Change the path of the data file inf the config
ynh_replace_string "^(\s*'datadirectory' =>).*," "\1 '${DATADIR}'," "$oc_conf"

# Rename the MySQL database
db_name=$(ynh_sanitize_dbid $migration_name)
rename_mysql_db "$oc_dbname" "$oc_dbuser" "$oc_dbpass" "$db_name" "$db_name"
ynh_replace_string "^(\s*'dbname' =>).*," "\1 '${db_name}'," "$oc_conf"
ynh_replace_string "^(\s*'dbuser' =>).*," "\1 '${db_name}'," "$oc_conf"

#=================================================
# RENAME OWNCLOUD USER
#=================================================

groupmod -n "$migration_name" "$app"
usermod -l "$migration_name" "$app"
