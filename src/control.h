#ifndef CONTROL_H
#define CONTROL_H

/* Estado de ejecución condicional */
extern int ejecutando_bloque;

/* Funciones para condicionales */
void iniciar_si(int condicion);
void finalizar_si();

/* Funciones para bucles */
void iniciar_repetir(int veces);
void finalizar_repetir();
int debe_ejecutar();

#endif