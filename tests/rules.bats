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
        
    if [ ! -d "$$DOCS_DIR_TESTS" ]; then
        echo "no existe directorio $DOCS_DIR" >&2
        false
    fi
    
    #Se va a usar URL URL_TEST_OK
    #https://www.example.com
    #https://www.google.com
    
    echo "$URL_TEST_OK" > "$TARGETS_FILE_TESTS"
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
    
    if [ ! -d "$DOCS_DIR_TESTS" ]; then
        echo "no existe directorio $DOCS_DIR" >&2
        false
    fi
    
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

@test "Script: Interpreta correctamente respuesta 304 Not Modified del servidor" {
    #echo "$OUT_HEADERS" >&3
    #echo "$DOCS_TARGETS" >&3
    
    #Se va a usar URL URL_TEST_FALLO
    #https://www.example.com
    #https://www.google.com
    
    url_ejemplo="https://www.wikipedia.org/"
    cache_control_ejemplo="s-maxage=86400; must-revalidate; max-age=3600"
    etag_ejemplo="166f0-63fa44419ec80"
    
    run bash -c '
    	url_ejemplo="https://www.wikipedia.org/"
    	etag_ejemplo="166f0-63fa44419ec80"
    	source ./src/analizador.sh
    	sim_revalidacion_target "$url_ejemplo" "$etag_ejemplo"
    	'
    
    #cat "$OUT_HEADERS" | awk -F "," 'NR==2 {print $2 $3}' >&3
    url="$(cat "$OUT_HEADERS" | awk -F "," 'NR==2 {print $1}')"
    cache_control="$(cat "$OUT_HEADERS" | awk -F "," 'NR==2 {print $2}')"
    etag="$(cat "$OUT_HEADERS" | awk -F "," 'NR==2 {print $3}')"
    
    #"$etag" == *"$etag_ejemplo"*
    #"$url" == *"$url_ejemplo"*
    #"$cache_control" == *"$cache_control_ejemplo"*
    
    if [[ "$url" == *"$url_ejemplo"* && "$etag" == *"$etag_ejemplo"* && "$cache_control" == *"$cache_control_ejemplo"* ]]; then
        #echo "Error: Matriz no reporto fallo de alguna de las reglas ($REPORTE)" >&2
        #false
        echo "Script interpreto respuesta 304 Not Modified correctamente" >&3
    else
    	echo "Error: Script fallo al interpretar respuesta 304 Not Modified" >&2
        false
    fi
    
    #echo "Matriz reporto \"FALLO\" para una de las reglas" >&3
}
