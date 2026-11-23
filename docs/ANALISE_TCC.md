# Análise de apoio ao TCC

Trabalho de apoio ao TCC *Desenvolvimento de Jogos: Uma Análise Comparativa
entre Orientação a Objetos e Concorrência Estruturada* (UERJ, 2026), em três
partes:

1. validação das duas conversas com o ChatGPT;
2. fluxo de leitura, estrutura do texto e tópicos;
3. o repositório `pico-tcc` como base da comparação.

A parte 4 (equivalência entre as versões Lua e Atmos) está em
[`EQUIVALENCIA.md`](EQUIVALENCIA.md).

Data da análise: 23/11/2026. Versões consultadas: artigo
`TCC___Samuel-26.pdf` (12 páginas); Atmos `atmos-lang dev-4` (CLI v0.8) e
repositório `atmos-lang/atmos` em `a06998a` (20/10/2026); `pico-tcc` em
`fb04dd3` e seguintes.

---

## 0. Fontes e como foram lidas

Cada referência citada nas conversas foi localizada e conferida. A tabela diz
o que foi lido de fato. Os textos da ACM (`dl.acm.org`) ficaram atrás de uma
verificação anti-robô; nesses casos, usei a versão aberta dos autores quando
existe e, quando não existe, só os metadados (Crossref) e o resumo.

| Fonte | Como foi lida |
|---|---|
| Chen & You, *Structured Concurrency: A Review* (2022) | resumo (Semantic Scholar) e lista de referências (Crossref, OpenAlex); texto integral bloqueado |
| Teodorescu, *Overload* 168, 174 e 181 | texto integral (accu.org) |
| Elizarov et al., *Kotlin Coroutines: Design and Implementation* (2021) | metadados e página da SPLASH; texto integral bloqueado |
| Brockbernd et al., ECOOP 2024 | página, resumo e referências (Dagstuhl) |
| Beronić et al. (MIPRO 2021), Pufek et al. (MIPRO 2020), Zhang et al. (MDPI 2025) | metadados (Crossref) |
| de Moura & Ierusalimschy, *Revisiting Coroutines* | texto integral do relatório técnico PUC-Rio MCC 15/04 (2004), versão do artigo da TOPLAS |
| Smith, *Notes on structured concurrency* (2018) | texto integral |
| Adya et al., *Cooperative Task Management...* (2002) | texto integral (PDF) |
| Tanter, *Beyond Static and Dynamic Scope* (2009) | metadados e resumo |
| Allais et al. (ICFP 2018) | resumo e introdução da versão estendida (arXiv 2001.11001) |
| Milano et al. (PLDI 2022) | resumo e introdução (PDF aberto, NSF PAR) |
| *Rust Async Book*, capítulo *Structured concurrency* | texto integral |
| Erlang/OTP *Design Principles* (OTP 25) | texto integral das seções de supervisão |
| Dahl, Dijkstra & Hoare, *Structured Programming* (1972) | não lido (livro); existência confirmada pela lista de referências de Chen & You |
| Berry & Gonthier (1992) | texto integral (digitalização com OCR) |
| Boussinot & de Simone (1991); Tardieu (2007); Berry, Ramesh & Shyamasundar (1993); Berry (1993) | metadados (Crossref) e resumos |
| Tardieu & Edwards, *Instantaneous Transitions in Esterel* | texto integral (SLA++P'07) |
| Céu: TECS 2017, LCTES 2018, SenSys 2013, relatório técnico 2012 | texto integral (versões dos autores) |
| Sant'Anna, *Structured (Synchronous) Concurrency* (`fsantanna.github.io/sc.html`) | texto integral |
| Sant'Anna, *Pingus: C++ → Céu* (SBGames 2018) | texto integral (PDF em `docs/` do repositório) |
| Manual e guia do Atmos; manual do Céu v0.30 | texto integral (repositórios) |
| Ierusalimschy, de Figueiredo & Celes, *The evolution of Lua, continued* (2025) | texto integral (`lua.org/doc/cola.pdf`) |
| Nystrom, *Game Programming Patterns*; notas CS442 de Waterloo | páginas citadas (texto integral) |
| Ramadan & Widyani (2013); Raynal (2013) | metadados (Crossref) e resumo |

---

## 1. Validação das conversas com o ChatGPT

**Situação:** *correta*; *imprecisa* (existe, mas com dado ou atribuição
errada, ou exagero); *errada*; *referência inexistente* (não existe com
aquele título ou autoria). **Adequação** ao TCC: alta, média ou baixa.

### 1.1 Conversa 1: "Artigos sobre concorrência estruturada"

#### Artigos "parecidos" com Chen & You

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 1 | Chen & You (2022) trata da relação entre concorrência estruturada, corrotinas e ciclo de vida das tarefas | CHEN, Y.-A.; YOU, Y.-P. Structured Concurrency: A Review. *Workshop Proceedings of the 51st International Conference on Parallel Processing (ICPP Workshops '22)*. ACM, 2022, p. 1–8. DOI 10.1145/3547276.3548519 | correta | O resumo defende que a concorrência estruturada nasce das corrotinas: "the foundation established by coroutines that gives birth to structured concurrency". **O artigo do TCC cita "Association for Computing Machinery, 2023": corrigir para ICPP Workshops 2022.** Adequação alta. |
| 2 | Teodorescu, *Structured Concurrency in C++* (2022) | TEODORESCU, L. R. *Overload*, v. 30, n. 168, p. 9–14, abr. 2022 | correta | Discute escopo léxico ("A lexical scope isolates the local concerns of a code block") e raciocínio local. Adequação média (C++, modelo assíncrono). |
| 3 | Teodorescu, *In Search of a Better Concurrency Model* (2023), baseado em computações, corrotinas e senders/receivers | *Overload*, v. 31, n. 174, p. 10–15, abr. 2023 | imprecisa | É um modelo teórico para a linguagem Val, com sintaxe de corrotinas *stackful* e a eficiência de senders/receivers como meta; o autor diz: "It is purely theoretical, there is no real implementation for it." Adequação baixa. |
| 4 | Elizarov, Belyaev, Akhin e Usmanov, *Kotlin Coroutines: Design and Implementation*, Onward! 2021 | *Proc. Onward! 2021*, ACM, p. 68–84. DOI 10.1145/3486607.3486751 | imprecisa | Os dados bibliográficos estão certos, mas **o link dado aponta para outro artigo** (ECOOP 2024, item 5). Texto integral não lido. Adequação média (a concorrência estruturada do Kotlin é uma referência da indústria). |
| 5 | *Understanding Concurrency Bugs in Real-World Programs with Kotlin Coroutines*, ECOOP 2024 | BROCKBERND, B.; KOVAL, N.; VAN DEURSEN, A.; OZKAN, B. K. ECOOP 2024, LIPIcs v. 313, p. 8:1–8:20. DOI 10.4230/LIPIcs.ECOOP.2024.8 | correta (sem autores) | Estudo empírico de 55 bugs em 7 projetos. O resumo não fala em concorrência estruturada. Adequação baixa (pode motivar a discussão de correção). |
| 6 | Beronić, Pufek, Mihaljević e Radovan, *On Analyzing Virtual Threads...*, 2021 | MIPRO 2021, p. 1684–1689. DOI 10.23919/MIPRO52101.2021.9596855 | imprecisa | Os dados estão certos, mas **o link dado é de outro artigo**: ZHANG, Y. et al. *Refactoring for Java-Structured Concurrency*. *Applied Sciences*, 15(5):2407, 2025. Trata de desempenho de *virtual threads*. Adequação baixa. |
| 7 | Pufek, Beronić, Mihaljević e Radovan, *Achieving Efficient Structured Concurrency through Lightweight Fibers in JVM*, 2020 | MIPRO 2020. DOI 10.23919/MIPRO48935.2020.9245253 | imprecisa | Mesmo problema do link (aponta para o artigo da MDPI de 2025). Adequação baixa. |
| 8 | de Moura & Ierusalimschy, *Revisiting Coroutines*, TOPLAS 2009: classificação de corrotinas, semântica operacional, relação com continuações; autores da PUC-Rio | *ACM TOPLAS*, v. 31, n. 2, art. 6, p. 1–31, 2009. DOI 10.1145/1462166.1462167 | correta | Propõe uma classificação nova, define as corrotinas assimétricas completas por semântica operacional e mostra que elas têm o poder expressivo das continuações *one-shot*. Adequação **alta**: as tasks do Atmos são corrotinas de Lua (manual do Atmos, seção *Structured Deterministic Concurrency*). |
| 9 | Smith (2018), *Notes on structured concurrency, or: Go statement considered harmful*: motivação, *nurseries* do Trio | post de blog, 25 abr. 2018 | correta | Argumenta que "go statements are a form of goto statement" e propõe as *nurseries*. Não é revisado por pares, mas é a referência mais citada da área (Chen & You o citam). Adequação alta. |
| 10 | A concorrência estruturada ainda é recente "como paradigma formal" | Chen & You (resumo); Sant'Anna, `sc.html` | imprecisa | O *nome* é recente (Sústrik 2016, Smith 2018). Sant'Anna, porém, mostra que as linguagens síncronas, desde os anos 1980, já reforçam "lexically-scoped tasks with safe cancellation". Para o TCC, essa linhagem (Esterel → Céu → Atmos) é central. |

#### Ciclo de vida, hierarquia, escopo e *binding*

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 11 | Vocabulário: ciclo de vida, hierarquia, escopo léxico, *extent*, *binding*, *lifetime*; "escopo léxico de variáveis e escopo temporal de tarefas são diferentes, e a concorrência estruturada busca fazê-los coincidir" | Manual do Atmos (*Structured Deterministic Concurrency*); *Rust Async Book* | correta | O manual do Atmos diz exatamente isso: "tasks in Atmos are treated in the same way as local variables". |
| 12 | Chen & You discutem as diferenças entre concorrência estruturada e programação estruturada | Chen & You (resumo) | imprecisa | O artigo **contesta** a visão de que a concorrência estruturada seja sucessora da programação estruturada e propõe outra origem, as corrotinas. |
| 13 | Teodorescu (2022) discute escopos, decomposição hierárquica e raciocínio local; "quando uma tarefa sobrevive ao contexto que a criou, perde-se o raciocínio local" | *Overload* 168 | imprecisa | Os temas estão lá. A frase atribuída não está: o autor diz que se perde o raciocínio local ao passar continuações entre tarefas ("we lose the ability for local reasoning") e que primitivas de sincronização "act like GOTO commands". A tese é que as *computations* estão para a concorrência como as funções para a programação estruturada. |
| 14 | Teodorescu, *Concurrency: From Theory to Practice* (2024) | *Overload*, v. 32, n. 181, p. 21–27, jun. 2024 | correta | Modelo `spawn`/`await` sobre corrotinas *stackful* (biblioteca concore2full), com medições. Adequação baixa. |
| 15 | Adya et al., *Cooperative Task Management Without Manual Stack Management* (USENIX 2002), que "aparece nas referências de Chen & You" | ADYA, A.; HOWELL, J.; THEIMER, M.; BOLOSKY, W. J.; DOUCEUR, J. R. In: *USENIX Annual Technical Conference*, 2002 | correta; a citação por Chen & You é provável | O link dado (trilha FREENIX) dá 404; o artigo é da conferência principal. Na lista de Chen & You (Crossref), a entrada `10.5555/647057.713851` cai na posição alfabética de "Adya", mas não pude confirmar pelo texto. Adequação **alta**, e a conversa a subestimou: o artigo separa *gerenciamento de tarefas* de *gerenciamento de pilha*. A versão Lua do `pico-tcc` é o caso cooperativo com pilha manual (o estado de cada comportamento vira campos de tabela, o *stack ripping*); a versão Atmos é o cooperativo com pilha automática. É a moldura teórica exata da comparação. |
| 16 | Tanter, *Beyond Static and Dynamic Scope* (2009): escopo × *extent* | *Proc. DLS 2009*, ACM, p. 3–14. DOI 10.1145/1640134.1640137 | imprecisa | Existe. O tema são estratégias de escopo (propagação e ativação de mecanismos como aspectos), não *extent* de tarefas. Adequação baixa. |
| 17 | Allais et al., *A Type and Scope Safe Universe of Syntaxes with Binding* (2018) | *PACMPL*, v. 2, ICFP, p. 1–30. DOI 10.1145/3236785 | correta | Programação genérica de sintaxes com *binders* em Agda. Fora do escopo do TCC. Adequação nenhuma. |
| 18 | Revisiting Coroutines: simétricas × assimétricas, continuações | idem item 8 | correta | — |
| 19 | Erlang/OTP: árvores de supervisão (supervisores, *workers*, estratégias de reinício) | Erlang/OTP 25, *Design Principles* | correta | As estratégias (one_for_one, one_for_all, rest_for_one) estão na seção de supervisores. Adequação baixa: serve só de contraste (hierarquia sem escopo léxico). |
| 20 | *Rust Async Book*: "temporal scope follows lexical scope" | capítulo *Structured concurrency* | correta | A frase está lá ("Primarily, temporal scope follows lexical scope"), mas o capítulo é um rascunho, com marcas TODO. Cite com essa ressalva. |
| 21 | Milano, Turcotti e Myers, *A Flexible Type System for Fearless Concurrency* (PLDI 2022) | *Proc. PLDI 2022*, p. 458–473. DOI 10.1145/3519939.3523443 | correta | O segundo autor aparece como Joshua no PDF e como Julia no registro da ACM. O tema são tipos contra corridas de dados; o Atmos não tem memória compartilhada entre threads. Adequação nenhuma. |
| 22 | Dahl, Dijkstra & Hoare, *Structured Programming* (1972), presente nas referências de Chen & You | Academic Press, 1972; lista de Chen & You (Crossref) | correta | Adequação média: origem histórica do termo "estruturado". |
| 23 | Separar a hierarquia das entidades da hierarquia das tasks | código do `pico-tcc` | correta (boa sugestão) | No `pico-tcc` as duas quase coincidem (cada entidade é uma task), com exceções úteis para o texto: os componentes `XClickable` e `XCollidable` são tasks sem entidade. |

#### "E Esterel?"

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 24 | Esterel é imperativa, síncrona e reativa, de Berry; hipótese de sincronismo; `\|\|` termina quando todos os ramos terminam | BERRY, G.; GONTHIER, G. The Esterel synchronous programming language: design, semantics, implementation. *Science of Computer Programming*, 19(2):87–152, 1992 | correta | O resumo define a linguagem pela "synchrony hypothesis"; a seção do paralelo descreve o término conjunto dos ramos. |
| 25 | Berry & Gonthier (1992) é indispensável | idem | correta | Adequação média: basta a parte inicial, para a hipótese de sincronismo e a preempção. |
| 26 | Boussinot & de Simone, *The Esterel Language* (1991) | *Proceedings of the IEEE*, 79(9):1293–1304, 1991. DOI 10.1109/5.97299 | correta | O link dado dá 404. Adequação média (introdução curta). |
| 27 | Tardieu, *A Deterministic Logical Semantics for Pure Esterel* (TOPLAS 2007) | *ACM TOPLAS*, 29(2), art. 8, 2007 | correta | Adequação baixa (semântica formal). |
| 28 | Tardieu & Edwards, *Instantaneous Transitions in Esterel*: escopos e prioridades para desvios de controle | SLA++P 2007 (versão preliminar) | correta | "Concurrency demands we assign scopes and priorities to gotos". Adequação baixa. |
| 29 | *Communicating Reactive Processes* (POPL 1993), de "Gérard Boudol e outros" | BERRY, G.; RAMESH, S.; SHYAMASUNDAR, R. K. *Proc. POPL '93*, p. 85–98. DOI 10.1145/158511.158526 | **errada (autoria)** | Os autores são Berry, Ramesh e Shyamasundar. O conteúdo (nós Esterel síncronos ligados por canais assíncronos) está certo. Adequação baixa. |
| 30 | Tabela Esterel × concorrência estruturada ("concorrência estruturada geralmente assíncrona") | `sc.html` | imprecisa | É verdade para Kotlin, Swift e Trio, mas o orientador defende o oposto: a concorrência estruturada *deve* ser síncrona, porque o aborto seguro (preempção) exige um modelo dependente do tempo (Berry, 1993). |

#### "E Céu?"

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 31 | Céu é reativa síncrona, criada por Francisco Sant'Anna (UERJ) "entre outros" | Relatório técnico PUC-Rio MCC 12/12 (2012); SenSys 2013 | imprecisa | Céu nasceu no doutorado de Sant'Anna na **PUC-Rio** (com Rodriguez e Ierusalimschy); a UERJ é a filiação atual dele (TECS 2017). |
| 32 | *The Design and Implementation of the Synchronous Language CÉU* (TECS 2017): Sant'Anna, Ierusalimschy, Rodriguez, Rossetto e Branco | *ACM TECS*, 16(4):1–26, 2017. DOI 10.1145/3035544 | correta | Inspirada em Esterel, com verificação em tempo de compilação de comandos concorrentes conflitantes, eventos internos em pilha, integração com C e finalização. Adequação **alta** (trabalhos relacionados). |
| 33 | *A Memory-Bounded, Deterministic and Terminating Semantics for... Céu* (LCTES 2018): Santos, Lima, Sant'Anna, Ierusalimschy e Haeusler; semântica *small-step* | *Proc. LCTES 2018*, p. 1–18. DOI 10.1145/3211332.3211334 | correta | Semântica operacional estrutural *small-step*, com prova de reações limitadas, determinísticas e com memória finita. Adequação média. |
| 34 | *Céu: Embedded, Safe, and Reactive Programming* (2012), Sant'Anna, Rodriguez e Ierusalimschy | Relatório técnico PUC-Rio MCC 12/12, 2012 | correta | — |
| 35 | *Safe Concurrent Abstractions for Wireless Sensor Networks* (2013) | lista de publicações de `ceu-lang.org`; preprint do SenSys 2013 | **referência inexistente** (com esse título) | O artigo de Céu no SenSys 2013 chama-se *Safe System-level Concurrency on Resource-Constrained Nodes* (Sant'Anna, Rodriguez, Ierusalimschy, Landsiedel e Tsigas). Adequação baixa (redes de sensores). |
| 36 | Unidade de execução de Céu é a *trail*; "gerenciamento estático de memória baseado em escopo léxico" | TECS 2017 ("known as trails"); manual do Céu v0.30, *Overview* | correta | A frase está no **manual v0.30** (`docs/manual/v0.30`), não no site, ao contrário do que a conversa sugere. |

#### "E Atmos?"

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 37 | Atmos, de Sant'Anna, reconcilia concorrência estruturada e programação orientada a eventos; subtítulo *Structured Event-Driven Concurrency* | README e manual do Atmos | correta | — |
| 38 | Combina concorrência determinística, eventos, ciclo de vida léxico, *streams* funcionais e paralelismo por threads | manual, seção *DESIGN*; guia, seção 7 | correta | O manual também avisa: "Atmos is in **experimental stage**". |
| 39 | Tabela de construções: `task`, `spawn`, `pin` ("vincula ao escopo léxico"), `tasks`, `await`, `emit`, `par`, `watching`, `defer` | manual (*Tasks*, *Local Variables*, *Emit*) | imprecisa | Duas ressalvas. **`pin`**: toda task criada por `spawn` já fica presa ao bloco onde nasce ("By default, an unassigned `spawn` attaches the new task to the enclosing block"); o `pin` dá um nome à referência e é obrigatório para pools. **`emit`**: o alcance padrão é a task corrente e seus descendentes (`:task`); para todas as tasks, `emit @:global`. Faltaram construções usadas no `pico-tcc`: `toggle`, `loop ... on`, `pub`, `abort`, `throw`/`catch`. |
| 40 | Citação "The lexical organization of tasks determines their lifetimes." e o exemplo do `spawn` aninhado | guia, seções 3 e 3.2 | correta | A frase continua: "...and also how they are scheduled". |
| 41 | "Veja as seções 3.2, 3.2.1, 5.2 e 6 do guia" | guia | correta | *Lexical Hierarchy*, *Deferred Statements*, *Task Pools* e *Errors*. |
| 42 | Tabela Esterel/Céu/Atmos | manuais | correta, em linhas gerais | — |
| 43 | Núcleo síncrono e cooperativo, mais threads isoladas para paralelismo | guia, seções 3.1 e 7.2 | correta | "deterministic and cooperative"; as threads "cannot use Atmos standard primitives like `await`, `emit`, or `spawn`". |
| 44 | `sc.html`: compara concorrência estruturada, Esterel, threads, MapReduce e FRP em dois eixos (procedural × funcional; síncrono × assíncrono); recomenda Berry (1993) | SANT'ANNA, F. *Structured (Synchronous) Concurrency*. Disponível em `fsantanna.github.io/sc.html` | correta | Chama Berry (1993) de "the most interesting paper to connect SC with Esterel". Para o TCC, vale um ponto que a conversa não citou: segundo o post, a hipótese de sincronismo vale para a maioria das aplicações reativas, **entre elas os video games**. |
| 45 | Berry, *Preemption in Concurrent Systems* (1993) | FSTTCS 1993, LNCS v. 761, p. 72–93. DOI 10.1007/3-540-57529-4_44 | correta | Adequação média. |
| 46 | Não há artigo acadêmico que formalize o Atmos | lista de publicações de `ceu-lang.org`; repositório | correta, até onde verifiquei | As fontes são o manual, o guia e o repositório. Cite o manual com versão e data. |

#### *Streams*, fluxo de estudos e o projeto

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 47 | *Streams* funcionais com `map`, `filter` e `reduce`; no Atmos, sobre eventos ao longo do tempo | guia, seção 7.1 | correta, com exemplo inválido | O código de exemplo (`numbers:map(...)`) não funciona em Lua puro, porque tabelas não têm métodos `map`. No Atmos, as *streams* vêm da biblioteca f-streams ("à la ReactiveX"), puxadas pelo consumidor. O `pico-tcc` não as usa: deixe-as fora do TCC ou como trabalho futuro. |
| 48 | Fluxo de estudos em 6 etapas e 8 semanas (escopo e *binding* → modelos → concorrência estruturada → Esterel/Céu → Atmos → síntese) | — | imprecisa (desalinhada) | Organizado, mas voltado a um estudo de semântica comparada de cinco linguagens, não à comparação Lua × Atmos em jogos. Sobram Tanter, Allais, Milano, Tardieu, CRP e os artigos da JVM. **Faltam** as leituras mais próximas do TCC: o caso Pingus de Sant'Anna (C++ → Céu), Adya et al. e Nystrom. Ver a parte 2. |
| 49 | O `pico-tcc` é "uma aplicação desenvolvida com Atmos" | repositório | imprecisa | Tem as **duas** versões do mesmo jogo, `src/codes_tcc/pico_ilha_geladeira` (Lua) e `src/codes_tcc/atmos_ilha_geladeira` (Atmos), além de uma versão anterior em C (`src/codes_eletiva`). Ver a parte 3. |
| 50 | Resumo do PDF (título; Lua como OO; Atmos como concorrência estruturada) | artigo do TCC | correta | — |

### 1.2 Conversa 2: continuação

| # | Afirmação | Fonte conferida | Situação | Correção e citação |
|---|---|---|---|---|
| 51 | Comparar *abordagens* (organização de comportamentos), não linguagens | manual do Atmos; código | correta e bem fundamentada | O Atmos compila para Lua e "mimics most of the semantics of Lua" (manual, *DESIGN*); as diferenças estão no controle, não nos dados. |
| 52 | OO, concorrência estruturada e eventos são dimensões diferentes e podem coexistir | código | correta | No `pico-tcc` Atmos, cada task expõe estado por `pub` (como um objeto) e se comunica por eventos. |
| 53 | Faltam no texto as seções de concorrência estruturada e de programação orientada a eventos; a seção de OO repete a de programação estruturada | artigo do TCC, p. 3–4 | correta | Os dois primeiros parágrafos da seção 2.1.2 copiam os da 2.1.1. |
| 54 | Citar Chen & You não basta: é preciso fundamentar as propriedades que serão observadas | — | correta | — |
| 55 | Experimentos sugeridos: movimento, animação, inimigo perseguindo o jogador, projétil, dano e morte, interface | código | imprecisa | Genéricos. O `pico-tcc` **já tem** equivalentes: movimento até um alvo (pinguim do centro), estados com tempo (pinguim atordoado no Bean Counters), projéteis (cargas), dano e vidas, fuga e empurrão (puffles), interface (botões com *hover*, placar). Use-os em vez de criar experimentos novos. |
| 56 | Não comparar só linhas de código; perguntas sobre onde fica o estado, quantos pontos mudam, como começa, como termina, como reage a eventos | Sant'Anna (Pingus, SBGames 2018) | correta | É o método do estudo do Pingus, que mede variáveis de estado e classifica o código em cinco padrões de controle. |
| 57 | Não presumir que propriedades da concorrência estruturada *assíncrona* valham para o modelo *síncrono* do Atmos | `sc.html`; guia, seção 3.1 | correta | — |
| 58 | Estrutura proposta: introdução, fundamentação, Atmos, metodologia e experimentos, trabalhos relacionados, conclusão | — | correta, com ajustes | Ver a parte 2 (separar resultados da metodologia e incluir a equivalência). |
| 59 | Começar escrevendo três experimentos novos, a partir de "um inimigo que persegue o jogador" | repositório | imprecisa | A prioridade, com base no repositório, é garantir que as duas versões existentes façam a mesma coisa (parte 4) e medir. |
| 60 | O GitHub não mostrou `src` e `docs`; o README descreve o projeto original | — | correta | Limitação da ferramenta dele. Esta análise leu o código local. |

### 1.3 Observações sobre o próprio artigo (referências e texto)

| Ponto do artigo | Situação | Correção |
|---|---|---|
| [1] Ramadan & Widyani (2013), citado para definir "jogo" | existe (ICACSIS 2013, p. 95–100, DOI 10.1109/ICACSIS.2013.6761558); conteúdo inadequado | O artigo propõe um *ciclo de desenvolvimento* de jogos (GDLC), não uma definição de jogo. Para definir jogo, sugiro uma fonte de *game studies*, como Salen & Zimmerman (*Rules of Play*, 2004) ou Juul (*Half-Real*, 2005). Não as conferi nesta análise. |
| [2] *The evolution of Lua, continued* | dados incompletos | IERUSALIMSCHY, R.; DE FIGUEIREDO, L. H.; **CELES, W.** *Journal of Computer Languages*, v. 83, 101326, 2025. DOI 10.1016/j.cola.2025.101326. Sustenta a afirmação: Lua "is one of the leading scripting languages in game development". |
| [3] Cormen et al., *Introduction to Algorithms*, citado para o padrão Observer e como "Nystrom [3]" | **errada** | Trocar por NYSTROM, R. *Game Programming Patterns*. Genever Benning, 2014 (`gameprogrammingpatterns.com`), que tem os capítulos *Observer*, *State*, *Game Loop* e *Update Method*. A ideia de OO sem classes está no capítulo *Prototype*, sobre a linguagem Self. Para o Observer original: GAMMA, E. et al. *Design Patterns*, 1994. |
| [4] Chen & You | veículo errado | ICPP Workshops '22, ACM, 2022, p. 1–8. |
| [5] e [7] Notas CS442 de Waterloo | corretas | O Módulo 8 diz que a maioria das linguagens OO, mas não todas, usa classes; o Módulo 9 divide a comunicação em memória compartilhada e troca de mensagens. Aceitáveis, mas são notas de aula: se possível, complete com um livro de linguagens de programação. |
| [6] Raynal (2013) | correta | Springer, 2013. DOI 10.1007/978-3-642-32027-9 (o ISBN citado é o da edição impressa). |
| Seções 2.1.1 e 2.1.2 | texto duplicado | Reescrever a 2.1.2 com o que é próprio de OO: encapsulamento, mensagens, herança por metatabelas em Lua (o `Pinguim` herda de `Objeto` no `pico-tcc`). |
| Palavras-chave ("Orientação a Eventos") × título ("Orientação a Objetos") | inconsistente | Alinhar. Sugestão de título na parte 2.2. |
| Resumo: "As implementações (de que?)" | lacuna | Os minigames da Ilha Geladeira (Dojo, Bean Counters, Pega Puffles), o centro e os menus, em Lua e em Atmos. |

---

## 2. Fluxo de leitura, estrutura e tópicos

### 2.1 Fluxo de leitura (em ordem)

| Ordem | Leitura | O que tirar | Onde entra |
|---|---|---|---|
| 1 | Manual e guia do Atmos (manual: *DESIGN*, *Tasks*, *Task Operations*; guia: seções 1 a 6) | Modelo de execução (ambiente, `emit`/`await`, escalonamento determinístico e cooperativo, ordem léxica), hierarquia, `pin`/`tasks`, `par`/`watching`/`toggle`, `pub`, `defer`/`abort` | Cap. 3 |
| 2 | Sant'Anna, *Pingus: C++ → Céu* (SBGames 2018; PDF em `docs/`) | Os cinco padrões de controle em jogos (máquinas de estados, passagem de continuação, hierarquias de despacho, hierarquias de vida, sinalização); variáveis de estado como sintoma; LOC "densas" | Cap. 4 (critérios) e Cap. 6 |
| 3 | Nystrom, *Game Programming Patterns* (*Game Loop*, *Update Method*, *State*, *Observer*) | O modelo da versão Lua: laço, `update`/`draw`, estado explícito, observadores | Cap. 2.1 e Cap. 4.2 |
| 4 | Adya et al. (2002) | Gerenciamento de tarefas × gerenciamento de pilha; *stack ripping* | Cap. 2.3 (a moldura da comparação) |
| 5 | Smith (2018) e Chen & You (2022) | Definição de concorrência estruturada, *nurseries*, histórico, papel das corrotinas | Cap. 2.5 |
| 6 | de Moura & Ierusalimschy (2009) | Corrotinas assimétricas completas: a base das tasks | Cap. 2.4 e Cap. 3 |
| 7 | Sant'Anna, `sc.html`, e Berry (1993) | Concorrência estruturada síncrona; preempção; por que jogos satisfazem a hipótese de sincronismo | Cap. 2.6 |
| 8 | Berry & Gonthier (1992), seções introdutórias | Hipótese de sincronismo, paralelo, preempção | Cap. 2.6 |
| 9 | Céu: TECS 2017 (LCTES 2018, opcional) | A linhagem Esterel → Céu → Atmos; determinismo, ordem léxica, finalização | Cap. 6 |
| 10 | Ierusalimschy et al. (2025) | Lua em jogos; corrotinas na linguagem | Cap. 1 e 2 |
| opcional | Teodorescu (2022); *Rust Async Book*; Erlang/OTP | Raciocínio local; "temporal scope follows lexical scope"; hierarquia sem escopo léxico (contraste) | Cap. 2.5 ou 6 |

Pode descartar: Tanter, Allais, Milano, Tardieu (2007), Tardieu & Edwards,
CRP, os artigos da JVM e o dos bugs em Kotlin. São corretos, mas não ajudam a
responder a pergunta do TCC.

### 2.2 Estrutura proposta (monografia, no formato do PDF)

Título sugerido, mais fiel ao que o projeto compara: *Desenvolvimento de
Jogos: Laço de Atualização com Objetos × Concorrência Estruturada Síncrona*.
Se preferir manter "Orientação a Objetos", explique no capítulo 1 que a
versão Lua é imperativa, com objetos sobre metatabelas e um laço
`update`/`draw`.

1. **Introdução**
   - jogos como sistemas reativos e o laço de jogo;
   - problema: em código com `update`/`draw`, o estado e o fluxo de cada
     comportamento se espalham entre chamadas;
   - pergunta: como as duas abordagens diferem em expressividade, correção e
     custo, com o mesmo comportamento?;
   - objetivos e contribuições: duas implementações do mesmo jogo, um método
     de equivalência por replay, métricas;
   - organização do texto.
2. **Fundamentação teórica**
   - 2.1 Jogos: laço, atualização e desenho, máquinas de estados (Nystrom);
   - 2.2 Programação estruturada e orientada a objetos (o que o texto já tem,
     sem a duplicação; objetos em Lua);
   - 2.3 Programação orientada a eventos e inversão de controle (callbacks;
     Adya: tarefas × pilha, *stack ripping*);
   - 2.4 Concorrência: processos e tarefas, escalonamento cooperativo,
     corrotinas, comunicação (o que já está escrito, mais corrotinas e
     *broadcast* de eventos);
   - 2.5 Concorrência estruturada: hierarquia, ciclo de vida, cancelamento
     (Smith; Chen & You);
   - 2.6 Programação síncrona: hipótese de sincronismo, Esterel, preempção
     (Berry; `sc.html`).
3. **A linguagem Atmos**
   - ambiente e eventos (`atmos.env.pico`: relógio, entrada, `draw`);
   - tasks, hierarquia e escalonamento léxico;
   - `pin`, pools (`tasks`), `pub`;
   - compostos: `par`, `watching`, `loop on`, `toggle`, `every`;
   - finalização e aborto: `defer`, `abort`, erros;
   - integração com Lua.
4. **Metodologia e implementações**
   - 4.1 O jogo Ilha Geladeira e o pico-sdl;
   - 4.2 A versão Lua (telas com `init`/`update`/`draw`/`finish`, estado em
     tabelas);
   - 4.3 A versão Atmos (uma task por entidade; componentes `Image`, `Botao`,
     `XClickable`, `XCollidable`);
   - 4.4 Equivalência por replay (`EQUIVALENCIA.md`);
   - 4.5 Critérios de comparação (padrões do Pingus, variáveis de estado,
     pontos de mudança, LOC, custo por quadro).
5. **Resultados e discussão**
   - por padrão, com pares de trechos Lua × Atmos (ver 3.3);
   - métricas (3.2);
   - divergências que o teste encontrou: o que mostram sobre correção;
   - custo de execução;
   - ameaças à validade (versões escritas em momentos diferentes, por
     autores diferentes).
6. **Trabalhos relacionados**: Pingus/Céu; Esterel e Céu; concorrência
   estruturada em Kotlin, Swift e Trio; o caso do Doom (ver 2.4).
7. **Conclusão**: respostas, limitações, trabalhos futuros (*streams*,
   threads, um estudo maior).

### 2.3 O que se mantém, o que muda, o que falta

- **Mantém-se:** a introdução, em linhas gerais (com as correções da tabela
  1.3); a seção 2.1.1; a seção 2.1.3 (concorrência), que está boa e bem
  referenciada.
- **Muda:** a 2.1.2 (duplicada); as referências [1], [2], [3] e [4]; o título
  ou as palavras-chave; o capítulo de trabalhos relacionados passa para
  depois dos resultados.
- **Falta:** concorrência estruturada; eventos e inversão de controle;
  programação síncrona; o capítulo do Atmos; a metodologia com o `pico-tcc` e
  a equivalência; os resultados. Hoje o texto não menciona o repositório.

### 2.4 O caso do Doom (`lua_doom`)

**Convém usar, como estudo complementar e curto**: uma seção no capítulo 5 ou
6, não um eixo do texto. Pelo `CLAUDE.md` do projeto, ele tem o que falta ao
`pico-tcc`: escala (a lógica inteira de um jogo comercial), migração passo a
passo com tags, e uma equivalência provada por replay determinístico, com hash
de estado, 14 roteiros e testes de mutação, contra a versão imperativa com
*thinkers*. Serve para mostrar que o método da parte 4 escala e para discutir
custo.

Dois cuidados:

- é um port de um port (Python → Lua), com diferenças conhecidas em relação
  ao `linuxdoom` original (há uma auditoria em andamento). O texto deve
  comparar as duas versões Lua do port entre si, não com o Doom original;
- é um projeto à parte, ainda em correção. Para não abrir uma segunda frente,
  fixe uma tag e use só os números dela.

---

## 3. O repositório como base da comparação

### 3.1 Inventário

O repositório tem uma versão do jogo em cada abordagem, com as mesmas telas e
os mesmos recursos (`assets/`). Desenho, colisão e entrada vêm do pico-sdl
(submódulo `src/pico-sdl`; o binding Lua instalado é a v0.7).

| Programa | Versão Lua (`src/codes_tcc/pico_ilha_geladeira`) | Versão Atmos (`src/codes_tcc/atmos_ilha_geladeira`) |
|---|---|---|
| fluxo de telas | `main.lua`: laço `while`, tabela `screens`, `gameState.nextScreen` | `main.atm`: `loop { await Menu() ... }`; os minigames são aguardados dentro do `Centro` |
| menu | `screens/telas_menu/menu.lua` | `screens/telas_menu/menu.atm` + `util/components/botao.atm`, `image_hover.atm`, `xclickable.atm` |
| personalização | `screens/telas_menu/personalizacao.lua` (**não roda**: API antiga de `pico.layer.empty` e campo `cor_select.text.fixo` inexistente) | `screens/telas_menu/personalizar.atm` (`cor.atm` existe e não é usado) |
| centro | `screens/centro/centro.lua`, `pinguim.lua` | `screens/centro/centro.atm`, `pinguim.atm`, `predio.atm` |
| Dojo | `screens/minigames/dojo/dojo.lua`, `carta.lua` | `screens/minigames/dojo/dojo.atm`, `carta.atm` |
| Bean Counters | `screens/minigames/bean_counters/bean_counters.lua`, `pinguim.lua`, `carga.lua`, `pilha.lua` | `.../bean_counters.atm`, `pinguim.atm`, `carga.atm`, `pilha.atm`, `plataforma.atm` |
| Pega Puffles | `screens/minigames/pega_puffles/pega_puffles.lua`, `puffle.lua` | `.../pega_puffles.atm`, `puffle.atm` |
| utilitários | `util/objeto.lua` (base com metatabela), `timer.lua` (relógio real), `vetor.lua` | `util/vetor.atm`, `util/components/image.atm`, `xcollidable.atm` |

Como rodar cada uma:

```bash
cd src/codes_tcc/pico_ilha_geladeira && pico-lua main.lua
```

```bash
cd src/codes_tcc/atmos_ilha_geladeira && atmos main.atm
```

(`pico-lua` faz `cd` para a pasta do arquivo e roda `lua5.4 -lpico main.lua`.)

Outras pastas, fora da comparação: `src/codes_eletiva` (versão anterior em C,
da disciplina eletiva: menu, Dojo, Bean Counters, Pega Puffle);
`src/codes_tcc/comparativos` (a mesma tela de personalização em Lua, em C com
pico e em C com SDL puro); `src/codes_tcc/testes` (experimentos com layers e
`pin`).

Diferenças de execução que afetam a comparação:

- o Lua liga o modo *expert* a 60 quadros/s; o ambiente `atmos.env.pico`, a
  30. Parte da lógica Lua conta quadros (o movimento no Bean Counters, o
  `dt = 0.05` fixo dos puffles), e por isso a velocidade do jogo Lua depende
  da taxa de quadros. A lógica Atmos usa o tempo do relógio;
- o Atmos chama `math.randomseed()` sem semente no início; o Lua semeia com o
  relógio ao entrar no Dojo e no Pega Puffles;
- no Atmos, os minigames rodam *dentro* da task `Centro`: o centro continua
  vivo e é desenhado por baixo do minigame, e Escape aborta o minigame e
  volta ao menu. No Lua as telas são planas, e não há como voltar do centro
  ao menu.

### 3.2 Métricas (medidas por `python3 tools/metricas.py`)

Contagens léxicas, sem linhas em branco nem comentários. "Campos de estado"
(Lua) são os alvos distintos de atribuição do tipo `obj.campo =`; no Atmos,
contam-se as declarações `var` e os alvos distintos de `set`.

| Programa | LOC Lua | LOC Atmos | Atmos/Lua | funções Lua | tasks + funcs Atmos | if/elseif Lua | if/ifs Atmos |
|---|---:|---:|---:|---:|---:|---:|---:|
| main (fluxo de telas) | 39 | 21 | 0,54 | 0 | 0+0 | 2 | 0 |
| menu | 64 | 35 | 0,55 | 4 | 1+0 | 7 | 0 |
| personalização | 80 | 84 | 1,05 | 6 | 1+1 | 3 | 1 |
| centro | 153 | 132 | 0,86 | 10 | 4+2 | 13 | 1 |
| Dojo | 249 | 145 | 0,58 | 13 | 2+3 | 29 | 16 |
| Bean Counters | 401 | 279 | 0,70 | 30 | 5+0 | 39 | 5 |
| Pega Puffles | 257 | 217 | 0,84 | 16 | 2+2 | 16 | 8 |
| utilitários e componentes | 231 | 155 | 0,67 | 46 | 5+19 | 7 | 7 |
| **total** | **1474** | **1068** | **0,72** | | | | |

| Programa | campos de estado Lua | enumerações de estado Lua | `var` Atmos | alvos de `set` Atmos |
|---|---:|---|---:|---:|
| main | 2 | — | 1 | 4 |
| menu | 2 | — | 0 | 0 |
| personalização | 2 | — | 2 | 2 |
| centro | 10 | — | 11 | 10 |
| Dojo | 13 | `DuelState`, `Elemento`, `ResultadoState` | 13 | 8 |
| Bean Counters | 33 | — | 12 | 17 |
| Pega Puffles | 11 | — | 10 | 13 |
| utilitários e componentes | 11 | — | 13 | 5 |

Construções de concorrência no Atmos:

| Programa | spawn | await | watching | par | loop on | toggle | emit | tasks/pin | abort |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| main | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| menu | 2 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| personalização | 4 | 2 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| centro | 10 | 7 | 4 | 1 | 4 | 0 | 0 | 2 | 0 |
| Dojo | 4 | 4 | 2 | 0 | 1 | 0 | 2 | 4 | 0 |
| Bean Counters | 22 | 17 | 5 | 2 | 10 | 2 | 7 | 10 | 2 |
| Pega Puffles | 11 | 4 | 0 | 2 | 10 | 0 | 3 | 2 | 0 |
| utilitários e componentes | 2 | 3 | 2 | 1 | 4 | 0 | 3 | 0 | 0 |

Leitura inicial, com cautela:

- o Atmos tem cerca de 28% menos linhas no total; a maior redução está nos
  programas com mais controle (Dojo, menu, fluxo de telas) e a menor nos de
  mais cálculo (puffles, personalização);
- as condicionais caem muito no Atmos (Bean Counters: 39 → 5; menu: 7 → 0),
  porque o "em que fase estou?" vira posição no código (`await`, `watching`);
- **essas métricas ainda não comparam a mesma coisa**: as versões têm regras
  diferentes (seção 3.4 e `EQUIVALENCIA.md`). Os números finais devem ser
  medidos depois da equivalência.

### 3.3 Forma das máquinas de estados (exemplos para o capítulo 5)

| Comportamento | Lua: estado explícito | Atmos: estado na estrutura do código |
|---|---|---|
| Dojo, rodada do duelo | `DuelState` com 4 estados (`SELECIONANDO`, `COMPARANDO`, `MOSTRANDO_RESULTADO`, `FINALIZADO`), `tempoResultado`, `cartaSelecionada`, `cartaNPCSelecionada`; o `update` despacha por `if jogo.estado == ...` | um `loop in num_cartas { await :clicked; ...; await 2s }`; a fase é o ponto de suspensão |
| Bean Counters, pinguim derrubado | `derrubado`, `cooldown`, `duracao_colldown`; cada função testa `if data.pinguim.derrubado then return end` | `watching :pinguim.atordoado { ... }` seguido de `await 2s`, nos ramos de movimento e de lançamento |
| Bean Counters, intervalo da plataforma | um `Timer` (`ativo`, `inicio`) atualizado a cada quadro | `toggle spawn_plataforma(false); await 250ms; toggle spawn_plataforma(true)` |
| Centro, ir até um prédio | `destino`, `velocidade`, `chegou_destino()` e teste de chegada no `update` | `watching :collided until (...)` sobre o movimento; `watching :mouse.button.dn` recomeça a caminhada |
| Menu, botão com *hover* | três `hover` zerados e recalculados a cada quadro | `Image_Hover`: `watching :on { await Image(off) }` e `watching :off { ... }` alternados |
| Fim do minigame e volta ao centro | `state.nextScreen` + `finish()` + `init()` da próxima tela | `set moedas = moedas + await BeanCounters()`: a continuação é a linha seguinte |

Nos termos de Adya et al., o Lua faz *stack ripping*: o que seria uma variável
local da sequência "esperar o clique, mostrar o resultado por 1,5 s, passar à
próxima rodada" vira campo de tabela, e a sequência vira `if` por estado. Nos
termos do estudo do Pingus, os exemplos acima cobrem os padrões de máquina de
estados (Dojo, pinguim), passagem de continuação (fim do minigame), hierarquia
de vida (cargas no pool, minigame dentro do centro) e sinalização
(`:pinguim.coleta`, `:puffle.entrou`).

### 3.4 Diferenças de regra encontradas

As duas versões não são ports linha a linha: foram escritas em momentos
diferentes (a Lua sobretudo entre março e maio de 2026, com os minigames
completados em julho; a Atmos de junho em diante, com refatorações do
orientador) e divergem em constantes, regras e tempos. O
catálogo completo, com a causa de cada diferença e o que já foi corrigido,
está em [`EQUIVALENCIA.md`](EQUIVALENCIA.md).
