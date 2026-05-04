local Vetor = require("util.vetor")
local Objeto = require("util.objeto")

local Pilha = {}
Pilha.__index = Pilha

-- Herança: Movable herda de Objeto
setmetatable(Pilha, {__index = Objeto})

function Pilha.new(opts)
    opts = opts or {}
    local self = Objeto.create(opts) 

    self.posicao = {x = opts.x,
                    y = opts.y}

    self.num_cafes = 0
    self.num_max = 10
   
    setmetatable(self, Pilha)
    return self
end

function Pilha:add()
    self.num_cafes = self.num_cafes + 1
end

function Pilha:get_img()
    local base = "../../../assets/imgs/bean_counters/Coffe_bag.webp"
    return base
end

function Pilha:cheia()
    return self.num_cafes >= self.num_max
end

return Pilha