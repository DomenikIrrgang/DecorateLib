local Knife = Injectable(CreateClass("Knife"), { Global = true })
local Apple = Injectable(CreateClass("Apple"), { Global = true })

Default(Knife, "Cut", { [1] = 4 })
Inject(Knife, "Cut", { [2] = Apple })
InjectGlobals(Knife, "Cut", { [3] = "print" })
function Knife:Cut(sharpness, second_sharpness, callable)
    callable("Cutting with sharpness", sharpness, second_sharpness.MetaData.Name, callable)
end

Knife:Cut()