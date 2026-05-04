require 'pico.check'
local Timer = require("util.timer")
local Pinguim = require("screens.minigames.bean_counters.pinguim")
local Carga = require("screens.minigames.bean_counters.carga")
local Pilha = require("screens.minigames.bean_counters.pilha")

local BeanCounters = {}

local img_background = "../../../assets/imgs/bean_counters/background.png"
local img_caminhao = "../../../assets/imgs/bean_counters/trucker.png"
local img_neve = "../../../assets/imgs/bean_counters/neve.png"
local img_plataforma = "../../../assets/imgs/bean_counters/plataforma.png"

local img_cafe = "../../../assets/imgs/bean_counters/Coffe_bag.webp"
local img_ceramica = "../../../assets/imgs/bean_counters/Flower_pot.webp"
local img_bigorna = "../../../assets/imgs/bean_counters/Anvil.webp"
local img_peixe = "../../../assets/imgs/bean_counters/Fish_bean_counters.webp"

local rect_background = {'%', x=0.5, y=0.5, w=1, h=1}
local rect_caminhao = {'%', x=1, y=1, w=0.20, h=0.85, anchor='SE'}
local rect_neve = {'%', x=0.5, y=1, w=1, h=0.4, anchor='S'}
local rect_plataforma = {'%', x=0.13, y=0.86, w=0.30, h=0.15}

function BeanCounters.init(state)
    pico.set.window{title="Bean Counters"}
    state.BeanCountersData =
    {
        pinguim = Pinguim.new({
            rect = {'%', x=0.3, y=0.80, w=0.12, h=0.25}
        }),
        cargas = {},
        last = pico.get.now(),
        last_fixed = pico.get.now(),
        fixed_dt = 1/state.frames,
        next_update = pico.get.now(),
        cooldown_plataforma = Timer.new(250),
        pilha1 = Pilha.new(),
        pilha2 = Pilha.new()
    }
    
    local data = state.BeanCountersData
    Carga.table_add(data.cargas, Carga.new())
end 

function BeanCounters.handle_input(data, event)
    if event and event.tag == 'key.dn' and not data.pinguim.derrubado then
        if event.key == 'Left' then
            data.pinguim.velocidade = -10
            return 
        elseif event.key == 'Right' then 
            data.pinguim.velocidade = 10
            return
        end
    end
    data.pinguim.velocidade = 0
    return
end

function BeanCounters.update_movimento(data, dt)
    local new_x = data.pinguim:calcula_posicao(dt)

    if new_x < 0.25 then  
        new_x = 0.25
    elseif new_x > 0.8 then
        new_x = 0.8
    end

    data.pinguim:valida_posicao(new_x)
end

function BeanCounters.update_spawn(data)
    if data.pinguim.derrubado then return end

    local nova = Carga.lanca_carga(data.fixed_dt)

    if nova then
        nova:inicializacao()
        table.insert(data.cargas, nova)
    end
end

function BeanCounters.update_cargas(data, dt)
    for i = #data.cargas, 1, -1 do
        local carga = data.cargas[i]

        if carga:chegou_destino() then
            table.remove(data.cargas, i)
        else
            carga:atualiza_posicao(dt)
        end
    end
end

function BeanCounters.check_colisoes(data)
    if data.pinguim.derrubado then return end

    for i = #data.cargas, 1, -1 do
        local carga = data.cargas[i]

        if data.pinguim:colidou_carga(carga) then
            if carga.tipo.key == "cafe" then
                data.pinguim.score = data.pinguim.score + 2
                data.pinguim.cargas = data.pinguim.cargas + 1 
                data.cooldown_plataforma:reset()
            else
                data.pinguim.vidas = data.pinguim.vidas - 1
            end

            data.pinguim:troca_img(carga)
            table.remove(data.cargas, i)
        end
    end
end

function BeanCounters.check_plataforma(data)
    if data.pinguim.derrubado then return end

    if pico.vs.rect_rect(data.pinguim.rect, rect_plataforma) then
        if data.pinguim.cargas > 0 and not data.cooldown_plataforma.ativo then
            if not data.pilha1:cheia() then
                data.pilha1:add()
            else
                data.pilha2:add()
            end
            data.pinguim.score = data.pinguim.score + 3
            data.cooldown_plataforma:reset()
            data.pinguim.cargas = data.pinguim.cargas - 1
            data.pinguim:troca_img()
        end
    end
end

function BeanCounters.update(state, event)
    local data = state.BeanCountersData

    local agora = pico.get.now()
    local dt_real = (agora - data.last) / 1000
    data.last = agora

    -- input
    BeanCounters.handle_input(data, event)

    -- movimento suave
    BeanCounters.update_movimento(data, data.fixed_dt)

    -- cooldowns
    if data.cooldown_plataforma.ativo then
        data.cooldown_plataforma:update()
    end

    if data.pinguim.derrubado then
        data.pinguim:atualiza_cooldown(dt_real)
    end

    -- lógica fixa
    if agora >= data.next_update then
        data.next_update = data.next_update + data.fixed_dt * 1000

        BeanCounters.update_spawn(data)
    end

    -- cargas
    BeanCounters.update_cargas(data, dt_real * 0.5)

    -- colisões
    BeanCounters.check_colisoes(data)
    BeanCounters.check_plataforma(data)

    -- fim de jogo
    if data.pinguim.vidas <= 0 or (data.pilha1:cheia() and data.pilha2:cheia()) then
        state.nextScreen = "centro"
    end
end

function BeanCounters.draw(state)
        local data = state.BeanCountersData    
        pico.output.clear()

        pico.output.draw.image(img_background, rect_background)
        pico.output.draw.image(img_neve, rect_neve)
        pico.output.draw.image(img_caminhao, rect_caminhao)
        pico.output.draw.image(img_plataforma, rect_plataforma)
        pico.output.draw.image(data.pinguim:get_img(), data.pinguim.rect)

        local score = string.format("%s: %d", "Score", data.pinguim.score)
        local life = string.format("%s: %d", "Vidas", data.pinguim.vidas)
        pico.output.draw.text(score, {'%', x=0.02, y=0.02, w=0.008*#score, h=0.05, anchor='NW'})
        pico.output.draw.text(life, {'%', x=0.02, y=0.06, w=0.008*#life, h=0.05, anchor='NW'})
        

        for _, carga in pairs(data.cargas) do
            if carga.tipo.key == "cafe" then
                pico.layer.image(carga:get_img())
                pico.set.layer(carga:get_img())
                pico.set.view{rotation={angle=carga.angle, anchor='C'}}
                pico.set.layer()
            end
           
            pico.output.draw.image(carga:get_img(), carga.rect)
        end

        for i = 1, data.pilha1.num_cafes do
            pico.layer.image(data.pilha1:get_img())
            pico.set.layer(data.pilha1:get_img())
            pico.set.view{rotation={angle=0, anchor='C'}}
            pico.set.layer()
            pico.output.draw.image(data.pilha1:get_img(), {'%', x=0.1, y=0.85 - (0.03*(i-1)), w=0.1,h=0.1})
        end

        for i = 1, data.pilha2.num_cafes do
            pico.layer.image(data.pilha2:get_img())
            pico.set.layer(data.pilha2:get_img())
            pico.set.view{rotation={angle=0, anchor='C'}}
            pico.set.layer()
            pico.output.draw.image(data.pilha2:get_img(), {'%', x=0.15, y=0.85 - (0.03*(i-1)), w=0.1,h=0.1})
        end
        
        pico.output.draw.image(img_neve, rect_neve)
        pico.output.present()
end

function BeanCounters.finish(state)
    state.money = state.money + state.BeanCountersData.pinguim.score
     state.BeanCountersData = nil
end 

return BeanCounters
