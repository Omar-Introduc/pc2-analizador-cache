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
