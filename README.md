## Lenguaje de programacion miutn

Los comentarios usan la siguiente estructura /* comentario */

### Estructura de scanner.l:

Archivo que define los tokens y expresiones regulares del lenguaje, cosas como
palabras reservadas pedidas en las consignas, tipos de archivos 
y los operadores aritmetico-logicos.

```lexer

%{
    /* Código C inicial */
%}

/* Definiciones de patrones (regex) */

%%

/* Reglas léxicas: patrón → acción */

%%

/* Código C adicional (opcional) */

```
Los comentarios en lexer son problemicos a la hora de pasarlos por win_lexer o lexer en si
a continuacion se muestran algunas cosas importantes del archivo:

""."         { return PUNTO; }" Define el caracter con los que se terminan las sentencias
"DECIMAL   {DIGITO}+"."{DIGITO}+" Permite el valor tipo float

### Estructura de parser.y:

Este archivo compone el analizador sintactico, lee los tokens y arma las reglas gramaticales
que el lenguaje va a seguir a la hora de ejecutarse, por ejemplo, que el contenido fuente 
del archivo .miutn, este entre las palabras claves "UTN" "FINUTN".

Este archivo tambien define una estrcutura para usar variables, tabla de simbolos
y la estructura para interpretar el lenguaje.


```parser

%{
    /* Código C inicial (sección de declaraciones)
       - Inclusión de librerías estándar
       - Declaración de funciones externas (yylex, yyerror)
       - Variables globales o estructuras auxiliares
    */
%}

/* Declaración de tokens, tipos de datos y precedencias
   - %token: define los tokens que vienen desde Flex
   - %union: define tipos de valores que pueden tener los tokens
   - %left / %right: define precedencias de operadores
   - %type: asocia reglas con tipos del %union
*/

%%

/* Reglas gramaticales (producciones)
   - Estructura principal del lenguaje
   - Definición de sentencias, expresiones y bloques
   - Acciones semánticas opcionales en C (entre llaves { })
*/

%%

/* Código C adicional (opcional)
   - Función yyerror() para manejar errores sintácticos
   - Función main() o integración con otro archivo .c
*/
```


### MiUtn.c

Este archivo permite al lenguaje ser mas flexible, inicializa lexer y el analizador
sintactico (bison) y lee el contenido de un archivo .miutn.

```c


/* Inclusión de librerías estándar
   - Librerías necesarias para manejo de archivos, entrada/salida y sistema.
*/
#include <stdio.h>
#include <stdlib.h>

/* Declaraciones externas
   - yyin: archivo de entrada utilizado por Flex.
   - yyparse(): función principal generada por Bison.
*/
extern FILE *yyin;
int yyparse();

/* Función principal del programa
   - Verifica que se haya pasado un archivo .miutn como argumento.
   - Abre el archivo y lo asigna a yyin.
   - Llama a yyparse() para iniciar el análisis léxico y sintáctico.
   - Muestra el resultado del análisis y maneja posibles errores.
*/
int main(int argc, char *argv[]) {
    /* Lógica del programa principal */
}

/* (Opcional) Funciones auxiliares
   - Pueden incluir impresión de mensajes, manejo de errores o modos de depuración.
*/

```