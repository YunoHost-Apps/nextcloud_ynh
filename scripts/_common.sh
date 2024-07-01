#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Check if an URL is already handled
# usage: is_url_handled --domain=DOMAIN --path=PATH_URI
is_url_handled() {
    # Declare an array to define the options of this helper.
    #REMOVEME? local legacy_args=dp
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
