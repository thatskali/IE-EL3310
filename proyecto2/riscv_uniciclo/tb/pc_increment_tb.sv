// pc_increment_tb.sv
// verificar el bloque PC + 4 y selección de PCNext
module pc_increment_tb;

    // --- señales de prueba ---
    logic        clk;
    logic        rst;
    logic        PCSrc;
    logic [31:0] BranchTarget;
    logic [31:0] PC;
    logic [31:0] PCPlus4;

    // --- instancia del módulo a probar ---
    pc_increment dut (
        .clk          (clk),
        .rst          (rst),
        .PCSrc        (PCSrc),
        .BranchTarget (BranchTarget),
        .PC           (PC),
        .PCPlus4      (PCPlus4)
    );

    // --- generador de reloj ---
    always #5 clk = ~clk;

    // --- tarea para revisar resultados ---
    task check (
        input string       nombre,
        input logic [31:0] pc_esp,
        input logic [31:0] pcplus4_esp
    );
        if (PC == pc_esp && PCPlus4 == pcplus4_esp)
            $display("PASS: %s | PC=%h PCPlus4=%h", nombre, PC, PCPlus4);
        else begin
            $display("FAIL: %s", nombre);
            $display("  PC esperado=%h obtenido=%h", pc_esp, PC);
            $display("  PCPlus4 esperado=%h obtenido=%h", pcplus4_esp, PCPlus4);
        end
    endtask

    initial begin
        $display("=== Pruebas pc_increment ===");

        clk = 0;
        rst = 1;
        PCSrc = 0;
        BranchTarget = 32'h0000_0040;

        @(posedge clk); #1;
        check("reset", 32'h0000_0000, 32'h0000_0004);

        rst = 0;
        PCSrc = 0;
        @(posedge clk); #1;
        check("avance normal a PC+4", 32'h0000_0004, 32'h0000_0008);

        PCSrc = 0;
        @(posedge clk); #1;
        check("avance normal otra vez", 32'h0000_0008, 32'h0000_000C);

        PCSrc = 1;
        BranchTarget = 32'h0000_0040;
        @(posedge clk); #1;
        check("salto a BranchTarget", 32'h0000_0040, 32'h0000_0044);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
