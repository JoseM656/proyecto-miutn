%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "control.h"   /* <- incluirás este archivo cuando crees control.c */

/* -------------------------------------------
   Declaraciones globales y estructuras base
   ------------------------------------------- */
extern int yylex();
extern int yylineno;
extern char *yytext;

void yyerror(const char *s);

/* Tipos de datos soportados por el lenguaje */
typedef enum { TIPO_INT, TIPO_FLOAT, TIPO_STRING } TipoDato;

/* Estructura para cada variable */
typedef struct {
    char nombre[50];
    TipoDato tipo;
    union {
        int ival;
        float fval;
        char sval[100];
    } valor;
} Variable;

/* Tabla de variables (memoria simulada) */
Variable tabla[100];
int num_vars = 0;

/* Declaraciones de funciones auxiliares */
void asignar_variable(const char *nombre, TipoDato tipo, void *valor);
Variable *obtener_variable(const char *nombre);
%}

/* -------------------------------------------
   Definición de tokens y tipos
   ------------------------------------------- */
%union {
    int  ival;
    float fval;
    char *sval;
}

/* Palabras clave */
%token UTN FINUTN LEER ESCRIBIR REPETIR VECES FINREPETIR SI ENTONCES FINSI
%token INT STRING FLOAT

/* Símbolos y operadores */
%token ASIGN MAYOR MENOR IGUAL SUMA RESTA MULT PARI PARD COMA PUNTO

/* Tipos con valores asociados */
%token <ival> NUM_INT
%token <fval> NUM_FLOAT
%token <sval> CADENA_TXT ID

/* Precedencia */
%left SUMA RESTA
%left MULT
%left IGUAL MAYOR MENOR

/* Tipado de las expresiones */
%type <fval> expresion

%%

/* -------------------------------------------
   REGLAS GRAMATICALES PRINCIPALES
   ------------------------------------------- */

programa:
    UTN lista_sentencias FINUTN
;

lista_sentencias:
      lista_sentencias sentencia
    | sentencia
;

sentencia:
      /* Escritura de valores o cadenas */
      ESCRIBIR PARI expresion PARD PUNTO   { printf("%g\n", $3); }
    | ESCRIBIR PARI CADENA_TXT PARD PUNTO  { printf("%s\n", $3); free($3); }
    | ESCRIBIR PARI ID PARD PUNTO          {
                                              Variable *v = obtener_variable($3);
                                              if (!v)
                                                  printf("Advertencia: variable '%s' no definida\n", $3);
                                              else if (v->tipo == TIPO_INT)
                                                  printf("%d\n", v->valor.ival);
                                              else if (v->tipo == TIPO_FLOAT)
                                                  printf("%g\n", v->valor.fval);
                                              else
                                                  printf("%s\n", v->valor.sval);
                                              free($3);
                                           }

      /* Lectura (acepta enteros o flotantes) */
    | LEER PARI ID PARD PUNTO              {
                                              char buffer[64];
                                              printf("Ingrese valor para %s: ", $3);
                                              scanf("%63s", buffer);

                                              if (strchr(buffer, '.')) {
                                                  float f = atof(buffer);
                                                  asignar_variable($3, TIPO_FLOAT, &f);
                                              } else {
                                                  int i = atoi(buffer);
                                                  asignar_variable($3, TIPO_INT, &i);
                                              }
                                              free($3);
                                           }

      /* Declaraciones con asignación */
    | INT ID ASIGN expresion PUNTO         { int v = (int)$4; asignar_variable($2, TIPO_INT, &v); free($2); }
    | FLOAT ID ASIGN expresion PUNTO       { float f = $4; asignar_variable($2, TIPO_FLOAT, &f); free($2); }
    | STRING ID ASIGN CADENA_TXT PUNTO     { asignar_variable($2, TIPO_STRING, $4); free($2); free($4); }

      /* Asignación a variable existente */
    | ID ASIGN expresion PUNTO             { float f = $3; asignar_variable($1, TIPO_FLOAT, &f); free($1); }

      /* Estructura condicional (preparada para control.c) */
    | SI expresion ENTONCES lista_sentencias FINSI PUNTO {
          ejecutar_si((int)$2);
      }

      /* Estructura de repetición (preparada para control.c) */
    | REPETIR NUM_INT VECES lista_sentencias FINREPETIR PUNTO {
          ejecutar_repetir($2, NULL);
      }
;

/* -------------------------------------------
   EXPRESIONES ARITMÉTICAS Y VARIABLES
   ------------------------------------------- */

expresion:
      expresion SUMA expresion   { $$ = $1 + $3; }
    | expresion RESTA expresion  { $$ = $1 - $3; }
    | expresion MULT expresion   { $$ = $1 * $3; }
    | expresion MENOR expresion  { $$ = ($1 < $3); }
    | expresion MAYOR expresion  { $$ = ($1 > $3); }
    | expresion IGUAL expresion  { $$ = ($1 == $3); }
    | PARI expresion PARD        { $$ = $2; }
    | NUM_INT                    { $$ = (float)$1; }
    | NUM_FLOAT                  { $$ = $1; }
    | ID {
            Variable *v = obtener_variable($1);
            if (!v) {
                printf("Advertencia: variable '%s' no definida (usando 0)\n", $1);
                $$ = 0.0;
            } else if (v->tipo == TIPO_INT)
                $$ = (float)v->valor.ival;
            else if (v->tipo == TIPO_FLOAT)
                $$ = v->valor.fval;
            else
                $$ = 0.0;
            free($1);
         }
;

%%

/* -------------------------------------------
   FUNCIONES AUXILIARES EN C
   ------------------------------------------- */

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d: %s (token: '%s')\n", yylineno, s, yytext);
}

void asignar_variable(const char *nombre, TipoDato tipo, void *valor) {
    /* Si ya existe, se actualiza */
    for (int i = 0; i < num_vars; i++) {
        if (strcmp(tabla[i].nombre, nombre) == 0) {
            tabla[i].tipo = tipo;
            if (tipo == TIPO_INT)
                tabla[i].valor.ival = *(int *)valor;
            else if (tipo == TIPO_FLOAT)
                tabla[i].valor.fval = *(float *)valor;
            else
                strcpy(tabla[i].valor.sval, (char *)valor);
            return;
        }
    }

    /* Si no existe, se crea */
    strcpy(tabla[num_vars].nombre, nombre);
    tabla[num_vars].tipo = tipo;
    if (tipo == TIPO_INT)
        tabla[num_vars].valor.ival = *(int *)valor;
    else if (tipo == TIPO_FLOAT)
        tabla[num_vars].valor.fval = *(float *)valor;
    else
        strcpy(tabla[num_vars].valor.sval, (char *)valor);
    num_vars++;
}

Variable *obtener_variable(const char *nombre) {
    for (int i = 0; i < num_vars; i++) {
        if (strcmp(tabla[i].nombre, nombre) == 0)
            return &tabla[i];
    }
    return NULL;
}
