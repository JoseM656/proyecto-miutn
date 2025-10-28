#include <stdio.h>
#include <stdlib.h>

/* Variables y funciones externas de Flex y Bison */
extern FILE *yyin;     // Archivo de entrada para el lexer
int yyparse();          // Función principal del parser generada por Bison

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo.miutn>\n", argv[0]);
        return 1;
    }

    /* Abrir el archivo fuente .miutn */
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error al abrir el archivo");
        return 1;
    }

    printf("📘 Analizando archivo: %s\n", argv[1]);
    printf("-----------------------------------\n");

    /* Llamar al analizador sintáctico */
    int resultado = yyparse();

    printf("-----------------------------------\n");
    if (resultado == 0)
        printf("✅ Análisis completado correctamente.\n");
    else
        printf("❌ Se encontraron errores durante el análisis.\n");

    fclose(yyin);
    return 0;
}
