<!--
NB: Deze README is automatisch gegenereerd door <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Hij mag NIET handmatig aangepast worden.
-->

# Nextcloud voor Yunohost

[![Integratieniveau](https://dash.yunohost.org/integration/nextcloud.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/) ![Mate van functioneren](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Onderhoudsstatus](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Nextcloud met Yunohost installeren](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Deze README in een andere taal lezen.](./ALL_README.md)*

> *Met dit pakket kun je Nextcloud snel en eenvoudig op een YunoHost-server installeren.*  
> *Als je nog geen YunoHost hebt, lees dan [de installatiehandleiding](https://yunohost.org/install), om te zien hoe je 'm installeert.*

## Overzicht

Nextcloud lets you access and synchronize data, files, contacts and calendars between different devices (PCs or mobiles), or share them with other people (with or without accounts), and also offers advanced communication and collaborative working features. Nextcloud features its own application mechanism (see also [Nextcloud's app store](https://apps.nextcloud.com/)) for specific functionalities. 

In the context of YunoHost, Nextcloud integrates with the SSO / user portal (YunoHost accounts are automatically connected to Nextcloud).

The `/.well-known` address will be automatically configured for CalDAV and CardDAV synchronization if no other service such as Baïkal is already using it.


**Geleverde versie:** 29.0.7~ynh1

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
