#!/bin/bash

# Version cible de la mise à jour de Nextcloud
VERSION="12.0.0"

# Nextcloud tarball checksum
NEXTCLOUD_SOURCE_SHA256="1b9d9cf05e657cd564a552b418fbf42d669ca51e0fd1f1f118fe44cbf93a243f"

# Load common variables and helpers
source ./_common.sh

# Source app helpers
source /usr/share/yunohost/helpers

# Load common upgrade function
source ./upgrade.d/upgrade.generic.sh

COMMON_UPGRADE # Met à jour Nextcloud vers la version suivante
