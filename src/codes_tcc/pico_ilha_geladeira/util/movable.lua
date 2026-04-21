local Objeto = require("util.objeto")
local Vetor = require("util.vetor")

local Movable = {}
Movable.__index = Movable

-- Herança: Movable herda de Objeto
setmetatable(Movable, {__index = Objeto})

function Movable.create(opts)
    opts = opts or {}
    local self = Objeto.create(opts)
    
    self.velocidade = opts.velocidade or Vetor.new{ x = 0, y = 0 }
    
    setmetatable(self, Movable)
    return self
end

-- ==================== MOVIMENTO ====================



function Movable:set_velocidade(vx, vy)
    self.velocidade = Vetor.new({x=vx, y=vy})
    return self
end

function Movable:get_velocidade_magnitude()
    return self.velocidade:magnitude()
end

function Movable:get_posicao_vetor()
    return Vetor.new({x=self.rect.x, y=self.rect.y})
end

function Movable:set_posicao_vetor(pos)
    self.rect.x = pos.x
    self.rect.y = pos.y
    return self
end

return Movable
