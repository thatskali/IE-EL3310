module data_mem (
    input  logic        clk,
    input  logic        MemWrite, // habilita escritura en memoria
    input  logic [31:0] ALUResult,
    input  logic [31:0] WriteData, // datos a escribir en memoria (desde RD2)
    input  logic [3:0]  ByteEnable, // señales de habilitación para cada byte en la memoria (1 para habilitar escritura, 0 para deshabilitar)

    output logic [31:0] ReadData
);

    logic [31:0] mem [0:255];

    initial begin
        integer i;

        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000000;

        mem[0] = 32'h0000007F;
        mem[1] = 32'h0000012C;
        mem[2] = 32'h12345000;
    end


    assign ReadData = (ALUResult[31:2] < 256) ? mem[ALUResult[31:2]] : 32'h00000000; // Lectura de memoria, con protección de rango (si la dirección es mayor a 1023, se devuelve 0)

    always_ff @(posedge clk) begin
    if (MemWrite === 1'b1 && (ALUResult[31:2] < 256)) begin
        if (ByteEnable[0])
            mem[ALUResult[31:2]][7:0] <= WriteData[7:0]; // Si ByteEnable[0] es 1, se habilita la escritura del byte 0 (bits 7:0) en la memoria

        if (ByteEnable[1])
            mem[ALUResult[31:2]][15:8] <= WriteData[15:8]; // Si ByteEnable[1] es 1, se habilita la escritura del byte 1 (bits 15:8) en la memoria

        if (ByteEnable[2])
            mem[ALUResult[31:2]][23:16] <= WriteData[23:16]; // Si ByteEnable[2] es 1, se habilita la escritura del byte 2 (bits 23:16) en la memoria

        if (ByteEnable[3])
            mem[ALUResult[31:2]][31:24] <= WriteData[31:24]; // Si ByteEnable[3] es 1, se habilita la escritura del byte 3 (bits 31:24) en la memoria
        end
    end

endmodule