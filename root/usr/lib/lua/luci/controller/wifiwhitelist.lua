module("luci.controller.wifiwhitelist", package.seeall)

local http = require "luci.http"
local template = require "luci.template"
local sys = require "luci.sys"
local util = require "luci.util"

function index()
    entry(
        {"admin", "network", "wifiwhitelist"},
        call("main"),
        _("Wi-Fi Whitelist"),
        60
    ).dependent = false

    entry(
        {"admin", "network", "wifiwhitelist", "add"},
        call("add"),
        nil
    ).leaf = true

    entry(
        {"admin", "network", "wifiwhitelist", "remove"},
        call("remove"),
        nil
    ).leaf = true
end

function main()
    local output = sys.exec("/usr/libexec/wifiwhitelist list 2>/dev/null")
    local entries = {}

    for line in output:gmatch("[^\r\n]+") do
        local ifname, mac, expires = line:match("^(.-)\t(.-)\t(.+)$")

        if ifname and mac and expires then
            entries[#entries + 1] = {
                ifname = ifname,
                mac = mac,
                expires = expires
            }
        end
    end

    local interfaces = {}

    local wireless = sys.exec("iw dev 2>/dev/null")
    for ifname in wireless:gmatch("Interface%s+([%w%._%-]+)") do
        interfaces[#interfaces + 1] = ifname
    end

    template.render("wifiwhitelist", {
        entries = entries,
        interfaces = interfaces
    })
end

function add_perm(mac)
    if not mac then
        http.redirect(luci.dispatcher.build_url(
            "admin", "network", "wifiwhitelist"
        ))
        return
    end

    mac = mac:lower()

    local valid_mac = mac:match(
        "^%x%x:%x%x:%x%x:%x%x:%x%x:%x%x$"
    )

    if valid_mac then
        local command = string.format(
            "/usr/libexec/wifiwhitelist addperm %s >/dev/null 2>&1",
            util.shellquote(mac)
        )

        sys.call(command)
    end

    http.redirect(luci.dispatcher.build_url(
        "admin", "network", "wifiwhitelist"
    ))
end

function add()
    local ifname = http.formvalue("ifname")
    local mac = http.formvalue("mac")
    local delay = tonumber(http.formvalue("delay"))

    if not ifname or not mac then
        http.redirect(luci.dispatcher.build_url(
            "admin", "network", "wifiwhitelist"
        ))
        return
    end

    mac = mac:lower()

    local valid_ifname = ifname:match("^[%w%._%-]+$")
    local valid_mac = mac:match(
        "^%x%x:%x%x:%x%x:%x%x:%x%x:%x%x$"
    )

    if valid_ifname and valid_mac then
        if delay == 0 then
            add_perm(mac)
            return
        end

        local command = string.format(
            "/usr/libexec/wifiwhitelist add %s %s %s >/dev/null 2>&1",
            util.shellquote(ifname),
            util.shellquote(mac),
            util.shellquote(delay)
        )

        sys.call(command)
    end

    http.redirect(luci.dispatcher.build_url(
        "admin", "network", "wifiwhitelist"
    ))
end

function remove()
    local ifname = http.formvalue("ifname")
    local mac = http.formvalue("mac")

    if ifname and mac then
        local command = string.format(
            "/usr/libexec/wifiwhitelist remove %s %s >/dev/null 2>&1",
            util.shellquote(ifname),
            util.shellquote(mac)
        )

        sys.call(command)
    end

    http.redirect(luci.dispatcher.build_url(
        "admin", "network", "wifiwhitelist"
    ))
end