-- Ponto de entrada de teste da versão Lua: o mesmo laço do main.lua, mas
-- começando na tela EQ_TELA (menu, person, centro, pega_puffle, dojo,
-- bean_counters). Ao sair da tela inicial, o teste termina (FIM <proxima>),
-- para que cada minigame seja comparado isoladamente.
local screens = {
    menu = require("screens.telas_menu.menu"),
    person = require("screens.telas_menu.personalizacao"),
    centro = require("screens.centro.centro"),
    pega_puffle = require("screens.minigames.pega_puffles.pega_puffles"),
    dojo = require("screens.minigames.dojo.dojo"),
    bean_counters = require("screens.minigames.bean_counters.bean_counters")
}

local gameState = { screen = os.getenv("EQ_TELA"), money = 0, nextScreen = nil, frames = 60 }

pico.init(true)
pico.set.effect{grid=false}
pico.set.dim{'!', w=1280, h=720}
pico.set.expert(true, gameState.frames)

local current = assert(screens[gameState.screen], "EQ_TELA invalida")
current.init(gameState)

while true do
    local event = pico.input.event()
    if event and event.tag == 'quit' then break end
    current.update(gameState, event)
    pico.output.clear()
    current.draw(gameState)
    pico.output.present()
    if gameState.nextScreen then
        current.finish(gameState)
        EQ_RESULTADO = string.format("%s moedas=%d", gameState.nextScreen, gameState.money)
        break
    end
end
pico.init(false)
