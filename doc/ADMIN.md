### Manually running Nextcloud commands

You can run Nextcloud commands from the command line using:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Alternatively, you may open a 'Nextcloud shell' with `sudo yunohost app shell __APP__`, then run `php occ ...`

### High Performance Backend

High Performance Backend is an application on Nextcloud that should speed up the instance, more information here: https://github.com/nextcloud/notify_push#about

### ONLYOFFICE integration

ONLYOFFICE is an online rich text document editor which can be integrated in Nextcloud

#### With YunoHost App (ARM64 support, better performance)

For better performance and ARM64 support (Raspberry Pi, OLinuXino...), install the [OnlyOffice YunoHost app](https://apps.yunohost.org/app/onlyoffice) and connect it to Nextcloud, see the tutorial in the [doc of onlyoffice_ynh package](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: With Nextcloud App (no ARM support, lower performance)

Nextcloud features a direct integration of ONLYOFFICE through a Nextcloud app.
- Install *Community Document Server* application in your Nextcloud. That's the part that runs ONLYOFFICE server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an ONLYOFFICE server.
- Then in Settings -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by ONLYOFFICE.

### Trashbin and file versions retention

By default, Nextcloud keeps files in trashbin and old versions of files, and delete them only when the disk space is almost full. (cf : https://docs.nextcloud.com/server/18/admin_manual/configuration_server/config_sample_php_parameters.html#deleted-items-trash-bin)
You can change this by editing this file : /var/www/nextcloud/config/config.php
Just add this lines :
```
  'trashbin_retention_obligation' => 'auto, 30',
  'versions_retention_obligation' => 'auto, 90',
```
In this case, nextcloud will delete files in trashbin older than 30 days, and file versions older than 90 days.
