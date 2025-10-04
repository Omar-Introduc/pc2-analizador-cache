#!/usr/bin/env bats

load 'test_helper'

OUT_DIR_TESTS="$TMP_DIR_TESTS/out"
OUT_HEADERS_TESTS="$OUT_DIR_TESTS/headers.csv"
TARGETS_FILE_TESTS="$TMP_DIR_TESTS/docs/targets.txt"


@test "Makefile: Correcta creación de $OUT_HEADERS" {
    #echo "$OUT_DIR" >&3
    #echo "$OUT_HEADERS" >&3
    echo "https://www.example.com" > "$TARGETS_FILE_TESTS"
    #rutas temporales
    TARGETS_FILE="$TARGETS_FILE_TESTS" OUT_DIR="$OUT_DIR_TESTS" make run

    if [ ! -d "$OUT_DIR_TESTS" ]; then
        echo "no existe directorio $OUT_DIR_TESTS" >&2
        false
    else
        if [ ! -f "$OUT_HEADERS_TESTS" ]; then
            echo "no existe archivo $OUT_HEADERS_TESTS" >&2
            false
        fi
    fi
    
    echo "archivo $OUT_HEADERS_TESTS existe" >&3
    
    if [ ! -s "$OUT_HEADERS_TESTS" ]; then
        echo "$OUT_HEADERS_TESTS esta vacio" >&2
        false
    else
        echo "$OUT_HEADERS_TESTS no esta vacio" >&3
    fi
}
