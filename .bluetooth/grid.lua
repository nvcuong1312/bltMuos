local love = require("love")

local grid = {}
local items = {}
local idxSelected = 0

function grid.config(width, height)
    return {
        width = width,
        height = height
    }
end

function grid.addItem(item)
    table.insert(items, item)
end

function grid.update(dt)

end

function grid.moveUp()
    if idxSelected > 0 then
        idxSelected = idxSelected - 1
    end
end

function grid.moveDown()
    if idxSelected < table.getn(items) then
        idxSelected = idxSelected + 1
    end
end

return grid