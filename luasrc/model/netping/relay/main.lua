local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.netping.log"
local config = "owrt_digital_outs"
local relay_section = "info"

local relay = {}
relay.loaded = {}

function relay:new()
	-- local prototype = uci:get_all(config, "relay_prototype")
	local prototype = {}
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do prototype[k] = nil end
	local globals = uci:get_all(config, "globals")
	local count = 0
	local maxcfg = 100000
	local cfg = 'cfg'
	uci:foreach(config, relay_section, function(r)
		local cfgnum = tonumber(string.sub(r[".name"], 4))
		if cfgnum > maxcfg then maxcfg = cfgnum end
		count = count + 1
		end
	)
	cfg = cfg .. tostring(maxcfg + 1)
	prototype["memo"] = globals["default_memo"] .. " " .. maxcfg - 100000 + 1
	prototype["start_state"] = globals["default_start_state"]
	prototype["state_alias_0"] = string.sub(globals["default_state"][1], 3)
	prototype["state_alias_1"] = string.sub(globals["default_state"][2], 3)
	prototype["timeout"] = globals["default_timeout"]
	prototype["period"] = globals["default_period"]

	local relay_id = uci:section(config, relay_section, cfg, prototype) or log("Unable to do uci:section()", {relay_section, prototype})
	relay.loaded = prototype
	relay.id = relay_id
	success = uci:commit(config) or log("Unable to uci:commit()", {config, 'New Relay'} )
	return relay
end

function relay:get(optname)
	return relay.loaded[optname]
end

function relay:set(optname, value)
	local id = relay.id
	local success = uci:set(config, id, optname, value) or log("Unable to uci:set()", {config, id, optname, value})
	success = uci:commit(config) or log("Unable to uci:commit()", {config, id, optname, value} )
end

function relay:delete()
	local id = relay.id
	-- Don't forget to protect embedded relays from deleting
	-- local embedded = uci:get(config, id, "embedded") == "1"
	local embedded = uci:get(config, id, "proto")
	-- if not embedded then
	if embedded == "SNMP" or embedded == "HTTP" or embedded == nil then
		local sucsess = uci:delete(config, id) or log("Unable to uci:delete()", {config, id})
		succsess = uci:commit(config) or log("Unable uci:commit() after uci:delete", {config})
	end
end

function relay:render(optname)
	local globals = uci:get_all(config, "globals")
	local value = relay.loaded[optname]
	local rendered = {
		-- Render specific representation of these options:
		---------------------------------------------------
		state = function()
			-- Prepare state label, customized with globals setting
			local state_label = {}
			for _, s in pairs(globals["state"]) do
				for k, v in s.gmatch(s, "(%d+)\.(.*)") do
					state_label[k] = v
				end
			end
			return state_label[value]
		end,

		status = function()
			local status_label = {}
			for _, s in pairs(globals["status"]) do
				for k, v in s.gmatch(s, "(%d+)\.(.*)") do
					status_label[k] = v
				end
			end
			return status_label[value]
		end,

		embedded = function()
			-- return relay.loaded["embedded"] == '1' and "Локально" or "Удалённо"
			local embedded = relay.loaded["proto"]
			if embedded == 'SNMP' or embedded == 'HTTP' then
				return "Удалённо"
			else
				if embedded == 'GPIO' or embedded == '1-wire' or embedded == 'I2C' or embedded == 'CAN' then
					return "Локально"
				else
					return "Не определено"
				end
			end
		end,

		-- All trivial options are rendered as is.
		-----------------------------------------
		default = function(optname)
			return relay:get(optname)
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
			table.loaded = uci:get_all(config, id) or table:new(id)
		end
		return table
	end
}
setmetatable(relay, metatable)


return(relay)