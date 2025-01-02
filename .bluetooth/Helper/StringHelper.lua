local StringHelper = {}

function StringHelper.IsMACAndNameValid(MAC, Name)
    -- local s1 = MAC:gsub(":", "")
    -- local s2 = Name:gsub("-", "")
    -- return s1 ~= s2

    return true
end

function StringHelper.FormatStringToLarge(str, maxLength)
    if #str > 0 and #str > maxLength then
        return string.sub(str, 1, maxLength)
    end

    return str
end

return StringHelper