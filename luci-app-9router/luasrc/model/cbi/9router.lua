m = Map("9router", translate("9Router Settings"))
s = m:section(TypedSection, "main", translate("Main"))
s.anonymous = true
s.addremove = false
e = s:option(Flag, "enabled", translate("Enabled"))
e.default = "1"
e.rmempty = false
p = s:option(Value, "port", translate("Port"))
p.default = "20128"
p.datatype = "port"
h = s:option(Value, "host", translate("Host"))
h.default = "0.0.0.0"
d = s:option(Value, "data_dir", translate("Data dir"))
d.default = "/mnt/data/9router-data"
return m
