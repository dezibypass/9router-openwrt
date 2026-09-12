module("luci.controller.9router", package.seeall)
function index()
  entry({"admin", "services", "9router"}, alias("admin", "services", "9router", "status"), _("9Router"), 90).dependent = false
  entry({"admin", "services", "9router", "status"}, template("9router/status"), _("Status"), 1)
  entry({"admin", "services", "9router", "settings"}, cbi("9router"), _("Settings"), 2)
  entry({"admin", "services", "9router", "action"}, call("do_action"), nil).leaf = true
end
function do_action()
  local http = require "luci.http"
  local util = require "luci.util"
  local act = http.formvalue("act")
  local ok = 1
  local msg = ""
  local function q(s)
    if util and util.shellquote then return util.shellquote(s) end
    return "'" .. tostring(s):gsub("'", "''") .. "'"
  end
  if act == "start" then
    msg = util.exec("/etc/init.d/9router start 2>&1")
  elseif act == "stop" then
    msg = util.exec("/etc/init.d/9router stop 2>&1")
  elseif act == "restart" then
    msg = util.exec("/etc/init.d/9router restart 2>&1; sleep 2; ubus call service list 2>/dev/null | grep -A2 9router")
  elseif act == "resetpw" then
    local pw = http.formvalue("pw") or ""
    if #pw >= 4 then
      msg = util.exec("/usr/sbin/9router-reset-password " .. q(pw) .. " 2>&1")
      if not msg:match("password updated") and not msg:match("^OK") then ok = 0 end
    else ok = 0; msg = "password minimal 4 karakter" end
  elseif act == "status" then
    msg = util.exec("ubus call service list 2>/dev/null | grep -A6 '\"9router\"'; echo ---; netstat -tlnp 2>/dev/null | grep 20128; echo ---; uci show 9router 2>&1")
  else ok = 0; msg = "unknown act" end
  http.prepare_content("application/json")
  http.write_json({ok = ok, msg = msg or ""})
end
