local DefaultClassMetaTable = {
    __newindex = function(class, key, value)
        if type(value) == "function" then
            InitializeClassFunction(class, key, value)
        else
            rawset(class, key, value)
        end
    end
}

function InitFunctionMetaData(class, function_name, callable)
    if callable == nil then
        callable = function() end
    end
    class.MetaData.Functions[function_name] = class.MetaData.Functions[function_name] or {
        Class = class,
        OriginalFunction = callable,
        BeforeCallHooks = {},
        AfterCallHooks = {},
    }
end

function InitializeClassFunction(class, function_name, callable)
    InitFunctionMetaData(class, function_name, callable)
    class.MetaData.Functions[function_name].OriginalFunction = callable
    rawset(class, function_name, function(instance, ...)
        CallStack:Push({
            Key = function_name,
            Class = class,
            Instance = instance,
            Function = callable,
            Arguments = { ... }
        })
        local arguments = { ... }
        print("Calling function " .. class.MetaData.Name .. "." .. function_name .. ".")
        print("Arguments: ", unpack(arguments))
        print("Functions", class.MetaData.Functions)
        print("Functions", class.MetaData.Functions[function_name].BeforeCallHooks)
        print("BeforeCallHooks", unpack(class.MetaData.Functions[function_name].BeforeCallHooks))
        for _, decorator in pairs(class.MetaData.Functions[function_name].BeforeCallHooks) do
            decorator(instance, arguments)
        end
        local result = class.MetaData.Functions[function_name].OriginalFunction(instance, unpack(arguments))
        for _, decorator in pairs(class.MetaData.Functions[function_name].AfterCallHooks) do
            decorator(instance, arguments, result)
        end
        CallStack:Pop()
        return result
    end)
end

function AddClassFunctionDecorator(class, function_name, before_callback, after_callback, ...)
    if before_callback ~= nil then
        class.MetaData.Functions[function_name].BeforeCallHooks[#class.MetaData.Functions[function_name].BeforeCallHooks + 1] = before_callback(...)
    end
    if after_callback ~= nil then
        class.MetaData.Functions[function_name].AfterCallHooks[#class.MetaData.Functions[function_name].AfterCallHooks + 1] = after_callback(...)
    end
end

function CreateClassFunctionDecorator(before_callback, after_callback)
    return function(class, function_name, ...)
        InitFunctionMetaData(class, function_name)
        AddClassFunctionDecorator(class, function_name, before_callback, after_callback, ...)
    end
end

function FunctionDefaultParameters(callable, ...)
    local defaults = { ... }
    return function(...)
        local arguments = { ... }
        for key, value in pairs(defaults) do
            if arguments[key] == nil then
                arguments[key] = value
            end
        end
        return callable(unpack(arguments))
    end
end

function CreateMethodDecorator(callable)
    return function(class, function_name, ...)
        class.MetaData.Functions[function_name] = class.MetaData.Functions[function_name] or {
            Class = class,
            OriginalFunction = function() end,
            Decorator = function(...)
                print("Decorator function called for " .. class.MetaData.Name .. "." .. function_name .. ".", class.MetaData.Functions[function_name].OriginalFunction)
                return class.MetaData.Functions[function_name].OriginalFunction(...)
            end,
        }
        class.MetaData.Functions[function_name].Decorator = callable(class.MetaData.Functions[function_name].Decorator, ...)
    end
end

function CreateClass(name, decorators)
    if name == nil then
        error("CreateClass has to be passed a name.")
    end
    local decorators = decorators or {}
    local new_class = {}
    new_class.__index = new_class
    new_class.MetaData = {}
    new_class.MetaData.Name = name
    new_class.MetaData.Functions = {}
    new_class.MetaData.Fields = {}
    new_class.MetaData.Decorators = decorators
    setmetatable(new_class, DefaultClassMetaTable)
    for _, decorator in pairs(decorators) do
        local arguments = { unpack(decorator, 2, #decorator) }
        decorator[1](new_class,  unpack(decorator, 2, #decorator))
    end
    return new_class
end

Injector = {}
Injector.Instances = {}
Injector.Context = {}

function Injector:InjectClass(class_definition, injection_context)
    local context = injection_context or self.Context
    if class_definition.MetaData.Injection and (class_definition.MetaData.Injection.Global or context[class_definition.MetaData.Name] ~= nil) then
        local test = self:CreateClassInstance(class_definition)
        return test
    end
    DependencyInjector:Error("Class '" .. class_definition.MetaData.Name .. "' is not in injection context or is not injectable.")
end

function Injector:CreateClassInstance(class_definition)
    if class_definition.MetaData.Injection.Unique and self.Instances[class_definition.MetaData.Name] ~= nil then
        return self.Instances[class_definition.MetaData.Name]
    end
    local instance = {}
    setmetatable(instance, class_definition)
    for field, class in pairs(class_definition.MetaData.Fields) do
        instance[field] = self:InjectClass(class)
    end
    self.Instances[class_definition.MetaData.Name] = instance
    if instance.Constructor then
        instance:Constructor()
    end
    return instance
end