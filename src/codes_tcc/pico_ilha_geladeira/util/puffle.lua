local Movable = require("util.movable")
local Vetor = require("util.vetor")

local Puffle = {}
Puffle.__index = Puffle

-- Herança: Puffle herda de Movable
setmetatable(Puffle, {__index = Movable})

function Puffle.create(opts)
    opts = opts or {}

    local self = Movable.create(opts)
    setmetatable(self, Puffle)

    self.em_fuga = false
    self.tempo_fuga = 0
    self.dentro_cercado = false
    
    self.hitbox = opts.hitbox or {
        x = self.rect.x,
        y = self.rect.y,
        w = 0.02,
        h = 0.02
    }

    return self
end

function Puffle.lista()
    local puffles = {}
    local puffle_paths = {
        "../../../assets/imgs/puffle_roundup/puffle_amarelo.png",
        "../../../assets/imgs/puffle_roundup/puffle_azul.png",
        "../../../assets/imgs/puffle_roundup/puffle_branco.png",
        "../../../assets/imgs/puffle_roundup/puffle_vermelho.png",
        "../../../assets/imgs/puffle_roundup/puffle_verde.png",
        "../../../assets/imgs/puffle_roundup/puffle_laranja.png",
        "../../../assets/imgs/puffle_roundup/puffle_rosa.png",
        "../../../assets/imgs/puffle_roundup/puffle_roxo.png",
        "../../../assets/imgs/puffle_roundup/puffle_preto.png",
        "../../../assets/imgs/puffle_roundup/puffle_marrom.png"
    }

    for i = 1, #puffle_paths do
        local x_rect = math.random(30, 70) / 100
        local y_rect = math.random(10, 40) / 100

        puffles[i] = Puffle.create({
            img = puffle_paths[i],

            rect = {   
                '%', 
                x= x_rect,
                y= y_rect,
                w=0.05, 
                h=0.05
            },

            hitbox = {   
                '%', 
                x= x_rect,
                y= y_rect,
                w=0.02, 
                h=0.02
            }
        })
    end
    return puffles
end

function Puffle:atualizar_posicao(dt)
    self.rect.x = self.rect.x + self.velocidade.x * dt
    self.rect.y = self.rect.y + self.velocidade.y * dt
    self.hitbox.x = self.hitbox.x + self.velocidade.x * dt
    self.hitbox.y = self.hitbox.y + self.velocidade.y * dt
    return self
end

function Puffle:parar()
    self.velocidade = Vetor.new({x=0, y=0})
    return self
end

function Puffle:limpar_movimento()
    self:parar()
    self.em_fuga = false
    self.fugindo_jogador = false
    self.tempo_fuga = 0
    return self
end

function Puffle:calcula_velocidade_vetorial(destino, velocidade_escalar)
    velocidade_escalar = velocidade_escalar or 0.1
    
    local delta = Vetor.new({x=destino.x - self.rect.x, y= destino.y - self.rect.y})

    if delta:magnitude() > 0 then
        self.velocidade = delta:normalize(velocidade_escalar):multiply(velocidade_escalar)
        self.fugindo_jogador = true
    else
        self:parar()
    end
    return self
end

function Puffle:ativar_fuga(destino, velocidade_escalar, duracao)
    velocidade_escalar = velocidade_escalar or 0.1
    duracao = duracao or 0.4
    self.em_fuga = true
    self.tempo_fuga = duracao
    self:calcula_velocidade_vetorial(destino,velocidade_escalar)
    
    return self
end

function Puffle:atualizar_fuga(dt, ativo)
    if not self.em_fuga then return false end
    
    self.tempo_fuga = self.tempo_fuga - dt
    
    if self.tempo_fuga <= 0 or ativo then
        self.em_fuga = false
        self:parar()
        return true
    end
    
    return false
end

function Puffle:colidir_com(outro)
    local influencia = 0.5

    -- direção entre eles
    local dx = outro.rect.x - self.rect.x
    local dy = outro.rect.y - self.rect.y

    local direcao = Vetor.new({x = dx, y = dy})

    if direcao:magnitude() > 0 then
        direcao = direcao:normalized()

        -- mistura + empurra na direção certa
        local nova_vel = outro.velocidade:copy()
            :add(self.velocidade)
            :multiply(influencia)
        self:atualizar_fuga(0.05, true)
        outro.velocidade = nova_vel:add(direcao:multiply(0.2))
    end
end

function Puffle:clamp_cercado(cercado)
    if pico.vs.pos_rect(self.rect, cercado) then
        -- força voltar pra dentro (versão simples)
        self.rect.x = math.max(0.45, math.min(0.58, self.rect.x))
        self.rect.y = math.max(0.1, math.min(0.7, self.rect.y))
    end
end

return Puffle