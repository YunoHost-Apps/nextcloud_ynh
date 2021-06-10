## Configuration

#### Configure OnlyOffice integration

Starting from Nextcloud 18, it features a direct integration of OnlyOffice (an online rich text document editor) through a Nextcloud app.
To install and configure it:
- Install *Community Document Server* application in your Nextcloud. That's the part that runs OnlyOffice server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an OnlyOffice server.
- Then in Settings -> ONLYOFFICE (`https://yourdomain.tld/nextcloud/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by OnlyOffice.
- Here you go :) You should be able to create new type of documents and open them.

*NB: OnlyOffice is only available for x86 architecture - **ARM** architecture is **not** supported (Raspberry Pi, OLinuXino...)*

#### High Performance Backend

This is an application on Nextcloud that should speed up the instance, more information here: https://github.com/nextcloud/notify_push#about

## YunoHost specific features

In addition to Nextcloud core features, the following are made available with
this package:

 * Integrate with YunoHost users and SSO - i.e. logout button
 * Allow one user to be the administrator (set at the installation)
 * Allow multiple instances of this application
 * Optionally access the user home folder from Nextcloud files (set at the installation, the sharing is enabled by default)
 * Serve `/.well-known` paths for CalDAV and CardDAV on the domain only if it's not already served - i.e. by Baïkal
