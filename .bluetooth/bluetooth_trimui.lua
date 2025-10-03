local love = require("love")
local socket = require("socket")

local Config = require("config")
local StringHelper = require("Helper/StringHelper")

local Bluetooth = {}

local availableDevices = {}
local connectedDevices = {}

Bluetooth.ConnectedType = {
    NOTHING = 0,
    CONNECTED = 1,
    PAIRED = 2
}

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

function Bluetooth.RetryTurnOnPower()
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("killall rtk_hciattach")
        os.execute("killall bluetoothd")
        socket.sleep(0.5)

        os.execute("rtk_hciattach -n -s 115200 ttyS1 xradio >/dev/null 2>&1 &")
        socket.sleep(3)

        os.execute("hciconfig hci0 up")
        socket.sleep(1)

        os.execute("/usr/libexec/bluetooth/bluetoothd -n -d > /mnt/mmc/MUOS/log/bluetoothd.log 2>&1 &")
        socket.sleep(2)
        
        Bluetooth.PowerOn()
    end
end

function Bluetooth.PowerOn()
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl power on")
    end
end

function Bluetooth.PowerOff()
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl power off")
    end
end

function Bluetooth.ScanDevices(timeout)
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl --timeout " .. timeout .." scan on");
    end
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
            if string.find(line, "^Device") then
                local lineData = line:gsub("Device ", "")
                local ip, name = lineData:match("([^%s]+)%s+(.*)")
                if StringHelper.IsMACAndNameValid(ip, name) then
                    local cDevices = Bluetooth.GetConnectedDevices()
                    local isExits = false
                    for _, obj in ipairs(cDevices) do
                        if obj.ip and string.find(obj.ip, ip, 1, true) then
                            isExits = true
                        end
                    end

                    if isExits == false then
                        table.insert(availableDevices,
                        {
                            ip = ip,
                            name = StringHelper.Trim(name)
                        })
                    end
                end
            end
        end
    end

    return availableDevices
end

function Bluetooth.GetConnectedDevices()
    connectedDevices = {}

    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl devices Connected > " .. Config.CONNECTED_DEVICES_PATH)
        os.execute("bluetoothctl devices Trusted > " .. Config.TRUSTED_DEVICES_PATH)
        socket.sleep(0.5)
    end

    local file = io.open(Config.CONNECTED_DEVICES_PATH, "r")
    if file then
        for line in file:lines() do
            local lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            if StringHelper.IsMACAndNameValid(ip, name) then
                table.insert(connectedDevices,
                {
                    ip = ip,
                    name = StringHelper.Trim(name),
                    type = Bluetooth.ConnectedType.PAIRED
                })

                for _,item in ipairs(connectedDevices) do
                   if item.ip == ip then
                        item.type = Bluetooth.ConnectedType.CONNECTED
                   end
                end
            end
        end
    end

    file = io.open(Config.TRUSTED_DEVICES_PATH, "r")
    if file then
        for line in file:lines() do
            local lineData = line:gsub("Device ", "")
            local ip, name = lineData:match("([^%s]+)%s+(.*)")
            if StringHelper.IsMACAndNameValid(ip, name) then
                local isExisted = false
                for _, item in ipairs(connectedDevices) do
                    if item.ip == ip then
                        isExisted = true
                    end
                end
                if not isExisted then
                    table.insert(connectedDevices,
                    {
                        ip = ip,
                        name = StringHelper.Trim(name),
                        type = Bluetooth.ConnectedType.PAIRED
                    })
                end
            end
        end
    end
    
    Bluetooth.GetBatteryPercent()
    
    return connectedDevices
end

function Bluetooth.Disconnect(deviceMAC)
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl disconnect " .. deviceMAC)
    end
end

function Bluetooth.Remove(deviceMAC)
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl remove " .. deviceMAC)
    end
end

function Bluetooth.Connect(deviceMAC, isExpectMethod)
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        if isExpectMethod then
            local command = string.format("expect %s %s > %s", Config.BLUETOOTH_EXPECT_PATH, deviceMAC, Config.BLUETOOTH_CONNECT_PATH)
            os.execute(command)
        else
            os.execute("bluetoothctl trust " .. deviceMAC .. " > " .. Config.BLUETOOTH_TRUST_PATH)
            os.execute("bluetoothctl pair " .. deviceMAC .. " > " .. Config.BLUETOOTH_PAIR_PATH)
            os.execute("bluetoothctl connect " .. deviceMAC .. " > " .. Config.BLUETOOTH_CONNECT_PATH)
        end
    end
end

function Bluetooth.Pair(deviceMAC)
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        os.execute("bluetoothctl pair " .. deviceMAC)
    end
end

function Bluetooth.GetBatteryPercent()
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
        for _,device in ipairs(connectedDevices) do
            if device.type == Bluetooth.ConnectedType.CONNECTED then
                os.execute("bluetoothctl info " .. device.ip .. " > " .. Config.BLUETOOTH_BATTERY_PATH)
                local file = io.open(Config.BLUETOOTH_BATTERY_PATH, "r")
                if file then
                    for line in file:lines() do
                        if string.find(line, "Battery") then
                            local battery = line:match("Battery Percentage: 0x%x+ %((%d+)%)")
                            if battery then
                                device.battery = battery .. "%"
                            end
                        end
                    end
                end
            end
        end
    end
end

return Bluetooth