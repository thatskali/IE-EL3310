module main_deco (
    input  logic [6:0] op,
    input  logic [2:0] funct3,


    output logic       RegWrite,
    output logic [2:0] ImmSrc,
    output logic       ALUSrc,
    output logic       MemWrite,
    output logic [1:0] ResultSrc,
    output logic       Branch,
    output logic       Jump,
    output logic [1:0] ALUOp,
    output logic [2:0] LoadType,
    output logic [1:0] StoreType
);

    logic [11:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, Jump, ALUOp} = controls;

    always_comb begin

        LoadType  = 3'b010; // por defecto lw
        StoreType = 2'b10;  // por defecto sw

        case (op)

            // lw, lh, lb, lhu, lbu
            7'b0000011: begin
                controls = 12'b1_000_1_0_01_0_0_00;
                LoadType = funct3;
            end

            // sw, sh, sb
            7'b0100011: begin
                controls = 12'b0_001_1_1_00_0_0_00;

                case (funct3)
                    3'b000: StoreType = 2'b00; // sb
                    3'b001: StoreType = 2'b01; // sh
                    3'b010: StoreType = 2'b10; // sw
                    default: StoreType = 2'b10;
                endcase
            end

            // addi, xori, ori, andi, slti, sltiu, slli, srli, srai
            7'b0010011: controls = 12'b1_000_1_0_00_0_0_10;

            // add, sub, xor, or, and, slt, sltu, sll, srl, sra
            7'b0110011: controls = 12'b1_000_0_0_00_0_0_10;

            // beq, bne, blt, bge
            7'b1100011: controls = 12'b0_010_0_0_00_1_0_01;

            // lui
        7'b0110111: controls = 12'b1_100_1_0_00_0_0_00;
            // jal
            7'b1101111: controls = 12'b1_011_0_0_10_0_1_00;

            // jalr
            7'b1100111: controls = 12'b1_000_1_0_10_0_1_00;

            default:    controls = 12'b0_000_0_0_00_0_0_00;

        endcase
    end

endmodule