### Configure ONLYOFFICE integration

#### With Nextcloud App (no ARM support, lower performance)

Starting from Nextcloud 18, it features a direct integration of ONLYOFFICE (an online rich text document editor) through a Nextcloud app.
To install and configure it:
- Install *Community Document Server* application in your Nextcloud. That's the part that runs ONLYOFFICE server.
- Install *ONLYOFFICE* application. That's the client part that will connect to an ONLYOFFICE server.
- Then in Settings -> ONLYOFFICE (`https://yourdomain.tld/nextcloud/settings/admin/onlyoffice`), if you want to configure which file formats should be opened by ONLYOFFICE.
- Here you go :) You should be able to create new type of documents and open them.

*NB: ONLYOFFICE Nextcloud App is only available for x86 architecture - for **ARM** architecture (Raspberry Pi, OLinuXino...), consider the YunoHost App below*

#### With YunoHost App (ARM64 support, better performance)

For better performance and ARM64 support, install ONLYOFFICE YunoHost App and connect it to Nextcloud, see the tutorial in the [doc of onlyoffice_ynh package](https://github.com/YunoHost-Apps/onlyoffice_ynh/blob/master/README_fr.md#configuration-de-onlyoffice-server)

#### High Performance Backend

This is an application on Nextcloud that should speed up the instance, more information here: https://github.com/nextcloud/notify_push#about

