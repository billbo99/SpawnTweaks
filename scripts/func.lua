local Func = {}

function Func.sortKeys(data)
    local tkeys = {}
    for k, _ in pairs(data) do
        table.insert(tkeys, k)
    end
    table.sort(tkeys)
    return tkeys
end

function Func.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Func.ends_with(str, ending)
    return ending == "" or str:sub(-(#ending)) == ending
end

function Func.starts_with(str, start)
    return str:sub(1, #start) == start
end

function Func.Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function Func.CapitalizeWord(str)
    return (str:gsub("^%l", string.upper))
end

return Func
