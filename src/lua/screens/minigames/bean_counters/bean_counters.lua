-- Bean Counters: o caminhão lança cargas; o pinguim pega os sacos de café e
-- os entrega na plataforma. Pegar vale 2 pontos, entregar vale 3. Acaba
-- 0,5 s depois de as duas pilhas encherem ou de as vidas acabarem, e o
-- placar vira moedas.
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")
local Pinguim = require("screens.minigames.bean_counters.pinguim")
local Carga = require("screens.minigames.bean_counters.carga")
local Plataforma = require("screens.minigames.bean_counters.plataforma")

local BASE = "../../assets/imgs/bean_counters/"

local BeanCounters = Objeto:extend()

function BeanCounters:init ()
    pico.set.window{title="Bean Counters"}
    self.fundo    = {'%', x=0.5, y=0.5, w=1, h=1}
    self.caminhao = {'%', x=1, y=1, w=0.20, h=0.85, anchor='SE'}
    self.neve     = {'%', x=0.5, y=1, w=1, h=0.4, anchor='S'}
    self.plataforma = Plataforma:new({'%', x=0.13, y=0.86, w=0.30, h=0.15}, BASE.."plataforma.png")
    self.cargas = {}
    self.pinguim = Pinguim:new(self)
    self.placar = 0
    self.lancamento = Temporizador:new(0.5 * Temporizador.S)   -- próxima carga
    self.fim = nil
end

-- avisos do pinguim ---------------------------------------------------------

function BeanCounters:ao_coletar ()
    self.placar = self.placar + 2
end

function BeanCounters:ao_entregar ()
    self.plataforma:recebe()
    self.placar = self.placar + 3
    if self.plataforma:cheia() then self:acaba() end
end

function BeanCounters:ao_ser_atingido ()
    self.lancamento = Temporizador:new(2 * Temporizador.S)    -- o caminhão para 2 s
    if self.pinguim.vidas == 0 then self:acaba() end
end

function BeanCounters:acaba ()
    if not self.fim then
        self.fim = Temporizador:new(0.5 * Temporizador.S)
    end
end

-------------------------------------------------------------------------------

function BeanCounters:lanca ()
    self.cargas[#self.cargas + 1] = Carga:new()
    self.lancamento = Temporizador:new((0.2 + (math.random() * 0.8)) * Temporizador.S)
end

local function tira_mortas (cargas)
    for i = #cargas, 1, -1 do
        if not cargas[i].viva then table.remove(cargas, i) end
    end
end

-- devolve o placar quando o jogo acaba. A ordem dos passos é a da versão
-- Atmos; prazos criados durante o passo só contam a partir do próximo.
function BeanCounters:tempo (dt)
    local lancamento, fim = self.lancamento, self.fim
    self.plataforma:tempo(dt)
    for _, c in ipairs(self.cargas) do
        c:tempo(dt)
    end
    tira_mortas(self.cargas)
    self.pinguim:tempo(dt, self.cargas, self.plataforma)
    tira_mortas(self.cargas)
    if lancamento == self.lancamento and lancamento:tempo(dt) then
        self:lanca()
    end
    if fim and fim:tempo(dt) then
        return self.placar
    end
    return nil
end

function BeanCounters:evento (e)
    self.pinguim:evento(e)
    return nil
end

function BeanCounters:desenha ()
    pico.output.draw.image(BASE.."background.png", self.fundo)
    pico.output.draw.image(BASE.."trucker.png", self.caminhao)
    pico.output.draw.image(BASE.."neve.png", self.neve)
    self.plataforma:desenha()
    for _, c in ipairs(self.cargas) do
        c:desenha()
    end
    self.pinguim:desenha()
    local placar = string.format("%s: %d", "Score", self.placar)
    local vidas = string.format("%s: %d", "Vidas", self.pinguim.vidas)
    pico.output.draw.text.dyn("score", placar, {'%', x=0.02, y=0.02, w=0.008*#placar, h=0.05, anchor='NW'})
    pico.output.draw.text.dyn("life", vidas, {'%', x=0.02, y=0.06, w=0.008*#vidas, h=0.05, anchor='NW'})
end

return BeanCounters
