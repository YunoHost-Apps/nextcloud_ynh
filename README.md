Nextcloud for YunoHost
---------------------

**This is a work-in-progress Nextcloud package for YunoHost.**

[Nextcloud](https://nextcloud.com) gives you freedom and control over your
own data. A personal cloud which run on your own server. With Nextcloud
you can synchronize your files over your devices.

**Shipped version:** 9.0.51

![](https://github.com/nextcloud/screenshots/blob/master/files/filelist.png)

## TODO

 * Manage the upgrade from ownCloud

## Features

In addition to Nextcloud core features, the following are made available with
this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Optionally access the user home folder from Nextcloud files (set at the installation)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's
   not already served - i.e. by Baïkal

## Limitations

To integrate the logout button to the SSO, we have to patch Nextcloud sources.
In waiting an upstream integration, the source code integrity checking has been
disabled to prevent the warning message.

Also, note we made the choice to disable third-parties applications at the
upgrade. It allows to prevent an unstable - and sometimes broken - Nextcloud
installation. You will just have to manually activate them after the upgrade.

## Links

 * Report a bug: https://dev.yunohost.org/projects/apps/issues
 * Nextcloud website: https://nextcloud.com/
 * YunoHost website: https://yunohost.org/
