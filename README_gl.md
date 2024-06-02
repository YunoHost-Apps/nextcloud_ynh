<!--
NOTA: Este README foi creado automáticamente por <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
NON debe editarse manualmente.
-->

# Nextcloud para YunoHost

[![Nivel de integración](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud) ![Estado de funcionamento](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Estado de mantemento](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Instalar Nextcloud con YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Le este README en outros idiomas.](./ALL_README.md)*

> *Este paquete permíteche instalar Nextcloud de xeito rápido e doado nun servidor YunoHost.*  
> *Se non usas YunoHost, le a [documentación](https://yunohost.org/install) para saber como instalalo.*

## Vista xeral

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


**Versión proporcionada:** 27.1.10~ynh1

**Demo:** <https://demo.nextcloud.com/>

## Capturas de pantalla

![Captura de pantalla de Nextcloud](./doc/screenshots/screenshot.png)

## Documentación e recursos

- Web oficial da app: <https://nextcloud.com>
- Documentación oficial para usuarias: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Documentación oficial para admin: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Repositorio de orixe do código: <https://github.com/nextcloud/server>
- Tenda YunoHost: <https://apps.yunohost.org/app/nextcloud>
- Informar dun problema: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Info de desenvolvemento

Envía a túa colaboración á [rama `testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Para probar a rama `testing`, procede deste xeito:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
ou
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Máis info sobre o empaquetado da app:** <https://yunohost.org/packaging_apps>
