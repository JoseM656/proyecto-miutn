%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "control.h"

extern int yylex();
extern int yylineno;
extern char *yytext;

void yyerror(const char *s);

typedef enum { TIPO_INT, TIPO_FLOAT, TIPO_STRING } TipoDato;

typedef struct {
    char nombre[50];
    TipoDato tipo;
    union {
        int ival;
        float fval;
        char sval[100];
    } valor;
} Variable;

Variable tabla[100];
int num_vars = 0;

void asignar_variable(const char *nombre, TipoDato tipo, void *valor);
Variable *obtener_variable(const char *nombre);
%}

%union {
    int  ival;
    float fval;
    char *sval;
}

%token UTN FINUTN LEER ESCRIBIR REPETIR VECES FINREPETIR SI ENTONCES FINSI
%token INT STRING FLOAT
%token ASIGN MAYOR MENOR IGUAL SUMA RESTA MULT PARI PARD COMA PUNTO

%token <ival> NUM_INT
%token <fval> NUM_FLOAT
%token <sval> CADENA_TXT ID

%left SUMA RESTA
%left MULT
%left IGUAL MAYOR MENOR

%type <fval> expresion
%type <ival> condicion

%%

programa:
    UTN lista_sentencias FINUTN
;

lista_sentencias:
      lista_sentencias sentencia
    | sentencia
;

sentencia:
      /* ESCRIBIR NÚMERO */
      ESCRIBIR PARI expresion PARD PUNTO {
          if (en_bucle) {
              /* Guardar comando para ejecutar después */
              Comando cmd;
              cmd.tipo = CMD_ESCRIBIR_NUMERO;
              cmd.datos.escribir_num.valor = $3;
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              printf("%g\n", $3);
          }
      }
      
      /* ESCRIBIR STRING */
    | ESCRIBIR PARI CADENA_TXT PARD PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ESCRIBIR_STRING;
              strncpy(cmd.datos.escribir_str.texto, $3, 199);
              cmd.datos.escribir_str.texto[199] = '\0';
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              printf("%s\n", $3);
          }
          free($3);
      }
      
      /* ESCRIBIR VARIABLE */
    | ESCRIBIR PARI ID PARD PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ESCRIBIR_VARIABLE;
              strncpy(cmd.datos.escribir_var.nombre, $3, 49);
              cmd.datos.escribir_var.nombre[49] = '\0';
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              Variable *v = obtener_variable($3);
              if (!v)
                  printf("Advertencia: variable '%s' no definida\n", $3);
              else if (v->tipo == TIPO_INT)
                  printf("%d\n", v->valor.ival);
              else if (v->tipo == TIPO_FLOAT)
                  printf("%g\n", v->valor.fval);
              else
                  printf("%s\n", v->valor.sval);
          }
          free($3);
      }
      
      /* LEER */
    | LEER PARI ID PARD PUNTO {
          if (debe_ejecutar() && !en_bucle) {
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
          }
          free($3);
      }
      
      /* DECLARACIÓN INT */
    | INT ID ASIGN expresion PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ASIGNAR_INT;
              strncpy(cmd.datos.asignar_int.nombre, $2, 49);
              cmd.datos.asignar_int.nombre[49] = '\0';
              cmd.datos.asignar_int.valor = (int)$4;
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              int v = (int)$4;
              asignar_variable($2, TIPO_INT, &v);
          }
          free($2);
      }
      
      /* DECLARACIÓN FLOAT */
    | FLOAT ID ASIGN expresion PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ASIGNAR_FLOAT;
              strncpy(cmd.datos.asignar_float.nombre, $2, 49);
              cmd.datos.asignar_float.nombre[49] = '\0';
              cmd.datos.asignar_float.valor = $4;
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              float f = $4;
              asignar_variable($2, TIPO_FLOAT, &f);
          }
          free($2);
      }
      
      /* DECLARACIÓN STRING */
    | STRING ID ASIGN CADENA_TXT PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ASIGNAR_STRING;
              strncpy(cmd.datos.asignar_string.nombre, $2, 49);
              cmd.datos.asignar_string.nombre[49] = '\0';
              strncpy(cmd.datos.asignar_string.valor, $4, 99);
              cmd.datos.asignar_string.valor[99] = '\0';
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              asignar_variable($2, TIPO_STRING, $4);
          }
          free($2);
          free($4);
      }
      
      /* ASIGNACIÓN A VARIABLE EXISTENTE */
    | ID ASIGN expresion PUNTO {
          if (en_bucle) {
              Comando cmd;
              cmd.tipo = CMD_ASIGNAR_EXPR;
              strncpy(cmd.datos.asignar_expr.nombre, $1, 49);
              cmd.datos.asignar_expr.nombre[49] = '\0';
              cmd.datos.asignar_expr.valor = $3;
              guardar_comando(cmd);
          } else if (debe_ejecutar()) {
              float f = $3;
              asignar_variable($1, TIPO_FLOAT, &f);
          }
          free($1);
      }
      
    | condicional
    | bucle
;

/* ==================== CONDICIONAL ==================== */

condicional:
    SI condicion ENTONCES {
        iniciar_si($2);
    } lista_sentencias FINSI PUNTO {
        finalizar_si();
    }
;

condicion:
      expresion MENOR expresion  { $$ = ($1 < $3); }
    | expresion MAYOR expresion  { $$ = ($1 > $3); }
    | expresion IGUAL expresion  { $$ = ($1 == $3); }
    | expresion                  { $$ = ($1 != 0); }
;

/* ==================== BUCLE ==================== */

bucle:
    REPETIR NUM_INT VECES {
        iniciar_repetir($2);
    } lista_sentencias FINREPETIR PUNTO {
        finalizar_repetir();
    }
;

/* ==================== EXPRESIONES ==================== */

expresion:
      expresion SUMA expresion   { $$ = $1 + $3; }
    | expresion RESTA expresion  { $$ = $1 - $3; }
    | expresion MULT expresion   { $$ = $1 * $3; }
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

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d: %s (token: '%s')\n", yylineno, s, yytext);
}

void asignar_variable(const char *nombre, TipoDato tipo, void *valor) {
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