<!--
N.B.: Questo README è stato automaticamente generato da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
NON DEVE essere modificato manualmente.
-->

# Nextcloud per YunoHost

[![Livello di integrazione](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud) ![Stato di funzionamento](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Stato di manutenzione](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Installa Nextcloud con YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Leggi questo README in altre lingue.](./ALL_README.md)*

> *Questo pacchetto ti permette di installare Nextcloud su un server YunoHost in modo semplice e veloce.*  
> *Se non hai YunoHost, consulta [la guida](https://yunohost.org/install) per imparare a installarlo.*

## Panoramica

Nextcloud Hub is a fully open-source on-premises content collaboration platform. Teams access, share and edit their documents, chat and participate in video calls and manage their mail and calendar and projects across mobile, desktop and web interfaces.

### YunoHost-specific features

In addition to Nextcloud core features, the following are made available with this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's not already served - i.e. by Baïkal


**Versione pubblicata:** 28.0.4~ynh1

**Prova:** <https://demo.nextcloud.com/>

## Screenshot

![Screenshot di Nextcloud](./doc/screenshots/screenshot.png)

## Documentazione e risorse

- Sito web ufficiale dell’app: <https://nextcloud.com>
- Documentazione ufficiale per gli utenti: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Documentazione ufficiale per gli amministratori: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Repository upstream del codice dell’app: <https://github.com/nextcloud/server>
- Store di YunoHost: <https://apps.yunohost.org/app/nextcloud>
- Segnala un problema: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Informazioni per sviluppatori

Si prega di inviare la tua pull request alla [branch di `testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Per provare la branch di `testing`, si prega di procedere in questo modo:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
o
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Maggiori informazioni riguardo il pacchetto di quest’app:** <https://yunohost.org/packaging_apps>
