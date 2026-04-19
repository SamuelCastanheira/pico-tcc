local Vetor = {}
Vetor.__index = Vetor

--- Cria um novo vetor
-- @param x número - componente x
-- @param y número - componente y
-- @return Vetor novo objeto vetor
function Vetor.new(x, y)
    local self = setmetatable({}, Vetor)
    self.x = x or 0
    self.y = y or 0
    return self
end

--- Cria um vetor nulo (0, 0)
-- @return Vetor novo vetor nulo
function Vetor.zero()
    return Vetor.new(0, 0)
end

--- Cria um vetor a partir de um ângulo e magnitude
-- @param angle number - ângulo em radianos
-- @param magnitude number - magnitude (comprimento) do vetor
-- @return Vetor novo vetor
function Vetor.fromAngle(angle, magnitude)
    magnitude = magnitude or 1
    return Vetor.new(
        magnitude * math.cos(angle),
        magnitude * math.sin(angle)
    )
end

--- Cria uma cópia do vetor
-- @return Vetor cópia do vetor
function Vetor:copy()
    return Vetor.new(self.x, self.y)
end

--- Calcula a magnitude (comprimento) do vetor
-- @return number magnitude
function Vetor:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Calcula a magnitude ao quadrado (mais eficiente para comparações)
-- @return number magnitude ao quadrado
function Vetor:magnitudeSquared()
    return self.x * self.x + self.y * self.y
end

--- Alias para magnitude
-- @return number comprimento
function Vetor:length()
    return self:magnitude()
end

--- Normaliza o vetor (torna com magnitude 1)
-- @return Vetor self para encadeamento
function Vetor:normalize()
    local mag = self:magnitude()
    if mag > 0 then
        self.x = self.x / mag
        self.y = self.y / mag
    end
    return self
end

--- Retorna um novo vetor normalizado
-- @return Vetor novo vetor normalizado
function Vetor:normalized()
    local copy = self:copy()
    copy:normalize()
    return copy
end

--- Adiciona outro vetor a este
-- @param v Vetor vetor a adicionar
-- @return Vetor self para encadeamento
function Vetor:add(v)
    self.x = self.x + v.x
    self.y = self.y + v.y
    return self
end

--- Retorna um novo vetor que é a soma de dois vetores
-- @param v1 Vetor primeiro vetor
-- @param v2 Vetor segundo vetor
-- @return Vetor novo vetor resultante
function Vetor.add(v1, v2)
    return Vetor.new(v1.x + v2.x, v1.y + v2.y)
end

--- Subtrai outro vetor deste
-- @param v Vetor vetor a subtrair
-- @return Vetor self para encadeamento
function Vetor:subtract(v)
    self.x = self.x - v.x
    self.y = self.y - v.y
    return self
end

--- Retorna um novo vetor que é a subtração de dois vetores
-- @param v1 Vetor primeiro vetor
-- @param v2 Vetor segundo vetor
-- @return Vetor novo vetor resultante
function Vetor.subtract(v1, v2)
    return Vetor.new(v1.x - v2.x, v1.y - v2.y)
end

--- Multiplica o vetor por um escalar
-- @param scalar number fator de multiplicação
-- @return Vetor self para encadeamento
function Vetor:multiply(scalar)
    self.x = self.x * scalar
    self.y = self.y * scalar
    return self
end

--- Retorna um novo vetor multiplicado por um escalar
-- @param v Vetor vetor a multiplicar
-- @param scalar number fator de multiplicação
-- @return Vetor novo vetor resultante
function Vetor.multiply(v, scalar)
    return Vetor.new(v.x * scalar, v.y * scalar)
end

--- Divide o vetor por um escalar
-- @param scalar number divisor
-- @return Vetor self para encadeamento
function Vetor:divide(scalar)
    if scalar ~= 0 then
        self.x = self.x / scalar
        self.y = self.y / scalar
    end
    return self
end

--- Retorna um novo vetor dividido por um escalar
-- @param v Vetor vetor a dividir
-- @param scalar number divisor
-- @return Vetor novo vetor resultante
function Vetor.divide(v, scalar)
    if scalar ~= 0 then
        return Vetor.new(v.x / scalar, v.y / scalar)
    end
    return v:copy()
end

--- Calcula o produto escalar (dot product)
-- @param v Vetor outro vetor
-- @return number produto escalar
function Vetor:dot(v)
    return self.x * v.x + self.y * v.y
end

--- Calcula o produto escalar entre dois vetores
-- @param v1 Vetor primeiro vetor
-- @param v2 Vetor segundo vetor
-- @return number produto escalar
function Vetor.dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

--- Calcula a distância para outro ponto
-- @param v Vetor outro ponto/vetor
-- @return number distância
function Vetor:distance(v)
    local dx = v.x - self.x
    local dy = v.y - self.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Calcula a distância entre dois pontos
-- @param v1 Vetor primeiro ponto
-- @param v2 Vetor segundo ponto
-- @return number distância
function Vetor.distance(v1, v2)
    return v1:distance(v2)
end

--- Calcula a distância ao quadrado (mais eficiente)
-- @param v Vetor outro ponto/vetor
-- @return number distância ao quadrado
function Vetor:distanceSquared(v)
    local dx = v.x - self.x
    local dy = v.y - self.y
    return dx * dx + dy * dy
end

--- Calcula o ângulo do vetor em radianos
-- @return number ângulo em radianos
function Vetor:angle()
    return math.atan2(self.y, self.x)
end

--- Calcula o ângulo entre dois vetores em radianos
-- @param v Vetor outro vetor
-- @return number ângulo em radianos
function Vetor:angleTo(v)
    local angle1 = self:angle()
    local angle2 = v:angle()
    return angle2 - angle1
end

--- Calcula o ângulo entre dois vetores
-- @param v1 Vetor primeiro vetor
-- @param v2 Vetor segundo vetor
-- @return number ângulo em radianos
function Vetor.angle(v1, v2)
    return v1:angleTo(v2)
end

--- Rotaciona o vetor por um ângulo em radianos
-- @param angle number ângulo em radianos
-- @return Vetor self para encadeamento
function Vetor:rotate(angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    local x = self.x * cos - self.y * sin
    local y = self.x * sin + self.y * cos
    self.x = x
    self.y = y
    return self
end

--- Retorna um novo vetor rotacionado
-- @param v Vetor vetor a rotacionar
-- @param angle number ângulo em radianos
-- @return Vetor novo vetor rotacionado
function Vetor.rotate(v, angle)
    local copy = v:copy()
    copy:rotate(angle)
    return copy
end

--- Inverte o vetor (multiplica por -1)
-- @return Vetor self para encadeamento
function Vetor:negate()
    self.x = -self.x
    self.y = -self.y
    return self
end

--- Retorna um novo vetor invertido
-- @param v Vetor vetor a inverter
-- @return Vetor novo vetor invertido
function Vetor.negate(v)
    return Vetor.new(-v.x, -v.y)
end

--- Limita a magnitude do vetor a um valor máximo
-- @param maxMagnitude number magnitude máxima
-- @return Vetor self para encadeamento
function Vetor:clamp(maxMagnitude)
    local mag = self:magnitude()
    if mag > maxMagnitude then
        self:normalize():multiply(maxMagnitude)
    end
    return self
end

--- Retorna um novo vetor com magnitude limitada
-- @param v Vetor vetor a limitar
-- @param maxMagnitude number magnitude máxima
-- @return Vetor novo vetor limitado
function Vetor.clamp(v, maxMagnitude)
    local copy = v:copy()
    copy:clamp(maxMagnitude)
    return copy
end

--- Interpola linear entre dois vetores
-- @param v Vetor vetor destino
-- @param t number fator de interpolação (0 a 1)
-- @return Vetor self para encadeamento
function Vetor:lerp(v, t)
    self.x = self.x + (v.x - self.x) * t
    self.y = self.y + (v.y - self.y) * t
    return self
end

--- Retorna um novo vetor interpolado entre dois vetores
-- @param v1 Vetor primeiro vetor
-- @param v2 Vetor segundo vetor
-- @param t number fator de interpolação (0 a 1)
-- @return Vetor novo vetor interpolado
function Vetor.lerp(v1, v2, t)
    return Vetor.new(
        v1.x + (v2.x - v1.x) * t,
        v1.y + (v2.y - v1.y) * t
    )
end

--- Reflete o vetor em relação a uma normal
-- @param normal Vetor vetor normal (deve estar normalizado)
-- @return Vetor self para encadeamento
function Vetor:reflect(normal)
    local d = 2 * self:dot(normal)
    self.x = self.x - d * normal.x
    self.y = self.y - d * normal.y
    return self
end

--- Obtém um vetor perpendicular (rotação de 90 graus)
-- @return Vetor novo vetor perpendicular
function Vetor:perpendicular()
    return Vetor.new(-self.y, self.x)
end

--- Verifica se o vetor é nulo (0, 0)
-- @return boolean true se é nulo
function Vetor:isZero()
    return self.x == 0 and self.y == 0
end

--- Define os componentes do vetor
-- @param x number - novo componente x
-- @param y number - novo componente y
-- @return Vetor self para encadeamento
function Vetor:set(x, y)
    self.x = x or 0
    self.y = y or 0
    return self
end

--- Retorna uma representação em string do vetor
-- @return string representação
function Vetor:__tostring()
    return string.format("Vetor(%.2f, %.2f)", self.x, self.y)
end

--- Igualdade entre vetores
-- @param v Vetor outro vetor
-- @return boolean true se são iguais
function Vetor:__eq(v)
    return self.x == v.x and self.y == v.y
end

return Vetor
