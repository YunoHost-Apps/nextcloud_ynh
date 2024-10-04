### Exécuter manuellement des commandes Nextcloud

Vous pouvez lancer des commandes Nextcloud depuis la ligne de commande avec:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Ou bien, vous pouvez ouvrir un "shell Nextcloud" avec `sudo yunohost app shell __APP__`, puis lancer `php occ ...`

### Backend Hautes Performances

Le backend Hautes Performances est une application sur Nextcloud qui devrait accélérer l'instance, plus d'informations ici : https://github.com/nextcloud/notify_push#about

### Intégration d'ONLYOFFICE

ONLYOFFICE est un éditeur de texte enrichi en ligne qui peut s'intégrer dans Nextcloud

#### Avec l'application YunoHost (support ARM64, meilleures performances)

Pour de meilleures performances et le support de ARM64 (Raspberry Pi, OLinuXino...), installez l'[app YunoHost OnlyOffice](https://apps.yunohost.org/app/onlyoffice), puis connectez-la à Nextcloud : voir le tutoriel dans la [doc du paquet onlyoffice_ynh](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: avec l'application Nextcloud (pas de support ARM, performances limitées)

Nextcloud inclut une intégration directe via une application Nextcloud.
- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur ONLYOFFICE.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur ONLYOFFICE.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec ONLYOFFICE.

### Gestion des versions et de la corbeille de nextcloud

Par défaut, Nextcloud conserve les fichiers supprimés et les anciennes versions, et ne les supprime quand l'espace disque est presque plein (cf : https://docs.nextcloud.com/server/18/admin_manual/configuration_server/config_sample_php_parameters.html#deleted-items-trash-bin)
On peut modifier ce comportement en éditant ce fichier : /var/www/nextcloud/config/config.php
Et en ajoutant ces lignes :
```
  'trashbin_retention_obligation' => 'auto, 30',
  'versions_retention_obligation' => 'auto, 90',
```
Dans ce cas, nextcloud va supprimer les fichiers de la corbeille après 30 jours, et les versions plus vieilles que 90 jours.
