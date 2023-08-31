Default = CreateClassFunctionDecorator(function(parameter_options)
    return function(instance, arguments)
        for index, value in pairs(parameter_options) do
            if arguments[index] == nil then
                arguments[index] = value
            end
        end
    end
end)