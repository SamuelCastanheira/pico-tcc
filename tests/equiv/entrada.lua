-- Ponto de entrada de teste da versão Lua: o mesmo laço do main.lua, mas
-- começando na tela EQ_TELA (menu, person, centro, pega_puffle, dojo,
-- bean_counters). Quando essa tela termina, o teste termina
-- (FIM <resultado> moedas=<n>), para comparar cada tela isoladamente.
local Objeto = require("util.objeto")

local CLASSES = {
    menu          = "screens.telas_menu.menu",
    person        = "screens.telas_menu.personalizacao",
    centro        = "screens.centro.centro",
    dojo          = "screens.minigames.dojo.dojo",
    bean_counters = "screens.minigames.bean_counters.bean_counters",
    pega_puffle   = "screens.minigames.pega_puffles.pega_puffles",
}

-- faz o papel do Jogo: guarda moedas e cor, e encerra quando a tela termina
local JogoTeste = Objeto:extend()
function JogoTeste:init ()
    self.moedas = 0
    self.cor_pinguim = "amarelo"
    self.fim = false
end
function JogoTeste:termina (res)
    self.fim = true
    EQ_RESULTADO = string.format("%s moedas=%s", tostring(res), tostring(self.moedas))
end
function JogoTeste:menu_escolheu (op) self:termina(op) end
function JogoTeste:volta_menu () self:termina(nil) end
function JogoTeste:ganha_moedas (n) self.moedas = self.moedas + n end
function JogoTeste:escolhe_cor (c) self.cor_pinguim = c end

pico.init(true)
pico.set.window{title="Ilha da Geladeira"}
pico.set.effect{grid=false}
pico.set.dim{'!', w=1280, h=720}
pico.set.expert(true, 60)
math.randomseed()

local jogo = JogoTeste:new()
local tela = require(assert(CLASSES[os.getenv("EQ_TELA")], "EQ_TELA invalida")):new(jogo)

-- os minigames devolvem as moedas ganhas por tempo() ou evento() quando terminam
while not jogo.fim do
    local e, ms = pico.input.event()
    local r = tela:tempo(ms * 1000)
    if r ~= nil then jogo:termina(r) break end
    if e then
        if e.tag == 'quit' then break end
        r = tela:evento(e)
        if r ~= nil then jogo:termina(r) break end
    end
    if jogo.fim then break end
    pico.output.clear()
    tela:desenha()
    pico.output.present()
end
pico.init(false)
