#
# Common variables
#

APPNAME="owncloud"

# ownCloud version
VERSION="9.0.2"

# Package name for ownCloud dependencies
DEPS_PKG_NAME="owncloud-deps"

# Remote URL to fetch ownCloud tarball
OWNCLOUD_SOURCE_URL="https://download.owncloud.org/community/owncloud-${VERSION}.tar.bz2"

# Remote URL to fetch ownCloud tarball checksum
OWNCLOUD_SOURCE_SHA256="845c43fe981fa0fd07fc3708f41f1ea15ecb11c2a15c65a4de191fc85b237c74"

# App package root directory should be the parent folder
PKGDIR=$(cd ../; pwd)

#
# Common helpers
#

# Download and extract ownCloud sources to the given directory
# usage: extract_owncloud DESTDIR [AS_USER]
extract_owncloud() {
  local DESTDIR=$1
  local AS_USER=${2:-admin}

  # retrieve and extract Roundcube tarball
  oc_tarball="/tmp/owncloud.tar.bz2"
  rm -f "$oc_tarball"
  wget -q -O "$oc_tarball" "$OWNCLOUD_SOURCE_URL" \
    || ynh_die "Unable to download ownCloud tarball"
  echo "$OWNCLOUD_SOURCE_SHA256 $oc_tarball" | sha256sum -c >/dev/null \
    || ynh_die "Invalid checksum of downloaded tarball"
  exec_as "$AS_USER" tar xjf "$oc_tarball" -C "$DESTDIR" --strip-components 1 \
    || ynh_die "Unable to extract ownCloud tarball"
  rm -f "$oc_tarball"

  # apply patches
  (cd "$DESTDIR" \
   && for p in ${PKGDIR}/patches/*.patch; do \
        exec_as "$AS_USER" patch -p1 < $p; done) \
    || ynh_die "Unable to apply patches to ownCloud"
}

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" "$@"
  fi
}

# Execute a command with occ as a given user from a given directory
# usage: exec_occ WORKDIR AS_USER COMMAND [ARG ...]
exec_occ() {
  local WORKDIR=$1
  local AS_USER=$2
  shift 2

  (cd "$WORKDIR" && exec_as "$AS_USER" \
      php occ --no-interaction --no-ansi "$@")
}
