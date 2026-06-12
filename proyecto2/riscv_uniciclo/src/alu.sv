// ALU (Arithmetic Logic Unit) para el procesador RISC-V uniciclo
// Implementa las operaciones aritméticas y lógicas necesarias para la ejecución de instrucciones
// Unidad Aritmético-Lógica de 32 bits
module alu (
    input  logic [31:0] SrcA,       // primer operando (rs1)
    input  logic [31:0] SrcB,       // segundo operando (rs2 o inmediato)
    input  logic [3:0]  ALUControl, // operación a realizar
    output logic [31:0] ALUResult,  // resultado de la operación
    output logic        Zero        // 1 si ALUResult == 0 (para beq)
);

    always_comb begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA + SrcB;                                  // add
            4'b0001: ALUResult = SrcA - SrcB;                                  // subtract
            4'b0010: ALUResult = SrcA & SrcB;                                  // and
            4'b0011: ALUResult = SrcA | SrcB;                                  // or
            4'b0100: ALUResult = SrcA << SrcB[4:0];                            // sll
            4'b0101: ALUResult = {{31{1'b0}}, $signed(SrcA) < $signed(SrcB)};  // slt signed
            4'b0110: ALUResult = SrcA >> SrcB[4:0];                            // srl
            4'b0111: ALUResult = $signed(SrcA) >>> SrcB[4:0];                  // sra
            4'b1000: ALUResult = SrcA ^ SrcB;                                  // xor
            4'b1001: ALUResult = {{31{1'b0}}, SrcA < SrcB};                    // sltu
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);

endmodule