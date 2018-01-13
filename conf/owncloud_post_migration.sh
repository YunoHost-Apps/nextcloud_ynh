#!/bin/bash

# Ending the migration process from Owncloud to Nextcloud

set -u

#=================================================
# IMPORT GENERIC HELPERS
#=================================================

source /usr/share/yunohost/helpers

#=================================================
# SET VARIABLES
#=================================================

old_app="__OLD_APP__"
new_app="__NEW_APP__"
script_name="$0"

#=================================================
# MOVE HOOKS
#=================================================

hooks_dir="/etc/yunohost/hooks.d/"
mv "$hooks_dir/post_user_create/50-$old_app" "$hooks_dir/post_user_create/50-$new_app"

#=================================================
# DELETE OLD APP'S SETTINGS
#=================================================

ynh_secure_remove "/etc/yunohost/apps/$old_app"
yunohost app ssowatconf

#=================================================
# REMOVE THE OLD USER
#=================================================

ynh_system_user_delete $old_app

#=================================================
# DELETE THIS SCRIPT
#=================================================

echo "rm $script_name" | at now + 1 minutes
