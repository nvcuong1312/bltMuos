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

local isTimeoutShow = false
local idxTimeout = 1

local isAudioShow = false
local idxAudio = 1
local audioList = {}

local isSwitchAudioShow = false

local isQuitConfirm = false

local fontBig
local fontSmall

function HeaderUI()
    local xPos = 0
    local yPos = 0

    love.graphics.setColor(0.31, 0.31, 0.118)
    love.graphics.rectangle("fill", xPos, yPos, 640, 30)

    love.graphics.setColor(0.98, 0.98, 0.749)
    love.graphics.setFont(fontBig)
    love.graphics.draw(ic_bluetooth, 640 - 25, yPos + 4)
    love.graphics.print("Bluetooth Settings", xPos + 230, yPos + 5)

    Now = os.date('*t')
    local formatted_time = string.format("%d:%02d", tonumber(Now.hour), tonumber(Now.min))
    love.graphics.setColor(0.98, 0.98, 0.749, 0.7)
    love.graphics.print(formatted_time, xPos + 10, yPos + 5)

    love.graphics.setFont(fontSmall)
end

function BottomButtonUI()
    local xPos = 10
    local yPos = 435

    -- UI
    love.graphics.setColor(1,1,1)
    love.graphics.print("[Y]: Scan", xPos + 100, yPos)
    love.graphics.print("[A]: Connect", xPos, yPos)
    love.graphics.print("[X]: " .. txtDisconnectRemoveBtn, xPos, yPos + 20)
    love.graphics.print("[B]: Quit",  xPos + 100, yPos + 20)
    love.graphics.print("[Start]  : ON",  xPos + 180, yPos)
    love.graphics.print("[Select]: OFF", xPos + 180, yPos + 20)
    love.graphics.print("[L1]: Audio",  xPos + 265, yPos + 20)

    -- Event
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

    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.416, 0.439, 0.408)
    love.graphics.rectangle("fill", xPos,yPos, 300, 200)

    love.graphics.setColor(0.49, 0.502, 0.49)
    love.graphics.rectangle("fill", xPos,yPos, 300, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.print("Choose timeout", xPos + 80, yPos + 5)

    local iPos = 1
    local lineHeight = 20
    for _,timeout in ipairs(Config.TIMEOUT_LIST) do
        love.graphics.setColor(1,1,1)
        if iPos == idxTimeout then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 30, 300, lineHeight)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print(timeout, xPos + 10, iPos * lineHeight + yPos + 30)
        iPos = iPos + 1
    end

    love.graphics.setFont(fontSmall)

    love.graphics.setColor(1,1,1)
    love.graphics.print("A: Continue   B: Close", xPos, yPos + 200)
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

    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.416, 0.439, 0.408)
    love.graphics.rectangle("fill", xPos,yPos, 400, 300)

    love.graphics.setColor(0.49, 0.502, 0.49)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.print("Select a sound output ", xPos + 80, yPos + 5)

    local iPos = 1
    local lineHeight = 20
    for _,audio in ipairs(audioList) do
        love.graphics.setColor(1,1,1)
        if iPos == idxAudio then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos,iPos * lineHeight + yPos + 20, 400, lineHeight)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.print("[" .. audio.id .. "] " .. audio.name, xPos + 10, iPos * lineHeight + yPos + 20)
        iPos = iPos + 1
    end

    love.graphics.setFont(fontSmall)

    love.graphics.setColor(1,1,1)
    love.graphics.print("A: Select   B: Close", xPos, yPos + 300)
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

    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.416, 0.439, 0.408)
    love.graphics.rectangle("fill", xPos,yPos, 400, 100)

    love.graphics.setColor(0.49, 0.502, 0.49)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.print("Confirm", xPos + 150, yPos + 5)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Do you want to change the audio output?", xPos + 10, yPos + 50)

    love.graphics.setColor(1,1,1)
    love.graphics.print("A: Yes   B: No", xPos, yPos + 100)
end

-- Bluetooth
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
        local MAC = ""
        local fullName = ""
        if isAvailableDevicesSelected then
            MAC = availableDevices[idxAvailableDevices].ip
            fullName = availableDevices[idxAvailableDevices].fullname
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
            MAC = connectedDevices[idxConnectedDevice].ip
            fullName = connectedDevices[idxConnectedDevice].fullname
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
            msgLog = "Failed to connect: " .. MAC
        else
            msgLog = "Connected: " .. MAC
            audioList = Audio.Sinks()
            for idx,item in ipairs(audioList) do
                if StringHelper.Trim(item.name) == StringHelper.Trim(fullName) then
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
        local MAC = connectedDevices[idxConnectedDevice].ip
        local dType = connectedDevices[idxConnectedDevice].type

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

    local total = table.getn(availableDevices)
    local idxStart = currAvailableDevicePage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = currAvailableDevicePage * Config.GRID_PAGE_ITEM

    local iPos = 0
    for idx = idxStart, idxEnd do
        if idx > total then break end

        if isAvailableDevicesSelected and iPos + 1 == idxAvailableDevices then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos, iPos * lineHeight + yPos + 65, width, 15)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.setColor(1,1,1)
        love.graphics.print(availableDevices[idx].ip, xPos + 10, iPos * lineHeight + yPos + 65)
        love.graphics.print(availableDevices[idx].name, xPos + 150, iPos * lineHeight + yPos + 65)

        iPos = iPos + 1
    end

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

    local total = table.getn(connectedDevices)
    local idxStart = currConnectedDevicePage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = currConnectedDevicePage * Config.GRID_PAGE_ITEM

    local iPos = 0
    for idx = idxStart, idxEnd do
        if idx > total then break end

        if not isAvailableDevicesSelected and iPos + 1 == idxConnectedDevice then
            love.graphics.setColor(0.435, 0.522, 0.478, 0.4)
            love.graphics.rectangle("fill", xPos, iPos * lineHeight + yPos + 65, width, 15)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.setColor(1,1,1)
        love.graphics.print(connectedDevices[idx].ip, xPos + 10, iPos * lineHeight + yPos + 65)
        love.graphics.print(connectedDevices[idx].name, xPos + 150, iPos * lineHeight + yPos + 65)

        iPos = iPos + 1
    end

    love.graphics.setColor(1,1,1)
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

    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0,0, 640, 480)

    love.graphics.setColor(0.416, 0.439, 0.408)
    love.graphics.rectangle("fill", xPos,yPos, 400, 100)

    love.graphics.setColor(0.49, 0.502, 0.49)
    love.graphics.rectangle("fill", xPos,yPos, 400, 30)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.print("Confirm", xPos + 150, yPos + 5)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Are you sure you want to exit?", xPos + 10, yPos + 50)

    love.graphics.setColor(1,1,1)
    love.graphics.print("A: Yes   B: No", xPos, yPos + 100)
end

-- Love

function love.load()
    fontBig = love.graphics.newFont(Config.FONT_PATH, 17)
    fontSmall = love.graphics.newFont(Config.FONT_PATH, 12)

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

    ScanTimeoutSelectionUI()
    AudioSelectionUI()
    ConfirmAutoSwitchAudioUI()
    ShowQuitConfirmUI()
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
    if button == "a" then
        key = "a"
    end
    if button == "b" then
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

 function OnKeyPress(key)
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
    end

    if isAvailableDevicesSelected then
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
        if key == "up" then
            GridKeyUp(connectedDevices, currConnectedDevicePage, idxConnectedDevice, Config.GRID_PAGE_ITEM, SetIdxConnectedDevice, ChangeConnectedDevicePage)
            return
        end

        if key == "down" then
            GridKeyDown(connectedDevices, currConnectedDevicePage, idxConnectedDevice, Config.GRID_PAGE_ITEM, SetIdxConnectedDevice, ChangeConnectedDevicePage)
            return
        end
    end

    if isQuitConfirm then
        if key == "a" then
            love.event.quit()
           return 
        end

        if key == "b" then
            isQuitConfirm = false
            return
        end
    end

    if isBluetoothOn then
        if key == "a" then
            -- Connect
            ConnectDevice()
            return
        elseif key == "x" then
            -- Disconnect
            DisconnectDevice()
            return
        elseif key == "select" then
            -- PowerOff
            TurnOffBluetooth()
            return
        else if key == "y" then
            -- Scan
            ShowScanTimeoutUI()
            return
        end
    end
    else
        if key == "start" then
            -- PowerOn
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
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
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
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
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