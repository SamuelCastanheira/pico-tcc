local Objeto = require("util.objeto")
local Vetor = require("util.vetor")

local Movable = {}
Movable.__index = Movable

-- Herança: Movable herda de Objeto
setmetatable(Movable, {__index = Objeto})

--- Cria um novo objeto móvel
-- @param rect tabela - retângulo de posição {%, x, y, w, h}
-- @param img string - caminho da imagem padrão
-- @param img_hover string - caminho da imagem ao passar mouse
-- @param velocidade Vetor - velocidade inicial (opcional)
-- @return Movable novo objeto móvel
function Movable.create(rect, img, img_hover, velocidade)
    local self = {
        rect = rect,
        img = img,
        img_hover = img_hover,
        hover = false,
        velocidade = velocidade or Vetor.new(0, 0),
        get_img = function(self)
            return self.hover and self.img_hover or self.img
        end
    }
    
    setmetatable(self, Movable)
    return self
end

--- Obtém a magnitude da velocidade
-- @return number magnitude da velocidade
function Movable:get_velocidade_magnitude()
    return self.velocidade:magnitude()
end

--- Para o movimento zerando a velocidade
-- @return Movable self para encadeamento
function Movable:parar()
    self.velocidade = Vetor.new(0, 0)
    return self
end

--- Define a velocidade do objeto
-- @param vx number - componente x da velocidade
-- @param vy number - componente y da velocidade
-- @return Movable self para encadeamento
function Movable:set_velocidade(vx, vy)
    self.velocidade = Vetor.new(vx, vy)
    return self
end

--- Define a velocidade a partir de um vetor
-- @param vel Vetor - vetor de velocidade
-- @return Movable self para encadeamento
function Movable:set_velocidade_vetor(vel)
    self.velocidade = vel:copy()
    return self
end

--- Atualiza a posição baseado na velocidade
-- @param dt number - delta time (tempo decorrido)
-- @return Movable self para encadeamento
function Movable:atualizar_posicao(dt)
    self.rect.x = self.rect.x + self.velocidade.x * dt
    self.rect.y = self.rect.y + self.velocidade.y * dt
    return self
end

--- Limita a magnitude da velocidade
-- @param max_vel number - velocidade máxima
-- @return Movable self para encadeamento
function Movable:limitar_velocidade(max_vel)
    self.velocidade:clamp(max_vel)
    return self
end

--- Desacelera o objeto multiplicando a velocidade por um fator
-- @param fator number - fator de desaceleração (0 a 1)
-- @return Movable self para encadeamento
function Movable:desacelerar(fator)
    self.velocidade:multiply(fator)
    return self
end

--- Adiciona uma força (aceleração) ao objeto
-- @param fx number - força em x
-- @param fy number - força em y
-- @return Movable self para encadeamento
function Movable:aplicar_forca(fx, fy)
    self.velocidade:add(Vetor.new(fx, fy))
    return self
end

--- Adiciona uma força vetorial ao objeto
-- @param forca Vetor - vetor de força
-- @return Movable self para encadeamento
function Movable:aplicar_forca_vetor(forca)
    self.velocidade:add(forca)
    return self
end

--- Ricocheia a velocidade em relação a uma normal (reflexão)
-- @param normal Vetor - vetor normal (deve estar normalizado)
-- @param amortecimento number - fator de amortecimento (0 a 1)
-- @return Movable self para encadeamento
function Movable:ricochear(normal, amortecimento)
    amortecimento = amortecimento or 0.5
    self.velocidade:reflect(normal):multiply(amortecimento)
    return self
end

--- Obtém a posição como um Vetor
-- @return Vetor posição (cópia)
function Movable:get_posicao_vetor()
    return Vetor.new(self.rect.x, self.rect.y)
end

--- Define a posição usando um Vetor
-- @param pos Vetor - novo vetor de posição
-- @return Movable self para encadeamento
function Movable:set_posicao_vetor(pos)
    self.rect.x = pos.x
    self.rect.y = pos.y
    return self
end

--- Verifica se está dentro de um retângulo
-- @param cercado_rect tabela - retângulo para verificação
-- @return boolean true se está dentro
function Movable:esta_dentro(cercado_rect)
    return pico.vs.pos_rect(self.rect, cercado_rect)
end

--- Obtém a distância para outro objeto
-- @param outro Movable - outro objeto móvel
-- @return number distância
function Movable:distancia_para(outro)
    local pos1 = self:get_posicao_vetor()
    local pos2 = outro:get_posicao_vetor()
    return pos1:distance(pos2)
end

return Movable
