If you are upgrading to a **new major version** of Nextcloud (e.g. 32, 33), **please make sure that your Nextcloud apps are up to date** from Nextcloud's administration panel beforehand.

Additionally, if you installed **specific Nextcloud apps**, we recommend **making sure that they are compatible with the new major version**.
YunoHost will attempt to check this automatically at the very beginning of the upgrade, but a manual check doesn't hurt either. See https://apps.nextcloud.com/apps/<app_name>  


* **Incompatible apps will cause the upgrade to fail.**
* Also make sure the **sury repo signing key** is up to date (run `sudo apt update` and check the output. If needed, this thread may help to renew this key : <https://forum.yunohost.org/t/yarn-and-sury-apt-keys-issues/41617>
