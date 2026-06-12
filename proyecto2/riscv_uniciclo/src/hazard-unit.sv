module hazard_unit (

    // Decodificador
    input  logic [4:0] Rs1D,
    input  logic [4:0] Rs2D,

    // Executer
    input  logic [4:0] Rs1E,
    input  logic [4:0] Rs2E,
    input  logic [4:0] RdE,

    // Memoria
    input  logic [4:0] RdM,
    input  logic       RegWriteM,

    // Writeback
    input  logic [4:0] RdW,
    input  logic       RegWriteW,

    // Señales de Control
    input  logic       ResultSrcE0,
    input  logic       PCSrcE,

    // Forward Control
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE,

    // Stall Control
    output logic       StallF,
    output logic       StallD,

    // Flush Control
    output logic       FlushD,
    output logic       FlushE
);

    logic lwStall;


    // Logica Forwarding para Input A ALU

    always_comb begin

        if ((Rs1E == RdM) &&
            RegWriteM &&
            (Rs1E != 5'd0))
            ForwardAE = 2'b10;

        else if ((Rs1E == RdW) &&
                 RegWriteW &&
                 (Rs1E != 5'd0))
            ForwardAE = 2'b01;

        else
            ForwardAE = 2'b00;

    end


    // Logica Forwarding para entrada B ALU 

    always_comb begin

        if ((Rs2E == RdM) &&
            RegWriteM &&
            (Rs2E != 5'd0))
            ForwardBE = 2'b10;

        else if ((Rs2E == RdW) &&
                 RegWriteW &&
                 (Rs2E != 5'd0))
            ForwardBE = 2'b01;

        else
            ForwardBE = 2'b00;

    end


    // Deteccion Load-Use Hazard 

    assign lwStall =
        (((Rs1D == RdE) ||
          (Rs2D == RdE))
         &&
         ResultSrcE0);


    // Señales Stall 

    assign StallF = lwStall;
    assign StallD = lwStall;


    // Señales Flush 
    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;

endmodule
