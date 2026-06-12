module pipe_if_id (
    input  logic        clk,
    input  logic        rst,
    input  logic        StallD,   //del Hazard Unit
    input  logic        FlushD,   //del Hazard Unit

    //entradas que vienen de Fetch
    input  logic [31:0] PCF, //PC actual
    input  logic [31:0]  InstrF, //instrucción leída
    input  logic [31:0] PCPlus4F, //PC + 4

    //salidas que van a Decode
    output logic [31:0] PCD,
    output logic [31:0] InstrD,
    output logic [31:0] PCPlus4D
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst || FlushD) begin
            //flush o reset: poner todo en 0
            PCD<= 0;
            InstrD<= 0;
            PCPlus4D<= 0;
        end else if (StallD) begin
            //stall: no hacer 
        end else begin
            //normal: capturar
            PCD<= PCF;
            InstrD<= InstrF;
            PCPlus4D<=PCPlus4F;
        end
    end

endmodule
