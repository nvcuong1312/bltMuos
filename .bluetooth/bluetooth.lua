local love = require("love")
local socket = require("socket")

local Config = require("config")

local devices = {}

function ScanDevices(timeout)
    os.execute("bluetoothctl --timeout " .. timeout .." scan on");
    socket.sleep(timeout)
end

function GetDevices()
    os.execute("bluetoothctl devices > " .. DEVICE_PATH)
    socket.sleep(0.5)

    local file = io.open("data/devices.txt", "r")
    if file then
        for line in file:lines() do
            lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            table.insert(devices, {ip = ip, name = name})
        end
    end

    return devices
end

return Bluetooth