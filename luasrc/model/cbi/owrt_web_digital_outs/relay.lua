
local config, title = "owrt_digital_outs", "Digital Outs"

m = Map(config, title)
m.template = "owrt_web_digital_outs/relay_list"
m.pageaction = false

return m
