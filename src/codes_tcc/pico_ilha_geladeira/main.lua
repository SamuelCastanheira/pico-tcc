local Menu = require("menu")
local  Dojo = require("dojo")

pico.init(true)
local phy = {'!', w=1280, h=720}
pico.set.view{grid=false}
pico.set.dim(phy)
pico.set.expert(true,10)
Menu.renderizar()
pico.init(false)