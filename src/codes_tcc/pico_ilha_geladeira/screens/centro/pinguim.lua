local Vetor = require("util.vetor")
local Objeto = require("util.objeto")


local direcoes = {
    LESTE = 0,
    SUDESTE = 1,
    SUL = 2,
    SUDOESTE = 3,
    OESTE = 4,
    NOROESTE = 5,
    NORTE = 6,
    NORDESTE = 7
}

local angulos = {
    "090", -- 0 = LESTE
    "045", -- 1 = SUDESTE
    "000", -- 2 = SUL
    "315", -- 3 = SUDOESTE
    "270", -- 4 = OESTE
    "225", -- 5 = NOROESTE
    "180", -- 6 = NORTE
    "135", -- 7 = NORDESTE
}

local Pinguim = {}
Pinguim.__index = Pinguim

-- Herança: Movable herda de Objeto
setmetatable(Pinguim, {__index = Objeto})

function Pinguim.new(opts)
    opts = opts or {}
    local self = Objeto.create(opts) 
    self.cor = opts.cor or "amarelo"
    self.direcao = angulos[direcoes.SUL + 1]
    self.velocidade = Vetor.new({x=0, y=0})
    self.destino = {x=opts.rect.x, y=opts.rect.y}
    setmetatable(self, Pinguim)
    return self
end

function Pinguim:get_img()
    local base = "../../../assets/imgs/pinguim"
    self:get_direcao()
    self.img = string.format("%s/%s/%s.png", base, self.cor, self.direcao)
    return self.img
end



function Pinguim:get_direcao()
    if self.velocidade:magnitude() == 0 then
        return
    end

    local ang = self.velocidade:angle()

    local setor = math.floor((ang + math.pi/8) / (math.pi/4)) % 8
    print(setor)
    self.direcao = angulos[setor + 1]
end

function Pinguim:atualiza_posicao(dt)
    self.rect.x = self.rect.x + self.velocidade.x * dt
    self.rect.y = self.rect.y + self.velocidade.y * dt
end

function Pinguim:calcula_movimento(ponto)

    local delta = Vetor.new({x= ponto.x - self.rect.x,
                             y= ponto.y - self.rect.y})

    self.destino = ponto
    self.velocidade = delta:normalize():multiply(0.2)
end

function Pinguim:chegou_destino()
    local delta = Vetor.new({x= self.rect.x - self.destino.x,
                             y= self.rect.y - self.destino.y})
    if delta:magnitude() < 0.01 then
        self.destino = self.rect
        self.velocidade = Vetor.new({x=0, y=0})
        return true
    end
    return false
end

return Pinguim