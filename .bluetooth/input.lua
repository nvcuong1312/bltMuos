local love = require("love")

local input = {}
local key = ""
local joystick

function input.load()
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
            key = "l1"
        end
        if joystick:isGamepadDown("rightshoulder") then
            key = "r1"
        end
    end
end

local lastTime = 0
function input.onClick(callBack)
    local currentTime = love.timer.getTime()
    if currentTime - lastTime > 0.2 and key ~= "" then
        callBack(key)
        lastTime = currentTime
    end

    key = ""
end

return input