-- Pega Puffles: o mouse espanta os puffles para dentro do cercado. Acaba
-- quando todos os que restam estão no cercado (ou nenhum resta) ou em 100 s;
-- cada capturado vale 10 moedas.
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")
local Puffle = require("screens.minigames.pega_puffles.puffle")

local IMGS = "../../../assets/imgs/puffle_roundup/"
local CORES = { "amarelo", "azul", "branco", "vermelho", "verde",
                "laranja", "rosa", "roxo", "preto", "marrom" }

local PegaPuffles = Objeto:extend()

function PegaPuffles:init ()
    self.fundo = {'%', x=0.5, y=0.5, w=1, h=1}
    self.cercado = {'%', x=0.5, y=0.65, w=0.15, h=0.25}
    self.paredes = {        -- esquerda, direita, baixo (ordem fixa)
        {'%', x=0.43, y=0.65, w=0.02, h=0.3, anchor='C'},
        {'%', x=0.58, y=0.65, w=0.02, h=0.3, anchor='C'},
        {'%', x=0.5, y=0.8, w=0.15, h=0.02, anchor='C'},
    }
    self.puffles = {}
    for _, cor in ipairs(CORES) do
        local x = math.random(5, 90) / 100
        local y = math.random(10, 50) / 100
        self.puffles[#self.puffles + 1] = Puffle:new(IMGS.."puffle_"..cor..".png", x, y)
    end
    self.relogio = Temporizador:new(100 * Temporizador.S)
    self.capturados = 0
    self.fugiram = 0
end

-- cada quadro em duas fases: todos calculam a direção, depois todos andam.
-- Devolve as moedas quando o jogo acaba.
function PegaPuffles:tempo (dt)
    self.relogio:tempo(dt)
    local mouse = pico.get.mouse('%')
    for _, p in ipairs(self.puffles) do
        p:calcula_direcao(mouse, self.puffles, self.paredes)
    end
    for _, p in ipairs(self.puffles) do
        p:anda()
        if p.fugiu then self.fugiram = self.fugiram + 1 end
    end
    for i = #self.puffles, 1, -1 do
        if self.puffles[i].fugiu then table.remove(self.puffles, i) end
    end

    self.capturados = 0
    for _, p in ipairs(self.puffles) do
        if p:dentro(self.cercado) then self.capturados = self.capturados + 1 end
    end
    if self.capturados == #self.puffles or self.relogio:acabou() then
        return self.capturados * 10
    end
    return nil
end

function PegaPuffles:desenha ()
    pico.output.draw.image(IMGS.."background.png", self.fundo)
    for _, p in ipairs(self.puffles) do
        p:desenha()
    end
    pico.output.draw.image(IMGS.."arvores.png", self.fundo)
    pico.set.pencil{color='yellow'}
    local cap = string.format("%s: %d", "Capturados", self.capturados)
    local fug = string.format("%s: %d", "Fugiram", self.fugiram)
    local seg = string.format("%s: %d", "Timer", math.floor(self.relogio:restante() / Temporizador.S))
    pico.output.draw.text.dyn("puf.caps", cap, {'%', x=0.02, y=0.02, w=0.008*#cap, h=0.05, anchor='NW'})
    pico.output.draw.text.dyn("puf.fugs", fug, {'%', x=0.02, y=0.06, w=0.008*#fug, h=0.05, anchor='NW'})
    pico.output.draw.text.dyn("puf.timer", seg, {'%', x=0.9, y=0.02, w=0.008*#seg, h=0.1, anchor='NW'})
end

return PegaPuffles
