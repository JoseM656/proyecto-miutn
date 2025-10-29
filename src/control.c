#include <stdio.h>
#include "control.h"

void ejecutar_si(int condicion) {
    if (condicion) {
        // En el futuro: podríamos ejecutar un bloque de instrucciones
        // Por ahora, solo mostramos que se evaluó el "si"
        printf("[control] Ejecutando bloque SI (condición verdadera)\n");
    } else {
        printf("[control] Saltando bloque SI (condición falsa)\n");
    }
}

void ejecutar_repetir(int veces, void (*bloque)()) {
    printf("[control] Iniciando bucle REPETIR (%d veces)\n", veces);
    for (int i = 0; i < veces; i++) {
        if (bloque) bloque(); // Ejecuta el bloque pasado como función
    }
    printf("[control] Fin del bucle REPETIR\n");
}
