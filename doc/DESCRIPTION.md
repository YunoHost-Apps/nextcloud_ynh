Nextcloud Hub is a fully open-source on-premises content collaboration platform. Teams access, share and edit their documents, chat and participate in video calls and manage their mail and calendar and projects across mobile, desktop and web interfaces.

### YunoHost-specific features

In addition to Nextcloud core features, the following are made available with this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's not already served - i.e. by Baïkal

### Oldstable branch

This branch is following old stable release because nextcloud first release are often not totally stable.

Please send your pull request to the [oldstable branch](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable).

To try the oldstable branch, please proceed like that.

```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
or
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
```
