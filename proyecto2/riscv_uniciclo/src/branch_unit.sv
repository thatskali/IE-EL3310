
// Unidad de condición de branch
// Decide si el branch se toma según funct3, Zero y ALUResult[0]
module branch_unit (
    input  logic [2:0] funct3,      // tipo de branch
    input  logic       zero,        // 1 si ALUResult == 0 (para beq)
    input  logic       alu_result0, // bit 0 del resultado (para blt, bge)
    output logic       branch_taken // 1 si el branch se debe tomar
);

    always_comb begin
    case (funct3)
        3'b000: branch_taken = zero;          // beq
        3'b001: branch_taken = !zero;         // bne
        3'b100: branch_taken = alu_result0;   // blt
        3'b101: branch_taken = !alu_result0;  // bge
        default: branch_taken = 1'b0;
    endcase
end

endmodule