local Objeto = require("util.objeto")
local Botao = require("util.botao")

local IMGS = "../../assets/imgs/"

local cores = {
    "amarelo", "avermelhado", "azul_forte", "ciano", "cinza",
    "azul_fraco", "laranja", "marrom", "preto", "rosa_medio",
    "roxo", "verde_forte", "verde_medio", "verde_vomito", "vermelho",
}

-- quadro de gelo: layer de 600 x 400 com uma grade de 7 x 5 células; as
-- cores ocupam as colunas 2 a 6 e as linhas 2 a 4
local QUADRO = {'%', x=0.78, y=0.5, w=0.4, h=0.5}

local function cor_rect (i)
    return {'#', x = 2 + ((i-1) % 5), y = 2 + math.floor((i-1) / 5), w=1, h=1}
end

local Personalizacao = Objeto:extend()

function Personalizacao:init (jogo)
    self.jogo = jogo
    self:cria_quadro()
    self.fundo = {'%', x=0.5, y=0.5, w=1, h=1}
    self.r_pinguim = {'%', x=0.3, y=0.35, w=0.3, h=0}
    self.voltar = Botao:new("PERSON", {'%', x=0.3, y=0.8, w=0.3, h=0},
                            IMGS.."botoes/b_voltar.png", IMGS.."botoes/b_voltar_clicado.png")
end

-- o layer é criado a cada entrada na tela: o Jogo abre a tela entre
-- pico.push() e pico.pop()
function Personalizacao:cria_quadro ()
    pico.layer.empty{
        key    = "quadro_gelo",
        dim    = {'!', w=600, h=400},
        tile   = {'#', w=7, h=5},
        target = QUADRO,
    }
    pico.set.layer("quadro_gelo")
    pico.output.draw.image(IMGS.."personalizar/quadro.png", {'#', x=1, y=1, w=7, h=5, anchor='NW'})
    for i = 1, #cores do
        pico.output.draw.image(string.format("%spersonalizar/%d.png", IMGS, i-1), cor_rect(i))
    end
    pico.set.layer("world")
end

-- a cor clicada no quadro (nil fora dele)
function Personalizacao:cor_clicada ()
    local m = pico.get.mouse("quadro_gelo", '#')
    local escolhida = nil
    pico.set.layer("quadro_gelo")
    for i, c in ipairs(cores) do
        if pico.vs.pos.rect(m, cor_rect(i)) then
            escolhida = c
        end
    end
    pico.set.layer("world")
    return escolhida
end

function Personalizacao:tempo (dt)
    self.voltar:tempo(dt)
end

function Personalizacao:evento (e)
    if e.tag == 'mouse.button.dn' then
        local cor = self:cor_clicada()
        if cor then
            self.jogo:escolhe_cor(cor)
        end
    end
    if self.voltar:clicado(e) then
        self.jogo:volta_menu()
    end
end

function Personalizacao:desenha ()
    pico.output.draw.image(IMGS.."background_personalizar.png", self.fundo)
    pico.output.draw.image(string.format("%spersonalizar/pinguim_%s.png", IMGS, self.jogo.cor_pinguim),
                           self.r_pinguim)
    pico.set.pencil{color='white'}
    pico.output.draw.text.fix("Escolha sua cor", {'%', x=0.78, y=0.25, w=0.38, h=0.1})
    pico.output.draw.layer("quadro_gelo", QUADRO)
    self.voltar:desenha()
end

return Personalizacao
