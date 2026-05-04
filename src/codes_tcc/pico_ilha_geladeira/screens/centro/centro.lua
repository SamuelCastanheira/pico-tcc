local Centro = {}
local Objeto =  require("util.objeto")
local Pinguim =  require("screens.centro.pinguim")

local background = Objeto.create({
                        rect = {'%', x=0.5, y=0.5, w=1, h=1},
                        img = "../../../assets/imgs/centro.png"})

local cafeteria = Objeto.create({
                        rect = {'%', x=0.25, y=0.4, w=0.4, h=0.4},
                        img = "../../../assets/imgs/coffe.png",
                        img_hover = "../../../assets/imgs/coffe_hover.png"})

local petshop = Objeto.create({
                        rect = {'%', x=0.5, y=0.4, w=0.35, h=0.35},
                        img = "../../../assets/imgs/pet_shop.png",
                        img_hover = "../../../assets/imgs/pet_shop_hover.png"})

local dojo = Objeto.create({
                        rect = {'%', x=0.72, y=0.39, w=0.35, h=0.35},
                        img = "../../../assets/imgs/dojo/dojo.png",
                        img_hover = "../../../assets/imgs/dojo/dojo_hover.png"})                    


function Centro.init(state)
    pico.set.window{title="Centro"}
    state.centroData =
    {
       pinguim = Pinguim.new({rect={'%', x=0.5, y=0.7, w=0.08, h=0}}),
       last = pico.get.now(),
       destino = nil
    }
end

function Centro.update(state, event)
    local mouse = pico.get.mouse('%')
    cafeteria.hover = false
    dojo.hover = false
    petshop.hover = false
    local data = state.centroData
    local agora = pico.get.now()
    local dt =  (agora - data.last)/1000
    data.last = agora

    if event and event.tag == 'mouse.button.dn' then
        data.pinguim:calcula_movimento(mouse)
    end
    if not data.pinguim:chegou_destino() then
        data.pinguim:atualiza_posicao(dt)
    end

    if pico.vs.pos_rect(mouse, petshop.rect) then
        petshop.hover = true
        data.destino = "petshop"
    elseif pico.vs.pos_rect(mouse, cafeteria.rect) then
        cafeteria.hover = true
        data.destino = "cafeteria"
    elseif pico.vs.pos_rect(mouse, dojo.rect) then
        dojo.hover = true
        data.destino = "dojo"
    end

    if data.destino and data.destino == "petshop" and pico.vs.pos_rect(data.pinguim.rect, petshop.rect) then
        state.nextScreen = "pega_puffle"
    elseif data.destino and data.destino == "cafeteria" and pico.vs.pos_rect(data.pinguim.rect, cafeteria.rect) then
        state.nextScreen = "bean_counters"
    elseif data.destino and data.destino == "dojo" and pico.vs.pos_rect(data.pinguim.rect, dojo.rect) then
        state.nextScreen = "dojo"
    end
end

function Centro.draw(state)
    data = state.centroData
    pico.output.draw.image(background:get_img(), background.rect)
    pico.output.draw.image(cafeteria:get_img(), cafeteria.rect)
    pico.output.draw.image(dojo:get_img(), dojo.rect)
    pico.output.draw.image(petshop:get_img(), petshop.rect)
    pico.output.draw.image(data.pinguim:get_img(), data.pinguim.rect)


    local moeda = {'%',x=0.05, y=0.05, w=0.05, h=0}
    local moeda_num = {'%',x=0.08, y=0, w=.025*#tostring(state.money), h= 0.1, anchor='NW'}
    pico.output.draw.image("../../../assets/imgs/moeda.png",moeda )
    pico.set.color.draw('yellow')
    pico.output.draw.text(state.money, moeda_num)
    pico.output.present()
end

function Centro.finish(state)
    state.screen = nil
end

return Centro