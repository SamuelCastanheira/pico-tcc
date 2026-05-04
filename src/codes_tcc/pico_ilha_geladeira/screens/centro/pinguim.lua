local Vetor = require("util.vetor")
local Objeto = require("util.objeto")

local direcoes = 
{
    SUL = "000",
    SUDESTE = "045",
    LESTE = "090",
    NORDESTE = "135",
    NORTE = "180",
    NOROESTE = "225" ,
    OESTE = "270",
    SUDOESTE = "315"
}

local Pinguim = {}
Pinguim.__index = Pinguim

-- Herança: Movable herda de Objeto
setmetatable(Pinguim, {__index = Objeto})

function Pinguim.new(opts)
    opts = opts or {}
    local self = Objeto.create(opts) 
    self.cor = opts.cor or "amarelo"
    self.direcao = direcoes.SUL
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
    if self.velocidade:magnitude() == 0 then return end

    local ang = self.velocidade:angle()

    if ang >= 3*math.pi/8 and ang < 5*math.pi/8 then
        self.direcao = direcoes.SUL

    elseif ang >= math.pi/8 and ang < 3*math.pi/8 then
        self.direcao = direcoes.SUDESTE

    elseif ang >= -math.pi/8 and ang < math.pi/8 then 
        self.direcao = direcoes.LESTE

    elseif ang >= -3*math.pi/8 and ang < -math.pi/8 then
        self.direcao = direcoes.NORDESTE

    elseif ang >= -5*math.pi/8 and ang < -3*math.pi/8 then
        self.direcao = direcoes.NORTE
    
    elseif ang >= -7*math.pi/8 and ang < -5*math.pi/8 then
        self.direcao = direcoes.NOROESTE

    elseif ang >= 7*math.pi/8 or ang < -7*math.pi/8 then
        self.direcao = direcoes.OESTE

    elseif ang >= 5*math.pi/8 and ang < 7*math.pi/8 then
        self.direcao = direcoes.SUDOESTE
    end
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