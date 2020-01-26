#!/bin/bash

# Last available nextcloud version
next_version="17.0.0"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="6081421b33ecdb3130b2bfb2293a3f4045aeb0b471ee570e675de3d931a142a6"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php occ db:add-missing-indices ; sudo -u $app php occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
