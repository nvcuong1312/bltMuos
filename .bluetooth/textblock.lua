local love = require("love")

function textblock(text, isSelected, callBack)
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle( "fill", 10, 100, 100, 50)

    love.graphics.setColor(1, 1, 1)
    if isSelected then
        text = "-> " .. text
    end
    love.graphics.print(text, 10, 110)
end

return textblock