### Manually running Nextcloud commands

You can run Nextcloud commands from the command line using:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Alternatively, you may open a 'Nextcloud shell' with `sudo yunohost app shell __APP__`, then run `php occ ...`
