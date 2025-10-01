#!/usr/bin/env bats

OUT_DIR="out"
OUT_HEADERS="$OUT_DIR/headers.csv"
OUT_MATRIZ="$OUT_DIR/matriz_cumplimiento.csv"
DOCS_DIR="docs"
DOCS_TARGETS="$DOCS_DIR/targets.txt"
URL_TEST_OK="https://www.example.com"
URL_TEST_FALLO="https://www.google.com"

@test "Matriz: Matriz reporta OK para una URL de prueba conforme" {
    #echo "$OUT_HEADERS" >&3
    #echo "$DOCS_TARGETS" >&3
    
    if [ ! -d "$DOCS_DIR" ]; then
        echo "no existe directorio $DOCS_DIR" >&2
        false
    fi
    
    #Se va a usar URL URL_TEST_OK
    #https://www.example.com
    #https://www.google.com
    
    echo "$URL_TEST_OK" > "$DOCS_TARGETS"
    make run
    
    #cat "$OUT_MATRIZ" | awk -v regex="$URL_TEST_OK" -F "," '$0 ~ regex {print $2 $3}' >&3
    REPORTE="$(cat "$OUT_MATRIZ" | awk -F "," 'NR==2 {print $2 $3}')"
    
    if [[ ! "$REPORTE" == "OKOK" ]]; then
        echo "Error: Matriz reporto fallo de alguna de las reglas ($REPORTE)" >&2
        false
    fi
    
    echo "Matriz reporto \"OK\" para ambas reglas" >&3
}

@test "Matriz: Matriz reporta FALLO para una URL de prueba no conforme" {
    #echo "$OUT_HEADERS" >&3
    #echo "$DOCS_TARGETS" >&3
    
    if [ ! -d "$DOCS_DIR" ]; then
        echo "no existe directorio $DOCS_DIR" >&2
        false
    fi
    
    #Se va a usar URL URL_TEST_FALLO
    #https://www.example.com
    #https://www.google.com
    
    
    echo "$URL_TEST_FALLO" > "$DOCS_TARGETS"
    make run
    
    #cat "$OUT_MATRIZ" | awk -v regex="$URL_TEST_OK" -F "," '$0 ~ regex {print $2 $3}' >&3
    REPORTE="$(cat "$OUT_MATRIZ" | awk -F "," 'NR==2 {print $2 $3}')"
    
    if [[ "$REPORTE" == "OKOK" ]]; then
        echo "Error: Matriz no reporto fallo de alguna de las reglas ($REPORTE)" >&2
        false
    fi
    
    echo "Matriz reporto \"FALLO\" para una de las reglas" >&3
}
