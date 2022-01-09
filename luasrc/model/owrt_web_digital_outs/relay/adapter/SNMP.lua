local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.owrt_web_digital_outs.log"
---------------------------------------------------------
--------- Change these when create new adapter ----------
-- local adapter_config = "netping_luci_relay_adapter_snmp"
local adapter_config = "owrt_digital_outs"
local adapter_section = "SNMP" -->>-- and all in the code
---------------------------------------------------------
---------------------------------------------------------
-- local adapter_jsname = adapter_config
local adapter_jsname = 'SNMP'

local snmp = {}
snmp.loaded = {}
snmp.id = nil

function snmp:new(relay_id)
	local template = uci:get_all(adapter_config, "template")
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do template[k] = nil end

	uci:section(adapter_config, adapter_section, relay_id, template)
	uci:commit(adapter_config)
	snmp.loaded = template
	snmp.id = relay_id

	return snmp.loaded
end


function snmp:get(optname)
	return snmp.loaded[optname]
end


function snmp:set(...)
	-- if obj provided as argument
	if(#arg == 1) then
		snmp.loaded = arg[1]
	end

	local success = false
	if(snmp.id) then
		success = uci:get(adapter_config, snmp.id) or log("Unable to uci:get()", {adapter.config, snmp.id})
		log("SNMP", snmp.loaded)
		for key, value in pairs(snmp.loaded) do
			success = uci:set(adapter_config, snmp.id, key, value) or log("Unable to uci:set() - ", {adapter_config, snmp.id, key, value})
		end
	else
		log("ERROR snmp:set() - no snmp.id provided", {snmp})
	end
end


function snmp:save()
	local success = uci:save(adapter_config)
	success = success or log("ERROR: " .. adapter_config .. "uci:save() error", snmp.loaded)
end


function snmp:commit()
	local success = uci:commit(adapter_config)
	success = success or log("ERROR: " .. adapter_config .. "uci:commit() error", snmp.loaded)
end


function snmp:delete()
	local success = uci:delete(adapter_config, snmp.id) or log("Unable to uci:delete() adapter", adapter_config, snmp.id)
	success = uci:commit(adapter_config) or log("Unable to uci:commit() config after deleting adapter", adapter_config)
	snmp.table = nil
	snmp.id = nil
end


function snmp:getLabel()
	return adapter_section:upper()
end

function snmp:getName()
	return adapter_jsname
end


function snmp:render(optname, ...)
	local value = snmp.loaded[optname]
	local rendered = {
		-- Render specific representation of uci option and define extra, non-uci options
		---------------------------------------------------------------------------------
		cssfile = function()
			local path = util.libpath() .. '/view/owrt_web_digital_outs/ui_adapter/' .. adapter_jsname .. '.css.htm'
			return fs.readfile(path)
		end,

		validator = function()
			local path = util.libpath() .. '/view/owrt_web_digital_outs/ui_adapter/' .. adapter_jsname .. '.valid.js.htm'
			return fs.readfile(path)
		end,

		widgetfile = function()
			local path = util.libpath() .. '/view/owrt_web_digital_outs/ui_adapter/' .. adapter_jsname .. '.js.htm'
			return fs.readfile(path)
		end,

		jsinit = function()
			return string.format("var %s = new ui.%s(relay_id)", adapter_jsname, adapter_jsname)
		end,

		jsrender = function()
			return  adapter_jsname .. ".render()"
		end,

		getvalues = function()
			return  adapter_jsname .. ".getValue()"
		end,

		getfields = function()
			return  adapter_jsname .. ".getFields()"
		end,

		-- All trivial options are rendered as is
		-----------------------------------------
		default = function(optname)
			return snmp:get(optname)
		end
	}
	return rendered[optname] ~= nil and rendered[optname]() or rendered['default'](optname)
end

-- Make a Functable to load relay with "relay(id)" style
local metatable = { 
	__call = function(table, ...)

		-- if id provided, then load from uci or create with template
		-- if id not provided, then only create the object for methods using
		local id = arg[1] ~= nil and arg[1] or nil
		if(id) then
			table.id = id
			table.loaded = uci:get_all(adapter_config, id) or table:new(id)
		end
		return table
	end
}
setmetatable(snmp, metatable)


return(snmp)