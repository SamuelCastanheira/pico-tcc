#!/usr/bin/env python3
"""Métricas de comparação entre as versões Lua e Atmos do pico-tcc.

Uso: python3 tools/metricas.py            (tabelas em Markdown na saída)
     python3 tools/metricas.py --listas   (também lista as variáveis de estado)

Para cada programa (par de arquivos Lua x Atmos), mede:
- linhas de código (sem linhas em branco e sem comentários);
- Lua: funções, condicionais (if/elseif) e campos de estado mutáveis
  (alvos distintos de atribuição `self.campo =` ou `self.x.campo =`);
- Atmos: tasks, variáveis mutáveis (`var`), alvos distintos de `set`, e as
  construções de concorrência (spawn, await, watching, par, loop on, toggle,
  emit, tasks/pin, every/defer, abort).
As contagens são léxicas (expressões regulares sobre o texto, sem parser).
"""
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LUA = RAIZ / "src/codes_tcc/pico_ilha_geladeira"
ATM = RAIZ / "src/codes_tcc/atmos_ilha_geladeira"

PROGRAMAS = [
    ("main e jogo (fluxo de telas)", ["main.lua", "jogo.lua"], ["main.atm"]),
    ("menu", ["screens/telas_menu/menu.lua"], ["screens/telas_menu/menu.atm"]),
    ("personalização", ["screens/telas_menu/personalizacao.lua"],
     ["screens/telas_menu/personalizar.atm"]),
    ("centro", ["screens/centro/centro.lua", "screens/centro/pinguim.lua",
                "screens/centro/predio.lua"],
     ["screens/centro/centro.atm", "screens/centro/pinguim.atm",
      "screens/centro/predio.atm"]),
    ("dojo", ["screens/minigames/dojo/dojo.lua", "screens/minigames/dojo/carta.lua"],
     ["screens/minigames/dojo/dojo.atm", "screens/minigames/dojo/carta.atm"]),
    ("bean counters",
     ["screens/minigames/bean_counters/" + f for f in
      ("bean_counters.lua", "pinguim.lua", "carga.lua", "pilha.lua", "plataforma.lua")],
     ["screens/minigames/bean_counters/" + f for f in
      ("bean_counters.atm", "pinguim.atm", "carga.atm", "pilha.atm", "plataforma.atm")]),
    ("pega puffles",
     ["screens/minigames/pega_puffles/pega_puffles.lua",
      "screens/minigames/pega_puffles/puffle.lua"],
     ["screens/minigames/pega_puffles/pega_puffles.atm",
      "screens/minigames/pega_puffles/puffle.atm"]),
    ("utilitários e componentes",
     ["util/objeto.lua", "util/temporizador.lua", "util/botao.lua"],
     ["util/vetor.atm"] + ["util/components/" + f for f in
      ("image.atm", "image_hover.atm", "botao.atm", "xclickable.atm", "xcollidable.atm")]),
]
# Arquivos que existem mas não são usados pelo programa (cor.atm não é requerido).
NAO_USADOS = ["screens/telas_menu/cor.atm"]


def linhas_codigo(texto, coment):
    n = 0
    for l in texto.splitlines():
        l = l.strip()
        if l and not l.startswith(coment):
            n += 1
    return n


def sem_strings_e_comentarios(texto, coment):
    texto = re.sub(r'"(\\.|[^"\\])*"|\'(\\.|[^\'\\])*\'', '""', texto)
    return "\n".join(l.split(coment)[0] for l in texto.splitlines())


def medir_lua(arqs):
    m = dict(loc=0, funcoes=0, ifs=0, campos=set(), enums=set(), globais_estado=set())
    for a in arqs:
        t = (LUA / a).read_text(encoding="utf-8")
        m["loc"] += linhas_codigo(t, "--")
        c = sem_strings_e_comentarios(t, "--")
        m["funcoes"] += len(re.findall(r"\bfunction\b", c))
        m["ifs"] += len(re.findall(r"\b(if|elseif)\b", c))
        for obj, campo in re.findall(r"\b(self(?:\.[a-z_]+)?)\.([A-Za-z_]\w*)\s*=(?!=)", c):
            m["campos"].add(f"{obj}.{campo}")
        for nome in re.findall(r"\blocal\s+([A-Z]\w*)\s*=\s*\{\s*\n\s*[A-Z_]+\s*=", c):
            m["enums"].add(nome)
    return m


CONSTRUCOES = {
    "spawn": r"\bspawn\b",
    "await": r"\bawait\b",
    "watching": r"\bwatching\b",
    "par": r"\bpar\b",
    "loop on": r"\bloop\b[^\n{]*\bon\b",
    "toggle": r"\btoggle\b",
    "emit": r"\bemit\b",
    "tasks/pin": r"\b(tasks|pin)\b",
    "abort": r"\babort\b",
    "defer": r"\bdefer\b",
}


def medir_atm(arqs):
    m = dict(loc=0, tasks=0, funcs=0, ifs=0, vars=0, sets=set(),
             **{k: 0 for k in CONSTRUCOES})
    for a in arqs:
        t = (ATM / a).read_text(encoding="utf-8")
        m["loc"] += linhas_codigo(t, ";;")
        c = sem_strings_e_comentarios(t, ";;")
        m["tasks"] += len(re.findall(r"^\s*task\s+\w+\s*\(", c, re.M))
        m["funcs"] += len(re.findall(r"^\s*(val\s+)?func\b", c, re.M))
        m["ifs"] += len(re.findall(r"\b(if|ifs)\b", c))
        m["vars"] += len(re.findall(r"\bvar\b", c))
        for alvo in re.findall(r"\bset\s+([A-Za-z_][\w.@]*)", c):
            m["sets"].add(alvo)
        for k, rx in CONSTRUCOES.items():
            m[k] += len(re.findall(rx, c))
    return m


def main():
    listas = "--listas" in sys.argv
    print("## Tamanho e forma, por programa\n")
    print("| Programa | LOC Lua | LOC Atmos | Atmos/Lua | funções Lua | tasks+funcs Atmos | if/elseif Lua | if/ifs Atmos |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|")
    tot = [0, 0]
    res = []
    for nome, la, aa in PROGRAMAS:
        l, a = medir_lua(la), medir_atm(aa)
        res.append((nome, l, a))
        tot[0] += l["loc"]
        tot[1] += a["loc"]
        print(f"| {nome} | {l['loc']} | {a['loc']} | {a['loc']/l['loc']:.2f} | {l['funcoes']} | "
              f"{a['tasks']}+{a['funcs']} | {l['ifs']} | {a['ifs']} |")
    print(f"| **total** | **{tot[0]}** | **{tot[1]}** | **{tot[1]/tot[0]:.2f}** | | | | |\n")

    print("## Estado mutável e controle de fase\n")
    print("| Programa | campos de estado Lua | `var` Atmos | alvos de `set` Atmos |")
    print("|---|---:|---:|---:|")
    for nome, l, a in res:
        print(f"| {nome} | {len(l['campos'])} | {a['vars']} | {len(a['sets'])} |")
    print()

    print("## Construções de concorrência no Atmos\n")
    ks = list(CONSTRUCOES)
    print("| Programa | " + " | ".join(ks) + " |")
    print("|---|" + "---:|" * len(ks))
    for nome, l, a in res:
        print(f"| {nome} | " + " | ".join(str(a[k]) for k in ks) + " |")
    print()

    if listas:
        print("## Listas\n")
        for nome, l, a in res:
            print(f"### {nome}\n")
            print("- Lua, campos atribuídos: " + ", ".join(f"`{x}`" for x in sorted(l["campos"])))
            print("- Atmos, alvos de `set`: " + ", ".join(f"`{x}`" for x in sorted(a["sets"])))
            print()
    print("Arquivos presentes e não usados: " + ", ".join(f"`{x}`" for x in NAO_USADOS))


if __name__ == "__main__":
    main()
