SHELL := /bin/bash
PROJECT_NAME := analizador-cache
OUT_DIR := out
DIST_DIR := dist
RELEASE ?=v0.1.0

#Archivo de código fuente y de entrada
ANALIZADOR_SCRIPT := src/analizador.sh
TARGET_INPUT := docs/targets.txt

#Archivo de salida generados
CACHE_FILE := $(OUT_DIR)/.cache

.PHONY: help tools test clean run pack

help: ## Muestra esta ayuda.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

run: $(CACHE_FILE)## Ejecuta el script analizador.sh
	@echo "Ejecución completada. Generado en $(OUT_DIR)/"

$(CACHE_FILE): $(ANALIZADOR_SCRIPT) $(TARGET_INPUT)
	@echo "Ejecutando el analizador..."
	@ANALIZADOR_NO_CLEANUP=true bash $(ANALIZADOR_SCRIPT)
	@touch $@

pack: ## Empaqueta el proyecto en un archivo tar.gz
	@echo "Empaquetando el proyecto..."
	@mkdir -p $(DIST_DIR)
	@tar -czf $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz src docs Makefile
	@echo "Empaquetado completado: $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz"

tools: ## Verifica que las herramientas requeridas estén instaladas.
	@echo "Verificando herramientas requeridas..."
	@for tool in curl bats; do \
		if ! command -v $$tool &> /dev/null; then \
			echo "Error: '$$tool' no está instalado. Por favor, instálalo."; \
			exit 1; \
		fi \
	done
	@echo "Todas las herramientas están instaladas."

test: ## Ejecuta la suite de pruebas con Bats.
	@echo "Ejecutando pruebas..."
	@bats tests/
	@ANALIZADOR_NO_CLEANUP=true bats tests/

clean: ## Limpia los directorios de salida.
	@echo "Limpiando directorios de salida..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)
	@echo "Limpieza completada."
