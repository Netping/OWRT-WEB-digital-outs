local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.owrt_web_digital_outs.log"
---------------------------------------------------------
--------- Change these when create new adapter ----------
-- local adapter_config = "netping_luci_relay_adapter_http"
local adapter_config = "owrt_digital_outs"
local adapter_section = "http" -->>-- and all in the code
---------------------------------------------------------
---------------------------------------------------------
-- local adapter_jsname = adapter_config
local adapter_jsname = 'HTTP'

local http = {}
http.loaded = {}
http.id = nil

function http:new(relay_id)
	local template = uci:get_all(adapter_config, "template")
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do template[k] = nil end

	uci:section(adapter_config, adapter_section, relay_id, template)
	uci:commit(adapter_config)
	http.loaded = template
	http.id = relay_id

	return http.loaded
end


function http:get(optname)
	return http.loaded[optname]
end


function http:set(...)
	-- if obj provided as argument
	if(#arg == 1) then
		http.loaded = arg[1]
	end
	
	local success = false
	if(http.id) then
		--success = uci:get(adapter_config, http.id) or log("Unable to uci:get()", {adapter.config, http.id})
		for key, value in pairs(http.loaded) do
			if(key == "hostport" and (#util.split(value, ":") >= 2)) then
				success = uci:set(adapter_config, http.id, "address", util.split(value, ":")[1]) or log("Unable to uci:set() - ", {adapter_config, http.id, "address", util.split(value, ":")[1]})
				success = uci:set(adapter_config, http.id, "port", util.split(value, ":")[2]) or log("Unable to uci:set() - ", {adapter_config, http.id, "port", util.split(value, ":")[2]})
			end
			success = uci:set(adapter_config, http.id, key, value) or log("Unable to uci:set() - ", {adapter_config, http.id, key, value})
		end
	else
		log("ERROR http:set() - no http.id provided", {http})
	end
end

function http:save()
	local success = uci:save(adapter_config)
	success = success or log("ERROR: " .. adapter_config .. "uci:save() error", http.loaded)
end

function http:commit()
	local success = uci:commit(adapter_config)
	success = success or log("ERROR: " .. adapter_config .. "uci:commit() error", http.loaded)
end

function http:delete()
	local success = uci:delete(adapter_config, http.id) or log("Unable to uci:delete() adapter", adapter_config, http.id)
	success = uci:save(adapter_config) or log("Unable to uci:save() config after deleting adapter", adapter_config)
	success = uci:commit(adapter_config) or log("Unable to uci:commit() config after deleting adapter", adapter_config)
	http.table = nil
	http.id = nil
end

function http:getLabel()
	return adapter_section:upper()
end

function http:getName()
	return adapter_jsname
end

function http:render(optname, ...)
	local value = http.loaded[optname]
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
			return http:get(optname)
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
setmetatable(http, metatable)


return(http)