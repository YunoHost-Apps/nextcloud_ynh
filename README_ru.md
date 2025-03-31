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

Nextcloud lets you access and synchronize data, files, contacts and calendars between different devices (PCs or mobiles), or share them with other people (with or without accounts), and also offers advanced communication and collaborative working features. Nextcloud features its own application mechanism (see also [Nextcloud's app store](https://apps.nextcloud.com/)) for specific functionalities. 

In the context of YunoHost, Nextcloud integrates with the SSO/User Portal (YunoHost accounts are automatically connected to Nextcloud).

The `/.well-known` address will be automatically configured for CalDAV and CardDAV synchronization if no other service such as Baïkal is already using it.

The YunoHost catalog has two collaborative office suites, [OnlyOffice](https://github.com/YunoHost-Apps/onlyoffice_ynh) and [Collabora](https://github.com/YunoHost-Apps/collabora_ynh), which can be integrated with Nextcloud.

**Поставляемая версия:** 29.0.14~ynh1

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

### Oldstable branch

This branch is following old stable release because nextcloud first release are often not totally stable.

Пришлите Ваш запрос на слияние в [ветку `oldstable`](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable).

Чтобы попробовать ветку `oldstable`, пожалуйста, сделайте что-то вроде этого:

```
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
or
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/oldstable --debug
```

**Больше информации о пакетировании приложений:** <https://yunohost.org/packaging_apps>
