# Equivalência entre as versões Lua e Atmos

Parte 4 do apoio ao TCC: um método reproduzível para verificar se a versão
Atmos (`src/atmos`) e a versão Lua
(`src/lua`) fazem a mesma coisa, inspirado no
replay determinístico do `lua_doom`.

**Situação em 23/11/2026: as duas versões são equivalentes.** Em todos os
roteiros (seção 3), com as sementes 1, 2, 3 e 7, **todos os quadros são
iguais**, inclusive a ordem de desenho. Isso vale para cada tela isolada e
para o jogo inteiro pelos `main.lua` e `main.atm` (menu, personalização,
centro, os três minigames, Escape de dentro de um minigame e "Sair").

---

## 1. Decisões do usuário (23/11/2026)

| Id | Questão | Decisão |
|---|---|---|
| D1 | Qual versão vale quando as duas têm a mesma regra de jeitos diferentes? | **A do Atmos**, a última feita e aprimorada. O que só o Lua tinha entra no Atmos. A versão Lua passa a ser mais orientada a objetos e encapsulada |
| D1a | Personalização e Pega Puffles, alinhados ao Lua na rodada anterior | **Pega Puffles com as regras do Lua**; **personalização com a escolha por clique do Atmos** |
| D2 | `carga_maxima` no Bean Counters: o 2 da cópia de trabalho ou 5 | **5** (o 2 era teste local) |
| D3 | A defasagem de um quadro nas transições | **Aceitar ±1 quadro** como critério. Com o novo laço do Lua (seção 2), a defasagem sumiu e a comparação estrita passou |
| D4 | A personalização em Lua, que não rodava | **Consertar o Lua** |

A primeira rodada, com o Lua como referência para tudo, está nos commits
`b9bbef0` a `2a5f89d`.

## 2. Método

**Ideia.** As mesmas entradas, numa sequência roteirizada e com o tempo
controlado, devem produzir a mesma saída nas duas versões, quadro a quadro.

**O que se compara.** As versões não têm estruturas de dados em comum
(objetos Lua × tasks e `pub` no Atmos). A interface comum é o que cada uma
*desenha* com o pico-sdl. O traço de um quadro é o conjunto dos desenhos
daquele quadro: cada imagem com o retângulo efetivo (arredondado em 4 casas)
e a rotação, e cada texto com o seu retângulo. Os números do jogo (moedas,
placar, vidas, tempo) entram no traço porque são desenhados. A comparação é
de caixa-preta: não exige mudar o código dos jogos.

**Critério.** Dois quadros são iguais se os conjuntos de desenhos são iguais;
a ordem (sobreposição) é conferida à parte e também bate. O comparador mostra
ainda a "janela de ±1 quadro" aceita em D3, que hoje não é necessária.

**O mesmo laço nas duas versões.** O ambiente `atmos.env.pico` faz, a cada
quadro: emite o tempo decorrido, emite o evento de entrada (se houver) e
emite `:draw`. O `main.lua` agora faz o mesmo: `jogo:tempo(dt)`, depois
`jogo:evento(e)`, depois `jogo:desenha()`, com as trocas de tela imediatas.
Por isso não há mais defasagem de um quadro nas transições.

**O tempo do Atmos, reproduzido no Lua.** No runtime do Atmos, um `await` de
tempo começa do zero (não herda o excedente do anterior), soma os `:clock`
*seguintes* ao da sua criação e acorda quando a soma alcança o prazo. O
`Temporizador` do Lua conta do mesmo jeito, em microssegundos, e as classes
só avançam um prazo a partir do passo seguinte ao da criação. A ordem dos
passos dentro do quadro segue a ordem em que o Atmos percorre a árvore de
tasks (filhos antes do pai, na ordem do código).

**Fontes de não determinismo e como foram eliminadas** (instrumentação só de
teste, em `tests/equiv/harness.lua`):

| Fonte | No teste |
|---|---|
| relógio real e espera do modo *expert* | relógio virtual: o quadro *q* acontece em `floor(q·1000/60)` ms; o `pico.input.event` devolve a diferença (16 ou 17 ms). As duas versões rodam a 60 quadros/s também no jogo real |
| `math.random` | `math.randomseed` semeia sempre com `EQ_SEED`. As duas versões semeiam uma vez, no início |
| entrada do usuário | vem do roteiro: um evento por quadro, no máximo; o mouse é posicionado com o `pico.set.mouse` real |
| ordem de `pairs` | o Lua 5.4 sorteia a semente do hash de strings, e a ordem de `pairs` em chaves string pode mudar entre execuções. As paredes do cercado viraram uma lista de ordem fixa nas duas versões (U8); não restou `pairs` sobre estado |
| janela e GPU | o pico-sdl real roda no driver `offscreen` do SDL (sem janela) |

**Isolamento.** `tests/equiv/entrada.lua` e `entrada.atm` começam direto numa
tela (`# tela: <nome>` no roteiro) e terminam quando ela termina.

## 3. Arquivos e como reproduzir

| Arquivo | Papel |
|---|---|
| `tests/equiv/harness.lua` | instrumentação: relógio, entrada, semente, registro do traço, modo controlador e capturas de tela (`EQ_FOTOS`, usadas no README) |
| `tests/equiv/run_lua.lua`, `run_atm.lua` | rodam cada versão sob a instrumentação |
| `tests/equiv/entrada.lua`, `entrada.atm` | entradas de teste que começam numa tela |
| `tests/equiv/compare.lua` | compara dois traços |
| `tests/equiv/run.sh` | roda um roteiro nas duas versões e compara |
| `tests/equiv/roteiros/*.txt` | roteiros |
| `tests/equiv/gen_cercar.py`, `controles/bean.lua` | geradores de roteiros (pastoreio dos puffles; jogador do Bean Counters) |
| `tests/equiv/out/` | traços gerados (fora do git) |

```bash
sh tests/equiv/run.sh tests/equiv/roteiros/fluxo.txt
```

```bash
for r in tests/equiv/roteiros/*.txt; do sh tests/equiv/run.sh "$r" "" 0 | grep -E '^(==|RESUMO)'; done
```

Argumentos de `run.sh`: roteiro, semente (vazio: a do roteiro, `# semente: N`,
ou 1) e quantos quadros divergentes mostrar. O código de saída é 0 quando
todos os quadros batem.

Formato do roteiro (o quadro é o número da chamada a `pico.input.event`, a
partir de 1):

```
# tela: dojo          (opcional: começa direto nesta tela)
# semente: 41         (opcional)
1 mouse 0.5 0.5       posiciona o mouse (fração da janela)
10 click 0.9 0.88     clique (mouse.button.dn), posicionando antes
30 key Right          tecla (key.dn)
650 quit              encerra
```

**Modo controlador.** Para gerar roteiros que joguem de verdade:
`EQ_CONTROLE=<script.lua>` faz o harness chamar, a cada quadro, uma função
que recebe os desenhos do quadro anterior e devolve o comando do quadro;
`EQ_GRAVA=<arquivo>` guarda o roteiro gerado. O roteiro sai fixo e é rodado
nas duas versões como qualquer outro. Exemplo, da pasta da versão Lua:

```bash
SDL_VIDEODRIVER=offscreen EQ_TELA=bean_counters EQ_SEED=41 EQ_ROTEIRO=roteiro_vazio.txt EQ_TRACO=/tmp/t.trc EQ_CONTROLE=../../tests/equiv/controles/bean.lua EQ_GRAVA=/tmp/gerado.txt lua5.4 ../../tests/equiv/run_lua.lua
```

## 4. Roteiros e resultados

| Roteiro | Tela | O que exercita | Quadros iguais |
|---|---|---|---|
| `smoke.txt` | jogo inteiro | *hover* no menu, "Jogar", entrada no centro | 40/40 |
| `person.txt` | personalização | *hover* sobre cores (sem efeito), clique numa cor, outra cor, "Voltar" | 80/80 |
| `centro.txt` | centro | caminhada, troca de destino, chegada ao Dojo pela hitbox e o Dojo aninhado | 600/600 |
| `dojo.txt` | Dojo | três rodadas até o prêmio (100 moedas) | 520/520 |
| `bean_counters.txt` | Bean Counters | idas e vindas, coletas, entregas, os três acertos até o fim | 854/854 |
| `bean_counters_jogo.txt` (semente 41) | Bean Counters | jogador gerado: enche a primeira pilha e põe 7 cafés na segunda | 3044/3044 |
| `bean_counters_sobrecarga.txt` (semente 24) | Bean Counters | jogador gerado: pega o 6º café e é derrubado | 2002/2002 |
| `pega_puffle.txt` | Pega Puffles | o mouse numa curva: empurrões entre puffles e 3 fugas | 901/901 |
| `pega_puffle_cercar.txt` | Pega Puffles | pastoreio: paredes, 8 capturas, 2 fugas e vitória (80 moedas) | 1816/1816 |
| `fluxo.txt` | jogo inteiro | personaliza a cor, ganha o Dojo, volta ao centro, sai do Pega Puffles e do Bean Counters com Escape, "Sair" | 1550/1550 |

Com as sementes 2, 3 e 7, `centro`, `dojo`, `bean_counters`, `pega_puffle` e
`fluxo` também dão todos os quadros iguais.

**Vitória no Bean Counters.** Nenhum roteiro enche as duas pilhas de 10
(o controlador perde as vidas antes). O fim por pilhas cheias foi conferido
em cópias das duas versões com pilhas de 2, no roteiro `bean_counters_jogo`:
1224/1224 quadros iguais, depois de corrigir no Lua a plataforma que ainda
recebia cafés com as duas pilhas cheias.

### 4.1 Sensibilidade (mutações)

Cada mutação foi aplicada a uma cópia e comparada com a outra versão sem
mudança.

**Pega Puffles** (no `puffle.atm`, roteiro `pega_puffle_cercar`): detectadas
a cerca somando em vez de substituir (quadro 551), o empurrão com sinal
trocado (1), o raio 0,06 (4), a fuga depois de andar (797) e o passo 1% maior
(1). Equivalente: o fator 0,2 da cerca (a direção é normalizada antes de
andar). Não coberta: empurrar puffles que já fugiram.

**Bean Counters** (no Lua, roteiro `bean_counters_jogo`):

| Mutação | Resultado |
|---|---|
| o bloqueio da plataforma conta já no quadro em que nasce | detectada (quadro 933) |
| o bloqueio avança antes da entrega, no mesmo quadro | detectada (972) |
| a troca do prazo de lançamento no quadro do acerto é ignorada | detectada (698) |
| o prazo do fim conta no quadro em que nasce | detectada (3044) |
| as cargas andam depois do pinguim | detectada (368) |
| passo sem o "+1" na carga máxima | detectada (369) |
| a plataforma sem a espera de 250 ms | **equivalente**: o bloqueio do pinguim já espaça as entregas em mais de 250 ms, então essa espera da versão Atmos nunca decide nada |
| o atordoamento acaba antes das colisões do mesmo quadro | não detectada em nenhum dos roteiros do Bean Counters: um acerto bem no quadro em que o atordoamento acaba é raro. Situação não coberta |

## 5. Divergências encontradas e como foram resolvidas

### 5.1 Erros que o teste encontrou

| Versão | Erro | Commit |
|---|---|---|
| Atmos | Bean Counters: com o pinguim cheio, um `until` dentro do laço de colisões encerrava o laço, e o pinguim ficava imune até o fim | `e2964a8` |
| Atmos | Bean Counters: a integração passo a passo da carga contava a gravidade duas vezes; o café nunca girava (`pub.tipo`) | `b013989` |
| Atmos | Dojo: um prédio clicado no centro, vivo por baixo do minigame, emitia `:clicked`, e o Dojo o tomava por uma carta | `1a3b6f1` |
| Atmos | menu: fundo no tamanho natural da imagem; centro: pinguim parado virado para leste | `7b0b8f2`, `3b24142` |
| as duas | centro: escolher avermelhado, ciano ou vermelho derrubava o jogo (faltam os sprites); `azul_fraco/090.png` estava salvo como `3.png` | `2d7c1df` |
| as duas | Pega Puffles: paredes percorridas com `pairs` (ordem variável) | `3909138`, `bc84248` |
| Lua | personalização não rodava (API antiga do pico, campo `text.fixo`) | `b9bbef0` |
| Lua | Pega Puffles: remover o puffle que fugiu dentro do `ipairs` pulava o seguinte | `3909138` |
| Lua novo | Bean Counters: a plataforma recebia cafés com as duas pilhas cheias | `cdcf1b4` |

### 5.2 Regras que eram diferentes

Com D1, as regras do Atmos passaram para o Lua, e o que só o Lua tinha passou
para o Atmos:

| Tela | Do Atmos para o Lua | Do Lua para o Atmos |
|---|---|---|
| fluxo | minigames dentro do centro; Escape no centro (e num minigame) volta ao menu; a cor escolhida vale no centro | títulos de janela por tela; `grid=false`; 60 quadros/s |
| personalização | escolha da cor por clique | o quadro em grade 7 × 5 (rodada anterior) |
| centro | cafeteria em x = 0,20; chegada pela hitbox (0,08 × 0,10 contra 0,21 × 0,21); pinguim com altura 0,2 | — |
| Dojo | 4 cartas, sem água; 2 s de resultado; mãos rearrumadas na hora da jogada; vitórias por rodada | — |
| Bean Counters | café com o pinguim cheio derruba e tira vida; passo `10·(6 − carga)/6`; primeira carga após 0,5 s; o caminhão para 2 s e volta lançando; fim 0,5 s depois; espera de 250 ms na plataforma; neve atrás das cargas | — |
| Pega Puffles | — | as regras do Lua, em duas fases por quadro (rodada anterior, `bc84248`) |

### 5.3 Organização do Lua (pedido de mais orientação a objetos)

A versão Lua foi reescrita em classes (`dfa8702`, `cdcf1b4`, `a2d041e`):
`Objeto` é a classe base (herança por metatabelas, `extend`/`new`/`init`) com
os ganchos `tempo`, `evento` e `desenha`; `Jogo` guarda o estado entre telas e
as transições; cada tela e cada entidade guarda o próprio estado e só expõe
métodos (antes, os dados de cada tela ficavam em `gameState`, e as telas
mexiam diretamente nos campos das entidades). O pinguim do Bean Counters
avisa o minigame por métodos de um observador (`ao_coletar`, `ao_entregar`,
`ao_ser_atingido`). `timer.lua` (relógio real) e `vetor.lua` saíram.

## 6. Limitações

- A vitória do Bean Counters com pilhas de 10 não está em nenhum roteiro (foi
  conferida com pilhas de 2, em cópias).
- Duas mutações não são detectadas pelos roteiros atuais (seção 4.1).
- A comparação vê o que é desenhado. Estado que não aparece na tela só é
  conferido pelos efeitos que tem depois (por exemplo, o placar só aparece
  como texto).
