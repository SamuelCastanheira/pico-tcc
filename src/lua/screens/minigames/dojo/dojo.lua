-- Dojo: três rodadas de cartas contra o inimigo. Em cada rodada o jogador
-- clica numa carta da mão, o inimigo joga uma ao acaso, e o resultado fica
-- 2 s na tela. Prêmio: 100 moedas se vencer mais rodadas, 50 no empate.
local Objeto = require("util.objeto")
local Temporizador = require("util.temporizador")
local Carta = require("screens.minigames.dojo.carta")

local IMGS = "../../assets/imgs/dojo/"
local NUM_CARTAS = 3

local BARALHO = {
    {elem = "FOGO", poder = 4, img = IMGS.."fogo_4.png"},
    {elem = "FOGO", poder = 7, img = IMGS.."fogo_7.png"},
    {elem = "GELO", poder = 5, img = IMGS.."gelo_5.png"},
    {elem = "GELO", poder = 6, img = IMGS.."gelo_6.png"},
}

-- posição da i-ésima carta (a partir de 0) na mão de cada lado
local function rect_mao (dono, i)
    local x0  = (dono == "player") and 0.9 or 0.1
    local dir = (dono == "player") and -1 or 1
    return {'%', x = x0 + (dir * i * 0.12), y = 0.88, w = 0.1, h = 0.2}
end

local Dojo = Objeto:extend()

function Dojo:init ()
    pico.set.window{title="Dojo"}
    self.fundo = {'%', x=0.5, y=0.5, w=1, h=1}
    self.vitorias = 0
    self.derrotas = 0
    self.rodada = 0
    self.espera = nil       -- prazo do resultado da rodada (nil: esperando o clique)
    self.mao = { player = self:sorteia("player"), enemy = self:sorteia("enemy") }
end

-- NUM_CARTAS cartas diferentes do baralho, sorteadas ao acaso
function Dojo:sorteia (dono)
    local mao, usadas = {}, {}
    while #mao < NUM_CARTAS do
        local idx = math.random(1, #BARALHO)
        if not usadas[idx] then
            usadas[idx] = true
            local c = BARALHO[idx]
            mao[#mao + 1] = Carta:new(dono, rect_mao(dono, #mao), c.img, c.elem, c.poder)
        end
    end
    return mao
end

-- reposiciona as cartas que ficam na mão, sem a jogada
function Dojo:arruma (dono, jogada)
    local i = 0
    for _, c in ipairs(self.mao[dono]) do
        if c ~= jogada then
            c:move(rect_mao(dono, i))
            i = i + 1
        end
    end
end

function Dojo:joga (carta)
    local inimigo = self.mao.enemy[math.random(1, #self.mao.enemy)]
    self:arruma("player", carta)
    self:arruma("enemy", inimigo)
    local r = carta:compara(inimigo)
    if r > 0 then self.vitorias = self.vitorias + 1 end
    if r < 0 then self.derrotas = self.derrotas + 1 end
    carta:joga(r)
    inimigo:joga(-r)
    self.rodada = self.rodada + 1
    self.espera = Temporizador:new(2 * Temporizador.S)
end

function Dojo:evento (e)
    if self.espera then return nil end
    for _, c in ipairs(self.mao.player) do
        if c:clicada(e) then
            self:joga(c)
            return nil
        end
    end
    return nil
end

local function tira_mortas (cartas)
    for i = #cartas, 1, -1 do
        if not cartas[i].viva then table.remove(cartas, i) end
    end
end

-- devolve o prêmio quando as rodadas acabam
function Dojo:tempo (dt)
    for _, dono in ipairs{"player", "enemy"} do
        for _, c in ipairs(self.mao[dono]) do
            c:tempo(dt)
        end
        tira_mortas(self.mao[dono])
    end
    if self.espera and self.espera:tempo(dt) then
        self.espera = nil
        if self.rodada == NUM_CARTAS then
            if self.vitorias > self.derrotas then return 100 end
            if self.vitorias == self.derrotas then return 50 end
            return 0
        end
    end
    return nil
end

function Dojo:desenha ()
    pico.output.draw.image(IMGS.."background.png", self.fundo)
    for _, dono in ipairs{"player", "enemy"} do
        for _, c in ipairs(self.mao[dono]) do
            c:desenha()
        end
    end
end

return Dojo
