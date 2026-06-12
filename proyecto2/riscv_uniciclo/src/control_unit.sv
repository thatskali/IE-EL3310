module control_unit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero,
    input  logic       alu_result0,
    output logic [1:0] pc_src,
    output logic [1:0] result_src,
    output logic       mem_write,
    output logic [3:0] alu_control,
    output logic       alu_src,
    output logic [2:0] imm_src,
    output logic       reg_write,
    output logic [2:0] load_type,   // ← nuevo
    output logic [1:0] store_type   // ← nuevo
);

    // --- Señales internas ---
    logic       branch;
    logic       jump;
    logic [1:0] alu_op;
    logic       branch_taken;

    // --- Instancia: Main Decoder ---
    main_deco main_decoder (
        .op        (op),
        .funct3    (funct3),
        .RegWrite  (reg_write),
        .ImmSrc    (imm_src),
        .ALUSrc    (alu_src),
        .MemWrite  (mem_write),
        .ResultSrc (result_src),
        .Branch    (branch),
        .Jump      (jump),
        .ALUOp     (alu_op),
        .LoadType  (load_type),   // ← nuevo
        .StoreType (store_type)   // ← nuevo
    );

    // --- Instancia: ALU Decoder ---
    alu_deco alu_decoder (
        .opb5       (op[5]),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .ALUOp      (alu_op),
        .ALUControl (alu_control)
    );

    // --- Instancia: Branch Condition Unit ---
    branch_unit branch_cond (
        .funct3      (funct3),
        .zero        (zero),
        .alu_result0 (alu_result0),
        .branch_taken(branch_taken)
    );

    // --- Lógica PCSrc ---
    always_comb begin
        if (jump & ~op[3])              // jalr
            pc_src = 2'b10;
        else if (jump & op[3])          // jal
            pc_src = 2'b01;
        else if (branch & branch_taken) // branch tomado
            pc_src = 2'b01;
        else
            pc_src = 2'b00;             // flujo normal
    end

endmodule