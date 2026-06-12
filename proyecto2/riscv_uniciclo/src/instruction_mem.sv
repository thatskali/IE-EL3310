module imem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

logic [31:0] imem [0:255];

//initial begin
//    $readmemh("programas/prueba.mem", imem);
//end

assign instr = imem[addr >> 2];

endmodule