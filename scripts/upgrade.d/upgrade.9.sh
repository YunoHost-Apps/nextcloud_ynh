#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION="10.0.2"

# Nextcloud tarball checksum
NEXTCLOUD_SOURCE_SHA256="a687a818778413484f06bb23b4e98589c73729fe2aa9feb1bf5584e3bd37103c"

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
