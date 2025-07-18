### Manually running Nextcloud commands

You can run Nextcloud commands from the command line by opening a Nextcloud "shell" and running `php occ` directly:

```bash
sudo yunohost app shell __APP__
# You should then see you're in a shell with "__APP__@yourmachine"
php occ ...
```
Alternatively, you can run `sudo -u __APP__ php__PHP_VERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...`

## Promoting a user to admin

In some cases, your user may not be a Nextcloud admin and therefore cannot access the admin panels from Nextcloud.

This user can be added to the Nextcloud admin group with : 

```bash
sudo yunohost app shell __APP__
# And then
php occ group:adduser admin <username>
```
