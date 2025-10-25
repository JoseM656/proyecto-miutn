%{
#include "parser.tab.h"   // Tokens generados por Bison
#include <stdio.h>
%}

/* Se definen los patrones o expresiones regulares */
DIGITO          [0-9]
LETRA           [a-zA-Z]
IDENT           {LETRA}({LETRA}|{DIGITO}|_)*
ENTERO          {DIGITO}+
DECIMAL         {DIGITO}+"."{DIGITO}+ /* Permite el float */
CADENA          \"([^\"\n]|\\\")*\"
ESPACIOS        [ \t\r\n]+
COMENTARIO      \/\/.*              /* Permite los comentarios con "//" */

%%

/* Palabras reservadas pedidas en la consigna */ 
"utn"           { return UTN; }
"finutn"        { return FINUTN; }
"leer"          { return LEER; }
"escribir"      { return ESCRIBIR; }
"repetir"       { return REPETIR; }
"veces"         { return VECES; }
"si"            { return SI; }
"entonces"      { return ENTONCES; }
"finsi"         { return FINSI; }

/* Define tipos de datos basicos */
"int"           { return INT; }
"string"        { return STRING; }
"float"         { return FLOAT; }

/* Operadores aritmeticos y logicos */
":="            { return ASIGN; }
">"             { return MAYOR; }
"<"             { return MENOR; }
"="             { return IGUAL; }
"+"             { return SUMA; }
"-"             { return RESTA; }
"*"             { return MULT; }
"("             { return PARI; }
")"             { return PARD; }
","             { return COMA; }

"."             { return PUNTO; } /* Simbolo para terminar las sentencias */

/* Define las reglas */
{DECIMAL}       { yylval.fval = atof(yytext); return NUM_FLOAT; }
{ENTERO}        { yylval.ival = atoi(yytext); return NUM_INT; }
{CADENA}        { yylval.sval = strdup(yytext); return CADENA_TXT; }
{IDENT}         { yylval.sval = strdup(yytext); return ID; }

{COMENTARIO}    { /* Ignorar línea */ } 
{ESPACIOS}      { /* Ignorar */ } 

.               { printf("Error léxico: símbolo '%s' no reconocido.\n", yytext); }

%%

int yywrap() { return 1; }
