#!/bin/bash

# Last available nextcloud version
next_version="15.0.8"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="b782599fa39919ecd96d93cfb6374f4d42cd6de22a9a2d12ec11ed38a2e5f2f0"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php occ db:add-missing-indices ; sudo -u $app php occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
