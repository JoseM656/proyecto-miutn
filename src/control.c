#include <stdio.h>
#include "control.h"

/* Variables de estado para condicionales */
int ejecutando_bloque = 1;  /* 1 = ejecutar, 0 = saltar */
static int nivel_anidamiento = 0;

/* Variables de estado para bucles */
static int en_bucle = 0;
static int iteraciones_restantes = 0;
static int iteracion_actual = 0;

/* ==================== CONDICIONALES ==================== */

void iniciar_si(int condicion) {
    nivel_anidamiento++;
    
    if (condicion) {
        ejecutando_bloque = 1;
       
    } else {
        ejecutando_bloque = 0;
        
    }
}

void finalizar_si() {
    nivel_anidamiento--;
    ejecutando_bloque = 1;  /* Restaurar ejecución normal */
   
}

/* ==================== BUCLES ==================== */

void iniciar_repetir(int veces) {
    if (veces <= 0) {
        
        en_bucle = 0;
        return;
    }
    
    en_bucle = 1;
    iteraciones_restantes = veces;
    iteracion_actual = 0;
    
}

void finalizar_repetir() {
    
    en_bucle = 0;
    iteraciones_restantes = 0;
    iteracion_actual = 0;
}

int debe_ejecutar() {
    return ejecutando_bloque;
}