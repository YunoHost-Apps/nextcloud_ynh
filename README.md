# Nextcloud for YunoHost

[![Integration level](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud) ![](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)  
[![Install Nextcloud with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=nextcloud)

> *This package allow you to install Nextcloud quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

[Nextcloud](https://nextcloud.com) gives you freedom and control over your
own data. A personal cloud which run on your own server. With Nextcloud
you can synchronize your files over your devices.


**Shipped version:** 18.0.4

## Screenshots

![](https://raw.githubusercontent.com/nextcloud/screenshots/master/files/Files%20Overview.png)

## Demo

* [YunoHost demo](https://demo.yunohost.org/nextcloud/)
* [Official demo](https://demo.nextcloud.com/)

## Configuration

## Documentation

 * Official documentation: https://docs.nextcloud.com/server/18/user_manual/
 * YunoHost documentation: https://github.com/YunoHost/doc/blob/master/app_nextcloud_fr.md

## YunoHost specific features

In addition to Nextcloud core features, the following are made available with
this package:

 * Integrate with YunoHost users and SSO - i.e logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the
   installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's
   not already served - i.e by Baïkal

#### Multi-users support

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/ci/logs/nextcloud%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/nextcloud%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/nextcloud/)

## Limitations

To integrate the logout button to the SSO, we have to patch Nextcloud sources.
In waiting an upstream integration, the source code integrity checking has been
disabled to prevent the warning message.

Also, note we made the choice to disable third-parties applications at the
upgrade. It allows to prevent an unstable - and sometimes broken - Nextcloud
installation. You will just have to manually activate them after the upgrade.

Finally, the following error message in Nextcloud logs can be safely ignored:
```
Following symlinks is not allowed ('/home/yunohost.multimedia/user/Share' -> '/home/yunohost.multimedia/share/' not inside '/home/yunohost.multimedia/user/')
```

## Additionnal informations

#### Migrate from ownCloud

**This is not considered as stable yet, please do it with care and only for
testing!**

This package handle the migration from ownCloud to Nextcloud. For that, your
ownCloud application must be **up-to-date** in YunoHost.

You will then have to upgrade your ownCloud application with this repository.
This can only be done from the command-line interface - e.g. through SSH. Once
you're connected, you simply have to execute the following:

```bash
sudo yunohost app upgrade -u https://github.com/YunoHost-Apps/nextcloud_ynh owncloud --debug
```

The `--debug` option will let you see the full output. If you encounter any
issue, please paste it.

Note that a cron job will be executed at some time after the end of this
command. You must wait that before doing any other application operations!
You should see that Nextcloud is installed after that.

Note that it does not change the application label nor the URL. To rename
the label, you can execute the following - replace `Nextcloud` with whatever
you want:

```bash
sudo yunohost app setting nextcloud label -v "Nextcloud"
sudo yunohost app ssowatconf
```

## Links

 * Report a bug: https://github.com/YunoHost-Apps/nextcloud_ynh/issues
 * Nextcloud website: https://nextcloud.com/
 * Nextcloud repository: https://github.com/nextcloud/server
 * YunoHost website: https://yunohost.org/

---

Developers infos
----------------

Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
or
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```
