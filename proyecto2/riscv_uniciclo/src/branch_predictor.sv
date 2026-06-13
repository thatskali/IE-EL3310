module branch_predictor #(
    parameter INDEX_BITS = 4
)(
    input  logic        clk,
    input  logic        rst,

    // Consulta en Fetch
    input  logic [31:0] PCF,
    output logic        predict_takenF,

    // Actualización en Execute
    input  logic        updateE,
    input  logic [31:0] PCE,
    input  logic        actual_takenE
);

    localparam ENTRIES = (1 << INDEX_BITS);

    logic [1:0] bht [0:ENTRIES-1];

    logic [INDEX_BITS-1:0] indexF;
    logic [INDEX_BITS-1:0] indexE;

    integer i;

    assign indexF = PCF[INDEX_BITS+1:2];
    assign indexE = PCE[INDEX_BITS+1:2];

    // Predice tomado si el bit más significativo está en 1
    assign predict_takenF = bht[indexF][1];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < ENTRIES; i = i + 1)
                bht[i] <= 2'b01; // weak not taken
        end else if (updateE) begin
            if (actual_takenE) begin
                if (bht[indexE] != 2'b11)
                    bht[indexE] <= bht[indexE] + 2'b01;
            end else begin
                if (bht[indexE] != 2'b00)
                    bht[indexE] <= bht[indexE] - 2'b01;
            end
        end
    end

endmodule