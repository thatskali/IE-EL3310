
// Testbench para verificar la ALU completa
module alu_tb;

    // --- Señales de prueba ---
    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [3:0]  ALUControl;
    logic [31:0] ALUResult;
    logic        Zero;

    // --- Instancia del módulo a probar ---
    alu dut (
        .SrcA       (SrcA),
        .SrcB       (SrcB),
        .ALUControl (ALUControl),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

    // --- Tarea para verificar resultados ---
    task check (
        input string   nombre,
        input logic [31:0] esperado,
        input logic        zero_esp
    );
        if (ALUResult == esperado && Zero == zero_esp)
            $display("PASS: %s | resultado=%h zero=%b", nombre, ALUResult, Zero);
        else begin
            $display("FAIL: %s", nombre);
            $display("  esperado=%h obtenido=%h", esperado, ALUResult);
            $display("  zero esperado=%b obtenido=%b", zero_esp, Zero);
        end
    endtask

    initial begin
        $display("=== Pruebas ALU ===");

        // -------------------------------------------------
        // ADD (0000)
        // -------------------------------------------------
        SrcA = 32'd10; SrcB = 32'd20; ALUControl = 4'b0000; #10;
        check("add 10+20", 32'd30, 1'b0);

        SrcA = 32'd0; SrcB = 32'd0; ALUControl = 4'b0000; #10;
        check("add 0+0 (zero=1)", 32'd0, 1'b1);

        // -------------------------------------------------
        // SUBTRACT (0001)
        // -------------------------------------------------
        SrcA = 32'd30; SrcB = 32'd20; ALUControl = 4'b0001; #10;
        check("sub 30-20", 32'd10, 1'b0);

        SrcA = 32'd5; SrcB = 32'd5; ALUControl = 4'b0001; #10;
        check("sub 5-5 (zero=1, beq)", 32'd0, 1'b1);

        SrcA = 32'd3; SrcB = 32'd5; ALUControl = 4'b0001; #10;
        check("sub 3-5 (bne)", 32'hFFFFFFFE, 1'b0);

        // -------------------------------------------------
        // AND (0010)
        // -------------------------------------------------
        SrcA = 32'hFF00FF00; SrcB = 32'h0F0F0F0F; ALUControl = 4'b0010; #10;
        check("and", 32'h0F000F00, 1'b0);

        // -------------------------------------------------
        // OR (0011)
        // -------------------------------------------------
        SrcA = 32'hFF00FF00; SrcB = 32'h0F0F0F0F; ALUControl = 4'b0011; #10;
        check("or", 32'hFF0FFF0F, 1'b0);

        // -------------------------------------------------
        // SLL (0100)
        // -------------------------------------------------
        SrcA = 32'd1; SrcB = 32'd4; ALUControl = 4'b0100; #10;
        check("sll 1<<4", 32'd16, 1'b0);

        SrcA = 32'd1; SrcB = 32'd0; ALUControl = 4'b0100; #10;
        check("sll 1<<0", 32'd1, 1'b0);

        // -------------------------------------------------
        // SLT signed (0101)
        // -------------------------------------------------
        SrcA = 32'd3; SrcB = 32'd5; ALUControl = 4'b0101; #10;
        check("slt 3<5 (true)", 32'd1, 1'b0);

        SrcA = 32'd5; SrcB = 32'd3; ALUControl = 4'b0101; #10;
        check("slt 5<3 (false)", 32'd0, 1'b1);

        // negativo < positivo
        SrcA = 32'hFFFFFFFF; SrcB = 32'd1; ALUControl = 4'b0101; #10;
        check("slt -1<1 signed (true)", 32'd1, 1'b0);

        // -------------------------------------------------
        // SRL (0110)
        // -------------------------------------------------
        SrcA = 32'd16; SrcB = 32'd2; ALUControl = 4'b0110; #10;
        check("srl 16>>2", 32'd4, 1'b0);

        // shift lógico: no extiende signo
        SrcA = 32'hFFFFFFFF; SrcB = 32'd4; ALUControl = 4'b0110; #10;
        check("srl 0xFFFFFFFF>>4", 32'h0FFFFFFF, 1'b0);

        // -------------------------------------------------
        // SRA (0111)
        // -------------------------------------------------
        SrcA = 32'hFFFFFFFF; SrcB = 32'd4; ALUControl = 4'b0111; #10;
        check("sra -1>>4 (extiende signo)", 32'hFFFFFFFF, 1'b0);

        SrcA = 32'd16; SrcB = 32'd2; ALUControl = 4'b0111; #10;
        check("sra 16>>2", 32'd4, 1'b0);

        // -------------------------------------------------
        // XOR (1000)
        // -------------------------------------------------
        SrcA = 32'hFF00FF00; SrcB = 32'hFF00FF00; ALUControl = 4'b1000; #10;
        check("xor mismo valor (zero=1)", 32'd0, 1'b1);

        SrcA = 32'hFF00FF00; SrcB = 32'h0F0F0F0F; ALUControl = 4'b1000; #10;
        check("xor distintos", 32'hF00FF00F, 1'b0);

        // -------------------------------------------------
        // SLTU unsigned (1001)
        // -------------------------------------------------
        SrcA = 32'd3; SrcB = 32'd5; ALUControl = 4'b1001; #10;
        check("sltu 3<5 (true)", 32'd1, 1'b0);

        SrcA = 32'd5; SrcB = 32'd3; ALUControl = 4'b1001; #10;
        check("sltu 5<3 (false)", 32'd0, 1'b1);

        // unsigned: 0xFFFFFFFF es mayor que 1
        SrcA = 32'hFFFFFFFF; SrcB = 32'd1; ALUControl = 4'b1001; #10;
        check("sltu 0xFFFFFFFF<1 unsigned (false)", 32'd0, 1'b1);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule