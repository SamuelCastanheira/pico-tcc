local PegaPuffle = {}
local Puffle = require("screens.minigames.pega_puffles.puffle")
local Vetor = require("util.vetor")
local Timer = require("util.timer")

-- ==================== UTILITÁRIOS ====================
local function removerPuffle(lista, alvo)
    for i, v in ipairs(lista) do
        if v == alvo then
            table.remove(lista, i)
            return 1
        end
    end
end

function verifica_vitoria(data)
    -- Verifica vitória
    data.capturados = 0
    for _, puffle in ipairs(data.puffles) do
        if pico.vs.pos_rect(puffle.rect, data.cercado) then
             data.capturados = data.capturados + 1
        end
    end 
    return data.capturados == #data.puffles or #data.puffles == 0 or data.timer:isFinished()
end

local function dentro_do_mapa(puffle)
    local centro = Vetor.new{ x = 0.5, y = 0.5 }

    local rx = 1.53 / 2
    local ry = 0.9 / 2

    local dx = puffle.rect.x - centro.x
    local dy = puffle.rect.y - centro.y

    local valor =
        (dx * dx) / (rx * rx) +
        (dy * dy) / (ry * ry)

    return valor <= 1 and puffle.rect.x < 1 and puffle.rect.x > 0 
end

local function direcao_fuga_mouse(puffle, data, mouse)
    local direcao = Vetor.new({x=0, y=0})

    local dx = mouse.x - puffle.rect.x
    local dy = mouse.y - puffle.rect.y
    local delta = Vetor.new({x=dx, y=dy})
    local dist = delta:magnitude()
    
    if dist > 0.001 and dist <= data.distancia_max then
        -- Calcula reflexão e move para lá
        local destino = {
            x= mouse.x - (2 * delta.x),
            y=mouse.y - (2 * delta.y)
        }
        
        direcao = Vetor.new({
            x = destino.x - puffle.rect.x,
            y = destino.y - puffle.rect.y
        })
    end
    return direcao
end

local function direcao_fuga_puffles(puffle, data)
    local direcao = Vetor.new({x=0, y=0})
    local influencia = 0.5
    for _, outro in ipairs(data.puffles) do
        if outro ~= puffle then
            local dx = outro.rect.x - puffle.rect.x
            local dy = outro.rect.y - puffle.rect.y
            direcao = Vetor.new({x = dx, y = dy})

            if direcao:magnitude() < 0.05 and direcao:magnitude() > 0 then
                outro.direcao =  outro.direcao:add(direcao:multiply(influencia))
            end
        end
    end  
end

local function direcao_fuga_parede(puffle, data)
    local direcao = Vetor.new({x=0, y=0})
    local normais = {}

    for _, parede in pairs(data.hitboxes) do
        if pico.vs.rect_rect(puffle.rect, parede) then
            
            local dx = puffle.rect.x - parede.x
            local dy = puffle.rect.y - parede.y

            local overlapX = (parede.w/2 + puffle.rect.w/2) - math.abs(dx)
            local overlapY = (parede.h/2 + puffle.rect.h/2) - math.abs(dy)

            local normal

            if overlapX < overlapY then
                -- colisão horizontal
                if dx > 0 then
                   normal = Vetor.new({x=1, y=0})
                else
                    normal = Vetor.new({x=-1, y=0})
                end
            else
                -- colisão vertical
                if dy > 0 then
                    normal = Vetor.new({x=0, y=1})
                else
                    normal = Vetor.new({x=0, y=-1})
                end
            end
            table.insert(normais, normal)
        end
    end

    return normais
end

local function aplicar_slide(direcao, normal)
    local dot = direcao:dot(normal)

    if dot < 0 then
        direcao.x = direcao.x - dot * normal.x
        direcao.y = direcao.y - dot * normal.y
    end

    return direcao:multiply(0.1)
end

function PegaPuffle.init(state)
    math.randomseed(pico.get.now())

    state.pegaPuffleData = {
        puffles = Puffle.lista(),
        hitboxes = {
            esquerda = {'%', x=0.43, y=0.65, w=0.02, h=0.3, anchor='C'},
            direita =  {'%', x=0.58, y=0.65, w=0.02, h=0.3, anchor='C'},
            baixo =    {'%', x=0.5, y=0.8, w=0.15, h=0.02, anchor='C'}
        },
        distancia_max = 0.2,
        velocidade_esc = 0.04,
        cercado = {'%', x=0.5, y=0.65, w=0.15, h=0.25},
        capturados = 0,
        fugiram = 0,
        timer = Timer.new(100*1000)
    }

     state.pegaPuffleData.timer:start()
end

function PegaPuffle.update(state, event)
    local data = state.pegaPuffleData
    local mouse = pico.get.mouse('%')
    data.timer:update()
    local dt = 0.05

    -- Processa evento de mouse
    for _, puffle in ipairs(data.puffles) do
        puffle.direcao = Vetor.new({x=0, y=0})
        puffle.direcao = puffle.direcao:add(direcao_fuga_mouse(puffle, data, mouse))

    end

    --afeta o movimento dos outros puffles
    for _, puffle in ipairs(data.puffles) do
        direcao_fuga_puffles(puffle, data)
    end 

    -- Processa evento de mouse
    for _, puffle in ipairs(data.puffles) do
       
        local normais = direcao_fuga_parede(puffle, data)

        for _, normal in ipairs(normais) do
            if not normal:isZero() then
                normal = normal:normalize()
                dt = 0.03
                puffle.direcao = aplicar_slide(puffle.direcao, normal)
            end 
        end
    end

    --mudança da posição 
     for _, puffle in ipairs(data.puffles) do
        if dentro_do_mapa(puffle, data) then
            if ( puffle.direcao:isZero()) then
                puffle:parar()
            else
                puffle:calcula_velocidade_vetorial(puffle.direcao, data.velocidade_esc)
            end
            
            if not puffle.velocidade:isZero() then
                puffle:atualizar_posicao(dt)
            end
        else
            data.fugiram = data.fugiram + removerPuffle(data.puffles, puffle)
        end
    end 
        
    if verifica_vitoria(data) then
        state.nextScreen = "centro"
    end
end

function PegaPuffle.draw(state)
    local data = state.pegaPuffleData
    local background = {'%', x=0.5, y=0.5, w=1, h=1}
    local arvores = {'%', x=0.5, y=0.5, w=1, h=1}
    
    pico.output.draw.image("../../../assets/imgs/puffle_roundup/background.png", background)

    for _, puffle in ipairs(data.puffles) do
        pico.output.draw.image(puffle.img, puffle.rect)
    end

    pico.output.draw.image("../../../assets/imgs/puffle_roundup/arvores.png", arvores)
    pico.set.color.draw('yellow')
    local s_capturados = string.format("%s: %d", "Capturados", data.capturados)
    local s_fugiram = string.format("%s: %d", "Fugiram", data.fugiram)
    local s_timer = string.format("%s: %d", "Timer", math.floor(data.timer:getRestante()/1000))
    pico.output.draw.text(s_capturados, {'%', x=0.02, y=0.02, w=0.008*#s_capturados, h=0.05, anchor='NW'})
    pico.output.draw.text(s_fugiram, {'%', x=0.02, y=0.06, w=0.008*#s_fugiram, h=0.05, anchor='NW'})
    pico.output.draw.text(s_timer, {'%', x=0.9, y=0.02, w=0.008*#s_timer, h=0.1, anchor='NW'})

end

function PegaPuffle.finish(state)
    state.money = state.money + state.pegaPuffleData.capturados * 10
    state.pegaPuffleData = nil
end

return PegaPuffle