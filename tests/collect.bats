#!/usr/bin/env bats

OUT_DIR="out"
OUT_HEADERS="$OUT_DIR/headers.csv"

@test "Makefile: Correcta creación de $OUT_HEADERS" {
    #echo "$OUT_DIR" >&3
    #echo "$OUT_HEADERS" >&3
    run make run
    if [ ! -d "$OUT_DIR" ]; then
        echo "no existe directorio $OUT_DIR" >&2
        false
    else
        if [ ! -f "$OUT_HEADERS" ]; then
            echo "no existe archivo $OUT_HEADERS" >&2
            false
        fi
    fi
    
    echo "archivo $OUT_HEADERS existe" >&3
    
    if [ ! -s "$OUT_HEADERS" ]; then
        echo "$OUT_HEADERS esta vacio" >&2
        false
    else
        echo "$OUT_HEADERS no esta vacio" >&3
    fi
}
