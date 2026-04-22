require 'pico.check'

local BeanCounters = {}

--nao necessario
--local lim_esquerda = {'%',x=0.15, y=0.9} 
--local lim_direita = {'%',x=0.8, y=0.9}

local jogando = true

local img_background = "../../../assets/imgs/bean_counters/background.png"
local img_caminhao = "../../../assets/imgs/bean_counters/trucker.png"
local img_neve = "../../../assets/imgs/bean_counters/neve.png"
local img_plataforma = "../../../assets/imgs/bean_counters/plataforma.png"

local img_cafe = "../../../assets/imgs/bean_counters/Coffe_bag.webp"
local img_ceramica = "../../../assets/imgs/bean_counters/Flower_pot.webp"
local img_bigorna = "../../../assets/imgs/bean_counters/Anvil.webp"
local img_peixe = "../../../assets/imgs/bean_counters/Fish_bean_counters.webp"

local rect_background = {'%', x=0.5, y=0.5, w=1, h=1}
local rect_caminhao = {'%', x=1, y=1, w=0.22, h=0, anchor='SE'}
local rect_neve = {'%', x=0.5, y=1, w=1, h=0.4, anchor='S'}
local rect_plataforma = {'%', x=0, y=1, w=0.25, h=0.25, anchor='SW'}

local pinguim = {
    img = "../../../assets/imgs/bean_counters/penguin0.webp",
    rect = {'%', x=0.3, y=0.97, w=0.15, h=0, anchor='S'},
    speed = 0.08
}

function BeanCounters.update()
    local e = pico.input.event()
    if e ~= nil then
        if e.tag == 'key.dn' then
            local next_step = pinguim.rect.x - pinguim.speed
            if e.key == 'Left' and not pico.vs.rect_rect(rect_plataforma, pinguim.rect) then 
                pinguim.rect.x = next_step
            elseif e.key == 'Right' and not pico.vs.rect_rect(rect_caminhao, pinguim.rect) then 
                local next_step = pinguim.rect.x + pinguim.speed
                pinguim.rect.x = next_step
        end
        elseif e.tag=='quit' then
            pico.quit()
            jogando = false
        end
    end
end

function BeanCounters.draw()    
        pico.output.clear()
        pico.output.draw.image(img_background, rect_background)
        pico.output.draw.image(img_neve, rect_neve)
        pico.output.draw.image(img_caminhao, rect_caminhao)
        pico.output.draw.image(img_plataforma, rect_plataforma)
        pico.output.draw.image(pinguim.img, pinguim.rect)
        pico.output.draw.image(img_neve, rect_neve)
        pico.output.present()
end


function BeanCounters.init()
    pico.set.window{title="Bean Counters"}
end 

function BeanCounters.finish()
    
end 

return BeanCounters
