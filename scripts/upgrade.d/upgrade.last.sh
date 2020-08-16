#!/bin/bash

# Last available nextcloud version
next_version="19.0.1"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="4ef311e00d939915d3a9714cd3a1ad436db9157e04620e4a88c2f427e5e65b2d"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php${YNH_PHP_VERSION} occ db:add-missing-indices ; sudo -u $app php${YNH_PHP_VERSION} occ db:add-missing-columns ; sudo -u $app php${YNH_PHP_VERSION} occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
