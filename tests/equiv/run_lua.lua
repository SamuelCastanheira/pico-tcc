-- Roda a versão Lua (src/codes_tcc/pico_ilha_geladeira) sob a instrumentação.
-- Uso (de dentro de src/codes_tcc/pico_ilha_geladeira):
--   EQ_ROTEIRO=... EQ_TRACO=... lua5.4 ../../../tests/equiv/run_lua.lua
local dir = arg[0]:match("^(.*)/[^/]*$") or "."
package.path = dir .. "/?.lua;" .. package.path

local pico = require "pico"
local harness = require "harness"
harness.instalar(pico)
_G.pico = pico                  -- o pico-lua faz "lua5.4 -lpico main.lua"

local main = os.getenv("EQ_TELA") and (dir .. "/entrada.lua") or "main.lua"
local ok, err = xpcall(dofile, debug.traceback, main)
harness.fim(ok and ("ok " .. tostring(EQ_RESULTADO or "")) or ("ERRO " .. tostring(err):gsub("\n.*", "")))
if not ok then io.stderr:write(err, "\n") os.exit(1) end
