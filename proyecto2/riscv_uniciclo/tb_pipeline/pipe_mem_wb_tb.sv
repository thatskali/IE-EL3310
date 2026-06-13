module pipe_mem_wb_tb;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic        clk;
    logic        rst;

    // señales de control entradas
    logic        RegWriteM;
    logic [1:0]  ResultSrcM;
    logic [2:0]  LoadTypeM;

    // datos entradas
    logic [31:0] ALUResultM;
    logic [31:0] ReadDataM;
    logic [31:0] PCPlus4M;
    logic [4:0]  RdM;

    // señales de control salidas
    logic        RegWriteW;
    logic [1:0]  ResultSrcW;
    logic [2:0]  LoadTypeW;

    // datos salidas
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [4:0]  RdW;

    // =========================================================
    // INSTANCIA
    // =========================================================
    pipe_mem_wb dut (
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
        RegWriteM  = 1;
        ResultSrcM = 2'b00;
        LoadTypeM  = 3'b010;
        ALUResultM = 32'hDEADBEEF;
        ReadDataM  = 32'hCAFEBABE;
        PCPlus4M   = 32'h00000018;
        RdM        = 5'd12;
    endtask

    // =========================================================
    // ESTÍMULOS
    // =========================================================
    initial begin
        $display("=========================================");
        $display("  Testbench pipe_mem_wb");
        $display("=========================================");

        // inicializar
        rst = 1;
        RegWriteM = 0; ResultSrcM = 0; LoadTypeM = 0;
        ALUResultM = 0; ReadDataM = 0; PCPlus4M = 0; RdM = 0;

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
        check("rst: RegWriteW  = 0", {31'b0, RegWriteW},  32'h0);
        check("rst: ResultSrcW = 0", {30'b0, ResultSrcW}, 32'h0);
        check("rst: ALUResultW = 0", ALUResultW,           32'h0);
        check("rst: ReadDataW  = 0", ReadDataW,            32'h0);
        check("rst: PCPlus4W   = 0", PCPlus4W,             32'h0);
        check("rst: RdW        = 0", {27'b0, RdW},        32'h0);
        rst = 0;

        // -------------------------------------------------
        // CASO 2: Comportamiento normal — captura entradas
        // -------------------------------------------------
        $display("--- Caso 2: Normal ---");
        set_inputs();
        @(posedge clk); #1;
        check("normal: RegWriteW",  {31'b0, RegWriteW},  32'h1);
        check("normal: ResultSrcW", {30'b0, ResultSrcW}, 32'h0);
        check("normal: LoadTypeW",  {29'b0, LoadTypeW},  32'h2);
        check("normal: ALUResultW", ALUResultW,           32'hDEADBEEF);
        check("normal: ReadDataW",  ReadDataW,            32'hCAFEBABE);
        check("normal: PCPlus4W",   PCPlus4W,             32'h00000018);
        check("normal: RdW",        {27'b0, RdW},        32'd12);

        // -------------------------------------------------
        // CASO 3: Instrucción lw — ResultSrc=01
        // -------------------------------------------------
        $display("--- Caso 3: Instruccion lw ---");
        RegWriteM  = 1;
        ResultSrcM = 2'b01;    // selecciona ReadData
        LoadTypeM  = 3'b010;   // lw
        ALUResultM = 32'h0000008C;
        ReadDataM  = 32'h12345678; // dato leído de memoria
        PCPlus4M   = 32'h0000001C;
        RdM        = 5'd8;
        @(posedge clk); #1;
        check("lw: RegWriteW  = 1",  {31'b0, RegWriteW},  32'h1);
        check("lw: ResultSrcW = 01", {30'b0, ResultSrcW}, 32'h1);
        check("lw: ReadDataW",       ReadDataW,            32'h12345678);
        check("lw: RdW",             {27'b0, RdW},        32'd8);

        // -------------------------------------------------
        // CASO 4: Instrucción JAL — ResultSrc=10
        // -------------------------------------------------
        $display("--- Caso 4: Instruccion JAL ---");
        RegWriteM  = 1;
        ResultSrcM = 2'b10;    // selecciona PCPlus4
        LoadTypeM  = 3'b010;
        ALUResultM = 32'h00000040;
        ReadDataM  = 32'h0;
        PCPlus4M   = 32'h00000024; // PC+4 se escribe en rd
        RdM        = 5'd1;
        @(posedge clk); #1;
        check("jal: RegWriteW  = 1",  {31'b0, RegWriteW},  32'h1);
        check("jal: ResultSrcW = 10", {30'b0, ResultSrcW}, 32'h2);
        check("jal: PCPlus4W",        PCPlus4W,             32'h00000024);
        check("jal: RdW",             {27'b0, RdW},        32'd1);

        // -------------------------------------------------
        // CASO 5: Instrucción LUI — ResultSrc=11
        // -------------------------------------------------
        $display("--- Caso 5: Instruccion LUI ---");
        RegWriteM  = 1;
        ResultSrcM = 2'b11;    // selecciona ImmExt
        LoadTypeM  = 3'b010;
        ALUResultM = 32'h0;
        ReadDataM  = 32'h0;
        PCPlus4M   = 32'h00000028;
        RdM        = 5'd5;
        @(posedge clk); #1;
        check("lui: RegWriteW  = 1",  {31'b0, RegWriteW},  32'h1);
        check("lui: ResultSrcW = 11", {30'b0, ResultSrcW}, 32'h3);
        check("lui: RdW",             {27'b0, RdW},        32'd5);

        $display("=========================================");
        $display("  Fin testbench pipe_mem_wb");
        $display("=========================================");
        $finish;
    end

endmodule