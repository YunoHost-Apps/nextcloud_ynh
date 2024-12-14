<!--
Важно: этот README был автоматически сгенерирован <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Он НЕ ДОЛЖЕН редактироваться вручную.
-->

# Nextcloud для YunoHost

[![Уровень интеграции](https://apps.yunohost.org/badge/integration/nextcloud)](https://ci-apps.yunohost.org/ci/apps/nextcloud/)
![Состояние работы](https://apps.yunohost.org/badge/state/nextcloud)
![Состояние сопровождения](https://apps.yunohost.org/badge/maintained/nextcloud)

[![Установите Nextcloud с YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[Прочтите этот README на других языках.](./ALL_README.md)*

> *Этот пакет позволяет Вам установить Nextcloud быстро и просто на YunoHost-сервер.*  
> *Если у Вас нет YunoHost, пожалуйста, посмотрите [инструкцию](https://yunohost.org/install), чтобы узнать, как установить его.*

## Обзор

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


**Поставляемая версия:** 28.0.14~ynh1

**Демо-версия:** <https://demo.nextcloud.com/>

## Снимки экрана

![Снимок экрана Nextcloud](./doc/screenshots/screenshot.png)

## Документация и ресурсы

- Официальный веб-сайт приложения: <https://nextcloud.com>
- Официальная документация пользователя: <https://docs.nextcloud.com/server/latest/user_manual/en/>
- Официальная документация администратора: <https://docs.nextcloud.com/server/stable/admin_manual/>
- Репозиторий кода главной ветки приложения: <https://github.com/nextcloud/server>
- Магазин YunoHost: <https://apps.yunohost.org/app/nextcloud>
- Сообщите об ошибке: <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## Информация для разработчиков

Пришлите Ваш запрос на слияние в [ветку `testing`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing).

Чтобы попробовать ветку `testing`, пожалуйста, сделайте что-то вроде этого:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
или
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**Больше информации о пакетировании приложений:** <https://yunohost.org/packaging_apps>
