Validate = CreateMethodDecorator(function(callable, options, filter)
    filter = filter or false
    if type(options) ~= "table" then
        error("Options for ValidateParameters have to be of type table in the format key = parameter_index, value = validator_function.")
    end
    return function(instance, ...)
        local arguments = { ... }
        local valid = true
        local error_message = ""
        for index, validators in pairs(options) do
            for _, validator in pairs(validators) do
                valid, error_message = validator(arguments[index])
                if not valid then
                    if not filter then
                        error("Validation failed for parameter " .. index .. " in function " .. instance.MetaData.Name .. "." .. CallStack:Peek().Key .. ". Error: " .. error_message)
                    else
                        break
                    end
                end
            end
            if not valid then
                break
            end
        end
        if valid then
            return callable(instance, unpack(arguments))
        end
    end
end)

function MinimumValidator(min)
    return function(value)
        return value >= min, "Value must be bigger or equal to " .. min .. ", but was " .. value .. "."
    end
end

function MaximumValidator(max)
    return function(value)
        return value <= max, "Value must be smaller or equal to " .. max .. ", but was " .. value .. "."
    end
end

function RangeValidator(min, max)
    return function(value)
        return value >= min and value <= max, "Value must be between " .. min .. " and " .. max .. ", but was " .. value .. "."
    end
end

function TypeValidator(value_type)
    return function(value)
        return type(value) == value_type, "Value must be of type " .. value_type .. ", but was " .. type(value) .. "."
    end
end

function EnumValidator(enum)
    return function(value)
        for _, enum_value in pairs(enum) do
            if enum_value == value then
                return true
            end
        end
        return false, "Value must be one of the following: " .. table.concat(enum, ", ") .. ", but was " .. value .. "."
    end
end

function StringLengthValidator(min, max)
    return function(value)
        return #value >= min and #value <= max, "String length must be between " .. min .. " and " .. max .. ", but was " .. #value .. "."
    end
end

function NilValidator(value)
    return value == nil, "Value must be nil, but was " .. value .. "."
end

function NotNilValidator(value)
    return value ~= nil, "Value must not be nil, but was nil."
end

function NotEmptyValidator(value)
    return #value > 0, "Value must not be empty, but was empty."
end

function EmptyValidator(value)
    return #value == 0, "Value must be empty, but was not empty."
end

function NotZeroValidator(value)
    return value ~= 0, "Value must not be zero, but was zero."
end

function ZeroValidator(value)
    return value == 0, "Value must be zero, but was not zero."
end

function NotFalseValidator(value)
    return value ~= false, "Value must not be false, but was false."
end

function FalseValidator(value)
    return value == false, "Value must be false, but was not false."
end

function NotTrueValidator(value)
    return value ~= true, "Value must not be true, but was true."
end

function TrueValidator(value)
    return value == true, "Value must be true, but was not true."
end

function EqualValidator(value)
    return function(other_value)
        return value == other_value, "Value must be equal to " .. value .. ", but was " .. other_value .. "."
    end
end

function InstanceOfValidator(class)
    return function(value)
        return value.MetaData.Name == class.MetaData.Name, "Value must be an instance of " .. class.MetaData.Name .. ", but was " .. value.MetaData.Name .. "."
    end
end