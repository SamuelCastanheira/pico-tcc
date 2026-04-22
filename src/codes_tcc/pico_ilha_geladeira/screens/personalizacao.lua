require 'pico.check'
local Personalizacao = {}

local qnt_cores = 15
local cores = 
{
    {index = 0,  texto="amarelo",     rect={'#', x=2 , y=2 , w=1 , h=1}},
    {index = 1,  texto="avermelhado", rect={'#', x=3 , y=2 , w=1 , h=1}},
    {index = 2,  texto="azul_forte",  rect={'#', x=4 , y=2 , w=1 , h=1}},
    {index = 3,  texto="ciano",       rect={'#', x=5 , y=2 , w=1 , h=1}},
    {index = 4,  texto="cinza",       rect={'#', x=6 , y=2 , w=1 , h=1}},
    {index = 5,  texto="azul_fraco",  rect={'#', x=2 , y=3 , w=1 , h=1}},
    {index = 6,  texto="laranja",     rect={'#', x=3 , y=3 , w=1 , h=1}},
    {index = 7,  texto="marrom",      rect={'#', x=4 , y=3 , w=1 , h=1}},
    {index = 8,  texto="preto",       rect={'#', x=5 , y=3 , w=1 , h=1}},
    {index = 9,  texto="rosa_medio",  rect={'#', x=6 , y=3 , w=1 , h=1}},
    {index = 10, texto="roxo",        rect={'#', x=2 , y=4 , w=1 , h=1}},
    {index = 11, texto="verde_forte", rect={'#', x=3 , y=4 , w=1 , h=1}},
    {index = 12, texto="verde_medio", rect={'#', x=4 , y=4 , w=1 , h=1}},
    {index = 13, texto="verde_vomito",rect={'#', x=5 , y=4 , w=1 , h=1}},
    {index = 14, texto="vermelho",    rect={'#', x=6 , y=4 , w=1 , h=1}},
}

local background = {'%', x=0.5, y=0.5, w=1, h=1}
local pinguim = {'%', x=0.3, y=0.35, w=0.3, h=0}
local voltar = {'%', x=0.3, y=0.8, w=0.3, h=0}
local texto_escolha = {'%', x=0.78, y=0.25, w=0.38, h=0.1}
local layer_place = {'%', x=0.78, y=0.5, w=0.4, h=0.5}

local function cria_layer_quadro()
    local dim = {w=600, h=400}
    local tile = {x=7, y=5}
    pico.layer.empty('=', "quadro_gelo", {w=dim.w, h=dim.h})
    pico.set.layer("quadro_gelo")
    pico.set.view{tile={w=dim.w/tile.x, h=dim.h/tile.y}}
    local quadro_gelo = {'#', x=1, y=1, w=7, h=5, anchor='NW'}
    pico.output.draw.image("../../../assets/imgs/personalizar/quadro.png", quadro_gelo)

    local base = "../../../assets/imgs/personalizar"
    for _, cor in ipairs(cores) do
        local path = string.format("%s/%d.png", base, cor.index)
        pico.output.draw.image(path, cor.rect)
    end
    pico.set.layer(nil)
end

local function mouse_em_cor(state, mouse)
    for _, cor in ipairs(cores) do
        print(mouse.x, mouse.y)
        if pico.vs.pos_rect(mouse, cor.rect) then
            state.personData.cor_select = cor
        end 
    end
end

function Personalizacao.init(state)
    cria_layer_quadro()
    state.personData = {
        cor_select = cores[1]
    }
end

function Personalizacao.update(state, event)
    local mouse = pico.get.mouse('!')
    
    if event and event.tag == 'mouse.button.dn' then
        if pico.vs.pos_rect(mouse, voltar) then
            state.nextScreen = "menu"
        end
    end
    mouse = pico.get.mouse('!', layer_place)
    mouse_em_cor(state, mouse)
end

function Personalizacao.draw(state)
    local mouse = pico.get.mouse('!')
    local img_voltar = pico.vs.pos_rect(mouse, voltar) and "../../../assets/imgs/botoes/b_voltar_clicado.png" or "../../../assets/imgs/botoes/b_voltar.png"
    local base_pinguins = "../../../assets/imgs/personalizar/pinguim"
    local cor_select = state.personData.cor_select

    pico.output.clear()
    pico.output.draw.image("../../../assets/imgs/background_personalizar.png", background)
    pico.output.draw.image(string.format("%s_%s.png", base_pinguins, cor_select.texto), pinguim)
    pico.output.draw.image(img_voltar, voltar)
    pico.output.draw.text("Escolha sua cor", texto_escolha)
    pico.output.draw.layer("quadro_gelo", layer_place)
end

function Personalizacao.finish(state)
    state.personData = nil
end

return Personalizacao
