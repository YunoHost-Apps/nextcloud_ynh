<!--
Este archivo README esta generado automaticamente<https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
No se debe editar a mano.
-->

# Nextcloud para Yunohost

[![Nivel de integración](https://dash.yunohost.org/integration/nextcloud.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/) ![Estado funcional](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Estado En Mantención](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Instalar Nextcloud con Yunhost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Leer este README en otros idiomas.](./ALL_README.md)*

> *Este paquete le permite instalarNextcloud rapidamente y simplement en un servidor YunoHost.*  
> *Si no tiene YunoHost, visita [the guide](https://yunohost.org/install) para aprender como instalarla.*

## Descripción general

Nextcloud lets you access and synchronize data, files, contacts and calendars between different devices (PCs or mobiles), or share them with other people (with or without accounts), and also offers advanced communication and collaborative working features. Nextcloud features its own application mechanism (see also [Nextcloud's app store](https://apps.nextcloud.com/)) for specific functionalities. 

In the context of YunoHost, Nextcloud integrates with the SSO / user portal (YunoHost accounts are automatically connected to Nextcloud).

The `/.well-known` address will be automatically configured for CalDAV and CardDAV synchronization if no other service such as Baïkal is already using it.


**Versión actual:** 29.0.7~ynh1

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

Por favor enviar sus correcciones a la [rama `testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Para probar la rama `testing`, sigue asÍ:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
o
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Mas informaciones sobre el empaquetado de aplicaciones:** <https://yunohost.org/packaging_apps>
