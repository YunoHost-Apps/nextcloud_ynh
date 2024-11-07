<!--
注意：此 README 由 <https://github.com/YunoHost/apps/tree/master/tools/readme_generator> 自动生成
请勿手动编辑。
-->

# YunoHost 上的 Nextcloud

[![集成程度](https://dash.yunohost.org/integration/nextcloud.svg)](https://ci-apps.yunohost.org/ci/apps/nextcloud/) ![工作状态](https://ci-apps.yunohost.org/ci/badges/nextcloud.status.svg) ![维护状态](https://ci-apps.yunohost.org/ci/badges/nextcloud.maintain.svg)

[![使用 YunoHost 安装 Nextcloud](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=nextcloud)

*[阅读此 README 的其它语言版本。](./ALL_README.md)*

> *通过此软件包，您可以在 YunoHost 服务器上快速、简单地安装 Nextcloud。*  
> *如果您还没有 YunoHost，请参阅[指南](https://yunohost.org/install)了解如何安装它。*

## 概况

Nextcloud lets you access and synchronize data, files, contacts and calendars between different devices (PCs or mobiles), or share them with other people (with or without accounts), and also offers advanced communication and collaborative working features. Nextcloud features its own application mechanism (see also [Nextcloud's app store](https://apps.nextcloud.com/)) for specific functionalities. 

In the context of YunoHost, Nextcloud integrates with the SSO/User Portal (YunoHost accounts are automatically connected to Nextcloud).

The `/.well-known` address will be automatically configured for CalDAV and CardDAV synchronization if no other service such as Baïkal is already using it.

The YunoHost catalog has two collaborative office suites, [OnlyOffice](https://github.com/YunoHost-Apps/onlyoffice_ynh) and [Collabora](https://github.com/YunoHost-Apps/collabora_ynh), which can be integrated with Nextcloud.

**分发版本：** 29.0.9~ynh1

**演示：** <https://demo.nextcloud.com/>

## 截图

![Nextcloud 的截图](./doc/screenshots/screenshot.png)

## 文档与资源

- 官方应用网站： <https://nextcloud.com>
- 官方用户文档： <https://docs.nextcloud.com/server/latest/user_manual/en/>
- 官方管理文档： <https://docs.nextcloud.com/server/stable/admin_manual/>
- 上游应用代码库： <https://github.com/nextcloud/server>
- YunoHost 商店： <https://apps.yunohost.org/app/nextcloud>
- 报告 bug： <https://github.com/YunoHost-Apps/nextcloud_ynh/issues>

## 开发者信息

请向 [`testing` 分支](https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing) 发送拉取请求。

如要尝试 `testing` 分支，请这样操作：

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
或
sudo yunohost app upgrade nextcloud -u https://github.com/YunoHost-Apps/nextcloud_ynh/tree/testing --debug
```

**有关应用打包的更多信息：** <https://yunohost.org/packaging_apps>
