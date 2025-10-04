## Estructura de Salidas

### Archivo `headers.csv`

Este archivo contiene los valores de las cabeceras de cache obtenidas para cada URL analizada.

**Formato:**
```csv
"URL","Cache-Control","ETag","Expires"
```
- **Comillas:** Los valores se encierran entre comillas para manejar caracteres especiales como comas.
- **Separador de `Cache-Control`:** Los múltiples valores en la cabecera `Cache-Control` se separan por punto y coma (`;`) en lugar de comas para evitar conflictos con el formato CSV.

### Archivo `matriz_cumplimiento.csv`

Este archivo es el resultado de la evaluación de las reglas de cumplimiento. Indica si cada URL cumple o no con las políticas de caché definidas.

**Formato:**
```csv
"URL","Regla1_OK","Regla2_OK"
```
- **`URL`**: La URL que fue analizada.
- **`Regla1_OK`**: Indica si la URL cumple con la Regla 1 (Directivas de Frescura). Los valores pueden ser `OK` o `FALLO`.
- **`Regla2_OK`**: Indica si la URL cumple con la Regla 2 (Validadores de Contenido). Los valores pueden ser `OK` o `FALLO`.