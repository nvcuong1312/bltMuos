local love = require("love")
local Config = require("config")
local Bluetooth = require("bluetooth")

local textblock = require("textblock")


local input = require("input")

local keyPrs = ""

function love.load()
    -- love.graphics.setFullscreen(true)
    -- ScanDevices(5)

    -- local devices = GetDevices()
    -- for _, device in ipairs(devices) do
    --     print("IP: " .. device.ip .. ", Name: " .. device.name)
    -- end
    -- Initialize joystick

    local height = love.graphics.getHeight()
    local width = love.graphics.getWidth()
    input.load()
    print("height: " .. height .. " width: " .. width)
end

function love.draw()
    -- callBack = function()
    --     print("click click")
    -- end
    -- tbl = textblock("cuong", true, callBack)

    love.graphics.print(keyPrs)
end

function love.update(dt)
    input.update(dt)
    input.onClick(function (key)
        keyPrs = key
    end)
end

function love.keypressed(key)
    if key == "escape" then
        keyPrs = "escape"
    end

    if key == "left" then
        keyPrs = "left"
    end

    if key == "right" then
        keyPrs = "right"
    end

    if key == "up" then
        keyPrs = "up"
    end

    if key == "down" then
        keyPrs = "down"
    end

    if key == "return" then
        keyPrs = "return"
    end

    if key == "lalt" then
        keyPrs = "lalt"
    end
end
