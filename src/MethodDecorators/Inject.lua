Inject = CreateMethodDecorator(function(callable, options)
    if type(options) ~= "table" then
        error("Options for InjectParameters have to be of type table in the format key = parameter_index, value = class.")
    end
    return function(instance, ...)
        local arguments = { ... }
        for index, class in pairs(options) do
            arguments[index] = Injector:InjectClass(class) or arguments[index]
        end
        return callable(instance, unpack(arguments))
    end
end)