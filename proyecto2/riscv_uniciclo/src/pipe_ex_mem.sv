module pipe_ex_mem (
    input  logic        clk,
    input  logic        rst,

    //señales de control que vienen de Execute
    input  logic        RegWriteE,   //habilita escritura en el Register File
    input  logic        MemWriteE,   //habilita escritura en memoria
    input  logic [1:0]  ResultSrcE,  //selecciona qué se escribe en el registro destino
    input  logic [2:0]  LoadTypeE,   //tipo de load (lw, lh, lb, lhu, lbu)
    input  logic [1:0]  StoreTypeE,  //tipo de store (sw, sh, sb)

    //datos que vienen de Execute
    input  logic [31:0] ALUResultE,  //resultado de la ALU
    input  logic [31:0] WriteDataE,  //dato a escribir en memoria (store)
    input  logic [3:0]  ByteEnableE, //byte enable generado por store unit
    input  logic [31:0] PCPlus4E,    //PC+4 para JAL/JALR
    input  logic [4:0]  RdE,         //registro destino

    //señales de control que van a Memory
    output logic        RegWriteM,
    output logic        MemWriteM,
    output logic [1:0]  ResultSrcM,
    output logic [2:0]  LoadTypeM,
    output logic [1:0]  StoreTypeM,

    //datos que van a Memory
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [3:0]  ByteEnableM,
    output logic [31:0] PCPlus4M,
    output logic [4:0]  RdM
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            //reset: poner todo en 0
            RegWriteM  <= 0;
            MemWriteM  <= 0;
            ResultSrcM <= 0;
            LoadTypeM  <= 0;
            StoreTypeM <= 0;
            ALUResultM <= 0;
            WriteDataM <= 0;
            ByteEnableM<= 0;
            PCPlus4M   <= 0;
            RdM        <= 0;
        end else begin
            //normal: capturar todas las señales de Execute
            RegWriteM  <= RegWriteE;
            MemWriteM  <= MemWriteE;
            ResultSrcM <= ResultSrcE;
            LoadTypeM  <= LoadTypeE;
            StoreTypeM <= StoreTypeE;
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            ByteEnableM<= ByteEnableE;
            PCPlus4M   <= PCPlus4E;
            RdM        <= RdE;
        end
    end

endmodule