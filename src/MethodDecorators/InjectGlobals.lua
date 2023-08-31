InjectGlobals = CreateMethodDecorator(function(callable, options)
    if type(options) ~= "table" then
        error("Options for InjectGlobals have to be of type table in the format key = parameter_index, value = global_name.")
    end
    return function(instance, ...)
        local arguments = { ... }
        for index, global_name in pairs(options) do
            arguments[index] = _G[global_name] or arguments[index]
        end
        return callable(instance, unpack(arguments))
    end
end)

InjectGlobals = CreateClassFunctionDecorator(function(parameter_options)
    return function(instance, arguments) 
        for index, global_name in pairs(parameter_options) do
            arguments[index] = arguments[index] or _G[global_name]
        end
    end
end)