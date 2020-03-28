#!/bin/bash

# Last available nextcloud version
next_version="18.0.3"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="7b67e709006230f90f95727f9fa92e8c73a9e93458b22103293120f9cb50fd72"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php${YNH_PHP_VERSION} occ db:add-missing-indices ; sudo -u $app php${YNH_PHP_VERSION} occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
