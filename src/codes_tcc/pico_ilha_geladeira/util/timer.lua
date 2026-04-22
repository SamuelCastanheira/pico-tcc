local Timer = {}
Timer.__index = Timer

-- Cria um novo timer
function Timer.new(duracao)
    local self = setmetatable({}, Timer)
    self.duracao = duracao or 0
    self.inicio = 0
    self.ativo = false
    self.finalizado = false
    return self
end

-- Inicia o timer
function Timer:start()
    self.inicio = pico.get.now()
    self.ativo = true
    self.finalizado = false
end

-- Reinicia
function Timer:reset()
    self:start()
end

-- Para o timer
function Timer:stop()
    self.ativo = false
end

-- Atualiza estado
function Timer:update()
    if not self.ativo then return end

    local tempo_atual = pico.get.now()
    local decorrido = tempo_atual - self.inicio

    if decorrido >= self.duracao then
        self.finalizado = true
        self.ativo = false
    end
end

-- Verifica se terminou
function Timer:isFinished()
    return self.finalizado
end

-- Tempo restante
function Timer:getRestante()
    if not self.ativo then return 0 end

    local tempo_atual = pico.get.now()
    local decorrido = tempo_atual - self.inicio

    return math.max(0, self.duracao - decorrido)
end

-- Progresso (0 a 1)
function Timer:getProgress()
    local tempo_atual = pico.get.now()
    local decorrido = tempo_atual - self.inicio

    return math.min(1, decorrido / self.duracao)
end

return Timer