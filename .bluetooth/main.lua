local love = require("love")
local Config = require("config")
local Bluetooth = require("bluetooth")

local textblock = require("textblock")

function love.load()
    -- love.graphics.setFullscreen(true)
    -- ScanDevices(5)

    -- local devices = GetDevices()
    -- for _, device in ipairs(devices) do
    --     print("IP: " .. device.ip .. ", Name: " .. device.name)
    -- end
    local height = love.graphics.getHeight( )
    local width = love.graphics.getWidth( )
    print("height: " .. height .. " width: " .. width)
end

function love.draw()
    callBack = function() 
        print("click click")
    end
    tbl = textblock("cuong", true, callBack)

end

function love.update(dt)
    love.graphics.print("ahihi", 400, 300)
end