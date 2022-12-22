## Configuration

### Configure ONLYOFFICE integration

#### with Nextcloud App (no ARM support, lower performance)

Starting from Nextcloud 18, it features a direct integration of ONLYOFFICE (an online rich text document editor) through a Nextcloud app.
To install and configure it:
- Install *Community Document Server* application in your Nextcloud. That's the part that runs ONLYOFFICE server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an ONLYOFFICE server.
- Then in Settings -> ONLYOFFICE (`https://yourdomain.tld/nextcloud/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by ONLYOFFICE.
- Here you go :) You should be able to create new type of documents and open them.

*NB: ONLYOFFICE Nextcloud App is only available for x86 architecture - for **ARM** architecture (Raspberry Pi, OLinuXino...), consider the YunoHost App below*

#### with YunoHost App (ARM64 support, better performance)

For better performance and ARM64 support, install ONLYOFFICE YunoHost App and connect it to Nextcloud, see the tutorial in the [doc of onlyoffice_ynh package](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)


## YunoHost specific features

In addition to Nextcloud core features, the following are made available with
this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's not already served - i.e. by Baïkal
