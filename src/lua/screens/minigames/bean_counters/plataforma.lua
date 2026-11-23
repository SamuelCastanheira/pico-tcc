-- Plataforma de entrega com duas pilhas: enche a primeira, depois a segunda.
-- Depois de cada entrega na primeira pilha, espera 250 ms.
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")
local Pilha = require("screens.minigames.bean_counters.pilha")

local Plataforma = Objeto:extend()

function Plataforma:init (rect, img)
    self.rect = rect
    self.hitbox = rect
    self.img = img
    self.pilhas = { Pilha:new(0.1, 0.85, 10), Pilha:new(0.15, 0.85, 10) }
    self.espera = nil
end

function Plataforma:recebe ()
    local p1, p2 = self.pilhas[1], self.pilhas[2]
    if not p1:cheia() then
        if self.espera then return end
        p1:adiciona()
        self.espera = Temporizador:new(250 * Temporizador.MS)
        if p1:cheia() then self.espera = nil end
    elseif not p2:cheia() then      -- com as duas cheias, não recebe mais
        p2:adiciona()
    end
end

function Plataforma:cheia ()
    return self.pilhas[2]:cheia()
end

function Plataforma:tempo (dt)
    if self.espera and self.espera:tempo(dt) then
        self.espera = nil
    end
end

function Plataforma:desenha ()
    pico.output.draw.image(self.img, self.rect)
    for _, p in ipairs(self.pilhas) do
        p:desenha()
    end
end

return Plataforma
