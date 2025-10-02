# Proyecto 6: Analizador de Headers de Cache
Documentación de variables:
| Variable | Descripción                                                            | Ejemplo                                                |
|:--------:|------------------------------------------------------------------------|--------------------------------------------------------|
|$TARGETS  |Incluye las URLs las cuales se quieren consultar, separadas por espacios| TARGETS="www.google.com www.example.com www.github.com"|

## Reglas de Cumplimiento de Cache

El script `analizador.sh` evalúa el cumplimiento de las políticas de caché de las URLs basándose en dos reglas fundamentales. El resultado de esta evaluación se guarda en `out/matriz_cumplimiento.csv`.


### Regla 1: Directivas de Frescura (`max-age` o `s-maxage`)

Esta regla verifica si la respuesta del servidor incluye la directiva `Cache-Control` con una instrucción de tiempo de vida, como `max-age` o `s-maxage`. Estas directivas son cruciales porque le indican al navegador o al proxy por cuánto tiempo puede reutilizar una copia local del recurso sin necesidad de volver a consultar al servidor.

- **Cumplimiento (`OK`):** La cabecera `Cache-Control` contiene `max-age` o `s-maxage`.
- **Fallo (`FALLO`):** La cabecera no contiene ninguna de estas directivas.

### Regla 2: Validadores de Contenido (`ETag`)

Esta regla comprueba la presencia de la cabecera `ETag`. El `ETag` es un identificador único para una versión específica de un recurso. Permite a los clientes realizar solicitudes condicionales (`If-None-Match`), donde el servidor puede responder con un `304 Not Modified` si el recurso no ha cambiado, ahorrando ancho de banda.

- **Cumplimiento (`OK`):** La cabecera `ETag` está presente y tiene un valor.
- **Fallo (`FALLO`):** La cabecera `ETag` no existe o no tiene valor (`N/A`).