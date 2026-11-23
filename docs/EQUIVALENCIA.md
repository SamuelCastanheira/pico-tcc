# Equivalência entre as versões Lua e Atmos

Parte 4 do apoio ao TCC: um método reproduzível para verificar se a versão
Atmos (`src/codes_tcc/atmos_ilha_geladeira`) faz o mesmo que a versão Lua
(`src/codes_tcc/pico_ilha_geladeira`), inspirado no replay determinístico do
`lua_doom`. Aqui estão o método, os roteiros, os resultados, as divergências
com a causa de cada uma, as correções já feitas e as decisões pendentes.

**Situação em 23/11/2026:** o teste roda as duas versões inteiras sob o mesmo
roteiro e compara o que cada uma desenha, quadro a quadro. **A referência é a
versão Lua, em tudo** (decisão do usuário, D1). O **Pega Puffles** e a
**personalização** já são equivalentes: todos os quadros batem, menos o último
quadro da tela, que é a defasagem de transição F3 (decisão D3 pendente). O
menu bate até a transição. Centro, Dojo e Bean Counters ainda seguem regras
próprias (seção 4.2); as correções estão na seção 5.

---

## 1. Método

**Ideia.** As mesmas entradas, numa sequência roteirizada e com o tempo
controlado, devem produzir a mesma saída nas duas versões, quadro a quadro.

**O que se compara.** As duas versões não têm estruturas de dados em comum
(tabelas e campos no Lua; tasks e `pub` no Atmos). A única interface comum é o
que cada uma *desenha* com o pico-sdl. O traço de um quadro é, então, o
conjunto dos desenhos daquele quadro: cada imagem com o retângulo efetivo
(arredondado em 4 casas) e a rotação, e cada texto com o seu retângulo. Os
números do jogo (moedas, placar, vidas, tempo) entram no traço porque são
desenhados. É uma comparação de caixa-preta e não exige mudar o código dos
jogos.

**Critério.** Dois quadros são iguais se os conjuntos de desenhos são iguais.
A comparação ignora a ordem e as repetições: desenhar o mesmo fundo duas vezes
não muda a tela. Diferenças só de ordem (sobreposição) são contadas à parte,
como aviso. O resultado também mostra, só como informação, uma "janela de ±1
quadro" (o quadro *q* do Lua bate com algum dos quadros *q*−1, *q* ou *q*+1 do
Atmos), que isola as defasagens da seção 4.3.

**Fontes de não determinismo e como foram eliminadas** (instrumentação só de
teste, em `tests/equiv/harness.lua`):

| Fonte | Onde aparece | No teste |
|---|---|---|
| relógio real (`pico.get.now`) | Lua: `dt` do centro e das cargas, `Timer` (plataforma, 100 s dos puffles), 1,5 s do Dojo; Atmos: o ambiente `atmos.env.pico` emite o tempo decorrido a cada passo | relógio virtual: o quadro *q* acontece em `floor(q·1000/60)` ms; o `pico.input.event` devolve a diferença (16 ou 17 ms) |
| espera do modo *expert* (60 quadros/s no Lua, 30 no `atmos.env.pico`) | `pico.set.expert` | desligada; as duas versões andam no mesmo relógio virtual de 60 quadros/s, a taxa para a qual a lógica Lua foi escrita (`state.frames = 60`) |
| `math.random` sem semente | Atmos: `math.randomseed()` no `main.atm`; Lua: `math.randomseed(pico.get.now())` no Dojo e no Pega Puffles | `math.randomseed` passa a semear sempre com `EQ_SEED` (padrão 1) |
| entrada do usuário | teclado e mouse | vem do roteiro: um evento por quadro, no máximo (como o `pico.input.event` real); o mouse é posicionado com o `pico.set.mouse` real |
| ordem de `pairs` | Lua: desenho das cargas (`pairs(data.cargas)`, tabela-sequência) e das paredes do cercado (chaves fixas `esquerda`, `direita`, `baixo`); Atmos: percursos de pools e tabelas (`loop _, x in t`) | não afeta o traço: as tabelas percorridas são sequências ou têm chaves de string fixas, e a comparação é de conjunto. Não há chaves-objeto em código que mude o estado |
| janela e GPU | — | o pico-sdl real roda no driver `offscreen` do SDL (sem janela); `pico.get.mouse`, `pico.vs.*` e os desenhos continuam sendo os do pico-sdl |

**Isolamento.** O minigame em que o jogo entra depende de onde o pinguim
chega; uma diferença no centro desalinharia tudo o que vem depois. Por isso há
pontos de entrada de teste que começam direto numa tela e terminam quando ela
termina (`tests/equiv/entrada.lua` e `entrada.atm`, escolhidos pela linha
`# tela: <nome>` do roteiro). Eles repetem o início do `main.lua` e do
`main.atm`. Com a semente fixa, cada minigame começa com o mesmo estado do
gerador nas duas versões: nenhuma das telas anteriores sorteia números.

## 2. Arquivos e como reproduzir

| Arquivo | Papel |
|---|---|
| `tests/equiv/harness.lua` | instrumentação: relógio, entrada, semente, registro do traço |
| `tests/equiv/run_lua.lua`, `run_atm.lua` | rodam cada versão sob a instrumentação (o segundo faz o mesmo que `atmos main.atm`) |
| `tests/equiv/entrada.lua`, `entrada.atm` | entradas de teste que começam numa tela (`EQ_TELA`) |
| `tests/equiv/compare.lua` | compara dois traços |
| `tests/equiv/run.sh` | roda um roteiro nas duas versões e compara |
| `tests/equiv/roteiros/*.txt` | roteiros |
| `tests/equiv/out/` | traços gerados (fora do git) |

Requisitos: `lua5.4`, o binding Lua do pico-sdl instalado (`require "pico"`)
e o Atmos (`atmos-lang`, runtime `atmos`) instalados pelo luarocks.

```bash
sh tests/equiv/run.sh tests/equiv/roteiros/dojo.txt
```

```bash
for r in tests/equiv/roteiros/*.txt; do sh tests/equiv/run.sh "$r" 1 0 | grep -E '^(==|RESUMO|JANELA)'; done
```

Argumentos de `run.sh`: roteiro, semente (padrão 1) e quantos quadros
divergentes mostrar (padrão 5). O código de saída é 0 quando todos os quadros
batem. Para ver a diferença de um quadro, por exemplo o 40:

```bash
awk -F'\t' '$1==40' tests/equiv/out/dojo.lua.trc tests/equiv/out/dojo.atm.trc | tr '|' '\n'
```

Formato do roteiro (o quadro é o número da chamada a `pico.input.event`, a
partir de 1; o roteiro acabou, o teste manda `quit`):

```
# tela: dojo          (opcional: começa direto nesta tela)
1 mouse 0.5 0.5       posiciona o mouse (fração da janela)
10 click 0.9 0.88     clique (mouse.button.dn), posicionando antes
30 key Right          tecla (key.dn)
650 quit              encerra
```

## 3. Roteiros

| Roteiro | Tela | O que exercita |
|---|---|---|
| `smoke.txt` | fluxo completo | *hover* no menu, clique em "Jogar", entrada no centro |
| `centro.txt` | centro | caminhada até um ponto, mudança de destino, caminhada até o Dojo e entrada |
| `person.txt` | personalização | o mouse passa por duas cores do quadro (o Lua escolhe pelo *hover*), clica numa terceira e volta por "Voltar" |
| `dojo.txt` | Dojo | três rodadas, sempre a carta mais à direita, até o fim e a recompensa |
| `bean_counters.txt` | Bean Counters | seis idas e vindas (passos por `key.dn`, como a repetição de tecla), coletas, quedas e entregas, até o fim |
| `pega_puffle.txt` | Pega Puffles | o mouse passeia numa curva de Lissajous por 15 s: empurra os puffles (80 quadros com vizinhos a menos de 0,05) e faz 3 fugirem |
| `pega_puffle_cercar.txt` | Pega Puffles | pastoreio em malha fechada: a cada 40 quadros, o mouse vai para trás do puffle livre mais próximo do cercado. Toca as paredes, captura 8, deixa 2 fugirem e termina com vitória (80 moedas). Gerado por `tests/equiv/gen_cercar.py`, que simula com a versão Lua; o roteiro sai fixo e é o mesmo nas duas versões |

## 4. Resultados

### 4.1 Situação atual (semente 1, depois das correções da seção 5)

| Roteiro | Quadros | Iguais | Diferentes (1º) | Janela ±1 | Fim no Lua | Fim no Atmos |
|---|---:|---:|---|---:|---|---|
| smoke | 40 | 10 | 30 (10) | 29 | quit | quit |
| centro | 600 | 1 | 599 (1) | 598 | entra no Dojo no quadro 200 | entra no Dojo no quadro 215 |
| person | 80 | **79** | 1 (80) | **0** | volta ao menu | volta ao menu |
| dojo | 520 | 1 | 519 (1) | 518 | 100 moedas (quadro 492) | 100 moedas (quadro 520) |
| bean_counters | 854 | 109 | 745 (1) | 743 | 5 moedas | 10 moedas |
| pega_puffle | 901 | **901** | 0 | **0** | quit (jogo não terminou) | quit (jogo não terminou) |
| pega_puffle_cercar | 1816 | **1815** | 1 (1816) | 1 | vitória, 80 moedas | vitória, 80 moedas |

O `pega_puffle` também dá 901/901 com as sementes 2, 3 e 7, e o
`pega_puffle_cercar`, 1901/1901 (com outra semente, o pastoreio não termina o
jogo). Nos três roteiros com um quadro diferente, esse é o último quadro da
tela: o Lua ainda desenha a tela no quadro em que ela termina, e o Atmos não
(F3). A "janela ±1" não absorve o último quadro do `pega_puffle_cercar`
porque o Atmos não tem quadro seguinte. Os outros roteiros divergem desde o
primeiro quadro por regras e constantes ainda não alinhadas (seção 4.2).

### 4.1.1 Sensibilidade do teste (Pega Puffles)

Sete mutações das regras de colisão no `puffle.atm`, cada uma rodada contra o
`pega_puffle_cercar.txt` (o arquivo foi restaurado depois de cada uma):

| Mutação | Resultado |
|---|---|
| cerca: somar a direção deslizada em vez de substituir (o erro antigo) | detectada no quadro 551 |
| empurrão com o sinal trocado | detectada no quadro 1 |
| raio do empurrão 0,06 em vez de 0,05 | detectada no quadro 4 |
| testar a fuga depois de andar, em vez de antes | detectada no quadro 797 |
| passo 1% maior (como se o tempo real entrasse) | detectada no quadro 1 |
| cerca: fator 0,2 em vez de 0,1 | **equivalente**: a direção é normalizada antes de andar, e a escala não muda nada (no Lua também) |
| empurrar também os puffles que já fugiram | não detectada: os dois que fogem ficam longe dos outros. Situação não coberta pelos roteiros |

### 4.2 Catálogo das divergências

Categorias:

- **E**: erro numa das versões (a intenção do código é clara);
- **R**: regra, constante ou tempo diferente (escolha de projeto: decidir);
- **O**: ordem dentro do quadro, efeito da estrutura do laço ou do ambiente
  (decidir o critério);
- **Q**: quebra que impede a comparação.

Situação: **corrigido** (commit), **pendente** (esperando decisão).

#### Fluxo, menu e centro

| Id | Diferença | Causa | Cat. | Situação |
|---|---|---|---|---|
| F1 | Fundo do menu no tamanho natural da imagem no Atmos (1,0625 × 1,0667 da janela) | `menu.atm`: retângulo sem `w` e `h` | E | **corrigido** (`7b0b8f2`) |
| F2 | Pinguim do centro começa virado para leste no Atmos (`090`), para o sul no Lua (`000`) | `centro/pinguim.atm`: velocidade zero caía no setor 0 | E | **corrigido** (`3b24142`) |
| F3 | Na transição de tela, o Lua ainda desenha a tela antiga no quadro do clique; o Atmos já desenha a nova | `main.lua` faz `update` → `draw` → troca de tela; no Atmos a tela termina dentro do `emit` do clique e a seguinte começa no mesmo passo | O | pendente (D3) |
| F4 | O movimento do pinguim começa um quadro depois no Atmos e fica um quadro atrás até chegar | o `atmos.env.pico` emite o relógio *antes* do evento de entrada; o Lua trata evento e tempo no mesmo `update` | O | pendente (D3) |
| F5 | Cafeteria em x = 0,25 no Lua e 0,20 no Atmos | constante | R | pendente |
| F6 | Chegada ao prédio: no Lua, a posição do pinguim dentro do retângulo inteiro do prédio (0,35–0,40 de largura); no Atmos, colisão da *hitbox* do pinguim (0,08 × 0,10) com a do prédio (0,21 × 0,21). Entra no Dojo no quadro 200 (Lua) e 215 (Atmos) | regra | R | pendente |
| F7 | Altura do pinguim do centro: automática no Lua (proporção da imagem, 0,2276), fixa em 0,2 no Atmos | constante | R | pendente |
| F8 | Escape no centro volta ao menu (só no Atmos); no Lua não há como sair do centro | `watching :key.dn until (it.key == :Escape)` | R | pendente |
| F9 | Durante o minigame, o Atmos ainda desenha o centro por baixo, e Escape aborta o minigame | os minigames são aguardados dentro da task `Centro` (hierarquia de vida); no Lua as telas são planas | R | pendente |
| F10 | A cor escolhida na personalização vale no centro do Atmos (`cor_pinguim`, gravada ao sair da tela); o Lua usa sempre "amarelo" | o Lua não guarda a cor | R | pendente |
| F11 | Título da janela por tela no Lua; fixo no Atmos | cosmético (não entra no traço) | R | registrado |

#### Personalização

| Id | Diferença | Causa | Cat. | Situação |
|---|---|---|---|---|
| P1 | A tela Lua não rodava: erro em `pico.layer.empty` na inicialização | `personalizacao.lua` usava a assinatura antiga (`pico.layer.empty('=', nil, nil, ...)`) e o mouse no formato antigo, e o desenho lia `cor_select.text.fixo`, campo que não existe (o campo é `texto`) | Q | **corrigido no Lua** (`b9bbef0`) |
| P2 | O Lua escolhe a cor sob o mouse a cada quadro (*hover*); o Atmos só no clique, e começava na última cor escolhida | regra | R | **corrigido** (`f643bdc`): o Atmos segue o Lua |
| P3 | O quadro de cores: no Lua, um layer de 600 × 400 com grade de 7 × 5 células, desenhado a cada quadro; no Atmos, sub-layers presos ao `world`, com as cores em posições um pouco diferentes | forma de construir o quadro | R | **corrigido** (`f643bdc`) |
| P4 | Recriar o layer do quadro com a mesma chave aborta o pico | o Lua criava o quadro a cada entrada na tela | E (Lua) | **corrigido no Lua** (`b9bbef0`: cria uma vez). No Atmos, o `main.atm` cerca cada tela com `pico.push()`/`pico.pop()`, e a reentrada funciona |

#### Dojo

| Id | Diferença | Causa | Cat. | Situação |
|---|---|---|---|---|
| D1 | Baralho: 5 cartas no Lua (com `agua_3`), 4 no Atmos (sem cartas de água). Com a mesma semente, as mãos sorteadas já diferem | constante (`cartas` em `dojo.atm`) | R | pendente |
| D2 | Resultado da rodada na tela por 1,5 s (Lua) ou 2 s (Atmos) | constante | R | pendente |
| D3 | O Lua reordena as mãos só depois do resultado; o Atmos, logo na escolha | regra (posição das cartas restantes durante o resultado) | R | pendente |
| D4 | Placar: o Lua soma 3 por vitória e 1 por empate; o Atmos conta vitórias | forma diferente, mesmo resultado (3V+E > 3D+E se e só se V > D); a recompensa (100/50/0) é igual | — | equivalente |

#### Bean Counters

| Id | Diferença | Causa | Cat. | Situação |
|---|---|---|---|---|
| B1 | Trajetória das cargas: o Atmos integrava passo a passo e contava a gravidade duas vezes; a carga não caía no destino calculado | `carga.atm` | E | **corrigido** (`b013989`): com a mesma semente, a primeira carga tem a mesma trajetória nas duas versões |
| B2 | O saco de café nunca girava no Atmos | `carga.atm` testava `pub.tipo`, campo inexistente | E | **corrigido** (`b013989`) |
| B3 | Pinguim cheio + mais um café: no Atmos, o `until (carga >= carga_maxima)` dentro do laço de colisões **encerra o laço**, e o pinguim fica imune a tudo (cafés e objetos) até o fim do jogo. Comprovado num teste isolado da construção `until` | `bean_counters/pinguim.atm` | E | pendente: o arquivo tem uma mudança do usuário não commitada (D2) |
| B4 | `carga_maxima`: 5 no Lua e no último commit do Atmos; **2** na cópia de trabalho do Atmos (não commitada) | mudança local do usuário | R | pendente (D2) |
| B5 | Sobrecarga: no Lua, o 6º café ainda soma 2 pontos e derruba o pinguim por 2 s, **sem perder vida**; no Atmos (intenção do código), o café além do máximo conta como acerto: perde vida | regra | R | pendente |
| B6 | Velocidade: `10·(cm − cargas)/cm` no Lua (parado com 5 cargas); `10·((cm+1) − carga)/(cm+1)` no Atmos | fórmula | R | pendente |
| B7 | Primeira carga: lançada na inicialização no Lua; depois de 0,5 s no Atmos | tempo | R | pendente |
| B8 | Depois de derrubado: o Lua retoma o intervalo de lançamento de onde parou; o Atmos reinicia o laço e lança uma carga na hora | regra | R | pendente |
| B9 | Fim do jogo: imediato no Lua; 0,5 s depois no Atmos | tempo | R | pendente |
| B10 | A carga some no quadro em que passa de y = 0,9 no Atmos e no seguinte no Lua (o Lua testa antes de mover) | ordem dentro do quadro | O | pendente (D3) |
| B11 | A neve é desenhada de novo depois das cargas no Lua (as cargas passam por trás da neve); no Atmos as cargas ficam por cima | ordem de desenho | O | registrado (a comparação é de conjunto) |
| B12 | Plataforma: além do intervalo de 250 ms do pinguim, o Atmos espera mais 250 ms dentro da `Plataforma` a cada entrega na primeira pilha; uma entrega que chegue nesse intervalo soma pontos mas não entra na pilha | regra | R | pendente |

#### Pega Puffles

| Id | Diferença | Causa | Cat. | Situação |
|---|---|---|---|---|
| U0 | **Fases do quadro (a causa principal das colisões diferentes):** o Lua calcula a direção de *todos* os puffles com as posições paradas e só depois move todos; no Atmos cada puffle calculava e andava sozinho no seu `:clock`, e os seguintes já viam os anteriores na posição nova | estrutura | R | **corrigido** (`bc84248`): a tela emite `:puffle.direcao` e `:puffle.anda` a cada `:clock` |
| U1 | Velocidade de fuga: 0,04 × `dt` fixo de 0,05 por quadro no Lua (0,12/s a 60 quadros/s); 0,4 × tempo real no Atmos (0,4/s, cerca de 3,3 vezes mais rápido) | constante e unidade de tempo | R | **corrigido** (`bc84248`) |
| U2 | Empurrão entre puffles: o Lua soma 0,5·(outro − ele) à direção do *outro*; o Atmos subtrai 0,5·(vizinho − ele) da *própria* direção | forma diferente, mesma soma: na mesma ordem de vizinhos, as duas contas dão o mesmo número em ponto flutuante (a − b = −(b − a) exatamente) | — | equivalente, depois de U0 |
| U3 | Cerca: o Lua *substitui* a direção pelo deslizamento × 0,1; o Atmos *somava* o deslizamento × 0,1 | regra | R | **corrigido** (`bc84248`) |
| U4 | Captura: o Lua conta os puffles cujo centro está dentro do cercado, a cada quadro; o Atmos contava entradas e saídas por sobreposição de retângulos | regra | R | **corrigido** (`bc84248`) |
| U5 | Cronômetro: o Lua mostra 99 no início (`floor(restante/1000)`); o Atmos, 100 | arredondamento | R | **corrigido** (`bc84248`) |
| U6 | As árvores cobrem os puffles no Lua; no Atmos, os puffles ficavam por cima | ordem de desenho | O | **corrigido** (`bc84248`) |
| U7 | O Lua removia o puffle que fugiu dentro do `ipairs` e pulava o puffle seguinte naquele quadro | erro no Lua | E (Lua) | **corrigido no Lua** (`3909138`: laço de trás para a frente) |
| U8 | As paredes do cercado eram percorridas com `pairs` (chaves string) nas duas versões; no Lua 5.4 essa ordem pode mudar entre execuções, e importa quando o puffle toca duas paredes | não determinismo | E | **corrigido** nas duas (`3909138`, `bc84248`): lista fixa esquerda, direita, baixo |
| U9 | O puffle fora do mapa: o Lua testa antes de andar e o remove no quadro seguinte; o Atmos testava depois de andar | ordem | R | **corrigido** (`bc84248`) |

### 4.3 Sobre as defasagens de um quadro (categoria O)

São efeitos da forma do laço, não das regras:

- **transição de tela (F3):** o Lua desenha a tela antiga no quadro em que a
  troca é pedida e só troca no fim do quadro; no Atmos, a tela termina dentro
  do `emit` do clique e a seguinte já desenha no mesmo quadro;
- **relógio antes do evento (F4, B10):** a cada passo, o `atmos.env.pico`
  emite primeiro o tempo decorrido e depois o evento de entrada. Uma reação
  que depende do tempo começa no passo seguinte ao do evento; no Lua, o mesmo
  `update` vê o evento e o tempo.

Fazer o Atmos imitar essas defasagens exigiria código artificial (desenhar
mais um quadro da tela que já terminou; aplicar à mão o `dt` do quadro do
clique) ou um ambiente próprio do projeto que emitisse a entrada antes do
relógio. Daí a decisão D3.

## 5. Correções feitas

### 5.1 Na versão Lua (a referência)

Só erros que impediam a tela de rodar ou que tornavam a referência não
determinística ou incoerente; nenhuma regra do jogo mudou.

| Commit | Arquivo | Correção |
|---|---|---|
| `b9bbef0` | `screens/telas_menu/personalizacao.lua` | API atual do pico (`pico.layer.empty{...}`, mouse em células do layer), campo `texto`, layer criado uma vez só (P1, P4) |
| `3909138` | `screens/minigames/pega_puffles/pega_puffles.lua` | paredes em lista de ordem fixa (U8); laço de movimento de trás para a frente, para a remoção não pular o puffle seguinte (U7) |

### 5.2 Na versão Atmos

| Commit | Arquivo | Correção | Como o teste mostra |
|---|---|---|---|
| `f643bdc` | `screens/telas_menu/personalizar.atm` | o quadro, a escolha por *hover* e a cor inicial do Lua (P2, P3) | `person.txt`: 79 de 80 quadros iguais (o último é F3) |
| `bc84248` | `screens/minigames/pega_puffles/pega_puffles.atm`, `puffle.atm` | fases do quadro, cerca, velocidade, fuga, captura, cronômetro e ordem de desenho do Lua (U0 a U9) | `pega_puffle.txt` 901/901; `pega_puffle_cercar.txt` 1815/1816 (o último é F3); mutações na seção 4.1.1 |
| `b013989` | `screens/minigames/bean_counters/carga.atm` | posição exata do lançamento (p₀ + v₀t + gt²/2), como no Lua; rotação do café (`pub.id` em vez de `pub.tipo`) | a primeira carga (mesmo sorteio nas duas versões) tem as mesmas posições quadro a quadro, deslocadas pelos 30 quadros de B7; os desenhos com rotação passam de 0 a 161 no roteiro |
| `3b24142` | `screens/centro/pinguim.atm` | parado, o pinguim fica virado para o sul | o sprite inicial passa de `090` para `000`, como no Lua |
| `7b0b8f2` | `screens/telas_menu/menu.atm` | fundo com `w=1, h=1` | os quadros 1 a 9 do `smoke` passam a ser iguais |

## 6. Decisões

- **D1. Referência e alcance: decidido em 23/11/2026.** A versão Lua é a
  referência para tudo: o Atmos passa a seguir as regras e constantes do Lua.
  Feito para o Pega Puffles e a personalização. Faltam o centro (F5 a F10), o
  Dojo (D1 a D3 da tabela) e o Bean Counters (B3 a B12).
- **D4. Personalização em Lua: decidido em 23/11/2026.** Consertar o Lua
  (feito em `b9bbef0`).

Pendentes:

- **D2. `bean_counters/pinguim.atm`.** O `carga_maxima = 2` da cópia de
  trabalho é um teste local (a referência fica em 5, como no Lua e no último
  commit) ou o novo valor do jogo (e então o Lua também deveria mudar)? A
  correção do erro B3 está no mesmo arquivo e espera essa resposta, para não
  misturar a mudança do usuário com a correção.
- **D3. Defasagens de um quadro (F3, F4, B10).** Aceitar como diferença do
  ambiente (o critério passa a ser a janela de ±1 quadro, já medida pelo
  comparador) ou criar no projeto Atmos um ambiente que entregue a entrada
  antes do relógio?
  Com a decisão D3 tomada, o Pega Puffles e a personalização passam a ser
  equivalentes sem ressalva (se a janela for aceita) ou depois do ambiente
  novo.

Próximos passos: alinhar ao Lua o centro, o Dojo e o Bean Counters, uma
mudança por commit (o Bean Counters depois de D2), e acrescentar aos roteiros
as situações que faltam (sobrecarga no Bean Counters, empate no Dojo, um
puffle que foge perto de outro).
