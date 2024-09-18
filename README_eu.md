<!--
Ohart ongi: README hau automatikoki sortu da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>ri esker
EZ editatu eskuz.
-->

# Nextcloud YunoHost-erako

[![Integrazio maila](https://dash.yunohost.org/integration/nextcloud.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/) ![Funtzionamendu egoera](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Mantentze egoera](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Instalatu Nextcloud YunoHost-ekin](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Irakurri README hau beste hizkuntzatan.](./ALL_README.md)*

> *Pakete honek Nextcloud YunoHost zerbitzari batean azkar eta zailtasunik gabe instalatzea ahalbidetzen dizu.*  
> *YunoHost ez baduzu, kontsultatu [gida](https://yunohost.org/install) nola instalatu ikasteko.*

## Aurreikuspena

Nextcloud lets you access and synchronize data, files, contacts and calendars between different devices (PCs or mobiles), or share them with other people (with or without accounts), and also offers advanced communication and collaborative working features. Nextcloud features its own application mechanism (see also [Nextcloud's app store](https://apps.nextcloud.com/)) for specific functionalities. 

In the context of YunoHost, Nextcloud integrates with the SSO / user portal (YunoHost accounts are automatically connected to Nextcloud).

The `/.well-known` address will be automatically configured for CalDAV and CardDAV synchronization if no other service such as Baïkal is already using it.


**Paketatutako bertsioa:** 29.0.7~ynh1

**Demoa:** <https://demo.nextcloud.com/>

## Pantaila-argazkiak

![Nextcloud(r)en pantaila-argazkia](./doc/screenshots/screenshot.png)

## Dokumentazioa eta baliabideak

- Aplikazioaren webgune ofiziala: <https://nextcloud.com>
- Erabiltzaileen dokumentazio ofiziala: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Administratzaileen dokumentazio ofiziala: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Jatorrizko aplikazioaren kode-gordailua: <https://github.com/nextcloud/server>
- YunoHost Denda: <https://apps.yunohost.org/app/nextcloud>
- Eman errore baten berri: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Garatzaileentzako informazioa

Bidali `pull request`a [`testing` abarrera](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

`testing` abarra probatzeko, ondorengoa egin:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
edo
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Informazio gehiago aplikazioaren paketatzeari buruz:** <https://yunohost.org/packaging_apps>
