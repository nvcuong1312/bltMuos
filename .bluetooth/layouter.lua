--[[
Layouter
UI Grid Layout Library for LÖVE 2D Game Engine
© Daniel Duris, dusoft@staznosti.sk, 2023+
License: GNU LGPL 3.0
]]--

local layouter = {
    _NAME = "Layouter",
    _DESCRIPTION = 'UI Grid Layout Library for LÖVE 2D Game Engine',
    _URL = 'https://github.com/nekromoff/layouter',
    _VERSION = 1,
    _LICENSE = "LGPL 3.0",
    _LOVE = 11.4,
    ---------------------------
    ROWS = 16,
    COLUMNS = 24,
    elements = {},
    _layout = {},
    _helpers = {},
}

-- @param table options
layouter.initialize = function(options)
    local options = options or {}
    layouter.font = options.font or love.graphics.newFont(15)
    layouter.background = options.background or {255, 255, 255}
    layouter.color = options.color or {0, 0, 0}
    layouter.debug = options.debug or false
    local width, height = love.window.getMode()
    layouter.COLUMN_WIDTH = layouter._helpers.math_round(width / layouter.COLUMNS)
    layouter.ROW_HEIGHT = layouter._helpers.math_round(height / layouter.ROWS)
    -- precalculate pixels for each column/row to allow for using shortcuts, e.g. layouter.COLUMN5 or layouter.ROW2
    -- (yeah, similar to Bootstrap CSS grid)
    for column = 1, layouter.COLUMNS do
        layouter['COLUMN'..column] = layouter.COLUMN_WIDTH * column
    end
    for row = 1, layouter.ROWS do
        layouter['ROW'..row] = layouter.ROW_HEIGHT * row
    end
    layouter.reset()
end

layouter.reset = function()
    layouter.elements = {}
    layouter._layout = {}
    layouter._previous = nil
end

-- add element to layout
-- @param nil/string/table element options
layouter.add = function (element)
    local element = layouter._createElement(element)
    layouter.elements[#layouter.elements + 1] = element
end

-- replace existing element in layout by a new one
-- @param string existing element_key
-- @param nil/string/table element options
layouter.replace = function(element_key, element)
    local element = layouter._createElement(element)
    for temp_key, temp_element in pairs(layouter.elements) do
        if temp_element.key == element_key then
            layouter.elements[temp_key] = element
        end
    end
    -- call prepare automatically to update screen on next draw (prepare remembers previous state)
    layouter.prepare()
end

-- remove existing element from layout
-- @param string existing element_key
layouter.remove = function(element_key)
    for key, element in pairs(layouter.elements) do
        if element.key == element_key then
            table.remove(layouter.elements, key)
        end
    end
end

-- setup an element to be added to layout
-- @param string existing element_key
layouter._createElement = function(element)
    -- change empty content for adding text to proper table
    if element == nil then
        element = {}
        element.content = '';
    elseif type(element) == 'string' then -- change simplified format for adding text to proper table
        local temp_content = element
        element = {}
        element.content = temp_content
    end
    element.content = element.content or ''
    element.type = element.type or 'text'
    element.callback = element.callback or false
    element.font = element.font or layouter.font
    element.color = element.color or layouter.color
    element.background = element.background or layouter.background
    if element.key == nil then
        -- generate unique identifier / key using only a-z0-9_
        element.key = string.gsub(element.content:lower(), '%W', '')
    end
    element.x = element.x or false
    element.y = element.y or false
    -- if exact location is provided, precalculate dimensions
    if element.x and element.y and element.width == nil and element.height == nil then
        if element.type == 'image' then
            element.width, element.height = element.content:getDimensions()
        else
            temp_text = love.graphics.newText(element.font, element.content)
            element.width, element.height = temp_text:getDimensions()
        end
    end
    return element
end

-- prepares a layout, does all computations for elements, assigns positions, does autosizing etc.
-- @param table layout options
layouter.prepare = function(layout)
    layouter._layout = {}
    local layout = layout or {}
    -- if previous state exists and was not reset, use it
    if layouter._previous then
        layout.x = layouter._previous.x
        layout.y = layouter._previous.y
        layout.direction = layouter._previous.direction
        layout.spacing = layouter._previous.spacing
        layout.padding = layouter._previous.padding
    end
    layout.x = layout.x or false
    layout.y = layout.y or false
    layout.width, layout.height = love.window.getMode()
    layout.direction = layout.direction or 'vertical'
    layout.spacing = layout.spacing or {width = layout.width, height = layout.height}
    layout.padding = layout.padding or 10
    if layout.spacing == 'auto' then
        layout.spacing = {width = layout.width - layout.x * 2, height = layout.height - layout.y * 2}
    end
    -- remember current state
    layouter._previous = {x = layout.x, y = layout.y, direction = layout.direction, spacing = layout.spacing, padding = layout.padding}
    if layout.direction == 'horizontal' then
        fit_width = layout.spacing.width / layouter._helpers.table_length(layouter.elements) - layout.padding * 2
        fit_height = layouter.font:getHeight() + layout.padding * 2
    else -- vertical
        fit_width = layout.spacing.width - layout.padding * 2
        fit_height = layout.spacing.height / layouter._helpers.table_length(layouter.elements) - layout.padding * 2
    end
    local last_x = layout.x
    local last_y = layout.y
    for key, element in ipairs(layouter.elements) do
        local prepared_element = layouter._helpers.table_copy(element)
        -- do automatic layout, if x and y not set directly
        if prepared_element.x == false and prepared_element.y == false then
            if layout.direction == 'horizontal' then
                prepared_element.width = fit_width
                prepared_element.height = fit_height
                prepared_element.x = layout.padding + last_x
                prepared_element.y = layout.y
            else
                prepared_element.width = fit_width
                prepared_element.height = fit_height
                prepared_element.x = layout.x + layout.padding
                prepared_element.y = layout.padding + last_y
            end
            last_x = prepared_element.x + prepared_element.width + layout.padding
            last_y = prepared_element.y + prepared_element.height + layout.padding
        end
        layouter._layout[#layouter._layout + 1] = prepared_element
    end
end

-- draw a layout, to be used in love.draw() function
layouter.draw = function()
    local x, y = love.mouse.getPosition()
    love.graphics.clear(layouter.background)
    love.graphics.setColor(love.math.colorFromBytes(layouter.color))
    if layouter.debug then
        love.graphics.setColor(love.math.colorFromBytes(176, 176, 176))
        love.graphics.setFont(layouter.font)
        for column = 0, layouter.COLUMNS do
            for row = 0, layouter.ROWS do
                love.graphics.line(column * layouter.COLUMN_WIDTH, 0, column * layouter.COLUMN_WIDTH, 16 * layouter.ROW_HEIGHT)
                love.graphics.line(0, row * layouter.ROW_HEIGHT, 24 * layouter.COLUMN_WIDTH, row * layouter.ROW_HEIGHT)
                love.graphics.print(column..','..row, column * layouter.COLUMN_WIDTH, row * layouter.ROW_HEIGHT)
            end
        end
    end
    love.graphics.setColor(love.math.colorFromBytes(layouter.color))
    for key, element in pairs(layouter._layout) do
        local content_y = layouter._helpers.math_round(element.y + element.height / 5 * 2)
        if element.type == 'button' then
            if x >= element.x and x <= element.x + element.width and y >= element.y and y <= element.y + element.height then
                love.graphics.setColor(love.math.colorFromBytes(element.color))
                love.graphics.rectangle('fill', element.x, element.y, element.width, element.height)
                love.graphics.setColor(love.math.colorFromBytes(element.background))
                love.graphics.printf(element.content, element.font, element.x, content_y, element.width, 'center')
            else
                love.graphics.setColor(love.math.colorFromBytes(element.color))
                love.graphics.rectangle('line', element.x, element.y, element.width, element.height)
                love.graphics.printf(element.content, element.font, element.x, content_y, element.width, 'center')
            end
        elseif element.type == 'text' then
            love.graphics.setColor(love.math.colorFromBytes(element.color))
            love.graphics.printf(element.content, element.font, element.x, content_y, element.width, 'center')
        else -- image
            love.graphics.setColor(love.math.colorFromBytes(element.background))
            love.graphics.draw(element.content, element.x, element.y)
        end
    end
end

-- process mouse callbacks, to be used in love.mousepressed() function
-- currently supports only default (usually left) button
layouter.processMouse = function(x, y, mouse_button, is_touch)
    if mouse_button ~= 1 then
        return
    end
    for element_key, element in pairs(layouter._layout) do
        -- for position debug
        -- print (element.x..'> '..x..' <'..element.x + element.width, element.y..'> '..y..' <'..element.y + element.height)
        if element.callback ~= false and x >= element.x and x <= element.x + element.width and y >= element.y and y <= element.y + element.height then
            element.callback()
        end
    end
end

layouter._helpers.math_round = function(number, decimal_places)
    local multiplicator = 10 ^ (decimal_places or 0)
    return math.floor(number * multiplicator + 0.5) / multiplicator
end

layouter._helpers.table_length = function(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

layouter._helpers.table_copy = function (orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[layouter._helpers.table_copy(orig_key)] = layouter._helpers.table_copy(orig_value)
        end
        setmetatable(copy, layouter._helpers.table_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return layouter
