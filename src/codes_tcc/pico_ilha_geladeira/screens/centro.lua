local Centro = {}
local Objeto =  require("util.objeto")

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
end

function Centro.update(state, event)
    local mouse = pico.get.mouse('%')
    cafeteria.hover = false
    dojo.hover = false
    petshop.hover = false

    if pico.vs.pos_rect(mouse, petshop.rect) then
        petshop.hover = true
    elseif pico.vs.pos_rect(mouse, cafeteria.rect) then
        cafeteria.hover = true
    elseif pico.vs.pos_rect(mouse, dojo.rect) then
        dojo.hover = true
    end

    if event and event.tag == 'mouse.button.dn' then
        if pico.vs.pos_rect(mouse, petshop.rect) then
            state.nextScreen = "pega_puffle"
        elseif pico.vs.pos_rect(mouse, cafeteria.rect) then
            state.nextScreen = "bean_counters"
        elseif pico.vs.pos_rect(mouse, dojo.rect) then
            state.nextScreen = "dojo"
        end
    end
end

function Centro.draw(state)

    pico.output.draw.image(background:get_img(), background.rect)
    pico.output.draw.image(cafeteria:get_img(), cafeteria.rect)
    pico.output.draw.image(dojo:get_img(), dojo.rect)
    pico.output.draw.image(petshop:get_img(), petshop.rect)

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