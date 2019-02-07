#!/bin/bash

# Last available nextcloud version
next_version="15.0.4"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="f87db047c174f563e391a22c959d9ace767ca14ef0f97fc394f3061fc63d8f77"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php occ db:add-missing-indices ; sudo -u $app php occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
