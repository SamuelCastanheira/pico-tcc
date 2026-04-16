local Dojo = {}

math.randomseed(os.time())

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

local DURACAO_RESULTADO = 1.5

local function novaCarta(elemento, pontuacao, path)
    local carta = {
        elemento = elemento,
        pontuacao = pontuacao,
        path = path,
        rect = {},
        source = {'%', x=0.5, y=0.5, w=0.6, h=0.8}
    }

    pico.layer.image(carta.path)
    pico.set.layer(carta.path)
    pico.set.view{source=carta.source}
    pico.set.layer()

    return carta
end

local function sortearCartas(pool)
    local destino = {}
    local usados = {}

    while #destino < NUM_CARTAS_PLAYER do
        local idx = math.random(1, #pool)

        if not usados[idx] then
            usados[idx] = true
            local base = pool[idx]
            table.insert(destino, novaCarta(base.elemento, base.pontuacao, base.path))
        end
    end

    return destino
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
            w = 0.2,
            h = 0.3
        }
    end
end

local function desenha_mao(mao, isJogador, cartaSelecionada)
    local verso = "../../../assets/imgs/dojo/carta_azul.png"

    for _, carta in ipairs(mao) do
        if carta ~= cartaSelecionada then
            if isJogador then
                pico.output.draw.layer(carta.path, carta.rect)
            else
                pico.output.draw.image(verso, carta.rect)
            end
        end
    end
end


local function init()
    local pool = {
        novaCarta(Elemento.AGUA, 3, "../../../assets/imgs/dojo/agua_3.png"),
        novaCarta(Elemento.FOGO, 4, "../../../assets/imgs/dojo/fogo_4.png"),
        novaCarta(Elemento.FOGO, 7, "../../../assets/imgs/dojo/fogo_7.png"),
        novaCarta(Elemento.GELO, 5, "../../../assets/imgs/dojo/gelo_5.png"),
        novaCarta(Elemento.GELO, 6, "../../../assets/imgs/dojo/gelo_6.png")
    }

    local jogo = {
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

    ordena_mao(jogo.cartasJogador, true)
    ordena_mao(jogo.cartasNPC, false)

    return jogo
end

local function update(jogo, agora)
    if jogo.estado == DuelState.SELECIONANDO then

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
    end
end

local function draw(jogo)
    local background = {'%', x=0.5, y=0.5, w=1, h=1}
    local rect_jogador = {'%', x=0.8, y=0.3, w=0.5, h=0}
    local rect_npc = {'%', x=0.2, y=0.3, w=0.5, h=0}

    pico.output.draw.image("../../../assets/imgs/dojo/background.png", background)

    desenha_mao(jogo.cartasNPC, false, jogo.cartaSelecionada)
    desenha_mao(jogo.cartasJogador, true, jogo.cartaSelecionada)

    if jogo.estado == DuelState.MOSTRANDO_RESULTADO and jogo.cartaSelecionada and jogo.cartaNPCSelecionada then

        pico.output.draw.image(jogo.cartaSelecionada.path, rect_jogador)
        pico.output.draw.image(jogo.cartaNPCSelecionada.path, rect_npc)

        if jogo.resultado == ResultadoState.GANHOU then
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/x.png", rect_npc)

        elseif jogo.resultado == ResultadoState.PERDEU then
            pico.output.draw.image("../../../assets/imgs/dojo/x.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_npc)

        else
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_jogador)
            pico.output.draw.image("../../../assets/imgs/dojo/ok.png", rect_npc)
        end
    end
end

function Dojo.renderizar()
    pico.set.window{title="Dojo"}

    local jogo = init()

    while true do
        local e = pico.input.event()
        local mouse = pico.get.mouse('%')
        local agora = os.time()

        if e and e.tag == 'quit' then break end

        if e and e.tag == 'mouse.button.dn' and jogo.estado == DuelState.SELECIONANDO then
            for _, carta in ipairs(jogo.cartasJogador) do
                if pico.vs.pos_rect(mouse, carta.rect) then
                    jogo.cartaSelecionada = carta
                    break
                end
            end
        end

        update(jogo, agora)

        if jogo.estado == DuelState.FINALIZADO then
            break
        end

        draw(jogo)

        pico.output.present()
    end
end

return Dojo