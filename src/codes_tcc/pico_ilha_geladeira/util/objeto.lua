local Objeto = {}
Objeto.__index = Objeto

function Objeto.create(opts)
    opts = opts or {}

    local self = setmetatable({}, Objeto)

    self.rect = opts.rect or {}
    self.hitbox = opts.hitbox or {}
    self.hover = false
    self.img = opts.img
    self.img_hover = opts.img_hover or opts.img

    return self
end

function Objeto:get_img()
    return self.hover and self.img_hover or self.img
end

return Objeto