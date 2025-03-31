<!--
NB: Deze README is automatisch gegenereerd door <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Hij mag NIET handmatig aangepast worden.
-->

# Nextcloud voor Yunohost

[![Integratieniveau](https://apps.yunohost.org/badge/integration/nextcloud)](https://ci-apps.yunohost.org/ci/apps/nextcloud/)
![Mate van functioneren](https://apps.yunohost.org/badge/state/nextcloud)
![Onderhoudsstatus](https://apps.yunohost.org/badge/maintained/nextcloud)

[![Nextcloud met Yunohost installeren](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Deze README in een andere taal lezen.](./ALL_README.md)*

> *Met dit pakket kun je Nextcloud snel en eenvoudig op een YunoHost-server installeren.*  
> *Als je nog geen YunoHost hebt, lees dan [de installatiehandleiding](https://yunohost.org/install), om te zien hoe je 'm installeert.*

## Overzicht

Nextcloud Hub is a fully open-source on-premises content collaboration platform. Teams access, share and edit their documents, chat and participate in video calls and manage their mail and calendar and projects across mobile, desktop and web interfaces.

### YunoHost-specific features

In addition to Nextcloud core features, the following are made available with this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's not already served - i.e. by Baïkal

### Oldstable branch

This branch is following old stable release because nextcloud first release are often not totally stable.

Please send your pull request to the [oldstable branch](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable).

To try the oldstable branch, please proceed like that.

```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
or
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
```


**Geleverde versie:** 29.0.14~ynh1

**Demo:** <https://demo.nextcloud.com/>

## Schermafdrukken

![Schermafdrukken van Nextcloud](./doc/screenshots/screenshot.png)

## Documentatie en bronnen

- Officiele website van de app: <https://nextcloud.com>
- Officiele gebruikersdocumentatie: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Officiele beheerdersdocumentatie: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Upstream app codedepot: <https://github.com/nextcloud/server>
- YunoHost-store: <https://apps.yunohost.org/app/nextcloud>
- Meld een bug: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Ontwikkelaarsinformatie

Stuur je pull request alsjeblieft naar de [`testing`-branch](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Om de `testing`-branch uit te proberen, ga als volgt te werk:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
of
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Verdere informatie over app-packaging:** <https://yunohost.org/packaging_apps>
