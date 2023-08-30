CallStack = {}
CallStack.Values = {}

function CallStack:Push(element)
    self.Values[self:Size() + 1] = element
end

function CallStack:Pop()
    local element = self.Values[self:Size()]
    self.Values[self:Size()] = nil
    return element
end

function CallStack:Peek()
    return self.Values[self:Size()]
end

function CallStack:Size()
    return #self.Values
end

function CallStack:Print()
    print("Stack for", self:Peek().Key)
    for _, value in pairs(self.Values) do
        print(value.Key)
    end
end