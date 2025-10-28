%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char *yytext;

void yyerror(const char *s);

/* Estructura de variable  */
typedef struct {
    char nombre[50];
    int valor;
} Variable;

Variable tabla[100];
int num_vars = 0;

/* Funciones auxiliares */
void asignar_variable(const char *nombre, int valor);
int obtener_variable(const char *nombre);
%}

%union {
    int  ival;
    float fval;
    char *sval;
}

/* Tokens */
%token UTN FINUTN LEER ESCRIBIR REPETIR VECES SI ENTONCES FINSI
%token INT STRING FLOAT
%token ASIGN MAYOR MENOR IGUAL SUMA RESTA MULT PARI PARD COMA PUNTO
%token <ival> NUM_INT
%token <fval> NUM_FLOAT
%token <sval> CADENA_TXT ID

%left SUMA RESTA
%left MULT

%type <ival> expresion

%%

programa:
    UTN lista_sentencias FINUTN
;

lista_sentencias:
      lista_sentencias sentencia
    | sentencia
;

sentencia:
      ESCRIBIR PARI expresion PARD PUNTO   { printf("%d\n", $3); }
    | ESCRIBIR PARI CADENA_TXT PARD PUNTO  { printf("%s\n", $3); free($3); }
    | LEER PARI ID PARD PUNTO              {
                                              int valor;
                                              printf("Ingrese valor para %s: ", $3);
                                              scanf("%d", &valor);
                                              asignar_variable($3, valor);
                                              free($3);
                                           }
    | INT ID ASIGN expresion PUNTO         { asignar_variable($2, $4); printf("(int) %s = %d\n", $2, $4); free($2); }
    | STRING ID ASIGN CADENA_TXT PUNTO     { printf("(string) %s = \"%s\"\n", $2, $4); free($2); free($4); }
    | FLOAT ID ASIGN expresion PUNTO       { asignar_variable($2, $4); printf("(float) %s = %d\n", $2, $4); free($2); }
    | ID ASIGN expresion PUNTO             { asignar_variable($1, $3); printf("%s := %d\n", $1, $3); free($1); }
;

expresion:
      expresion SUMA expresion   { $$ = $1 + $3; }
    | expresion RESTA expresion  { $$ = $1 - $3; }
    | expresion MULT expresion   { $$ = $1 * $3; }
    | PARI expresion PARD        { $$ = $2; }
    | NUM_INT                    { $$ = $1; }
    | NUM_FLOAT                  { $$ = (int)$1; }
    | ID                         { $$ = obtener_variable($1); free($1); }
;

%%

/* -------------------------------
   Funciones auxiliares
   ------------------------------- */

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d: %s (token: '%s')\n", yylineno, s, yytext);
}

void asignar_variable(const char *nombre, int valor) {
    for (int i = 0; i < num_vars; i++) {
        if (strcmp(tabla[i].nombre, nombre) == 0) {
            tabla[i].valor = valor;
            return;
        }
    }
    strcpy(tabla[num_vars].nombre, nombre);
    tabla[num_vars].valor = valor;
    num_vars++;
}

int obtener_variable(const char *nombre) {
    for (int i = 0; i < num_vars; i++) {
        if (strcmp(tabla[i].nombre, nombre) == 0)
            return tabla[i].valor;
    }
    printf("Advertencia: variable '%s' no definida (usando 0)\n", nombre);
    return 0;
}
