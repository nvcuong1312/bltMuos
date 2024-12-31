local love = require("love")
local Config = require("config")
local Bluetooth = require("bluetooth")

local textblock = require("textblock")

local input = require("input")

local SCREEN_MAIN = 1
local SCREEN_LOADING = 2
local SCREEN_GRID = 3

local currScreen = SCREEN_MAIN

local keyPress = ""

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
    print("height: " .. height .. " width: " .. width)
end

function love.draw()
    BottomButton()
    ConnectedDevices()
    ScanDevices()

    love.graphics.print(keyPress, 100, 100)
end

function ConnectedDevices()
    -- UI
    love.graphics.rectangle("line", 10, 10, 300, 400)
    love.graphics.print("Connected Devices", 10 + 10, 20)
end

function ScanDevices()
    -- UI
    love.graphics.rectangle("line", 330, 10, 300, 400)
    love.graphics.print("Scan Devices", 330 + 10, 20)
end

local bottomEvent
function BottomButton()
    -- UI
    love.graphics.print("Start: PowerOn Bluetooth", 10, 430)
    love.graphics.print("Select: PowerOf Bluetooth", 10, 450)
    love.graphics.print("Y: Scan", 200, 430)
    love.graphics.print("A: Connect", 200, 450)
    love.graphics.print("B: Disconnect", 300, 430)
    love.graphics.print("X: Delete", 300, 450)

    -- Event
    bottomEvent = function(key)
        if key == "a" then
            -- Connect
        elseif key == "b" then
            -- Disconnect
        elseif key == "x" then
            -- Delete
        elseif key == "y" then
            -- Scan
        elseif key == "select" then
            -- PowerOf
        elseif key == "start" then
            -- PowerOn
        end
    end
end

function callBackOnclick(key)
    bottomEvent(key)
end

function love.update(dt)
    input.update(dt)
    input.onClick(callBackOnclick)
end

-- function love.keypressed(key)
--     bottomEvent("a")
--     keyPress = "a"
--     -- love.graphics.print("key", 100, 100)
-- end