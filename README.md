## Lenguaje de programacion miutn
El proyecto MiUTN consiste en un lenguaje interpretado básico, implementado con Flex (lexer) 
y Bison (parser) y gcc,permite declarar variables, leer y escribir valores, 
operar con expresiones aritméticas y trabajar con cadenas de texto.

Los comentarios usan en codigo usan la siguiente estructura /* comentario */

Estructura basica:

´´´ASCII


PROYECTO_FINAL2/
│
├── src/
│   ├── scanner.l          → Analizador léxico (Flex)
│   ├── parser.y           → Analizador sintáctico (Bison)
│   ├── parser.tab.c       → Código C generado por Bison (desechable)
│   ├── parser.tab.h       → Encabezado generado por Bison (desechable)
│   ├── lex.yy.c           → Código C generado por Flex (desechable)
│   ├── MiUtn.c            → Programa principal (ejecuta el parser)
│   └── miutn.exe          → Ejecutable compilado
│
├── programa.miutn         → Programa de prueba principal
├── programa_minimo.miutn  → Ejemplo básico del lenguaje
│
└── README.md              → Documentación del proyecto
´´´

### Estructura de scanner.l:

Archivo que define los **tokens y expresiones regulares del lenguaje**, cosas como
palabras reservadas pedidas en las consignas, tipos de archivos, 
operadores aritmetico-logicos y comentarios.

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
**Importante sobre lexer**

- ´´"." { return PUNTO; }´´ obligatorio al finalizar cada setencia.

- ´´DECIMAL {DIGITO}+"."{DIGITO}+´´ Permite reconocer valores de tipo float (ej: 3.14).

- Se definen los comentarios usando "//".

### Estructura de parser.y:

Este archivo compone el analizador sintactico y es una pieza clave para lograr
que el lenguaje sea util. Lee los tokens y arma las reglas gramaticales
que el lenguaje va a seguir a la hora de ejecutarse, por ejemplo, que el contenido fuente 
del archivo .miutn, este entre las palabras claves "UTN" "FINUTN".

Este archivo tambien define una estrcutura para usar variables, tabla de simbolos
y la estructura para interpretar el lenguaje.

También gestiona:

- **Declaración de variables**

- Tabla de símbolos

- Tipos de datos (int, float, string)

- Lectura y escritura

- Operaciones aritméticas

```parser

%{
    /* Código C inicial (declaraciones)
       - Librerías estándar
       - Funciones externas (yylex, yyerror)
       - Estructuras de datos y variables globales
    */
%}

/* Declaración de tokens, tipos de datos y precedencias
   - %token: define los tokens de Flex
   - %union: agrupa los tipos de valores (int, float, string)
   - %left / %right: define precedencias
   - %type: asocia tipos del %union con reglas gramaticales
*/

%%

/* Reglas gramaticales
   - Estructura principal del lenguaje
   - Definición de sentencias (leer, escribir, asignar, etc.)
   - Expresiones aritméticas y manejo de variables
*/

%%

/* Código C adicional
   - Funciones auxiliares (asignar_variable, obtener_variable)
   - Manejador de errores sintácticos (yyerror)
*/

```


### MiUtn.c

Este archivo permite al lenguaje ser mas flexible, sirve como punto de entrada 
del programa Permite ejecutar el analizador con un archivo fuente .miutn desde línea de comandos.

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

**Características finales**

- Soporte para int, float y string

- Operadores aritméticos: +, -, *

- Lectura (leer) y escritura (escribir)

- Comentarios con //

- Ejecución desde archivo .miutn

- Manejo de errores léxicos y sintácticos

- Tabla de símbolos interna (memoria básica)