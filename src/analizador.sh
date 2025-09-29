#!/bin/bash

OUT_DIR="out"
OUT_HEADERS="$OUT_DIR/headers.csv"
TEMP=$(mktemp) 

cleanup() {
    echo "Ejecutando limpieza"
    rm -f "$TEMP" 2>/dev/null
}

trap cleanup EXIT INT TERM

mkdir -p "$OUT_DIR"

echo "URL " > "$OUT_HEADERS"

DOCS_FILE="docs"
TARGETS_FILE="$DOCS_FILE/targets.txt"
if [ ! -f "$TARGETS_FILE" ]; then
    echo "Erro: El archivo de targets '$TARGETS_FILE' no se encontró." >&2
    exit 1
fi

echo "Iniciando análisis de targets desde $TARGETS_FILE"

while IFS= read -r target; do
    echo "Analizando: $target"
    HEADERS=$(curl -I "$target" 2> /dev/null)
    
    if [ $? -eq 0 ]; then
        echo "${target},${HEADERS}" >> "$OUT_HEADERS"
    else
        echo "${target},ERROR,N/A" >> "$OUT_HEADERS"
        echo " Aviso: Falló la conexión para ${target}" >&2
    fi

done < "$TARGETS_FILE"

echo "Análisis completado: Resultados guardados en $OUT_HEADERS."

