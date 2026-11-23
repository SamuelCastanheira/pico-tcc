-- Imagem clicável com destaque quando o mouse está em cima (hover).
-- Usada pelos botões dos menus e pelos prédios do centro.
local Objeto = require("util.objeto")

local Botao = Objeto:extend()

function Botao:init (id, rect, img, img_hover)
    self.id = id
    self.rect = rect
    self.img = img
    self.img_hover = img_hover
    self.hover = false
end

-- o destaque acompanha o mouse a cada passo do relógio
function Botao:tempo (dt)
    local m = pico.get.mouse('%')
    self.hover = (self.img_hover ~= nil) and
                 pico.vs.pos.rect({'%', x=m.x, y=m.y}, self.rect)
end

function Botao:clicado (e)
    return e.tag == 'mouse.button.dn' and
           pico.vs.pos.rect(pico.get.mouse('%'), self.rect)
end

function Botao:desenha ()
    pico.output.draw.image(self.hover and self.img_hover or self.img, self.rect)
end

return Botao
