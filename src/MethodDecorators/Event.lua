Event = CreateMethodDecorator(function(callable, event_name, index)
    if type(event_name) ~= "string" then
        error("Event name has to be of type string.")
    end
    local frame = CreateFrame("Frame")
    frame:RegisterEvent(event_name)
    print("registering event", event_name, "for", callable)
    frame:SetScript("OnEvent", function(_, event, ...)
        print("event", event, callable)
        callable(instance)
    end)
    return function(instance, ...)
        return callable(instance, ...)
    end
end)