local love = require("love")
local input = {}

local joystick
local key = ""

function input.load()
    -- love.graphics.setFullscreen(true)
    -- ScanDevices(5)

    -- local devices = GetDevices()
    -- for _, device in ipairs(devices) do
    --     print("IP: " .. device.ip .. ", Name: " .. device.name)
    -- end
    -- Initialize joystick
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        joystick = joysticks[1]
    end
end

function input.update(dt)
    if joystick then
        if joystick:isGamepadDown("dpleft") then
            key = "left"
        end
        if joystick:isGamepadDown("dpright") then
            key = "right"
        end
        if joystick:isGamepadDown("dpup") then
            key = "up"
        end
        if joystick:isGamepadDown("dpdown") then
            key = "down"
        end
        if joystick:isGamepadDown("a") then
            key = "a"
        end
        if joystick:isGamepadDown("b") then
            key = "b"
        end
        if joystick:isGamepadDown("x") then
            key = "x"
        end
        if joystick:isGamepadDown("y") then
            key = "y"
        end
        if joystick:isGamepadDown("back") then
            key = "select"
        end
        if joystick:isGamepadDown("start") then
            key = "start"
        end
        if joystick:isGamepadDown("leftshoulder") then
            key = "leftshoulder"
        end
        if joystick:isGamepadDown("rightshoulder") then
            key = "rightshoulder"
        end
    end
end

function input.onClick(callBack)
    if key ~= "" then
        callBack(key)
        key = ""
    end
end

return input