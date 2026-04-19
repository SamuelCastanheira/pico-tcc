#ifndef DOJO_H
#define DOJO_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include <stdio.h>  // necessário para atoi() e sprintf()
#include "../../utils/Aux_Timeout.h"
#include "../../utils/Aux_monitor.h"
#include "../personalizacao/personalizacao.h"
#include "../../texturas/leitura_arquivos.c"
#include "../../texturas/globais.c"

#define NUM_CARTAS_PLAYER 3
#define NUM_CARTAS_POOL 5

typedef enum { GELO, AGUA, FOGO } Elemento;

typedef struct {
    Elemento elemento;
    int pontuacao;
    SDL_Texture* textura;
} Carta;

typedef enum {
    DUEL_SELECIONANDO,
    DUEL_COMPARANDO,
    DUEL_MOSTRANDO_RESULTADO,
    DUEL_FINALIZADO
} DuelState;

typedef enum {
    RESULTADO_EMPATE = 0,
    RESULTADO_GANHOU = 1,
    RESULTADO_PERDEU = -1
} ResultadoState;

#define DURACAO_RESULTADO 1500  // milliseconds

typedef struct {
    DuelState estado;
    Carta cartasJogador[NUM_CARTAS_PLAYER];
    Carta cartasNPC[NUM_CARTAS_PLAYER];
    int cartasRestantesJogador;
    int cartasRestantesNPC;
    int jogadorScore;
    int npcScore;
    ResultadoState resultado;
    int cartaSelecionadaIdx;
    int cartaNPCSelecionadaIdx;
    Uint32 tempoResultado;
} DojoGame;

// Sorteio de cartas sem repetição
static inline void sortearCartas(Carta* cartas_pool, Carta* cartas_destino) {
    bool usados[NUM_CARTAS_POOL] = {false};
    for (int i = 0; i < NUM_CARTAS_PLAYER; i++) {
        int idx;
        do { idx = rand() % NUM_CARTAS_POOL; } while (usados[idx]);
        usados[idx] = true;
        cartas_destino[i] = cartas_pool[idx];
    }
}

// Comparar cartas por elemento e desempate por pontuação
static inline ResultadoState compararCartas(Carta jogador, Carta npc) {
    if (jogador.elemento == npc.elemento) {
        if (jogador.pontuacao > npc.pontuacao) return RESULTADO_GANHOU;
        else if (jogador.pontuacao < npc.pontuacao) return RESULTADO_PERDEU;
        else return RESULTADO_EMPATE;
    }

    // Atributos: gelo > agua > fogo > gelo
    if ((jogador.elemento == GELO && npc.elemento == AGUA) ||
        (jogador.elemento == AGUA && npc.elemento == FOGO) ||
        (jogador.elemento == FOGO && npc.elemento == GELO)) {
        return RESULTADO_GANHOU; // jogador vence
    } else {
        return RESULTADO_PERDEU; // NPC vence
    }
}

// Remove carta do jogador
static inline void removerCarta(Carta* array, int index, int* tamanho) {
    for (int i = index; i < (*tamanho) - 1; i++) {
        array[i] = array[i + 1];
    }
    (*tamanho)--;
}

static inline void ordena_mao(Carta* mao, int tamanho, SDL_Rect* rects, bool isJogador, int LARGURA, int ALTURA) {
    float baseX = isJogador ? 0.85f : 0.05f;
    float dir = isJogador ? -1.0f : 1.0f;
    int card_w = (int)(0.1f * LARGURA);
    int card_h = (int)(0.2f * ALTURA);

    for (int i = 0; i < tamanho; i++) {
        rects[i].x = (int)(baseX * LARGURA + dir * i * 0.12f * LARGURA);
        rects[i].y = (int)(0.80f * ALTURA);
        rects[i].w = card_w;
        rects[i].h = card_h;
    }
}

static inline void desenha_mao(Carta* mao, int tamanho, SDL_Rect* rects, SDL_Renderer* renderizador, SDL_Texture* verso, bool isJogador, Carta* cartaSelecionada) {
    for (int i = 0; i < tamanho; i++) {
        if (&mao[i] != cartaSelecionada) {
            if (isJogador) {
                SDL_RenderCopy(renderizador, mao[i].textura, NULL, &rects[i]);
            } else {
                SDL_RenderCopy(renderizador, verso, NULL, &rects[i]);
            }
        }
    }
}

static inline DojoGame init() {
    srand(time(NULL));

    Carta pool[NUM_CARTAS_POOL] = {
        {AGUA, 3, lista_txt.inicio[TEX_AGUA_3].txt},
        {FOGO, 4, lista_txt.inicio[TEX_FOGO_4].txt},
        {FOGO, 7, lista_txt.inicio[TEX_FOGO_7].txt},
        {GELO, 5, lista_txt.inicio[TEX_GELO_5].txt},
        {GELO, 6, lista_txt.inicio[TEX_GELO_6].txt}
    };

    DojoGame jogo;
    jogo.estado = DUEL_SELECIONANDO;
    sortearCartas(pool, jogo.cartasJogador);
    sortearCartas(pool, jogo.cartasNPC);
    jogo.cartasRestantesJogador = NUM_CARTAS_PLAYER;
    jogo.cartasRestantesNPC = NUM_CARTAS_PLAYER;
    jogo.jogadorScore = 0;
    jogo.npcScore = 0;
    jogo.resultado = RESULTADO_EMPATE;
    jogo.cartaSelecionadaIdx = -1;
    jogo.cartaNPCSelecionadaIdx = -1;
    jogo.tempoResultado = 0;

    return jogo;
}

static inline void update(DojoGame* jogo, Uint32 agora) {
    if (jogo->estado == DUEL_SELECIONANDO) {
        if (jogo->cartaSelecionadaIdx != -1 && jogo->cartaNPCSelecionadaIdx == -1) {
            jogo->cartaNPCSelecionadaIdx = rand() % jogo->cartasRestantesNPC;
        }
        if (jogo->cartaSelecionadaIdx != -1 && jogo->cartaNPCSelecionadaIdx != -1) {
            jogo->estado = DUEL_COMPARANDO;
        }
    } else if (jogo->estado == DUEL_COMPARANDO) {
        Carta cJog = jogo->cartasJogador[jogo->cartaSelecionadaIdx];
        Carta cNPC = jogo->cartasNPC[jogo->cartaNPCSelecionadaIdx];
        jogo->resultado = compararCartas(cJog, cNPC);

        if (jogo->resultado == RESULTADO_GANHOU) {
            jogo->jogadorScore += 3;
        } else if (jogo->resultado == RESULTADO_PERDEU) {
            jogo->npcScore += 3;
        } else {
            jogo->jogadorScore += 1;
            jogo->npcScore += 1;
        }

        jogo->tempoResultado = agora;
        jogo->estado = DUEL_MOSTRANDO_RESULTADO;
    } else if (jogo->estado == DUEL_MOSTRANDO_RESULTADO) {
        if (agora - jogo->tempoResultado >= DURACAO_RESULTADO) {
            removerCarta(jogo->cartasJogador, jogo->cartaSelecionadaIdx, &jogo->cartasRestantesJogador);
            removerCarta(jogo->cartasNPC, jogo->cartaNPCSelecionadaIdx, &jogo->cartasRestantesNPC);

            jogo->cartaSelecionadaIdx = -1;
            jogo->cartaNPCSelecionadaIdx = -1;

            if (jogo->cartasRestantesJogador == 0 || jogo->cartasRestantesNPC == 0) {
                jogo->estado = DUEL_FINALIZADO;
            } else {
                jogo->estado = DUEL_SELECIONANDO;
            }
        }
    }
}

static inline void draw(DojoGame* jogo, SDL_Renderer* renderizador, SDL_Texture* background_textura, SDL_Texture* verso, SDL_Texture* ganhou_textura, SDL_Texture* perdeu_textura, int LARGURA, int ALTURA) {
    SDL_Rect background = {0, 0, LARGURA, ALTURA};
    SDL_RenderClear(renderizador);
    SDL_RenderCopy(renderizador, background_textura, NULL, &background);

    SDL_Rect rectsJogador[NUM_CARTAS_PLAYER];
    SDL_Rect rectsNPC[NUM_CARTAS_PLAYER];
    ordena_mao(jogo->cartasJogador, jogo->cartasRestantesJogador, rectsJogador, true, LARGURA, ALTURA);
    ordena_mao(jogo->cartasNPC, jogo->cartasRestantesNPC, rectsNPC, false, LARGURA, ALTURA);

    Carta* cartaSel = (jogo->cartaSelecionadaIdx != -1) ? &jogo->cartasJogador[jogo->cartaSelecionadaIdx] : NULL;
    desenha_mao(jogo->cartasNPC, jogo->cartasRestantesNPC, rectsNPC, renderizador, verso, false, cartaSel);
    desenha_mao(jogo->cartasJogador, jogo->cartasRestantesJogador, rectsJogador, renderizador, verso, true, cartaSel);

    if (jogo->estado == DUEL_MOSTRANDO_RESULTADO && jogo->cartaSelecionadaIdx != -1 && jogo->cartaNPCSelecionadaIdx != -1) {
        SDL_Rect rect_jogador = {(int)(0.7f * LARGURA), (int)(0.2f * ALTURA), (int)(0.2f * LARGURA), (int)(0.4f * ALTURA)};
        SDL_Rect rect_npc = {(int)(0.1f * LARGURA), (int)(0.2f * ALTURA), (int)(0.2f * LARGURA), (int)(0.4f * ALTURA)};

        SDL_RenderCopy(renderizador, jogo->cartasJogador[jogo->cartaSelecionadaIdx].textura, NULL, &rect_jogador);
        SDL_RenderCopy(renderizador, jogo->cartasNPC[jogo->cartaNPCSelecionadaIdx].textura, NULL, &rect_npc);

        SDL_Rect txt_rect = {0, 0, 150, 150};
        if (jogo->resultado == RESULTADO_GANHOU) {
            SDL_RenderCopy(renderizador, ganhou_textura, NULL, &rect_jogador);
            SDL_RenderCopy(renderizador, perdeu_textura, NULL, &rect_npc);
        } else if (jogo->resultado == RESULTADO_PERDEU) {
            SDL_RenderCopy(renderizador, perdeu_textura, NULL, &rect_jogador);
            SDL_RenderCopy(renderizador, ganhou_textura, NULL, &rect_npc);
        } else {
            SDL_RenderCopy(renderizador, ganhou_textura, NULL, &rect_jogador);
            SDL_RenderCopy(renderizador, ganhou_textura, NULL, &rect_npc);
        }
    }

    SDL_RenderPresent(renderizador);
}

static inline int RenderDojoScreen(
    SDL_Window *janela,
    SDL_Renderer *renderizador,
    SDL_Event *evento,
    Uint32 *timeout,
    GameState *estadoJogo,
    char dinheiro[10]  // agora é string
) {
    obterTamanhoJanela(janela, &LARGURA, &ALTURA);
    IMG_Init(IMG_INIT_PNG);

    SDL_Texture* background_textura = lista_txt.inicio[TEX_FUNDO_DOJO].txt;
    SDL_Texture* carta_azul_textura = lista_txt.inicio[TEX_CARTA_AZUL].txt;
    SDL_Texture* ganhou_textura = lista_txt.inicio[TEX_GANHOU].txt;
    SDL_Texture* perdeu_textura = lista_txt.inicio[TEX_PERDEU].txt;

    DojoGame jogo = init();

    while (true) {
        Uint32 agora = SDL_GetTicks();

        if (AUX_WaitEventTimeout(evento, timeout)) {
            if (evento->type == SDL_MOUSEBUTTONDOWN && jogo.estado == DUEL_SELECIONANDO) {
                int mx = evento->button.x;
                int my = evento->button.y;

                SDL_Rect rectsJogador[NUM_CARTAS_PLAYER];
                ordena_mao(jogo.cartasJogador, jogo.cartasRestantesJogador, rectsJogador, true, LARGURA, ALTURA);

                for (int i = 0; i < jogo.cartasRestantesJogador; i++) {
                    if (mx >= rectsJogador[i].x && mx <= rectsJogador[i].x + rectsJogador[i].w &&
                        my >= rectsJogador[i].y && my <= rectsJogador[i].y + rectsJogador[i].h) {
                        jogo.cartaSelecionadaIdx = i;
                        break;
                    }
                }
            }

            if (evento->type == SDL_KEYDOWN && evento->key.keysym.sym == SDLK_ESCAPE) {
                *estadoJogo = STATE_JOGANDO;
                IMG_Quit();
                return 1;
            }
            if (evento->type == SDL_QUIT) {
                *estadoJogo = STATE_SAIR;
                IMG_Quit();
                return 0;
            }
        }

        update(&jogo, agora);

        if (jogo.estado == DUEL_FINALIZADO) {
            // Premiação apenas no resultado final
            int dinheiro_int = atoi(dinheiro); // converte string para int
            if (jogo.jogadorScore > jogo.npcScore) dinheiro_int += 100;
            else if (jogo.jogadorScore == jogo.npcScore) dinheiro_int += 50;
            sprintf(dinheiro, "%d", dinheiro_int); // atualiza string

            *estadoJogo = STATE_JOGANDO;
            IMG_Quit();
            return 1;
        }

        draw(&jogo, renderizador, background_textura, carta_azul_textura, ganhou_textura, perdeu_textura, LARGURA, ALTURA);
    }

    IMG_Quit();
    return 1;
}

#endif
