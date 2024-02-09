Nextcloud Hub est la plate-forme de collaboration de contenu sur site entièrement open source. Les équipes accèdent, partagent et modifient leurs documents, discutent et participent à des appels vidéo et gèrent leur courrier, leur calendrier et leurs projets sur des interfaces mobiles, de bureau et Web.

### Caractéristiques spécifiques YunoHost

En plus des fonctionnalités principales de Nextcloud, les fonctionnalités suivantes sont incluses dans ce package :

 * Intégration avec les utilisateurs YunoHost et le SSO - exemple, le bouton de déconnexion
 * Permet à un utilisateur d'être l'administrateur (choisi à l'installation)
 * Permet de multiples instances de cette application
 * Accès optionnel au répertoire home depuis les fichiers Nextcloud (à activer à l'installation, le partage étant activé par défaut)
 * Utilise l'adresse `/.well-known` pour la synchronisation CalDAV et CardDAV du domaine si aucun autre service ne l'utilise déjà - par exemple, Baïkal
 * 
## Branche olstable

Cette branche suit une ancienne version stable, car souvent les premières versions de nextcloud ne sont pas totalement stables.

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Pour essayer la branche oldstable, procédez comme suit.

``` bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
ou
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
```

