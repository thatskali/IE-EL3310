module pipe_id_ex (
    input  logic        clk,
    input  logic        rst,
    input  logic        FlushE,   //del Hazard Unit: limpia la etapa Execute insertando una burbuja (NOP)

    //señales de control que vienen de Decode
    input  logic        RegWriteD,   //habilita escritura en el Register File
    input  logic        MemWriteD,   //habilita escritura en memoria
    input  logic        ALUSrcD,     //selecciona segundo operando de la ALU (0=RD2, 1=ImmExt)
    input  logic        JumpD,       //indica instrucción de salto (jal/jalr)
    input  logic        BranchD,     //indica instrucción de branch
    input  logic [1:0]  ResultSrcD,  //selecciona qué se escribe en el registro destino
    input  logic [1:0]  ALUOpD,      //indica tipo de operación a la ALU Decoder
    input  logic [3:0]  ALUControlD, //operación específica de la ALU
    input  logic [2:0]  LoadTypeD,   //tipo de load (lw, lh, lb, lhu, lbu)
    input  logic [1:0]  StoreTypeD,  //tipo de store (sw, sh, sb)
    input  logic [2:0] funct3D,


    //datos que vienen de Decode
    input  logic [31:0] RD1D,      //valor leído del registro rs1
    input  logic [31:0] RD2D,      //valor leído del registro rs2
    input  logic [31:0] ImmExtD,   //inmediato extendido
    input  logic [31:0] PCD,       //PC actual, para calcular PCTarget
    input  logic [31:0] PCPlus4D,  //PC+4, para JAL/JALR
    input  logic [4:0]  Rs1D,      //número de registro rs1, para Hazard Unit
    input  logic [4:0]  Rs2D,      //número de registro rs2, para Hazard Unit
    input  logic [4:0]  RdD,       //número de registro destino

    //señales de control que van a Execute
    output logic        RegWriteE,
    output logic        MemWriteE,
    output logic        ALUSrcE,
    output logic        JumpE,
    output logic        BranchE,
    output logic [1:0]  ResultSrcE,
    output logic [1:0]  ALUOpE,
    output logic [3:0]  ALUControlE,
    output logic [2:0]  LoadTypeE,
    output logic [1:0]  StoreTypeE,
    output logic [2:0]  funct3E,
    //datos que van a Execute
    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCE,
    output logic [31:0] PCPlus4E,
    output logic [4:0]  Rs1E,
    output logic [4:0]  Rs2E,
    output logic [4:0]  RdE
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst || FlushE) begin
            //flush o reset: poner todo en 0, burbuja NOP que no modifica ningún estado
            RegWriteE  <= 0;
            MemWriteE  <= 0;
            ALUSrcE    <= 0;
            JumpE      <= 0;
            BranchE    <= 0;
            ResultSrcE <= 0;
            ALUOpE     <= 0;
            ALUControlE<= 0;
            LoadTypeE  <= 0;
            StoreTypeE <= 0;
            RD1E       <= 0;
            RD2E       <= 0;
            ImmExtE    <= 0;
            PCE        <= 0;
            PCPlus4E   <= 0;
            Rs1E       <= 0;
            Rs2E       <= 0;
            RdE        <= 0;
            funct3E <= 3'b000;
        end else begin
            //normal: capturar todas las señales de Decode
            RegWriteE  <= RegWriteD;
            MemWriteE  <= MemWriteD;
            ALUSrcE    <= ALUSrcD;
            JumpE      <= JumpD;
            BranchE    <= BranchD;
            ResultSrcE <= ResultSrcD;
            ALUOpE     <= ALUOpD;
            ALUControlE<= ALUControlD;
            LoadTypeE  <= LoadTypeD;
            StoreTypeE <= StoreTypeD;
            RD1E       <= RD1D;
            RD2E       <= RD2D;
            ImmExtE    <= ImmExtD;
            PCE        <= PCD;
            PCPlus4E   <= PCPlus4D;
            Rs1E       <= Rs1D;
            Rs2E       <= Rs2D;
            RdE        <= RdD;
            funct3E <= funct3D;
        end
    end

endmodule