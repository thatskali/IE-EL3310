module alu_deco (
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [3:0] ALUControl
);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;

    always_comb begin
        case (ALUOp)

            // lw, lh, lb, lhu, lbu, sw, sh, sb, jalr
            2'b00: ALUControl = 4'b0000; // add

            // beq, bne, blt, bge
            2'b01: begin
                case (funct3)
                    3'b000: ALUControl = 4'b0001; // beq usa resta
                    3'b001: ALUControl = 4'b0001; // bne usa resta
                    3'b100: ALUControl = 4'b0101; // blt usa slt
                    3'b101: ALUControl = 4'b0101; // bge usa slt
                    default: ALUControl = 4'b0001;
                endcase
            end

            // tipo R y tipo I aritmético/lógico
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (RtypeSub)
                            ALUControl = 4'b0001; // sub
                        else
                            ALUControl = 4'b0000; // add, addi
                    end
                    3'b001: ALUControl = 4'b0100; // sll, slli  (era 0111)
                    3'b010: ALUControl = 4'b0101; // slt, slti
                    3'b011: ALUControl = 4'b1001; // sltu, sltiu (era 0110)
                    3'b100: ALUControl = 4'b1000; // xor, xori  (era 0100)
                    3'b101: begin
                        if (funct7b5)
                            ALUControl = 4'b0111; // sra, srai  (era 1001)
                        else
                            ALUControl = 4'b0110; // srl, srli  (era 1000)
                    end
                    3'b110: ALUControl = 4'b0011; // or, ori
                    3'b111: ALUControl = 4'b0010; // and, andi
                    default: ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;

        endcase
    end

endmodule