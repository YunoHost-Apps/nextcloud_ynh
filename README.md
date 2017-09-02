Nextcloud for YunoHost
---------------------

[Nextcloud](https://nextcloud.com) gives you freedom and control over your
own data. A personal cloud which run on your own server. With Nextcloud
you can synchronize your files over your devices.

**Shipped version:** 12.0.1

[![Install Nextcloud with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=nextcloud)
![](https://github.com/nextcloud/screenshots/blob/master/files/filelist.png)

## Features

In addition to Nextcloud core features, the following are made available with
this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Optionally access the user home folder from Nextcloud files (set at the
   installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's
   not already served - i.e. by Baïkal

## Limitations

To integrate the logout button to the SSO, we have to patch Nextcloud sources.
In waiting an upstream integration, the source code integrity checking has been
disabled to prevent the warning message.

Also, note we made the choice to disable third-parties applications at the
upgrade. It allows to prevent an unstable - and sometimes broken - Nextcloud
installation. You will just have to manually activate them after the upgrade.

## Migrate from ownCloud

**This is not considered as stable yet, please do it with care and only for
testing!**

This package handle the migration from ownCloud to Nextcloud. For that, your
ownCloud application must be **up-to-date** in YunoHost.

You will then have to upgrade your ownCloud application with this repository.
This can only be done from the command-line interface - e.g. through SSH. Once
you're connected, you simply have to execute the following:

```bash
sudo yunohost app upgrade -u https://github.com/YunoHost-Apps/nextcloud_ynh owncloud --verbose
```

The `--verbose` option will let you see the full output. If you encounter any
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

 * Report a bug: https://dev.yunohost.org/projects/apps/issues
 * Nextcloud website: https://nextcloud.com/
 * YunoHost website: https://yunohost.org/
