#!/bin/bash

# Last available nextcloud version
next_version="14.0.4"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="4f5dd15a71694bd2f15fba0d2f942e5a5b1f5aba13511c507a23324d746b40e8"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches

# Execute post-upgrade operations later on
(cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u nextcloud php occ db:add-missing-indices ; sudo -u nextcloud php occ db:convert-filecache-bigint -n) > /tmp/nextcloud_maintenance.log")
