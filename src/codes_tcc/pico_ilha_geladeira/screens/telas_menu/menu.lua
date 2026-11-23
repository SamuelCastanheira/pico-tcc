local Objeto = require("util.objeto")
local Botao = require("util.botao")

local IMGS = "../../../assets/imgs/"

local Menu = Objeto:extend()

function Menu:init (jogo)
    self.jogo = jogo
    pico.set.window{title="Menu"}
    self.fundo = {'%', x=0.5, y=0.5, w=1, h=1}
    self.logo = {'%', x=0.5, y=0.225, w=0.45, h=0.45}
    self.botoes = {
        Botao:new("CENTRO", {'%', x=0.5, y=0.5, w=0.55, h=0.15},
                  IMGS.."botoes/b_jogar.png", IMGS.."botoes/b_jogar_clicado.png"),
        Botao:new("PERSON", {'%', x=0.5, y=0.7, w=0.55, h=0.15},
                  IMGS.."botoes/b_personalizar.png", IMGS.."botoes/b_personalizar_clicado.png"),
        Botao:new("SAIR", {'%', x=0.5, y=0.9, w=0.55, h=0.15},
                  IMGS.."botoes/b_sair.png", IMGS.."botoes/b_sair_clicado.png"),
    }
end

function Menu:tempo (dt)
    for _, b in ipairs(self.botoes) do
        b:tempo(dt)
    end
end

function Menu:evento (e)
    for _, b in ipairs(self.botoes) do
        if b:clicado(e) then
            self.jogo:menu_escolheu(b.id)
            return
        end
    end
end

function Menu:desenha ()
    pico.output.draw.image(IMGS.."background_menu.png", self.fundo)
    pico.output.draw.image(IMGS.."logo.png", self.logo)
    for _, b in ipairs(self.botoes) do
        b:desenha()
    end
end

return Menu
