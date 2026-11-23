-- Temporizador que conta o tempo do jogo (os dt recebidos em tempo()), e não
-- o relógio real. Começa a contar no primeiro tempo() depois de criado.
-- Tempos em microssegundos, como o relógio do Atmos (1 s = 1000000).
local Objeto = require("util.objeto")

local Temporizador = Objeto:extend()

Temporizador.S  = 1000000
Temporizador.MS = 1000

function Temporizador:init (duracao)
    self.duracao = duracao
    self.decorrido = 0
end

-- avança e diz se o prazo acabou
function Temporizador:tempo (dt)
    self.decorrido = self.decorrido + dt
    return self:acabou()
end

function Temporizador:acabou ()
    return self.decorrido >= self.duracao
end

function Temporizador:restante ()
    return math.max(0, self.duracao - self.decorrido)
end

return Temporizador
