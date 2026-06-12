#!/usr/bin/env bash
# run_all_tb.sh
# Script para compilar y ejecutar los testbenches del procesador RISC-V uniciclo.
# Se ejecuta desde la carpeta riscv_uniciclo.

set -u

BUILD_DIR="build"
LOG_DIR="$BUILD_DIR/logs"

mkdir -p "$BUILD_DIR" "$LOG_DIR"

PASSED=0
FAILED=0
SKIPPED=0

run_test() {
    local name="$1"
    local top="$2"
    shift 2
    local files=("$@")

    echo "----------------------------------------"
    echo "TEST: $name"
    echo "TOP : $top"

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "SKIP: falta $file"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
    done

    if iverilog -g2012 -Wall -s "$top" -o "$BUILD_DIR/$name.out" "${files[@]}" > "$LOG_DIR/$name.compile.log" 2>&1; then
        if vvp "$BUILD_DIR/$name.out" > "$LOG_DIR/$name.run.log" 2>&1; then
            echo "PASS: $name"
            PASSED=$((PASSED + 1))
        else
            echo "FAIL: $name falló durante la ejecución"
            echo "Ver: $LOG_DIR/$name.run.log"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "FAIL: $name falló durante la compilación"
        echo "Ver: $LOG_DIR/$name.compile.log"
        FAILED=$((FAILED + 1))
    fi
}

run_optional_test() {
    local name="$1"
    local top="$2"
    shift 2
    local files=("$@")

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "----------------------------------------"
            echo "TEST: $name"
            echo "SKIP: falta $file"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
    done

    run_test "$name" "$top" "${files[@]}"
}

# =========================================================
# Testbenches individuales
# =========================================================

run_optional_test "adder_tb"           "adder_tb"           src/adder.sv tb/adder_tb.sv
run_test          "mux21_tb"           "mux21_tb"           src/mux21.sv tb/mux21_tb.sv
run_test          "mux41_tb"           "mux41_tb"           src/mux41.sv tb/mux41_tb.sv
run_test          "pc_tb"              "pc_tb"              src/pc.sv tb/pc_tb.sv
run_optional_test "pc_increment_tb"    "pc_increment_tb"    src/pc.sv src/adder.sv src/mux21.sv src/pc_increment.sv tb/pc_increment_tb.sv
run_test          "instruction_mem_tb" "instruction_mem_tb" src/instruction_mem.sv tb/instruction_mem_tb.sv
run_test          "extend_tb"          "extend_tb"          src/extend.sv tb/extend_tb.sv
run_test          "alu_tb"             "alu_tb"             src/alu.sv tb/alu_tb.sv
run_test          "alu_deco_tb"        "alu_deco_tb"        src/alu_deco.sv tb/alu_deco_tb.sv
run_test          "main_deco_tb"       "main_deco_tb"       src/main_deco.sv tb/main_deco_tb.sv
run_test          "branch_unit_tb"     "branch_unit_tb"     src/branch_unit.sv tb/branch_unit_tb.sv
run_test          "control_unit_tb"    "control_unit_tb"    src/main_deco.sv src/alu_deco.sv src/branch_unit.sv src/control_unit.sv tb/control_unit_tb.sv
run_test          "register_file_tb"   "tb_register_file"   src/register_file.sv tb/register_file_tb.sv
run_test          "store_unit_tb"      "tb_store_unit"      src/store_unit.sv tb/store_unit_tb.sv
run_test          "load_unit_tb"       "tb_load_unit"       src/load_unit.sv tb/load_unit_tb.sv
run_test          "data_mem_tb"        "tb_data_mem"        src/data_mem.sv tb/data_mem_tb.sv

# =========================================================
# Testbench completo
# =========================================================

run_test "riscv_top_tb" "riscv_top_tb" \
    src/pc.sv \
    src/instruction_mem.sv \
    src/main_deco.sv \
    src/alu_deco.sv \
    src/branch_unit.sv \
    src/control_unit.sv \
    src/register_file.sv \
    src/extend.sv \
    src/mux21.sv \
    src/mux41.sv \
    src/alu.sv \
    src/store_unit.sv \
    src/data_mem.sv \
    src/load_unit.sv \
    src/riscv_top.sv \
    tb/riscv_top_tb.sv

# =========================================================
# Resumen
# =========================================================

echo "----------------------------------------"
echo "Resumen de pruebas"
echo "PASS : $PASSED"
echo "FAIL : $FAILED"
echo "SKIP : $SKIPPED"
echo "Logs : $LOG_DIR"

if [ "$FAILED" -ne 0 ]; then
    exit 1
fi

exit 0
