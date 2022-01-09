local util = require "luci.util"
local flist = require "luci.model.owrt_web_digital_outs.relay.filelist"


local adapter_path = util.libpath() .. "/model/owrt_web_digital_outs/relay/adapter"
local files = flist({path = adapter_path, grep = ".lua"})

local at, adapter_type = {}, ''
local adapter_models = {}

for i=1, #files do
	adapter_type = util.split(files[i], '.lua')[1]
	adapter_models[adapter_type] = require("luci.model.owrt_web_digital_outs.relay.adapter." .. adapter_type)
end

return(adapter_models)