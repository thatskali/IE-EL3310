
// Testbench completo del procesador RISC-V uniciclo
// Prueba dos programas: ALU/Memoria y Branches/Jumps
module riscv_top_tb;

    logic clk;
    logic rst;

    // --- Instancia del procesador ---
    riscv_top dut (
        .clk (clk),
        .rst (rst)
    );

    // --- Generador de reloj ---
    always #5 clk = ~clk;

    // --- Tarea para verificar resultados ---
    task check (
        input string       nombre,
        input logic [31:0] obtenido,
        input logic [31:0] esperado
    );
        if (obtenido == esperado)
            $display("PASS: %s | obtenido=%0d (0x%h)", nombre, obtenido, obtenido);
        else begin
            $display("FAIL: %s | esperado=%0d (0x%h) obtenido=%0d (0x%h)",
                     nombre, esperado, esperado, obtenido, obtenido);
        end
    endtask

    // =========================================================
    // PROGRAMA 1: MEMORIA + ALU + SHIFTS + COMPARACIONES
    // =========================================================
    task run_programa1;
        // Cargar programa 1
        $readmemh("programas/programa1.mem", dut.instr_mem.imem);

        // Inicializar datos de memoria para las instrucciones load
        dut.dm.mem[0] = 32'h0000007F;
        dut.dm.mem[1] = 32'h0000012C;
        dut.dm.mem[2] = 32'h12345000;
        dut.dm.mem[27] = 32'h12345000;

        // Reset
        rst = 1; #20; rst = 0;

        // Correr suficientes ciclos
        #400;

        $display("=== Programa 1: ALU + Memoria + Shifts + Comparaciones ===");

        // --- LOADS ---
        // lb x3, 0(x1): 127 con signo → 127
        check("lb  x3 (signed byte 127)",   dut.rf.regs[3],  32'd127);
        // lbu x4, 0(x1): 127 sin signo → 127
        check("lbu x4 (unsigned byte 127)", dut.rf.regs[4],  32'd127);
        // lh x5, 4(x1): 300 con signo → 300
        check("lh  x5 (signed half 300)",   dut.rf.regs[5],  32'd300);
        // lhu x6, 4(x1): 300 sin signo → 300
        check("lhu x6 (unsigned half 300)", dut.rf.regs[6],  32'd300);



        // lw x7, 8(x1): 0x12345000
        check("lw  x7 (word 0x12345000)",   dut.rf.regs[7],  32'h12345000);


        // --- ADD / SUB ---
        // add x10 = 10 + 3 = 13
        check("add x10 = 10+3",             dut.rf.regs[10], 32'd13);
        // sub x11 = 10 - 3 = 7
        check("sub x11 = 10-3",             dut.rf.regs[11], 32'd7);

        // --- LÓGICAS ---
        // xor x12 = 10 ^ 3 = 9
        check("xor  x12 = 10^3",            dut.rf.regs[12], 32'd9);
        // xori x13 = 10 ^ 5 = 15
        check("xori x13 = 10^5",            dut.rf.regs[13], 32'd15);
        // or x14 = 10 | 3 = 11
        check("or   x14 = 10|3",            dut.rf.regs[14], 32'd11);
        // ori x15 = 10 | 1 = 11
        check("ori  x15 = 10|1",            dut.rf.regs[15], 32'd11);
        // and x16 = 10 & 3 = 2
        check("and  x16 = 10&3",            dut.rf.regs[16], 32'd2);
        // andi x17 = 10 & 7 = 2
        check("andi x17 = 10&7",            dut.rf.regs[17], 32'd2);

        // --- SHIFTS ---
        // sll x18 = 3 << 3 = 24
        check("sll  x18 = 3<<3",            dut.rf.regs[18], 32'd24);
        // slli x19 = 3 << 2 = 12
        check("slli x19 = 3<<2",            dut.rf.regs[19], 32'd12);
        // srl x20 = 24 >> 3 = 3
        check("srl  x20 = 24>>3",           dut.rf.regs[20], 32'd3);
        // srli x21 = 24 >> 1 = 12
        check("srli x21 = 24>>1",           dut.rf.regs[21], 32'd12);
        // sra x23 = -16 >> 3 = -2 (con signo)
        check("sra  x23 = -16>>3",          dut.rf.regs[23], 32'hFFFFFFFE);
        // srai x24 = -16 >> 2 = -4
        check("srai x24 = -16>>2",          dut.rf.regs[24], 32'hFFFFFFFC);

        // --- COMPARACIONES ---
        // slt x25 = (3 < 10) = 1
        check("slt   x25 = 3<10",           dut.rf.regs[25], 32'd1);
        // slti x26 = (3 < 5) = 1
        check("slti  x26 = 3<5",            dut.rf.regs[26], 32'd1);
        // sltu x27 = (3 < 10) unsigned = 1
        check("sltu  x27 = 3<10 unsigned",  dut.rf.regs[27], 32'd1);
        // sltiu x28 = (3 < 20) unsigned = 1
        check("sltiu x28 = 3<20 unsigned",  dut.rf.regs[28], 32'd1);

    endtask

    // =========================================================
// PROGRAMA 2: BRANCHES + JUMPS
// =========================================================
task run_programa2;
    // Cargar programa 2
    $readmemh("programas/programa2.mem", dut.instr_mem.imem);

    // Reset
    rst = 1; #20; rst = 0;

    // Correr suficientes ciclos
    #300;

    $display("=== Programa 2: Branches + Jumps ===");

    // beq x1, x2 → tomado (x1=5, x2=5)
    check("beq tomado  → x10 != 111", dut.rf.regs[10], 32'd13);

    // bne x1, x3 → tomado (x1=5, x3=2)
    check("bne tomado  → x10 != 222", dut.rf.regs[10], 32'd13);

    // blt x3, x1 → tomado (2 < 5)
    check("blt tomado  → x10 != 333", dut.rf.regs[10], 32'd13);

    // bge x1, x3 → tomado (5 >= 2)
    check("bge tomado  → x10 != 444", dut.rf.regs[10], 32'd13);

    // jal tomado
    check("jal tomado  → x10 != 555", dut.rf.regs[10], 32'd13);

    // después del jal
    check("jal x6 = 99", dut.rf.regs[6], 32'd99);

    // jalr
    check("jalr x8 = 1", dut.rf.regs[8], 32'd1);

endtask

    // =========================================================
    // MAIN
    // =========================================================
    initial begin
        clk = 0;
        rst = 1;
        #10;

        $display("=========================================");
        $display("  Testbench completo RISC-V uniciclo");
        $display("=========================================");

        run_programa1();

        $display("");

        run_programa2();

        $display("");
        $display("=========================================");
        $display("  Fin de simulación");
        $display("=========================================");
        $finish;
    end

endmodule