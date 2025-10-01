#!/bin/bash

OUT_DIR="out"
OUT_HEADERS="$OUT_DIR/headers.csv"
TEMP=$(mktemp) 
DOCS_FILE="docs"
TARGETS_FILE="$DOCS_FILE/targets.txt"
MATRIX_FILE="$OUT_DIR/matriz_cumplimiento.csv"

cleanup() {
    echo "Ejecutando limpieza"
    rm -f "$TEMP" 2>/dev/null
}

trap cleanup EXIT INT TERM

recolectar() {
    if [ ! -f "$TARGETS_FILE" ]; then
        echo "Error: El archivo de targets '$TARGETS_FILE' no se encontró." >&2
        exit 1
    fi

    echo "Iniciando análisis de targets desde $TARGETS_FILE"
        echo "\"URL\",\"Cache-Control\",\"ETag\",\"Expires\"" > "$OUT_HEADERS"

    while IFS= read -r target || [ -n "$target" ]; do
        echo "Analizando: $target"
        HEADERS=$(curl -I "$target" 2> /dev/null)

        if ! echo "$HEADERS" | grep -q "^HTTP/"; then
            echo "No se pudo acceder a: $target, se omite."
            echo "\"${target}\",\"N/A\",\"N/A\",\"N/A\"" >> "$OUT_HEADERS"
            continue
        fi

        CACHE_CONTROL=$(echo "$HEADERS" | awk -F': ' '/^[Cc]ache-[Cc]ontrol:/ {print $2; exit}' | tr -d '\r' | cut -d ';' -f1)
        ETAG=$(echo "$HEADERS" | awk -F': ' '/^[Ee][Tt]ag:/ {print $2; exit}' | tr -d '\r')
        EXPIRES=$(echo "$HEADERS" | awk -F': ' '/^[Ee]xpires:/ {print $2; exit}' | tr -d '\r')

        CACHE_CONTROL=${CACHE_CONTROL:-N/A}
        ETAG=${ETAG:-N/A}
        EXPIRES=${EXPIRES:-N/A}

        CACHE_CONTROL=$(echo "$CACHE_CONTROL" | sed 's/,/;/g')

        echo "\"${target}\",\"${CACHE_CONTROL}\",\"${ETAG}\",\"${EXPIRES}\"" >> "$OUT_HEADERS"
    done < "$TARGETS_FILE"

    echo "Análisis completado: Resultados guardados en $OUT_HEADERS."
}

evaluar() {
    if [ ! -f $OUT_HEADERS ]; then
        echo "Error: El archivo de entrada '$OUT_HEADERS' no se generó correctamente." >&2
        return 1
    fi

    echo "El archivo headers.csv se generó correctamente en 'out/'."
    echo "Iniciando evaluación de reglas"

    echo "\"URL\",\"Regla1_OK\",\"Regla2_OK\"" > "$MATRIX_FILE"

    tail -n +2 "$OUT_HEADERS" | while IFS=',' read -r url cache_control etag expires; do
        url=$(echo "$url" | sed 's/^"\(.*\)"$/\1/')
        cache_control=$(echo "$cache_control" | sed 's/^"\(.*\)"$/\1/')
        etag=$(echo "$etag" | sed 's/^"\(.*\)"$/\1/')

        if [[ "$cache_control" == *max-age* || "$cache_control" == *s-maxage* ]]; then
            regla1="OK"
        else
            regla1="FALLO"
        fi

        if [[ "$etag" != "N/A" && -n "$etag" ]]; then
            regla2="OK"
        else
            regla2="FALLO"
        fi

        echo "$url,$regla1,$regla2" >> "$MATRIX_FILE"
    done

    echo "Evaluación completada: Resultados guardados en $MATRIX_FILE."


}

main(){

    echo "Iniciando script analizador.sh"
    mkdir -p "$OUT_DIR"
    recolectar
    evaluar
    echo "Fin de la ejecución."


}
main "$@"
