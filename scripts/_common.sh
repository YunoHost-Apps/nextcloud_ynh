#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

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

# Adapted from nginx helpers
ynh_add_nginx_notify_push_config() {

    local finalnginxconf="/etc/nginx/conf.d/$domain.d/${app}_notify_push.conf"

    ynh_add_config --template="nginx_notify_push.conf" --destination="$finalnginxconf"

    if [ "${path_url:-}" != "/" ]; then
        ynh_replace_string --match_string="^#sub_path_only" --replace_string="" --target_file="$finalnginxconf"
    else
        ynh_replace_string --match_string="^#root_path_only" --replace_string="" --target_file="$finalnginxconf"
    fi

    ynh_store_file_checksum --file="$finalnginxconf"

    ynh_systemd_action --service_name=nginx --action=reload
}

ynh_remove_nginx_notify_push_config() {
    ynh_secure_remove --file="/etc/nginx/conf.d/$domain.d/${app}_notify_push.conf"
    ynh_systemd_action --service_name=nginx --action=reload
}


ynh_change_url_nginx_notify_push_config() {

    # Make a backup of the original NGINX config file if manually modified
    # (nb: this is possibly different from the same instruction called by
    # ynh_add_config inside ynh_add_nginx_notify_push_config because the path may have 
    # changed if we're changing the domain too...)
    local old_nginx_conf_path=/etc/nginx/conf.d/$old_domain.d/${app}_notify_push.conf
    ynh_backup_if_checksum_is_different --file="$old_nginx_conf_path"
    ynh_delete_file_checksum --file="$old_nginx_conf_path"
    ynh_secure_remove --file="$old_nginx_conf_path"

    # Regen the nginx conf
    ynh_add_nginx_notify_push_config
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
