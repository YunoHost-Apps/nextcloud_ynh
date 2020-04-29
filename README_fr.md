# Nextcloud pour YunoHost

[![Niveau d'integration](https://dash.yunohost.org/integration/nextcloud.svg)](https://dash.yunohost.org/appci/app/nextcloud)  
[![Install Nextcloud with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=nextcloud)

*[Read this readme in english.](./README.md)* 


> *Ce package vous permet d'installer Nextcloud rapidement et simplement sur un serveur Yunohost.   
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

[Nextcloud](https://nextcloud.com) vous donne la liberté et le contrôle sur vos données. Un nuage personnel qui tourne sur votre serveur.
Avec NextCloud vous pouvez synchroniser vos fichiers sur vos appareils.

**Version incluse :** 18.0.2

## Captures d'écran

![](https://raw.githubusercontent.com/nextcloud/screenshots/master/files/Files%20Overview.png)

## Démo

* [Démo YunoHost](https://demo.yunohost.org/nextcloud/)
* [Démo officielle](https://demo.nextcloud.com/)

## Configuration

## Documentation

 * Documentation officielle : https://docs.nextcloud.com/server/18/user_manual/
 * Documentation YunoHost : https://github.com/YunoHost/doc/blob/master/app_nextcloud_fr.md

## Caractéristiques spécifiques YunoHost

En plus des fonctionnalités principales de Nextcloud, les fonctionnalités suivantes sont incluses dans ce package :

 * Intégration avec les utilisateurs YunoHost et le SSO - exemple, le bouton de déconnexion
 * Permet à un utilisateur d'être l'administrateur (choisi à l'installation)
 * Permet de multiples instances de cette application
 * Accès optionnel au répertoire home depuis les fichiers Nextcloud (à activer à l'installation, le partage étant activé par défaut)
 * Utilise le répertoire `/.well-known` pour la synchronisation CalDAV et CardDAV du domaine si aucun autre service ne l'utilise déjà -par exemple, baikal

#### Support multi-utilisateurs

#### Architectures supportées

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/ci/logs/nextcloud%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/nextcloud%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/nextcloud/)

## Limitations

Pour intégrer le bouton de déconnexion du SSO, nous devons patcher les sources de Nextcloud.
En attendant un intégration de leur part, la vérification d'intégrité du code source est désactivée pour ne pas avoir de message d'avertissement.

Donc notez que nous avons choisi de désactiver la applications de tierces-parties lors des mises à jour. Ça permet d'éviter une installation de Nextcloud instable - ou qui pourrait planter.
Vous devrez juste les réactiver manuellement après chaque mise à jour.

Et enfin, le message d'erreur suivant dans les logs de Nextcloud peut être ignoré sans problème :
```
Following symlinks is not allowed ('/home/yunohost.multimedia/user/Share' -> '/home/yunohost.multimedia/share/' not inside '/home/yunohost.multimedia/user/')
```

## Informations supplémentaires

#### Migrer depuis ownCloud

**La migration n'est pas encore considérée comme stable, merci de la faire prudemment et uniquement pour tester !**

Ce package gère la migration de OwnCloud vers Nextcloud. Pour ça, l'application OwnCloud doit **être à jour** dans YunoHost.

Vous allez ensuite mettre à niveau votre OwnCloud avec ce dépôt.
Ça ne peut être fait qu'en ligne de commande - par exemple via SSH. Une fois connecté, vous n'avez plus qu'à exécuter la commande suivante :
```bash
sudo yunohost app upgrade -u https://github.com/YunoHost-Apps/nextcloud_ynh owncloud --debug
```

L'option `--debug` va vous permettre de visualiser entièrement les retours de la mise à niveau. Si vous rencontrez un problème, merci de nous le transmettre.

Notez qu'une tâche cron va être exécutée une fois la fin de cette commande. Vous devez attendre qu'elle se fasse avant de faire une autre opération liée aux applications.
Nous espérons que Nextcloud sera installé après ça.

Notez que ça ne changera pas la label ni l'URL. Pour renommer le label, vous pouvez exécuter la commande suivante (en remplaçant `Nextcloud` par ce que vous voulez) :
```bash
sudo yunohost app setting nextcloud label -v "Nextcloud"
sudo yunohost app ssowatconf
```

## Links

 * Signaler un bug : https://github.com/YunoHost-Apps/nextcloud_ynh/issues
 * Site web de Nextcloud : https://nextcloud.com/
 * Dpôt de Nextcloud : https://github.com/nextcloud/server
 * Site web de YunoHost : https://yunohost.org/
 
---
Informations pour les développeurs
----------------

Merci de faire votre « pull request » sur la [branche de test](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).
Pour tester la branche de test, faites comme ceci.
```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
ou
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```
