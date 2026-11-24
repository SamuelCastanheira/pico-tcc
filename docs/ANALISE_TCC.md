# Análise de apoio ao TCC

Apoio ao TCC *Desenvolvimento de Jogos: Uma Análise Comparativa entre
Orientação a Objetos e Concorrência Estruturada* (UERJ, 2026):

1. o que vale a pena ler;
2. os achados que valem análise no texto;
3. a sequência de leitura;
4. correções no artigo atual;
5. estrutura do texto e tópicos;
6. o repositório como base da comparação (inventário e métricas).

Documentos relacionados: [`EQUIVALENCIA.md`](EQUIVALENCIA.md) (o teste que
prova que as versões Lua e Atmos fazem a mesma coisa) e
[`PADROES.md`](PADROES.md) (padrões de jogos no código, com diagramas).

Referências conferidas em 23/11/2026 contra o artigo `TCC___Samuel-26.pdf`,
o Atmos `atmos-lang dev-4` (CLI v0.8; repositório `atmos-lang/atmos` em
`a06998a`) e o código do `pico-tcc`.

---

## 1. O que vale a pena ler

| Referência | O que traz para o TCC | Leitura conferida | Prioridade |
|---|---|---|---|
| Manual e guia do Atmos (`github.com/atmos-lang/atmos`, `doc/manual.md` e `doc/guide.md`) | Modelo de execução, tasks, hierarquia, `pin`/`tasks`, `par`/`watching`/`toggle`, `emit`/`await`, `defer`/`abort`, escalonamento determinístico. É a fonte primária: não há artigo que formalize o Atmos | texto integral | essencial |
| SANT'ANNA, F. *Structured Synchronous Reactive Programming for Game Development — Case Study: On Rewriting Pingus from C++ to Céu*. SBGames, 2018 (`fsantanna.github.io/pingus`) | O trabalho mais próximo do seu: reescrita da lógica de um jogo para uma linguagem síncrona, com cinco padrões de controle e as variáveis de estado como sintoma | texto integral | essencial |
| NYSTROM, R. *Game Programming Patterns*. Genever Benning, 2014 (`gameprogrammingpatterns.com`) | Game Loop, Update Method, State, Observer, Component: o vocabulário para descrever a versão Lua | capítulos citados | essencial |
| ADYA, A. et al. Cooperative Task Management Without Manual Stack Management. *USENIX Annual Technical Conference*, 2002 | Separa gerenciamento de tarefas de gerenciamento de pilha; nomeia o *stack ripping*. É a moldura teórica da comparação | texto integral | essencial |
| SMITH, N. J. *Notes on structured concurrency, or: Go statement considered harmful*. Blog, 2018 (`vorpus.org`) | A motivação mais citada da concorrência estruturada (*nurseries*; "go statements are a form of goto statement") | texto integral | alta |
| CHEN, Y.-A.; YOU, Y.-P. Structured Concurrency: A Review. *ICPP Workshops '22*, ACM, 2022, p. 1–8. DOI 10.1145/3547276.3548519 | Revisão da área; defende que a concorrência estruturada nasce das corrotinas | resumo e referências (texto integral bloqueado pela ACM) | alta |
| DE MOURA, A. L.; IERUSALIMSCHY, R. Revisiting Coroutines. *ACM TOPLAS*, 31(2), 2009. DOI 10.1145/1462166.1462167 | Corrotinas assimétricas completas, com o poder das continuações *one-shot*: a base das tasks do Atmos, que são corrotinas de Lua | texto integral (relatório técnico PUC-Rio MCC 15/04) | alta |
| SANT'ANNA, F. *Structured (Synchronous) Concurrency* (`fsantanna.github.io/sc.html`) | Concorrência estruturada comparada a threads, MapReduce, Esterel e FRP em dois eixos; defende que ela deve ser síncrona | texto integral | alta |
| BERRY, G. Preemption in Concurrent Systems. *FSTTCS*, LNCS 761, 1993, p. 72–93. DOI 10.1007/3-540-57529-4_44 | Preempção (aborto) segura exige um modelo dependente do tempo: o argumento central do `sc.html` | resumo | média |
| BERRY, G.; GONTHIER, G. The Esterel synchronous programming language: design, semantics, implementation. *Science of Computer Programming*, 19(2):87–152, 1992 | Hipótese de sincronismo, composição paralela, preempção (só as seções iniciais) | texto integral | média |
| SANT'ANNA, F. et al. The Design and Implementation of the Synchronous Language CÉU. *ACM TECS*, 16(4):1–26, 2017. DOI 10.1145/3035544 | A linhagem Esterel → Céu → Atmos: *trails*, ordem léxica, verificação de concorrência, finalização | texto integral | média |
| SANTOS, R. C. M. et al. A Memory-Bounded, Deterministic and Terminating Semantics for the Synchronous Programming Language Céu. *LCTES*, 2018. DOI 10.1145/3211332.3211334 | Semântica formal de Céu (determinismo, memória limitada, terminação) | texto integral | complementar |
| IERUSALIMSCHY, R.; DE FIGUEIREDO, L. H.; CELES, W. The evolution of Lua, continued. *Journal of Computer Languages*, 83, 101326, 2025 | Lua em jogos ("one of the leading scripting languages in game development"); corrotinas na linguagem | texto integral | média |

Os textos da ACM ficaram atrás de uma verificação anti-robô; nesses casos, a
leitura foi da versão aberta dos autores ou, sem ela, do resumo e dos
metadados (Crossref).

## 2. Achados que valem análise no texto

| Achado | Evidência | Onde usar |
|---|---|---|
| A versão Lua é o caso "cooperativo com pilha manual" e a Atmos, o "cooperativo com pilha automática" | Adya et al. (2002): as duas dimensões; no código, o estado de cada comportamento Lua vira campo de objeto (`tonto`, `bloqueio`, `espera`), o *stack ripping* | Cap. 2 (moldura) e 5 |
| A concorrência estruturada nasce das corrotinas, não da programação estruturada | Chen & You (2022), contra a visão corrente | Cap. 2 (concorrência estruturada) |
| A ideia de tarefas com escopo léxico e cancelamento seguro é antiga: as linguagens síncronas a usam desde os anos 1980 | `sc.html`: "lexically-scoped tasks with safe cancellation" | Cap. 2 e 6 (linhagem Esterel → Céu → Atmos) |
| A concorrência estruturada deve ser síncrona, e jogos cabem na hipótese de sincronismo | `sc.html`, apoiado em Berry (1993); o post cita os video games entre as aplicações que satisfazem a hipótese | Cap. 2 (programação síncrona) e 3 |
| As tasks do Atmos são corrotinas de Lua e se comportam como variáveis locais: o escopo do código define o tempo de vida | manual do Atmos, *Structured Deterministic Concurrency* ("tasks in Atmos are treated in the same way as local variables"); guia, seção 3 ("the lexical organization of tasks determines their lifetimes and also how they are scheduled"); de Moura & Ierusalimschy (2009) | Cap. 3 |
| O escalonamento é determinístico, na ordem do código | guia, seção 3.1 ("deterministic and cooperative") | Cap. 3 e 4 (é o que torna o teste de equivalência possível) |
| `pin` não é o que prende a task ao escopo: toda task criada por `spawn` já fica presa ao bloco; o `pin` dá nome à referência e é obrigatório para pools | manual, *Tasks* ("By default, an unassigned `spawn` attaches the new task to the enclosing block") | Cap. 3 |
| O alcance padrão do `emit` é a task corrente e seus descendentes; o alcance errado causou dois erros reais no projeto | manual, *Emit*; `EQUIVALENCIA.md`, seção 5.1 (o `:clicked` dos prédios chegando ao Dojo; o `until` que encerrava o laço de colisões) | Cap. 5 (custo do Atmos) |
| No Lua, a ordem das chamadas dentro do quadro é semântica, e um prazo criado num passo só pode contar no seguinte; no Atmos, isso vem do escalonador | `EQUIVALENCIA.md`, seções 2 e 4.1 (seis de oito mutações detectadas são desses detalhes) | Cap. 5 (custo do Lua) |
| As duas versões fazem exatamente a mesma coisa, quadro a quadro | `EQUIVALENCIA.md`: todos os roteiros, quatro sementes, todos os quadros iguais | Cap. 4 e 5 (validade da comparação) |
| Com versões limpas e equivalentes, o tamanho fica parecido (980 × 888 linhas), mas as condicionais caem onde há fases (Bean Counters 22 × 7) | seção 6.2 | Cap. 5 |
| O jogo estudado tem os cinco padrões do Pingus | `PADROES.md` (máquinas de estados, continuação, despacho, tempo de vida, sinalização, com diagramas) | Cap. 4 (critérios) e 5 |
| A comparação é entre abordagens, não entre linguagens: o Atmos compila para Lua e imita a sua semântica | manual do Atmos, *DESIGN* ("mimics most of the semantics of Lua") | Cap. 1 e 4 |
| Céu verifica a concorrência em tempo de compilação, ordena as *trails* pelo código e gerencia memória pelo escopo léxico | TECS 2017; manual do Céu v0.30, *Overview* | Cap. 6 |
| Esterel: o paralelo termina quando todos os ramos terminam | Berry & Gonthier (1992) | Cap. 2 e 3 (origem do `par :all`) |
| O Atmos é experimental e não tem artigo próprio | manual ("Atmos is in **experimental stage**") | Cap. 3 (citar o manual com versão e data) |

## 3. Sequência de leitura

| Ordem | Leitura | O que tirar | Onde entra |
|---|---|---|---|
| 1 | Manual e guia do Atmos (manual: *DESIGN*, *Tasks*, *Task Operations*; guia: seções 1 a 6) | Modelo de execução, hierarquia, compostos, eventos, finalização | Cap. 3 |
| 2 | Sant'Anna, Pingus (2018) | Os cinco padrões; variáveis de estado como sintoma; LOC "densas" | Cap. 4 e 6 |
| 3 | Nystrom (2014): *Game Loop*, *Update Method*, *State*, *Observer*, *Component* | O vocabulário da versão Lua | Cap. 2 e 4 |
| 4 | Adya et al. (2002) | Tarefas × pilha; *stack ripping* | Cap. 2 (moldura da comparação) |
| 5 | Smith (2018) e Chen & You (2022) | Definição e origem da concorrência estruturada | Cap. 2 |
| 6 | de Moura & Ierusalimschy (2009) | Corrotinas assimétricas completas | Cap. 2 e 3 |
| 7 | Sant'Anna, `sc.html`, e Berry (1993) | Concorrência estruturada síncrona; preempção; jogos e a hipótese de sincronismo | Cap. 2 |
| 8 | Berry & Gonthier (1992), seções iniciais | Hipótese de sincronismo, paralelo, preempção | Cap. 2 |
| 9 | Céu: TECS 2017 (LCTES 2018 como complemento) | A linhagem até o Atmos | Cap. 6 |
| 10 | Ierusalimschy et al. (2025) | Lua em jogos | Cap. 1 e 2 |

## 4. Correções no artigo atual (`TCC___Samuel-26.pdf`)

| Ponto do artigo | Problema | Correção |
|---|---|---|
| [1] Ramadan & Widyani (2013), citado para definir "jogo" | O artigo propõe um ciclo de desenvolvimento de jogos (GDLC), não uma definição de jogo | Usar uma fonte de *game studies* para a definição, como Salen & Zimmerman (*Rules of Play*, 2004) ou Juul (*Half-Real*, 2005) (não conferidas aqui) |
| [2] *The evolution of Lua, continued* | Falta o terceiro autor | IERUSALIMSCHY, R.; DE FIGUEIREDO, L. H.; CELES, W. *Journal of Computer Languages*, v. 83, 101326, 2025 |
| [3] Cormen et al., citado para o Observer e como "Nystrom [3]" | Referência errada | NYSTROM, R. *Game Programming Patterns*, 2014. Para o Observer original: GAMMA, E. et al. *Design Patterns*, 1994. A ideia de OO sem classes está no capítulo *Prototype* de Nystrom |
| [4] Chen & You, "Association for Computing Machinery, 2023" | Veículo e ano errados | *ICPP Workshops '22*, ACM, 2022, p. 1–8 |
| [5] e [7] Notas CS442 de Waterloo | Corretas, mas são notas de aula | Se possível, completar com um livro de linguagens de programação |
| [6] Raynal (2013) | Correta | Springer, 2013. DOI 10.1007/978-3-642-32027-9 |
| Seções 2.1.1 e 2.1.2 | Os dois primeiros parágrafos da 2.1.2 copiam os da 2.1.1 | Reescrever a 2.1.2 com o que é próprio de OO: encapsulamento, mensagens, herança por metatabelas (a classe base `Objeto` do jogo) |
| Seção 2.1.3 (concorrência) | Descreve a concorrência assíncrona e não determinística; o Atmos é o oposto | Encurtar e apresentar como contraste: escalonamento cooperativo, determinismo, comunicação por eventos |
| Palavras-chave ("Orientação a Eventos") × título ("Orientação a Objetos") | Inconsistentes | Alinhar (título sugerido na seção 5) |
| Resumo: "As implementações (de que?)" | Lacuna | Os minigames da Ilha Geladeira (Dojo, Bean Counters, Pega Puffles), a praça e os menus, em Lua e em Atmos |
| Introdução | Afirmações sem referente ("essas características", "essa abordagem", "determinadas estruturas"); o problema só no condicional; sem contribuições | Abrir com um exemplo concreto do jogo (a rodada do Dojo nas duas versões) e fechar com as contribuições numeradas |
| Seção 2.1, fim do segundo parágrafo | Marcador "como: ......" | Completar ou cortar |

## 5. Estrutura do texto e tópicos

Título sugerido, mais fiel ao que o projeto compara: *Desenvolvimento de
Jogos: Laço de Atualização com Objetos × Concorrência Estruturada Síncrona*.
Se preferir manter "Orientação a Objetos", explique no capítulo 1 que a
versão Lua é um laço de jogo com objetos sobre metatabelas.

1. **Introdução**
   - jogos como sistemas reativos e o laço de jogo;
   - problema, com o exemplo da rodada do Dojo: no laço de atualização, o
     estado e o fluxo de um comportamento se espalham entre chamadas;
   - pergunta: como as duas abordagens diferem em expressividade, correção e
     custo, para o mesmo comportamento?;
   - contribuições: o mesmo jogo nas duas abordagens; um método de
     equivalência por replay determinístico; a comparação por padrões e
     métricas; os erros que a comparação revelou;
   - organização do texto.
2. **Fundamentação teórica**
   - 2.1 Jogos: laço, atualização e desenho, máquinas de estados (Nystrom);
   - 2.2 Programação estruturada e orientada a objetos (sem a duplicação;
     objetos em Lua);
   - 2.3 Eventos e inversão de controle (Adya: tarefas × pilha, *stack
     ripping*);
   - 2.4 Concorrência cooperativa e corrotinas (de Moura & Ierusalimschy);
   - 2.5 Concorrência estruturada (Smith; Chen & You);
   - 2.6 Programação síncrona (hipótese de sincronismo, Esterel, preempção;
     Berry; `sc.html`).
3. **A linguagem Atmos**
   - ambiente e eventos (relógio, entrada, `draw`; o `ambiente.lua` do jogo);
   - tasks, hierarquia e escalonamento na ordem do código;
   - `pin`, pools (`tasks`), `pub`;
   - compostos: `par`, `watching`, `loop on`, `toggle`;
   - eventos: `emit`, alcance e `await` com padrões;
   - finalização e aborto: `defer`, `abort`;
   - integração com Lua.
4. **Metodologia e implementações**
   - 4.1 O jogo Ilha Geladeira e o pico-sdl;
   - 4.2 A versão Lua: classes com `tempo`/`evento`/`desenha`, estado em cada
     objeto, transições pelo `Jogo`;
   - 4.3 A versão Atmos: uma task por entidade, componentes `Image`,
     `Image_Hover`, `XClickable`, `XCollidable`;
   - 4.4 Equivalência por replay (`EQUIVALENCIA.md`);
   - 4.5 Critérios de comparação: os padrões do Pingus, variáveis de estado,
     pontos de mudança, linhas de código, custo por quadro.
5. **Resultados e discussão**
   - por padrão, com os pares Lua × Atmos da seção 6.3 e os diagramas do
     `PADROES.md`;
   - métricas (seção 6.2);
   - erros que a comparação revelou, nas duas versões;
   - custo de execução (o Atmos gasta mais por quadro; ver o relógio na
     seção 2 do `EQUIVALENCIA.md`);
   - ameaças à validade (versões escritas em momentos diferentes, por
     autores diferentes; um só jogo).
6. **Trabalhos relacionados**: Pingus em Céu; Esterel e Céu; concorrência
   estruturada em Kotlin, Swift e Trio; o caso do Doom (abaixo).
7. **Conclusão**: respostas, limitações, trabalhos futuros (*streams*,
   threads, um estudo maior).

**O que se mantém, o que muda, o que falta no artigo atual.**
Mantêm-se a introdução, em linhas gerais (com as correções da seção 4), a
seção 2.1.1 e a base da 2.1.3. Mudam a 2.1.2, as referências [1] a [4], o
título ou as palavras-chave, e a posição dos trabalhos relacionados (depois
dos resultados). Faltam concorrência estruturada, eventos e inversão de
controle, programação síncrona, o capítulo do Atmos, a metodologia com o
`pico-tcc` e a equivalência, e os resultados.

**O caso do Doom (`lua_doom`).** Convém usar como estudo complementar e
curto, numa seção do capítulo 5 ou 6. Ele tem o que falta ao `pico-tcc`:
escala (a lógica inteira de um jogo comercial), migração passo a passo com
tags e equivalência provada por replay contra a versão imperativa com
*thinkers*. Dois cuidados: é um port de um port (Python → Lua), então a
comparação é entre as duas versões Lua do port, não com o Doom original; e é
um projeto ainda em correção, então fixe uma tag e use só os números dela.

---

## 6. O repositório como base da comparação

Situação em 24/11/2026. As duas versões são equivalentes quadro a quadro
([`EQUIVALENCIA.md`](EQUIVALENCIA.md)), então as métricas comparam programas
que fazem exatamente a mesma coisa.

### 6.1 Inventário

As duas versões usam as mesmas telas e os mesmos recursos (`assets/`).
Desenho, colisão e entrada vêm do pico-sdl, instalado no sistema.

| Programa | Versão Lua (`src/lua`) | Versão Atmos (`src/atmos`) |
|---|---|---|
| fluxo de telas | `main.lua` (laço: `tempo`, `evento`, `desenha`) e `jogo.lua` (classe `Jogo`: moedas, cor do pinguim, troca de telas) | `main.atm` (`loop { await Menu() ... }`) e `ambiente.lua` (relógio, entrada e `draw`) |
| menu | `screens/telas_menu/menu.lua` + `util/botao.lua` | `screens/telas_menu/menu.atm` + `util/components/botao.atm`, `image_hover.atm`, `xclickable.atm` |
| personalização | `screens/telas_menu/personalizacao.lua` | `screens/telas_menu/personalizar.atm` |
| praça (com os minigames dentro) | `screens/centro/centro.lua`, `pinguim.lua`, `predio.lua` | `screens/centro/centro.atm`, `pinguim.atm`, `predio.atm` |
| Dojo | `screens/minigames/dojo/dojo.lua`, `carta.lua` | `screens/minigames/dojo/dojo.atm`, `carta.atm` |
| Bean Counters | `screens/minigames/bean_counters/bean_counters.lua`, `pinguim.lua`, `carga.lua`, `pilha.lua`, `plataforma.lua` | `.../bean_counters.atm`, `pinguim.atm`, `carga.atm`, `pilha.atm`, `plataforma.atm` |
| Pega Puffles | `screens/minigames/pega_puffles/pega_puffles.lua`, `puffle.lua` | `.../pega_puffles.atm`, `puffle.atm` |
| base | `util/objeto.lua` (classe base), `util/temporizador.lua` (tempo do jogo), `util/lista.lua` | `util/vetor.atm`, `util/components/image.atm`, `xcollidable.atm` |

```bash
cd src/lua && lua main.lua
```

```bash
cd src/atmos && atmos main.atm
```

A versão Lua é orientada a objetos: `Objeto` é a classe base (herança por
metatabelas: `extend`, `new`, `init`) com três ganchos (`tempo`, `evento`,
`desenha`); cada tela e cada entidade guarda o próprio estado e só expõe
métodos (`pinguim:escolhe_destino(id)`, `carta:joga(r)`, `plataforma:recebe()`);
o pinguim do Bean Counters avisa o minigame como um observador
(`ao_coletar`, `ao_entregar`, `ao_ser_atingido`); o `Temporizador` conta o
tempo do jogo.

### 6.2 Métricas (`python3 tools/metricas.py`)

Contagens léxicas, sem linhas em branco nem comentários.

| Programa | LOC Lua | LOC Atmos | Atmos/Lua | funções Lua | tasks + funcs Atmos | if/elseif Lua | if/ifs Atmos |
|---|---:|---:|---:|---:|---:|---:|---:|
| main e jogo (fluxo de telas) | 58 | 22 | 0,38 | 8 | 0+0 | 5 | 0 |
| menu | 34 | 36 | 1,06 | 3 | 1+0 | 1 | 0 |
| personalização | 68 | 80 | 1,18 | 6 | 1+2 | 4 | 1 |
| praça | 169 | 142 | 0,84 | 16 | 4+2 | 16 | 3 |
| Dojo | 152 | 108 | 0,71 | 15 | 2+4 | 16 | 12 |
| Bean Counters | 284 | 262 | 0,92 | 31 | 5+1 | 22 | 7 |
| Pega Puffles | 159 | 174 | 1,09 | 13 | 2+4 | 13 | 11 |
| base e componentes | 56 | 64 | 1,14 | 14 | 5+6 | 0 | 4 |
| **total** | **980** | **888** | **0,91** | | | | |

| Programa | campos de estado Lua (`self.x =`) | `var` Atmos | alvos de `set` Atmos |
|---|---:|---:|---:|
| main e jogo | 4 | 1 | 3 |
| menu | 4 | 0 | 0 |
| personalização | 4 | 0 | 1 |
| praça | 15 | 11 | 10 |
| Dojo | 15 | 3 | 6 |
| Bean Counters | 32 | 6 | 15 |
| Pega Puffles | 13 | 6 | 11 |
| base e componentes | 6 | 2 | 1 |

Construções de concorrência no Atmos:

| Programa | spawn | await | watching | par | loop on | toggle | emit | tasks/pin | abort |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| main | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| menu | 2 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| personalização | 4 | 1 | 0 | 0 | 3 | 0 | 0 | 0 | 0 |
| praça | 10 | 7 | 4 | 1 | 4 | 0 | 0 | 2 | 0 |
| Dojo | 4 | 3 | 2 | 0 | 1 | 0 | 2 | 4 | 0 |
| Bean Counters | 25 | 12 | 5 | 0 | 15 | 2 | 7 | 8 | 2 |
| Pega Puffles | 7 | 0 | 0 | 0 | 6 | 0 | 3 | 2 | 0 |
| base e componentes | 1 | 1 | 0 | 0 | 4 | 0 | 2 | 0 | 0 |

Leitura dos números:

- **tamanho**: o Atmos tem 9% menos linhas (888 × 980). A maior diferença
  está no fluxo de telas (22 × 58), em que a troca de telas é um laço com
  `await`;
- **condicionais**: caem no Atmos onde há fases (Bean Counters 22 × 7, praça
  16 × 3, fluxo 5 × 0). No Dojo e no Pega Puffles ficam perto, porque ali os
  `if` são regras do jogo (comparar cartas, testar colisão), não controle de
  fase;
- **estado de controle de fase**: no Lua aparece como campos (Bean Counters:
  `tonto`, `bloqueio`, `lancamento`, `fim`, `viva`; Dojo: `espera`, `rodada`,
  `resultado`, `prazo`, `viva`; praça: `ponto`, `destino`, `minigame`). No
  Atmos, os mesmos papéis são pontos de suspensão (`await 2s`,
  `watching :pinguim.atordoado`, `toggle ... await 250ms`). Os outros campos
  das duas contagens são sobretudo dados (retângulos, imagens, placar);
- **custo de correção de cada versão**: no Lua, a ordem dos passos e a regra
  dos prazos criados no passo; no Atmos, o alcance dos eventos (seção 2).

### 6.3 Forma das máquinas de estados (exemplos para o capítulo 5)

| Comportamento | Lua (classes) | Atmos (tasks) |
|---|---|---|
| Dojo, rodada | `Dojo:evento` só aceita clique quando `self.espera == nil`; `joga` cria `self.espera = Temporizador(2 s)`; `Dojo:tempo` avança cartas e espera e conta `rodada` até 3 | `loop in 3 { await <:clicked until ...>; ...; await 2s }`: a fase é o ponto do laço |
| Bean Counters, pinguim atordoado | `self.tonto` (Temporizador) testado em `tempo` antes de colidir e de andar; o minigame troca `self.lancamento` por 2 s | `await 2s` no laço de colisões e `watching :pinguim.atordoado { ... }` seguido de `await 2s` no movimento e no lançador |
| Bean Counters, intervalo da plataforma | `self.bloqueio` (Temporizador), criado na coleta ou entrega se não existir | `toggle entrega(false); await 250ms; toggle entrega(true)` |
| Praça, ir até um prédio | `self.ponto` e `self.destino`; `tempo` testa a colisão e anda | `watching :collided until (...)` sobre o movimento; `watching :mouse.button.dn` recomeça a caminhada |
| Botão com destaque | `Botao:em_cima()` decide a imagem no desenho; `Menu:evento` repassa o clique a cada botão | `Image_Hover` (um `loop on :draw`) + `XClickable(alvo, me)`; `Botao` termina no primeiro `:clicked`; o menu espera com `par :any` |
| Fim do minigame | `Centro:tempo` recebe as moedas de `minigame:tempo(dt)` e cria um novo pinguim | `set moedas = moedas + await BeanCounters()`: a continuação é a linha seguinte |

Cada linha tem diagramas em [`PADROES.md`](PADROES.md): máquina de estados e
comunicação das tasks; fluxo das funções do Lua.

Nos termos de Adya et al., o Lua faz *stack ripping* organizado em objetos: o
que seria uma variável local da sequência "esperar o clique, mostrar o
resultado por 2 s, passar à próxima rodada" vira campo do objeto (`espera`,
`rodada`). Nos termos do estudo do Pingus, os exemplos cobrem máquinas de
estados (Dojo, pinguim), passagem de continuação (fim do minigame),
hierarquia de vida (minigame dentro da praça, cargas e puffles em pools) e
sinalização (`:pinguim.coleta`, `:puffle.fugiu` no Atmos; métodos de
observador no Lua).
