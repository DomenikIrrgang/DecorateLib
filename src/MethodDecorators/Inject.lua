Inject = CreateClassFunctionDecorator(function(parameter_options)
    return function(instance, arguments)
        for index, class in pairs(parameter_options) do
            arguments[index] = arguments[index] or Injector:InjectClass(class)
        end
    end
end)