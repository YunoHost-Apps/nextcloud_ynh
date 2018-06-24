#!/bin/bash

# Last available nextcloud version
next_version="13.0.3"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="183667540800dd045ea57801fedf8ca280de82b91582412aad07d42ed71e93e4"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches
