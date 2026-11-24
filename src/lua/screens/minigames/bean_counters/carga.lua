-- Carga lançada do caminhão: sai de (0,85; 0,5) num lançamento oblíquo que
-- cai num ponto sorteado da neve. Pode ser saco de café ou objeto.
local Objeto = require("util.objeto")

local BASE = "../../assets/imgs/bean_counters"
local TIPOS = { "Anvil", "Flower_pot", "Coffe_bag", "Fish_bean_counters" }
-- lançamento oblíquo em frações da tela: g em frações por s²; o tempo da
-- carga corre a meia velocidade (ESCALA_TEMPO) para a queda ficar visível
local G = 9.8
local ESCALA_TEMPO = 0.5
local CHAO = 0.9

local Carga = Objeto:extend()

function Carga:init ()
    self.tipo = TIPOS[math.random(1, #TIPOS)]
    self.img = string.format("%s/%s.webp", BASE, self.tipo)
    self.viva = true
    self.t = 0

    -- trajetória: velocidade inicial que leva do lançamento ao destino
    self.lancamento = {x = 0.85, y = 0.5}
    local lim_e, lim_d = 0.25, 0.75
    self.destino = {x = (math.random() * (lim_d - lim_e)) + lim_e, y = CHAO}
    local min, max = math.pi/4, math.pi/3
    local dx = self.destino.x - self.lancamento.x
    local dy = self.lancamento.y - self.destino.y
    local angulo
    if dx >= 0 then
        angulo = (math.random() * (max - min)) + min
    else
        angulo = (math.random() * (math.pi - max - (math.pi - min))) + (math.pi - max)
    end
    local cos, tan = math.cos(angulo), math.tan(angulo)
    local denom = 2 * (cos * cos) * ((dx * tan) - dy)
    local v0 = math.sqrt((G * dx * dx) / denom)
    self.vel = {x = v0 * cos, y = (-v0) * math.sin(angulo)}
    self.giro0 = math.deg(math.atan2(self.vel.y, self.vel.x))

    self.rect = {'%', x = self.lancamento.x, y = self.lancamento.y, w = 0.08, h = 0.08}
    self.hitbox = self.rect
end

function Carga:e_cafe ()
    return self.tipo == "Coffe_bag"
end

-- pega pelo pinguim (sai do jogo)
function Carga:some ()
    self.viva = false
end

-- posição exata no instante t; some ao passar do chão
function Carga:tempo (dt)
    self.t = self.t + ((dt * ESCALA_TEMPO) / 1000000)
    self.rect.x = self.lancamento.x + (self.vel.x * self.t)
    self.rect.y = (self.lancamento.y + (self.vel.y * self.t)) + ((G * math.pow(self.t, 2)) / 2)
    if self.rect.y > CHAO then
        self.viva = false
    end
end

function Carga:desenha ()
    if self:e_cafe() then
        -- o saco de café gira acompanhando a direção do movimento
        local giro = math.deg(math.atan2(self.vel.y + (G * self.t), self.vel.x)) - self.giro0
        pico.set.layer(self.img)
        pico.set.effect{rotate = {angle = math.floor(giro + 0.5), anchor = 'C'}}
        pico.set.layer("world")
    end
    pico.output.draw.layer(self.img, self.rect)
end

return Carga
