-- Importa módulos de tela (como no seu código, mas adicionando dojo)
local screens = {
    menu = require("screens.telas_menu.menu"),
    person = require("screens.telas_menu.personalizacao"),
    centro = require("screens.centro.centro"),
    pega_puffle = require("screens.minigames.pega_puffles.pega_puffles"),
    dojo = require("screens.minigames.dojo.dojo"),
    bean_counters = require("screens.minigames.bean_counters.bean_counters")
}

-- Estado global compartilhado (novo, para evitar globais)
local gameState = {
    screen = "menu",  -- tela inicial
    money = 0,      -- exemplo, baseado no seu dojo
    nextScreen = nil, -- sinal para trocar tela
    frames = 60
}

-- Inicializações do seu código original
pico.init(true)
local phy = {'!', w=1280, h=720}
pico.set.view{grid=false}
pico.set.dim(phy)
pico.set.expert(true, gameState.frames)

-- Inicializa a tela atual
local current = screens[gameState.screen]
current.init(gameState)

-- Loop principal (substitui o "Menu.renderizar()" que cria pilha)
while true do
    -- Polla eventos
    local event =  pico.input.event()
    if event and event.tag == 'quit' then
         break 
    end
    -- Atualiza a tela atual
    current.update(gameState, event)
    
    -- Limpa e desenha
    pico.output.clear()
    current.draw(gameState)
    pico.output.present()
    
    -- Verifica transição de tela
    if gameState.nextScreen then
        current.finish(gameState)
        gameState.screen = gameState.nextScreen
        gameState.nextScreen = nil
        current = screens[gameState.screen]
        current.init(gameState)
    end
end

-- Finaliza (raramente alcançado)
pico.init(false)