%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}


DIGITO    [0-9]
LETRA     [a-zA-Z]
IDENT     {LETRA}({LETRA}|{DIGITO}|_)*
ENTERO    {DIGITO}+
DECIMAL   {DIGITO}+"."{DIGITO}+
CADENA    \"([^\"\n]|\\\")*\"
ESPACIOS  [ \t\r\n]+
COMENTARIO "//".*

%%


"utn"       { return UTN; }
"finutn"    { return FINUTN; }
"leer"      { return LEER; }
"escribir"  { return ESCRIBIR; }
"repetir"   { return REPETIR; }
"veces"     { return VECES; }
"si"        { return SI; }
"entonces"  { return ENTONCES; }
"finsi"     { return FINSI; }


"int"       { return INT; }
"string"    { return STRING; }
"float"     { return FLOAT; }


":="        { return ASIGN; }
">"         { return MAYOR; }
"<"         { return MENOR; }
"="         { return IGUAL; }
"+"         { return SUMA; }
"-"         { return RESTA; }
"*"         { return MULT; }
"("         { return PARI; }
")"         { return PARD; }
","         { return COMA; }
"."         { return PUNTO; }


{ENTERO}    { yylval.ival = atoi(yytext); return NUM_INT; }
{DECIMAL}   { yylval.fval = atof(yytext); return NUM_FLOAT; }
{CADENA}    { 
    /* Remover comillas y procesar escapes */
    char *text = yytext;
    int len = strlen(text);
    char *str = (char *)malloc(len - 1);
    strncpy(str, text + 1, len - 2);
    str[len - 2] = '\0';
    yylval.sval = str;
    return CADENA_TXT; 
}
{IDENT}     { yylval.sval = strdup(yytext); return ID; }

{COMENTARIO}  { /* ignorar */ }
{ESPACIOS}    { /* ignorar */ }

.           { printf("Error lexico: simbolo '%s' no reconocido\n", yytext); }

%%

int yywrap() {
    return 1;
}