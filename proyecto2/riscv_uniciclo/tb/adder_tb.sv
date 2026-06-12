// adder_tb.sv
// verificar el sumador de 32 bits
module adder_tb;

    // --- señales de prueba ---
    logic [31:0] in0;
    logic [31:0] in1;
    logic [31:0] out;

    // --- instancia del módulo a probar ---
    adder dut (
        .in0 (in0),
        .in1 (in1),
        .out (out)
    );

    // --- tarea para revisar resultados ---
    task check (
        input string       nombre,
        input logic [31:0] esperado
    );
        if (out == esperado)
            $display("PASS: %s | out=%h", nombre, out);
        else
            $display("FAIL: %s | esperado=%h obtenido=%h", nombre, esperado, out);
    endtask

    initial begin
        $display("=== Pruebas adder ===");

        in0 = 32'd0; in1 = 32'd4; #10;
        check("0 + 4", 32'd4);

        in0 = 32'd8; in1 = 32'd4; #10;
        check("8 + 4", 32'd12);

        in0 = 32'hFFFF_FFFF; in1 = 32'd1; #10;
        check("overflow modular", 32'h0000_0000);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
