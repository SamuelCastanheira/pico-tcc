#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <string.h>
#include <assert.h>

// Dimensões da tela
int LARGURA = 800;
int ALTURA = 600;
int CORES = 15;

int main(int args, char* argc[]) {

    SDL_Init(SDL_INIT_EVERYTHING);
  
    SDL_Window *win = SDL_CreateWindow(
        "Persanalização",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        LARGURA, ALTURA, 
        SDL_WINDOW_FULLSCREEN_DESKTOP 
    );

    SDL_DisplayMode displayMode;
    SDL_GetDesktopDisplayMode(0, &displayMode);
    LARGURA = displayMode.w;
    ALTURA = displayMode.h;

    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, 0);

    TTF_Init();
    TTF_Font* fnt = TTF_OpenFont("imgs/tiny.ttf", 50);
    assert(fnt != NULL);
    SDL_Color clr = {0xFF,0xFF,0xFF,0xFF};
    SDL_Surface* sfc = TTF_RenderText_Blended(fnt, "Escolha sua cor: ", clr);
    assert(sfc != NULL);
    SDL_Texture* txt_escolha = SDL_CreateTextureFromSurface(ren, sfc);
    assert(txt_escolha != NULL);
    SDL_FreeSurface(sfc);

    SDL_Texture* txt_background = IMG_LoadTexture(ren, "imgs/background_personalizar.png");
    SDL_Texture* txt_quadro = IMG_LoadTexture(ren, "imgs/personalizar/quadro.png");
    SDL_Texture* txt_bt_voltar = IMG_LoadTexture(ren, "imgs/botoes/b_voltar.png");
    SDL_Texture* txt_pinguim = IMG_LoadTexture(ren, "imgs/personalizar/pinguim_amarelo.png");
    
    SDL_Rect rect_background = {0, 0, LARGURA, ALTURA};
    SDL_Rect rect_quadro = {LARGURA*0.55, ALTURA*0.20, LARGURA*0.45, ALTURA*0.56};
    SDL_Rect rect_pinguim= { LARGURA*0.146, ALTURA*0.13, ALTURA*0.52, ALTURA*0.52};
    SDL_Rect rect_bt_voltar= {LARGURA*0.142, ALTURA*0.75, LARGURA*0.292, ALTURA*0.156};
    SDL_Rect rect_escolha = {LARGURA*0.60, ALTURA*0.19, LARGURA*0.38, ALTURA*0.1};
   
    SDL_Rect rect_cores[CORES];
    SDL_Texture * txt_cores[CORES];

    int startX = LARGURA*0.60;
    int startY = ALTURA*0.30;
    int espaco = 10;
    int largura = 0.065*LARGURA;
    int altura  = 0.117*ALTURA;

    char path[100];
    char base[] = "imgs/personalizar"; 

    for (int i = 0; i < CORES; i++) {
        rect_cores[i].x = startX + (i % 5) * (largura + espaco);
        rect_cores[i].y = startY + (i / 5) * (altura + espaco);
        rect_cores[i].w = largura;
        rect_cores[i].h = altura;
        snprintf(path, sizeof(path), "%s/%d.png", base, i);
        SDL_Log(path);
        txt_cores[i] = IMG_LoadTexture(ren, path);
        assert(txt_cores[i] != NULL);
    }

    SDL_RenderClear(ren);
    SDL_RenderCopy(ren, txt_background, NULL, &rect_background);
    SDL_RenderCopy(ren, txt_quadro, NULL, &rect_quadro);
    SDL_RenderCopy(ren, txt_pinguim, NULL, &rect_pinguim);
    SDL_RenderCopy(ren, txt_bt_voltar, NULL, &rect_bt_voltar);
    SDL_RenderCopy(ren, txt_escolha, NULL, &rect_escolha);

    for (int i = 0; i < CORES; i++) {
        SDL_RenderCopy(ren, txt_cores[i], NULL , &rect_cores[i]);
    }

    SDL_RenderPresent(ren);
    SDL_Delay(20000);

    TTF_CloseFont(fnt);
    SDL_DestroyTexture(txt_background);
    SDL_DestroyTexture(txt_quadro);
    SDL_DestroyTexture(txt_bt_voltar);
    SDL_DestroyTexture(txt_pinguim);
    SDL_DestroyTexture(txt_escolha);


    for (int i = 0; i < CORES; i++) {

        SDL_DestroyTexture(txt_cores[i]);
    }

    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    TTF_Quit();
    SDL_Quit();

    return 0;
}
