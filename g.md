# Fichero de Decisiones Técnicas del Proyecto

Este documento registra las decisiones clave tomadas durante la refactorización y mejora del proyecto "Analizador de Headers de Cache", con el objetivo de alinearlo a los principios de robustez, automatización y 12-Factor.

## 1. Refactorización de `analizador.sh`

### Decisión: Adoptar `set -euo pipefail`
- **Problemática:** El script original carecía de un manejo de errores robusto. Un comando fallido no detenía la ejecución, pudiendo llevar a resultados incorrectos o incompletos.
- **Solución:** Se ha añadido `set -euo pipefail` al inicio del script.
  - `set -e`: El script terminará inmediatamente si un comando falla.
  - `set -u`: Tratar las variables no definidas como un error.
  - `set -o pipefail`: Asegura que si un comando en una tubería (`|`) falla, el código de salida de toda la tubería sea el del comando fallido.
- **Justificación:** Aumenta la fiabilidad y previsibilidad del script, un requisito clave para la automatización.

### Decisión: Configuración vía Variables de Entorno (`TARGETS`)
- **Problemática:** El script leía las URLs desde un fichero (`docs/targets.txt`), lo cual viola el Factor III de 12-Factor (configuración en el entorno).
- **Solución:** Se ha modificado el script para que priorice la variable de entorno `TARGETS`. Si esta no se encuentra definida, como fallback, utilizará el fichero `docs/targets.txt`.
- **Justificación:** Facilita la ejecución en distintos entornos (desarrollo, pruebas, producción) sin modificar el código fuente.

### Decisión: Implementar Ejecución Modular con Flags
- **Problemática:** El script ejecutaba todas sus fases (recolección, evaluación) de forma monolítica. Esto dificultaba las pruebas y la reutilización de fases individuales.
- **Solución:** Se han añadido flags (`--recolectar-only`, `--evaluar-only`, `--simular`) para controlar qué parte del script se ejecuta.
- **Justificación:** Cumple con el Factor V de 12-Factor (separación estricta de fases build/release/run) y permite una mayor flexibilidad para depuración y pruebas.

## 2. Mejora del `Makefile`

### Decisión: Completar y Corregir Targets
- **Problemática:** El `Makefile` estaba incompleto. Faltaban los targets `build` y `pack`, y no todos los targets no-fichero estaban declarados como `.PHONY`.
- **Solución:** Se han añadido los targets `build` y `pack`, y se ha corregido el uso de `.PHONY`.
  - `build`: Encapsula la generación de artefactos en `out/`.
  - `pack`: Crea un paquete distribuible en `dist/`.
- **Justificación:** Proporciona una interfaz de automatización estándar y predecible, alineada con las buenas prácticas.

## 3. Mecanismo de Verificación Funcional

### Decisión: Crear un Flag de Autoevaluación (`--test-funcionamiento`)
- **Problemática:** Se requería una forma de validar la funcionalidad del script sin depender de la configuración completa de `bats`, que presentaba problemas.
- **Solución:** Se ha creado un modo de prueba (`--test-funcionamiento`) dentro del propio script `analizador.sh`. Este modo ejecuta un caso de prueba controlado (con una URL de prueba) y verifica que las salidas generadas sean las correctas mediante `grep`.
- **Justificación:** Proporciona una prueba de humo rápida, portable y desacoplada del framework de pruebas completo, garantizando que la lógica principal del script funciona como se espera. Permite una verificación en un "entorno limpio" sin dependencias externas complejas.