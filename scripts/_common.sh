
#=================================================
# COMMON VARIABLES
#=================================================

pkg_dependencies="imagemagick libmagickcore-6.q16-6-extra acl tar smbclient at"

YNH_PHP_VERSION="7.3"
extra_php_dependencies="php${YNH_PHP_VERSION}-bz2 php${YNH_PHP_VERSION}-imap php${YNH_PHP_VERSION}-smbclient php${YNH_PHP_VERSION}-gmp php${YNH_PHP_VERSION}-gd php${YNH_PHP_VERSION}-json php${YNH_PHP_VERSION}-intl php${YNH_PHP_VERSION}-curl php${YNH_PHP_VERSION}-apcu php${YNH_PHP_VERSION}-redis php${YNH_PHP_VERSION}-ldap php${YNH_PHP_VERSION}-imagick php${YNH_PHP_VERSION}-zip php${YNH_PHP_VERSION}-mbstring php${YNH_PHP_VERSION}-xml php${YNH_PHP_VERSION}-mysql php${YNH_PHP_VERSION}-igbinary php${YNH_PHP_VERSION}-bcmath"

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

# Set ownership on files and directories with chown
#
# Use find to apply permissions faster on very big directories.
#
# usage: ynh_chown --user=user [--group=group] --file="file_or_directory" [--recursive]
# | arg: -u, --user - Owner
# | arg: -g, --group - Owner group (Default same as --user)
# | arg: -f, --file - File or directory where permissions will be applied.
# | arg: -r, --recursive - Change permissions recursively
ynh_chown () {
	# Declare an array to define the options of this helper.
	local legacy_args=ugfr
	declare -Ar args_array=( [u]=user= [g]=group= [f]=file= [r]=recursive )
	local user
	local group
	local file
	local recursive
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	group="${group:-$user}"
	recursive=${recursive:-0}

	if [ $recursive -eq 1 ]
	then
		local ending_slash=""
		if [ -d "$file" ]
		then
			ending_slash=/
		fi

		# With very big directories, find is way faster than chown itself.
		# Especially because find will check the permissions and apply chown only if the permissions aren't correct.
		# '\!' is used to have a negation on -user and -group.
		# ' -d '\n' ' forces \n to be the delimiter of each entry instead of space. So xargs will handle correctly directories and files with spaces.
		ynh_exec_warn_less "find \"$file$ending_slash\" \! -user $user -o \! -group $group | xargs --no-run-if-empty --delimiter='\n' chown --preserve-root $user:$group"
	else
		ynh_exec_warn_less chown $user:$group \"$file\"
	fi
}

# Set permissions on files and directories with chmod
#
# Use find to apply permissions faster on very big directories.
#
# usage: ynh_chmod --permissions=0755 --file="file_or_directory" [--recursive]  [--type=file/dir]
# | arg: -p, --permissions - Permissions to apply with chmod.
# | arg: -f, --file - File or directory where permissions will be applied.
# | arg: -r, --recursive - Change permissions recursively
# | arg: -t, --type - Apply permissions only on regular files (file) or directories (dir)
ynh_chmod () {
	# Declare an array to define the options of this helper.
	local legacy_args=pfrt
	declare -Ar args_array=( [p]=permissions= [f]=file= [r]=recursive [t]=type= )
	local permissions
	local file
	local recursive
	local type
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	recursive=${recursive:-0}
	type="${type:-}"

	if [ -n "$type" ] && [ "$type" != "file" ] && [ "$type" != "dir" ]
	then
		ynh_print_err --message="The value \"$type\" for --type is not recognized."
		type=""
	else
		if [ "$type" == "file" ]
		then
			type="-type f"
		elif [ "$type" == "dir" ]
		then
			type="-type d"
		fi
	fi

	if [ $recursive -eq 1 ]
	then
		local ending_slash=""
		if [ -d "$file" ]
		then
			ending_slash=/
		fi

		# With very big directories, find is way faster than chmod itself.
		# Especially because find will check the permissions and apply chmod only if the permissions aren't correct.
		# '\!' is used to have a negation on -perm.
		# ' -d '\n' ' forces \n to be the delimiter of each entry instead of space. So xargs will handle correctly directories and files with spaces.
		ynh_exec_warn_less "find \"$file$ending_slash\" $type \! -perm $permissions | xargs --no-run-if-empty --delimiter='\n' chmod --preserve-root $permissions"
	else
		ynh_exec_warn_less chmod $permissions \"$file\"
	fi
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
