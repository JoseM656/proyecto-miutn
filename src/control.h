#ifndef CONTROL_H
#define CONTROL_H

/* ==================== CONDICIONALES ==================== */
extern int ejecutando_bloque;

void iniciar_si(int condicion);
void finalizar_si();
int debe_ejecutar();

/* ==================== BUCLES ==================== */

/* Tipos de comandos que podemos guardar */
typedef enum {
    CMD_ESCRIBIR_NUMERO,
    CMD_ESCRIBIR_STRING,
    CMD_ESCRIBIR_VARIABLE,
    CMD_ASIGNAR_INT,
    CMD_ASIGNAR_FLOAT,
    CMD_ASIGNAR_STRING,
    CMD_ASIGNAR_EXPR
} TipoComando;

/* Estructura para guardar un comando */
typedef struct {
    TipoComando tipo;
    union {
        struct { float valor; } escribir_num;
        struct { char texto[200]; } escribir_str;
        struct { char nombre[50]; } escribir_var;
        struct { char nombre[50]; int valor; } asignar_int;
        struct { char nombre[50]; float valor; } asignar_float;
        struct { char nombre[50]; char valor[100]; } asignar_string;
        struct { char nombre[50]; float valor; } asignar_expr;
    } datos;
} Comando;

/* Buffer de comandos para el bucle */
#define MAX_COMANDOS 100
extern Comando buffer_comandos[MAX_COMANDOS];
extern int num_comandos;
extern int en_bucle;

/* Funciones de bucles */
void iniciar_repetir(int veces);
void finalizar_repetir();
void guardar_comando(Comando cmd);
void ejecutar_comandos_guardados();

#endif