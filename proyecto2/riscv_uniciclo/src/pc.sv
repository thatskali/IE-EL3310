module pc (
    input  logic        clk,
    input  logic        rst,
    input  logic        StallF,
    input  logic [31:0] PCNext,
    output logic [31:0] PC
);

    always_ff @(posedge clk) begin
        if (rst)
            PC <= 32'b0;
        else if (!StallF)
            PC <= PCNext;
    end

endmodule