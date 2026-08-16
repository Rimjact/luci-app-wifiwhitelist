# Wi-Fi Whitelist
Wi-Fi whitelist controller for manual add and automatic remove MAC's after 1 hour. Have a page with add panel and current active devices table.

Контроллер для белого списка Wi-Fi, позволяющий добавлять вручную и автоматически удалять MAC-адреса через один час. Имеет страницу с панелью
добавления и таблицой текущих активных устройств.

---
## Featuers
- manually adding a device by MAC address via the convenient panel.
- automatic remove device by MAC after 1 hour;
- table with current active devices and remove buttons.
## Возможности
- ручное добавление устройства по MAC-адресу через удобную панель;
- автоматическое удаление устройства по MAC-адресу спустя час;
- таблица текущих активных устройств с кнопками удаления.
---
## Installation (Установка)
Copy and paste commands below to your SSH terminal and press Enter.
Скопируйте и вставьте команды ниже в ваш SSH терминал, после чего нажмите Enter.
```sh
wget -O /tmp/wifiwhitelist-install.sh https://raw.githubusercontent.com/Rimjact/luci-app-wifiwhitelist/main/install.sh
chmod +x /tmp/wifiwhitelist-install.sh
/tmp/wifiwhitelist-install.sh
```
After install go to Status -> Wi-Fi Stats at LuCI.

## Uninstallation (Удаление)
Copy and paste commands below to your SSH terminal and press Enter.
Скопируйте и вставьте команды ниже в ваш SSH терминал, после чего нажмите Enter.
```sh
wget -O /tmp/wifiwhitelist-uninstall.sh https://raw.githubusercontent.com/Rimjact/luci-app-wifiwhitelist/main/uninstall.sh
chmod +x /tmp/wifiwhitelist-uninstall.sh
/tmp/wifiwhitelist-uninstall.sh
```
---
## To-Do
- enter the removal delay (ввод времени для удаления);
- install by .ipk packet (установка засчёт .ipk пакета);
- fixes.