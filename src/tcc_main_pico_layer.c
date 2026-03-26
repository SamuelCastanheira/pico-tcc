#include "pico.h"
#include "../check.h"

int CORES = 15;

int main(int args, char* argc[]) {

    pico_init(1);

    pico_set_window(NULL, 1, NULL);
    Pico_Abs_Dim window;
    pico_get_window(NULL, NULL, &window);
    Pico_Rel_Dim dim = { '!', {window.w, window.h}, NULL };
    pico_set_view(-1, &dim, NULL, NULL, NULL, NULL, NULL, NULL);
    
    Pico_Rel_Rect background = { '%', {0.5, 0.5, 1,1}, PICO_ANCHOR_C, NULL };
    Pico_Rel_Rect pinguim = { '%', {0.3, 0.35, 0.3, 0}, PICO_ANCHOR_C, NULL };
    Pico_Rel_Rect voltar = { '%', {0.3, 0.8, 0.3, 0}, PICO_ANCHOR_C, NULL };

    pico_set_expert(1,20);
    pico_output_clear();
    pico_output_draw_image("imgs/background_personalizar.png", &background);
    pico_output_draw_image("imgs/personalizar/pinguim_amarelo.png", &pinguim);
    pico_output_draw_image("imgs/botoes/b_voltar.png", &voltar);
    pico_output_draw_text("Escolha sua cor: ", &(Pico_Rel_Rect){'%', {0.60, 0.20, 0.38, 0.1}, PICO_ANCHOR_NW, NULL});
   

    pico_layer_empty("quadro", (Pico_Abs_Dim){1360, 768});
    pico_set_layer("quadro");

    pico_set_view(-1, &(Pico_Rel_Dim){'#', {7,5}}, &(Pico_Abs_Dim){1360/7,768/5},
    NULL,NULL,NULL,NULL,NULL);

    pico_output_draw_image("imgs/personalizar/quadro.png",
                            &(Pico_Rel_Rect){'#', {1,1,7,5}, PICO_ANCHOR_NW, NULL});

    char path[100];
    char base[] = "imgs/personalizar"; 

    for (int i = 0; i < CORES; i++) {
        snprintf(path, sizeof(path), "%s/%d.png", base, i);
        pico_output_draw_image(path,
                            &(Pico_Rel_Rect){'#', {i%5 + 2, 2 + i/5,1,1}, PICO_ANCHOR_C, NULL});
    }
    
    pico_set_layer(NULL);
    pico_output_draw_layer("quadro", &(Pico_Rel_Rect){ '%', {0.75, 0.5, 0.5, 0}, PICO_ANCHOR_C, NULL });
    pico_output_present();
    pico_input_delay(5000);
    pico_init(0);

    return 0;
}