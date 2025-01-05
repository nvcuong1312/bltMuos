local socket = require("socket")
local Config = require("config")
local StringHelper = require("Helper/StringHelper")

local Audio = {}

function Audio.DefaultSinkNumber()
    local cmd = "wpctl status | grep -A 5 Sinks | grep '\\*' | sed 's/ \\|.*\\*   //' | cut -f1 -d'.' > " .. Config.AUDIO_SINK_NUMBER

    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute(cmd)
        socket.sleep(0.5)
    end

    local file = io.open(Config.AUDIO_SINK_NUMBER, "r")
    local defSinkNumber = ""
    if file then
        defSinkNumber = StringHelper.Trim(file:read("*a"))
        file:close()
    end

    return defSinkNumber
end

function Audio.Sinks()
    local cmd = "pw-dump | jq -r '.[] | select(.type == \"PipeWire:Interface:Node\") | select(.info.props[\"media.class\"] == \"Audio/Sink\") | \"\\(.id):\\(.info.props[\"node.description\"])\"' > " ..Config.AUDIO_SINKS
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute(cmd)
        socket.sleep(0.5)
    end

    local file = io.open(Config.AUDIO_SINKS, "r")
    local sinks = {}
    if file then
        for line in file:lines() do
            local id, name = line:match("^(%d+):(.+)$")
            table.insert(sinks, {id = StringHelper.Trim(id), name = StringHelper.Trim(name)})
        end
    end

    file:close()
    return sinks
end

function Audio.Select(id)
    local cmd = "wpctl set-default \"" .. id .. "\""
    local cmd2 = "echo \"" .. id .."\" > \"/run/muos/audio/nid_internal\""
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute(cmd)
        os.execute(cmd2)
        socket.sleep(0.5)
    end

end

return Audio