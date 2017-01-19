#!/bin/bash

# Préparation à la migration de owncloud 9 vers nextcloud.
# La migration sera effective lors de la mise à joru qui suivra

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Set app specific variables
app=$APPNAME
dbname=$app
dbuser=$app

# check that Nextcloud is not already installed
(sudo yunohost app list --installed -f "$app" | grep -q id) \
&& ynh_die "Nextcloud is already installed"

echo "Migration to nextcloud." >&2

# retrieve ownCloud app settings
real_app=$YNH_APP_INSTANCE_NAME	# real_app prend le nom de owncloud.
domain=$(ynh_app_setting_get "$real_app" domain)
oc_dbpass=$(ynh_app_setting_get "$real_app" mysqlpwd)
oc_dbname=$real_app
oc_dbuser=$real_app

# remove nginx and php-fpm configuration files
sudo rm -f \
	"/etc/nginx/conf.d/${domain}.d/${real_app}.conf" \
	"/etc/php5/fpm/pool.d/${real_app}.conf" \
	"/etc/cron.d/${real_app}"

# reload services to disable php-fpm and nginx config for ownCloud
sudo service php5-fpm reload || true
sudo service nginx reload || true

# remove dependencies package
ynh_package_remove owncloud-deps || true

# clean new destination and data directories
DESTDIR="/var/www/$app"
DATADIR="/home/yunohost.app/${app}/data"
SECURE_REMOVE '$DESTDIR'	# Supprime le dossier de nextcloud dans /var/www le cas échéant
SECURE_REMOVE '/home/yunohost.app/$app'	# Et dans yunohost.app

# rename ownCloud folders
sudo mv "/var/www/$real_app" "$DESTDIR"	# Puis renomme les dossiers de owncloud en nextcloud
sudo mv "/home/yunohost.app/$real_app" "/home/yunohost.app/$app"
sudo sed -ri "s#^(\s*'datadirectory' =>).*,#\1 '${DATADIR}',#" \
	"/var/www/${app}/config/config.php"	# Change l'emplacement du dossier de data dans le fichier de config

# rename the MySQL database
rename_mysql_db "$oc_dbname" "$oc_dbuser" "$oc_dbpass" "$dbname" "$dbuser"
sudo sed -ri "s#^(\s*'dbname' =>).*,#\1 '${dbname}',#" \
	"/var/www/${app}/config/config.php"
sudo sed -ri "s#^(\s*'dbuser' =>).*,#\1 '${dbuser}',#" \
	"/var/www/${app}/config/config.php"

# rename ownCloud system group and account
sudo groupmod -n "$app" "$real_app"
sudo usermod -l "$app" "$real_app"
