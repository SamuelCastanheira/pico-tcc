local Vetor = require("util.vetor")
local Objeto = require("util.objeto")

local Pinguim = {}
Pinguim.__index = Pinguim

-- Herança: Movable herda de Objeto
setmetatable(Pinguim, {__index = Objeto})

local imgs = 
{
    {key = "bigorna", path = "_anvil"},
    {key = "flores", path = "_pot"},
    {key = "peixe", path = "_fish"},
    {key = "cafe0", path = "0"},
    {key = "cafe1", path = "1"},
    {key = "cafe2", path = "2"},
    {key = "cafe3", path = "3"},
    {key = "cafe4", path = "4"},
    {key = "cafe5", path = "5"},
    {key = "cafe6", path = "6"},
}

function Pinguim.new(opts)
    opts = opts or {}
    local self = Objeto.create(opts) 

    self.velocidade = 0.05
    self.destino = {x=opts.rect.x, y=opts.rect.y}
    self.vidas = 3
    self.cargas = 0
    self.carga_maxima = 5
    self.score = 0
    self.derrubado = false
    self.cooldown = 0
    self.duracao_colldown = 2000
    self.img = imgs[4].path
    
    setmetatable(self, Pinguim)
    return self
end

function Pinguim:get_img()
    local base = "../../../assets/imgs/bean_counters/"
    return string.format("%s/penguin%s.webp", base, self.img)
    
end

function Pinguim:calcula_posicao(dt)
    return  self.rect.x + self.velocidade*(self.carga_maxima - self.cargas)/self.carga_maxima * dt
end


function Pinguim:valida_posicao(x)
    self.rect.x = x
end


function Pinguim:chegou_destino()
   
end

function Pinguim:colidou_carga(carga)
    if pico.vs.rect_rect(self.rect, carga.rect) then
        return true
    end
    return false
end

function Pinguim:troca_img(carga)
    if not carga then self.img = imgs[4 + self.cargas].path return end
    if carga.tipo.key == "cafe" then
        self.img = imgs[4 + self.cargas].path
    else 
        if carga.tipo.key == "bigorna" then
            self.img = imgs[1].path
        elseif carga.tipo.key == "flores" then
            self.img = imgs[2].path
        elseif carga.tipo.key == "peixe" then
            self.img = imgs[3].path
        elseif carga.tipo.key == "cafe" then
            self.img = imgs[4 + self.cargas].path
     
        end
    end
    if self.cargas >= 6 or carga.tipo.key ~= "cafe" then
        print(self.cargas)
        self.rect.w = 0.12
        self.rect.h = 0.15
        self.derrubado = true
    end
end

function Pinguim:atualiza_cooldown(dt)
    if not self.derrubado then return true end
    self.cooldown = self.cooldown + dt*1000
    if self.cooldown >= self.duracao_colldown then
        self.derrubado = false
        self.cargas = 0
        self.img = imgs[4].path
        self.cooldown = 0
        self.rect.w = 0.12
        self.rect.h = 0.25
        return true
    end
    return false
end

return Pinguim