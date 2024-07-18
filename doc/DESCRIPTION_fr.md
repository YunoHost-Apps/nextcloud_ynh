Nextcloud permet de rendre accessible et de synchroniser ses données, fichiers, contacts, agendas entre différents appareils (ordinateurs ou mobiles), ou de les partager avec d'autres personnes (avec ou sans comptes), et propose également des fonctionnalités avancées de communication et de travail collaboratif. Nextcloud dispose de son propre mécanisme d'applications (voir aussi [le store d'apps de Nextcloud](https://apps.nextcloud.com/)) pour disposer des fonctionnalités spécifiques.

Dans le cadre de YunoHost, Nextcloud s'intègre avec le SSO / portail utilisateur (les comptes YunoHost sont automatiquements connectés à Nextcloud).

L'adresse  `/.well-known` sera automatiquement configuré pour la synchronisation CalDAV et CardDAV si aucun autre service tel que Baïkal ne l'utilise déjà.
