
#=================================================
# COMMON VARIABLES
#=================================================

dependencies="php5-gd php5-json php5-intl php5-mcrypt php5-curl php5-apcu php5-imagick acl tar smbclient"

#=================================================
# COMMON HELPERS
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

# Check if an URL is already handled
# usage: is_url_handled URL
is_url_handled() {
  local output=($(curl -k -s -o /dev/null \
      -w 'x%{redirect_url} %{http_code}' "$1"))
  # It's handled if it does not redirect to the SSO nor return 404
  [[ ! ${output[0]} =~ \/yunohost\/sso\/ && ${output[1]} != 404 ]]
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
