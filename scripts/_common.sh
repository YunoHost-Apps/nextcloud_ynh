#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

wait_nginx_reload() {
    # NGINX may take some time to support the new configuration,
    # wait for the Nextcloud configuration file to disappear from NGINX before checking the CalDAV/CardDAV URL.
    timeout=30
    for i in $(seq 1 $timeout); do
        if ! ynh_exec_warn_less nginx -T | grep --quiet "# configuration file /etc/nginx/conf.d/$domain.d/$app.conf:"; then
            break
        fi
        sleep 1
    done
    # Wait untils NGINX has fully reloaded (avoid cURL fail with http2) 
    sleep 2
}

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

    # Try to get the URL with cURL, and keep the http code and an eventual redirection URL.
    local curl_output="$(curl --insecure --silent --output /dev/null \
      --write-out '%{http_code};%{redirect_url}' https://127.0.0.1$path --header "Host: $domain" --resolve $domain:443:127.0.0.1)"

    # Cut the output and keep only the first part to keep the http code
    local http_code="${curl_output%%;*}"
    # Do the same thing but keep the second part, the redirection URL
    local redirection="${curl_output#*;}"

    # Return 1 if the URL isn't handled.
    # Which means either cURL got a 404 (or the admin) or the SSO.
    # A handled URL should redirect to a publicly accessible URL.
    # Return 1 if the URL has returned 404
    if [ "$http_code" = "404" ] || [[ $redirection =~ "/yunohost/admin" ]]; then
        return 1
    # Return 1 if the URL is redirected to the SSO
    elif [[ $redirection =~ "/yunohost/sso" ]]; then
        return 1
    fi
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
