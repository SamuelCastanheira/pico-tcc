-- Controlador para gerar o roteiro do Bean Counters (modo EQ_CONTROLE do
-- harness). Joga a partir do que foi desenhado no quadro anterior:
-- acompanha cada carga entre quadros, prevê onde ela cruza a altura do
-- pinguim, foge dos objetos, vai buscar o café que chega primeiro e entrega
-- na plataforma com 3 cargas. Uma vez, insiste até sobrecarregar (6º café).
-- Segura a seta enquanto quer andar e solta para parar (key / keyup).
local G = 9.8 * (0.5 / 60) ^ 2      -- aceleração por quadro² (tempo a meia velocidade)
local ALTURA = 0.72                  -- y em que a carga começa a tocar a hitbox do pinguim
local sobrecarga_feita = false
local antes = {}
local seta = 0           -- -1, 0, 1: seta que o controlador está segurando
local MAX = 9000

local function num (s) return tonumber(s) end

-- quadros até cruzar ALTURA e x nesse instante (nil se não der para prever)
local function previsao (c)
    if not c.vx then return nil end
    local y, vy, x, n = c.y, c.vy, c.x, 0
    while y < ALTURA and n < 200 do
        vy = vy + G
        y = y + vy
        x = x + c.vx
        n = n + 1
    end
    if y < ALTURA then return nil end
    return n, x
end

return function (q, desenhos)
    if q > MAX then return "quit" end
    local px, carga, tonto, placar = nil, 0, false, 0
    local cargas = {}
    for _, d in ipairs(desenhos) do
        local n, x = d:match("^img bean_counters/penguin(%d)%.webp %%%(([-%d.]+),")
        if n then px, carga = num(x), num(n) end
        local t, x2 = d:match("^img bean_counters/penguin_(%a+)%.webp %%%(([-%d.]+),")
        if t then px, tonto = num(x2), true end
        local tipo, cx, cy, w = d:match("^img bean_counters/(%a[%w_]*)%.webp %%%(([-%d.]+),([-%d.]+),([%d.]+),")
        if tipo and w == "0.08" then
            local c = {tipo = tipo, x = num(cx), y = num(cy)}
            for _, a in ipairs(antes) do      -- a mesma carga no quadro anterior
                if a.tipo == c.tipo and math.abs(a.x - c.x) < 0.02 and math.abs(a.y - c.y) < 0.03 then
                    c.vx, c.vy = c.x - a.x, c.y - a.y
                end
            end
            cargas[#cargas + 1] = c
        end
        local s = d:match("^txt 'Score: (%d+)'")
        if s then placar = num(s) end
    end
    antes = cargas
    if not px then return nil end
    if carga >= 6 then sobrecarga_feita = true end

    local quer_sobrecarga = (not sobrecarga_feita) and placar >= 25
    local perigos, cafes = {}, {}
    for _, c in ipairs(cargas) do
        local n, x = previsao(c)
        if n then
            local perigo = c.tipo ~= "Coffe_bag" or (carga >= 5 and not quer_sobrecarga)
            local lista = perigo and perigos or cafes
            lista[#lista + 1] = {n = n, x = x}
        end
    end

    local function seguro (x)
        for _, p in ipairs(perigos) do
            if p.n < 40 and math.abs(p.x - x) < 0.11 then return false end
        end
        return true
    end

    local alvo
    if quer_sobrecarga or carga < 3 then
        table.sort(cafes, function (a, b) return a.n < b.n end)
        for _, c in ipairs(cafes) do
            local cx = math.min(math.max(c.x, 0.25), 0.8)
            if seguro(cx) then alvo = cx break end
        end
    elseif carga > 0 then
        alvo = 0.25
    end
    -- direção desejada: fugir se o lugar atual não é seguro; senão, ir ao alvo
    local quero = 0
    if not seguro(px) then
        local melhor
        for i = 0, 22 do
            local x = 0.25 + i * 0.025
            if seguro(x) and (not melhor or math.abs(x - px) < math.abs(melhor - px)) then melhor = x end
        end
        if melhor then quero = (melhor > px) and 1 or -1 end
    elseif alvo and math.abs(alvo - px) > 0.02 then
        quero = (alvo > px) and 1 or -1
        if not seguro(px + quero * 0.06) then quero = 0 end
    end
    if tonto then quero = 0 end
    if quero == seta then return nil end
    local nome = { [1] = "Right", [-1] = "Left" }
    local cmd
    if quero == 0 then cmd = "keyup " .. nome[seta] else cmd = "key " .. nome[quero] end
    seta = quero
    return cmd
end
