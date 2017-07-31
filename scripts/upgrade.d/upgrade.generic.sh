#!/bin/bash

# Fonction rassemblant les opérations communes de mise à jour.

# occ helper for the current installation
_exec_occ() {
  exec_occ "$DESTDIR" "$app" $@	# Appel de php occ avec les droits de l'user nextcloud. A noter que ce n'est là que la déclaration de la fonction qui sera appelée plus tard.
}

COMMON_UPGRADE () {
	app=$APPNAME
	DESTDIR="/var/www/$app"
	DATADIR="/home/yunohost.app/$app/data"
	domain=$(ynh_app_setting_get "$YNH_APP_INSTANCE_NAME" domain)	# Utilise $YNH_APP_INSTANCE_NAME au lieu de $app pour utiliser la config de owncloud en cas de migration

	echo -e "\nUpdate to nextcloud $VERSION" >&2

	# Retrieve new Nextcloud sources in a temporary directory
	TMPDIR=$(mktemp -d)

	# Set temp folder ownership
	sudo chown -R $app: "$TMPDIR"
	extract_nextcloud "$TMPDIR"	"$app" # Télécharge nextcloud, vérifie sa somme de contrôle et le décompresse.

	# Copy Nextcloud configuration file
	sed -i "s@#DOMAIN#@${domain}@g" ../conf/config.json
	sed -i "s@#DATADIR#@${DATADIR}@g" ../conf/config.json
	sudo cp ../conf/config.json "${TMPDIR}/config.json"

	# Enable maintenance mode
	_exec_occ maintenance:mode --on

	# Copy config and 3rd party applications from current directory
	sudo cp -a "${DESTDIR}/config/config.php" "${TMPDIR}/config/config.php"
	for a in $(sudo ls "${DESTDIR}/apps"); do
	[[ ! -d "${TMPDIR}/apps/$a" ]] \
		&& sudo cp -a "${DESTDIR}/apps/$a" "${TMPDIR}/apps/$a"
	done

	# Rename existing app directory and move new one
	SECURE_REMOVE '$DESTDIR'	# Supprime le dossier actuel de nextcloud
	sudo mv "$TMPDIR" "$DESTDIR"	# Et le remplace par la nouvelle version du dossier temporaire
	sudo chmod +x "$DESTDIR"

	# Set app folders ownership
	sudo chown -R $app: "$DESTDIR" "$DATADIR"

	# Upgrade Nextcloud (SUCCESS = 0, UP_TO_DATE = 3)
	# TODO: Restore old directory in case of failure?
	_exec_occ maintenance:mode --off
	_exec_occ upgrade \
	|| ([[ $? -eq 3 ]] || ynh_die "Unable to upgrade Nextcloud")
}
