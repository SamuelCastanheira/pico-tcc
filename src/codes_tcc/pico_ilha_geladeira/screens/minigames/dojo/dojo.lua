local Dojo = {}
local Objeto = require("util.objeto")
local Carta = require("screens.minigames.dojo.carta")

local NUM_CARTAS_PLAYER = 3

local Elemento = {
    GELO = 1,
    AGUA = 2,
    FOGO = 3
}

local DuelState = {
    SELECIONANDO = 1,
    COMPARANDO = 2,
    MOSTRANDO_RESULTADO = 3,
    FINALIZADO = 4
}

local ResultadoState = {
    EMPATE = 0,
    GANHOU = 1,
    PERDEU = -1
}

local DURACAO_RESULTADO = 1500

local function sortearCartas(pool)
    local mao = {}
    local cartas_na_mao = {}

    while #mao < NUM_CARTAS_PLAYER do
        local idx = math.random(1, #pool)

        if not cartas_na_mao[idx] then
            cartas_na_mao[idx] = true
            local carta = pool[idx]
            table.insert(mao, carta:copy())
        end
    end

    return mao
end

local function compararCartas(a, b)
    if a.elemento == b.elemento then
        if a.pontuacao > b.pontuacao then return ResultadoState.GANHOU end
        if a.pontuacao < b.pontuacao then return ResultadoState.PERDEU end
        return ResultadoState.EMPATE
    end

    if (a.elemento == Elemento.GELO and b.elemento == Elemento.AGUA) or
       (a.elemento == Elemento.AGUA and b.elemento == Elemento.FOGO) or
       (a.elemento == Elemento.FOGO and b.elemento == Elemento.GELO) then
        return ResultadoState.GANHOU
    end

    return ResultadoState.PERDEU
end

local function removerCarta(lista, alvo)
    for i, v in ipairs(lista) do
        if v == alvo then
            table.remove(lista, i)
            return
        end
    end
end

local function ordena_mao(mao, isJogador)
    local baseX = isJogador and 0.9 or 0.1
    local dir = isJogador and -1 or 1

    for i, carta in ipairs(mao) do
        carta.rect = {
            '%',
            x = baseX + dir * (i - 1) * 0.12,
            y = 0.88,
            w = 0.1,
            h = 0.2
        }
    end
end

local function desenha_mao(mao, isJogador, cartaSelecionada)
    for _, carta in ipairs(mao) do
        if carta ~= cartaSelecionada then
            if isJogador then
                pico.output.draw.image(carta.img, carta.rect)
            else
                pico.output.draw.image(carta:get_verso(), carta.rect)
            end
        end
    end
end


function Dojo.init(state)
    pico.set.window{title="Dojo"}
    math.randomseed(pico.get.now())
    
    local pool = {
        Carta.create({
                    elemento = Elemento.AGUA, 
                    pontuacao = 3, 
                    img="../../../assets/imgs/dojo/agua_3.png"}),
        Carta.create({
                    elemento =Elemento.FOGO,
                    pontuacao =4, 
                    img="../../../assets/imgs/dojo/fogo_4.png"}),
        Carta.create({
                    elemento =Elemento.FOGO, 
                    pontuacao =7, 
                    img="../../../assets/imgs/dojo/fogo_7.png"}),
        Carta.create({
                    Elemento.GELO, 
                    pontuacao =5, 
                    img="../../../assets/imgs/dojo/gelo_5.png"}),
        Carta.create({
                    Elemento.GELO, 
                    pontuacao =6, 
                    img="../../../assets/imgs/dojo/gelo_6.png"})
    }

    state.dojoData = {
        estado = DuelState.SELECIONANDO,
        cartasJogador = sortearCartas(pool),
        cartasNPC = sortearCartas(pool),
        jogadorScore = 0,
        npcScore = 0,
        resultado = ResultadoState.EMPATE,
        cartaSelecionada = nil,
        cartaNPCSelecionada = nil,
        tempoResultado = 0
    }

    ordena_mao(state.dojoData.cartasJogador, true)
    ordena_mao(state.dojoData.cartasNPC, false)
end

function Dojo.update(state, event)
    local jogo = state.dojoData
    local agora = pico.get.now()
    local mouse = pico.get.mouse('%')

    if event and event.tag == 'mouse.button.dn' and jogo.estado == DuelState.SELECIONANDO then
        for _, carta in ipairs(jogo.cartasJogador) do
            if pico.vs.pos_rect(mouse, carta.rect) then
                jogo.cartaSelecionada = carta
                break
            end
        end
    end

    if jogo.estado == DuelState.SELECIONANDO then
        if event and event.tag == 'mouse.button.dn' then
            for _, carta in ipairs(jogo.cartasJogador) do
                if pico.vs.pos_rect(mouse, carta.rect) then
                    jogo.cartaSelecionada = carta
                    break
                end
            end
        end

        if jogo.cartaSelecionada and not jogo.cartaNPCSelecionada then
            jogo.cartaNPCSelecionada = jogo.cartasNPC[math.random(1, #jogo.cartasNPC)]
        end

        if jogo.cartaSelecionada and jogo.cartaNPCSelecionada then
            jogo.estado = DuelState.COMPARANDO
        end

    elseif jogo.estado == DuelState.COMPARANDO then
        jogo.resultado = compararCartas(jogo.cartaSelecionada, jogo.cartaNPCSelecionada)

        if jogo.resultado == ResultadoState.GANHOU then
            jogo.jogadorScore = jogo.jogadorScore + 3
        elseif jogo.resultado == ResultadoState.PERDEU then
            jogo.npcScore = jogo.npcScore + 3
        else
            jogo.jogadorScore = jogo.jogadorScore + 1
            jogo.npcScore = jogo.npcScore + 1
        end

        jogo.tempoResultado = agora
        jogo.estado = DuelState.MOSTRANDO_RESULTADO

    elseif jogo.estado == DuelState.MOSTRANDO_RESULTADO then
        if agora - jogo.tempoResultado >= DURACAO_RESULTADO then
            removerCarta(jogo.cartasJogador, jogo.cartaSelecionada)
            removerCarta(jogo.cartasNPC, jogo.cartaNPCSelecionada)

            jogo.cartaSelecionada = nil
            jogo.cartaNPCSelecionada = nil

            ordena_mao(jogo.cartasJogador, true)
            ordena_mao(jogo.cartasNPC, false)

            if #jogo.cartasJogador == 0 or #jogo.cartasNPC == 0 then
                jogo.estado = DuelState.FINALIZADO
            else
                jogo.estado = DuelState.SELECIONANDO
            end
        end

    elseif jogo.estado == DuelState.FINALIZADO then
        if jogo.jogadorScore > jogo.npcScore then
            state.money = state.money + 100
        elseif jogo.jogadorScore == jogo.npcScore then
            state.money = state.money + 50
        end
        state.nextScreen = "menu"
    end
end



function Dojo.draw(state)
    local jogo = state.dojoData
    local background = {'%', x=0.5, y=0.5, w=1, h=1}
    local rect_jogador = {'%', x=0.8, y=0.3, w=0.2, h=0}
    local rect_npc = {'%', x=0.2, y=0.3, w=0.2, h=0}

    pico.output.draw.image("../../../assets/imgs/dojo/background.png", background)
    pico.output.draw.image("../../../assets/imgs/dojo/background.png", background)

    desenha_mao(jogo.cartasNPC, false, jogo.cartaNPCSelecionada)
    desenha_mao(jogo.cartasJogador, true, jogo.cartaSelecionada)

    if jogo.estado == DuelState.MOSTRANDO_RESULTADO then

        pico.output.draw.image(jogo.cartaSelecionada.img, rect_jogador)
        pico.output.draw.image(jogo.cartaNPCSelecionada.img, rect_npc)
        pico.output.draw.image(jogo.cartaSelecionada.img, rect_jogador)
        pico.output.draw.image(jogo.cartaNPCSelecionada.img, rect_npc)

        if jogo.resultado == ResultadoState.GANHOU then
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/x.png", rect_npc)
        elseif jogo.resultado == ResultadoState.PERDEU then
            pico.output.draw.image("../../../assets/imgs/dojo/x.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_npc)
        elseif jogo.resultado == ResultadoState.PERDEU then
            pico.output.draw.image("../../../assets/imgs/dojo/x.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_npc)

        else
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_npc)
        end
    end
end

function Dojo.finish(state)
    state.nextScreen = "centro"
end

return Dojo