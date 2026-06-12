// mux21_tb.sv
// verificar el mux de 2 entradas
module mux21_tb;

    // --- señales de prueba ---
    logic        sel;
    logic [31:0] ina;
    logic [31:0] inb;
    logic [31:0] out;

    // --- instancia del módulo a probar ---
    mux21 dut (
        .sel (sel),
        .ina (ina),
        .inb (inb),
        .out (out)
    );

    // --- pruebas ---
    initial begin
        $display("=== Pruebas mux21 ===");

        // Prueba 1: sel=0 → debe salir ina
        ina = 32'hAAAA_AAAA;
        inb = 32'hBBBB_BBBB;
        sel = 0;
        #10;
        if (out == ina)
            $display("PASS: sel=0 → sale ina = %h", out);
        else
            $display("FAIL: sel=0 → esperaba %h, salió %h", ina, out);

        // Prueba 2: sel=1 → debe salir inb
        sel = 1;
        #10;
        if (out == inb)
            $display("PASS: sel=1 → sale inb = %h", out);
        else
            $display("FAIL: sel=1 → esperaba %h, salió %h", inb, out);

        // Prueba 3: cambiar valores
        ina = 32'h0000_0001;
        inb = 32'h0000_0002;
        sel = 0;
        #10;
        if (out == 32'h0000_0001)
            $display("PASS: sel=0 → sale %h", out);
        else
            $display("FAIL: esperaba 00000001, salió %h", out);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule