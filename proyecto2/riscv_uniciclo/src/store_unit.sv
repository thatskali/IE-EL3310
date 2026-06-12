module store_unit (
    input  logic [31:0] rs2, // valor del registro fuente 2 (RD2)
    input  logic [31:0] ALUResult, // resultado de la ALU, usado para determinar el byte/halfword a almacenar
    input  logic [1:0]  StoreType, // tipo de almacenamiento (sb, sh, sw)

    output logic [31:0] WriteData,
    output logic [3:0]  ByteEnable // señales de habilitación para cada byte en la memoria (1 para habilitar escritura, 0 para deshabilitar)
);

    always_comb begin
        WriteData   = 32'b0;
        ByteEnable  = 4'b0000;

        case (StoreType)

            // sb se toma el byte menos significativo de rs2 y se almacena en la dirección determinada por ALUResult, y se habilita solo el byte correspondiente para escritura según los bits 1:0 de ALUResult
            2'b00: begin
                case (ALUResult[1:0])
                    2'b00: begin 
                        WriteData  = {24'b0, rs2[7:0]}; 
                        ByteEnable = 4'b0001;
                    end

                    2'b01: begin
                        WriteData  = {16'b0, rs2[7:0], 8'b0};
                        ByteEnable = 4'b0010;
                    end

                    2'b10: begin
                        WriteData  = {8'b0, rs2[7:0], 16'b0};
                        ByteEnable = 4'b0100;
                    end

                    2'b11: begin
                        WriteData  = {rs2[7:0], 24'b0};
                        ByteEnable = 4'b1000;
                    end
                endcase
            end

            // sh se toma el bit 1 de la ALUResult para determinar qué halfword almacenar (0 para los 16 bits menos significativos, 1 para los 16 bits más significativos)
            2'b01: begin  
                case (ALUResult[1])
                    1'b0: begin
                        WriteData  = {16'b0, rs2[15:0]};
                        ByteEnable = 4'b0011;
                    end

                    1'b1: begin
                        WriteData  = {rs2[15:0], 16'b0};
                        ByteEnable = 4'b1100;
                    end
                endcase
            end

            // sw  se almacena la palabra completa de 32 bits desde el registro fuente 2 a la memoria, y se habilitan los 4 bytes para escritura
            2'b10: begin
                WriteData  = rs2;
                ByteEnable = 4'b1111;
            end

            default: begin
                WriteData  = 32'b0;
                ByteEnable = 4'b0000;
            end

        endcase
    end

endmodule