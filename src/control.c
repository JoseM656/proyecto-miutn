#include <stdio.h>
#include <string.h>
#include "control.h"

/* ==================== VARIABLES GLOBALES ==================== */

/* Condicionales */
int ejecutando_bloque = 1;
static int nivel_anidamiento = 0;

/* Bucles */
Comando buffer_comandos[MAX_COMANDOS];
int num_comandos = 0;
int en_bucle = 0;
static int iteraciones_objetivo = 0;

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
    ejecutando_bloque = 1;
    printf("[DEBUG] Fin del bloque SI\n");
}

int debe_ejecutar() {
    /* Si estamos en un bucle, NO ejecutar (solo guardar) */
    if (en_bucle) {
        return 0;
    }
    return ejecutando_bloque;
}

/* ==================== BUCLES ==================== */

void iniciar_repetir(int veces) {
  
    en_bucle = 1;
    num_comandos = 0;
    iteraciones_objetivo = veces;
}

void finalizar_repetir() {
   
    
    /* Ejecutar todos los comandos guardados N veces */
    for (int iter = 0; iter < iteraciones_objetivo; iter++) {
        
        ejecutar_comandos_guardados();
    }
    
    /* Limpiar estado */
    en_bucle = 0;
    num_comandos = 0;
    iteraciones_objetivo = 0;
   
}

void guardar_comando(Comando cmd) {
    if (num_comandos >= MAX_COMANDOS) {
        printf("[ERROR] Buffer de comandos lleno\n");
        return;
    }
    buffer_comandos[num_comandos++] = cmd;
    
}

/* Declaración adelantada de funciones del parser */
extern void asignar_variable(const char *nombre, int tipo, void *valor);
extern void* obtener_variable(const char *nombre);

void ejecutar_comandos_guardados() {
    for (int i = 0; i < num_comandos; i++) {
        Comando *cmd = &buffer_comandos[i];
        
        switch (cmd->tipo) {
            case CMD_ESCRIBIR_NUMERO:
                printf("%g\n", cmd->datos.escribir_num.valor);
                break;
                
            case CMD_ESCRIBIR_STRING:
                printf("%s\n", cmd->datos.escribir_str.texto);
                break;
                
            case CMD_ESCRIBIR_VARIABLE: {
                /* Necesitamos obtener el valor actual de la variable */
                void *v = obtener_variable(cmd->datos.escribir_var.nombre);
                if (v) {
                    /* Aquí imprimimos la variable - esto se conecta con el parser */
                    printf("[Variable: %s]\n", cmd->datos.escribir_var.nombre);
                }
                break;
            }
                
            case CMD_ASIGNAR_INT:
                asignar_variable(cmd->datos.asignar_int.nombre, 0, 
                               &cmd->datos.asignar_int.valor);
                break;
                
            case CMD_ASIGNAR_FLOAT:
                asignar_variable(cmd->datos.asignar_float.nombre, 1, 
                               &cmd->datos.asignar_float.valor);
                break;
                
            case CMD_ASIGNAR_STRING:
                asignar_variable(cmd->datos.asignar_string.nombre, 2, 
                               cmd->datos.asignar_string.valor);
                break;
                
            case CMD_ASIGNAR_EXPR:
                asignar_variable(cmd->datos.asignar_expr.nombre, 1, 
                               &cmd->datos.asignar_expr.valor);
                break;
        }
    }
}