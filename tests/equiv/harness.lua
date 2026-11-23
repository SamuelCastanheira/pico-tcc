-- Instrumentação de teste para o replay determinístico (Lua x Atmos).
--
-- Não altera o código dos jogos: substitui, dentro do processo, as poucas
-- funções do pico-sdl que trazem não determinismo ou produzem saída:
--
--   pico.input.event  -> entrega os eventos do roteiro, um quadro por chamada
--   pico.get.now      -> relógio virtual (quadro * 1000/60 ms, inteiro)
--   math.randomseed   -> semente fixa (EQ_SEED), qualquer que seja o argumento
--   pico.output.*     -> registra cada desenho do quadro no traço
--
-- O mouse é posicionado com o pico.set.mouse real, para que pico.get.mouse
-- e pico.vs.* continuem sendo os do pico-sdl.
--
-- Variáveis de ambiente:
--   EQ_ROTEIRO  arquivo do roteiro (obrigatório)
--   EQ_TRACO    arquivo de saída do traço (obrigatório)
--   EQ_SEED     semente (padrão 1)
--   EQ_FOTOS    capturas de tela: "quadro=arquivo.png,..." (as do README)
--
-- Formato do roteiro (uma linha por comando; quadro = número da chamada a
-- pico.input.event, a partir de 1; '#' inicia comentário):
--   <quadro> mouse <x%> <y%>     posiciona o mouse (fração da janela)
--   <quadro> click [<x%> <y%>]   evento mouse.button.dn (posiciona antes)
--   <quadro> key <Tecla>         evento key.dn (ex.: Left, Right, Escape)
--   <quadro> quit                evento quit (encerra os dois programas)
-- Um quadro aceita no máximo um evento (como o pico.input.event real).

local M = {}

local FPS = 60
local W, H = 1280, 720

local function now_ms (q)
    return (q * 1000) // FPS
end

local function ler_roteiro (path)
    local mouse, evento = {}, {}
    local ultimo = 0
    for linha in io.lines(path) do
        linha = linha:gsub("#.*", "")
        local q, cmd, a, b = linha:match("^%s*(%d+)%s+(%S+)%s*(%S*)%s*(%S*)")
        if q then
            q = tonumber(q)
            if q > ultimo then ultimo = q end
            if cmd == "mouse" then
                mouse[q] = { tonumber(a), tonumber(b) }
            elseif cmd == "click" then
                if a ~= "" then mouse[q] = { tonumber(a), tonumber(b) } end
                assert(not evento[q], "dois eventos no quadro " .. q)
                evento[q] = { tag = "mouse.button.dn", but = "left" }
            elseif cmd == "key" then
                assert(not evento[q], "dois eventos no quadro " .. q)
                evento[q] = { tag = "key.dn", key = a }
            elseif cmd == "quit" then
                assert(not evento[q], "dois eventos no quadro " .. q)
                evento[q] = { tag = "quit" }
            else
                error("comando desconhecido no roteiro: " .. linha)
            end
        end
    end
    return mouse, evento, ultimo
end

local function arred (v)
    if type(v) ~= "number" then return tostring(v) end
    return string.format("%.4f", v):gsub("%.?0+$", ""):gsub("^%-0$", "0")
end

local function fmt_rect (r)
    if type(r) ~= "table" then return tostring(r) end
    local s = (r[1] or "?") .. "(" .. arred(r.x) .. "," .. arred(r.y) .. "," ..
              arred(r.w) .. "," .. arred(r.h)
    if r.anchor and r.anchor ~= "C" then s = s .. "," .. r.anchor end
    return s .. ")"
end

local function curto (path)
    -- "a//b" e "a/b" abrem o mesmo arquivo: normaliza antes de comparar
    return (tostring(path):gsub("/+", "/"):gsub("^.*/assets/imgs/", ""))
end

function M.instalar (pico)
    local roteiro = assert(os.getenv("EQ_ROTEIRO"), "defina EQ_ROTEIRO")
    local saida = assert(os.getenv("EQ_TRACO"), "defina EQ_TRACO")
    local seed = tonumber(os.getenv("EQ_SEED") or "1")

    local mouse, evento, ultimo = ler_roteiro(roteiro)
    local out = assert(io.open(saida, "w"))

    -- Modo controlador (só para gerar roteiros): EQ_CONTROLE é um arquivo
    -- Lua que devolve function(quadro, desenhos_do_quadro_anterior) -> linha
    -- de roteiro sem o número ("key Right", "mouse 0.5 0.5", "quit") ou nil.
    -- As linhas geradas são acrescentadas ao roteiro EQ_GRAVA.
    local controle, grava = nil, nil
    if os.getenv("EQ_CONTROLE") then
        controle = dofile(os.getenv("EQ_CONTROLE"))
        grava = assert(io.open(assert(os.getenv("EQ_GRAVA"), "defina EQ_GRAVA"), "w"))
        ultimo = math.huge
    end
    local anteriores = {}

    local quadro = 0
    local desenhos = {}
    local angulo = {}       -- rotação corrente por layer (set.effect)
    local layer_cur = nil

    local function fecha_quadro ()
        if quadro > 0 then
            out:write(quadro, "\t", table.concat(desenhos, " | "), "\n")
        end
        anteriores = desenhos
        desenhos = {}
    end

    -- semente fixa ----------------------------------------------------------
    local randomseed = math.randomseed
    math.randomseed = function (...) return randomseed(seed) end
    randomseed(seed)

    -- relógio e entrada -----------------------------------------------------
    pico.get.now = function () return now_ms(quadro) end

    pico.input.event = function (...)
        fecha_quadro()
        quadro = quadro + 1
        if controle then
            local cmd = controle(quadro, anteriores)
            if cmd then
                grava:write(quadro, " ", cmd, "\n")
                grava:flush()
                local c, a, b = cmd:match("^(%S+)%s*(%S*)%s*(%S*)")
                if c == "mouse" then mouse[quadro] = { tonumber(a), tonumber(b) }
                elseif c == "key" then evento[quadro] = { tag = "key.dn", key = a }
                elseif c == "click" then evento[quadro] = { tag = "mouse.button.dn", but = "left" }
                elseif c == "quit" then evento[quadro] = { tag = "quit" } end
            end
        end
        local m = mouse[quadro]
        if m then
            pico.set.mouse { '!', x = math.floor(m[1] * W + 0.5),
                                  y = math.floor(m[2] * H + 0.5) }
        end
        local e = evento[quadro]
        if not e and quadro > ultimo then
            e = { tag = "quit" }        -- roteiro acabou: encerra
        end
        local ms = now_ms(quadro) - now_ms(quadro - 1)
        return e, ms
    end

    pico.input.delay = function () error("pico.input.delay não é instrumentado") end
    pico.set.expert = function () end   -- o relógio virtual dita o ritmo

    local quit = pico.quit
    pico.quit = function ()             -- o "Sair" do menu Lua
        desenhos[#desenhos + 1] = "QUIT"
        fecha_quadro()
        out:close()
        os.exit(0)
    end

    -- registro da saída -----------------------------------------------------
    local function reg (s) desenhos[#desenhos + 1] = s end

    local set_layer = pico.set.layer
    pico.set.layer = function (k, ...)
        layer_cur = k
        return set_layer(k, ...)
    end
    local set_effect = pico.set.effect
    pico.set.effect = function (t, ...)
        if type(t) == "table" and t.rotate and layer_cur then
            angulo[layer_cur] = t.rotate.angle
        end
        return set_effect(t, ...)
    end

    local function img (tipo, path, rect)
        local a = angulo[path]
        local s = "img " .. curto(path) .. " " .. fmt_rect(rect)
        if a and a ~= 0 then s = s .. " rot" .. arred(a) end
        reg(s)
    end

    -- O registro é feito depois da chamada real: o pico-sdl preenche, na
    -- própria tabela do jogo, as dimensões automáticas (w/h ausentes ou 0).
    -- Assim o traço mostra o retângulo efetivamente desenhado.
    local draw = pico.output.draw
    local d_image, d_layer = draw.image, draw.layer
    draw.image = function (path, rect, ...)
        local r = table.pack(d_image(path, rect, ...))
        img("image", path, rect)
        return table.unpack(r, 1, r.n)
    end
    draw.layer = function (key, rect, ...)
        local r = table.pack(d_layer(key, rect, ...))
        img("layer", key, rect)
        return table.unpack(r, 1, r.n)
    end
    local t_fix, t_dyn = draw.text.fix, draw.text.dyn
    draw.text.fix = function (txt, rect, ...)
        local r = table.pack(t_fix(txt, rect, ...))
        reg("txt '" .. tostring(txt) .. "' " .. fmt_rect(rect))
        return table.unpack(r, 1, r.n)
    end
    draw.text.dyn = function (key, txt, rect, ...)
        local r = table.pack(t_dyn(key, txt, rect, ...))
        reg("txt '" .. tostring(txt) .. "' " .. fmt_rect(rect))
        return table.unpack(r, 1, r.n)
    end

    -- fotos (para o README): EQ_FOTOS="quadro=arquivo.png,quadro=arquivo.png"
    local fotos = {}
    for q, arq in (os.getenv("EQ_FOTOS") or ""):gmatch("(%d+)=([^,]+)") do
        fotos[tonumber(q)] = arq
    end
    local present = pico.output.present
    pico.output.present = function (...)
        if fotos[quadro] then
            pico.output.screenshot("world", fotos[quadro])
        end
        local r = table.pack(present(...))
        return table.unpack(r, 1, r.n)
    end

    -- fim do programa (quit pelo roteiro ou fim normal)
    M.fim = function (motivo)
        if motivo then reg("FIM " .. motivo) end
        fecha_quadro()
        out:close()
    end
end

return M
