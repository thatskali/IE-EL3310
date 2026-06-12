// instruction_mem_tb.sv
// verificar la memoria de instrucciones
module instruction_mem_tb;

    // --- señales de prueba ---
    logic [31:0] addr;
    logic [31:0] instr;

    // --- instancia del módulo a probar ---
    imem dut (
        .addr  (addr),
        .instr (instr)
    );

    // --- tarea para revisar resultados ---
    task check (
        input string       nombre,
        input logic [31:0] esperado
    );
        if (instr == esperado)
            $display("PASS: %s | instr=%h", nombre, instr);
        else
            $display("FAIL: %s | esperado=%h obtenido=%h", nombre, esperado, instr);
    endtask

    // --- pruebas ---
    initial begin
        $display("=== Pruebas instruction memory ===");

        // Se cargan valores directamente para no depender de un archivo .mem
        dut.imem[0] = 32'h0050_0093; // instrucción ejemplo en dirección 0
        dut.imem[1] = 32'h0030_8113; // instrucción ejemplo en dirección 4
        dut.imem[2] = 32'h0020_81B3; // instrucción ejemplo en dirección 8
        dut.imem[3] = 32'h0000_006F; // instrucción ejemplo en dirección 12

        // PC = 0 -> mem[0]
        addr = 32'd0; #10;
        check("addr=0 lee mem[0]", 32'h0050_0093);

        // PC = 4 -> mem[1]
        addr = 32'd4; #10;
        check("addr=4 lee mem[1]", 32'h0030_8113);

        // PC = 8 -> mem[2]
        addr = 32'd8; #10;
        check("addr=8 lee mem[2]", 32'h0020_81B3);

        // PC = 12 -> mem[3]
        addr = 32'd12; #10;
        check("addr=12 lee mem[3]", 32'h0000_006F);

        // Dirección no alineada: por addr >> 2 sigue leyendo mem[1]
        addr = 32'd5; #10;
        check("addr=5 también lee mem[1]", 32'h0030_8113);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
