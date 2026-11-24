-- Pinguim do centro: anda até o ponto clicado; quando um prédio é clicado,
-- ele vira o destino, e o pinguim entra nele ao encostar na sua hitbox.
local Objeto = require("util.objeto")

local VELOCIDADE = 0.2      -- fração da tela por segundo
local CHEGOU = 0.01         -- distância em que o pinguim para no ponto

-- cores que têm sprites do centro (assets/imgs/pinguim); as outras usam o amarelo
local COM_SPRITE = {
    amarelo=true, azul_forte=true, azul_fraco=true, cinza=true, laranja=true,
    marrom=true, preto=true, rosa_medio=true, roxo=true, verde_forte=true,
    verde_medio=true, verde_vomito=true,
}

local Pinguim = Objeto:extend()

function Pinguim:init (jogo, predios)
    self.jogo = jogo
    self.predios = predios
    self.rect = {'%', x=0.5, y=0.7, w=0.08, h=0.2}
    self.hitbox = {'%', x=0.5, y=0.7, w=0.08, h=0.1}
    self.vel = {x=0, y=0}
    self.ponto = nil        -- ponto para onde está andando (nil: parado)
    self.destino = false    -- id do prédio escolhido
end

function Pinguim:escolhe_destino (id)
    self.destino = id
end

-- devolve o id do prédio quando o pinguim chega nele
function Pinguim:tempo (dt)
    for _, p in ipairs(self.predios) do
        if p:colide(self.hitbox) and p.id == self.destino then
            return self.destino
        end
    end
    if self.ponto then
        local s = dt / 1000000
        if self:distancia(self.ponto) <= (VELOCIDADE * s) then
            -- o passo que alcança o ponto para nele (não passa)
            self.rect.x, self.rect.y = self.ponto.x, self.ponto.y
        else
            self.rect.x = self.rect.x + (self.vel.x * s)
            self.rect.y = self.rect.y + (self.vel.y * s)
        end
        self.hitbox.x = self.rect.x
        self.hitbox.y = self.rect.y
        if self:distancia(self.ponto) <= CHEGOU then
            self.ponto = nil
        end
    end
    return nil
end

function Pinguim:distancia (p)
    local dx, dy = p.x - self.rect.x, p.y - self.rect.y
    return math.sqrt((dx * dx) + (dy * dy))
end

-- cada clique dá um novo ponto e uma nova direção
function Pinguim:evento (e)
    if e.tag ~= 'mouse.button.dn' then return end
    local ponto = pico.get.mouse('%')
    local dx, dy = ponto.x - self.rect.x, ponto.y - self.rect.y
    local mag = math.sqrt((dx * dx) + (dy * dy))
    if mag > 0 then
        self.vel = {x = (dx / mag) * VELOCIDADE, y = (dy / mag) * VELOCIDADE}
    else
        self.vel = {x = 0, y = 0}
    end
    if mag <= CHEGOU then
        self.ponto = nil
    else
        self.ponto = ponto
    end
end

-- direção do sprite (0, 45, ..., 315 graus); parado, olha para o sul
function Pinguim:direcao ()
    local setor = 2
    local v = self.vel
    if math.sqrt((v.x * v.x) + (v.y * v.y)) ~= 0 then
        setor = math.floor((math.atan2(v.y, v.x) + (math.pi/8)) / (math.pi/4)) % 8
    end
    return (90 - (setor * 45)) % 360
end

function Pinguim:desenha ()
    local cor = COM_SPRITE[self.jogo.cor_pinguim] and self.jogo.cor_pinguim or "amarelo"
    local img = string.format("../../assets/imgs/pinguim/%s/%03d.png", cor, self:direcao())
    pico.output.draw.image(img, self.rect)
end

return Pinguim
