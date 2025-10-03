local love = require("love")

local Bluetooth = require("bluetooth")
local Config = require("config")
local Audio = require("Audio")
local StringHelper = require("Helper/StringHelper")

local msgLog = ""

local isBluetoothOn = false

local isAvailableDevicesSelected = false

local currAvailableDevicePage = 1
local idxAvailableDevices = 1
local availableDevices = {}

local currConnectedDevicePage = 1
local idxConnectedDevice = 1
local connectedDevices = {}
local titleConnectedDevice = ""
local itemSelectedType = Bluetooth.ConnectedType.NOTHING
local txtDisconnectRemoveBtn = ""

local runScanFunc
local timeRunScanFunc = 0

local runConnectFunc
local timeRunConnectFunc = 0

local runDisConnectFunc
local timeRunDisConnectFunc = 0

local ic_bluetooth
local ic_bluetooth_big
local ic_plus, ic_minus
local ic_select, ic_start
local ic_A, ic_B, ic_X, ic_Y, ic_ZL, ic_L1, ic_R1
local ic_off, ic_on

local isTimeoutShow = false
local idxTimeout = 1

local isAudioShow = false
local idxAudio = 1
local audioList = {}

local isSwitchAudioShow = false

local isQuitConfirm = false

local isConnectMethodSelection = false

local fontBig
local fontSmall
local fontBold
local fontBoldSmall
local fontBoldSmallest

local _screenW, _screenH = love.window.getDesktopDimensions()

function HeaderUI()
    local xPos = 0
    local yPos = 0

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos, yPos, 640, 48)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fontBold)
    love.graphics.draw(ic_bluetooth, 8, yPos + 8)
    love.graphics.print("Bluetooth", xPos + 37, yPos + 8)

    Now = os.date('*t')
    local formatted_time = string.format("%02d:%02d", tonumber(Now.hour), tonumber(Now.min))
    love.graphics.print(formatted_time, 640 - 60, yPos + 8)

    love.graphics.setFont(fontSmall)
end

function BottomButtonUI()
    local xPos = 8
    local yPos = 480 - 90 

    love.graphics.setColor(0.078, 0.106, 0.173)
    love.graphics.rectangle("fill", xPos, yPos, 623, 40, 4,4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(msgLog, xPos + 5, yPos + 8)

    xPos = 0
    yPos = 480 - 45
    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos, yPos, 680, 45)
    
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(ic_select, xPos + 5, yPos + 15)
    -- love.graphics.print("Off", xPos + 5 + 40, yPos + 13)
    -- if isBluetoothOn then
    --     love.graphics.draw(ic_on, xPos + 5 + 30 + 40, yPos + 7)
    -- else
    --     love.graphics.draw(ic_off, xPos + 5 + 30 + 40, yPos + 7)
    -- end

    -- love.graphics.draw(ic_start, xPos + 5 + 40 + 25 + 80, yPos + 15)
    -- love.graphics.print("On",  xPos + 5 + 40 + 25 + 80 + 40, yPos + 13)

    love.graphics.draw(ic_B, 640 - 66, yPos + 10)
    love.graphics.print("Quit", 640 - 40, yPos + 13)
end

-- Scan
function ShowScanTimeoutUI()
    isTimeoutShow = true
end

function HideScanTimeoutUI()
    isTimeoutShow = false
end

function ScanTimeoutSelectionUI()
    if not isTimeoutShow then
        return
    end

    local xPos = 180
    local yPos = 100

    love.graphics.setColor(0,0,0, 0.7)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos,yPos, 300, 200)

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos,yPos, 300, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Choose timeout", xPos + 80, yPos + 2)

    local iPos = 1
    local lineHeight = 30
    for _,timeout in ipairs(Config.TIMEOUT_LIST) do
        love.graphics.setColor(1,1,1)
        if iPos == idxTimeout then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 10, 300, lineHeight)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(timeout .. " seconds", xPos + 10, iPos * lineHeight + yPos + 10 + 3)
        iPos = iPos + 1
    end

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos,yPos + 200, 300, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + 207)
    love.graphics.print("Continue", xPos + 5 + 30, yPos + 210)

    love.graphics.draw(ic_B, xPos + 5 + 30 + 80, yPos + 207)
    love.graphics.print("Close", xPos + 5 + 30 + 80 + 30, yPos + 210)
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

-- Audio
function ShowAudioSelection()
    audioList = Audio.Sinks()
    local defSinkNumber = Audio.DefaultSinkNumber()
    for idx,item in ipairs(audioList) do
        if item.id == defSinkNumber then
            idxAudio = idx
        end
    end

    isAudioShow = true
end

function HideAudioSeleciton()
    isAudioShow = false
end

function AudioSelectionUI()
    if not isAudioShow then
        return
    end

    local xPos = 140
    local yPos = 80

    love.graphics.setColor(0,0,0, 0.7)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos,yPos, 400, 300)

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Select a sound output", xPos + 120, yPos + 2)

    local iPos = 1
    local lineHeight = 30
    for _,audio in ipairs(audioList) do
        love.graphics.setColor(1,1,1)
        if iPos == idxAudio then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 10, 400, lineHeight)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print("[" .. audio.id .. "] " .. audio.name, xPos + 10, iPos * lineHeight + yPos + 10)
        iPos = iPos + 1
    end

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos,yPos + 300, 400, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + 307)
    love.graphics.print("Select", xPos + 5 + 30, yPos + 310)

    love.graphics.draw(ic_B, xPos + 5 + 30 + 80, yPos + 307)
    love.graphics.print("Close", xPos + 5 + 30 + 80 + 30, yPos + 310)
end

function SelectAudio()
    if table.getn(audioList) < idxAudio then
        return
    end

    Audio.Select(audioList[idxAudio].id)

    msgLog = "Audio: " .. audioList[idxAudio].id .. " " .. audioList[idxAudio].name
end

function ConfirmAutoSwitchAudioUI()
    if not isSwitchAudioShow then
        return
    end

    local xPos = 140
    local yPos = 100

    love.graphics.setColor(0,0,0, 0.7)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos,yPos, 400, 100)

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Confirm", xPos + 160, yPos + 2)

    love.graphics.print("Do you want to change the audio output?", xPos + 10, yPos + 50)

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos,yPos + 100, 400, 40)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + 107)
    love.graphics.print("Yes", xPos + 5 + 30, yPos + 110)

    love.graphics.draw(ic_B, xPos + 5 + 30 + 50, yPos + 107)
    love.graphics.print("No", xPos + 5 + 30 + 50 + 30, yPos + 110)
end

-- Bluetooth
function TurnOnBluetooth()
    Bluetooth.PowerOn()
    isBluetoothOn = Bluetooth.IsPowerOn()
    if isBluetoothOn then
        msgLog = "Bluetooth: Started"
    else
        msgLog = "Retry turning on Bluetooth"
        Bluetooth.RetryTurnOnPower()
        isBluetoothOn = Bluetooth.IsPowerOn()
        if isBluetoothOn then
            msgLog = "Bluetooth: Started"
        else
            msgLog = "Bluetooth: Started Failed"
        end
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

function ConnectDevice(isExpectMethod)
    if (    isAvailableDevicesSelected and table.getn(availableDevices) < 1)
        or (not isAvailableDevicesSelected
            and itemSelectedType ~= Bluetooth.ConnectedType.PAIRED
            and table.getn(connectedDevices) < 1) then
        return
    end

    msgLog = "Connecting..."
    timeRunConnectFunc = love.timer.getTime()
    runConnectFunc = function ()
        local MAC = ""
        local name = ""
        if isAvailableDevicesSelected then
            local pos = (currAvailableDevicePage - 1) * Config.GRID_PAGE_ITEM + idxAvailableDevices
            MAC = availableDevices[pos].ip
            name = availableDevices[pos].name
            Bluetooth.Connect(MAC, isExpectMethod)
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
            local pos = (currConnectedDevicePage - 1) * Config.GRID_PAGE_ITEM + idxConnectedDevice
            MAC = connectedDevices[pos].ip
            name = connectedDevices[pos].name
            Bluetooth.Connect(MAC)
            connectedDevices = Bluetooth.GetConnectedDevices()
        end

        local isExists = false
        for _,device in ipairs(connectedDevices) do
            if device.ip == MAC and device.type == Bluetooth.ConnectedType.CONNECTED then
                isExists = true
            end
        end

        if not isExists then
            msgLog = "Failed! Send to me: /data/connect.txt"
        else
            msgLog = "Connected: " .. MAC
            audioList = Audio.Sinks()
            for idx,item in ipairs(audioList) do
                if StringHelper.Trim(item.name) == StringHelper.Trim(name) then
                    idxAudio = idx
                    isSwitchAudioShow = true
                end
            end
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
        local pos = (currConnectedDevicePage - 1) * Config.GRID_PAGE_ITEM + idxConnectedDevice
        local MAC = connectedDevices[pos].ip
        local dType = connectedDevices[pos].type

        if dType == Bluetooth.ConnectedType.CONNECTED then
            Bluetooth.Disconnect(MAC)
            msgLog = "Disconnected: " .. MAC
        else
            Bluetooth.Remove(MAC)
            msgLog = "Removed: " .. MAC
        end

        connectedDevices = Bluetooth.GetConnectedDevices()
        SetIdxConnectedDevice(1)
        idxAvailableDevices = 1
        isAvailableDevicesSelected = not table.getn(connectedDevices) == 0
    end
end

-- Available Devices
function AvailableDevicesUI()
    -- UI
    local xPos = 8
    local yPos = 48 + 8
    local width = 308
    local height = 319

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos, yPos, width, height, 8,8)

    -- Header
    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos, yPos, width, 40, 8, 8)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Available", xPos + 120, yPos + 7)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos, yPos + 35, width, 240)

    local lineHeight = 35
    local total = table.getn(availableDevices)
    local idxStart = currAvailableDevicePage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = currAvailableDevicePage * Config.GRID_PAGE_ITEM

    local iPos = 0
    for idx = idxStart, idxEnd do
        if idx > total then break end

        if isAvailableDevicesSelected and iPos + 1 == idxAvailableDevices then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos, iPos * lineHeight + yPos + 40, width, 35, 4,4)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fontBoldSmall)
        love.graphics.print(availableDevices[idx].name, xPos + 10, iPos * lineHeight + yPos + 40 + 7)

        love.graphics.setColor(1,1,1, 0.5)
        love.graphics.setFont(fontBoldSmallest)
        love.graphics.print(availableDevices[idx].ip, xPos + 210, iPos * lineHeight + yPos + 40 + 15)

        iPos = iPos + 1
    end

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos, yPos + height - 30, width, 40, 8,8)
    love.graphics.rectangle("fill", xPos, yPos + height - 30, width, 20)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + height - 22)
    love.graphics.print("Connect", xPos + 33, yPos + height - 20)

    love.graphics.draw(ic_Y, xPos + 100, yPos + height - 22)
    love.graphics.print("Scan", xPos + 100 + 30, yPos + height - 20)
    
    love.graphics.setColor(1,1,1)
end

function LoadAvailableDevices()
    local timeout = Config.TIMEOUT_LIST[idxTimeout]
    Bluetooth.ScanDevices(timeout)
    availableDevices = Bluetooth.GetAvailableDevices()
    msgLog = "Scanning complete!!!"
end

function SetIdxAvailableDevice(idx)
    idxAvailableDevices = idx
end

function ChangeAvailableDevicePage(page)
    currAvailableDevicePage = page
end

-- Connected Devices
function ConnectedDevicesUI()
    -- UI
    local xPos = 320 + 4
    local yPos = 48 + 8
    local width = 308
    local height = 319

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos, yPos, width, height, 8,8)

    -- Header
    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos, yPos, width, 40, 8, 8)

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

    local lineHeight = 35
    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos, yPos + 35, width, 240)

    local total = table.getn(connectedDevices)
    local idxStart = currConnectedDevicePage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = currConnectedDevicePage * Config.GRID_PAGE_ITEM

    local iPos = 0
    for idx = idxStart, idxEnd do
        if idx > total then break end

        if not isAvailableDevicesSelected and iPos + 1 == idxConnectedDevice then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos, iPos * lineHeight + yPos + 40, width, 35, 4,4)
            love.graphics.setColor(1,1,1)
        end

        local deviceName = connectedDevices[idx].name
        if connectedDevices[idx].battery then
            deviceName = "[" .. connectedDevices[idx].battery .. "] " .. deviceName
        end

        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fontBoldSmall)
        love.graphics.print(deviceName, xPos + 10, iPos * lineHeight + yPos + 40 + 7)

        love.graphics.setColor(1,1,1, 0.5)
        love.graphics.setFont(fontBoldSmallest)
        love.graphics.print(connectedDevices[idx].ip, xPos + 210, iPos * lineHeight + yPos + 40 + 15)

        iPos = iPos + 1
    end

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos, yPos + height - 30, width, 40, 8,8)
    love.graphics.rectangle("fill", xPos, yPos + height - 30, width, 20)

    love.graphics.setColor(1,1,1)
    if txtDisconnectRemoveBtn == "" then txtDisconnectRemoveBtn = "Disconnect" end
    love.graphics.draw(ic_X, xPos + 5, yPos + height - 22)
    love.graphics.print(txtDisconnectRemoveBtn, xPos + 33, yPos + height - 20)

    love.graphics.draw(ic_L1, xPos + 130, yPos + height - 22)
    love.graphics.print("Audio", xPos + 130 + 30, yPos + height - 20)
    
end

function LoadConnectedDevices()
    connectedDevices = Bluetooth.GetConnectedDevices()
    currConnectedDevicePage = 1
end

function SetIdxConnectedDevice(idx)
    idxConnectedDevice = idx

    local iPos = (currConnectedDevicePage - 1) * Config.GRID_PAGE_ITEM + idx
    if table.getn(connectedDevices) < iPos then
        itemSelectedType = Bluetooth.ConnectedType.NOTHING
        txtDisconnectRemoveBtn = "Disconnect"
        return
    end

    itemSelectedType = connectedDevices[iPos].type
    if itemSelectedType == Bluetooth.ConnectedType.CONNECTED then txtDisconnectRemoveBtn = "Disconnect"
    else txtDisconnectRemoveBtn = "Remove"
    end
end

function ChangeConnectedDevicePage(page)
    currConnectedDevicePage = page
end

-- Quit Confirm
function ShowQuitConfirmUI()
    if not isQuitConfirm then return end

    local xPos = 140
    local yPos = 100
    
    love.graphics.setColor(0,0,0, 0.7)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos,yPos, 400, 100)

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Confirm", xPos + 160, yPos + 2)

    love.graphics.print("Are you sure you want to exit?", xPos + 10, yPos + 50)

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos,yPos + 100, 400, 40)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + 107)
    love.graphics.print("Yes", xPos + 5 + 30, yPos + 110)

    love.graphics.draw(ic_B, xPos + 5 + 30 + 50, yPos + 107)
    love.graphics.print("No", xPos + 5 + 30 + 50 + 30, yPos + 110)
end

-- Connect method
function ConnectMethodSelectionUI()
    if not isConnectMethodSelection then return end

    local xPos = 140
    local yPos = 100
    
    love.graphics.setColor(0,0,0, 0.7)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.094, 0.094, 0.094)
    love.graphics.rectangle("fill", xPos,yPos, 400, 100)

    love.graphics.setColor(0.141, 0.141, 0.141)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Method", xPos + 160, yPos + 2)

    love.graphics.print("Choose a connection method", xPos + 10, yPos + 50)

    love.graphics.setFont(fontBoldSmall)
    love.graphics.setColor(0.125, 0.125, 0.125)
    love.graphics.rectangle("fill", xPos,yPos + 100, 400, 40)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(ic_A, xPos + 5, yPos + 107)
    love.graphics.print("Expect", xPos + 5 + 30, yPos + 110)

    love.graphics.draw(ic_Y, xPos + 105, yPos + 107)
    love.graphics.print("None Expect", xPos + 135, yPos + 110)

    love.graphics.draw(ic_B, xPos + 235, yPos + 107)
    love.graphics.print("Close", xPos + 265, yPos + 110)
end

-- Love

function love.load()
    fontBig = love.graphics.newFont(Config.FONT_PATH, 17)
    fontSmall = love.graphics.newFont(Config.FONT_PATH, 12)
    fontBold = love.graphics.newFont(Config.FONT_BOLD_PATH, 20)
    fontBoldSmall = love.graphics.newFont(Config.FONT_BOLD_PATH, 14)
    fontBoldSmallest = love.graphics.newFont(Config.FONT_BOLD_PATH, 10)

    isBluetoothOn = Bluetooth.IsPowerOn()
    if isBluetoothOn then
        LoadConnectedDevices()

        if table.getn(connectedDevices) > 0 then
            isAvailableDevicesSelected = false
            itemSelectedType = connectedDevices[1].type

            if itemSelectedType == Bluetooth.ConnectedType.CONNECTED then txtDisconnectRemoveBtn = "Disconnect"
            else txtDisconnectRemoveBtn = "Remove"
            end
        end
    end

    ic_bluetooth = love.graphics.newImage("Assets/Icon/ic_bluetooth.png")
    ic_bluetooth_big = love.graphics.newImage("Assets/Icon/ic_bluetooth_big.png")
    ic_plus = love.graphics.newImage("Assets/Icon/Plus.png")
    ic_minus = love.graphics.newImage("Assets/Icon/Minus.png")
    ic_select = love.graphics.newImage("Assets/Icon/Select.png")
    ic_start = love.graphics.newImage("Assets/Icon/Start.png")
    ic_A = love.graphics.newImage("Assets/Icon/Xbox A.png")
    ic_B = love.graphics.newImage("Assets/Icon/Xbox B.png")
    ic_X = love.graphics.newImage("Assets/Icon/Xbox X.png")
    ic_Y = love.graphics.newImage("Assets/Icon/Xbox Y.png")
    ic_ZL = love.graphics.newImage("Assets/Icon/Zl Button.png")
    ic_L1 = love.graphics.newImage("Assets/Icon/L1.png")
    ic_R1 = love.graphics.newImage("Assets/Icon/R1.png")
    


    ic_off = love.graphics.newImage("Assets/Icon/off.png")
    ic_on = love.graphics.newImage("Assets/Icon/on.png")
end

function love.draw()

    local scaleX = _screenW / 640
    local scaleY = _screenH / 480
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)

    love.graphics.setBackgroundColor(0.071, 0.071, 0.071)

    HeaderUI()

    love.graphics.setFont(fontBoldSmall)

    if isBluetoothOn then
        AvailableDevicesUI()
        ConnectedDevicesUI()
    else
        love.graphics.draw(ic_bluetooth_big, 640/2 - 60, 480/2 - 100)
        love.graphics.print("Press", 220, 253)
        love.graphics.draw(ic_R1, 220 + 40, 255)
        love.graphics.print("to turn on Bluetooth", 260 + 27, 253)
    end

    BottomButtonUI()

    ScanTimeoutSelectionUI()
    AudioSelectionUI()
    ConfirmAutoSwitchAudioUI()
    ShowQuitConfirmUI()
    ConnectMethodSelectionUI()

    love.graphics.pop()
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
    if key == "l" then
        key = "l1"
    end

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
    if button == "rightshoulder" then
        key = "a"
    end
    if button == "leftshoulder" then
        key = "b"
    end
    if button == "start" then
        key = "x"
    end
    if button == "back" then
        key = "y"
    end
    -- if button == "back" then
        -- key = "select"
    -- end
    -- if button == "start" then
        -- key = "start"
    -- end
    if button == "guide" then
        key = "l1"
    end
    if button == "leftstick" then
        key = "start"
    end
    -- if button == "guide" then
        -- key = "guide"
    -- end

    OnKeyPress(key)
 end

 function OnKeyPress(key)
    if isQuitConfirm then
        if key == "a" then
            love.event.quit()
           return 
        end

        if key == "b" then
            isQuitConfirm = false
            return
        end

        return
    end

    if isSwitchAudioShow then
        if key == "a" then
            SelectAudio()
            isSwitchAudioShow = false
            return
        end

        if key == "b" then
            isSwitchAudioShow = false
            return
        end

        return
    end

    if isTimeoutShow then
        if key == "a" then
            Scan()
            HideScanTimeoutUI()
            return
        end

        if key == "b" then
            HideScanTimeoutUI()
            return
        end

        if key == "up" then
            GridKeyUp(Config.TIMEOUT_LIST, 1, idxTimeout, 6, function (idx) idxTimeout = idx end)
            return
        end

        if key == "down" then
            GridKeyDown(Config.TIMEOUT_LIST, 1, idxTimeout, 6, function (idx) idxTimeout = idx end)
            return
        end

        return
    end

    if isAudioShow then
        if key == "a" then
            SelectAudio()
            HideAudioSeleciton()
            return
        end

        if key == "b" then
            HideAudioSeleciton()
            return
        end

        if key == "up" then
            GridKeyUp(audioList, 1, idxAudio, 5, function (idx) idxAudio = idx end)
            return
        end

        if key == "down" then
            GridKeyDown(audioList, 1, idxAudio, 10, function (idx) idxAudio = idx end)
            return
        end

        return
    end

    if isBluetoothOn then
        if isConnectMethodSelection then
            if key == "a" then
                isConnectMethodSelection = false
                ConnectDevice(true)
                return
            end

            if key == "y" then
                isConnectMethodSelection = false
                ConnectDevice(false)
                return
            end

            if key == "b" then
                isConnectMethodSelection = false
                return
            end

            return
        end
        if isAvailableDevicesSelected then
            if key == "a" then
                isConnectMethodSelection = true
                return
            end

            if key == "up" then
                GridKeyUp(availableDevices, currAvailableDevicePage, idxAvailableDevices, Config.GRID_PAGE_ITEM, SetIdxAvailableDevice, ChangeAvailableDevicePage)
                return
            end

            if key == "down" then
                GridKeyDown(availableDevices, currAvailableDevicePage, idxAvailableDevices, Config.GRID_PAGE_ITEM, SetIdxAvailableDevice, ChangeAvailableDevicePage)
                return
            end
        end

        if not isAvailableDevicesSelected then
            if key == "a" then
                isConnectMethodSelection = true
                return
            end

            if key == "x" then
                DisconnectDevice()
                return
            end

            if key == "up" then
                GridKeyUp(connectedDevices, currConnectedDevicePage, idxConnectedDevice, Config.GRID_PAGE_ITEM, SetIdxConnectedDevice, ChangeConnectedDevicePage)
                return
            end

            if key == "down" then
                GridKeyDown(connectedDevices, currConnectedDevicePage, idxConnectedDevice, Config.GRID_PAGE_ITEM, SetIdxConnectedDevice, ChangeConnectedDevicePage)
                return
            end
        end

        if key == "select" then
            TurnOffBluetooth()
            return
        else if key == "y" then
            ShowScanTimeoutUI()
            return
        end
    end
    else
        if key == "start" then
            TurnOnBluetooth()
            return
        end
    end

    if key == "left" or key == "right" then
        isAvailableDevicesSelected = not isAvailableDevicesSelected
        idxAvailableDevices = 1
        SetIdxConnectedDevice(1)
        return
    end

    if key == "l1" then
        if not isSwitchAudioShow and not isTimeoutShow then
            ShowAudioSelection()
            return
        end
    elseif key == "b" then
        if not isAudioShow and not isSwitchAudioShow and not isTimeoutShow then
            isQuitConfirm = true
            return
        end
    end
end

-- GridKey Up/Down

function GridKeyUp(list,currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage > 1 then
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage - 1) end
                callBackSetIdx(maxPageItem)
            end
        else
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(totalPage) end
                callBackSetIdx(remainder)
            end
        end
    else
        if idxCurr > 1 then
            callBackSetIdx(idxCurr - 1)
        else
            callBackSetIdx(total)
        end
    end
end

function GridKeyDown(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage < totalPage then
            if idxCurr < maxPageItem then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage + 1)end
                callBackSetIdx(1)
            end
        else
            if  idxCurr < remainder then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(1) end
                callBackSetIdx(1)
            end
        end
    else
        if idxCurr < total then
            callBackSetIdx(idxCurr + 1)
        else
            callBackSetIdx(1)
        end
    end
end