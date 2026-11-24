-- Puffle: foge do mouse, se afasta dos vizinhos muito próximos e desliza
-- nas paredes do cercado. Se sai do mapa, foge de vez.
local Objeto = require("util.objeto")

local VEL = 0.30            -- fração da tela por segundo
local DIST_MAX = 0.2        -- distância em que o mouse assusta
local VIZINHO = 0.05        -- distância em que dois puffles se empurram

local Puffle = Objeto:extend()

function Puffle:init (img, x, y)
    self.img = img
    self.rect = {'%', x = x, y = y, w = 0.05, h = 0.05}
    self.direcao = {x = 0, y = 0}
    self.fugiu = false
end

local function magnitude (v)
    return math.sqrt((v.x * v.x) + (v.y * v.y))
end

-- foge do mouse quando ele está a até DIST_MAX: a direção é -(mouse - puffle)
function Puffle:fuga_mouse (mouse)
    local delta = {x = mouse.x - self.rect.x, y = mouse.y - self.rect.y}
    local dist = magnitude(delta)
    if dist > 0.001 and dist <= DIST_MAX then
        local destino = {x = mouse.x - (2 * delta.x), y = mouse.y - (2 * delta.y)}
        return {x = destino.x - self.rect.x, y = destino.y - self.rect.y}
    end
    return {x = 0, y = 0}
end

-- normal da parede do lado em que o puffle está
function Puffle:normal_parede (parede)
    local dx, dy = self.rect.x - parede.x, self.rect.y - parede.y
    local overlap_x = ((parede.w / 2) + (self.rect.w / 2)) - math.abs(dx)
    local overlap_y = ((parede.h / 2) + (self.rect.h / 2)) - math.abs(dy)
    if overlap_x < overlap_y then
        return {x = (dx > 0) and 1 or -1, y = 0}
    else
        return {x = 0, y = (dy > 0) and 1 or -1}
    end
end

-- tira a componente que entra na parede e reduz a direção a 10%
function Puffle:desliza (parede, d)
    local normal = self:normal_parede(parede)
    local r = {x = d.x, y = d.y}
    local dot = (r.x * normal.x) + (r.y * normal.y)
    if dot < 0 then
        r.x = r.x - (dot * normal.x)
        r.y = r.y - (dot * normal.y)
    end
    return {x = r.x * 0.1, y = r.y * 0.1}
end

-- fase 1 do quadro: direção com as posições de todos ainda paradas
function Puffle:calcula_direcao (mouse, puffles, paredes)
    local d = self:fuga_mouse(mouse)
    for _, outro in ipairs(puffles) do
        if outro ~= self and not outro.fugiu then
            local delta = {x = outro.rect.x - self.rect.x, y = outro.rect.y - self.rect.y}
            local dist = magnitude(delta)
            if dist < VIZINHO and dist > 0 then
                d = {x = d.x - (delta.x * 0.5), y = d.y - (delta.y * 0.5)}
            end
        end
    end
    for _, parede in ipairs(paredes) do
        if pico.vs.rect.rect(self.rect, parede) then
            d = self:desliza(parede, d)
        end
    end
    self.direcao = d
end

function Puffle:fora_do_mapa ()
    local rx, ry = 1.53 / 2, 0.9 / 2
    local dx, dy = self.rect.x - 0.5, self.rect.y - 0.5
    local valor = ((dx * dx) / (rx * rx)) + ((dy * dy) / (ry * ry))
    return not ((valor <= 1) and (self.rect.x < 1) and (self.rect.x > 0))
end

-- fase 2: foge se já está fora do mapa; senão anda, sem entrar nas paredes
function Puffle:anda (dt, paredes)
    if self:fora_do_mapa() then
        self.fugiu = true
        return
    end
    local d = self.direcao
    local mag = magnitude(d)
    local k = VEL * (dt / 1000000)
    local passo = (mag > 0) and {x = (d.x / mag) * k, y = (d.y / mag) * k} or {x = 0, y = 0}
    for _, parede in ipairs(paredes) do
        local prox = {'%', x = self.rect.x + passo.x, y = self.rect.y + passo.y,
                      w = self.rect.w, h = self.rect.h}
        if pico.vs.rect.rect(prox, parede) then
            local n = self:normal_parede(parede)
            local dot = (passo.x * n.x) + (passo.y * n.y)
            if dot < 0 then
                passo = {x = passo.x - (dot * n.x), y = passo.y - (dot * n.y)}
            end
        end
    end
    self.rect.x = self.rect.x + passo.x
    self.rect.y = self.rect.y + passo.y
end

function Puffle:dentro (cercado)
    return pico.vs.pos.rect(self.rect, cercado)
end

function Puffle:desenha ()
    pico.output.draw.image(self.img, self.rect)
end

return Puffle
