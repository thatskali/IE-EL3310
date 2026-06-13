module register_file (
    input  logic        clk,
    input  logic        WE3,
    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,
    input  logic [31:0] WD3,

    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] regs [0:31];

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // Lectura combinacional con bypass desde Writeback
    assign RD1 = (A1 == 5'd0) ? 32'b0 :
                 (WE3 && (A1 == A3) && (A3 != 5'd0)) ? WD3 :
                 regs[A1];

    assign RD2 = (A2 == 5'd0) ? 32'b0 :
                 (WE3 && (A2 == A3) && (A3 != 5'd0)) ? WD3 :
                 regs[A2];

    always_ff @(posedge clk) begin
        regs[0] <= 32'b0;

        if (WE3 && (A3 != 5'd0))
            regs[A3] <= WD3;
    end

endmodule