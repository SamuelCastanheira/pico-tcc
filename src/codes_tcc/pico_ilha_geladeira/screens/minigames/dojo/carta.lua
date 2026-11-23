-- Carta do Dojo. Na mão, aparece de frente (jogador) ou de costas (inimigo);
-- depois de jogada, aparece no campo de batalha com o resultado por 2 s e sai
-- do jogo.
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")

local IMGS = "../../../assets/imgs/dojo/"

local Carta = Objeto:extend()

function Carta:init (dono, rect, img, elem, poder)
    self.dono = dono                -- "player" ou "enemy"
    self.rect = rect
    self.img = img
    self.elem = elem
    self.poder = poder
    self.batalha = (dono == "player") and {'%', x=0.8, y=0.3, w=0.2, h=0}
                                       or {'%', x=0.2, y=0.3, w=0.2, h=0}
    self.resultado = nil            -- 1, 0 ou -1, depois de jogada
    self.prazo = nil
    self.viva = true
end

function Carta:move (rect)
    self.rect = rect
end

function Carta:clicada (e)
    return self.dono == "player" and e.tag == 'mouse.button.dn' and
           pico.vs.pos.rect(pico.get.mouse('%'), self.rect)
end

-- 1 se ganha da outra, -1 se perde, 0 se empata
function Carta:compara (outra)
    if self.elem == outra.elem then
        if self.poder > outra.poder then return 1 end
        if self.poder < outra.poder then return -1 end
        return 0
    end
    if (self.elem == "GELO" and outra.elem == "AGUA") or
       (self.elem == "AGUA" and outra.elem == "FOGO") or
       (self.elem == "FOGO" and outra.elem == "GELO") then
        return 1
    end
    return -1
end

function Carta:joga (resultado)
    self.resultado = resultado
    self.prazo = Temporizador:new(2 * Temporizador.S)
end

function Carta:tempo (dt)
    if self.prazo and self.prazo:tempo(dt) then
        self.viva = false
    end
end

function Carta:desenha ()
    if not self.resultado then
        local img = (self.dono == "player") and self.img or (IMGS.."carta_azul.png")
        pico.output.draw.image(img, self.rect)
    else
        pico.output.draw.image(self.img, self.batalha)
        local marca = (self.resultado > -1) and "ok.png" or "x.png"
        pico.output.draw.image(IMGS..marca, self.batalha)
    end
end

return Carta
