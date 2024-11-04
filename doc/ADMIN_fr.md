### Exécuter manuellement des commandes Nextcloud

Vous pouvez lancer des commandes Nextcloud depuis la ligne de commande avec:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Ou bien, vous pouvez ouvrir un "shell Nextcloud" avec `sudo yunohost app shell __APP__`, puis lancer `php occ ...`
