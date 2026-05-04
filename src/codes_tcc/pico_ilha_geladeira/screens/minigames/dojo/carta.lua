local Objeto = require("util.objeto")

local Carta = {}
Carta.__index = Carta

-- Herança: Carta herda de Objeto
setmetatable(Carta, {__index = Objeto})

function Carta.create(opts)
    opts = opts or {}

    local self = Objeto.create(opts)

    self.elemento = opts.elemento
    self.pontuacao = opts.pontuacao

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
function Carta:copy()
    local newCarta = Carta.create({
        elemento = self.elemento,
        pontuacao = self.pontuacao,
        img = self.img 
    })

    local r = self.rect or {}
    if r.x and r.y and r.w and r.h then
        newCarta:set_rect({
            x = r.x,
            y = r.y,
            w = r.w,
            h = r.h
        })
    end
    return newCarta
end
return Carta