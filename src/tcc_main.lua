require 'pico.check'
pico.init(true)

local qnt_cores = 15

pico.set.window{title="Personalização", fullscreen = true}
local win = pico.get.window()
local window = win.dim
 local background = {0.5, 0.5, 1,1}
    Pico_Rel_Rect pinguim = { '%', {0.3, 0.35, 0.3, 0}, PICO_ANCHOR_C, NULL };
    Pico_Rel_Rect voltar = { '%', {0.3, 0.8, 0.3, 0}, PICO_ANCHOR_C, NULL };

pico.input.delay(5000)

pico.init(false)