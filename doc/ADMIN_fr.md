### Exécuter manuellement des commandes Nextcloud

Vous pouvez lancer des commandes Nextcloud depuis la ligne de commande avec:

```
sudo -u __APP__ php__PHPVERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...
```

Ou bien, vous pouvez ouvrir un "shell Nextcloud" avec `sudo yunohost app shell __APP__`, puis lancer `php occ ...`

### Changer l'emplacement du dossier data

Il peut être intéressant de changer l'emplacement par défaut du dossier Nextcloud pour stocker les données sur un second disque dur.

1. Trouver le chemin actuel des data Nextcloud

    ```bash
    yunohost app setting __APP__ data_dir
    ```

    Cette commande devrait afficher :

    ```bash
    __DATA_DIR__
    ```

1. Déplacer les données Nextcloud au nouvel emplacement :
    Pour l'exemple nous prendrons le dossier `/media/stockage/nextcloud`

    ```bash
    mv __DATA_DIR__ /media/stockage/nextcloud
    ```

1. Modifier le propriétaire du dossier :

    ```bash
    chown nextcloud:nextcloud /media/stockage/nextcloud
    ```

1. Créer un lien symbolique entre le dossier par défaut et le nouveau dossier :

    ```bash
    ln -s /media/stockage/nextcloud __DATA_DIR__
    ```

1. Tester les fichiers Nextcloud :

    ```bash
    sudo -u nextcloud php8.2 --define apc.enable_cli=1 /var/www/nextcloud/occ files:scan --all
    ```

C'est fini ! Vos données sont maintenant stocké dans le dossier `/media/stockage/nextcloud`

### Intégration d'ONLYOFFICE

ONLYOFFICE est un éditeur de texte enrichi en ligne qui peut s'intégrer dans Nextcloud

#### Avec l'application YunoHost (support ARM64, meilleures performances)

Pour de meilleures performances et le support de ARM64 (Raspberry Pi, OLinuXino...), installez l'[app YunoHost OnlyOffice](https://apps.yunohost.org/app/onlyoffice), puis connectez-la à Nextcloud : voir le tutoriel dans la [doc du paquet onlyoffice_ynh](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### Alternative: avec l'application Nextcloud (pas de support ARM, performances limitées)

Nextcloud inclut une intégration directe via une application Nextcloud.

- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur ONLYOFFICE.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur ONLYOFFICE.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://__DOMAIN____PATH__/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec ONLYOFFICE.
