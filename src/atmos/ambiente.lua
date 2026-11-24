-- Ambiente do jogo para o Atmos: o mesmo que o atmos.env.pico instalado, com
-- uma diferença. O tempo emitido a cada passo é o tempo real entre os passos
-- (pico.get.now), e não o devolvido por pico.input.event, que conta só a
-- espera e deixa de fora o tempo gasto processando o quadro: com isso, quanto
-- mais trabalho por quadro, mais devagar o jogo andava.
local atmos = require "atmos"
local pico  = require "pico"

local M = {
    fps = 60,
    now = 0,
    mode = { primary=true, secondary=true },
}

pico.init(true)
pico.set.expert(true, M.fps)

local antes = pico.get.now()

function M.quit ()
    pico.init(false)
end

function M.step ()
    local e = pico.input.event()
    local agora = pico.get.now()
    M.now = agora
    emit((agora - antes) * 1000)        -- microssegundos
    antes = agora
    if e then
        emit(e)
        if e.tag == 'quit' then
            return true
        end
    end
    pico.output.clear()
    emit('draw')
    pico.output.present()
end

atmos.env(M)

return M
