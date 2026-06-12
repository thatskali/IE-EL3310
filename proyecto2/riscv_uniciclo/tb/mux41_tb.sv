// mux41_tb.sv
// verificar el mux de 3 entradas
module mux41_tb;

    // --- señales de prueba ---
    logic [1:0]  sel;
    logic [31:0] ina;
    logic [31:0] inb;
    logic [31:0] inc;
    logic [31:0] out;

    // --- instancia del módulo a probar ---
    mux41 dut (
        .sel (sel),
        .ina (ina),
        .inb (inb),
        .inc (inc),
        .out (out)
    );

    // --- pruebas ---
    initial begin
        $display("=== Pruebas mux41 ===");

        ina = 32'hAAAA_AAAA;
        inb = 32'hBBBB_BBBB;
        inc = 32'hCCCC_CCCC;

        // Prueba 1: sel=00 → debe salir ina
        sel = 2'b00;
        #10;
        if (out == ina)
            $display("PASS: sel=00 → sale ina = %h", out);
        else
            $display("FAIL: sel=00 → esperaba %h, salió %h", ina, out);

        // Prueba 2: sel=01 → debe salir inb
        sel = 2'b01;
        #10;
        if (out == inb)
            $display("PASS: sel=01 → sale inb = %h", out);
        else
            $display("FAIL: sel=01 → esperaba %h, salió %h", inb, out);

        // Prueba 3: sel=10 → debe salir inc
        sel = 2'b10;
        #10;
        if (out == inc)
            $display("PASS: sel=10 → sale inc = %h", out);
        else
            $display("FAIL: sel=10 → esperaba %h, salió %h", inc, out);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule