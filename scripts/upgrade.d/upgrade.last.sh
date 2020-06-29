#!/bin/bash

# Last available nextcloud version
next_version="18.0.5"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="52182fcdc289061f981100f53ccd411c35a10b81d1b88a934af9668c8055d753"

# This function will only be executed upon applying the last upgrade referenced above
last_upgrade_operations () {
  # Patch nextcloud files only for the last version
  cp -a ../sources/patches_last_version/* ../sources/patches

  # Execute post-upgrade operations later on
  (cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u $app php${YNH_PHP_VERSION} occ db:add-missing-indices ; sudo -u $app php${YNH_PHP_VERSION} occ db:convert-filecache-bigint -n) > /tmp/${app}_maintenance.log")
}
