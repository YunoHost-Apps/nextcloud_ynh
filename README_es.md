<!--
Este archivo README esta generado automaticamente<https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
No se debe editar a mano.
-->

# Nextcloud para Yunohost

[![Nivel de integración](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud) ![Estado funcional](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Estado En Mantención](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Instalar Nextcloud con Yunhost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Leer este README en otros idiomas.](./ALL_README.md)*

> *Este paquete le permite instalarNextcloud rapidamente y simplement en un servidor YunoHost.*  
> *Si no tiene YunoHost, visita [the guide](https://yunohost.org/install) para aprender como instalarla.*

## Descripción general

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


**Versión actual:** 27.1.10~ynh1

**Demo:** <https://demo.nextcloud.com/>

## Capturas

![Captura de Nextcloud](./doc/screenshots/screenshot.png)

## Documentaciones y recursos

- Sitio web oficial: <https://nextcloud.com>
- Documentación usuario oficial: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Documentación administrador oficial: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Repositorio del código fuente oficial de la aplicación : <https://github.com/nextcloud/server>
- Catálogo YunoHost: <https://apps.yunohost.org/app/nextcloud>
- Reportar un error: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Información para desarrolladores

Por favor enviar sus correcciones a la [`branch testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing

Para probar la rama `testing`, sigue asÍ:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
o
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Mas informaciones sobre el empaquetado de aplicaciones:** <https://yunohost.org/packaging_apps>
