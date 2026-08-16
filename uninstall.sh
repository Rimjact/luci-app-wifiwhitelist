#!/bin/sh

cleanup_services() {
    echo "--- 🛠️ Готовимся удалять ---"

    echo "👾 Запускаем демонов обратно..."
    /etc/init.d/wifiwhitelist stop >/dev/null 2>&1 || true
    /etc/init.d/wifiwhitelist disable >/dev/null 2>&1 || true
    /etc/init.d/uhttpd restart >/dev/null 2>&1 || true

    echo "🛜 Восстанавливаем Wi-Fi интерфейс default_radio0..."
    uci delete wireless.default_radio0.macfilter
    uci commit wireless
    wifi reload

    echo "--- ✅ Приготовления к удалению закончены ---"
}

rmf() {
    rm -f "$@" 2>/dev/null || true
}

delete_project_files() {
    echo "--- ⚙️ Удаляем файлы проекта ---"

    rmf /etc/init.d/wifiwhitelist \
        /usr/libexec/wifiwhitelist \
        /usr/lib/lua/luci/controller/wifiwhitelist.lua \
        /usr/lib/lua/luci/view/wifiwhitelist.htm

    echo "--- ✅ Файлы проекта удалены ---"
}

uninstall_project() {
    echo "=== ▶️ Начало удаления Wi-Fi Whitelist ==="

    cleanup_services
    delete_project_files

    echo "=== 🎈 Wi-Fi Whitelist удалён ==="
    echo "Управление белым списком более недоступно."
    echo "Удалите зависимости вручную, если они не используются."

    rmf /tmp/wifiwhitelist-uninstall.sh
}

uninstall_project