-- Classe base de todas as classes do jogo.
--
-- Herança por metatabelas: cada classe é a metatabela (e o __index) das suas
-- instâncias, e cada subclasse herda da classe mãe pelo __index.
--
--   local Pinguim = Objeto:extend()          -- subclasse
--   function Pinguim:init(rect) ... end      -- construtor
--   local p = Pinguim:new(rect)              -- instância
--
-- Toda entidade do jogo participa do laço por três métodos, que as
-- subclasses redefinem quando precisam:
--   tempo(dt)   o relógio avançou dt microssegundos
--   evento(e)   chegou um evento de entrada (mouse, teclado)
--   desenha()   desenha a entidade no quadro corrente
local Objeto = {}
Objeto.__index = Objeto

function Objeto:extend ()
    local classe = setmetatable({}, self)
    classe.__index = classe
    return classe
end

function Objeto:new (...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function Objeto:init () end
function Objeto:tempo (dt) end
function Objeto:evento (e) end
function Objeto:desenha () end

return Objeto
