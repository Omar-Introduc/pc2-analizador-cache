#!/usr/bin/env bash

TMP_DIR_TESTS="tests/tmp"

#Funcionamiento para evaluar en entorno limpio
setup(){

    load 'libs/bats-support/load.bash'
    mkdir -p "$TMP_DIR_TESTS"
    mkdir -p "$TMP_DIR_TESTS/docs"
    mkdir -p "$TMP_DIR_TESTS/out"
}

#Limpia lo generado durante la prueba
teardown(){
    rm -rf "$TMP_DIR_TESTS"
}

