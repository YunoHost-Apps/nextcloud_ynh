### Adding storage space

Solution I. allows you to add a link to a local or remote folder.  
Solution II. allows to move the main storage space of Nextcloud.

#### I. Add an external storage space

Parameter =>[Administration] External storage.

At the bottom of the list you can add a folder (It is possible to define a subfolder using the `folder/subfolder` convention.)  
Select a storage type and specify the requested connection information.  
You can restrict this folder to one or more nextcloud users with the column `Available for`.  
With the gear you can allow or prohibit previewing and file sharing.  
Finally click on the check mark to validate the folder.

#### II. Migrate Nextcloud data to a larger partition

**Note**: The following assumes that you have a hard disk mounted on `/media/storage`. Refer to[this article](/external_storage) to prepare your system.

**Note**: Replace `nextcloud` with the name of its instance, if you have several Nextcloud apps installed.

First turn off the web server with the command:
```bash
systemctl stop nginx  
```

##### Choice of location

**Case A: Blank storage, exclusive to Nextcloud**

For the moment only root can write to it in `/media/storage`, which means that NGINX and Nextcloud will not be able to use it.

```bash
chown -R nextcloud:nextcloud /media/storage
chmod 775 -R /media/storage
```

**Case B: Shared storage, data already present, Nextcloud data in a subfolder**

If you want to use this disk for other applications, you can create a subfolder belonging to Nextcloud.

```bash
mkdir -p /media/storage/nextcloud_data
chown -R nextcloud /media/storage/nextcloud_data
chmod 775 -R /media/storage/nextcloud_data
```

##### Migrate data

Migrate your data to the new disk. To do this *(be patient, it can take a long time)*:

```bash
Case A: cp -ia /home/yunohost.app/nextcloud /media/storage
Case B: cp -ia /home/yunohost.app/nextcloud /media/storage/nextcloud_data
```

The `i` option allows you to ask yourself what to do if there is a file conflict, especially if you overwrite an old Owncloud or Nextcloud data folder.  
To check that everything went well, compare what these two commands display (the content must be identical):

```bash
ls -la /home/yunohost.app/nextcloud

Case A: ls -al /media/storage
Case B: ls -al /media/storage/nextcloud_data/nextcloud
```

##### Configure Nextcloud

To inform Nextcloud of its new directory, modify the `/var/www/nextcloud/config/config.php` file with the command:

```bash
nano /var/www/nextcloud/config/config.php
```

Look for the line:

```bash
'datadirectory' => '/home/yunohost.app/nextcloud/data',
```

That you modify:

```bash
CASE A:'datadirectory' =>'/media/storage',
CASE B:'datadirectory' =>'/media/storage/nextcloud_data/nextcloud/data',
```

Save it with `ctrl+x` then `y` or `o` (depending on your server locale).

Restart the web server:

```bash
systemctl start nginx
```

Add the.ocdata file
```bash
CASE A: nano /media/storage/.ocdata
CASE B: nano /media/storage/nextcloud_data/nextcloud/data/.ocdata
```
Add a space to the file to be able to save it

Back up with `ctrl+x` then `y` or `o` (depending on your server locale).

Run a scan of the new directory by Nextcloud:

```bash
cd /var/www/nextcloud
sudo -u nextcloud php8.1 --define apc.enable_cli=1 files:scan --all
```

Update the YunoHost setting, so automatic upgrades and backups know where the datadir is located:
```bash
Case A: yunohost app setting nextcloud datadir -v /media/storage
Case B: yunohost app setting nextcloud datadir -v /media/storage/nextcloud_data/nextcloud/data/
```

It's over now. Now test if everything is fine, try connecting to your Nextcloud instance, upload a file, check its proper synchronization.
