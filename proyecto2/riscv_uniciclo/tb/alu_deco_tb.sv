// alu_deco_tb.sv
// verificar el decodificador de la ALU
module alu_deco_tb;

    // --- señales de prueba ---
    logic       opb5;
    logic [2:0] funct3;
    logic       funct7b5;
    logic [1:0] ALUOp;
    logic [3:0] ALUControl;

    // --- instancia del módulo a probar ---
    alu_deco dut (
        .opb5       (opb5),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .ALUOp      (ALUOp),
        .ALUControl (ALUControl)
    );

    // --- tarea para revisar resultados ---
    task check (
        input string      nombre,
        input logic [3:0] esperado
    );
        if (ALUControl == esperado)
            $display("PASS: %s | ALUControl=%b", nombre, ALUControl);
        else
            $display("FAIL: %s | esperado=%b obtenido=%b", nombre, esperado, ALUControl);
    endtask

    initial begin
        $display("=== Pruebas alu_deco ===");

        // -------------------------------------------------
        // ALUOp = 00 -> add para loads/stores/jalr
        // -------------------------------------------------
        ALUOp = 2'b00; funct3 = 3'b000; funct7b5 = 1'b0; opb5 = 1'b0; #10;
        check("ALUOp 00 usa add", 4'b0000);

        // -------------------------------------------------
        // ALUOp = 01 -> branches
        // -------------------------------------------------
        ALUOp = 2'b01; funct7b5 = 1'b0; opb5 = 1'b1;

        funct3 = 3'b000; #10;
        check("beq usa sub", 4'b0001);

        funct3 = 3'b001; #10;
        check("bne usa sub", 4'b0001);

        funct3 = 3'b100; #10;
        check("blt usa slt", 4'b0101);

        funct3 = 3'b101; #10;
        check("bge usa slt", 4'b0101);

        // -------------------------------------------------
        // ALUOp = 10 -> tipo R/I aritmético y lógico
        // -------------------------------------------------
        ALUOp = 2'b10;

        // addi: opb5=0, aunque funct7b5=1 no debe ser sub
        opb5 = 1'b0; funct7b5 = 1'b1; funct3 = 3'b000; #10;
        check("addi usa add", 4'b0000);

        // add: opb5=1, funct7b5=0
        opb5 = 1'b1; funct7b5 = 1'b0; funct3 = 3'b000; #10;
        check("add usa add", 4'b0000);

        // sub: opb5=1, funct7b5=1
        opb5 = 1'b1; funct7b5 = 1'b1; funct3 = 3'b000; #10;
        check("sub usa sub", 4'b0001);

        funct3 = 3'b001; funct7b5 = 1'b0; #10;
        check("sll/slli", 4'b0100);

        funct3 = 3'b010; funct7b5 = 1'b0; #10;
        check("slt/slti", 4'b0101);

        funct3 = 3'b011; funct7b5 = 1'b0; #10;
        check("sltu/sltiu", 4'b1001);

        funct3 = 3'b100; funct7b5 = 1'b0; #10;
        check("xor/xori", 4'b1000);

        funct3 = 3'b101; funct7b5 = 1'b0; #10;
        check("srl/srli", 4'b0110);

        funct3 = 3'b101; funct7b5 = 1'b1; #10;
        check("sra/srai", 4'b0111);

        funct3 = 3'b110; funct7b5 = 1'b0; #10;
        check("or/ori", 4'b0011);

        funct3 = 3'b111; funct7b5 = 1'b0; #10;
        check("and/andi", 4'b0010);

        // -------------------------------------------------
        // Default
        // -------------------------------------------------
        ALUOp = 2'b11; funct3 = 3'b000; funct7b5 = 1'b0; opb5 = 1'b0; #10;
        check("ALUOp invalido usa add por defecto", 4'b0000);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
