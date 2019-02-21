#!/bin/bash

# Last available nextcloud version
next_version="15.0.0"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="5bb0c58171353da844019b64080c21078002a59ab956ab72adb958844a98eb78"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches

# Execute post-upgrade operations later on
(cd /tmp ; at now + 10 minutes <<< "(cd $final_path ; sudo -u nextcloud php occ db:add-missing-indices ; sudo -u nextcloud php occ db:convert-filecache-bigint -n) > /tmp/nextcloud_maintenance.log")
