module pipe_mem_wb (
    input  logic        clk,
    input  logic        rst,

    //señales de control que vienen de Memory
    input  logic        RegWriteM,   //habilita escritura en el Register File
    input  logic [1:0]  ResultSrcM,  //selecciona qué se escribe en el registro destino
    input  logic [2:0]  LoadTypeM,   //tipo de load (lw, lh, lb, lhu, lbu)

    //datos que vienen de Memory
    input  logic [31:0] ALUResultM,  //resultado de la ALU
    input  logic [31:0] ReadDataM,   //dato leído de memoria
    input  logic [31:0] PCPlus4M,    //PC+4 para JAL/JALR
    input  logic [4:0]  RdM,         //registro destino

    //señales de control que van a Writeback
    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW,
    output logic [2:0]  LoadTypeW,

    //datos que van a Writeback
    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic [31:0] PCPlus4W,
    output logic [4:0]  RdW
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            //reset: poner todo en 0
            RegWriteW  <= 0;
            ResultSrcW <= 0;
            LoadTypeW  <= 0;
            ALUResultW <= 0;
            ReadDataW  <= 0;
            PCPlus4W   <= 0;
            RdW        <= 0;
        end else begin
            //normal: capturar todas las señales de Memory
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            LoadTypeW  <= LoadTypeM;
            ALUResultW <= ALUResultM;
            ReadDataW  <= ReadDataM;
            PCPlus4W   <= PCPlus4M;
            RdW        <= RdM;
        end
    end

endmodule