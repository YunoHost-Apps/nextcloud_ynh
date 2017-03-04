#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION=11.0.2

# Nextcloud tarball checksum sha256
NEXTCLOUD_SOURCE_SHA256=5d1ef19d8f1f340b46c05ba3741dcb043dfc84fc3b9e2cfce1409c71a89b8700

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
