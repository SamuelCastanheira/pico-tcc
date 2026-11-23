"""Gera um roteiro de pastoreio em malha fechada, simulando com a versão Lua.
Uso (da raiz): python3 -I tests/equiv/gen_cercar.py tests/equiv/roteiros/pega_puffle_cercar.txt 4000 40
O roteiro sai fixo e é o mesmo para as duas versões; só a geração usa o Lua."""
import math, os, re, subprocess, sys
saida, total, passo = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
RAIZ = os.path.abspath(os.path.join(os.path.dirname(saida), "..", "..", ".."))
LUA = os.path.join(RAIZ, "src/codes_tcc/pico_ilha_geladeira")
trc = os.path.join(RAIZ, "tests/equiv/out/gen_cercar.trc")
CERC = (0.425, 0.575, 0.525, 0.775)
def dentro(x, y): return CERC[0] < x < CERC[1] and CERC[2] < y < CERC[3]
cmds = []
def escreve(fim):
    with open(saida, "w") as f:
        f.write("# tela: pega_puffle\n")
        f.write("# Pastoreio em malha fechada (gerado por gen_cercar.py com a versão Lua):\n")
        f.write("# a cada %d quadros, o mouse vai para trás do puffle livre mais próximo\n" % passo)
        f.write("# do cercado e o empurra para a abertura e depois para dentro.\n")
        for c in cmds: f.write(c + "\n")
        f.write("%d quit\n" % fim)
def roda(fim):
    escreve(fim)
    env = dict(os.environ, SDL_VIDEODRIVER="offscreen", EQ_TELA="pega_puffle",
               EQ_ROTEIRO=os.path.abspath(saida), EQ_TRACO=trc)
    subprocess.run(["lua5.4", "../../../tests/equiv/run_lua.lua"], cwd=LUA, env=env,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=120)
    last = None
    for l in open(trc):
        if "puffle_" in l or "Capturados" in l: last = l
    ps = [(float(a), float(b)) for a, b in re.findall(r"puffle_[a-z]+\.png %\(([-\d.]+),([-\d.]+)", last or "")]
    cap = re.search(r"Capturados: (\d+)", last or "")
    return ps, int(cap.group(1)) if cap else 0, "FIM ok centro" in open(trc).read()
os.makedirs(os.path.dirname(trc), exist_ok=True)
q = 1
while q < total:
    ps, cap, acabou = roda(q + 1)
    if acabou: break
    livres = [p for p in ps if not dentro(*p)]
    if not livres: break
    alvo_abertura = (0.5, 0.42)
    def custo(p): return math.hypot(p[0] - 0.5, p[1] - 0.45)
    p = min(livres, key=custo)
    # perto e acima da abertura: empurra para baixo, para dentro; senão, para a abertura
    if abs(p[0] - 0.5) < 0.03 and 0.38 < p[1] < 0.62:
        t = (0.5, 0.70)
    else:
        t = alvo_abertura
    dx, dy = p[0] - t[0], p[1] - t[1]
    d = math.hypot(dx, dy) or 1
    mx, my = p[0] + 0.06 * dx / d, p[1] + 0.06 * dy / d
    mx, my = min(max(mx, 0.01), 0.99), min(max(my, 0.01), 0.99)
    cmds.append("%d mouse %.4f %.4f" % (q, mx, my))
    q += passo
    sys.stderr.write("quadro %d capturados %d livres %d\n" % (q, cap, len(livres)))
escreve(q + 60)
