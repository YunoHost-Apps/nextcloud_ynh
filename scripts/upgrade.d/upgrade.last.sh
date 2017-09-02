#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION=12.0.2

# Nextcloud tarball checksum sha256
NEXTCLOUD_SOURCE_SHA256=eb34d6cb9f55ee84bf2ad847b4b08cdb925321848ffa2264a9b1566e7b21a17c

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE	# Met à jour Nextcloud vers la version suivante
