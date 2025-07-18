### Exécuter manuellement des commandes Nextcloud

Vous pouvez lancer des commandes Nextcloud en ouvrant un "shell" Nextcloud et utiliser `php occ` directement:

```bash
sudo yunohost app shell __APP__
# Vous devriez voir que vous êtes dans un shell "__APP__@yourmachine"
php occ ...
```

Autrement, vous pouvez exécuter `sudo -u __APP__ php__PHP_VERSION__ --define apc.enable_cli=1 __INSTALL_DIR__/occ ...`

### Ajouter un compte aux admins de Nextcloud

Dans certains cas, votre compte n'est peut-être pas un admin de Nextcloud et ne peut donc pas accéder aux fonctionnalités admin.

Vous pouvez ajouter le comptes aux admins de Nextcloud avec:

```bash
sudo yunohost app shell __APP__
# Puis
php occ group:adduser admin <username>
```
