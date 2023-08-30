local Knife = Injectable(CreateClass("Knife"), { Global = true })

local Seed = CreateClass("Seed")
Injectable(Seed, { Global = true })

Apple = CreateClass("Apple", {
    { Injectable, { Global = true, Unique = true } },
    { InjectField, "Seed", Seed },
})
InjectField(Apple, "Knife", Knife)

Validate(Apple, "Cut", {
    [1] = {
        TypeValidator("function")
    },
    [2] = {
        TypeValidator("table"),
        InstanceOfValidator(Knife)
    },
    [3] = {
        TypeValidator("table"),
        InstanceOfValidator(Seed)
    },
    [4] = {
        TypeValidator("number"),
        RangeValidator(1, 10)
    }
})
Default(Apple, "Cut", { [4] = 8 })
Inject(Apple, "Cut", { [2] = Knife, [3] = Seed })
InjectGlobals(Apple, "Cut", { "print" })
function Apple:Cut(callable, knife, seed, pieces)
    callable("Cutting apple into", pieces, "pieces with knife", knife, "revealing seed", seed)
end

Validate(Apple, "Throw", {
    [1] = {
        TypeValidator("number"),
        RangeValidator(1.0, 45.5)
    },
    [2] = {
        TypeValidator("number"),
        RangeValidator(0.0, 360.0)
    }
})
function Apple:Throw(force, angle)
    print("Throwing apple with force", force, "and angle", angle)
end

Event(Apple, "OnCombatLogEvent", "COMBAT_LOG_EVENT_UNFILTERED")
function Apple:OnCombatLogEvent()
    print("Apple:OnCombatLogEvent")
end


local Cook = CreateClass("Cook", {
    { Injectable }
})

Inject(Cook, "Constructor", { Apple })
function Cook:Constructor(apple)
    apple:Cut()
    apple:Throw(10.0, 45.0)
end

local TestCook = Injector:InjectClass(Cook, {
    Cook = Cook
})