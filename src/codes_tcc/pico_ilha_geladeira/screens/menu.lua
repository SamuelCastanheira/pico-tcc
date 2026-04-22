require 'pico.check'
local Objeto = require("util.objeto")

local Menu = {}

local background = Objeto.create({
                            rect = {'%', x=0.5, y=0.5, w=1, h=1},
                            img="../../../assets/imgs/background_menu.png"
                            })
        
local logo = Objeto.create({
                    rect={'%', x=0.5, y=0.225, w=0.45, h=0.45},
                    img="../../../assets/imgs/logo.png"
                    })

local bt_jogar = Objeto.create({
                        rect={'%', x=0.5, y=0.5, w=0.55, h=0.2},
                        img="../../../assets/imgs/botoes/b_jogar.png",
                        img_hover= "../../../assets/imgs/botoes/b_jogar_clicado.png"
                        })
                
local bt_personalizar = Objeto.create({
                                rect={'%', x=0.5, y=0.7, w=0.55, h=0.2},
                                img="../../../assets/imgs/botoes/b_personalizar.png",
                                img_hover=  "../../../assets/imgs/botoes/b_personalizar_clicado.png"
                                })  

local bt_sair = Objeto.create({
                        rect={'%', x=0.5, y=0.9, w=0.55, h=0.2},
                        img="../../../assets/imgs/botoes/b_sair.png",
                        img_hover= "../../../assets/imgs/botoes/b_sair_clicado.png"
                        })

function Menu.init(state)
     pico.set.window{title="Menu"}
end

function Menu.update(state, event)
    local mouse = pico.get.mouse('%')
    bt_sair.hover = false
    bt_personalizar.hover = false
    bt_jogar.hover = false 

    if pico.vs.pos_rect(mouse, bt_sair.rect) then
        bt_sair.hover = true
    elseif pico.vs.pos_rect(mouse, bt_personalizar.rect) then 
        bt_personalizar.hover = true
    elseif pico.vs.pos_rect(mouse, bt_jogar.rect) then
        bt_jogar.hover = true
    end

    if event then
        if event.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_sair.rect) then
            pico.quit()
        end
        if event.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_personalizar.rect) then
            state.nextScreen = "person"
        end
        if event.tag=='mouse.button.dn' and pico.vs.pos_rect(mouse, bt_jogar.rect) then
            state.nextScreen = "centro"
        end
    end
end

function Menu.draw(state)
    pico.output.draw.image(background:get_img(), background.rect) 
    pico.output.draw.image(logo:get_img(), logo.rect) 
    pico.output.draw.image(bt_jogar:get_img(), bt_jogar.rect) 
    pico.output.draw.image(bt_personalizar:get_img(), bt_personalizar.rect) 
    pico.output.draw.image(bt_sair:get_img(), bt_sair.rect) 
end

function Menu.finish(state)
    state.screen = nil
end

return Menu

