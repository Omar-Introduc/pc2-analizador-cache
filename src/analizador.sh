#!/bin/bash

OUT_DIR="out"
OUT_HEADERS="$OUT_DIR/headers.csv"
TEMP=$(mktemp) 
DOCS_FILE="docs"
TARGETS_FILE="$DOCS_FILE/targets.txt"
MATRIX_FILE="$OUT_DIR/matriz_cumplimiento.csv"

# Reglas configurables por variable de entorno
MIN_MAX_AGE="${MIN_MAX_AGE:-0}" 
MIN_S_MAXAGE="${MIN_S_MAXAGE:-0}"

cleanup() {
    echo "Ejecutando limpieza de archivos temporales..."
    rm -f "$TEMP" 2>/dev/null
    if [ -z "$ANALIZADOR_NO_CLEANUP" ]; then
        rm -rf "$OUT_DIR" 2>/dev/null
    fi
}

trap cleanup EXIT INT TERM

recolectar() {
    if [ ! -f "$TARGETS_FILE" ]; then
        echo "Error: El archivo de targets '$TARGETS_FILE' no se encontró." >&2
        exit 5 # Código de salida 5: Archivo de targets no encontrado
    fi

    echo "Iniciando análisis de targets desde $TARGETS_FILE"
        echo "\"URL\",\"Cache-Control\",\"ETag\",\"Expires\"" > "$OUT_HEADERS"

    while IFS= read -r target || [ -n "$target" ]; do
        analizar_target "$target"
    done < "$TARGETS_FILE"

    echo "Análisis completado: Resultados guardados en $OUT_HEADERS."
}

analizar_target() {
	option=${2:-0}
	etag=${3:-0}
	echo "Analizando: $1"
        HEADERS=$(get_headers "$1" "$2" "$3" 2> /dev/null)
        
	#echo "$HEADERS"
	
        if ! echo "$HEADERS" | grep -q "^HTTP/"; then
            echo "No se pudo acceder a: $1, se omite."
            echo "\"${1}\",\"N/A\",\"N/A\",\"N/A\"" >> "$OUT_HEADERS"
            return 2 # Código de salida 2: error de red
        fi

        CACHE_CONTROL=$(echo "$HEADERS" | awk -F': ' '/^[Cc]ache-[Cc]ontrol:/ {print $2; exit}' | tr -d '\r' | cut -d ';' -f1)
        ETAG=$(echo "$HEADERS" | awk -F': ' '/^[Ee][Tt]ag:/ {print $2; exit}' | tr -d '\r')
        EXPIRES=$(echo "$HEADERS" | awk -F': ' '/^[Ee]xpires:/ {print $2; exit}' | tr -d '\r')

        CACHE_CONTROL=${CACHE_CONTROL:-N/A}
        ETAG=${ETAG:-N/A}
        EXPIRES=${EXPIRES:-N/A}

        CACHE_CONTROL=$(echo "$CACHE_CONTROL" | sed 's/,/;/g')

        echo "\"${1}\",\"${CACHE_CONTROL}\",\"${ETAG}\",\"${EXPIRES}\"" >> "$OUT_HEADERS"
}

sim_revalidacion_target() {
	#etag_ejemplo="166f0-63fa44419ec80"
	#url_ejemplo="https://www.wikipedia.org/"
	
	url_ejemplo="$1"
	etag_ejemplo="$2"
        echo "\"URL\",\"Cache-Control\",\"ETag\",\"Expires\"" > "$OUT_HEADERS"
	echo "Simulacion de revalidación con target $url_ejemplo y etag $etag_ejemplo"
	analizar_target "$url_ejemplo" "1" "$etag_ejemplo"
	echo "Simulacion completada: Resultados guardados en $OUT_HEADERS."
}

get_headers() {
	url=$1
	option=${2:-0}
	etag=${3:-0}
	#echo "$option"
	
	if [[ "$option" == "0" ]]; then
        	res=$(curl -I "$1" 2> /dev/null)
        	echo "$res"
    	else 
    		res=$(curl -I -H "If-None-Match: \"$etag\"" "$url" 2> /dev/null)
        	echo "$res"
    	fi
}

evaluar() {
    if [ ! -f $OUT_HEADERS ]; then
        echo "Error: El archivo de entrada '$OUT_HEADERS' no se generó correctamente." >&2
        return 6 # Código de salida 6: Archivo de entrada no encontrado
    fi

    echo "El archivo headers.csv se generó correctamente en 'out/'."
    echo "Iniciando evaluación de reglas"

    echo "\"URL\",\"Regla1_OK\",\"Regla2_OK\"" > "$MATRIX_FILE"

    tail -n +2 "$OUT_HEADERS" | while IFS=',' read -r url cache_control etag expires; do
        url=$(echo "$url" | sed 's/^"\(.*\)"$/\1/')
        cache_control=$(echo "$cache_control" | sed 's/^"\(.*\)"$/\1/')
        etag=$(echo "$etag" | sed 's/^"\(.*\)"$/\1/')
        
        # Regla 1: max-age y s-maxage configurables
        max_age=$(echo "$cache_control" | grep -o 'max-age=[0-9]*' | cut -d= -f2)
        s_maxage=$(echo "$cache_control" | grep -o 's-maxage=[0-9]*' | cut -d= -f2)

        if { [[ -n "$max_age" && "$max_age" -ge "$MIN_MAX_AGE" ]]; } || { [[ -n "$s_maxage" && "$s_maxage" -ge "$MIN_S_MAXAGE" ]]; }; then
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

    echo "==========================================="
    echo "      Iniciando script analizador.sh"
    echo "==========================================="
    mkdir -p "$OUT_DIR"
    recolectar
    evaluar
    echo "==========================================="
    echo "      Fin de la ejecución."
    echo "==========================================="


}
main "$@"
