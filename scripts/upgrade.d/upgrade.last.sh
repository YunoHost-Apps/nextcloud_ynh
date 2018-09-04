#!/bin/bash

# Last available nextcloud version
next_version="13.0.6"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="90fc9e960b6a477bb14ee87042b3d158bde95c3f0157677cb4547ca7649968d4"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches
