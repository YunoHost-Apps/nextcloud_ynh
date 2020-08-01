#!/bin/bash

# Last available nextcloud version
next_version="18.0.7"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="4b2cc7475d925faf9ce6c655d290cbbee8c02a40aaf0628d3d41b7ccd8416a5e"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php${YNH_PHP_VERSION} occ db:add-missing-indices ; sudo -u $app php${YNH_PHP_VERSION} occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
