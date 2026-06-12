// pc_tb.sv
// verificar el registro PC
module pc_tb;

    // --- señales de prueba ---
    logic        clk;
    logic        rst;
    logic [31:0] PCNext;
    logic [31:0] PC;

    // --- instancia del módulo a probar ---
    pc dut (
        .clk    (clk),
        .rst    (rst),
        .PCNext (PCNext),
        .PC     (PC)
    );

    // --- generador de reloj ---
    always #5 clk = ~clk;

    // --- tarea para revisar resultados ---
    task check (
        input string       nombre,
        input logic [31:0] esperado
    );
        if (PC == esperado)
            $display("PASS: %s | PC=%h", nombre, PC);
        else
            $display("FAIL: %s | esperado=%h obtenido=%h", nombre, esperado, PC);
    endtask

    // --- pruebas ---
    initial begin
        $display("=== Pruebas PC ===");

        clk = 0;
        rst = 1;
        PCNext = 32'h0000_0010;

        // Con reset activo, PC debe ir a cero en el flanco
        @(posedge clk); #1;
        check("reset activo", 32'h0000_0000);

        // Sin reset, PC carga PCNext en el siguiente flanco
        rst = 0;
        PCNext = 32'h0000_0004;
        @(posedge clk); #1;
        check("PC carga 4", 32'h0000_0004);

        PCNext = 32'h0000_0020;
        @(posedge clk); #1;
        check("PC carga 32", 32'h0000_0020);

        // Reset nuevamente
        rst = 1;
        PCNext = 32'h0000_0040;
        @(posedge clk); #1;
        check("reset vuelve PC a cero", 32'h0000_0000);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
