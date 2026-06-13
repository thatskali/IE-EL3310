#!/bin/bash

set -e

PROG=$1

if [ -z "$PROG" ]; then
    echo "Uso: ./run_tests.sh programa1 | programa2 | programa3"
    exit 1
fi

MEMFILE="programas/${PROG}.mem"

if [ ! -f "$MEMFILE" ]; then
    echo "ERROR: no existe $MEMFILE"
    exit 1
fi

echo "Compilando..."
iverilog -g2012 -o sim_pipeline \
tb/tb_riscv_pipeline.sv \
src/riscv_pipeline.sv \
src/pc.sv \
src/instruction_mem.sv \
src/register_file.sv \
src/main_deco.sv \
src/alu_deco.sv \
src/alu.sv \
src/branch_unit.sv \
src/extend.sv \
src/data_mem.sv \
src/load_unit.sv \
src/store_unit.sv \
src/mux21.sv \
src/mux41.sv \
src/pipe_if_id.sv \
src/pipe_id_ex.sv \
src/pipe_ex_mem.sv \
src/pipe_mem_wb.sv \
src/hazard-unit.sv

echo "Ejecutando $MEMFILE..."
vvp sim_pipeline +MEM="$MEMFILE"