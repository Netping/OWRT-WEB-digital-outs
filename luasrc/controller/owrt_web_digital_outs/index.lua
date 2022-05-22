module("luci.controller.owrt_web_digital_outs.index", package.seeall)

function index()
	entry({"admin", "services", "digital_outs"}, template("owrt_web_digital_outs/digital_outs", {autoapply=true, hideresetbtn=true}), _("Digital Outs"), 80).dependent=false
	entry({"admin", "services", "digital_outs", "settings"}, call("settings_digital_outs"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "settings-commit"}, call("settings_d_o_commit"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "refresh"}, call("d_o_refresh"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "status_refresh"}, call("d_o_status_refresh"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "select"}, call("d_o_select"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "add"}, call("d_o_add"), nil).dependent=false
	entry({"admin", "services", "digital_outs", "delete"}, call("d_o_delete"), nil).dependent=false
end

function settings_digital_outs()

    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()

    section_name = luci.http.formvalue("id")
    d_o_memo = cursor_digital_outs:get(config, section_name, "memo"); d_o_memo = ((d_o_memo==nil) and "" or d_o_memo)
    d_o_state_alias_0 = cursor_digital_outs:get(config, section_name, "state_alias_0"); d_o_state_alias_0 = ((d_o_state_alias_0==nil) and "" or d_o_state_alias_0)
    d_o_state_alias_1 = cursor_digital_outs:get(config, section_name, "state_alias_1"); d_o_state_alias_1 = ((d_o_state_alias_1==nil) and "" or d_o_state_alias_1)
    d_o_address = cursor_digital_outs:get(config, section_name, "address"); d_o_address = ((d_o_address==nil) and "" or d_o_address)
    d_o_oid = cursor_digital_outs:get(config, section_name, "oid"); d_o_oid = ((d_o_oid==nil) and "" or d_o_oid)
    d_o_community = cursor_digital_outs:get(config, section_name, "community"); d_o_community = ((d_o_community==nil) and "" or d_o_community)
    d_o_port = cursor_digital_outs:get(config, section_name, "port"); d_o_port = ((d_o_port==nil) and "" or d_o_port)
    d_o_period = cursor_digital_outs:get(config, section_name, "period"); d_o_period = ((d_o_period==nil) and "" or d_o_period)
    d_o_timeout = cursor_digital_outs:get(config, section_name, "timeout"); d_o_timeout = ((d_o_timeout==nil) and "" or d_o_timeout)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write(section_name.."\n"..d_o_memo.."\n"..d_o_state_alias_0.."\n"..d_o_state_alias_1.."\n"..d_o_address.."\n"..d_o_oid.."\n"..d_o_community.."\n"..d_o_port.."\n"..d_o_period.."\n"..d_o_timeout)
end

function settings_d_o_commit()

    id = luci.http.formvalue("id")
    memo = luci.http.formvalue("memo")
    state_alias_1 = luci.http.formvalue("state_alias_1")
    state_alias_0 = luci.http.formvalue("state_alias_0")
    address = luci.http.formvalue("address")
    oid = luci.http.formvalue("oid")
    community = luci.http.formvalue("community")
    port = luci.http.formvalue("port")
    period = luci.http.formvalue("period")
    timeout = luci.http.formvalue("timeout")

    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()
    cursor_digital_outs:set(config, id, "memo", memo)
    cursor_digital_outs:set(config, id, "state_alias_1", state_alias_1)
    cursor_digital_outs:set(config, id, "state_alias_0", state_alias_0)
    cursor_digital_outs:set(config, id, "proto", "SNMP")
    cursor_digital_outs:set(config, id, "address", address)
    cursor_digital_outs:set(config, id, "oid", oid)
    cursor_digital_outs:set(config, id, "community", community)
    cursor_digital_outs:set(config, id, "port", port)
    cursor_digital_outs:set(config, id, "period", period)
    cursor_digital_outs:set(config, id, "timeout", timeout)

    cursor_digital_outs:save()
    cursor_digital_outs:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "owrt-digital-outs" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")
end

function d_o_refresh()

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write(tostring(nixio.fs.stat("/etc/config/owrt-digital-outs").mtime))
end

function d_o_status_refresh()

    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()
    
luci.http.prepare_content("application/javascript; charset=utf-8")

    cursor_digital_outs:foreach(config, "info", function(s)
    if (s.memo==nill) then return end
    luci.http.write(s[".name"].."\n")
    exec_str = 'ubus call owrt-digital-outs get_state '.."'"..'{"id_relay":"'..s[".name"]..'", "ubus_rpc_session":"String"}'.."'"
    exec_str_result = luci.sys.exec(exec_str)
--    luci.http.write(exec_str.."\n")
    parsed_result = luci.jsonc.parse(exec_str_result)

    if parsed_result["state"]=="0" then
    state = "<font color='#c44'>"..s.state_alias_0.."</font>"
    elseif parsed_result["state"]=="1" then
    state = "<font color='#4c4'>"..s.state_alias_1.."</font>"
    else
    state = "--"
    end
	luci.http.write(state); luci.http.write("\n")
        luci.http.write(parsed_result["status"]); luci.http.write("\n")
    end)

end


function d_o_select()
    local id = luci.http.formvalue("id")
    local value = luci.http.formvalue("value")

    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()

    cursor_digital_outs:set(config, id, "start_state", value)
    cursor_digital_outs:save()
    cursor_digital_outs:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "owrt-digital-outs" '.."}'"
    luci.sys.call(string_for_ubus)
end

function d_o_add()

    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()

	    --luci.http.prepare_content("application/javascript; charset=utf-8")
	    --luci.http.write(globals_default_memo)

    globals_default_memo = cursor_digital_outs:get(config, "globals", "default_memo")
    globals_default_start_state = cursor_digital_outs:get(config, "globals", "default_start_state")
    globals_default_state = cursor_digital_outs:get_list(config, "globals", "default_state")
    globals_default_status = cursor_digital_outs:get_list(config, "globals", "default_status")
    globals_default_timeout = cursor_digital_outs:get(config, "globals", "default_timeout")
    globals_default_period = cursor_digital_outs:get(config, "globals", "default_period")
    snmp_default_memo = cursor_digital_outs:get(config, "relay_prototype_snmp", "memo")
    snmp_default_start_state = cursor_digital_outs:get(config, "relay_prototype_snmp", "start_state")
    snmp_default_state_alias_0 = cursor_digital_outs:get(config, "relay_prototype_snmp", "state_alias_0")
    snmp_default_state_alias_1 = cursor_digital_outs:get(config, "relay_prototype_snmp", "state_alias_1")
    snmp_default_proto = cursor_digital_outs:get(config, "relay_prototype_snmp", "proto")
    snmp_default_community = cursor_digital_outs:get(config, "relay_prototype_snmp", "community")
    snmp_default_address = cursor_digital_outs:get(config, "relay_prototype_snmp", "address")
    snmp_default_port = cursor_digital_outs:get(config, "relay_prototype_snmp", "port")
    snmp_default_oid = cursor_digital_outs:get(config, "relay_prototype_snmp", "oid")
    snmp_default_type_oid = cursor_digital_outs:get(config, "relay_prototype_snmp", "type_oid")
    snmp_default_timeout = cursor_digital_outs:get(config, "relay_prototype_snmp", "timeout")
    snmp_default_period = cursor_digital_outs:get(config, "relay_prototype_snmp", "period")

    default_memo = ((snmp_default_memo==nil) and globals_default_memo or snmp_default_memo)
    default_start_state = ((snmp_default_start_state==nil) and globals_default_start_state or snmp_default_start_state)
    default_state_alias_0 = snmp_default_state_alias_0; default_state_alias_1 = snmp_default_state_alias_1
    default_proto = snmp_default_proto
    default_community = snmp_default_community
    default_address = snmp_default_address
    default_port = snmp_default_port
    default_oid = snmp_default_oid
    default_type_oid = snmp_default_type_oid
    default_timeout = ((snmp_default_timeout==nil) and globals_default_timeout or snmp_default_timeout)
    default_period = ((snmp_default_period==nil) and globals_default_period or snmp_default_period)

    exec_str = "ubus call owrt-digital-outs get_free_id '"..'{"ubus_rpc_session":"String"}'.."'"

    exec_str_result = luci.sys.exec(exec_str)
    parsed_result = luci.jsonc.parse(exec_str_result)

--	    luci.http.prepare_content("application/javascript; charset=utf-8")
--	    luci.http.write(parsed_result["free_id"])

    add_digital_outs = cursor_digital_outs:section(config, "info", parsed_result["free_id"] , "")
    cursor_digital_outs:set(config, add_digital_outs, "memo", default_memo)
    cursor_digital_outs:set(config, add_digital_outs, "start_state", default_start_state)
    cursor_digital_outs:set(config, add_digital_outs, "state_alias_0", default_state_alias_0)
    cursor_digital_outs:set(config, add_digital_outs, "state_alias_1", default_state_alias_1)
    cursor_digital_outs:set(config, add_digital_outs, "proto", default_proto)
    cursor_digital_outs:set(config, add_digital_outs, "community", default_community)
    cursor_digital_outs:set(config, add_digital_outs, "address", default_address)
    cursor_digital_outs:set(config, add_digital_outs, "port", default_port)
--    cursor_digital_outs:set(config, add_digital_outs, "oid", default_oid)    
    cursor_digital_outs:set(config, add_digital_outs, "oid", ".1.3.6.1.4.1.")    
--    cursor_digital_outs:set(config, add_digital_outs, "type_oid", default_type_oid)
    cursor_digital_outs:set(config, add_digital_outs, "type_oid", "Integer")    
    cursor_digital_outs:set(config, add_digital_outs, "timeout", default_timeout)
    cursor_digital_outs:set(config, add_digital_outs, "period", default_period)

    cursor_digital_outs:save()
    cursor_digital_outs:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "owrt-digital-outs" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")
end

function d_o_delete()

    id = luci.http.formvalue("id")
    local config = "owrt-digital-outs"
    cursor_digital_outs = luci.model.uci.cursor()

    cursor_digital_outs:delete(config, id)

    cursor_digital_outs:save()
    cursor_digital_outs:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "owrt-digital-outs" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")

end