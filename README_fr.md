<!--
Nota bene : ce README est automatiquement généré par <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Il NE doit PAS être modifié à la main.
-->

# Nextcloud pour YunoHost

[![Niveau d’intégration](https://apps.yunohost.org/badge/integration/nextcloud)](https://ci-apps.yunohost.org/ci/apps/nextcloud/)
![Statut du fonctionnement](https://apps.yunohost.org/badge/state/nextcloud)
![Statut de maintenance](https://apps.yunohost.org/badge/maintained/nextcloud)

[![Installer Nextcloud avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Lire le README dans d'autres langues.](./ALL_README.md)*

> *Ce package vous permet d’installer Nextcloud rapidement et simplement sur un serveur YunoHost.*  
> *Si vous n’avez pas YunoHost, consultez [ce guide](https://yunohost.org/install) pour savoir comment l’installer et en profiter.*

## Vue d’ensemble

Nextcloud permet de rendre accessible et de synchroniser ses données, fichiers, contacts, agendas entre différents appareils (ordinateurs ou mobiles), ou de les partager avec d'autres personnes (avec ou sans comptes), et propose également des fonctionnalités avancées de communication et de travail collaboratif. Nextcloud dispose de son propre mécanisme d'applications (voir aussi [le store d'apps de Nextcloud](https://apps.nextcloud.com/)) pour disposer des fonctionnalités spécifiques.

Dans le cadre de YunoHost, Nextcloud s'intègre avec le SSO/portail utilisateur (les comptes YunoHost sont automatiquements connectés à Nextcloud).

L'adresse `/.well-known` sera automatiquement configuré pour la synchronisation CalDAV et CardDAV si aucun autre service tel que Baïkal ne l'utilise déjà.

Le catalogue YunoHost dispose de deux suites bureautiques collaboratives, [OnlyOffice](https://github.com/YunoHost-Apps/onlyoffice_ynh) et [Collabora](https://github.com/YunoHost-Apps/collabora_ynh), qui peuvent être intégrées à Nextcloud.


**Version incluse :** 30.0.8~ynh1

**Démo :** <https://demo.nextcloud.com/>

## Captures d’écran

![Capture d’écran de Nextcloud](./doc/screenshots/screenshot.png)

## Documentations et ressources

- Site officiel de l’app : <https://nextcloud.com>
- Documentation officielle utilisateur : <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Documentation officielle de l’admin : <https://docs.nextcloud.com/server/stable/admin_manual/>
- Dépôt de code officiel de l’app : <https://github.com/nextcloud/server>
- YunoHost Store : <https://apps.yunohost.org/app/nextcloud>
- Signaler un bug : <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche `testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Pour essayer la branche `testing`, procédez comme suit :

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
ou
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Plus d’infos sur le packaging d’applications :** <https://yunohost.org/packaging_apps>
