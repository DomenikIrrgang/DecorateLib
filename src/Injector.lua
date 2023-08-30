local DefaultClassMetaTable = {
    __newindex = function(class, key, value)
        if type(value) == "function" then

            rawset(class, key, function(instance, ...)
                class.MetaData.Functions[key] = class.MetaData.Functions[key] or {
                    Class = class,
                    OriginalFunction = function(...) end,
                    Decorator = function(...)  return class.MetaData.Functions[key].OriginalFunction(...) end,
                }
                class.MetaData.Functions[key].OriginalFunction = value
                CallStack:Push({
                    Key = key,
                    Class = class,
                    Instance = instance,
                    Function = value,
                    Arguments = { ... }
                })
                local success, result = pcall(class.MetaData.Functions[key].Decorator, instance, ...)
                if (not success) then
                    local error_position = CallStack:Peek()
                    DependencyInjector:Error("An error occured in", error_position.Key)
                    DependencyInjector:Error("Error:", result)
                else
                    CallStack:Pop()
                    return result
                end
            end)
        else
            rawset(class, key, value)
        end
    end
}

function InitializeClassFunction(class, function_name, callable)
    class.MetaData.Functions[function_name] = class.MetaData.Functions[function_name] or {
        Class = class,
        OriginalFunction = callable,
        Decorators = [],
    }
    class.MetaData.Functions[function_name].OriginalFunction = callable
    class[function_name] = function(...)
        local result = nil
        for _, decorator in pairs(class.MetaData.Functions[function_name].Decorators) do
            decorator[1](class.MetaData.Functions[function_name].Decorator, unpack(decorator, 2, #decorator))
        end
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
                print("Apple Combatlog", Apple.OnCombatLogEvent)
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