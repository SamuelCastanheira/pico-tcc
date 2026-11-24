-- Ilha Geladeira, versão Lua: laço de jogo com objetos.
--
-- A cada quadro: o relógio avança (tempo), depois chega o evento de entrada,
-- se houver (evento), e então tudo é desenhado. É a mesma ordem do ambiente
-- atmos.env.pico da versão Atmos.
-- roda com "lua main.lua" ou "pico-lua main.lua" (que já carrega o pico)
pico = pico or require("pico")

local Jogo = require("jogo")

pico.init(true)
pico.set.window{title="Ilha da Geladeira"}
pico.set.effect{grid=false}
pico.set.dim{'!', w=1280, h=720}
pico.set.expert(true, 60)
math.randomseed()

local jogo = Jogo:new()

-- o tempo de cada passo é o tempo real entre os passos: o ms devolvido por
-- pico.input.event conta só a espera, sem o tempo gasto no quadro
local antes = pico.get.now()

while not jogo.fim do
    local e = pico.input.event()
    local agora = pico.get.now()
    jogo:tempo((agora - antes) * 1000)      -- microssegundos
    antes = agora
    if e then
        if e.tag == 'quit' then break end
        jogo:evento(e)
    end
    if jogo.fim then break end
    pico.output.clear()
    jogo:desenha()
    pico.output.present()
end

pico.init(false)
