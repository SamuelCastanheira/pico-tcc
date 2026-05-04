#ifndef BEAN_CARGA
#define BEAN_CARGA

#include <stdbool.h>
#include <SDL2/SDL.h>
#include "globais.c"
#include "enums.c"
#include "../../texturas/leitura_arquivos.c"
#include "../../texturas/globais.c"

// -----------------------------
//        STRUCT CARGA
// -----------------------------
typedef struct Carga {
    SDL_Rect rect;
    SDL_Texture *txt;
    int tipo;

    double pos_x;
    double pos_y;

    double velocidade_x;
    double velocidade_y;

    Uint32 tempo_anterior_carga;
    bool ativo;
    int tempo;
    SDL_Rect teste;
    int destino;
    int pos_inicial;    
    Uint32 tempo_queda;
    bool fade;
    double alpha;

    struct Carga *prox; // ← LISTA ENCADEADA

} Carga;



typedef struct {
    Carga *inicio; // cabeça da lista
    int prob;
} ListaCarga;


void inicializa_lista_carga(ListaCarga *lista)
{
    lista->inicio = NULL;
    lista->prob = 0;
}


Carga* cria_carga(SDL_Renderer *renderizador)
{
    Carga *c = malloc(sizeof(Carga));

    c->rect = (SDL_Rect){ LARGURA * 0.85, ALTURA * 0.52, LARGURA * 0.07, LARGURA * 0.07 };
    c->alpha = 255;
    c->pos_x = c->rect.x;
    c->pos_y = c->rect.y;
    c->tempo_anterior_carga = 0;
    c->fade = false;

    double space_x = limite_esq + rand() % (limite_dir - limite_esq + 1);
    c->pos_inicial = c->pos_y;
    c->destino = (int)ALTURA * 0.72;
    double space_y = ALTURA * 0.13;

    double dx = space_x - LARGURA * 0.85;
    double dy = space_y - c->pos_y;

    c->velocidade_x = -300;
    c->tempo = fabs(dx) / fabs(c->velocidade_x);
    c->velocidade_y = (dy - 0.5 * gravidade * c->tempo * c->tempo) / c->tempo;

    c->tipo = rand() % 4;

    switch (c->tipo)
    {
        case GRAOS:
            c->txt = IMG_LoadTexture(renderizador, lista_txt.inicio[TEX_BEAN_SACO].caminho);
            break;
        case PEIXE:
            c->txt = IMG_LoadTexture(renderizador, lista_txt.inicio[TEX_BEAN_PEIXE].caminho);
            break;
        case BIGORNA:
            c->txt = IMG_LoadTexture(renderizador, lista_txt.inicio[TEX_BEAN_BIGORNA].caminho);
            break;
        case VASO:
            c->txt = IMG_LoadTexture(renderizador, lista_txt.inicio[TEX_BEAN_VASO].caminho);
            break;
    }

    c->teste = (SDL_Rect){ space_x, 200, 10, 10 };
    c->ativo = true;

    c->prox = NULL;

    return c;
}



void adiciona_carga(ListaCarga *lista, Carga *nova)
{
    nova->prox = lista->inicio;
    lista->inicio = nova;
}

void sorteia_carga(SDL_Renderer *renderizador, ListaCarga *lista)
{
    lista->prob = rand() % 1000;

    if (lista->prob == 1)
    {
        Carga *c = cria_carga(renderizador);
        adiciona_carga(lista, c);
    }
}

void calcula_movimento_carga(Carga *c)
{
    Uint32 agora = SDL_GetTicks();

    if (c->tempo_anterior_carga == 0)
        c->tempo_anterior_carga = agora;

    double dt = (agora - c->tempo_anterior_carga) / 1000.0;
    c->tempo_anterior_carga = agora;

    c->velocidade_y += gravidade * dt;
    c->pos_x += c->velocidade_x * dt;
    c->pos_y += c->velocidade_y * dt;

    c->rect.x = (int)c->pos_x;
    c->rect.y = (int)c->pos_y;
}

void calcula_movimento_cargas(ListaCarga *lista)
{
    for (Carga *c = lista->inicio; c != NULL; c = c->prox)
    {
        if (!c->fade)
            calcula_movimento_carga(c);
    }
}

void remove_carga(ListaCarga *lista, Carga *carga)
{
    if (!lista->inicio || !carga)
        return;

    Carga *atual = lista->inicio;
    Carga *anterior = NULL;

    while (atual != NULL)
    {
        if (atual == carga)
        {
            // Ajusta encadeamento
            if (anterior == NULL)
            {
                lista->inicio = atual->prox;
            }
            else
            {
                anterior->prox = atual->prox;
            }

            // Libera recursos
            free(atual);
            return; // acabou
        }

        anterior = atual;
        atual = atual->prox;
    }
}


void draw_cargas(SDL_Renderer *renderizador, ListaCarga *lista)
{
    Carga *c = lista->inicio;

    while (c != NULL)
    {
        Carga *prox = c->prox; // ← guarda o próximo antes de possível remoção

        if (c->ativo)
        {
            if (c->fade)
            {
                c->alpha -= 255 * (SDL_GetTicks() - c->tempo_queda) / 2000;

                if (c->alpha <= 0)
                {
                    remove_carga(lista, c);
                    c = prox;
                    continue;   // ← evita usar carga apagada
                }

                SDL_SetTextureAlphaMod(c->txt, c->alpha);
            }

            if (c->tipo == GRAOS)
            {
                double porc = fabs(c->rect.y - c->pos_inicial) /
                              (c->destino - c->pos_inicial);

                double angulo =
                    (porc <= 0.25) ? 0 :
                    (porc <= 0.50) ? 45 :
                    (porc <= 0.75) ? 90 : 180;

                SDL_RenderCopyEx(renderizador, c->txt, NULL, &c->rect,
                                 angulo, NULL, SDL_FLIP_NONE);
            }
            else
            {
                SDL_RenderCopy(renderizador, c->txt, NULL, &c->rect);
            }
        }

        c = prox; // anda para o próximo
    }
}


void remove_cargas_mortas(ListaCarga *lista)
{
    Carga *atual = lista->inicio;
    Carga *anterior = NULL;

    while (atual != NULL)
    {
        if (!atual->ativo)
        {
            if (anterior == NULL)
                lista->inicio = atual->prox;
            else
                anterior->prox = atual->prox;

            SDL_DestroyTexture(atual->txt);
            free(atual);

            if (anterior == NULL)
                atual = lista->inicio;
            else
                atual = anterior->prox;
        }
        else
        {
            anterior = atual;
            atual = atual->prox;
        }
    }
}


void libera_lista_carga(ListaCarga *lista)
{
    Carga *c = lista->inicio;

    while (c)
    {
        Carga *prox = c->prox;
        SDL_DestroyTexture(c->txt);
        free(c);
        c = prox;
    }
}
#endif