module pipe_if_id_tb;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic        clk;
    logic        rst;
    logic        StallD;
    logic        FlushD;
    logic [31:0] PCF;
    logic [31:0] InstrF;
    logic [31:0] PCPlus4F;
    logic [31:0] PCD;
    logic [31:0] InstrD;
    logic [31:0] PCPlus4D;

    // =========================================================
    // INSTANCIA
    // =========================================================
    pipe_if_id dut (
        .clk      (clk),
        .rst      (rst),
        .StallD   (StallD),
        .FlushD   (FlushD),
        .PCF      (PCF),
        .InstrF   (InstrF),
        .PCPlus4F (PCPlus4F),
        .PCD      (PCD),
        .InstrD   (InstrD),
        .PCPlus4D (PCPlus4D)
    );

    // =========================================================
    // RELOJ
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk; // periodo de 10 unidades

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
        $display("  Testbench pipe_if_id");
        $display("=========================================");

        // inicializar señales
        rst = 1; StallD = 0; FlushD = 0;
        PCF = 0; InstrF = 0; PCPlus4F = 0;

        // -------------------------------------------------
        // CASO 1: Reset
        // -------------------------------------------------
        @(posedge clk); #1;
        rst = 0;
        PCF = 32'h00000004; InstrF = 32'hABCD1234; PCPlus4F = 32'h00000008;

        @(posedge clk); #1;
        $display("--- Caso 1: Reset ---");
        // después del reset todo debe ser 0
        rst = 1;
        @(posedge clk); #1;
        check("rst: PCD      = 0", PCD,      32'h0);
        check("rst: InstrD   = 0", InstrD,   32'h0);
        check("rst: PCPlus4D = 0", PCPlus4D, 32'h0);
        rst = 0;

        // -------------------------------------------------
        // CASO 2: Comportamiento normal — captura entradas
        // -------------------------------------------------
        $display("--- Caso 2: Normal ---");
        PCF = 32'h00000010; InstrF = 32'hDEADBEEF; PCPlus4F = 32'h00000014;
        StallD = 0; FlushD = 0;

        @(posedge clk); #1;
        check("normal: PCD      = PCF",      PCD,      32'h00000010);
        check("normal: InstrD   = InstrF",   InstrD,   32'hDEADBEEF);
        check("normal: PCPlus4D = PCPlus4F", PCPlus4D, 32'h00000014);

        // -------------------------------------------------
        // CASO 3: Stall — no actualiza
        // -------------------------------------------------
        $display("--- Caso 3: Stall ---");
        StallD = 1;
        PCF = 32'hFFFFFFFF; InstrF = 32'h11111111; PCPlus4F = 32'hEEEEEEEE;

        @(posedge clk); #1;
        // deben mantenerse los valores anteriores
        check("stall: PCD      sin cambio", PCD,      32'h00000010);
        check("stall: InstrD   sin cambio", InstrD,   32'hDEADBEEF);
        check("stall: PCPlus4D sin cambio", PCPlus4D, 32'h00000014);
        StallD = 0;

        // -------------------------------------------------
        // CASO 4: Flush — pone todo en 0
        // -------------------------------------------------
        $display("--- Caso 4: Flush ---");
        FlushD = 1;
        PCF = 32'h12345678; InstrF = 32'h87654321; PCPlus4F = 32'hAABBCCDD;

        @(posedge clk); #1;
        check("flush: PCD      = 0", PCD,      32'h0);
        check("flush: InstrD   = 0", InstrD,   32'h0);
        check("flush: PCPlus4D = 0", PCPlus4D, 32'h0);
        FlushD = 0;

        // -------------------------------------------------
        // CASO 5: Flush tiene prioridad sobre Stall
        // -------------------------------------------------
        $display("--- Caso 5: Flush + Stall simultaneos ---");
        // primero capturamos algo
        PCF = 32'h00000020; InstrF = 32'hCAFEBABE; PCPlus4F = 32'h00000024;
        @(posedge clk); #1;

        // ahora activamos ambos
        StallD = 1; FlushD = 1;
        PCF = 32'hFFFFFFFF; InstrF = 32'hFFFFFFFF; PCPlus4F = 32'hFFFFFFFF;
        @(posedge clk); #1;
        // flush gana → todo en 0
        check("flush+stall: PCD      = 0", PCD,      32'h0);
        check("flush+stall: InstrD   = 0", InstrD,   32'h0);
        check("flush+stall: PCPlus4D = 0", PCPlus4D, 32'h0);
        StallD = 0; FlushD = 0;

        $display("=========================================");
        $display("  Fin testbench pipe_if_id");
        $display("=========================================");
        $finish;
    end

endmodule