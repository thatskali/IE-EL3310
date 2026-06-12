// main_deco_tb.sv
// verificar el decodificador principal del control unit
module main_deco_tb;

    // --- señales de prueba ---
    logic [6:0] op;
    logic [2:0] funct3;

    logic       RegWrite;
    logic [2:0] ImmSrc;
    logic       ALUSrc;
    logic       MemWrite;
    logic [1:0] ResultSrc;
    logic       Branch;
    logic       Jump;
    logic [1:0] ALUOp;
    logic [2:0] LoadType;
    logic [1:0] StoreType;

    // --- instancia del módulo a probar ---
    main_deco dut (
        .op        (op),
        .funct3    (funct3),
        .RegWrite  (RegWrite),
        .ImmSrc    (ImmSrc),
        .ALUSrc    (ALUSrc),
        .MemWrite  (MemWrite),
        .ResultSrc (ResultSrc),
        .Branch    (Branch),
        .Jump      (Jump),
        .ALUOp     (ALUOp),
        .LoadType  (LoadType),
        .StoreType (StoreType)
    );

    // --- tarea para revisar señales principales ---
    task check_ctrl (
        input string       nombre,
        input logic        reg_esp,
        input logic [2:0]  imm_esp,
        input logic        alusrc_esp,
        input logic        mem_esp,
        input logic [1:0]  result_esp,
        input logic        branch_esp,
        input logic        jump_esp,
        input logic [1:0]  aluop_esp
    );
        if (RegWrite  == reg_esp    &&
            ImmSrc    == imm_esp    &&
            ALUSrc    == alusrc_esp &&
            MemWrite  == mem_esp    &&
            ResultSrc == result_esp &&
            Branch    == branch_esp &&
            Jump      == jump_esp   &&
            ALUOp     == aluop_esp)
            $display("PASS: %s", nombre);
        else begin
            $display("FAIL: %s", nombre);
            $display("  RegWrite esperado=%b obtenido=%b", reg_esp, RegWrite);
            $display("  ImmSrc    esperado=%b obtenido=%b", imm_esp, ImmSrc);
            $display("  ALUSrc    esperado=%b obtenido=%b", alusrc_esp, ALUSrc);
            $display("  MemWrite  esperado=%b obtenido=%b", mem_esp, MemWrite);
            $display("  ResultSrc esperado=%b obtenido=%b", result_esp, ResultSrc);
            $display("  Branch    esperado=%b obtenido=%b", branch_esp, Branch);
            $display("  Jump      esperado=%b obtenido=%b", jump_esp, Jump);
            $display("  ALUOp     esperado=%b obtenido=%b", aluop_esp, ALUOp);
        end
    endtask

    // --- tarea para revisar LoadType ---
    task check_load (
        input string      nombre,
        input logic [2:0] esperado
    );
        if (LoadType == esperado)
            $display("PASS: %s | LoadType=%b", nombre, LoadType);
        else
            $display("FAIL: %s | esperado=%b obtenido=%b", nombre, esperado, LoadType);
    endtask

    // --- tarea para revisar StoreType ---
    task check_store (
        input string      nombre,
        input logic [1:0] esperado
    );
        if (StoreType == esperado)
            $display("PASS: %s | StoreType=%b", nombre, StoreType);
        else
            $display("FAIL: %s | esperado=%b obtenido=%b", nombre, esperado, StoreType);
    endtask

    initial begin
        $display("=== Pruebas main_deco ===");

        // -------------------------------------------------
        // LOADS: lb, lh, lw, lbu, lhu
        // -------------------------------------------------
        op = 7'b0000011; funct3 = 3'b000; #10;
        check_ctrl("load lb", 1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        check_load("LoadType lb", 3'b000);

        op = 7'b0000011; funct3 = 3'b001; #10;
        check_ctrl("load lh", 1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        check_load("LoadType lh", 3'b001);

        op = 7'b0000011; funct3 = 3'b010; #10;
        check_ctrl("load lw", 1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        check_load("LoadType lw", 3'b010);

        op = 7'b0000011; funct3 = 3'b100; #10;
        check_ctrl("load lbu", 1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        check_load("LoadType lbu", 3'b100);

        op = 7'b0000011; funct3 = 3'b101; #10;
        check_ctrl("load lhu", 1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        check_load("LoadType lhu", 3'b101);

        // -------------------------------------------------
        // STORES: sb, sh, sw
        // -------------------------------------------------
        op = 7'b0100011; funct3 = 3'b000; #10;
        check_ctrl("store sb", 1'b0, 3'b001, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0, 2'b00);
        check_store("StoreType sb", 2'b00);

        op = 7'b0100011; funct3 = 3'b001; #10;
        check_ctrl("store sh", 1'b0, 3'b001, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0, 2'b00);
        check_store("StoreType sh", 2'b01);

        op = 7'b0100011; funct3 = 3'b010; #10;
        check_ctrl("store sw", 1'b0, 3'b001, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0, 2'b00);
        check_store("StoreType sw", 2'b10);

        // -------------------------------------------------
        // Tipo I aritmético/lógico
        // -------------------------------------------------
        op = 7'b0010011; funct3 = 3'b000; #10;
        check_ctrl("tipo I aritmetico", 1'b1, 3'b000, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10);

        // -------------------------------------------------
        // Tipo R
        // -------------------------------------------------
        op = 7'b0110011; funct3 = 3'b000; #10;
        check_ctrl("tipo R", 1'b1, 3'b000, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10);

        // -------------------------------------------------
        // Branch
        // -------------------------------------------------
        op = 7'b1100011; funct3 = 3'b000; #10;
        check_ctrl("branch", 1'b0, 3'b010, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 2'b01);

        // -------------------------------------------------
        // LUI
        // En este diseño el inmediato U pasa por la ALU con SrcA=0 en riscv_top,
        // por eso ResultSrc queda en 00.
        // -------------------------------------------------
        op = 7'b0110111; funct3 = 3'b000; #10;
        check_ctrl("lui", 1'b1, 3'b100, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00);

        // -------------------------------------------------
        // JAL
        // -------------------------------------------------
        op = 7'b1101111; funct3 = 3'b000; #10;
        check_ctrl("jal", 1'b1, 3'b011, 1'b0, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00);

        // -------------------------------------------------
        // JALR
        // -------------------------------------------------
        op = 7'b1100111; funct3 = 3'b000; #10;
        check_ctrl("jalr", 1'b1, 3'b000, 1'b1, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00);

        // -------------------------------------------------
        // Opcode inválido
        // -------------------------------------------------
        op = 7'b1111111; funct3 = 3'b000; #10;
        check_ctrl("opcode invalido", 1'b0, 3'b000, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00);

        $display("=== Fin de pruebas ===");
        $finish;
    end

endmodule
