#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION=11.0.3

# Nextcloud tarball checksum sha256
NEXTCLOUD_SOURCE_SHA256=28d5ee39f31c6be20f037ad2eb300272ad9bb72a7d428eb0152c7a3fde87d545

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
