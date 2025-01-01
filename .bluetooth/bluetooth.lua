local love = require("love")
local socket = require("socket")
local Config = require("config")

local Bluetooth = {}

local isRunning = false

local availableDevices = {}
local connectedDevices = {}

function Bluetooth.IsPowerOn()
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl show > " .. Config.BLUETOOTH_SHOW_PATH)
        socket.sleep(0.5)
    end

    local file = io.open(Config.BLUETOOTH_SHOW_PATH, "r")
    if file then
        for line in file:lines() do
            if string.find(line, "Powered: yes") then
                return true
            end
        end
    end
    return false
end

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

    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl --timeout " .. timeout .." scan on");
        -- socket.sleep(timeout)
    end

    isRunning = false
end

function Bluetooth.GetAvailableDevices()
    availableDevices = {}

    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl devices > " .. Config.AVAILABLE_DEVICES_PATH)
        socket.sleep(0.5)
    end

    local file = io.open(Config.AVAILABLE_DEVICES_PATH, "r")
    if file then
        for line in file:lines() do
            local lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            table.insert(availableDevices, {ip = ip, name = name})
        end
    end

    return availableDevices
end

function Bluetooth.GetConnectedDevices()
    connectedDevices = {}

    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl devices Trusted > " .. Config.CONNECTED_DEVICES_PATH)
        socket.sleep(0.5)
    end

    local file = io.open(Config.CONNECTED_DEVICES_PATH, "r")
    if file then
        for line in file:lines() do
            local lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            table.insert(connectedDevices, {ip = ip, name = name})
        end
    end

    return connectedDevices
end

function Bluetooth.Disconnect(deviceMAC)
    os.execute("bluetoothctl remove " .. deviceMAC)
    socket.sleep(2)
end

function Bluetooth.Connect(deviceMAC)
    os.execute("bluetoothctl trust " .. deviceMAC)
    os.execute("bluetoothctl connect " .. deviceMAC)
    socket.sleep(5)
end

function Bluetooth.Pair(deviceMAC)
    os.execute("bluetoothctl pair " .. deviceMAC)
    socket.sleep(5)
end

return Bluetooth