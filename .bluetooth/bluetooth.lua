local love = require("love")
local Bluetooth = {}
local socket = require("socket")

local Config = require("config")

local isRunning = false

local devices = {}

function Bluetooth.IsRunning()
    return isRunning
end

function Bluetooth.PowerOn()
    if isRunning then
        return
    end

    isRunning = true
    os.execute("bluetoothctl power on")
    isRunning = false
end

function Bluetooth.PowerOff()
    if isRunning then
        return
    end

    isRunning = true

    os.execute("bluetoothctl power off")

    isRunning = false
end

function Bluetooth.ScanDevices(timeout)
    if isRunning then
        return
    end

    isRunning = true

    os.execute("bluetoothctl --timeout " .. timeout .." scan on");
    socket.sleep(timeout)

    isRunning = false
end

function Bluetooth.GetDevices()
    os.execute("bluetoothctl devices > " .. Config.DEVICE_PATH)
    socket.sleep(0.5)

    local file = io.open("data/devices.txt", "r")
    if file then
        for line in file:lines() do
            local lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            table.insert(devices, {ip = ip, name = name})
        end
    end

    return devices
end

return Bluetooth