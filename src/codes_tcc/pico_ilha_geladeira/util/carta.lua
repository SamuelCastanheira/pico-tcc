local Objeto = require("util.objeto")

local Carta = {}
Carta.__index = Carta

-- Herança: Carta herda de Objeto
setmetatable(Carta, {__index = Objeto})

function Carta.create(elemento, pontuacao, path)
    local self = {
        elemento = elemento,
        pontuacao = pontuacao,
        path = path,
        rect = {}
    }
    
    setmetatable(self, Carta)
    return self
end

-- Métodos específicos de Carta (se houver)
function Carta:get_verso()
    return "../../../assets/imgs/dojo/carta_azul.png"
end

function Carta:set_rect(rect)
    self.rect = rect
end

return Carta