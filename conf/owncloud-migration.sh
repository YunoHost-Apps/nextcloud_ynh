#!/bin/bash

set -u

app="#APP#"

# rename hook
hooks_dir="/etc/yunohost/hooks.d/post_user_create"
[[ -f "${hooks_dir}/50-${app}" ]] \
  && mv "${hooks_dir}/50-${app}" "${hooks_dir}/50-nextcloud"

# move yunohost app settings
apps_dir="/etc/yunohost/apps"
if [[ -d "${apps_dir}/${app}" ]]; then
  yunohost app setting "$app" id -v nextcloud
  mv "${apps_dir}/${app}" "${apps_dir}/nextcloud"
  yunohost app ssowatconf --quiet
fi

# remove cron job
rm /etc/cron.d/owncloud-migration
