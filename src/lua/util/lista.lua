-- Funções de lista usadas pelas telas.
local M = {}

-- tira da lista os objetos com viva == false (de trás para a frente, para
-- não pular nenhum)
function M.tira_mortos (lista)
    for i = #lista, 1, -1 do
        if not lista[i].viva then table.remove(lista, i) end
    end
end

return M
