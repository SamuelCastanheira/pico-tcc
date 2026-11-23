-- O jogo: o estado que vale entre as telas (moedas, cor do pinguim) e a troca
-- de telas. Menu -> centro ou personalização -> menu. Os minigames rodam
-- dentro do centro (Centro).
local Objeto = require("util.objeto")
local Menu = require("screens.telas_menu.menu")
local Personalizacao = require("screens.telas_menu.personalizacao")
local Centro = require("screens.centro.centro")

local Jogo = Objeto:extend()

function Jogo:init ()
    self.moedas = 0
    self.cor_pinguim = "amarelo"
    self.fim = false
    self.tela = Menu:new(self)
end

-- chamado pelo menu: "CENTRO", "PERSON" ou "SAIR"
function Jogo:menu_escolheu (opcao)
    if opcao == "SAIR" then
        self.fim = true
        return
    end
    pico.push()
    if opcao == "CENTRO" then
        self.tela = Centro:new(self)
    else
        self.tela = Personalizacao:new(self)
    end
end

-- chamado pela tela aberta a partir do menu, quando ela termina
function Jogo:volta_menu ()
    pico.pop()
    self.tela = Menu:new(self)
end

function Jogo:ganha_moedas (n)
    self.moedas = self.moedas + n
end

function Jogo:escolhe_cor (cor)
    self.cor_pinguim = cor
end

function Jogo:tempo (dt)   self.tela:tempo(dt)   end
function Jogo:evento (e)   self.tela:evento(e)   end
function Jogo:desenha ()   self.tela:desenha()   end

return Jogo
