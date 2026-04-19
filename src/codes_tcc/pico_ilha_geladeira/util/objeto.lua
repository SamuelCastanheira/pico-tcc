local Objeto = {}

-- Função construtora para criar uma nova loja
function Objeto.create(rect, img, img_hover)
    return {
        rect = rect,
        hover = false,
        img = img,
        img_hover = img_hover,
        get_img = function(self)
            return self.hover and self.img_hover or self.img
        end
    }
end

return Objeto