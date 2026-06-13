module riscv_pipeline (
    input logic clk,
    input logic rst
);

    // =========================
    // FETCH
    // =========================
    logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;

    // =========================
    // DECODE
    // =========================
    logic [31:0] PCD, InstrD, PCPlus4D;
    logic [31:0] RD1D, RD2D, ImmExtD;
    logic [4:0]  Rs1D, Rs2D, RdD;
    logic [2:0]  funct3D;
    logic        RegWriteD, MemWriteD, ALUSrcD;
    logic        BranchD, JumpD;
    logic [1:0]  ResultSrcD, ALUOpD;
    logic [2:0]  ImmSrcD, LoadTypeD;
    logic [1:0]  StoreTypeD;
    logic [3:0]  ALUControlD;

    // =========================
    // EXECUTE
    // =========================
    logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
    logic [31:0] SrcAE, SrcBE, WriteDataE;
    logic [31:0] ALUResultE, PCTargetE, PCJalrE;
    logic [4:0]  Rs1E, Rs2E, RdE;
    logic [2:0]  funct3E;
    logic        RegWriteE, MemWriteE, ALUSrcE;
    logic        BranchE, JumpE;
    logic [1:0]  ResultSrcE, ALUOpE;
    logic [2:0]  LoadTypeE;
    logic [1:0]  StoreTypeE;
    logic [3:0]  ALUControlE;
    logic        ZeroE, BranchTakenE;
    logic [1:0]  PCSrcE;
    logic [3:0]  ByteEnableE;

    // =========================
    // MEMORY
    // =========================
    logic [31:0] ALUResultM, WriteDataM, ReadDataM, PCPlus4M;
    logic [4:0]  RdM;
    logic        RegWriteM, MemWriteM;
    logic [1:0]  ResultSrcM;
    logic [2:0]  LoadTypeM;
    logic [1:0]  StoreTypeM;
    logic [3:0]  ByteEnableM;

    // =========================
    // WRITEBACK
    // =========================
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [31:0] LoadDataW, ResultW;
    logic [4:0]  RdW;
    logic        RegWriteW;
    logic [1:0]  ResultSrcW;
    logic [2:0]  LoadTypeW;

    // =========================
    // HAZARD UNIT
    // =========================
    logic StallF, StallD, FlushD, FlushE;
    logic [1:0] ForwardAE, ForwardBE;

    // =========================
    // FETCH STAGE
    // =========================
    pc pc_reg (
        .clk    (clk),
        .rst    (rst),
        .StallF (StallF),
        .PCNext (PCNextF),
        .PC     (PCF)
    );

    assign PCPlus4F = PCF + 32'd4;

    imem instr_mem (
        .addr  (PCF),
        .instr (InstrF)
    );

    always_comb begin
        case (PCSrcE)
            2'b00: PCNextF = PCPlus4F;
            2'b01: PCNextF = PCTargetE;
            2'b10: PCNextF = PCJalrE;
            default: PCNextF = PCPlus4F;
        endcase
    end

    // =========================
    // IF / ID REGISTER
    // =========================
    pipe_if_id if_id_reg (
        .clk      (clk),
        .rst      (rst),
        .StallD   (StallD),
        .FlushD   (FlushD),
        .PCF      (PCF),
        .InstrF   (InstrF),
        .PCPlus4F (PCPlus4F),
        .PCD      (PCD),
        .InstrD   (InstrD),
        .PCPlus4D (PCPlus4D)
    );

    // =========================
    // DECODE STAGE
    // =========================
    assign Rs1D    = InstrD[19:15];
    assign Rs2D    = InstrD[24:20];
    assign RdD     = InstrD[11:7];
    assign funct3D = InstrD[14:12];

    main_deco main_decoder (
        .op        (InstrD[6:0]),
        .funct3    (InstrD[14:12]),
        .RegWrite  (RegWriteD),
        .ImmSrc    (ImmSrcD),
        .ALUSrc    (ALUSrcD),
        .MemWrite  (MemWriteD),
        .ResultSrc (ResultSrcD),
        .Branch    (BranchD),
        .Jump      (JumpD),
        .ALUOp     (ALUOpD),
        .LoadType  (LoadTypeD),
        .StoreType (StoreTypeD)
    );

    alu_deco alu_decoder (
        .opb5       (InstrD[5]),
        .funct3     (InstrD[14:12]),
        .funct7b5   (InstrD[30]),
        .ALUOp      (ALUOpD),
        .ALUControl (ALUControlD)
    );

    register_file rf (
        .clk (clk),
        .WE3 (RegWriteW),
        .A1  (Rs1D),
        .A2  (Rs2D),
        .A3  (RdW),
        .WD3 (ResultW),
        .RD1 (RD1D),
        .RD2 (RD2D)
    );

    extend ext (
        .Instr  (InstrD[31:7]),
        .ImmSrc (ImmSrcD),
        .ImmExt (ImmExtD)
    );

    // =========================
    // ID / EX REGISTER
    // =========================
    pipe_id_ex id_ex_reg (
        .clk         (clk),
        .rst         (rst),
        .FlushE      (FlushE),

        .RegWriteD   (RegWriteD),
        .MemWriteD   (MemWriteD),
        .ALUSrcD     (ALUSrcD),
        .JumpD       (JumpD),
        .BranchD     (BranchD),
        .ResultSrcD  (ResultSrcD),
        .ALUOpD      (ALUOpD),
        .ALUControlD (ALUControlD),
        .LoadTypeD   (LoadTypeD),
        .StoreTypeD  (StoreTypeD),

        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmExtD),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .funct3D     (funct3D),

        .RegWriteE   (RegWriteE),
        .MemWriteE   (MemWriteE),
        .ALUSrcE     (ALUSrcE),
        .JumpE       (JumpE),
        .BranchE     (BranchE),
        .ResultSrcE  (ResultSrcE),
        .ALUOpE      (ALUOpE),
        .ALUControlE (ALUControlE),
        .LoadTypeE   (LoadTypeE),
        .StoreTypeE  (StoreTypeE),

        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .PCE         (PCE),
        .PCPlus4E    (PCPlus4E),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdE         (RdE),
        .funct3E     (funct3E)
    );

    // =========================
    // EXECUTE STAGE
    // =========================

    always_comb begin
        if (ResultSrcE == 2'b11) begin
            SrcAE = 32'b0;   // LUI: 0 + inmediato U
        end else begin
            case (ForwardAE)
                2'b00: SrcAE = RD1E;
                2'b10: SrcAE = ALUResultM;
                2'b01: SrcAE = ResultW;
                default: SrcAE = RD1E;
            endcase
        end
    end

    always_comb begin
        case (ForwardBE)
            2'b00: WriteDataE = RD2E;
            2'b10: WriteDataE = ALUResultM;
            2'b01: WriteDataE = ResultW;
            default: WriteDataE = RD2E;
        endcase
    end

    assign SrcBE = (ALUSrcE) ? ImmExtE : WriteDataE;

    alu alu_exec (
        .SrcA       (SrcAE),
        .SrcB       (SrcBE),
        .ALUControl (ALUControlE),
        .ALUResult  (ALUResultE),
        .Zero       (ZeroE)
    );

    branch_unit branch_cond (
        .funct3       (funct3E),
        .zero         (ZeroE),
        .alu_result0  (ALUResultE[0]),
        .branch_taken (BranchTakenE)
    );

    assign PCTargetE = PCE + ImmExtE;
    assign PCJalrE   = (SrcAE + ImmExtE) & 32'hFFFF_FFFE;

    always_comb begin
        if (JumpE && ResultSrcE == 2'b10 && ALUSrcE)
            PCSrcE = 2'b10;              // jalr
        else if (JumpE)
            PCSrcE = 2'b01;              // jal
        else if (BranchE && BranchTakenE)
            PCSrcE = 2'b01;              // branch tomado
        else
            PCSrcE = 2'b00;
    end
    

    logic [31:0] StoreWriteDataE;

    store_unit store_unit_exec (
        .rs2        (WriteDataE),
        .ALUResult  (ALUResultE),
        .StoreType  (StoreTypeE),
        .WriteData  (StoreWriteDataE),
        .ByteEnable (ByteEnableE)
    );

    // =========================
    // EX / MEM REGISTER
    // =========================
    pipe_ex_mem ex_mem_reg (
        .clk         (clk),
        .rst         (rst),

        .RegWriteE   (RegWriteE),
        .MemWriteE   (MemWriteE),
        .ResultSrcE  (ResultSrcE),
        .LoadTypeE   (LoadTypeE),
        .StoreTypeE  (StoreTypeE),

        .ALUResultE  (ALUResultE),
        .WriteDataE  (StoreWriteDataE),
        .ByteEnableE (ByteEnableE),
        .PCPlus4E    (PCPlus4E),
        .RdE         (RdE),

        .RegWriteM   (RegWriteM),
        .MemWriteM   (MemWriteM),
        .ResultSrcM  (ResultSrcM),
        .LoadTypeM   (LoadTypeM),
        .StoreTypeM  (StoreTypeM),

        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .ByteEnableM (ByteEnableM),
        .PCPlus4M    (PCPlus4M),
        .RdM         (RdM)
    );

    // =========================
    // MEMORY STAGE
    // =========================
    data_mem data_memory (
        .clk        (clk),
        .MemWrite   (MemWriteM),
        .ALUResult  (ALUResultM),
        .WriteData  (WriteDataM),
        .ByteEnable (ByteEnableM),
        .ReadData   (ReadDataM)
    );

    // =========================
    // MEM / WB REGISTER
    // =========================
    pipe_mem_wb mem_wb_reg (
        .clk        (clk),
        .rst        (rst),

        .RegWriteM  (RegWriteM),
        .ResultSrcM (ResultSrcM),
        .LoadTypeM  (LoadTypeM),

        .ALUResultM (ALUResultM),
        .ReadDataM  (ReadDataM),
        .PCPlus4M   (PCPlus4M),
        .RdM        (RdM),

        .RegWriteW  (RegWriteW),
        .ResultSrcW (ResultSrcW),
        .LoadTypeW  (LoadTypeW),

        .ALUResultW (ALUResultW),
        .ReadDataW  (ReadDataW),
        .PCPlus4W   (PCPlus4W),
        .RdW        (RdW)
    );

    // =========================
    // WRITEBACK STAGE
    // =========================
    load_unit load_u (
        .read_data  (ReadDataW),
        .load_type  (LoadTypeW),
        .alu_result  (ALUResultW),
        .load_data  (LoadDataW)
    );

    always_comb begin
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = LoadDataW;
            2'b10: ResultW = PCPlus4W;
            2'b11: ResultW = ALUResultW;
            default: ResultW = ALUResultW;
        endcase
    end

    // =========================
    // HAZARD UNIT
    // =========================
    hazard_unit hz (
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdE         (RdE),
        .RdM         (RdM),
        .RegWriteM   (RegWriteM),
        .RdW         (RdW),
        .RegWriteW   (RegWriteW),
        .ResultSrcE0 (ResultSrcE[0]),
        .PCSrcE      (PCSrcE != 2'b00),
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE),
        .StallF      (StallF),
        .StallD      (StallD),
        .FlushD      (FlushD),
        .FlushE      (FlushE)
    );

endmodule