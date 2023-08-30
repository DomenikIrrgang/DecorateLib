function MethodDefaultParameters(callable, ...)
    local defaults = { ... }
    return function(instance, ...)
        local arguments = { ... }
        for key, value in pairs(defaults) do
            if arguments[key] == nil then
                arguments[key] = value
            end
        end
        return callable(instance, unpack(arguments, 1, GetTableKeys(arguments)[#GetTableKeys(arguments)]))
    end
end

Default = CreateMethodDecorator(function(callable, options)
    if type(options) ~= "table" then
        error("Options for DefaultParameters have to be of type table in the format key = parameter_index, value = default_value.")
    end
    return MethodDefaultParameters(callable, unpack(options, 1, GetTableKeys(options)[#GetTableKeys(options)]))
end)