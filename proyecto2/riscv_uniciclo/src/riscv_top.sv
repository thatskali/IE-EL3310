// Módulo top del procesador RISC-V uniciclo
// Instancia y conecta todos los módulos del diseño
module riscv_top (
    input  logic clk,
    input  logic rst
);

    // =========================================================
    // CABLES INTERNOS
    // =========================================================

    // --- PC ---
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] pc_plus4;
    logic [31:0] pc_target;

    // --- Instruction Memory ---
    logic [31:0] instr;

    // --- Control Unit ---
    logic [1:0]  pc_src;
    logic [1:0]  result_src;
    logic        mem_write;
    logic [3:0]  alu_control;
    logic        alu_src;
    logic [2:0]  imm_src;
    logic        reg_write;
    logic [2:0]  load_type;
    logic [1:0]  store_type;

    // --- Register File ---
    logic [31:0] rd1;
    logic [31:0] rd2;
    logic [31:0] result;

    // --- Extend ---
    logic [31:0] imm_ext;

    // --- ALU ---
    logic [31:0] src_a;
    logic [31:0] src_b;
    logic [31:0] alu_result;
    logic        zero;

    // --- Data Memory ---
    logic [31:0] read_data;
    logic [31:0] write_data;
    logic [3:0]  byte_enable;

    // --- Load Unit ---
    logic [31:0] load_data;

    // =========================================================
    // LÓGICA COMBINACIONAL
    // =========================================================

    // PC + 4
    assign pc_plus4  = pc + 32'd4;

    // PC + imm (destino de branch y jal)
    assign pc_target = pc + imm_ext;

    // CAMBIO 1: src_a siempre es rd1, ya no hay caso especial para LUI
    assign src_a = rd1;

    // =========================================================
    // INSTANCIAS
    // =========================================================

    // --- PC ---
    pc pc_reg (
        .clk    (clk),
        .rst    (rst),
        .PCNext (pc_next),
        .PC     (pc)
    );

    // --- Instruction Memory ---
    imem instr_mem (
        .addr  (pc),
        .instr (instr)
    );

    // --- Control Unit ---
    control_unit ctrl (
        .op          (instr[6:0]),
        .funct3      (instr[14:12]),
        .funct7b5    (instr[30]),
        .zero        (zero),
        .alu_result0 (alu_result[0]),
        .pc_src      (pc_src),
        .result_src  (result_src),
        .mem_write   (mem_write),
        .alu_control (alu_control),
        .alu_src     (alu_src),
        .imm_src     (imm_src),
        .reg_write   (reg_write),
        .load_type   (load_type),
        .store_type  (store_type)
    );

    // --- Register File ---
    register_file rf (
        .clk (clk),
        .WE3 (reg_write),
        .A1  (instr[19:15]),
        .A2  (instr[24:20]),
        .A3  (instr[11:7]),
        .WD3 (result),
        .RD1 (rd1),
        .RD2 (rd2)
    );

    // --- Extend ---
    extend ext (
        .Instr  (instr[31:7]),
        .ImmSrc (imm_src),
        .ImmExt (imm_ext)
    );

    // --- MUX SrcB ---
    // 0 → RD2 (tipo R), 1 → inmediato (tipo I, S, B)
    mux21 mux_srcb (
        .sel (alu_src),
        .ina (rd2),
        .inb (imm_ext),
        .out (src_b)
    );

    // --- ALU ---
    alu alu_unit (
        .SrcA       (src_a),
        .SrcB       (src_b),
        .ALUControl (alu_control),
        .ALUResult  (alu_result),
        .Zero       (zero)
    );

    // --- Store Unit ---
    store_unit su (
        .rs2        (rd2),
        .ALUResult  (alu_result),
        .StoreType  (store_type),
        .WriteData  (write_data),
        .ByteEnable (byte_enable)
    );

    // --- Data Memory ---
    data_mem dm (
        .clk        (clk),
        .MemWrite   (mem_write),
        .ALUResult  (alu_result),
        .WriteData  (write_data),
        .ByteEnable (byte_enable),
        .ReadData   (read_data)
    );

    // --- Load Unit ---
    load_unit lu (
        .read_data  (read_data),
        .load_type  (load_type),
        .alu_result (alu_result),
        .load_data  (load_data)
    );

    // --- MUX Result (ResultSrc) ---
    // 00 → ALUResult, 01 → load_data, 10 → PCPlus4, 11 → ImmExt (LUI)
    mux41 mux_result (
        .sel (result_src),
        .ina (alu_result),
        .inb (load_data),
        .inc (pc_plus4),
        .ind (imm_ext),   // CAMBIO 2: conectar imm_ext como 4ta entrada
        .out (result)
    );

    // --- MUX PCNext (PCSrc) ---
    // 00 → PC+4, 01 → PCTarget (branch/jal), 10 → ALUResult (jalr)
    // CAMBIO 3: este mux NO necesita ind, pc_src nunca vale 11
    mux41 mux_pcnext (
        .sel (pc_src),
        .ina (pc_plus4),
        .inb (pc_target),
        .inc (alu_result),
        .ind (32'b0),     // no se usa, se amarra a 0
        .out (pc_next)
    );

endmodule