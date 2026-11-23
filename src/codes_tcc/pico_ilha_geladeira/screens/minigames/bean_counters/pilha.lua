-- Pilha de sacos de café na plataforma.
local Objeto = require("util.objeto")

local IMG = "../../../assets/imgs/bean_counters/Coffe_bag.webp"

local Pilha = Objeto:extend()

function Pilha:init (x, y, max)
    self.x, self.y = x, y
    self.max = max
    self.qnt = 0
end

function Pilha:adiciona ()
    self.qnt = self.qnt + 1
end

function Pilha:cheia ()
    return self.qnt >= self.max
end

function Pilha:desenha ()
    for i = 1, self.qnt do
        pico.layer.image{path = IMG}
        pico.set.layer(IMG)
        pico.set.effect{rotate = {angle = 0, anchor = 'C'}}
        pico.set.layer("world")
        pico.output.draw.image(IMG, {'%', x = self.x, y = self.y - (0.03 * (i-1)), w = 0.1, h = 0.1})
    end
end

return Pilha
