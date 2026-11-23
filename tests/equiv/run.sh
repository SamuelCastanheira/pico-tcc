#!/bin/sh
# Roda um roteiro nas versões Lua e Atmos e compara os traços.
# Uso: sh tests/equiv/run.sh <roteiro> [semente] [max_divergencias]
#   ex.: sh tests/equiv/run.sh tests/equiv/roteiros/dojo.txt
# Saídas em tests/equiv/out/<roteiro>.{lua,atm}.trc (e .err, se houver erro).
set -u
AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/../.." && pwd)
ROT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
NOME=$(basename "$1" .txt)
OUT=$AQUI/out
mkdir -p "$OUT"

export SDL_VIDEODRIVER=offscreen SDL_AUDIODRIVER=dummy
export EQ_ROTEIRO="$ROT" EQ_SEED="${2:-1}"
# "# tela: <nome>" no roteiro começa direto nessa tela (entrada.lua/.atm)
TELA=$(sed -n "s/^# tela: *//p" "$ROT")
if [ -n "$TELA" ]; then export EQ_TELA="$TELA"; else unset EQ_TELA; fi

( cd "$RAIZ/src/codes_tcc/pico_ilha_geladeira" &&
  EQ_TRACO="$OUT/$NOME.lua.trc" timeout 120 lua5.4 "$AQUI/run_lua.lua" \
      >"$OUT/$NOME.lua.out" 2>"$OUT/$NOME.lua.err" )
( cd "$RAIZ/src/codes_tcc/atmos_ilha_geladeira" &&
  EQ_TRACO="$OUT/$NOME.atm.trc" timeout 120 lua5.4 "$AQUI/run_atm.lua" \
      >"$OUT/$NOME.atm.out" 2>"$OUT/$NOME.atm.err" )

for v in lua atm; do
    [ -s "$OUT/$NOME.$v.err" ] && { echo "== erro em $v:"; head -5 "$OUT/$NOME.$v.err"; }
done
echo "== $NOME (semente ${EQ_SEED})"
lua5.4 "$AQUI/compare.lua" "$OUT/$NOME.lua.trc" "$OUT/$NOME.atm.trc" "${3:-5}"
