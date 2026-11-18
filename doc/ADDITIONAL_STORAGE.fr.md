### Ajouter de l'espace à Nextcloud
La solution I. permet d'ajouter un lien vers un dossier local ou distant.  
La solution II. permet de déplacer l'espace de stockage principal de Nextcloud.

#### I. Ajouter un espace de stockage externe

Paramètre => [Administration] Stockages externe.

En bas de la liste vous pouvez rajouter un dossier (Il est possible de définir un sous dossier en utilisant la convention `dossier/sousDossier`.)  
Sélectionner un type de stockage et indiquez les informations de connexion demandées.  
Vous pouvez restreindre ce dossier à un ou plusieurs utilisateurs nextcloud avec la colonne `Disponible pour`.  
Avec l'engrenage vous pouvez autoriser ou interdire la prévisualisation et le partage des fichiers.  
Enfin cliquer sur la coche pour valider le dossier.

#### II. Migrer les données de Nextcloud dans une partition plus grosse

**Remarque** : Ce qui suit suppose que vous avez un disque dur monté sur `/media/stockage`. Référez-vous à [cet article](/external_storage) pour préparer votre système.

**Remarque** : Remplacez `nextcloud` par le nom de son instance, si vous avez plusieurs apps Nextcloud installées.

Commencez par éteindre le serveur web avec la commande :
```bash
systemctl stop nginx  
```

##### Choix de l'emplacement

**Cas A : Stockage vierge, exclusif à Nextcloud**

Pour l'instant seul root peut y écrire dans `/media/stockage` ; ce qui signifie que NGINX et Nextcloud ne pourront donc pas l'utiliser.

```bash
chown -R nextcloud:nextcloud /media/stockage
chmod 775 -R /media/stockage
```

**Cas B : Stockage partagé, données déjà présentes, données Nextcloud dans un sous-dossier**

Si vous souhaitez utiliser ce disque pour d'autres applications, vous pouvez créer un sous-dossier appartenant à Nextcloud.

```bash
mkdir -p /media/stockage/nextcloud_data
chown -R nextcloud /media/stockage/nextcloud_data
chmod 775 -R /media/stockage/nextcloud_data
```

##### Migrer les données

Migrez vos données vers le nouveau disque. Pour ce faire *(soyez patient, cela peut être long)* :

```bash
Cas A : cp -ir /home/yunohost.app/nextcloud /media/stockage
Cas B : cp -ir /home/yunohost.app/nextcloud /media/stockage/nextcloud_data
```

L'option `i` permet de vous demander quoi faire en cas de conflit de fichier, notamment si vous écrasez un ancien dossier de données Owncloud ou Nextcloud.  
Pour vérifier que tout s'est bien passé, comparer ce qu'affichent ces deux commandes (le contenu doit être identique) :

```bash
ls -la /home/yunohost.app/nextcloud

Cas A : ls -al /media/stockage
Cas B : ls -al /media/stockage/nextcloud_data/nextcloud
```

##### Configurer Nextcloud

Pour informer Nextcloud de son nouveau répertoire, modifiez le fichier `/var/www/nextcloud/config/config.php` avec la commande :

```bash
nano /var/www/nextcloud/config/config.php
```

Cherchez la ligne :

```bash
'datadirectory' => '/home/yunohost.app/nextcloud/data',
```

Que vous modifiez :

```bash
CAS A : 'datadirectory' => '/media/stockage',
CAS B : 'datadirectory' => '/media/stockage/nextcloud_data/nextcloud/data',
```

Sauvegardez avec `ctrl+x` puis `y` ou `o` (dépend de la locale de votre serveur).

Relancez le serveur web :

```bash
systemctl start nginx
```

Ajouter le fichier .ocdata
```bash
CAS A : nano /media/stockage/.ocdata
CAS B : nano /media/stockage/nextcloud_data/nextcloud/data/.ocdata
```
Ajouter un espace au fichier pour pouvoir le sauvegarder

Sauvegardez avec `ctrl+x` puis `y` ou `o` (dépend de la locale de votre serveur).

Lancez un scan du nouveau répertoire par Nextcloud:

```bash
cd /var/www/nextcloud
sudo -u nextcloud php8.1 --define apc.enable_cli=1 files:scan --all
```

C'est terminé. À présent testez si tout va bien, essayez de vous connecter à votre instance Nextcloud, envoyer un fichier, vérifiez sa bonne synchronisation.
