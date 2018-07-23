#!/bin/bash

# Last available nextcloud version
next_version="13.0.5"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="a110d32849259ab79813af3078123a09057fc659ee414e5f3ed75451ec9e80ea"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches
