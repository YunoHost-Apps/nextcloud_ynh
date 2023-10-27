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
