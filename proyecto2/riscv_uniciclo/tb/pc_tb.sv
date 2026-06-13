// pc_tb.sv
// verificar el registro PC
module pc_tb;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic        clk;
    logic        rst;
    logic        StallF;
    logic [31:0] PCNext;
    logic [31:0] PC;

    // =========================================================
    // INSTANCIA
    // =========================================================
    pc dut (
        .clk    (clk),
        .rst    (rst),
        .StallF (StallF),
        .PCNext (PCNext),
        .PC     (PC)
    );

    // =========================================================
    // RELOJ
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================
    // TAREA DE VERIFICACIÓN
    // =========================================================
    task check;
        input string nombre;
        input logic [31:0] obtenido;
        input logic [31:0] esperado;
        if (obtenido === esperado)
            $display("PASS: %s | obtenido=0x%h", nombre, obtenido);
        else
            $display("FAIL: %s | esperado=0x%h obtenido=0x%h", nombre, esperado, obtenido);
    endtask

    // =========================================================
    // ESTÍMULOS
    // =========================================================
    initial begin
        $display("=========================================");
        $display("  Testbench PC con StallF");
        $display("=========================================");

        // inicializar
        rst = 1; StallF = 0; PCNext = 32'h0;

        // -------------------------------------------------
        // CASO 1: Reset
        // -------------------------------------------------
        @(posedge clk); #1;
        $display("--- Caso 1: Reset ---");
        check("rst: PC = 0", PC, 32'h0);
        rst = 0;

        // -------------------------------------------------
        // CASO 2: Comportamiento normal — PC avanza
        // -------------------------------------------------
        $display("--- Caso 2: Normal ---");
        PCNext = 32'h00000004;
        @(posedge clk); #1;
        check("normal: PC = 0x4", PC, 32'h00000004);

        PCNext = 32'h00000008;
        @(posedge clk); #1;
        check("normal: PC = 0x8", PC, 32'h00000008);

        PCNext = 32'h0000000C;
        @(posedge clk); #1;
        check("normal: PC = 0xC", PC, 32'h0000000C);

        // -------------------------------------------------
        // CASO 3: Stall — PC se congela
        // -------------------------------------------------
        $display("--- Caso 3: Stall ---");
        StallF = 1;
        PCNext = 32'hFFFFFFFF; // intenta avanzar pero no debe
        @(posedge clk); #1;
        check("stall: PC sigue en 0xC", PC, 32'h0000000C);

        PCNext = 32'hAAAAAAAA; // otro intento
        @(posedge clk); #1;
        check("stall: PC sigue en 0xC", PC, 32'h0000000C);
        StallF = 0;

        // -------------------------------------------------
        // CASO 4: Después del stall, PC vuelve a avanzar
        // -------------------------------------------------
        $display("--- Caso 4: Recuperacion tras stall ---");
        PCNext = 32'h00000010;
        @(posedge clk); #1;
        check("post-stall: PC = 0x10", PC, 32'h00000010);

        // -------------------------------------------------
        // CASO 5: Reset en medio de ejecucion
        // -------------------------------------------------
        $display("--- Caso 5: Reset en medio de ejecucion ---");
        PCNext = 32'h00000050;
        @(posedge clk); #1;
        check("antes reset: PC = 0x50", PC, 32'h00000050);

        rst = 1;
        @(posedge clk); #1;
        check("reset: PC = 0", PC, 32'h0);
        rst = 0;

        $display("=========================================");
        $display("  Fin testbench PC");
        $display("=========================================");
        $finish;
    end

endmodule