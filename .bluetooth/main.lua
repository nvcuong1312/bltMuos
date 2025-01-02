local love = require("love")

local Bluetooth = require("bluetooth")
local input = require("input")

local msgLog = ""

local isBluetoothOn = false

local isAvailableDevicesSelected = false

local idxAvailableDevices = 1
local availableDevices = {}

local idxConnectedDevice = 1
local connectedDevices = {}

local bottomEventFunc

local runScanFunc
local timeRunScanFunc = 0

local runConnectFunc
local timeRunConnectFunc = 0

local runDisConnectFunc
local timeRunDisConnectFunc = 0

function love.load()
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
    bottomEventFunc = function(key)
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
                Scan()

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

function Scan()
    msgLog = "Scanning..."
    timeRunScanFunc = love.timer.getTime()
    runScanFunc = function ()
        LoadAvailableDevices()
        LoadConnectedDevices()
        isAvailableDevicesSelected = table.getn(availableDevices) > 0
    end
end

function ConnectDevice()
    if table.getn(availableDevices) < 1 then
        return
    end

    msgLog = "Connecting..."
    timeRunConnectFunc = love.timer.getTime()
    runConnectFunc = function ()
        if isAvailableDevicesSelected then
            local MAC = availableDevices[idxAvailableDevices].ip
            Bluetooth.Connect(MAC)
            connectedDevices = Bluetooth.GetConnectedDevices()
    
            local tempDevices = availableDevices
            availableDevices = {}
            
            for _, device in ipairs(tempDevices) do
                local isExits = false
                for _, cDevice in ipairs(connectedDevices) do
                    if device.ip == cDevice.ip then
                        isExits = true
                    end
                end

                if not isExits then
                    table.insert(availableDevices, device)
                end
            end
    
            isAvailableDevicesSelected = table.getn(availableDevices) > 0
    
            msgLog = "Connected: " .. MAC
        else
            msgLog = "TODO: Something..."
        end 
    end
end

function DisconnectDevice()
    if isAvailableDevicesSelected then
        return
    end

    if table.getn(connectedDevices) < 1 then
        return
    end

    msgLog = "Disconnecting..."
    timeRunDisConnectFunc = love.timer.getTime()
    runDisConnectFunc = function ()
        local MAC = connectedDevices[idxConnectedDevice].ip
        Bluetooth.Disconnect(MAC)
        connectedDevices = Bluetooth.GetConnectedDevices()
        msgLog = "Disconnected: " .. MAC
        idxConnectedDevice = 0
        idxAvailableDevices = 0
        isAvailableDevicesSelected = not table.getn(connectedDevices) == 0
    end
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
    if bottomEventFunc then
        bottomEventFunc(key)
    end

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

    if runScanFunc then
        local currentTime = love.timer.getTime()
        if currentTime - timeRunScanFunc > 0.2 then
            runScanFunc()
            runScanFunc = nil
        end
    end

    if runConnectFunc then
        local currentTime = love.timer.getTime()
        if currentTime - timeRunConnectFunc > 0.2 then
            runConnectFunc()
            runConnectFunc = nil
        end
    end

    if runDisConnectFunc then
        local currentTime = love.timer.getTime()
        if currentTime - timeRunDisConnectFunc > 0.2 then
            runDisConnectFunc()
            runDisConnectFunc = nil
        end
    end
end

function love.keypressed(key)
    OnKeyPress(key)
end