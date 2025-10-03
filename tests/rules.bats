#!/usr/bin/env bats

load 'test_helper'

OUT_DIR_TESTS="$TMP_DIR_TESTS/out"
DOCS_DIR_TESTS="$TMP_DIR_TESTS/docs"
TARGETS_FILE_TESTS="$TMP_DIR_TESTS/docs/targets.txt"
MATRIZ_FILE_TESTS="$OUT_DIR_TESTS/matriz_cumplimiento.csv"
OUT_HEADERS_TESTS="$OUT_DIR_TESTS/headers.csv"

URL_TEST_OK="https://www.example.com"
URL_TEST_FALLO="https://www.google.com"

@test "Matriz: Matriz reporta OK para una URL de prueba conforme" {
    #echo "$OUT_HEADERS" >&3
    #echo "$DOCS_TARGETS" >&3
    echo "$URL_TEST_OK" > "$TARGETS_FILE_TESTS"
        
    #if [ ! -d "$$DOCS_DIR_TESTS" ]; then
    #    echo "no existe directorio $DOCS_DIR" >&2
    #    false
    #fi
    
    #Se va a usar URL URL_TEST_OK
    #https://www.example.com
    #https://www.google.com
    
    TARGETS_FILE="$TARGETS_FILE_TESTS" OUT_DIR="$OUT_DIR_TESTS" make run
    
    #cat "$OUT_MATRIZ" | awk -v regex="$URL_TEST_OK" -F "," '$0 ~ regex {print $2 $3}' >&3
    REPORTE="$(cat "$MATRIZ_FILE_TESTS" | awk -F "," 'NR==2 {print $2 $3}')"
    
    if [[ ! "$REPORTE" == "OKOK" ]]; then
        echo "Error: Matriz reporto fallo de alguna de las reglas ($REPORTE)" >&2
        false
    fi
    
    echo "Matriz reporto \"OK\" para ambas reglas" >&3
}

@test "Matriz: Matriz reporta FALLO para una URL de prueba no conforme" {
    #echo "$OUT_HEADERS" >&3
    #echo "$DOCS_TARGETS" >&3
    
    #if [ ! -d "$DOCS_DIR_TESTS" ]; then
    #    echo "no existe directorio $DOCS_DIR" >&2
    #    false
    #fi
    
    #Se va a usar URL URL_TEST_FALLO
    #https://www.example.com
    #https://www.google.com
    
    
    echo "$URL_TEST_FALLO" > "$TARGETS_FILE_TESTS"
    TARGETS_FILE="$TARGETS_FILE_TESTS" OUT_DIR="$OUT_DIR_TESTS" make run
    
    #cat "$OUT_MATRIZ" | awk -v regex="$URL_TEST_OK" -F "," '$0 ~ regex {print $2 $3}' >&3
    REPORTE="$(cat "$MATRIZ_FILE_TESTS" | awk -F "," 'NR==2 {print $2 $3}')"
    
    if [[ "$REPORTE" == "OKOK" ]]; then
        echo "Error: Matriz no reporto fallo de alguna de las reglas ($REPORTE)" >&2
        false
    fi
    
    echo "Matriz reporto \"FALLO\" para una de las reglas" >&3
}

@test "Script: Interpreta correctamente una respuesta 304 Not Modified simulada" {
    url_ejemplo="https://mock.example.com"
    etag_ejemplo="etag-que-provoca-un-304"
    
    OUT_HEADERS_TESTS="$TMP_DIR_TESTS/out/headers.csv"

    curl() {
        if [[ "$*" == *'If-None-Match: "'"$etag_ejemplo"'"'* ]]; then
            echo "HTTP/2 304" # Respuesta 304 sin ETag ni Cache-Control
        fi
    }
    export -f curl

    OUT_DIR="$OUT_DIR_TESTS" ANALIZADOR_NO_CLEANUP="true" run bash -c '
        source ./src/analizador.sh
        sim_revalidacion_target "$0" "$1"
    ' "$url_ejemplo" "$etag_ejemplo"

    url="$(cat "$OUT_HEADERS_TESTS" | awk -F, 'NR==2 {print $1}' | sed 's/"//g')"
    cache_control="$(cat "$OUT_HEADERS_TESTS" | awk -F, 'NR==2 {print $2}' | sed 's/"//g')"
    etag="$(cat "$OUT_HEADERS_TESTS" | awk -F, 'NR==2 {print $3}' | sed 's/"//g')"

    # Verificamos que el archivo de salida fue creado
    if [[ "$url" == *"$url_ejemplo"* && "$etag" == "N/A" && "$cache_control" == "N/A" ]]; then
        #echo "Error: Matriz no reporto fallo de alguna de las reglas ($REPORTE)" >&2
        #false
        echo "Script interpreto respuesta 304 Not Modified correctamente" >&3
    else
    	echo "Error: Script fallo al interpretar respuesta 304 Not Modified" >&2
        false
    fi
}
