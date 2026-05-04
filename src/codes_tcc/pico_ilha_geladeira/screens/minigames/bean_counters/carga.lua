local Vetor = require("util.vetor")
local Objeto = require("util.objeto")

local tipos = 
{
    {key = "bigorna", path = "Anvil"},
    {key = "flores", path = "Flower_pot"},
    {key = "cafe",  path = "Coffe_bag"},
    {key = "peixe", path = "Fish_bean_counters"}
}

local Carga = {}
Carga.__index = Carga

Carga.spawn_timer = 0 
Carga.spawn_interval = 0.25

-- Herança: Movable herda de Objeto
setmetatable(Carga, {__index = Objeto})

function Carga.new(opts)
    opts = opts or {}
    local self = Objeto.create(opts) 

    self.p_lancamento = nil
    self.tempo = 0
    self.velocidade_inicial = nil
    self.destino  = nil
    self.gravidadade = nil
    self.tipo = tipos[math.random(1,4)]
    self.rect = nil
    
    setmetatable(self, Carga)
    return self
end

function Carga:get_img()
    local base = "../../../assets/imgs/bean_counters"
    self.img = string.format("%s/%s.webp", base, self.tipo.path)
    return self.img
end

function Carga.lanca_carga()
    

    return nil
end

function Carga.lanca_carga(dt)
    -- atualiza o tempo acumulado
    Carga.spawn_timer = Carga.spawn_timer + dt
    
    -- verifica se pode spawnar
    if Carga.spawn_timer >= Carga.spawn_interval then
        Carga.spawn_timer = 0
        Carga.spawn_interval = 0.2 + math.random() * 0.8  -- entre 0.2s e 2.5s
        print(Carga.spawn_interval)
        return Carga.new()
    end

    return nil
end

function Carga.table_add(tabela, carga)
    if not tabela or not carga then return end
    carga:inicializacao()
    table.insert(tabela, carga)
end

function Carga.table_remove(tabela, carga)
    if not tabela or not carga then return end

    for i, v in ipairs(tabela) do
        if v == carga then
            table.remove(tabela, i)
            return true
        end
    end

    return false
end

function Carga:inicializacao()
    local g = 9.8

    local lim_e = 0.25
    local lim_d = 0.75

    local y0 = 0.5
    local yf = 0.9
    
    local x0 = 0.85
    local xf = math.random() * (lim_d - lim_e) + lim_e

    local min = math.pi/4      -- 45°
    local max = math.pi/3      -- 60°
    local angle = math.pi - 0.2

    local dx = xf - x0
    local dy = -(yf - y0)

    if dx >= 0 then
        angle = math.random() * (max - min) + min
    else
        angle = math.random() * (math.pi - max - (math.pi - min)) + (math.pi - max)
    end

    local cos = math.cos(angle)
    local tan = math.tan(angle)

    local denom = 2 * (cos * cos) * (dx * tan - dy)

    -- evita divisão por zero / ângulo inválido
    if denom <= 0 then
        return self:inicializacao() -- tenta de novo
    end

    local v0 = math.sqrt((g * dx * dx) / denom)

    -- componentes da velocidade
    local vx = v0 * cos
    local vy = -v0 * math.sin(angle)

    local h_max = y0 + (vy * vy) / (2 * g)
    local LIMITE_ALTURA = 0.95  -- escolhe o máximo que quiser

    if h_max > LIMITE_ALTURA then
        return self:inicializacao() -- sorteia outro
    end

    self.p_lancamento = {x=x0, y=y0}
    self.destino = {x=xf, y= yf}
    self.velocidade_inicial = Vetor.new({x = vx, y = vy})
    self.rect = {'%', x=x0 ,y=y0 ,w=0.07, h=0.07}
    self.gravidade = g
end

function Carga:atualiza_posicao(dt)
    -- atualiza velocidade (gravidade)
    self.tempo = self.tempo + dt

    -- atualiza posição
    self.rect.x = self.p_lancamento.x + self.velocidade_inicial.x * self.tempo
    self.rect.y = self.p_lancamento.y + self.velocidade_inicial.y * self.tempo + self.gravidade*math.pow(self.tempo,2)/2
end

function Carga:chegou_destino()
    
    if self.rect.y > self.destino.y then
        return true
    end
    return false
end

return Carga