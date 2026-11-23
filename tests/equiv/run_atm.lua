-- Roda a versão Atmos (src/codes_tcc/atmos_ilha_geladeira) sob a instrumentação.
-- Uso (de dentro de src/codes_tcc/atmos_ilha_geladeira):
--   EQ_ROTEIRO=... EQ_TRACO=... lua5.4 ../../../tests/equiv/run_atm.lua
-- Faz o mesmo que o executável "atmos main.atm", com o pico instrumentado
-- antes de o ambiente atmos.env.pico carregá-lo.
local dir = arg[0]:match("^(.*)/[^/]*$") or "."
package.path = dir .. "/?.lua;" .. package.path

local pico = require "pico"
local harness = require "harness"
harness.instalar(pico)

atmos = require "atmos"
require "atmos.lang.exec"
require "atmos.lang.run"
atmos.thread_modules[#atmos.thread_modules+1] = "atmos"
atmos.thread_modules[#atmos.thread_modules+1] = "atmos.lang.run"

local ok, err = xpcall(function ()
    local main = os.getenv("EQ_TELA") and (dir .. "/entrada.atm") or "main.atm"
    atmos.loop(assert(atm_loadfile(main)))
end, debug.traceback)
harness.fim(ok and ("ok " .. tostring(EQ_RESULTADO or "")) or ("ERRO " .. tostring(err):gsub("\n.*", "")))
if not ok then io.stderr:write(err, "\n") os.exit(1) end
