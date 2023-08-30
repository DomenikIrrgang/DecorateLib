function DependencyInjector:ChatMessage(...)
    print("[DependencyInjector] ", ...)
end

function DependencyInjector:Debug(...)
    if self.MetaData.Mode == 1 then
        self:ChatMessage("[Debug] ", ...)
    end
end

function DependencyInjector:Info(...)
    if self.MetaData.Mode <= 2 then
        self:ChatMessage("[Info] ", ...)
    end
end

function DependencyInjector:Error(...)
    if self.MetaData.Mode <= 3 then
        self:ChatMessage("[Error] ", ...)
    end
end