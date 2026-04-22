-- Importa módulos de tela (como no seu código, mas adicionando dojo)
local screens = {
    menu = require("screens.menu"),
    person = require("screens.personalizacao"),
    centro = require("screens.centro"),
    pega_puffle = require("screens.minigames.pega_puffle"),
    dojo = require("screens.minigames.dojo"),
    bean_counters = require("screens.minigames.bean_counters")
}

-- Estado global compartilhado (novo, para evitar globais)
local gameState = {
    screen = "menu",  -- tela inicial
    money = 0,      -- exemplo, baseado no seu dojo
    nextScreen = nil, -- sinal para trocar tela
}

-- Inicializações do seu código original
pico.init(true)
local phy = {'!', w=1280, h=720}
pico.set.view{grid=false}
pico.set.dim(phy)
pico.set.expert(true, 60)

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