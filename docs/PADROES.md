# Padrões de jogos no código da Ilha Geladeira

Padrões de *Game Programming Patterns* (NYSTROM, 2014) e do estudo
*Structured Synchronous Reactive Programming for Game Development — Case
Study: On Rewriting Pingus from C++ to Céu* (SANT'ANNA, SBGames 2018) que
aparecem no código, com exemplos nas duas versões e diagramas para os
capítulos de implementação e de resultados.

Caminhos relativos a `src/lua/` e `src/atmos/`. Estado do código em
24/11/2026.

## Como ler os diagramas

- **Atmos, máquina de estados da task**: cada estado é um ponto em que a task
  está suspensa (um `await`, um `watching` ou um laço `loop ... on`); as
  setas são os eventos que a fazem andar. O estado não fica em nenhuma
  variável: é a posição no código.
- **Atmos, comunicação**: caixas são tasks; setas são eventos (`emit`), com o
  alvo do `emit`. `clock`, `draw` e os eventos de entrada vêm do ambiente
  (`ambiente.lua`) e chegam a todas as tasks.
- **Lua, fluxo**: caixas são funções (métodos); setas são chamadas, na ordem
  em que acontecem dentro do quadro; losangos são testes sobre campos do
  objeto, que é onde o estado fica.

## Resumo

| Padrão | Fonte | Lua | Atmos | Onde entra no texto |
|---|---|---|---|---|
| Game Loop | Nystrom | `main.lua`: `tempo`, `evento`, `desenha` | `ambiente.lua`: emite tempo, entrada e `draw` | 4.2 e 4.3 (as duas arquiteturas) |
| Update Method + Dispatching Hierarchies | Nystrom + Pingus | cada objeto repassa `tempo`/`desenha` aos filhos | a árvore de tasks recebe o `emit` sem repasse | 5 (hierarquia de despacho) |
| State / Finite State Machines | Nystrom + Pingus | campos (`espera`, `tonto`, `bloqueio`, `ponto`) testados a cada quadro | posição no código (`await`, `watching`, `toggle`) | 5 (exemplo principal) |
| Continuation Passing | Pingus | o minigame devolve as moedas por `tempo()`; o `Centro` decide o passo seguinte | `moedas += await Minigame()`: a continuação é a linha seguinte | 5 |
| Lifespan Hierarchies | Pingus | campos `viva`, `lista.tira_mortos`, `self.minigame = nil` | tasks filhas morrem com a mãe (Escape aborta o minigame); pools | 5 |
| Signaling Mechanisms / Observer | Pingus + Nystrom | métodos de observador (`ao_coletar`...) | `emit`/`await` (`:pinguim.coleta`, `:pilha.cheia`) | 5 |
| Component | Nystrom | herança: `Predio` estende `Botao` | composição: `Image`, `Image_Hover`, `XClickable`, `XCollidable` | 4.3 e 5 |
| Subclass Sandbox | Nystrom | `Objeto` dá `tempo`/`evento`/`desenha` às subclasses | — (tasks no lugar de classes) | 4.2 |
| Type Object | Nystrom | `TIPOS`, `BARALHO`, `IMG_ATINGIDO` | `tipos`, `cartas`, `VENCE` | 4 (dados das regras) |
| Flyweight | Nystrom | um layer por imagem, compartilhado pelas cargas | idem | 4 (e o efeito colateral do giro) |
| Object Pool (relacionado) | Nystrom | listas `cargas`, `puffles` | `tasks(n)`: pools com limite e tempo de vida | 3 (pools do Atmos) |

Não aparecem: Command, Event Queue (o `emit` do Atmos é síncrono, não uma
fila), Spatial Partition (o empurrão dos puffles compara todos com todos),
Double Buffer (feito pelo pico-sdl: `clear`, desenhos, `present`), Bytecode,
Service Locator, Data Locality, Dirty Flag. Vale citar no texto que a
ausência é coerente com o tamanho do jogo.

---

## 1. Game Loop (Nystrom)

O laço de jogo separa o tempo do jogo do tempo real e repete: processar
entrada, atualizar, desenhar. As duas versões fazem o mesmo passo, na mesma
ordem, e usam o tempo real entre passos (`pico.get.now`).

- Lua: `main.lua:24` (o `while`), com `jogo:tempo(dt)`, `jogo:evento(e)` e
  `jogo:desenha()`.
- Atmos: `ambiente.lua:24` (`M.step`), que emite o tempo, o evento e `draw`;
  quem reage são as tasks.

```mermaid
flowchart TD
    A["pico.input.event"] --> B["dt = agora - antes"]
    B --> C["jogo:tempo dt"]
    C --> D{"chegou evento?"}
    D -- sim --> E["jogo:evento e"]
    D -- não --> F["pico.output.clear"]
    E --> F
    F --> G["jogo:desenha"]
    G --> H["pico.output.present"]
    H --> A
```

```mermaid
flowchart TD
    A["pico.input.event"] --> B["emit do tempo em microssegundos"]
    B --> C{"chegou evento?"}
    C -- sim --> D["emit do evento"]
    C -- não --> E["pico.output.clear"]
    D --> E
    E --> F["emit draw"]
    F --> G["pico.output.present"]
    G --> A
    B -. "acorda" .-> T["tasks com await de tempo ou loop on clock"]
    D -. "acorda" .-> U["tasks com await do evento"]
    F -. "acorda" .-> V["tasks com loop on draw"]
```

No texto: no Lua o laço *chama* os objetos; no Atmos o laço só *emite*, e
cada task diz o que espera.

## 2. Update Method (Nystrom) e Dispatching Hierarchies (Pingus)

Cada entidade sabe se atualizar e se desenhar; um contêiner repassa o
estímulo aos filhos. No Pingus, a cadeia de despacho (`update` e `draw`
descendo pela hierarquia) é um dos cinco padrões: em Céu ela some, porque o
evento chega a todos.

- Lua: `Jogo:tempo` (`jogo.lua:46`) → `Centro:tempo` (`centro.lua:53`) →
  `BeanCounters:tempo` (`bean_counters.lua:65`) → `Carga:tempo`,
  `Pinguim:tempo`. O mesmo para `desenha`. Cada nível precisa repassar, e a
  ordem do repasse é a ordem da atualização.
- Atmos: nenhum repasse. O `emit` percorre a árvore de tasks na ordem do
  código; uma task nova entra no despacho só por existir.

```mermaid
flowchart TD
    J["Jogo:tempo"] --> C["Centro:tempo"]
    C --> M{"minigame ativo?"}
    M -- sim --> B["BeanCounters:tempo"]
    M -- não --> P["Pinguim:tempo da praça"]
    B --> K["Carga:tempo de cada carga"]
    K --> L["lista.tira_mortos"]
    L --> Q["Pinguim:tempo do Bean Counters"]
    Q --> R["lancamento:tempo"]
    R --> S["fim:tempo"]
```

```mermaid
flowchart TD
    E(["ambiente: emit do tempo"]) --> C["Centro"]
    C --> P1["pool predios: 3 Predio"]
    C --> W["watching Escape"]
    W --> B["BeanCounters"]
    B --> PL["pool plataforma: Plataforma, Pilha 1, Pilha 2"]
    B --> CA["pool cargas: Carga, Carga, ..."]
    B --> PG["Pinguim"]
    B --> LA["lançador de cargas"]
    PG --> X1["XCollidable das cargas"]
    PG --> X2["XCollidable da plataforma"]
```

## 3. State (Nystrom) e Finite State Machines (Pingus)

Nystrom propõe trocar flags espalhadas por uma máquina de estados explícita.
O Pingus mostra o passo seguinte: com `await`, a máquina de estados vira
código sequencial e as variáveis de estado somem. As cinco subseções abaixo
são as linhas da tabela 6.3 do `ANALISE_TCC.md`.

### 3.1 Dojo: a rodada

- Atmos: `screens/minigames/dojo/dojo.atm:33-55` (laço das rodadas) e
  `carta.atm:22-33` (carta na mão, depois no campo).
- Lua: `dojo.lua:76` (`evento`), `:63` (`joga`), `:88` (`tempo`);
  `carta.lua:48` (`joga`), `:53` (`tempo`). Estado: `espera`, `rodada`,
  `resultado`, `prazo`, `viva`.

```mermaid
stateDiagram-v2
    [*] --> Sorteio
    Sorteio --> EsperaClique : 6 cartas criadas nas pools
    state "await clicked de carta do jogador" as EsperaClique
    state "inimigo escolhe, cartas reordenadas, comparação, emit present" as Jogada
    state "await 2s" as Resultado
    EsperaClique --> Jogada : clicked
    Jogada --> Resultado
    Resultado --> EsperaClique : menos de 3 rodadas
    Resultado --> [*] : 3 rodadas, devolve 100, 50 ou 0
```

```mermaid
stateDiagram-v2
    direction LR
    state "na mão: loop on draw dentro de watching present" as Mao
    state "no campo: imagem e ok ou x, watching 2s" as Campo
    [*] --> Mao
    Mao --> Campo : present com o resultado
    Campo --> [*] : 2 s
```

```mermaid
flowchart LR
    XC["XClickable da carta do jogador"] -- "clicked, me = carta" --> D["Dojo"]
    PR["Predio da praça, por baixo"] -. "clicked, filtrado pelo until" .-> D
    D -- "present, resul" --> CJ["Carta do jogador"]
    D -- "present, -resul" --> CI["Carta do inimigo"]
```

```mermaid
flowchart TD
    EV["Dojo:evento e"] --> T1{"self.espera?"}
    T1 -- sim --> FIM1["ignora"]
    T1 -- não --> CL["Carta:clicada e, para cada carta da mão"]
    CL --> JO["Dojo:joga carta"]
    JO --> AR["Dojo:arruma player e enemy"]
    AR --> CO["Carta:compara"]
    CO --> CJ["Carta:joga r e Carta:joga -r"]
    CJ --> ES["espera = Temporizador 2 s, rodada + 1"]
    TE["Dojo:tempo dt"] --> CT["Carta:tempo de cada carta"]
    CT --> TM["lista.tira_mortos"]
    TM --> T2{"espera acabou?"}
    T2 -- não --> FIM2["continua"]
    T2 -- sim --> T3{"rodada == 3?"}
    T3 -- não --> FIM3["espera = nil, volta a aceitar clique"]
    T3 -- sim --> RE["devolve 100, 50 ou 0 ao Centro"]
```

### 3.2 Bean Counters: pinguim atordoado

- Atmos: `bean_counters/pinguim.atm:47-71` (colisões), `:91-105`
  (movimento); `bean_counters.atm:50-62` (lançador). Três tasks reagem ao
  mesmo evento `:pinguim.atordoado`, cada uma com o seu `await 2s`.
- Lua: `pinguim.lua:53` (`pega`), `:82` (`tempo`, com o campo `tonto`);
  `bean_counters.lua:45` (`ao_ser_atingido`, que troca `lancamento`).

```mermaid
stateDiagram-v2
    direction LR
    state "loop on collided com carga" as Atento
    state "await 2s" as Tonto
    [*] --> Atento
    Atento --> Atento : café com espaço, emit coleta
    Atento --> Tonto : objeto ou café com o pinguim cheio, emit atordoado
    Tonto --> Atento : 2 s
```

```mermaid
stateDiagram-v2
    direction LR
    state "watching atordoado, loop on clock move com a seta" as Andando
    state "await 2s" as Parado
    [*] --> Andando
    Andando --> Parado : atordoado
    Parado --> Andando : 2 s
```

```mermaid
stateDiagram-v2
    direction LR
    state "await 0.5s" as Inicio
    state "watching atordoado, spawn Carga e await intervalo" as Lancando
    state "await 2s" as Pausa
    [*] --> Inicio
    Inicio --> Lancando : 0.5 s
    Lancando --> Lancando : intervalo, nova carga
    Lancando --> Pausa : atordoado
    Pausa --> Lancando : 2 s
```

```mermaid
flowchart LR
    XC["XCollidable das cargas"] -- "collided, oth = carga" --> PC["Pinguim: colisões"]
    PC -- "abort da carga" --> CA["Carga"]
    PC -- "pinguim.atordoado, alvo BeanCounters" --> BC["BeanCounters"]
    BC --> LA["lançador: para 2 s"]
    BC --> PM["Pinguim: movimento para 2 s"]
    BC --> FV["await do fim: vidas == 0?"]
```

```mermaid
flowchart TD
    TE["Pinguim:tempo dt"] --> CO{"colide com carga e não tonto?"}
    CO -- não --> TT
    CO -- sim --> PE["Pinguim:pega carga"]
    PE --> TI{"café e carga menor que 5?"}
    TI -- sim --> OC["observador:ao_coletar"]
    TI -- não --> HI["tonto = Temporizador 2 s, vidas - 1"]
    HI --> OA["observador:ao_ser_atingido"]
    OA --> LA["BeanCounters: lancamento = Temporizador 2 s"]
    OA --> VI{"vidas == 0?"}
    VI -- sim --> AC["BeanCounters:acaba"]
    TT["tonto:tempo dt"] --> EX{"acabou?"}
    EX -- sim --> RS["tonto = nil, imagem normal"]
    EX -- não --> MV{"tonto?"}
    MV -- não --> AN["anda conforme a seta"]
```

### 3.3 Bean Counters: intervalo da plataforma

- Atmos: `bean_counters/pinguim.atm:27-43` (entrega e `toggle`),
  `plataforma.atm`, `pilha.atm`.
- Lua: `pinguim.lua:47` (`bloqueia_plataforma`), `:71` (`entrega`);
  `plataforma.lua:14` (`recebe`); `bean_counters.lua:39` (`ao_entregar`).

```mermaid
stateDiagram-v2
    direction LR
    state "await coleta ou entrega" as Livre
    state "toggle off, await 250ms" as Bloqueada
    [*] --> Livre
    Livre --> Bloqueada : coleta ou entrega
    Bloqueada --> Livre : 250 ms, toggle on
```

```mermaid
stateDiagram-v2
    direction LR
    state "watching pilha.cheia, entregas vão para a pilha 1" as P1
    state "watching pilha.cheia, entregas vão para a pilha 2" as P2
    state "emit plataforma.cheia, await false" as Cheia
    [*] --> P1
    P1 --> P2 : pilha.cheia
    P2 --> Cheia : pilha.cheia
```

```mermaid
flowchart LR
    XP["XCollidable da plataforma"] -- "collided" --> PE["Pinguim: entrega, se ligada e com carga"]
    PE -- "pinguim.entrega, alvo BeanCounters" --> BC["BeanCounters"]
    BC --> PL["placar + 3"]
    BC --> TG["Pinguim: toggle da entrega"]
    BC --> PF["Plataforma"]
    PF -- "plataforma.entrega" --> PI["Pilha 1 ou Pilha 2"]
    PI -- "pilha.cheia" --> PF
    PF -- "plataforma.cheia" --> BC
```

```mermaid
flowchart TD
    TE["Pinguim:tempo dt"] --> CP{"colide com a plataforma, sem bloqueio e com carga?"}
    CP -- sim --> EN["Pinguim:entrega"]
    EN --> BL["bloqueia_plataforma: bloqueio = Temporizador 250 ms"]
    BL --> AE["observador:ao_entregar"]
    AE --> RC["Plataforma:recebe"]
    RC --> AD["Pilha:adiciona da primeira não cheia"]
    AE --> PL["placar + 3"]
    AE --> CH{"Plataforma:cheia?"}
    CH -- sim --> AC["BeanCounters:acaba"]
    CP -- não --> BT["bloqueio:tempo dt"]
    EN --> BT
    BT --> NB{"acabou?"}
    NB -- sim --> LB["bloqueio = nil"]
```

### 3.4 Praça: ir até um prédio

- Atmos: `screens/centro/pinguim.atm:28-77`; o destino chega pelo
  `:clicked` dos prédios (`predio.atm`), a chegada pelo `:collided`.
- Lua: `centro.lua:63` (`evento`), `pinguim.lua:27` (`escolhe_destino`),
  `:62` (`evento`), `:32` (`tempo`). Estado: `ponto`, `vel`, `destino`.

```mermaid
stateDiagram-v2
    direction LR
    state "await mouse.button.dn" as Parado
    state "watching clique, loop on clock anda até o ponto" as Andando
    state "await false, no ponto" as NoPonto
    [*] --> Parado
    Parado --> Andando : clique
    Andando --> Andando : novo clique, novo ponto
    Andando --> NoPonto : distância até o ponto menor que 0.01
    NoPonto --> Andando : novo clique
    Andando --> [*] : collided com o prédio destino
    NoPonto --> [*] : collided com o prédio destino
```

```mermaid
flowchart LR
    XK["XClickable de cada Predio"] -- "clicked, alvo Centro" --> PG["Pinguim: guarda o destino"]
    XC["XCollidable dos predios"] -- "collided" --> PG
    PG -- "termina e devolve o destino" --> CE["Centro: await Pinguim"]
    CE -- "await do minigame" --> MG["BeanCounters, Dojo ou PegaPuffles"]
```

```mermaid
flowchart TD
    EV["Centro:evento e"] --> PC{"Predio:clicado e?"}
    PC -- sim --> ED["Pinguim:escolhe_destino id"]
    PC -- não --> ES
    ED --> ES{"Escape?"}
    ES -- sim --> VM["Jogo:volta_menu"]
    ES -- não --> PE["Pinguim:evento e: novo ponto e velocidade"]
    TE["Centro:tempo dt"] --> PT["Pinguim:tempo dt"]
    PT --> CH{"Predio:colide e id == destino?"}
    CH -- sim --> IM["Centro:inicia_minigame id"]
    CH -- não --> MV{"tem ponto?"}
    MV -- sim --> PA{"o passo alcança o ponto?"}
    PA -- sim --> NP["vai para o ponto, ponto = nil"]
    PA -- não --> AN["anda um passo"]
```

### 3.5 Botão com destaque

- Atmos: `util/components/botao.atm` (feito sobre `Predio`),
  `image_hover.atm`, `xclickable.atm`; o menu espera o primeiro botão
  clicado com `par :any` (`screens/telas_menu/menu.atm`).
- Lua: `util/botao.lua` (`em_cima`, `clicado`, `desenha`);
  `menu.lua` repassa o evento a cada botão.

```mermaid
stateDiagram-v2
    direction LR
    state "Botao: await clicked" as Espera
    [*] --> Espera
    Espera --> [*] : clicked, devolve o id
```

```mermaid
flowchart LR
    IH["Image_Hover: loop on draw escolhe a imagem pelo mouse"]
    XK["XClickable, alvo = o Botao"] -- "clicked" --> BO["Botao"]
    BO -- "termina com o id" --> ME["Menu: par any dos três botões"]
    ME -- "termina com o id" --> MA["main: Centro, Personalizar ou fim"]
    PR["Predio"] --> IH
    PR --> XK
    BO --> PR
```

```mermaid
flowchart TD
    EV["Menu:evento e"] --> CL["Botao:clicado e, para cada botão"]
    CL -- "o primeiro clicado" --> ME["Jogo:menu_escolheu id"]
    DE["Menu:desenha"] --> BD["Botao:desenha"]
    BD --> EC["Botao:em_cima: mouse sobre o retângulo?"]
```

## 4. Continuation Passing (Pingus)

O fim de uma atividade longa leva a uma continuação. No Pingus, isso cobre a
troca de telas e o fim de fases. Aqui: o fim de um minigame volta à praça
com as moedas; o menu leva à praça ou à personalização, que voltam ao menu.

- Atmos: `screens/centro/centro.atm:37-50` e `main.atm:18-25`. A
  continuação é a linha seguinte ao `await`.
- Lua: `centro.lua:43-51` (`inicia_minigame`, `termina_minigame`) e
  `jogo.lua:19-36` (`menu_escolheu`, `volta_menu`). A continuação é um
  método chamado quando o valor volta.

```mermaid
stateDiagram-v2
    direction LR
    state "await Pinguim" as Praca
    state "await do minigame" as Jogando
    [*] --> Praca
    Praca --> Jogando : chegou ao prédio
    Jogando --> Praca : moedas = moedas + resultado
    Praca --> [*] : Escape, pelo watching
    Jogando --> [*] : Escape, aborta o minigame
```

```mermaid
flowchart TD
    CT["Centro:tempo dt"] --> MT["minigame:tempo dt"]
    MT --> RV{"devolveu moedas?"}
    RV -- sim --> TM["Centro:termina_minigame"]
    TM --> GM["Jogo:ganha_moedas"]
    TM --> NP["Centro:novo_pinguim"]
    MN["Menu:evento"] --> JE["Jogo:menu_escolheu"]
    JE --> NT["Jogo.tela = Centro ou Personalizacao"]
    VO["Escape ou Voltar"] --> VM["Jogo:volta_menu"]
    VM --> NM["Jogo.tela = Menu"]
```

## 5. Lifespan Hierarchies (Pingus)

Quando o contêiner termina, os filhos terminam juntos. No Atmos isso vem da
estrutura; no Lua, de código que zera referências e remove mortos.

- Atmos: o minigame é filho do `watching` de Escape do `Centro`
  (`centro.atm:37`): Escape aborta a caminhada ou o minigame inteiro, com as
  cargas e o pinguim. As cartas (`carta.atm:30`, `watching 2s`) e as cargas
  (`carga.atm:63`, `await until`) terminam sozinhas e saem da pool.
- Lua: `viva = false` e `lista.tira_mortos` (`util/lista.lua:6`), chamado em
  `dojo.lua` e `bean_counters.lua`; `self.minigame = nil` em
  `centro.lua:37`; `Jogo:volta_menu` troca a tela, e a antiga fica sem
  referência.

**Armadilha encontrada (anotar no texto).** A pool `predios` é criada no
corpo do `Centro` (`centro.atm:17`), fora do laço, e o minigame roda num
`await` dentro desse laço. Como o `Centro` continua vivo, os prédios também
continuam: desenham por baixo do minigame e emitem `:clicked` para a árvore do
`Centro`, onde está o Dojo. Um clique onde fica um prédio chegava ao Dojo
como carta; hoje há um filtro (`dojo.atm:34`). A correção pelo escopo seria
criar os prédios num bloco `do { pin predios = tasks(3) ... await Pinguim(...) }`
dentro do laço, para morrerem quando o pinguim chega. No Lua, o mesmo cuidado
é manual: `centro.lua:63` só repassa o clique se houver pinguim.

```mermaid
flowchart TD
    CE["Centro"] --> PR["pool predios"]
    CE --> WE["watching Escape"]
    WE --> MG["minigame"]
    MG --> PO["pools e tasks do minigame"]
    PO --> FI["filhos: XCollidable, laços, imagens"]
    ES(["Escape"]) -. "aborta tudo abaixo do watching" .-> WE
```

```mermaid
flowchart TD
    TE["BeanCounters:tempo"] --> CA["Carga:tempo: passou do chão? viva = false"]
    CA --> T1["lista.tira_mortos cargas"]
    T1 --> PG["Pinguim:tempo: pegou a carga? Carga:some"]
    PG --> T2["lista.tira_mortos cargas"]
```

## 6. Signaling Mechanisms (Pingus) e Observer (Nystrom)

Entidades sem relação de hierarquia precisam se avisar. Nystrom descreve o
Observer; o Pingus mostra eventos internos de Céu no lugar de sinais do
Boost.

- Atmos: `emit @(jogo) :pinguim.coleta`, `:pinguim.entrega`,
  `:pinguim.atordoado` (`bean_counters/pinguim.atm:31,50,65`);
  `:pilha.cheia` → `:plataforma.cheia` (`pilha.atm:16`,
  `plataforma.atm:30`); `:clicked` e `:collided` dos componentes. Quem quer
  ouvir só escreve um `await` ou `loop on`; quem emite não conhece os
  ouvintes.
- Lua: o `Pinguim` recebe um observador no construtor e chama
  `ao_coletar`, `ao_entregar` e `ao_ser_atingido`
  (`bean_counters/pinguim.lua:24`, `bean_counters.lua:35-48`). O emissor
  conhece a interface do observador; cada novo ouvinte exige mudar o
  observador.

```mermaid
flowchart LR
    PG["Pinguim"] -- "pinguim.coleta" --> PL1["placar + 2"]
    PG -- "pinguim.coleta" --> TG["toggle da entrega"]
    PG -- "pinguim.entrega" --> PL2["placar + 3"]
    PG -- "pinguim.entrega" --> TG
    PG -- "pinguim.entrega" --> PF["Plataforma"]
    PG -- "pinguim.atordoado" --> LA["lançador"]
    PG -- "pinguim.atordoado" --> MV["movimento do Pinguim"]
    PG -- "pinguim.atordoado" --> FM["fim do jogo: vidas"]
```

```mermaid
flowchart LR
    PG["Pinguim"] -- "ao_coletar" --> BC["BeanCounters, o observador"]
    PG -- "ao_entregar" --> BC
    PG -- "ao_ser_atingido" --> BC
    BC --> PL["placar"]
    BC --> PF["Plataforma:recebe"]
    BC --> LA["lancamento = Temporizador 2 s"]
    BC --> AC["acaba"]
```

## 7. Component (Nystrom)

Comportamentos reutilizáveis presos a uma entidade, em vez de herança.

- Atmos: `Image`, `Image_Hover`, `XClickable`, `XCollidable`
  (`util/components/`) são tasks filhas que dão a uma entidade um
  comportamento. `Predio` = `Image_Hover` + `XClickable`; `Botao` = `Predio`
  + `await :clicked`; `Carta` do jogador ganha um `XClickable`; os pinguins
  ganham `XCollidable`.
- Lua: herança. `Predio` estende `Botao` (`screens/centro/predio.lua`), que
  estende `Objeto`. A colisão é um método (`Predio:colide`), não um
  componente.

```mermaid
flowchart TD
    BO["Botao"] --> PR["Predio"]
    PR --> IH["Image_Hover"]
    PR --> XK["XClickable"]
    CA["Carta do jogador"] --> XK2["XClickable"]
    CA --> IM["Image"]
    PC["Pinguim da praça"] --> XC["XCollidable dos predios"]
    PB["Pinguim do Bean Counters"] --> XC2["XCollidable das cargas"]
    PB --> XC3["XCollidable da plataforma"]
```

```mermaid
flowchart TD
    OB["Objeto: extend, new, init, tempo, evento, desenha"] --> BT["Botao: em_cima, clicado, desenha"]
    BT --> PD["Predio: colide"]
    OB --> PI["Pinguim, Carga, Carta, Puffle, telas"]
```

## 8. Subclass Sandbox (Nystrom)

A classe base dá às subclasses um conjunto de operações e ganchos; cada
subclasse só preenche o que precisa. No Lua, `Objeto` (`util/objeto.lua`)
define `extend`/`new`/`init` e os ganchos vazios `tempo`, `evento` e
`desenha`, que o laço chama em toda tela e entidade (diagrama da seção 7).
No Atmos não há equivalente: cada task é uma unidade com o próprio fluxo.

## 9. Type Object (Nystrom)

Os tipos são dados, não classes: um novo tipo de carga ou de carta é uma
linha na tabela.

- Lua: `TIPOS` (`bean_counters/carga.lua:6`), `IMG_ATINGIDO`
  (`bean_counters/pinguim.lua:15`), `BARALHO` (`dojo/dojo.lua:12`).
- Atmos: `tipos` (`bean_counters/carga.atm:1`), `cartas` e `VENCE`
  (`dojo/dojo.atm:6,14`).

```mermaid
flowchart LR
    TB["BARALHO: elemento, poder, imagem"] --> C1["Carta FOGO 4"]
    TB --> C2["Carta FOGO 7"]
    TB --> C3["Carta GELO 5"]
    TB --> C4["Carta GELO 6"]
    VE["VENCE: GELO vence AGUA, AGUA vence FOGO, FOGO vence GELO"] --> CO["comparação das cartas"]
```

## 10. Flyweight (Nystrom)

Os dados pesados (a textura) são compartilhados; cada instância guarda só o
que é seu (posição). O pico-sdl guarda um layer por caminho de imagem, criado
uma vez por partida (`bean_counters.lua:20-24`, `bean_counters.atm`); todas
as cargas do mesmo tipo usam o mesmo layer. Bom ponto para o texto: o giro do
café é um efeito do layer, então é compartilhado também, e cada carga
precisa ajustá-lo antes de se desenhar (`carga.lua:63`, `carga.atm:51`); as
pilhas o zeram (`pilha.lua:22`, `pilha.atm`).

```mermaid
flowchart LR
    L["layer Coffe_bag.webp: textura e giro"] --- C1["Carga 1: posição"]
    L --- C2["Carga 2: posição"]
    L --- P["Pilhas: posições, giro 0"]
```

## 11. Object Pool (relacionado)

Nystrom descreve o Object Pool como reaproveitamento de memória. O `tasks(n)`
do Atmos não reaproveita memória, mas tem duas coisas do padrão: o limite de
tamanho (`tasks(3)` para os prédios e as cartas, `tasks(#path_puffles)` para
os puffles) e a gestão do ciclo de vida (a task que termina sai da pool). No
Lua, as listas `cargas` e `puffles` fazem o papel, com remoção explícita.
Melhor citar como "relacionado", não como o padrão.

## 12. Observações para o texto

- Em cada linha da tabela 6.3, a coluna Atmos tem um diagrama de estados que
  é o próprio código lido de cima para baixo; a coluna Lua tem o estado em
  campos e o fluxo espalhado entre `evento` e `tempo`. É a tese do Pingus
  ("variáveis com nomes suspeitos" como `tonto`, `bloqueio`, `espera`).
- O preço do Atmos aparece nos diagramas de comunicação: quem recebe um
  evento depende do alcance do `emit`. Dois erros reais vieram disso (o
  `:clicked` dos prédios chegando ao Dojo; o `until` que encerrava o laço de
  colisões). O `emit` por referência (`emit @(jogo)`, `XClickable(alvo, me)`)
  reduziu o risco. Resta um `emit @2` em `pega_puffles/puffle.atm:69`.
- O preço do Lua aparece nos diagramas de fluxo: a ordem das chamadas dentro
  do quadro é semântica, e os prazos criados num passo só podem contar no
  seguinte. No Atmos isso vem do escalonador.
