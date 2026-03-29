require 'pico.check'

print("apenas imprime na layer main com draw.image com single buffer\n\n")
pico.init(true)
    pico.set.window { title="Somente draw image"}
    local background = {'%', x=0.5, y=0.5, w= 1.0, h=1.0}
    local logo = {'%', x= 0.5, y=0.5, w=1.0, h=1.0}

    pico.output.draw.image("../../imgs/background_menu.png", background)
    pico.output.draw.image("../../imgs/logo.png", logo)

    pico.input.delay(6000)
pico.init(false)

print("na layer logo imprime a imagem, que aparece com transparencia nalayer pricipal ao imprimir, teste para demonstrar que assim há transparencia\n\n")
pico.init(true)
     pico.set.window { title="Layer sem mexer na view"}
    pico.layer.empty("logo", {w=100, h=100})
    pico.set.layer("logo")
    local logo = {'%', x= 0.5, y=0.5, w=1.0}
    pico.output.draw.image("../../imgs/logo.png", logo)

    pico.set.layer(nil)
    local background = {'%', x=0.5, y=0.5, w= 1.0, h=1.0}
    pico.output.draw.image("../../imgs/background_menu.png", background)
    pico.output.draw.layer("logo", {'%', x= 0.5, y=0.5, w=1.0})

    pico.input.delay(6000)
pico.init(false)

print("a layer logo apresenta uma zoom (source) e isso não afeta transparencia\n\n")
pico.init(true)
    pico.set.window { title="Layer usando source e rotation"}
    pico.layer.empty("logo", {w=100, h=100})
    pico.set.layer("logo")
    local logo = {'%', x= 0.5, y=0.5, w=1.0}
    pico.output.draw.image("../../imgs/logo.png", logo)
    pico.set.view{ source = { '%', x=0.5, y=0.5, w=0.8, h=0.8},
                   rotation={angle=45, anchor='C'} }


    pico.set.layer(nil)
    local background = {'%', x=0.5, y=0.5, w= 1.0, h=1.0}
    pico.output.draw.image("../../imgs/background_menu.png", background)
    pico.output.draw.layer("logo", {'%', x= 0.5, y=0.5, w=1.0})

    pico.input.delay(6000)
pico.init(false)

print("modifico dim da layer e isso causa perda de transparencia em todos os tipos de rel_dim\n\n")
pico.init(true)
 pico.set.window { title="Layer mudando dim da view"}
    pico.layer.empty("logo", {w=100, h=100})
    pico.set.layer("logo")
    pico.set.view{dim={'!', w=50,h=50}}
    local logo = {'%', x= 0.5, y=0.5, w=1.0}
    pico.output.draw.image("../../imgs/logo.png", logo)
   

    pico.set.layer(nil)
    local background = {'%', x=0.5, y=0.5, w= 1.0, h=1.0}
    pico.output.draw.image("../../imgs/background_menu.png", background)
    pico.output.draw.layer("logo", {'%', x= 0.5, y=0.5, w=1.0})

    pico.input.delay(6000)
pico.init(false)

print("declaro implicitamente a quantidade de quadrados da view alterando o tile do layer, assim, transparencia se mantem. O que causa a perda da transparencia parece ser redimensionar a dim da layer\n\n")
pico.init(true)
 pico.set.window { title="Layer mudando tile da view"}
    pico.layer.empty("logo", {w=100, h=100})
    pico.set.layer("logo")
    pico.set.view{tile={w=20, h=20}}
    local logo = {'%', x= 0.5, y=0.5, w=1.0}
    pico.output.draw.image("../../imgs/logo.png", logo)
    pico.output.draw.rect({'#', x=3, y=3, w=1, h=1})
    
    pico.set.layer(nil)
    local background = {'%', x=0.5, y=0.5, w= 1.0, h=1.0}
    pico.output.draw.image("../../imgs/background_menu.png", background)
    pico.output.draw.layer("logo", {'%', x= 0.5, y=0.5, w=1.0})

    pico.input.delay(6000)
pico.init(false)
