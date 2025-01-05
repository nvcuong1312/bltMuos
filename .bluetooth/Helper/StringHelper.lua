local utf8 = require("utf8")

local StringHelper = {}

function StringHelper.IsMACAndNameValid(MAC, Name)
    local s1 = MAC:gsub(":", "")
    local s2 = Name:gsub("-", "")
    return s1 ~= s2
end

local function utf8_sub(s, i, j)
    local start_byte = utf8.offset(s, i) 
    local end_byte = utf8.offset(s, j + 1) - 1
    return string.sub(s, start_byte, end_byte)
end

function StringHelper.FormatStringToLarge(str, maxLength)
    if #str > maxLength then
        return utf8_sub(str, 1, maxLength)
    end

    return str
end

function StringHelper.Trim(s)
    return s:match("^%s*(.-)%s*$")
end

return StringHelper