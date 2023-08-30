function Injectable(class, options)
    local options = options or {}
    class.MetaData.Injection = {
        Global = options.Global == true,
        Unique = options.Unique == true
    }
    return class
end