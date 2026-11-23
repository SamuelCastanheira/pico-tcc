-- Prédio do centro: um botão (destaque e clique) com uma hitbox para a
-- chegada do pinguim.
local Botao = require("util.botao")

local Predio = Botao:extend()

function Predio:init (id, rect, hitbox, img, img_hover)
    Botao.init(self, id, rect, img, img_hover)
    self.hitbox = hitbox
end

function Predio:colide (hitbox)
    return pico.vs.rect.rect(hitbox, self.hitbox)
end

return Predio
