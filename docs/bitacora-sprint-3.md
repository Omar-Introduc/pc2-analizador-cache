### Implementación del Target `pack`

#### Especificación
El objetivo era crear un target `pack` en el `Makefile` que generara un archivo `.tar.gz` distribuible del proyecto en el directorio `dist/`.

- **Variable `RELEASE`**: Se añadió una variable `RELEASE` al `Makefile` con un valor incial por defecto de `v0.1.0`. Se utilizó `?=` para permitir que su valor se pueda sobrescribir fácilmente desde la línea de comandos (ej. `make pack RELEASE=v1.0.0`).
- **Contenido del Archivo**: El archivo `.tar.gz` incluye los directorios `src` y `docs`, así como el propio `Makefile`. Esto asegura que el paquete sea autocontenido y contenga todo lo necesario para ejecutar y entender el proyecto.
- **Directorio de Salida**: Se utiliza la variable `DIST_DIR` para el directorio de salida, manteniendo la estructura del proyecto limpia y organizada.

#### Problemáticas y Soluciones
No se encontraron problemas significativos durante la implementación del target `pack`. El proceso fue directo y se completó sin problemas.

---

### 2. Implementación de Caché Incremental

#### Especificación
El objetivo era optimizar el target `run` para que el script `analizador.sh` solo se ejecutara si sus dependencias (el propio script o el archivo de entrada `docs/targets.txt`) habían cambiado desde la última ejecución.

#### Decisiones de Diseño
- **Patrón de "Sentinel File"**: El enfoque inicial de usar los archivos de salida (`headers.csv`, `matriz_cumplimiento.csv`) como dependencias directas provocaba que el script se ejecutara múltiples veces, una por cada archivo. Para solucionar esto, se implementó el patrón de "sentinel file".
  - Se crea un archivo oculto, `.cache`, en el directorio `out/` después de que el script `analizador.sh` se ejecuta con éxito.
  - El target `run` ahora depende de este archivo `.cache`. A su vez, `.cache` depende de `src/analizador.sh` y `docs/targets.txt`.
  - Este diseño asegura que la lógica de análisis se ejecute solo una vez y únicamente cuando sea estrictamente necesario.

#### Problemáticas y Soluciones
- **Problema 1: Directorio `out/` no existente.**
  - **Síntoma**: La ejecución de `make run` fallaba porque el comando `touch out/.cache` no podía crear el archivo, ya que el directorio `out/` no existía.
  - **Causa Raíz**: Un error tipográfico en el `Makefile` (`ANALIZador_SCRIPT` en lugar de `ANALIZADOR_SCRIPT`) impedía que el script de análisis se ejecutara y creara el directorio.
  - **Solución**: Se corrigió el error tipográfico en la variable.

- **Problema 2: Limpieza automática del directorio `out/`.**
  - **Síntoma**: Incluso después de corregir el error tipográfico, el comando `touch` seguía fallando. El script `analizador.sh` se ejecutaba, pero el directorio `out/` desaparecía antes de que se pudiera crear el archivo `.cache`.
  - **Causa Raíz**: El script `analizador.sh` contiene una función `cleanup` que se activa con `trap` y elimina el directorio `out/` al finalizar la ejecución. Este comportamiento se puede desactivar con una variable de entorno.
  - **Solución**: Se añadió la variable de entorno `ANALIZADOR_NO_CLEANUP=true` a la llamada del script en el `Makefile`. Esto evita la limpieza automática del directorio `out/` y permite que el archivo `.cache` se cree correctamente, completando la implementación de la caché.

### Actualización del README.md, contrato-salidas.md y `make help`

- La tabla de variable de entorno del documento `README.md` fue actualizada para incluir las dos variables añadidas para la configuración de Regla 1 (`MIN_MAX_AGE` y  `MIN_S_MAXAGE`).
- `contrato-salidas.md` fue actualizado para especificar el formato de salida de la matriz en `matriz_cumplimiento.csv`, tambien se especifico la salida de las cabeceras en `headers.csv`
- Se actualizaron los comentarios en el `Makefile` que incluyen descripciones de los targets. Estos son impresos en terminal via un `grep` en `make help`, junto a su respectivo target.
