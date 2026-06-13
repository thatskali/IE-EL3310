module pipe_id_ex_tb;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic        clk;
    logic        rst;
    logic        FlushE;

    // señales de control entradas
    logic        RegWriteD;
    logic        MemWriteD;
    logic        ALUSrcD;
    logic        JumpD;
    logic        BranchD;
    logic [1:0]  ResultSrcD;
    logic [1:0]  ALUOpD;
    logic [3:0]  ALUControlD;
    logic [2:0]  LoadTypeD;
    logic [1:0]  StoreTypeD;

    // datos entradas
    logic [31:0] RD1D;
    logic [31:0] RD2D;
    logic [31:0] ImmExtD;
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic [4:0]  Rs1D;
    logic [4:0]  Rs2D;
    logic [4:0]  RdD;

    // señales de control salidas
    logic        RegWriteE;
    logic        MemWriteE;
    logic        ALUSrcE;
    logic        JumpE;
    logic        BranchE;
    logic [1:0]  ResultSrcE;
    logic [1:0]  ALUOpE;
    logic [3:0]  ALUControlE;
    logic [2:0]  LoadTypeE;
    logic [1:0]  StoreTypeE;

    // datos salidas
    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] ImmExtE;
    logic [31:0] PCE;
    logic [31:0] PCPlus4E;
    logic [4:0]  Rs1E;
    logic [4:0]  Rs2E;
    logic [4:0]  RdE;

    // =========================================================
    // INSTANCIA
    // =========================================================
    pipe_id_ex dut (
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
        .RdE         (RdE)
    );

    // =========================================================
    // RELOJ
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================
    // TAREA DE VERIFICACIÓN
    // =========================================================
    task check;
        input string nombre;
        input logic [31:0] obtenido;
        input logic [31:0] esperado;
        if (obtenido === esperado)
            $display("PASS: %s | obtenido=0x%h", nombre, obtenido);
        else
            $display("FAIL: %s | esperado=0x%h obtenido=0x%h", nombre, esperado, obtenido);
    endtask

    // tarea para poner todas las entradas con valores de prueba
    task set_inputs;
        RegWriteD   = 1;
        MemWriteD   = 0;
        ALUSrcD     = 1;
        JumpD       = 0;
        BranchD     = 0;
        ResultSrcD  = 2'b00;
        ALUOpD      = 2'b10;
        ALUControlD = 4'b0000;
        LoadTypeD   = 3'b010;
        StoreTypeD  = 2'b10;
        RD1D        = 32'hAAAAAAAA;
        RD2D        = 32'hBBBBBBBB;
        ImmExtD     = 32'h00000004;
        PCD         = 32'h00000008;
        PCPlus4D    = 32'h0000000C;
        Rs1D        = 5'd5;
        Rs2D        = 5'd6;
        RdD         = 5'd7;
    endtask

    // =========================================================
    // ESTÍMULOS
    // =========================================================
    initial begin
        $display("=========================================");
        $display("  Testbench pipe_id_ex");
        $display("=========================================");

        // inicializar
        rst = 1; FlushE = 0;
        RegWriteD = 0; MemWriteD = 0; ALUSrcD = 0;
        JumpD = 0; BranchD = 0; ResultSrcD = 0;
        ALUOpD = 0; ALUControlD = 0; LoadTypeD = 0;
        StoreTypeD = 0; RD1D = 0; RD2D = 0;
        ImmExtD = 0; PCD = 0; PCPlus4D = 0;
        Rs1D = 0; Rs2D = 0; RdD = 0;

        // -------------------------------------------------
        // CASO 1: Reset
        // -------------------------------------------------
        @(posedge clk); #1;
        rst = 0;
        set_inputs();
        @(posedge clk); #1;
        rst = 1;
        @(posedge clk); #1;
        $display("--- Caso 1: Reset ---");
        check("rst: RegWriteE  = 0", {31'b0, RegWriteE},  32'h0);
        check("rst: MemWriteE  = 0", {31'b0, MemWriteE},  32'h0);
        check("rst: ResultSrcE = 0", {30'b0, ResultSrcE}, 32'h0);
        check("rst: RD1E       = 0", RD1E,                32'h0);
        check("rst: RdE        = 0", {27'b0, RdE},        32'h0);
        rst = 0;

        // -------------------------------------------------
        // CASO 2: Comportamiento normal — captura entradas
        // -------------------------------------------------
        $display("--- Caso 2: Normal ---");
        set_inputs();
        FlushE = 0;
        @(posedge clk); #1;
        check("normal: RegWriteE",   {31'b0, RegWriteE},   32'h1);
        check("normal: ALUSrcE",     {31'b0, ALUSrcE},     32'h1);
        check("normal: ResultSrcE",  {30'b0, ResultSrcE},  32'h0);
        check("normal: ALUControlE", {28'b0, ALUControlE}, 32'h0);
        check("normal: RD1E",        RD1E,                 32'hAAAAAAAA);
        check("normal: RD2E",        RD2E,                 32'hBBBBBBBB);
        check("normal: ImmExtE",     ImmExtE,              32'h00000004);
        check("normal: PCE",         PCE,                  32'h00000008);
        check("normal: PCPlus4E",    PCPlus4E,             32'h0000000C);
        check("normal: Rs1E",        {27'b0, Rs1E},        32'd5);
        check("normal: Rs2E",        {27'b0, Rs2E},        32'd6);
        check("normal: RdE",         {27'b0, RdE},         32'd7);

        // -------------------------------------------------
        // CASO 3: Flush — pone todo en 0 (burbuja NOP)
        // -------------------------------------------------
        $display("--- Caso 3: Flush ---");
        FlushE = 1;
        set_inputs();
        @(posedge clk); #1;
        check("flush: RegWriteE  = 0", {31'b0, RegWriteE},  32'h0);
        check("flush: MemWriteE  = 0", {31'b0, MemWriteE},  32'h0);
        check("flush: ResultSrcE = 0", {30'b0, ResultSrcE}, 32'h0);
        check("flush: ALUSrcE    = 0", {31'b0, ALUSrcE},    32'h0);
        check("flush: JumpE      = 0", {31'b0, JumpE},      32'h0);
        check("flush: BranchE    = 0", {31'b0, BranchE},    32'h0);
        check("flush: RD1E       = 0", RD1E,                32'h0);
        check("flush: RD2E       = 0", RD2E,                32'h0);
        check("flush: RdE        = 0", {27'b0, RdE},        32'h0);
        FlushE = 0;

        // -------------------------------------------------
        // CASO 4: Instrucción tipo lw
        // -------------------------------------------------
        $display("--- Caso 4: Instruccion lw ---");
        RegWriteD   = 1;
        MemWriteD   = 0;
        ALUSrcD     = 1;
        ResultSrcD  = 2'b01;   // load_data → registro
        ALUOpD      = 2'b00;
        ALUControlD = 4'b0000; // ADD para calcular dirección
        LoadTypeD   = 3'b010;  // lw
        StoreTypeD  = 2'b10;
        RD1D        = 32'h00000064; // base = 100
        ImmExtD     = 32'h00000028; // offset = 40
        RdD         = 5'd7;
        FlushE      = 0;
        @(posedge clk); #1;
        check("lw: ResultSrcE = 01", {30'b0, ResultSrcE}, 32'h1);
        check("lw: LoadTypeE  = 010", {29'b0, LoadTypeE}, 32'h2);
        check("lw: RD1E base",        RD1E,               32'h00000064);
        check("lw: ImmExtE offset",   ImmExtE,            32'h00000028);

        $display("=========================================");
        $display("  Fin testbench pipe_id_ex");
        $display("=========================================");
        $finish;
    end

endmodule