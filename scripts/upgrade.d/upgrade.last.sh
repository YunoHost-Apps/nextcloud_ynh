#!/bin/bash

# Last available nextcloud version
next_version="15.0.5"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="4661869b797a340cd967abb3dbe6931b375434e0a44480346a27ccd73250b988"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php occ db:add-missing-indices ; sudo -u $app php occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
