function TableContainsValue(t, value)
    for _, table_value in pairs(t) do
        if value == table_value then
            return true
        end
    end
    return false
end

function GetTableKeys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end