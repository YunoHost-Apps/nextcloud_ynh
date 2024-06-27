### Manually running Nextcloud commands

You can run Nextcloud commands from the command line using:

```bash
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Alternatively, you may open a 'Nextcloud shell' with `sudo yunohost app shell __APP__`, then run `php occ ...`

### Change data folder location

It may be worth changing the default location of the Nextcloud folder to store data on a second hard disk.

1. Find the current Nextcloud data path

    ```bash
    yunohost app setting __APP__ data_dir
    ```

    This command should display :

    ```bash
    __DATA_DIR__
    ```

1. Move Nextcloud data to the new location:
    For the example, we'll use the `/media/storage/nextcloud` folder.

    ```bash
    mv __DATA_DIR__ /media/stockage/nextcloud
    ```

1. Change folder owner :

    ```bash
    chown nextcloud:nextcloud /media/storage/nextcloud
    ```

1. Create a symbolic link between the default folder and the new one:

    ```bash
    ln -s /media/stockage/nextcloud __DATA_DIR__
    ```

1. Test Nextcloud files:

    ```bash
    sudo -u nextcloud php8.2 --define apc.enable_cli=1 /var/www/nextcloud/occ files:scan --all
    ```

You're done! Your data is now stored in the folder `/media/storage/nextcloud`.

### ONLYOFFICE integration

ONLYOFFICE is an online rich text document editor which can be integrated in Nextcloud

#### With YunoHost App (ARM64 support, better performance)

For better performance and ARM64 support (Raspberry Pi, OLinuXino...), install the [OnlyOffice YunoHost app](https://apps.yunohost.org/app/onlyoffice) and connect it to Nextcloud, see the tutorial in the [doc of onlyoffice_ynh package](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: With Nextcloud App (no ARM support, lower performance)

Nextcloud features a direct integration of ONLYOFFICE through a Nextcloud app.

- Install *Community Document Server* application in your Nextcloud. That's the part that runs ONLYOFFICE server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an ONLYOFFICE server.
- Then in Settings -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by ONLYOFFICE.
