### Exécuter manuellement des commandes Nextcloud

Vous pouvez lancer des commandes Nextcloud depuis la ligne de commande avec:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Ou bien, vous pouvez ouvrir un "shell Nextcloud" avec `sudo yunohost app shell __APP__`, puis lancer `php occ ...`

### Intégration d'ONLYOFFICE

ONLYOFFICE est un éditeur de texte enrichi en ligne qui peut s'intégrer dans Nextcloud

#### Avec l'application YunoHost (support ARM64, meilleures performances)

Pour de meilleures performances et le support de ARM64 (Raspberry Pi, OLinuXino...), installez l'[app YunoHost OnlyOffice](https://apps.yunohost.org/app/onlyoffice), puis connectez-la à Nextcloud : voir le tutoriel dans la [doc du paquet onlyoffice_ynh](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: avec l'application Nextcloud (pas de support ARM, performances limitées)

Nextcloud inclut une intégration directe via une application Nextcloud.
- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur ONLYOFFICE.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur ONLYOFFICE.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec ONLYOFFICE.
