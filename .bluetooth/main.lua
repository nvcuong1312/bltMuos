local love = require("love")

local Bluetooth = require("bluetooth")

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
        love.graphics.print("Press [Start] to Power On Bluetooth", 200, 200)
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
        love.graphics.print("[A]: Connect", 80, 430)
        love.graphics.print("[X]: Disconnect", 80, 450)
        love.graphics.print("[Select]: PowerOff Bluetooth", 180, 430)
        love.graphics.print("[Menu]: Quit", 180, 450)
    else
        love.graphics.print("[Start]: PowerOn Bluetooth", 180, 430)
    end

    -- Event
    bottomEventFunc = function(key)
        if isBluetoothOn then
            if key == "a" then
                -- Connect
                ConnectDevice()
            elseif key == "x" then
                -- Disconnect
                DisconnectDevice()
            elseif key == "b" then
                -- Delete
            elseif key == "y" then
                -- Scan
                Scan()

            elseif key == "select" then
                -- PowerOff
                TurnOffBluetooth()
            end
        else
            if key == "start" then
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
        idxConnectedDevice = 1
        idxAvailableDevices = 1
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

        elseif key == "guide" then
            love.event.quit()
    end
end

function love.update(dt)
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

function love.gamepadpressed(joystick, button)
    local key = ""
    if button == "dpleft" then
        key = "left"
    end
    if button == "dpright" then
        key = "right"
    end
    if button == "dpup" then
        key = "up"
    end
    if button == "dpdown" then
        key = "down"
    end
    if button == "a" then
        key = "a"
    end
    if button == "b " then
        key = "b"
    end
    if button == "x" then
        key = "x"
    end
    if button == "y" then
        key = "y"
    end
    if button == "back" then
        key = "select"
    end
    if button == "start" then
        key = "start"
    end
    if button == "leftshoulder" then
        key = "l1"
    end
    if button == "rightshoulder" then
        key = "r1"
    end
    if button == "guide" then
        key = "guide"
    end

    OnKeyPress(key)
 end

function round_rectangle(x, y, width, height, radius)
	--RECTANGLES
	love.graphics.rectangle("fill", x + radius, y + radius, width - (radius * 2), height - radius * 2)
	love.graphics.rectangle("fill", x + radius, y, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x + radius, y + height - radius, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x, y + radius, radius, height - (radius * 2))
	love.graphics.rectangle("fill", x + (width - radius), y + radius, radius, height - (radius * 2))
	
	--ARCS
	love.graphics.arc("fill", x + radius, y + radius, radius, math.rad(-180), math.rad(-90))
	love.graphics.arc("fill", x + width - radius , y + radius, radius, math.rad(-90), math.rad(0))
	love.graphics.arc("fill", x + radius, y + height - radius, radius, math.rad(-180), math.rad(-270))
	love.graphics.arc("fill", x + width - radius , y + height - radius, radius, math.rad(0), math.rad(90))
end