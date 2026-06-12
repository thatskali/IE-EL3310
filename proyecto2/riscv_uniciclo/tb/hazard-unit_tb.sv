module tb_hazard_unit;

    logic [4:0] Rs1D, Rs2D;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic [4:0] RdM, RdW;

    logic RegWriteM;
    logic RegWriteW;

    logic ResultSrcE0;
    logic PCSrcE;

    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

    logic StallF;
    logic StallD;

    logic FlushD;
    logic FlushE;

    hazard_unit dut(
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .ResultSrcE0(ResultSrcE0),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    initial begin

        // Valores por defecto
        Rs1D = 0;
        Rs2D = 0;
        Rs1E = 0;
        Rs2E = 0;
        RdE  = 0;
        RdM  = 0;
        RdW  = 0;

        RegWriteM = 0;
        RegWriteW = 0;

        ResultSrcE0 = 0;
        PCSrcE      = 0;

        #10;

        
        // MEM Forwarding

        Rs1E = 5;
        RdM  = 5;
        RegWriteM = 1;

        #10;
        assert(ForwardAE == 2'b10);


        // WB Forwarding
        Rs1E = 7;
        RdM  = 0;
        RdW  = 7;

        RegWriteM = 0;
        RegWriteW = 1;

        #10;
        assert(ForwardAE == 2'b01);

        
        // No Forwarding
        Rs1E = 8;
        RdM  = 3;
        RdW  = 4;

        #10;
        assert(ForwardAE == 2'b00);

        
        // x0 should never forward
        Rs1E = 0;
        RdM  = 0;

        RegWriteM = 1;

        #10;
        assert(ForwardAE == 2'b00);

        
        // Load Use Hazard
        Rs1D = 5;
        RdE  = 5;

        ResultSrcE0 = 1;

        #10;

        assert(StallF == 1);
        assert(StallD == 1);
        assert(FlushE == 1);

        
        // Branch Flush
        ResultSrcE0 = 0;
        PCSrcE = 1;

        #10;

        assert(FlushD == 1);
        assert(FlushE == 1);

        $display("All Hazard Unit Tests Passed");
        $finish;

    end

endmodule
