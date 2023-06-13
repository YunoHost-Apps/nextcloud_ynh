### Comment utiliser la commande CLI

`sudo -u __APP__ php__YNH_PHP_VERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...`

### Configurer l'intégration d'ONLYOFFICE

#### Avec l'application Nextcloud (pas de support ARM, performances limitées)

À partir de sa version 18, Nextcloud inclut une intégration directe de ONLYOFFICE (un éditeur de texte enrichi en ligne) via une application Nextcloud.
Pour l'installer et la configurer :
- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur ONLYOFFICE.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur ONLYOFFICE.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://__DOMAIN__/__PATH__/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec ONLYOFFICE.
- Et voilà :) Vous devriez pouvoir créer de nouveaux types de documents, et les ouvrir.

*NB : l'app Nextcloud ONLYOFFICE Community Document Server n'est disponible que sous architecture x86 - Pour un support de l'architecture **ARM** (Raspberry Pi, OLinuXino...), installez plutôt l'App YunoHost, voir ci-dessous*

#### Avec l'application YunoHost (support ARM64, meilleures performances)

Pour  de meilleures performances et le support de ARM64, installez l'app YunoHost ONLYOFFICE, voir le tutoriel dans la [doc du paquet onlyoffice_ynh](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)
