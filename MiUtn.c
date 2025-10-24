#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
int yyparse();

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo.miutn>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error al abrir el archivo");
        return 1;
    }

    yyparse(); // Ejecuta el análisis sintáctico
    fclose(yyin);
    return 0;
}
