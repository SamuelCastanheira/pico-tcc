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

while not jogo.fim do
    local e, ms = pico.input.event()
    jogo:tempo(ms * 1000)                   -- microssegundos
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
