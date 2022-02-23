module("luci.controller.owrt_web_digital_outs.index", package.seeall)

local config = "owrt_digital_outs"

local relay = require "luci.model.owrt_web_digital_outs.relay.main"

require "ubus"

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.owrt_web_digital_outs.log"

function notify_backend_on_commit(config_name)
	local conn = ubus.connect()
	if not conn then
		error("Failed to connect to ubus")
	end
	conn:send("commit", { config = config_name})
	conn:close()
end

function index()
	if nixio.fs.access("/etc/config/owrt_digital_outs") then
		entry({"admin", "system", "relay"}, cbi("owrt_web_digital_outs/relay"), translate("douts_tab"), 30)
		entry({"admin", "system", "relay", "action"}, call("do_relay_action"), nil).leaf = true
		-- entry({"admin", "system", "alerts"}, cbi("owrt_digital_outs/alert"), nil).leaf = true
		-- entry({"admin", "system", "alerts", "action"}, call("do_action"), nil).leaf = true
		entry({"admin", "system", "relay", "indication"}, call("get_indication"), nil).leaf = true
	end
end

function get_indication()
	local mtime = nixio.fs.stat("/etc/config/owrt_digital_outs").mtime
	local relay_indication = {
		status = {},
		state = {},
		mtime = {}
	}
	local ubus_response = {}
	local all_relays = uci:foreach(config, "info", function(relay)
		util.perror(relay["proto"])
		if(relay["proto"]) then
			if ((relay["address"] and relay["port"] and relay["oid"]) or relay["hostport"] ) then
				util.perror('indicate')
				-- Get statuses of all relays
				ubus_response = util.ubus("owrt_digital_outs", "get_state", {id_relay = relay['.name']})
				if(ubus_response and type(ubus_response) == "table" and ubus_response["status"] and ubus_response["state"]) then
					relay_indication.status[relay[".name"]] = ubus_response["status"]
					relay_indication.state[relay[".name"]] = ubus_response["state"]
					relay_indication.mtime[relay[".name"]] = mtime
				end
			end
		end
	end)

	-- Return to web-interface as JSON
	http.prepare_content("application/json")
	http.write(util.serialize_json(relay_indication))
end


function do_relay_action(action, relay_id)
	local payload = {}
	payload["relay_data"] = luci.jsonc.parse(luci.http.formvalue("relay_data"))
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do payload["relay_data"][k] = nil end
	payload["globals_data"] = luci.jsonc.parse(luci.http.formvalue("globals_data"))
	payload["adapter_data"] = luci.jsonc.parse(luci.http.formvalue("adapter_data"))

	local sucsess = false

	local commands = {
		add = function(...)
			relay():new()
		end,
		rename = function(relay_id, payload)
			if payload["relay_data"]["memo"] then
				relay(relay_id):set("memo", payload["relay_data"]["memo"])
			end
		end,
		delete = function(relay_id, ...)
			relay(relay_id):delete()
		end,
		switch = function(relay_id, ...)
			util.ubus("owrt_digital_outs", "switch_relay", {id_relay = relay_id})
		end,
		edit = function(relay_id, payloads)
			-- apply relay settings
			local allowed_relay_options = util.keys(uci:get_all(config, "relay_prototype_" .. string.lower(payloads["relay_data"].proto)))
			local currelayconf = uci:get_all(config, relay_id)
			for key, value in pairs(payloads["relay_data"]) do
				if util.contains(allowed_relay_options, key) then
					uci:set(config, relay_id, key, value)
				end
			end
			for key, value in pairs(currelayconf) do
				if not (util.contains(allowed_relay_options, key)) then
					uci:delete(config, relay_id, key)
				end
			end
			uci:commit(config)
			-- notify_backend_on_commit(config)
		end,
		default = function(...)
			http.prepare_content("text/plain")
			http.write("0")
		end
	}
	if commands[action] then
		commands[action](relay_id, payload)
		commands["default"]()
		if action ~= 'switch' then
			notify_backend_on_commit('owrt_digital_outs')
		end
	end
end
