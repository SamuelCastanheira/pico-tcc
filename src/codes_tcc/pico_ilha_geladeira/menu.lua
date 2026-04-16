require 'pico.check'
local Personalizacao = require("personalizacao")
local Dojo  = require("dojo")

local Menu = {}

 local background =      {'%', x=0.5, y=0.5, w=1, h=1}
    local logo =            {'%', x=0.5, y=0.225, w=0.45, h=0.45}
    local bt_jogar =        {'%', x=0.5, y=0.5, w=0.55, h=0.2}
    local bt_personalizar = {'%', x=0.5, y=0.7, w=0.55, h=0.2}
    local bt_sair =         {'%', x=0.5, y=0.9, w=0.55, h=0.2}

function Menu.renderizar()
    pico.set.window{title="Menu"}

    while true do
        local e = pico.input.event()
        local mouse = pico.get.mouse('!')
        if e ~= nil then
            if e.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_sair) then
                pico.quit()
            end
            if e.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_personalizar) then
                Personalizacao.renderizar()
            end
            if e.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_jogar) then
                Dojo.renderizar()
            end
            if e.tag=='quit' then
                break
            end
        end

        local img_jogar = pico.vs.pos_rect(mouse, bt_jogar) and "../../../assets/imgs/botoes/b_jogar_clicado.png" or "../../../assets/imgs/botoes/b_jogar.png"
        local img_personalizar = pico.vs.pos_rect(mouse, bt_personalizar) and "../../../assets/imgs/botoes/b_personalizar_clicado.png" or "../../../assets/imgs/botoes/b_personalizar.png"
        local img_sair = pico.vs.pos_rect(mouse, bt_sair) and "../../../assets/imgs/botoes/b_sair_clicado.png" or "../../../assets/imgs/botoes/b_sair.png"

        pico.output.draw.image("../../../assets/imgs/background_menu.png", background) 
        pico.output.draw.image("../../../assets/imgs/logo.png", logo) 
        pico.output.draw.image(img_jogar, bt_jogar) 
        pico.output.draw.image(img_personalizar, bt_personalizar) 
        pico.output.draw.image(img_sair, bt_sair) 

        pico.output.present()
    end
end

return Menu
