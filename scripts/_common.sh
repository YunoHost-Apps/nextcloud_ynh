#
# Common variables
#

APPNAME="nextcloud"

# Nextcloud version
LAST_VERSION=$(grep "VERSION=" "upgrade.d/upgrade.last.sh" | cut -d= -f2)

# Package name for Nextcloud dependencies
DEPS_PKG_NAME="nextcloud-deps"

# App package root directory should be the parent folder
PKGDIR=$(cd ../; pwd)

#
# Common helpers
#

# Download and extract Nextcloud sources to the given directory
# usage: extract_nextcloud DESTDIR [AS_USER]
extract_nextcloud() {
  # Remote URL to fetch Nextcloud tarball
  NEXTCLOUD_SOURCE_URL="https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2"

  local DESTDIR=$1
  local AS_USER=${2:-admin}

  # retrieve and extract Roundcube tarball
  nc_tarball="/tmp/nextcloud.tar.bz2"
  rm -f "$nc_tarball"
  wget -q -O "$nc_tarball" "$NEXTCLOUD_SOURCE_URL" \
    || ynh_die "Unable to download Nextcloud tarball"
  echo "$NEXTCLOUD_SOURCE_SHA256 $nc_tarball" | sha256sum -c >/dev/null \
    || ynh_die "Invalid checksum of downloaded tarball"
  exec_as "$AS_USER" tar xjf "$nc_tarball" -C "$DESTDIR" --strip-components 1 \
    || ynh_die "Unable to extract Nextcloud tarball"
  rm -f "$nc_tarball"

  # apply patches
  (cd "$DESTDIR" \
   && for p in ${PKGDIR}/patches/*.patch; do \
        exec_as "$AS_USER" patch -p1 < $p; done) \
    || ynh_die "Unable to apply patches to Nextcloud"
}

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" "$@"
  fi
}

# Execute a command with occ as a given user from a given directory
# usage: exec_occ WORKDIR AS_USER COMMAND [ARG ...]
exec_occ() {
  local WORKDIR=$1
  local AS_USER=$2
  shift 2

  (cd "$WORKDIR" && exec_as "$AS_USER" \
      php occ --no-interaction --no-ansi "$@")
}

# Create the external storage for the home folders and enable sharing
# usage: create_home_external_storage OCC_COMMAND
create_home_external_storage() {
  local OCC=$1
  local mount_id=`$OCC files_external:create --output=json \
      'Home' 'local' 'null::null' -c 'datadir=/home/$user' || true`
  ! [[ $mount_id =~ ^[0-9]+$ ]] \
    && echo "Unable to create external storage" 1>&2 \
    || $OCC files_external:option "$mount_id" enable_sharing true
}

# Check if an URL is already handled
# usage: is_url_handled URL
is_url_handled() {
  local OUTPUT=($(curl -k -s -o /dev/null \
      -w 'x%{redirect_url} %{http_code}' "$1"))
  # it's handled if it does not redirect to the SSO nor return 404
  [[ ! ${OUTPUT[0]} =~ \/yunohost\/sso\/ && ${OUTPUT[1]} != 404 ]]
}

# Rename a MySQL database and user
# usage: rename_mysql_db DBNAME DBUSER DBPASS NEW_DBNAME NEW_DBUSER
rename_mysql_db() {
  local DBNAME=$1 DBUSER=$2 DBPASS=$3 NEW_DBNAME=$4 NEW_DBUSER=$5
  local SQLPATH="/tmp/${DBNAME}-$(date '+%s').sql"

  # dump the old database
  mysqldump -u "$DBUSER" -p"$DBPASS" --no-create-db "$DBNAME" > "$SQLPATH"
  # create the new database and user
  ynh_mysql_create_db "$NEW_DBNAME" "$NEW_DBUSER" "$DBPASS"
  ynh_mysql_connect_as "$NEW_DBUSER" "$DBPASS" "$NEW_DBNAME" < "$SQLPATH"
  # remove the old database
  ynh_mysql_drop_db "$DBNAME"
  ynh_mysql_drop_user "$DBUSER"
  rm "$SQLPATH"
}

SECURE_REMOVE () {      # Suppression de dossier avec vérification des variables
	chaine="$1"	# L'argument doit être donné entre quotes simple '', pour éviter d'interpréter les variables.
	no_var=0
	while (echo "$chaine" | grep -q '\$')	# Boucle tant qu'il y a des $ dans la chaine
	do
		no_var=1
		global_var=$(echo "$chaine" | cut -d '$' -f 2)	# Isole la première variable trouvée.
		only_var=\$$(expr "$global_var" : '\([A-Za-z0-9_]*\)')	# Isole complètement la variable en ajoutant le $ au début et en gardant uniquement le nom de la variable. Se débarrasse surtout du / et d'un éventuel chemin derrière.
		real_var=$(eval "echo ${only_var}")		# `eval "echo ${var}` permet d'interpréter une variable contenue dans une variable.
		if test -z "$real_var" || [ "$real_var" = "/" ]; then
			echo "Variable $only_var is empty, suppression of $chaine cancelled." >&2
			return 1
		fi
		chaine=$(echo "$chaine" | sed "s@$only_var@$real_var@")	# remplace la variable par sa valeur dans la chaine.
	done
	if [ "$no_var" -eq 1 ]
	then
		if [ -e "$chaine" ]; then
			echo "Delete directory $chaine"
			sudo rm -rf "$chaine"
		fi
		return 0
	else
		echo "No detected variable." >&2
		return 1
	fi
}

#=================================================
# FUTURE YUNOHOST HELPERS - TO BE REMOVED LATER
#=================================================

# Use logrotate to manage the logfile
#
# usage: ynh_use_logrotate [logfile]
# | arg: logfile - absolute path of logfile
#
# If no argument provided, a standard directory will be use. /var/log/${app}
# You can provide a path with the directory only or with the logfile.
# /parentdir/logdir/
# /parentdir/logdir/logfile.log
#
# It's possible to use this helper several times, each config will added to same logrotate config file.
ynh_use_logrotate () {
	if [ "$#" -gt 0 ]; then
		if [ "$(echo ${1##*.})" == "log" ]; then	# Keep only the extension to check if it's a logfile
			logfile=$1	# In this case, focus logrotate on the logfile
		else
			logfile=$1/.log	# Else, uses the directory and all logfile into it.
		fi
	else
		logfile="/var/log/${app}/.log" # Without argument, use a defaut directory in /var/log
	fi
	cat > ./${app}-logrotate << EOF	# Build a config file for logrotate
$logfile {
		# Rotate if the logfile exceeds 100Mo
	size 100M
		# Keep 12 old log maximum
	rotate 12
		# Compress the logs with gzip
	compress
		# Compress the log at the next cycle. So keep always 2 non compressed logs
	delaycompress
		# Copy and truncate the log to allow to continue write on it. Instead of move the log.
	copytruncate
		# Do not do an error if the log is missing
	missingok
		# Not rotate if the log is empty
	notifempty
		# Keep old logs in the same dir
	noolddir
}
EOF
	sudo mkdir -p $(dirname "$logfile")	# Create the log directory, if not exist
	cat ${app}-logrotate | sudo tee -a /etc/logrotate.d/$app > /dev/null	# Append this config to the others for this app. If a config file already exist
}

# Remove the app's logrotate config.
#
# usage: ynh_remove_logrotate
ynh_remove_logrotate () {
	if [ -e "/etc/logrotate.d/$app" ]; then
		sudo rm "/etc/logrotate.d/$app"
	fi
}

ynh_add_fail2ban_config () {
   # Process parameters
   logpath=$1
   failregex=$2
   max_retry=${3:-3}
   ports=${4:-http,https}
   
  test -n "$logpath" || ynh_die "ynh_add_fail2ban_config expects a logfile path as first argument and received nothing."
  test -n "$failregex" || ynh_die "ynh_add_fail2ban_config expects a failure regex as second argument and received nothing."
  
	finalfail2banjailconf="/etc/fail2ban/jail.d/$app.conf"
	finalfail2banfilterconf="/etc/fail2ban/filter.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalfail2banjailconf" 1
	ynh_backup_if_checksum_is_different "$finalfail2banfilterconf" 1
  
  echo | sudo tee $finalfail2banjailconf <<EOF
[$app]
enabled = true
port = $ports
filter = $app
logpath = $logpath
maxretry = $max_retry" 
EOF

  echo | sudo tee $finalfail2banfilterconf <<EOF
[INCLUDES]
before = common.conf
[Definition]
failregex = $failregex
ignoreregrex =" 
EOF

	ynh_store_file_checksum "$finalfail2banjailconf"
	ynh_store_file_checksum "$finalfail2banfilterconf"
  
	sudo systemctl restart fail2ban
}

# Remove the dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_remove_fail2ban_config
ynh_remove_fail2ban_config () {
	ynh_secure_remove "/etc/fail2ban/jail.d/$app.conf"
  ynh_secure_remove "/etc/fail2ban/filter.d/$app.conf"
	sudo systemctl restart fail2ban
}
