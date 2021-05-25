# Nextcloud pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud) ![](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg)  ![](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)
[![Installer nextcloud avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install nextcloud quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Vue d'ensemble

Stockage en ligne, plateforme de partage de fichiers et diverses autres applications

**Version incluse:** 21.0.2~ynh1

**Démo:** https://demo.nextcloud.com/


## Captures d'écran


   ![](./doc/screenshots/screenshot.png)




## Avertissements / informations importantes

## Configuration

#### Configurer l'intégration d'OnlyOffice

À partir de sa version 18, Nextcloud inclut une intégration directe de OnlyOffice (un éditeur de texte enrichi en ligne) via une application Nextcloud.
Pour l'installer et la configurer :
- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur OnlyOffice.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur OnlyOffice.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://yourdomain.tld/nextcloud/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec OnlyOffice.
- Et voilà :) Vous devriez pouvoir créer de nouveaux types de documents, et les ouvrir.
    
*NB : OnlyOffice n'est disponible que sous architecture x86 - L'architecture **ARM** n'est **pas** supporté (Raspberry Pi, OLinuXino...)*

## Caractéristiques spécifiques YunoHost

En plus des fonctionnalités principales de Nextcloud, les fonctionnalités suivantes sont incluses dans ce package :

 * Intégration avec les utilisateurs YunoHost et le SSO - exemple, le bouton de déconnexion
 * Permet à un utilisateur d'être l'administrateur (choisi à l'installation)
 * Permet de multiples instances de cette application
 * Accès optionnel au répertoire home depuis les fichiers Nextcloud (à activer à l'installation, le partage étant activé par défaut)
 * Utilise l'adresse `/.well-known` pour la synchronisation CalDAV et CardDAV du domaine si aucun autre service ne l'utilise déjà - par exemple, baikal



## Documentations et ressources

* Site official de l'app : https://nextcloud.com
* Documentation officielle utilisateur: https://yunohost.org/en/app_nextcloud
* Documentation officielle de l'admin: https://docs.nextcloud.com/server/21/user_manual/en/
* Dépôt de code officiel de l'app:  https://github.com/nextcloud/server
* Documentation YunoHost pour cette app: https://yunohost.org/app_nextcloud
* Signaler un bug: https://github.com/YunoHost-Apps/nextcloud_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
or
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications:** https://yunohost.org/packaging_apps