
// Testbench para verificar la control unit completa
module control_unit_tb;

    // --- Señales de prueba ---
    logic [6:0] op;
    logic [2:0] funct3;
    logic       funct7b5;
    logic       zero;
    logic       alu_result0;

    // --- Señales de salida ---
    logic [1:0] pc_src;
    logic [1:0] result_src;
    logic       mem_write;
    logic [3:0] alu_control;
    logic       alu_src;
    logic [2:0] imm_src;
    logic       reg_write;

    // --- Instancia del módulo a probar ---
    control_unit dut (
        .op          (op),
        .funct3      (funct3),
        .funct7b5    (funct7b5),
        .zero        (zero),
        .alu_result0 (alu_result0),
        .pc_src      (pc_src),
        .result_src  (result_src),
        .mem_write   (mem_write),
        .alu_control (alu_control),
        .alu_src     (alu_src),
        .imm_src     (imm_src),
        .reg_write   (reg_write)
    );

    // --- Tarea para verificar ---
    task check (
        input string       nombre,
        input logic [1:0]  pc_src_esp,
        input logic        reg_write_esp,
        input logic        mem_write_esp,
        input logic        alu_src_esp,
        input logic [1:0]  result_src_esp,
        input logic [3:0]  alu_control_esp
    );
        if (pc_src      == pc_src_esp      &&
            reg_write   == reg_write_esp   &&
            mem_write   == mem_write_esp   &&
            alu_src     == alu_src_esp     &&
            result_src  == result_src_esp  &&
            alu_control == alu_control_esp)
            $display("PASS: %s", nombre);
        else begin
            $display("FAIL: %s", nombre);
            $display("  pc_src:      esperado=%b obtenido=%b", pc_src_esp,      pc_src);
            $display("  reg_write:   esperado=%b obtenido=%b", reg_write_esp,   reg_write);
            $display("  mem_write:   esperado=%b obtenido=%b", mem_write_esp,   mem_write);
            $display("  alu_src:     esperado=%b obtenido=%b", alu_src_esp,     alu_src);
            $display("  result_src:  esperado=%b obtenido=%b", result_src_esp,  result_src);
            $display("  alu_control: esperado=%b obtenido=%b", alu_control_esp, alu_control);
        end
    endtask

    initial begin
        $display("=== Pruebas control_unit ===");

        // -------------------------------------------------
        // lw
        // -------------------------------------------------
        op = 7'b0000011; funct3 = 3'b010;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("lw",
            2'b00,    // pc_src
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b1,     // alu_src
            2'b01,    // result_src
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // sw
        // -------------------------------------------------
        op = 7'b0100011; funct3 = 3'b010;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("sw",
            2'b00,    // pc_src
            1'b0,     // reg_write
            1'b1,     // mem_write
            1'b1,     // alu_src
            2'b00,    // result_src
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // add (R-type)
        // -------------------------------------------------
        op = 7'b0110011; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("add R-type",
            2'b00,    // pc_src
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // sub (R-type)
        // -------------------------------------------------
        op = 7'b0110011; funct3 = 3'b000;
        funct7b5 = 1; zero = 0; alu_result0 = 0; #10;
        check("sub R-type",
            2'b00,    // pc_src
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0001   // alu_control: subtract
        );

        // -------------------------------------------------
        // addi (I-type ALU)
        // -------------------------------------------------
        op = 7'b0010011; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("addi I-type",
            2'b00,    // pc_src
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b1,     // alu_src
            2'b00,    // result_src
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // beq tomado (zero=1)
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b000;
        funct7b5 = 0; zero = 1; alu_result0 = 0; #10;
        check("beq tomado",
            2'b01,    // pc_src → PCTarget
            1'b0,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0001   // alu_control: subtract
        );

        // -------------------------------------------------
        // beq no tomado (zero=0)
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("beq no tomado",
            2'b00,    // pc_src → PC+4
            1'b0,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0001   // alu_control: subtract
        );

        // -------------------------------------------------
        // bne tomado (zero=0)
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b001;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("bne tomado",
            2'b01,    // pc_src → PCTarget
            1'b0,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0001   // alu_control: subtract
        );

        // -------------------------------------------------
        // blt tomado (alu_result0=1)
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b100;
        funct7b5 = 0; zero = 0; alu_result0 = 1; #10;
        check("blt tomado",
            2'b01,    // pc_src → PCTarget
            1'b0,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0101   // alu_control: slt
        );

        // -------------------------------------------------
        // bge tomado (alu_result0=0)
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b101;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("bge tomado",
            2'b01,    // pc_src → PCTarget
            1'b0,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b00,    // result_src
            4'b0101   // alu_control: slt
        );

        // -------------------------------------------------
        // jal
        // -------------------------------------------------
        op = 7'b1101111; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("jal",
            2'b01,    // pc_src → PCTarget
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b0,     // alu_src
            2'b10,    // result_src → PCPlus4
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // jalr
        // -------------------------------------------------
        op = 7'b1100111; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("jalr",
            2'b10,    // pc_src → ALUResult
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b1,     // alu_src
            2'b10,    // result_src → PCPlus4
            4'b0000   // alu_control: add
        );

        // -------------------------------------------------
        // lui
        // -------------------------------------------------
        op = 7'b0110111; funct3 = 3'b000;
        funct7b5 = 0; zero = 0; alu_result0 = 0; #10;
        check("lui",
            2'b00,    // pc_src
            1'b1,     // reg_write
            1'b0,     // mem_write
            1'b1,     // alu_src
            2'b11,    // result_src
            4'b0000   // alu_control: add
        );

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule