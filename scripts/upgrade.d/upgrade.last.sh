#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION="11.0.1"

# Nextcloud tarball checksum sha256
NEXTCLOUD_SOURCE_SHA256="00162bf454914a2acbe6a9ac47c9db9f411b99064f0736b43e73cabbd87f4629"

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
