local PegaPuffle = {}
local Puffle = require("util.puffle")
local Vetor = require("util.vetor")

local ALTURA_PUFFLE_RATIO = 18
local DISTANCIA_MAX = 0.3
local ESCALAR_VELOCIDADE = 0.01

local puffle_paths = {
    "../../../assets/imgs/puffle_roundup/puffle_amarelo.png",
    "../../../assets/imgs/puffle_roundup/puffle_azul.png",
    "../../../assets/imgs/puffle_roundup/puffle_branco.png",
    "../../../assets/imgs/puffle_roundup/puffle_vermelho.png",
    "../../../assets/imgs/puffle_roundup/puffle_verde.png",
    "../../../assets/imgs/puffle_roundup/puffle_laranja.png",
    "../../../assets/imgs/puffle_roundup/puffle_rosa.png",
    "../../../assets/imgs/puffle_roundup/puffle_roxo.png",
    "../../../assets/imgs/puffle_roundup/puffle_preto.png",
    "../../../assets/imgs/puffle_roundup/puffle_marrom.png"
}

local function verificaColisaoComParede(puffle, hitboxes)
    for _, parede in pairs(hitboxes) do
        for _, hitbox in ipairs(parede) do
            if pico.vs.rect_rect(puffle.rect, hitbox) then
                return true
            end
        end
    end
    return false
end

function PegaPuffle.init(state)
    math.randomseed(pico.get.now())
    
    local altura_puffle = 0.05  -- em porcentagem
    
    state.pegaPuffleData = {
        puffles = {},
        hitboxes = {
            esquerda = {
                {'%', x=0.40, y=0.82, w=0.02, h=0.15, anchor='NW'},
                {'%', x=0.44, y=0.52, w=0.02, h=0.30, anchor='NW'},
                {'%', x=0.46, y=0.52, w=0.02, h=0.30, anchor='NW'},
                {'%', x=0.42, y=0.82, w=0.02, h=0.15, anchor='NW'}
            },
            direita = {
                {'%', x=0.58, y=0.82, w=0.02, h=0.15, anchor='NW'},
                {'%', x=0.56, y=0.52, w=0.02, h=0.30, anchor='NW'},
                {'%', x=0.58, y=0.52, w=0.02, h=0.30, anchor='NW'},
                {'%', x=0.60, y=0.77, w=0.02, h=0.20, anchor='NW'}
            },
            baixo = {
                {'%', x=0.40, y=0.82, w=0.20, h=0.02, anchor='NW'},
                {'%', x=0.40, y=0.76, w=0.20, h=0.02, anchor='NW'}
            }
        },
        cercado = {'%', x=0.5, y=0.65, w=0.15, h=0.25},
        altura_puffle = altura_puffle,
        tempo_decorrido = 0
    }
    
    -- Inicializa puffles
    for i = 1, #puffle_paths do
        state.pegaPuffleData.puffles[i] = Puffle.create(
            puffle_paths[i],
            {   
                '%', 
                x= math.random(30, 70) / 100,  -- 0.30 a 0.70
                y= math.random(10, 40) / 100,  -- 0.10 a 0.40
                w=altura_puffle, 
                h=altura_puffle
            }
        )
    end
end

function PegaPuffle.update(state, event)
    local data = state.pegaPuffleData
    local mouse = pico.get.mouse('%')
    local mouse_vetor = Vetor.new(mouse.x, mouse.y)
    local dt = 0.1  -- ~60 FPS
    
    -- Atualiza movimento baseado no mouse
    if event and event.tag == 'mouse.motion' then
        for _, puffle in ipairs(data.puffles) do
            local puffle_pos = Vetor.new(puffle.rect.x, puffle.rect.y)
            local direcao_vetor = Vetor.subtract(mouse_vetor, puffle_pos)
            local dist = direcao_vetor:magnitude()
            
            -- Se mouse está perto, puffle foge
            if dist < DISTANCIA_MAX then
                -- Normaliza, inverte direção (fuga) e aplica velocidade
                direcao_vetor:normalize():negate():multiply(ESCALAR_VELOCIDADE)
                puffle.velocidade = direcao_vetor
            else
                -- Sem mouse próximo, desacelera
                --puffle:desacelerar(0.95)
            end
        end
    end
    
    -- Atualiza posições e verifica colisões
    for _, puffle in ipairs(data.puffles) do
        -- Salva posição anterior
        local pos_anterior = {x=puffle.rect.x, y=puffle.rect.y}
        
        -- Atualiza posição
        --puffle:atualizar_posicao(dt)
        
        -- Verifica colisão com paredes
        if verificaColisaoComParede(puffle, data.hitboxes) then
            -- Reverte posição
            puffle.rect.x = pos_anterior.x
            puffle.rect.y = pos_anterior.y
            -- Ricochete com amortecimento
            puffle:desacelerar(-0.5)
        end
        
        -- Limites da tela (em porcentagem)
        if puffle.rect.x < 0.1 then 
            puffle.rect.x = 0.1
            puffle.velocidade.x = math.abs(puffle.velocidade.x)
        end
        if puffle.rect.x > 0.9 then 
            puffle.rect.x = 0.9
            puffle.velocidade.x = -math.abs(puffle.velocidade.x)
        end
        if puffle.rect.y < 0.1 then 
            puffle.rect.y = 0.1
            puffle.velocidade.y = math.abs(puffle.velocidade.y)
        end
        if puffle.rect.y > 0.9 then 
            puffle.rect.y = 0.9
            puffle.velocidade.y = -math.abs(puffle.velocidade.y)
        end
    end
    
    -- Verifica se todos os puffles estão dentro do cercado
    local todos_dentro = true
    for _, puffle in ipairs(data.puffles) do
        if not puffle:esta_dentro(data.cercado) then
            todos_dentro = false
            break
        end
    end
    
    -- Se todos estão dentro, transiciona
    if todos_dentro then
        state.nextScreen = "centro"
    end
end

function PegaPuffle.draw(state)
    local data = state.pegaPuffleData
    local background = {'%', x=0.5, y=0.5, w=1, h=1}
    local arvores = {'%', x=0.5, y=0.5, w=1, h=1}
    
    pico.output.draw.image("../../../assets/imgs/puffle_roundup/background.png", background)
    
    -- Desenha puffles
    for _, puffle in ipairs(data.puffles) do
        pico.output.draw.image(puffle.path, puffle.rect)
    end
    
    -- Debug: desenha cercado (comentar depois)
    pico.output.draw.rect(data.cercado, {r=100, g=200, b=100, a=50})
    
    pico.output.draw.image("../../../assets/imgs/puffle_roundup/arvores.png", arvores)
end

function PegaPuffle.finish(state)
    state.pegaPuffleData = nil
end

return PegaPuffle