%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Variables externas del lexer */
extern int yylex();
extern int yylineno;
extern char *yytext;

/* Función para manejar errores sintácticos */
void yyerror(const char *s);
%}


/* -------------------------------
   Declaración de tokens (de Flex)
   ------------------------------- */
%token UTN FINUTN LEER ESCRIBIR REPETIR VECES SI ENTONCES FINSI
%token INT STRING FLOAT
%token ASIGN MAYOR MENOR IGUAL SUMA RESTA MULT PARI PARD COMA PUNTO
%token NUM_INT NUM_FLOAT CADENA_TXT ID

/* -------------------------------
   Definición de tipos y precedencias
   ------------------------------- */

/* Precedencia de operadores aritméticos */
%left SUMA RESTA
%left MULT

/* Tipos de valores (entero, float, string) */
%union {
    int  ival;
    float fval;
    char *sval;
}

/* Asociamos los tokens con los tipos del %union */
%type <ival> NUM_INT
%type <fval> NUM_FLOAT
%type <sval> ID CADENA_TXT

%%

/* -------------------------------
   REGLAS GRAMATICALES PRINCIPALES
   ------------------------------- */

programa:
      UTN lista_sentencias FINUTN
    ;

lista_sentencias:
      lista_sentencias sentencia
    | sentencia
    ;

sentencia:
      LEER PARI ID PARD PUNTO
    | ESCRIBIR PARI expresion PARD PUNTO
    | ID ASIGN expresion PUNTO
    | SI PARI expresion PARD ENTONCES lista_sentencias FINSI PUNTO
    | REPETIR NUM_INT VECES PUNTO
    | INT ID ASIGN expresion PUNTO
    | STRING ID ASIGN CADENA_TXT PUNTO
    | FLOAT ID ASIGN expresion PUNTO
    ;

expresion:
      expresion SUMA expresion
    | expresion RESTA expresion
    | expresion MULT expresion
    | PARI expresion PARD
    | ID
    | NUM_INT
    | NUM_FLOAT
    | CADENA_TXT
    ;

%%

/* -------------------------------
   CÓDIGO C AUXILIAR
   ------------------------------- */

void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico en línea %d: %s (token: '%s')\n", yylineno, s, yytext);
}

// int main(int argc, char *argv[]) {
//    printf("Iniciando analizador MiUtn...\n");

//    if (yyparse() == 0)
//        printf("Análisis completado correctamente.\n");
//    else
//        printf("Se encontraron errores durante el análisis.\n");

//    return 0;
//}
