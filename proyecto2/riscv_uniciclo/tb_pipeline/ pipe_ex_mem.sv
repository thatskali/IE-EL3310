module pipe_ex_mem_tb;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic        clk;
    logic        rst;

    // señales de control entradas
    logic        RegWriteE;
    logic        MemWriteE;
    logic [1:0]  ResultSrcE;
    logic [2:0]  LoadTypeE;
    logic [1:0]  StoreTypeE;

    // datos entradas
    logic [31:0] ALUResultE;
    logic [31:0] WriteDataE;
    logic [3:0]  ByteEnableE;
    logic [31:0] PCPlus4E;
    logic [4:0]  RdE;

    // señales de control salidas
    logic        RegWriteM;
    logic        MemWriteM;
    logic [1:0]  ResultSrcM;
    logic [2:0]  LoadTypeM;
    logic [1:0]  StoreTypeM;

    // datos salidas
    logic [31:0] ALUResultM;
    logic [31:0] WriteDataM;
    logic [3:0]  ByteEnableM;
    logic [31:0] PCPlus4M;
    logic [4:0]  RdM;

    // =========================================================
    // INSTANCIA
    // =========================================================
    pipe_ex_mem dut (
        .clk         (clk),
        .rst         (rst),
        .RegWriteE   (RegWriteE),
        .MemWriteE   (MemWriteE),
        .ResultSrcE  (ResultSrcE),
        .LoadTypeE   (LoadTypeE),
        .StoreTypeE  (StoreTypeE),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
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

    // tarea para poner entradas con valores de prueba
    task set_inputs;
        RegWriteE   = 1;
        MemWriteE   = 0;
        ResultSrcE  = 2'b00;
        LoadTypeE   = 3'b010;
        StoreTypeE  = 2'b10;
        ALUResultE  = 32'hDEADBEEF;
        WriteDataE  = 32'hCAFEBABE;
        ByteEnableE = 4'b1111;
        PCPlus4E    = 32'h00000014;
        RdE         = 5'd10;
    endtask

    // =========================================================
    // ESTÍMULOS
    // =========================================================
    initial begin
        $display("=========================================");
        $display("  Testbench pipe_ex_mem");
        $display("=========================================");

        // inicializar
        rst = 1;
        RegWriteE = 0; MemWriteE = 0; ResultSrcE = 0;
        LoadTypeE = 0; StoreTypeE = 0; ALUResultE = 0;
        WriteDataE = 0; ByteEnableE = 0; PCPlus4E = 0; RdE = 0;

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
        check("rst: RegWriteM  = 0", {31'b0, RegWriteM},  32'h0);
        check("rst: MemWriteM  = 0", {31'b0, MemWriteM},  32'h0);
        check("rst: ResultSrcM = 0", {30'b0, ResultSrcM}, 32'h0);
        check("rst: ALUResultM = 0", ALUResultM,           32'h0);
        check("rst: WriteDataM = 0", WriteDataM,           32'h0);
        check("rst: RdM        = 0", {27'b0, RdM},        32'h0);
        rst = 0;

        // -------------------------------------------------
        // CASO 2: Comportamiento normal — captura entradas
        // -------------------------------------------------
        $display("--- Caso 2: Normal ---");
        set_inputs();
        @(posedge clk); #1;
        check("normal: RegWriteM",   {31'b0, RegWriteM},  32'h1);
        check("normal: MemWriteM",   {31'b0, MemWriteM},  32'h0);
        check("normal: ResultSrcM",  {30'b0, ResultSrcM}, 32'h0);
        check("normal: LoadTypeM",   {29'b0, LoadTypeM},  32'h2);
        check("normal: ALUResultM",  ALUResultM,           32'hDEADBEEF);
        check("normal: WriteDataM",  WriteDataM,           32'hCAFEBABE);
        check("normal: ByteEnableM", {28'b0, ByteEnableM},32'hF);
        check("normal: PCPlus4M",    PCPlus4M,             32'h00000014);
        check("normal: RdM",         {27'b0, RdM},        32'd10);

        // -------------------------------------------------
        // CASO 3: Instrucción sw
        // -------------------------------------------------
        $display("--- Caso 3: Instruccion sw ---");
        RegWriteE   = 0;         // sw no escribe en registro
        MemWriteE   = 1;         // sw escribe en memoria
        ResultSrcE  = 2'b00;
        LoadTypeE   = 3'b010;
        StoreTypeE  = 2'b10;     // sw
        ALUResultE  = 32'h00000064; // dirección = 100
        WriteDataE  = 32'h000000FF; // dato a escribir
        ByteEnableE = 4'b1111;
        PCPlus4E    = 32'h00000020;
        RdE         = 5'd0;
        @(posedge clk); #1;
        check("sw: RegWriteM  = 0", {31'b0, RegWriteM},     32'h0);
        check("sw: MemWriteM  = 1", {31'b0, MemWriteM},     32'h1);
        check("sw: ALUResultM dir", ALUResultM,              32'h00000064);
        check("sw: WriteDataM dato",WriteDataM,              32'h000000FF);
        check("sw: StoreTypeM = 10",{30'b0, StoreTypeM},    32'h2);

        // -------------------------------------------------
        // CASO 4: Instrucción lw
        // -------------------------------------------------
        $display("--- Caso 4: Instruccion lw ---");
        RegWriteE   = 1;
        MemWriteE   = 0;
        ResultSrcE  = 2'b01;    // load_data → registro
        LoadTypeE   = 3'b010;   // lw
        StoreTypeE  = 2'b10;
        ALUResultE  = 32'h0000008C; // dirección calculada
        WriteDataE  = 32'h0;
        ByteEnableE = 4'b1111;
        PCPlus4E    = 32'h00000024;
        RdE         = 5'd15;
        @(posedge clk); #1;
        check("lw: RegWriteM  = 1",  {31'b0, RegWriteM},  32'h1);
        check("lw: MemWriteM  = 0",  {31'b0, MemWriteM},  32'h0);
        check("lw: ResultSrcM = 01", {30'b0, ResultSrcM}, 32'h1);
        check("lw: LoadTypeM  = 010",{29'b0, LoadTypeM},  32'h2);
        check("lw: ALUResultM dir",  ALUResultM,           32'h0000008C);
        check("lw: RdM",             {27'b0, RdM},        32'd15);

        $display("=========================================");
        $display("  Fin testbench pipe_ex_mem");
        $display("=========================================");
        $finish;
    end

endmodule