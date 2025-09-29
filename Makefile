SHELL := /bin/bash
PROJECT_NAME := analizador-cache
OUT_DIR := out
DIST_DIR := dist

.PHONY: help tools test clean

help: ## Muestra esta ayuda.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

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

clean: ## Limpia los directorios de salida.
	@echo "Limpiando directorios de salida..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)
	@echo "Limpieza completada."

run:  ## Ejecuta el script analizador.sh
	@echo "Ejecutando el analizador"
	@bash src/analizador.sh
	@echo "Ejecución completada."