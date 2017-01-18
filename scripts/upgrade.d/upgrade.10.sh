#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION="11.0.0"

# Nextcloud tarball checksum
NEXTCLOUD_SOURCE_SHA256="5bdfcb36c5cf470b9a6679034cabf88bf1e50a9f3e47c08d189cc2280b621429"

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
