-- Pinguim do Bean Counters: anda com as setas, pega sacos de café (até 5) e
-- os entrega na plataforma. Um objeto, ou um café com o pinguim cheio, o
-- derruba: perde uma vida e fica 2 s atordoado (sem andar nem pegar nada).
-- Depois de pegar ou entregar, a plataforma fica bloqueada por 250 ms.
--
-- O pinguim avisa o minigame (observador) do que acontece:
-- ao_coletar(), ao_entregar(), ao_ser_atingido().
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")

local BASE = "../../assets/imgs/bean_counters/"
local CARGA_MAXIMA = 5
local IMG_ATINGIDO = {
    Flower_pot         = BASE.."penguin_pot.webp",
    Anvil              = BASE.."penguin_anvil.webp",
    Fish_bean_counters = BASE.."penguin_fish.webp",
    Coffe_bag          = string.format(BASE.."penguin%d.webp", CARGA_MAXIMA + 1),
}

local Pinguim = Objeto:extend()

function Pinguim:init (observador)
    self.observador = observador
    self.rect = {'%', x=0.3, y=0.80, w=0.12, h=0.25}
    self.hitbox = {'%', x=0.3, y=0.80, w=0.12, h=0.25}
    self.vidas = 3
    self.carga = 0
    self.bloqueio = nil     -- plataforma bloqueada (250 ms)
    self.tonto = nil        -- atordoado (2 s)
    self:atualiza_img()
end

function Pinguim:atualiza_img ()
    self.img = string.format(BASE.."penguin%d.webp", self.carga)
end

function Pinguim:colide (outro)
    return pico.vs.rect.rect(self.hitbox, outro.hitbox)
end

function Pinguim:bloqueia_plataforma ()
    if not self.bloqueio then
        self.bloqueio = Temporizador:new(250 * Temporizador.MS)
    end
end

function Pinguim:pega (carga)
    if carga:e_cafe() and self.carga < CARGA_MAXIMA then
        self:bloqueia_plataforma()
        self.observador:ao_coletar()
        self.carga = self.carga + 1
        self:atualiza_img()
        carga:some()
    else
        self.img = IMG_ATINGIDO[carga.tipo]
        carga:some()
        self.carga = 0
        self.vidas = self.vidas - 1
        self.rect.h = 0.15
        self.tonto = Temporizador:new(2 * Temporizador.S)
        self.observador:ao_ser_atingido()
    end
end

function Pinguim:entrega ()
    self:bloqueia_plataforma()
    self.observador:ao_entregar()
    self.carga = self.carga - 1
    self:atualiza_img()
end

-- a cada passo: colisões com as cargas, entrega na plataforma e prazos.
-- Prazos criados neste passo só começam a contar no próximo.
function Pinguim:tempo (dt, cargas, plataforma)
    local bloqueio, tonto = self.bloqueio, self.tonto
    for _, c in ipairs(cargas) do
        if c.viva and not self.tonto and self:colide(c) then
            self:pega(c)
        end
    end
    if self:colide(plataforma) and not self.bloqueio and self.carga > 0 then
        self:entrega()
    end
    if bloqueio and bloqueio:tempo(dt) then
        self.bloqueio = nil
    end
    if tonto and tonto:tempo(dt) then
        self.tonto = nil
        self:atualiza_img()
        self.rect.h = 0.25
    end
end

-- cada key.dn de seta é um passo; mais carga, passo menor
function Pinguim:evento (e)
    if self.tonto or e.tag ~= 'key.dn' then return end
    local fator = ((CARGA_MAXIMA + 1) - self.carga) / (CARGA_MAXIMA + 1)
    local vel
    if e.key == 'Right' then vel = 10 * fator
    elseif e.key == 'Left' then vel = -10 * fator
    else return end
    local x = self.rect.x + (vel * (1/60))
    x = math.min(math.max(x, 0.25), 0.8)
    self.rect.x = x
    self.hitbox.x = x
end

function Pinguim:desenha ()
    pico.output.draw.image(self.img, self.rect)
end

return Pinguim
