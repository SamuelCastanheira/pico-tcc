-- Compara dois traços, quadro a quadro.
-- Uso: lua5.4 compare.lua lua.trc atm.trc [max_divergencias]
--
-- Em cada quadro, o traço é o conjunto dos desenhos (imagem ou texto, com o
-- retângulo arredondado em 4 casas e a rotação). A comparação principal é de
-- conjunto: ignora a ordem e as repetições (desenhar duas vezes o mesmo fundo
-- não muda a tela). Diferenças só de ordem (sobreposição) são contadas à
-- parte, como aviso.
local fa, fb, max = arg[1], arg[2], tonumber(arg[3] or "5")

local function ler (path)
    local t, n = {}, 0
    for linha in io.lines(path) do
        local q, resto = linha:match("^(%d+)\t?(.*)$")
        q = tonumber(q)
        local lista, set, ord = {}, {}, {}
        for item in (resto .. " | "):gmatch("(.-) | ") do
            -- "FIM <resultado>" e "QUIT" são marcas do teste, não desenhos
            if item:match("^FIM ") or item == "QUIT" then item = "" end
            if item ~= "" and not set[item] then
                set[item] = true
                lista[#lista + 1] = item
            end
            if item ~= "" then ord[#ord + 1] = item end
        end
        table.sort(lista)
        t[q] = { set = set, lista = lista, ord = table.concat(ord, " | ") }
        if q > n then n = q end
    end
    return t, n
end

local A, na = ler(fa)
local B, nb = ler(fb)
local n = math.max(na, nb)
local vazio = { set = {}, lista = {}, ord = "" }

local iguais, difs, ordem = 0, 0, 0
local primeira
for q = 1, n do
    local a, b = A[q] or vazio, B[q] or vazio
    local so_a, so_b = {}, {}
    for _, x in ipairs(a.lista) do if not b.set[x] then so_a[#so_a + 1] = x end end
    for _, x in ipairs(b.lista) do if not a.set[x] then so_b[#so_b + 1] = x end end
    if #so_a == 0 and #so_b == 0 then
        iguais = iguais + 1
        if a.ord ~= b.ord then ordem = ordem + 1 end
    else
        difs = difs + 1
        primeira = primeira or q
        if difs <= max then
            print(string.format("quadro %d:", q))
            for _, x in ipairs(so_a) do print("   so em " .. fa:match("[^/]*$") .. ": " .. x) end
            for _, x in ipairs(so_b) do print("   so em " .. fb:match("[^/]*$") .. ": " .. x) end
        end
    end
end

print(string.format("RESUMO: %d quadros, %d iguais, %d diferentes%s; %d iguais com ordem de desenho diferente",
    n, iguais, difs, primeira and (" (primeiro: " .. primeira .. ")") or "", ordem))

-- Janela de 1 quadro (só informativa): o quadro q do Lua bate com algum dos
-- quadros q-1, q, q+1 do Atmos? Mede as defasagens de ordem dentro do quadro
-- (o Lua desenha a tela antiga no quadro da transição; o atmos.env.pico emite
-- o relógio antes do evento de entrada).
local function igual (a, b)
    if #a.lista ~= #b.lista then return false end
    for i = 1, #a.lista do if a.lista[i] ~= b.lista[i] then return false end end
    return true
end
local jdif, jprim = 0, nil
for q = 1, n do
    local a = A[q] or vazio
    local ok = false
    for d = -1, 1 do
        if B[q + d] and igual(a, B[q + d]) then ok = true break end
    end
    if not ok then jdif = jdif + 1; jprim = jprim or q end
end
print(string.format("JANELA ±1: %d diferentes%s", jdif, jprim and (" (primeiro: " .. jprim .. ")") or ""))
os.exit(difs == 0 and 0 or 1)
