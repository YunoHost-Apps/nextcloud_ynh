#!/bin/bash

# Last available nextcloud version
next_version="13.0.1"

# Nextcloud tarball checksum sha256
nextcloud_source_sha256="5743314a71e972ae46a14b36b37394d4545915aa5f32d9e12ba786d04c1f1d11"

# Patch nextcloud files only for the last version
cp -a ../sources/patches_last_version/* ../sources/patches
