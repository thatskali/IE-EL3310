module extend_tb;

    logic [31:7] Instr;
    logic [2:0]  ImmSrc;
    logic [31:0] ImmExt;

    extend dut (
        .Instr  (Instr),
        .ImmSrc (ImmSrc),
        .ImmExt (ImmExt)
    );

    task check (
        input string       nombre,
        input logic [31:0] esperado
    );
        if (ImmExt == esperado)
            $display("PASS: %s | ImmExt=%h", nombre, ImmExt);
        else begin
            $display("FAIL: %s", nombre);
            $display("  esperado=%h obtenido=%h", esperado, ImmExt);
        end
    endtask

    initial begin
        $display("=== Pruebas extend ===");

        // Tipo I positivo (5)
        Instr[31:20] = 12'b000000000101;
        ImmSrc = 3'b000; #10;
        check("Tipo I positivo (5)", 32'h00000005);

        // Tipo I negativo (-1)
        Instr[31:20] = 12'b111111111111;
        ImmSrc = 3'b000; #10;
        check("Tipo I negativo (-1)", 32'hFFFFFFFF);

        // Tipo S positivo (8)
        Instr[31:25] = 7'b0000000;
        Instr[11:7]  = 5'b01000;
        ImmSrc = 3'b001; #10;
        check("Tipo S positivo (8)", 32'h00000008);

        // Tipo S negativo (-4)
        Instr[31:25] = 7'b1111111;
        Instr[11:7]  = 5'b11100;
        ImmSrc = 3'b001; #10;
        check("Tipo S negativo (-4)", 32'hFFFFFFFC);

        // Tipo B positivo (8)
        Instr[31]    = 1'b0;
        Instr[7]     = 1'b0;
        Instr[30:25] = 6'b000000;
        Instr[11:8]  = 4'b0100;
        ImmSrc = 3'b010; #10;
        check("Tipo B positivo (8)", 32'h00000008);

        // Tipo B negativo (-8)
        Instr[31]    = 1'b1;
        Instr[7]     = 1'b1;
        Instr[30:25] = 6'b111111;
        Instr[11:8]  = 4'b1100;
        ImmSrc = 3'b010; #10;
        check("Tipo B negativo (-8)", 32'hFFFFFFF8);

        // Tipo J positivo (16)
        Instr[31]    = 1'b0;
        Instr[19:12] = 8'b00000000;
        Instr[20]    = 1'b0;
        Instr[30:21] = 10'b0000001000;
        ImmSrc = 3'b011; #10;
        check("Tipo J positivo (16)", 32'h00000010);

        // Tipo J negativo (-4)
        Instr[31]    = 1'b1;
        Instr[19:12] = 8'b11111111;
        Instr[20]    = 1'b1;
        Instr[30:21] = 10'b1111111110;
        ImmSrc = 3'b011; #10;
        check("Tipo J negativo (-4)", 32'hFFFFFFFC);

        // Tipo U
        Instr[31:12] = 20'h00001;
        ImmSrc = 3'b100; #10;
        check("Tipo U (0x00001000)", 32'h00001000);

        Instr[31:12] = 20'hABCDE;
        ImmSrc = 3'b100; #10;
        check("Tipo U (0xABCDE000)", 32'hABCDE000);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule