## Configuration

#### Configurer l'intégration d'OnlyOffice

À partir de sa version 18, Nextcloud inclut une intégration directe de OnlyOffice (un éditeur de texte enrichi en ligne) via une application Nextcloud.
Pour l'installer et la configurer :
- Installez l'application *Community Document Server* dans votre Nextcloud. C'est la partie qui fait tourner un serveur OnlyOffice.
- Installez l'application *ONLYOFFICE*. C'est la partie cliente qui va se connecter au serveur OnlyOffice.
- Ensuite dans les Paramètres -> ONLYOFFICE (`https://yourdomain.tld/nextcloud/settings/admin/onlyoffice`), si vous voulez configurer quels formats de fichier s'ouvrent avec OnlyOffice.
- Et voilà :) Vous devriez pouvoir créer de nouveaux types de documents, et les ouvrir.
    
*NB : OnlyOffice n'est disponible que sous architecture x86 - L'architecture **ARM** n'est **pas** supporté (Raspberry Pi, OLinuXino...)*

#### Backend Hautes Performances

Il s'agit d'une application sur nextcloud qui devrait accélérer l'instance, plus d'informations ici: https://github.com/nextcloud/notify_push#about

## Caractéristiques spécifiques YunoHost

En plus des fonctionnalités principales de Nextcloud, les fonctionnalités suivantes sont incluses dans ce package :

 * Intégration avec les utilisateurs YunoHost et le SSO - exemple, le bouton de déconnexion
 * Permet à un utilisateur d'être l'administrateur (choisi à l'installation)
 * Permet de multiples instances de cette application
 * Accès optionnel au répertoire home depuis les fichiers Nextcloud (à activer à l'installation, le partage étant activé par défaut)
 * Utilise l'adresse `/.well-known` pour la synchronisation CalDAV et CardDAV du domaine si aucun autre service ne l'utilise déjà - par exemple, baikal
