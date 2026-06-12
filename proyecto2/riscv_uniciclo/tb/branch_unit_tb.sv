
// Testbench para verificar la Branch Condition Unit
module branch_unit_tb;

    // --- Señales de prueba ---
    logic [2:0] funct3;
    logic       zero;
    logic       alu_result0;
    logic       branch_taken;

    // --- Instancia del módulo a probar ---
    branch_unit dut (
        .funct3      (funct3),
        .zero        (zero),
        .alu_result0 (alu_result0),
        .branch_taken(branch_taken)
    );

    // --- Tarea para verificar resultados ---
    task check (
        input string nombre,
        input logic  esperado
    );
        if (branch_taken == esperado)
            $display("PASS: %s | branch_taken=%b", nombre, branch_taken);
        else begin
            $display("FAIL: %s", nombre);
            $display("  esperado=%b obtenido=%b", esperado, branch_taken);
        end
    endtask

    initial begin
        $display("=== Pruebas branch_unit ===");

        // -------------------------------------------------
        // BEQ (funct3=000)
        // branch_taken = zero
        // -------------------------------------------------
        funct3 = 3'b000; zero = 1; alu_result0 = 0; #10;
        check("beq tomado (zero=1)", 1'b1);

        funct3 = 3'b000; zero = 0; alu_result0 = 0; #10;
        check("beq no tomado (zero=0)", 1'b0);

        // -------------------------------------------------
        // BNE (funct3=001)
        // branch_taken = ~zero
        // -------------------------------------------------
        funct3 = 3'b001; zero = 0; alu_result0 = 0; #10;
        check("bne tomado (zero=0)", 1'b1);

        funct3 = 3'b001; zero = 1; alu_result0 = 0; #10;
        check("bne no tomado (zero=1)", 1'b0);

        // -------------------------------------------------
        // BLT (funct3=100)
        // branch_taken = alu_result0
        // -------------------------------------------------
        funct3 = 3'b100; zero = 0; alu_result0 = 1; #10;
        check("blt tomado (alu_result0=1)", 1'b1);

        funct3 = 3'b100; zero = 0; alu_result0 = 0; #10;
        check("blt no tomado (alu_result0=0)", 1'b0);

        // -------------------------------------------------
        // BGE (funct3=101)
        // branch_taken = ~alu_result0
        // -------------------------------------------------
        funct3 = 3'b101; zero = 0; alu_result0 = 0; #10;
        check("bge tomado (alu_result0=0)", 1'b1);

        funct3 = 3'b101; zero = 0; alu_result0 = 1; #10;
        check("bge no tomado (alu_result0=1)", 1'b0);

        // -------------------------------------------------
        // Default
        // -------------------------------------------------
        funct3 = 3'b111; zero = 1; alu_result0 = 1; #10;
        check("default (branch_taken=0)", 1'b0);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule