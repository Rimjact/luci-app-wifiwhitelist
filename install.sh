#!bin/sh

REPOSITORY="https://raw.githubusercontent.com/Rimjact/luci-app-wifiwhitelist"
BRANCH="main"

install_depends() {
    echo "--- 🔃 Устанавливаем зависимости ---"
    echo "Зависимости: luci-base lua luci-lua-runtime libubus-lua liblucihttp-lua procd wpad hostapd-utils"

    apk update
    apk del wpad-basic-mbedtls
    apk add wpad hostapd-utils
    apk add luci-base lua luci-lua-runtime libubus-lua liblucihttp-lua procd

    echo "--- ✅ Зависимости установлены ---"
}

create_directories() {
    echo "--- 📁 Создаём директории ---"

    echo "/etc/init.d/"
    mkdir -p /etc/init.d/
    echo "/usr/libexec/"
    mkdir -p /usr/libexec/
    echo "/usr/lib/lua/luci/controller/"
    mkdir -p /usr/lib/lua/luci/controller/
    echo "/usr/lib/lua/luci/view/"
    mkdir -p /usr/lib/lua/luci/view/

    echo "--- ✅ Директории созданы ---"
}

try_download_file() {
    local file="$1"
    local dest="$2"

    wget -q -O "$dest" "$file" >/dev/null 2>&1 && return 0

    return 1
}

download_file() {
    local file_path="$1"
    local dest="$2"

    local status=0

    echo "🔃 Скачиваем файл: $1"
    if try_download_file "${REPOSITORY}/${BRANCH}/${file_path}" "$dest"; then
        status=1
    fi

    if [ "$status" -ne 1 ]; then
        echo "❌ Не удалось скачать файл ${file_path}. Попробуйте повторить установку позже." >&2
        exit 1
    fi
}

download_project_files() {
    echo "--- ⚙️ Скачиваем файлы проекта ---"

    download_file "root/etc/init.d/wifiwhitelist" "/etc/init.d/wifiwhitelist"
    download_file "root/usr/libexec/wifiwhitelist" "/usr/libexec/wifiwhitelist"
    download_file "root/usr/lib/lua/luci/controller/wifiwhitelist.lua" "/usr/lib/lua/luci/controller/wifiwhitelist.lua"
    download_file "root/usr/lib/lua/luci/view/wifiwhitelist.htm" "/usr/lib/lua/luci/view/wifiwhitelist.htm"

    echo "--- ✅ Файлы проекта скачаны ---"
}

start_daemon() {
    echo "--- 🛠️ Проводим последние приготовления ---"

    echo "📕 Регулируем права..."
    chmod 755 /etc/init.d/wifiwhitelist
    chmod 755 /usr/libexec/wifiwhitelist

    echo "🛜 Настраиваем Wi-Fi интерфейс default_radio0"
    uci set wireless.default_radio0.macfilter='allow'
    uci commit wireless
    wifi reload

    echo "👾 Выпускаем демонов..."
    /etc/init.d/wifiwhitelist enable >/dev/null 2>&1 || true
    /etc/init.d/wifiwhitelist restart >/dev/null 2>&1 || true
    /etc/init.d/uhttpd restart >/dev/null 2>&1 || true

    echo "--- ✅ Приготовления закончены ---"
}

install_project() {
    echo "=== ▶️ Начало установки Wi-Fi Whitelist ==="
    echo "🔹${REPOSITORY}/${BRANCH}"

    install_depends
    create_directories
    download_project_files
    start_daemon

    echo "=== 🎉 Wi-Fi Whitelist установлен ==="
    echo "Управление белым списком доступно на Сеть -> Wi-Fi Whitelist"

    rm -f /tmp/wifiwhitelist-install.sh 2>/dev/null || true

    echo "ВЫПОЛНЯЕТСЯ ПЕРЕЗАГРУЗКА УСТРОЙСТВА..."
    sleep 3
    reboot
}

install_project