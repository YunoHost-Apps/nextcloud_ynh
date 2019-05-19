#!/bin/bash

# Last available nextcloud version
next_version="16.0.1"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="a80ce586e9e930b2fba69707311e575346cd4dc4402e84678c730f9930d78aee"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php occ db:add-missing-indices ; sudo -u $app php occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
