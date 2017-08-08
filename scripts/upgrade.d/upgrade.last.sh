#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION=12.0.1

# Nextcloud tarball checksum sha256
NEXTCLOUD_SOURCE_SHA256=5288f645348eddc1a7768825678bd19f110cec585a16f98b52c64389358c74bc

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
