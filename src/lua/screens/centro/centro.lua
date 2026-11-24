-- Centro: o pinguim anda entre os prédios; ao entrar num prédio, o minigame
-- correspondente roda dentro do centro e, ao terminar, as moedas ganhas vão
-- para o jogo e um novo pinguim aparece na praça. Escape volta ao menu, de
-- qualquer ponto (também durante um minigame).
local Objeto = require("util.objeto")
local Predio = require("screens.centro.predio")
local Pinguim = require("screens.centro.pinguim")

local IMGS = "../../assets/imgs/"

local MINIGAMES = {
    BEAN = "screens.minigames.bean_counters.bean_counters",
    DOJO = "screens.minigames.dojo.dojo",
    PUFF = "screens.minigames.pega_puffles.pega_puffles",
}

local Centro = Objeto:extend()

function Centro:init (jogo)
    self.jogo = jogo
    self.fundo = {'%', x=0.5, y=0.5, w=1, h=1}
    self.moeda = {'%', x=0.05, y=0.05, w=0.05, h=0}
    self.predios = {
        Predio:new("BEAN", {'%', x=0.20, y=0.4, w=0.4, h=0.4},
                   {'%', x=0.20, y=0.4, w=0.21, h=0.21},
                   IMGS.."coffe.png", IMGS.."coffe_hover.png"),
        Predio:new("DOJO", {'%', x=0.72, y=0.39, w=0.35, h=0.35},
                   {'%', x=0.72, y=0.39, w=0.21, h=0.21},
                   IMGS.."dojo/dojo.png", IMGS.."dojo/dojo_hover.png"),
        Predio:new("PUFF", {'%', x=0.5, y=0.4, w=0.35, h=0.35},
                   {'%', x=0.5, y=0.4, w=0.21, h=0.21},
                   IMGS.."pet_shop.png", IMGS.."pet_shop_hover.png"),
    }
    self:novo_pinguim()
end

function Centro:novo_pinguim ()
    pico.set.window{title="Centro"}
    self.minigame = nil
    self.pinguim = Pinguim:new(self.jogo, self.predios)
end

function Centro:inicia_minigame (id)
    self.pinguim = nil
    self.minigame = require(MINIGAMES[id]):new()
end

function Centro:termina_minigame (moedas)
    self.jogo:ganha_moedas(moedas)
    self:novo_pinguim()
end

function Centro:tempo (dt)
    if self.minigame then
        local moedas = self.minigame:tempo(dt)
        if moedas then self:termina_minigame(moedas) end
    else
        local id = self.pinguim:tempo(dt)
        if id then self:inicia_minigame(id) end
    end
end

function Centro:evento (e)
    for _, p in ipairs(self.predios) do
        if p:clicado(e) and self.pinguim then
            self.pinguim:escolhe_destino(p.id)
        end
    end
    if e.tag == 'key.dn' and e.key == 'Escape' then
        self.jogo:volta_menu()
        return
    end
    if self.minigame then
        local moedas = self.minigame:evento(e)
        if moedas then self:termina_minigame(moedas) end
    else
        self.pinguim:evento(e)
    end
end

function Centro:desenha ()
    pico.output.draw.image(IMGS.."centro.png", self.fundo)
    pico.output.draw.image(IMGS.."moeda.png", self.moeda)
    pico.set.pencil{color='yellow'}
    pico.output.draw.text.dyn("moedas", self.jogo.moedas,
        {'%', x=0.08, y=0, w=0.025*#tostring(self.jogo.moedas), h=0.1, anchor='NW'})
    for _, p in ipairs(self.predios) do
        p:desenha()
    end
    if self.minigame then
        self.minigame:desenha()
    else
        self.pinguim:desenha()
    end
end

return Centro
