local love = require("love")
local socket = require("socket")

local Config = require("config")
local Bluetooth = require("bluetooth")

local input = require("input")

local SCREEN_MAIN = 1
local SCREEN_LOADING = 2
local SCREEN_GRID = 3

local currScreen = SCREEN_MAIN

local msgLog = ""

local isBluetoothOn = false

local isAvailableDevicesSelected = false

local idxAvailableDevices = 1
local availableDevices = {}

local idxConnectedDevice = 1
local connectedDevices = {}

function love.load()
    -- love.graphics.setFullscreen(true)
    -- ScanDevices(5)

    -- local devices = GetDevices()
    -- for _, device in ipairs(devices) do
    --     print("IP: " .. device.ip .. ", Name: " .. device.name)
    -- end
    -- Initialize joystick

    currScreen = SCREEN_MAIN

    local height = love.graphics.getHeight()
    local width = love.graphics.getWidth()
    input.load()
    isBluetoothOn = Bluetooth.IsPowerOn()

    if isBluetoothOn then
        LoadConnectedDevices()
    end
end

function love.draw()
    if isBluetoothOn then
        AvailableDevicesUI()
        ConnectedDevicesUI()
    else
        love.graphics.print("Press [R1] to Power On Bluetooth", 200, 200)
    end

    BottomButtonUI()

    -- Log MSG
    love.graphics.rectangle("line", 370, 430, 260, 40)
    love.graphics.print(msgLog, 380, 442)
end

function AvailableDevicesUI()
    -- UI
    local xPos = 10;
    local yPos = 10
    love.graphics.rectangle("line", xPos, yPos, 300, 400)
    love.graphics.print("Available Devices:", xPos + 10, yPos + 10)

    local iPos = 0
    local lineHeight = 15
    love.graphics.print("MAC", xPos + 10, yPos + 30)
    love.graphics.print("Name", xPos + 150, yPos + 30)

    for _, device in ipairs(availableDevices) do
        if isAvailableDevicesSelected and iPos + 1 == idxAvailableDevices then
            love.graphics.setColor(1.4,1.4,0.4)
        else
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(device.ip, xPos + 10, iPos * lineHeight + yPos + 50)
        love.graphics.print(device.name, xPos + 150, iPos * lineHeight + yPos + 50)
        iPos = iPos + 1
    end

    love.graphics.setColor(1,1,1)
end

function ConnectedDevicesUI()
    -- UI
    local xPos = 330;
    local yPos = 10
    love.graphics.rectangle("line", xPos, yPos, 300, 400)
    love.graphics.print("Connected Devices:", xPos + 10, yPos + 10)

    local iPos = 0
    local lineHeight = 15
    love.graphics.print("MAC", xPos + 10, yPos + 30)
    love.graphics.print("Name", xPos + 150, yPos + 30)
    for _, device in ipairs(connectedDevices) do
        if not isAvailableDevicesSelected and iPos + 1 == idxConnectedDevice then
            love.graphics.setColor(1.4,1.4,0.4)
        else
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(device.ip, xPos + 10, iPos * lineHeight + yPos + 50)
        love.graphics.print(device.name, xPos + 150, iPos * lineHeight + yPos + 50)
        iPos = iPos + 1
    end

    love.graphics.setColor(1,1,1)
end

local bottomEvent
function BottomButtonUI()
    -- UI
    if isBluetoothOn then
        love.graphics.print("[Y]: Scan", 10, 430)
        love.graphics.print("[A]: Connect", 100, 430)
        love.graphics.print("[B]: Disconnect", 100, 450)
        -- love.graphics.print("[X]: Remove", 100, 450)
        love.graphics.print("[L1]: PowerOff Bluetooth", 200, 430)
        love.graphics.print("[Select+Start]: Quit", 200, 450)
    else
        love.graphics.print("[R1]: PowerOn Bluetooth", 200, 430)
    end

    -- Event
    bottomEvent = function(key)
        if isBluetoothOn then
            if key == "a" then
                -- Connect
                ConnectDevice()
            elseif key == "b" then
                -- Disconnect-7
                DisconnectDevice()
            elseif key == "x" then
                -- Delete
            elseif key == "y" then
                -- Scan
                LoadAvailableDevices()
                LoadConnectedDevices()
            elseif key == "l1" then
                -- PowerOff
                TurnOffBluetooth()
            end
        else
            if key == "r1" then
                -- PowerOn
                TurnOnBluetooth()
            end
        end
    end
end

function ConnectDevice()
    if table.getn(availableDevices) < 1 then
        return
    end

    if isAvailableDevicesSelected then
        local MAC = availableDevices[idxAvailableDevices].ip
        Bluetooth.Connect(MAC)
        connectedDevices = Bluetooth.GetConnectedDevices()
        msgLog = "Connected: " .. MAC
    else
        msgLog = "TODO: Something..."
    end
end

function DisconnectDevice()
    if isAvailableDevicesSelected then
        return
    end

    if table.getn(connectedDevices) < 1 then
        return
    end

    local MAC = connectedDevices[idxConnectedDevice].ip
    Bluetooth.Disconnect(MAC)
    connectedDevices = Bluetooth.GetConnectedDevices()
    msgLog = "Disconnected: " .. MAC
    idxConnectedDevice = 0
end

function LoadAvailableDevices()
    Bluetooth.ScanDevices(5)
    availableDevices = Bluetooth.GetAvailableDevices()
    msgLog = "Scanning complete!!!"
end

function LoadConnectedDevices()
    connectedDevices = Bluetooth.GetConnectedDevices()
end

function TurnOnBluetooth()
    Bluetooth.PowerOn()
    isBluetoothOn = Bluetooth.IsPowerOn()
    if isBluetoothOn then
        msgLog = "Bluetooth: Started"
    else
        msgLog = "Bluetooth: Started Failed"
    end
end

function TurnOffBluetooth()
    Bluetooth.PowerOff()
    isBluetoothOn = Bluetooth.IsPowerOn()
    if isBluetoothOn == false then
        msgLog = "Bluetooth: Stopped"
    else
        msgLog = "Bluetooth: Stopped Failed"
    end
end

function OnKeyPress(key)
    bottomEvent(key)

    if key == "left" or key == "right" then
        isAvailableDevicesSelected = not isAvailableDevicesSelected
        idxAvailableDevices = 1
        idxConnectedDevice = 1
    elseif key == "up" then
        if isAvailableDevicesSelected then
            if idxAvailableDevices > 1 then
                idxAvailableDevices = idxAvailableDevices - 1
            else
                idxAvailableDevices = table.getn(availableDevices)
            end
        else
            if idxConnectedDevice > 1 then
                idxConnectedDevice = idxConnectedDevice - 1
            else
                idxConnectedDevice = table.getn(connectedDevices)
            end
        end
    elseif key == "down" then
        if isAvailableDevicesSelected then
            if idxAvailableDevices < table.getn(availableDevices) then
                idxAvailableDevices = idxAvailableDevices + 1
            else
                idxAvailableDevices = 1
            end
        else
            if idxConnectedDevice < table.getn(connectedDevices) then
                idxConnectedDevice = idxConnectedDevice + 1
            else
                idxConnectedDevice = 1
            end
        end
    end
end

function love.update(dt)
    input.update(dt)
    input.onClick(OnKeyPress)
end

function love.keypressed(key)
    OnKeyPress(key)
end