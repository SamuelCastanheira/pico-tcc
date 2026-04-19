local Movable = require("util.movable")

local Puffle = {}
Puffle.__index = Puffle

-- Herança: Puffle herda de Movable
setmetatable(Puffle, {__index = Movable})

function Puffle.create(path, rect)
    local self = {
        path = path,
        rect = rect,
        img = path,
        img_hover = path,
        hover = false
    }
    
    setmetatable(self, Puffle)
    return self
end

-- Métodos específicos de Puffle
-- (métodos de movimento estão em Movable)

return Puffle