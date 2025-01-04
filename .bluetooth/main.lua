local love = require("love")

local Bluetooth = require("bluetooth")
local Config = require("config")

local msgLog = ""

local isBluetoothOn = false

local isAvailableDevicesSelected = false

local idxAvailableDevices = 1
local availableDevices = {}

local idxConnectedDevice = 1
local connectedDevices = {}
local titleConnectedDevice = ""
local itemSelectedType = Bluetooth.ConnectedType.NOTHING

local bottomEventFunc

local runScanFunc
local timeRunScanFunc = 0

local runConnectFunc
local timeRunConnectFunc = 0

local runDisConnectFunc
local timeRunDisConnectFunc = 0

local ic_bluetooth

function love.load()
    isBluetoothOn = Bluetooth.IsPowerOn()
    if isBluetoothOn then
        LoadConnectedDevices()

        if table.getn(connectedDevices) > 0 then
            isAvailableDevicesSelected = false
            itemSelectedType = connectedDevices[1].type
        end
    end

    ic_bluetooth = love.graphics.newImage("Assets/Icon/ic_bluetooth.png")
end

function love.draw()
    love.graphics.setBackgroundColor(0.043, 0.161, 0.094)

    HeaderUI()

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

function HeaderUI()
    local xPos = 0
    local yPos = 0

    love.graphics.setColor(0.31, 0.31, 0.118)
    love.graphics.rectangle("fill", xPos, yPos, 640, 30)

    love.graphics.setColor(0.98, 0.98, 0.749)
    local font = love.graphics.newFont(18)
    love.graphics.setFont(font)
    love.graphics.draw(ic_bluetooth, 640 - 25, yPos + 4)
    love.graphics.print("Bluetooth Settings", xPos + 230, yPos + 5)

    Now = os.date('*t')
    local formatted_time = string.format("%d:%02d", tonumber(Now.hour), tonumber(Now.min))
    love.graphics.setColor(0.98, 0.98, 0.749, 0.7)
    love.graphics.print(formatted_time, xPos + 10, yPos + 5)

    font = love.graphics.newFont(12)
    love.graphics.setFont(font)
end

function AvailableDevicesUI()
    -- UI
    local xPos = 0
    local yPos = 30
    local width = 320
    local height = 370

    love.graphics.setColor(0.102, 0.141, 0.078)
    love.graphics.rectangle("fill", xPos, yPos, width, height)

    -- Header
    if isAvailableDevicesSelected then love.graphics.setColor(1,1,1, 0.4)
    else love.graphics.setColor(0.247, 0.278, 0.224)
    end
    
    love.graphics.rectangle("fill", xPos, yPos, width, 30)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Available", xPos + 120, yPos + 7)

    local iPos = 0
    local lineHeight = 15
    love.graphics.setColor(0.169, 0.259, 0.11)
    love.graphics.rectangle("fill", xPos, yPos + 30, width, 30)

    love.graphics.setColor(0.169, 0.259, 0.212)
    love.graphics.rectangle("fill", xPos, yPos + 30, width / 2 - 20, 30)
    
    love.graphics.setColor(0.169, 0.259, 0.11)
    love.graphics.rectangle("fill", xPos + width / 2, yPos + 30, width / 2 + 20, 30)
    
    love.graphics.setColor(1,1,1)
    love.graphics.print("MAC", xPos + 10, yPos + 30 + 7)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Name", xPos + 150, yPos + 30  + 7)

    for idx, device in ipairs(availableDevices) do
        if idx > Config.GRID_PAGE_ITEM then
            goto continue
        end

        if isAvailableDevicesSelected and iPos + 1 == idxAvailableDevices then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 65, width, 15)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(device.ip, xPos + 10, iPos * lineHeight + yPos + 65)
        love.graphics.print(device.name, xPos + 150, iPos * lineHeight + yPos + 65)
        iPos = iPos + 1
        ::continue::
    end

    love.graphics.setColor(1,1,1)
end

function ConnectedDevicesUI()
    -- UI
    local xPos = 320
    local yPos = 30
    local width = 320
    local height = 370

    love.graphics.setColor(0.114, 0.149, 0.094)
    love.graphics.rectangle("fill", xPos, yPos, width, height, 5, 5, 10)

    -- Header
    if not isAvailableDevicesSelected then love.graphics.setColor(1,1,1, 0.4)
    else love.graphics.setColor(0.247, 0.278, 0.224)
    end

    love.graphics.rectangle("fill", xPos, yPos, width, 30)

    love.graphics.setColor(1,1,1)
    if isAvailableDevicesSelected then
        titleConnectedDevice = "Connected/Paired"
    else
        if itemSelectedType == Bluetooth.ConnectedType.CONNECTED then
            titleConnectedDevice = "Connected"
        else if itemSelectedType == Bluetooth.ConnectedType.PAIRED then
            titleConnectedDevice = "Paired"
        else
            titleConnectedDevice = "Connected/Paired"
            end
        end
    end

    love.graphics.print(titleConnectedDevice, xPos + 120, yPos + 7)

    local iPos = 0
    local lineHeight = 15
    love.graphics.setColor(0.169, 0.259, 0.11)
    love.graphics.rectangle("fill", xPos, yPos + 30, width, 30)

    love.graphics.setColor(0.169, 0.259, 0.212)
    love.graphics.rectangle("fill", xPos, yPos + 30, width / 2 - 20, 30)

    love.graphics.setColor(0.169, 0.259, 0.11)
    love.graphics.rectangle("fill", xPos + width / 2, yPos + 30, width / 2 + 20, 30)

    love.graphics.setColor(1,1,1)
    love.graphics.print("MAC", xPos + 10, yPos + 30 + 7)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Name", xPos + 150, yPos + 30  + 7)


    for idx, device in ipairs(connectedDevices) do
        if idx > Config.GRID_PAGE_ITEM then
            goto continue
        end

        if not isAvailableDevicesSelected and iPos + 1 == idxConnectedDevice then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 65, width, 15)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(device.ip, xPos + 10, iPos * lineHeight + yPos + 65)
        love.graphics.print(device.name, xPos + 150, iPos * lineHeight + yPos + 65)
        iPos = iPos + 1
        ::continue::
    end

    love.graphics.setColor(1,1,1)
end

function BottomButtonUI()
    local xPos = 10
    local yPos = 435

    -- UI
    love.graphics.setColor(1,1,1)
    love.graphics.print("[Start]: PowerOn Bluetooth",  xPos + 180, yPos + 20)
    love.graphics.print("[Select]: PowerOff Bluetooth", xPos + 180, yPos)
    love.graphics.print("[Y]: Scan", xPos + 100, yPos)
    love.graphics.print("[A]: Connect", xPos, yPos)
    love.graphics.print("[X]: Disconnect", xPos, yPos + 20)
    love.graphics.print("[Menu]: Quit",  xPos + 100, yPos + 20)

    -- Event
    bottomEventFunc = function(key)
        if isBluetoothOn then
            if key == "a" then
                -- Connect
                ConnectDevice()
            elseif key == "x" then
                -- Disconnect
                DisconnectDevice()
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
    if (    isAvailableDevicesSelected and table.getn(availableDevices) < 1)
        or (not isAvailableDevicesSelected
            and itemSelectedType ~= Bluetooth.ConnectedType.PAIRED
            and table.getn(connectedDevices) > 0) then
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
        else
            local MAC = connectedDevices[idxConnectedDevice].ip
            Bluetooth.Connect(MAC)
            connectedDevices = Bluetooth.GetConnectedDevices()
        end

        isAvailableDevicesSelected = table.getn(availableDevices) > 0
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
        SetIdxConnectedDevice(1)
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

function SetIdxConnectedDevice(idx)
    idxConnectedDevice = idx

    if table.getn(connectedDevices) < idx then
        itemSelectedType = Bluetooth.ConnectedType.NOTHING
        return
    end

    itemSelectedType = connectedDevices[idx].type
end

function OnKeyPress(key)
    if bottomEventFunc then
        bottomEventFunc(key)
    end

    if key == "left" or key == "right" then
        isAvailableDevicesSelected = not isAvailableDevicesSelected
        idxAvailableDevices = 1
        SetIdxConnectedDevice(1)
    elseif key == "up" then
        if isAvailableDevicesSelected then
            if idxAvailableDevices > 1 then
                idxAvailableDevices = idxAvailableDevices - 1
            else
                idxAvailableDevices = table.getn(availableDevices)
            end
        else
            if idxConnectedDevice > 1 then
                SetIdxConnectedDevice(idxConnectedDevice - 1)
            else
                SetIdxConnectedDevice(table.getn(connectedDevices))
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
                SetIdxConnectedDevice(idxConnectedDevice + 1)
            else
                SetIdxConnectedDevice(1)
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