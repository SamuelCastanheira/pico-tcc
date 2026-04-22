local Vetor = require("util.vetor")
local Objeto = require("util.objeto")

local Puffle = {}
Puffle.__index = Puffle

-- Herança: Movable herda de Objeto
setmetatable(Puffle, {__index = Objeto})

function Puffle.create(opts)
    opts = opts or {}

    local self = Objeto.create(opts)
    setmetatable(self, Puffle)

    self.em_fuga = false
    self.tempo_fuga = 0
    self.dentro_cercado = false
    self.direcao = Vetor.new({x=0, y=0})
    self.velocidade = opts.velocidade or Vetor.new{ x = 0, y = 0 }

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

function Puffle:calcula_velocidade_vetorial(destino, velocidade_escalar)
    velocidade_escalar = velocidade_escalar or 0.1
    
    if destino:magnitude() > 0 then
        self.velocidade = destino:normalize(velocidade_escalar):multiply(velocidade_escalar)
        self.fugindo_jogador = true
    else
        self:limpar_movimento()
    end
    return self
end

return Puffle