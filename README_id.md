<!--
N.B.: README ini dibuat secara otomatis oleh <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Ini TIDAK boleh diedit dengan tangan.
-->

# Nextcloud untuk YunoHost

[![Tingkat integrasi](https://dash.yunohost.org/integration/nextcloud.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/) ![Status kerja](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![Status pemeliharaan](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![Pasang Nextcloud dengan YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Baca README ini dengan bahasa yang lain.](./ALL_README.md)*

> *Paket ini memperbolehkan Anda untuk memasang Nextcloud secara cepat dan mudah pada server YunoHost.*  
> *Bila Anda tidak mempunyai YunoHost, silakan berkonsultasi dengan [panduan](https://yunohost.org/install) untuk mempelajari bagaimana untuk memasangnya.*

## Ringkasan

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


**Versi terkirim:** 28.0.8~ynh1

**Demo:** <https://demo.nextcloud.com/>

## Tangkapan Layar

![Tangkapan Layar pada Nextcloud](./doc/screenshots/screenshot.png)

## Dokumentasi dan sumber daya

- Website aplikasi resmi: <https://nextcloud.com>
- Dokumentasi pengguna resmi: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Dokumentasi admin resmi: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Depot kode aplikasi hulu: <https://github.com/nextcloud/server>
- Gudang YunoHost: <https://apps.yunohost.org/app/nextcloud>
- Laporkan bug: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Info developer

Silakan kirim pull request ke [`testing` branch](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Untuk mencoba branch `testing`, silakan dilanjutkan seperti:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
atau
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Info lebih lanjut mengenai pemaketan aplikasi:** <https://yunohost.org/packaging_apps>
