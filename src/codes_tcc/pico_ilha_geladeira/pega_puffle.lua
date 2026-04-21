local PegaPuffle = {}
local Puffle = require("util.puffle")
local Vetor = require("util.vetor")

-- ==================== UTILITÁRIOS ====================
local function removerPuffle(lista, alvo)
    for i, v in ipairs(lista) do
        if v == alvo then
            table.remove(lista, i)
            return 1
        end
    end
end

local function dentro_do_oval(puffle)
    local centro = Vetor.new{ x = 0.5, y = 0.5 }

    local rx = 1.53 / 2
    local ry = 0.9 / 2

    local dx = puffle.rect.x - centro.x
    local dy = puffle.rect.y - centro.y

    local valor =
        (dx * dx) / (rx * rx) +
        (dy * dy) / (ry * ry)

    return valor <= 1
end

local function verificaColisaoComParede(puffle, hitboxes)
    for nome, parede in pairs(hitboxes) do
        if pico.vs.rect_rect(puffle.rect, parede) then
            return true, nome
            
        end
    end
    return false, nil
end

local function calcula_fuga_obstaculo(puffle, mouse, v_direcao_obstaculo)
    -- Destino com direção contrária ao mouse
    local dx = puffle.rect.x - mouse.x
    local dy = puffle.rect.y - mouse.y
    local v_mouse = Vetor:new({x= dx, y= dy})
  
    
    -- Combina com a direção contrária ao obstáculo
    local v_final = v_mouse:add(v_direcao_obstaculo) 
    return v_final
end

-- ==================== INICIALIZAÇÃO ====================

function PegaPuffle.init(state)
    math.randomseed(pico.get.now())
    
    state.pegaPuffleData = {
        puffles = Puffle.lista(),
        hitboxes = {
            esquerda = {'%', x=0.43, y=0.65, w=0.02, h=0.3, anchor='C'},
            direita =  {'%', x=0.58, y=0.65, w=0.02, h=0.3, anchor='C'},
            baixo =    {'%', x=0.5, y=0.8, w=0.20, h=0.02, anchor='C'}
        },
        distancia_max = 0.1,
        velocidade_esc = 0.04,
        duracao_fuga = 0.4,
        cercado = {'%', x=0.5, y=0.65, w=0.15, h=0.25},
        capturados = 0,
        fugiram = 0,
        tempo_inicial = pico.get.now(),
        timer = 0,
        duracao_timer = 100*1000
    }
end

function PegaPuffle.update(state, event)
    local data = state.pegaPuffleData
    local mouse = pico.get.mouse('%')
    data.timer = pico.get.now() - data.tempo_inicial
    local dt = 0.05

    for _, puffle in ipairs(data.puffles) do
        puffle.movendo = false
    end
    -- Processa evento de mouse
    for _, puffle in ipairs(data.puffles) do
        if not puffle.em_fuga then
            local dx = mouse.x - puffle.rect.x
            local dy = mouse.y - puffle.rect.y
            local delta = Vetor.new({x=dx, y=dy})
            local dist = delta:magnitude()
            
            if dist > 0.001 and dist <= data.distancia_max then
                -- Calcula reflexão e move para lá
                local destino = Vetor.new({ x= mouse.x - (2 * delta.x),
                                            y=mouse.y - (2 * delta.y) })

                puffle:calcula_velocidade_vetorial(destino, data.velocidade_esc)
                puffle.movendo = true
                --Verifica colisões entre puffles
                for _, b in ipairs(data.puffles) do
                    if puffle ~= b and not b.movendo then
                        if pico.vs.rect_rect(puffle.hitbox, b.rect) then
                            puffle:colidir_com(b)
                            b.movendo = true
                        end
                    end
                end
            else
                puffle:limpar_movimento()
            end

            
            
        end
    end
    
    -- Atualiza movimento de cada puffle
    for _, puffle in ipairs(data.puffles) do
        
        puffle:atualizar_posicao(dt)
        puffle:clamp_cercado(data.cercado)
        if puffle.em_fuga then puffle:atualizar_fuga(dt) end
    end

    


    --Verifica colisões e limites de tela
    for _, puffle in ipairs(data.puffles) do
        if not dentro_do_oval(puffle) or puffle.rect.x > 1 or puffle.rect.x < 0 then
                removerPuffle(data.puffles, puffle)
                data.fugiram = data.fugiram + 1
        end

        local colidiu, parede_nome = verificaColisaoComParede(puffle, data.hitboxes)
        if colidiu then
            -- Calcula direção de fuga
            local cerca_outside = {esquerda = {x=-1, y=0}, 
                                direita = {x=1, y=0}, 
                                baixo = {x=0, y=1}}

            local cerca_inside =  {esquerda = {x=1, y=0}, 
                                    direita = {x=-1, y=0}, 
                                    baixo = {x=0, y=-1}} 

            local direcoes_fuga = pico.vs.pos_rect(puffle.rect,data.cercado) and cerca_inside or cerca_outside
            local direcao = direcoes_fuga[parede_nome] or {0, 0}
            local v_destino = calcula_fuga_obstaculo(puffle, mouse, direcao)
            
            -- Ativa fuga
            puffle:ativar_fuga(v_destino, data.velocidade_esc, data.duracao_fuga)
           
        end
    end
    
    

    -- Verifica vitória
    data.capturados = 0
    for _, puffle in ipairs(data.puffles) do
        if pico.vs.pos_rect(puffle.rect, data.cercado) then
             data.capturados = data.capturados + 1
        end
    end

    local todos_dentro = true
    for _, puffle in ipairs(data.puffles) do
        if not pico.vs.pos_rect(puffle.rect, data.cercado) then
            todos_dentro = false
            break
        end
    end

    if todos_dentro or #data.puffles == 0 or data.timer > data.duracao_timer  then
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
    local s_timer = string.format("%s: %d", "Timer", math.floor(data.duracao_timer/1000 - data.timer/1000))
    pico.output.draw.text(s_capturados, {'%', x=0.02, y=0.02, w=0.008*#s_capturados, h=0.05, anchor='NW'})
    pico.output.draw.text(s_fugiram, {'%', x=0.02, y=0.06, w=0.008*#s_fugiram, h=0.05, anchor='NW'})
    pico.output.draw.text(s_timer, {'%', x=0.9, y=0.02, w=0.008*#s_timer, h=0.1, anchor='NW'})

end

function PegaPuffle.finish(state)
    state.money = state.money + state.pegaPuffleData.capturados * 10
    state.pegaPuffleData = nil
end

return PegaPuffle