module register_file (
    input  logic        clk,
    input  logic        WE3,     // RegWrite
    input  logic [4:0]  A1,      // Instr[19:15] -> rs1
    input  logic [4:0]  A2,      // Instr[24:20] -> rs2
    input  logic [4:0]  A3,      // Instr[11:7]  -> rd
    input  logic [31:0] WD3,     // dato a escribir en rd

    output logic [31:0] RD1,     // dato leído de rs1
    output logic [31:0] RD2      // dato leído de rs2
);

    logic [31:0] regs [0:31];

    // Lectura combinacional
    assign RD1 = (A1 == 5'd0) ? 32'b0 : regs[A1]; // Si A1 es 0, RD1 se fuerza a 0 (x0 siempre es 0), de lo contrario se lee el registro indicado por A1
    assign RD2 = (A2 == 5'd0) ? 32'b0 : regs[A2]; // Si A2 es 0, RD2 se fuerza a 0 (x0 siempre es 0), de lo contrario se lee el registro indicado por A2

    // Escritura síncrona
    // x0 siempre debe permanecer en cero
    always_ff @(posedge clk) begin
        if (WE3 && (A3 != 5'd0)) begin // Si WE3 es 1 y A3 no es 0, se habilita la escritura en el registro indicado por A3
            regs[A3] <= WD3;
        end
    end

endmodule