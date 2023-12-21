### How to use CLI commande

`sudo -u __APP__ php__YNH_PHP_VERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...`

or use `sudo yunohost app shell __APP__` then run `php occ ...`

### Configure ONLYOFFICE integration

#### With YunoHost App (ARM64 support, better performance)

For better performance and ARM64 support (Raspberry Pi, OLinuXino...), install ONLYOFFICE YunoHost App and connect it to Nextcloud, see the tutorial in the [doc of onlyoffice_ynh package](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: With Nextcloud App (no ARM support, lower performance)

Nextcloud features a direct integration of ONLYOFFICE (an online rich text document editor) through a Nextcloud app.
To install and configure it:
- Install *Community Document Server* application in your Nextcloud. That's the part that runs ONLYOFFICE server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an ONLYOFFICE server.
- Then in Settings -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by ONLYOFFICE.
