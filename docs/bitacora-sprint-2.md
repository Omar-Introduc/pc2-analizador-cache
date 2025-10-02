# Bitácora Sprint 2

## Objetivo del Sprint

El objetivo fue refactorizar el *script* `src/analizador.sh` para hacerlo modular y desarrollar la lógica central que lee los *headers* recolectados, aplica criterios de caché (`Cache-Control`, `ETag`) y genera la matriz de cumplimiento final (`out/matriz_cumplimiento.csv`).
## Proceso de implementación

Se reemplazó el ineficiente `curl -I` por la combinación `curl -w` y *parsing* de `awk` para obtener solo los *headers* necesarios y alinearse con la estructura `headers.csv` definida (`URL,Cache-Control,ETag,Expires`).

| Archivo | Cambio Realizado | Justificación |
| :--- | :--- | :--- |
| `src/analizador.sh` | **Reemplazo de `curl -I`** por un *loop* que usa `curl -I` + `awk` para capturar los valores de `Cache-Control`, `ETag` y `Expires`. | Asegurar que `out/headers.csv` tenga el formato CSV correcto y contenga solo los *headers* necesarios para la evaluación. |
| `src/analizador.sh` | **Actualización del encabezado** en `recolectar()` a `"URL","Cache-Control","ETag","Expires"`. | Alinear el script con la estructura del entregable. |
--------------------------------------------------------------------------------------------

Se completó la refactorización a funciones (`recolectar`, `evaluar`, `main`) y se implementó la lógica de reglas dentro de `evaluar()`.

| Tarea | Lógica Implementada | Código Relevante |
| :--- | :--- | :--- |
| **Lectura** | Se configuró el *loop* de lectura en `evaluar()` para ignorar el encabezado y desempacar los 4 campos esperados: `URL`, `CACHE_CONTROL`, `ETAG`, `EXPIRES`. | `tail -n +2 "$OUT_HEADERS" \| while IFS=',' read -r url cache_control etag expires; do` |
| **Regla 1: Cache-Control** | Se verifica si el campo `Cache-Control` contiene las directivas `max-age` o `s-maxage`. | `if \[\[ "$cache_control" == *max-age* \|\| "$cache_control" == *s-maxage* \]\]; then regla1="OK"` |
| **Regla 2: ETag** | Se verifica si el campo `ETag` existe y no es el valor de "N/A" (usado para errores o ausencia). | `if \[\[ "$etag" != "N/A" && -n "$etag" \]\]; then regla2="OK"` |
| **Matriz Final** | Se creó la lógica para generar `out/matriz_cumplimiento.csv` con los veredictos finales (`OK`/`FALLO`) para ambas reglas. | `echo "\"$url\",\"$regla1\",\"$regla2\"" >> "$MATRIX_FILE"` |

-----

## Comandos para correr las pruebas localmente

```sh
# Ejecutar el flujo completo
make run

# Verificar los archivos generados
cat out/headers.csv
cat out/matriz_cumplimiento.csv
```

## Simulando la prueba de éxito

### Antes (pruebas fallando)
Para que las pruebas fallen, debes asegurarte de que las URLs no cumplan con las condiciones necesarias para las reglas. Específicamente:

En el estado inicial de la implementación de la lógica, las pruebas fallan porque el URL de prueba (ej: `http://www.google.com`) no cumple con ambas reglas de caché, lo que rompe la expectativa de la prueba BATS.

```sh

"https://www.google.com","FALLO","FALLO"
```

### Después (pruebas pasando)
Utiliza URLs que contengan las cabeceras correctas (Cache-Control con max-age o s-maxage, y un ETag presente).

```sh

"https://www.example.com","OK","OK"
```
## Proceso de implementación de pruebas

Para implementar las primeras dos pruebas, se usaron dos targets, `https://www.example.com` y `https://www.google.com`, los cuales cumplen completamente las reglas y no cumplen al menos una, respectivamente. Usando `awk` se extrae de la matriz las respuestas de ambas reglas juntas, y con comparaciones se determina si se cumplieron todas las reglas o no.  
Para la tercera prueba, se tuvo que reestructurar ciertas funciones de `src/analizador.sh` para hacer la simulación de respuesta `304 Not Modified`.

| Tarea | Lógica Implementada | Código Relevante |
| :--- | :--- | :--- |
| **Implementación de get_headers()** | Se implementó una funcion en `src/analizador.sh` la cual dependiendo de los argumentos que se le de den, agarra headers de forma diferente (esto para simular respuesta `304 Not Modified`) | `if [[ "$option" == "0" ]]; then res=$(curl -I "$1" 2> /dev/null) echo "$res" else res=$(curl -I -H "If-None-Match: \"$etag\"" "$url" 2> /dev/null) echo "$res" fi` |
| **Simulación de respuesta `304 Not Modified`** | Se implementó una funcion en `src/analizador.sh` la cual simula una respuesta `304 Not Modified` haciendo uso de una etag de ejemplo y un target de ejemplo | `echo "\"URL\",\"Cache-Control\",\"ETag\",\"Expires\"" > "$OUT_HEADERS" echo "Simulacion de revalidación con target $url_ejemplo y etag $etag_ejemplo" analizar_target "$url_ejemplo" "1" "$etag_ejemplo"` |

--------------------------------------------------------------------------------------------

| Archivo | Cambio Realizado | Justificación |
| :--- | :--- | :--- |
| `src/analizador.sh` | **Cambio de modo de obtención de headers:** en lugar del uso de `curl`, se usa la función `get_headers` | Esto se va a usar para la simulación |
| `src/analizador.sh` | **Refactorización de modo de análisis de targets:** la lógica de análisis de targets se separa en una funcion separada | Esto se va a usar para la simulación | 

## Salida de error esperadas

### Test 1
```sh
✗ Matriz: Matriz reporta OK para una URL de prueba conforme
   (in test file tests/rules.bats, line 32)
     `false' failed
   make[1]: se entra en el directorio '/home/exsos/Escritorio/General/Desarrollo-pc2/pc2-analizador-cache'
   Ejecutando el analizador
   Iniciando script analizador.sh
   Iniciando análisis de targets desde docs/targets.txt
   Analizando: https://www.example.com
   Análisis completado: Resultados guardados en out/headers.csv.
   El archivo headers.csv se generó correctamente en 'out/'.
   Iniciando evaluación de reglas
   Evaluación completada: Resultados guardados en out/matriz_cumplimiento.csv.
   Fin de la ejecución.
   Ejecutando limpieza
   Ejecución completada.
   make[1]: se sale del directorio '/home/exsos/Escritorio/General/Desarrollo-pc2/pc2-analizador-cache'
   Error: Matriz reporto fallo de alguna de las reglas (OKOK)
```

### Test 2
```sh
✗ Matriz: Matriz reporta FALLO para una URL de prueba no conforme
   (in test file tests/rules.bats, line 60)
     `false' failed
   make[1]: se entra en el directorio '/home/exsos/Escritorio/General/Desarrollo-pc2/pc2-analizador-cache'
   Ejecutando el analizador
   Iniciando script analizador.sh
   Iniciando análisis de targets desde docs/targets.txt
   Analizando: https://www.google.com
   Análisis completado: Resultados guardados en out/headers.csv.
   El archivo headers.csv se generó correctamente en 'out/'.
   Iniciando evaluación de reglas
   Evaluación completada: Resultados guardados en out/matriz_cumplimiento.csv.
   Fin de la ejecución.
   Ejecutando limpieza
   Ejecución completada.
   make[1]: se sale del directorio '/home/exsos/Escritorio/General/Desarrollo-pc2/pc2-analizador-cache'
   Error: Matriz no reporto fallo de alguna de las reglas (FALLOFALLO)
```

### Test 3
```sh
✗ Script: Interpreta correctamente respuesta 304 Not Modified del servidor
   (in test file tests/rules.bats, line 100)
     `false' failed
   Error: Script fallo al interpretar respuesta 304 Not Modified
```

## Porque estas pruebas son importantes?

Estas pruebas son importantes para validar el correcto funcionamiento del script, especificamente, que la matriz detecta correctamente el cumplimiento o no cumplimiento de las regla y que este interprete correctamente respuestas no esperadas del servidor
