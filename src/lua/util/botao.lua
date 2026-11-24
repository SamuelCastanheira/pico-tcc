-- Imagem clicável com destaque quando o mouse está em cima (hover).
-- Usada pelos botões dos menus e pelos prédios do centro.
local Objeto = require("util.objeto")

local Botao = Objeto:extend()

function Botao:init (id, rect, img, img_hover)
    self.id = id
    self.rect = rect
    self.img = img
    self.img_hover = img_hover
end

-- o destaque segue o mouse no momento do desenho
function Botao:em_cima ()
    local m = pico.get.mouse('%')
    return (self.img_hover ~= nil) and pico.vs.pos.rect({'%', x=m.x, y=m.y}, self.rect)
end

function Botao:clicado (e)
    return e.tag == 'mouse.button.dn' and
           pico.vs.pos.rect(pico.get.mouse('%'), self.rect)
end

function Botao:desenha ()
    pico.output.draw.image(self:em_cima() and self.img_hover or self.img, self.rect)
end

return Botao
