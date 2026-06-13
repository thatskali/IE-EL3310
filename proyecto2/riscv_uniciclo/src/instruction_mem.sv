module imem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] imem [0:255];
    string memfile;

    initial begin
        integer i;

        for (i = 0; i < 256; i = i + 1)
            imem[i] = 32'h00000013; // nop

        if (!$value$plusargs("MEM=%s", memfile))
            memfile = "programas/programa1.mem";

        $display("Cargando programa: %s", memfile);
        $readmemh(memfile, imem);
    end

    assign instr = imem[addr >> 2];

endmodule