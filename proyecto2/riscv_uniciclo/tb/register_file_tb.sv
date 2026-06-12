`timescale 1ns/1ps

module tb_register_file;

    logic        clk;
    logic        WE3;
    logic [4:0]  A1;
    logic [4:0]  A2;
    logic [4:0]  A3;
    logic [31:0] WD3;
    logic [31:0] RD1;
    logic [31:0] RD2;

    register_file dut (
        .clk (clk),
        .WE3 (WE3),
        .A1  (A1),
        .A2  (A2),
        .A3  (A3),
        .WD3 (WD3),
        .RD1 (RD1),
        .RD2 (RD2)
    );

    always #5 clk = ~clk;

    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
        input string name;
        begin
            @(negedge clk);
            A3  = addr;
            WD3 = data;
            WE3 = 1'b1;

            @(negedge clk);
            WE3 = 1'b0;

            $display("WRITE %s: x%0d = %h", name, addr, data);
        end
    endtask

    task check_read;
        input [4:0]  addr1;
        input [4:0]  addr2;
        input [31:0] expected1;
        input [31:0] expected2;
        input string name;
        begin
            A1 = addr1;
            A2 = addr2;
            #1;

            if ((RD1 !== expected1) || (RD2 !== expected2)) begin
                $display("ERROR en %s", name);
                $display("  A1=%0d esperado RD1=%h obtenido RD1=%h", addr1, expected1, RD1);
                $display("  A2=%0d esperado RD2=%h obtenido RD2=%h", addr2, expected2, RD2);
            end else begin
                $display("OK: %s -> RD1=%h RD2=%h", name, RD1, RD2);
            end
        end
    endtask

    initial begin
        clk = 0;
        WE3 = 0;
        A1 = 0;
        A2 = 0;
        A3 = 0;
        WD3 = 0;

        $display("===== TB REGISTER FILE =====");

        // Escribir algunos registros
        write_reg(5'd1, 32'h0000000A, "x1 = 10");
        write_reg(5'd2, 32'h00000014, "x2 = 20");
        write_reg(5'd5, 32'hAABBCCDD, "x5 = AABBCCDD");

        // Leer registros escritos
        check_read(5'd1, 5'd2, 32'h0000000A, 32'h00000014, "leer x1 y x2");
        check_read(5'd5, 5'd1, 32'hAABBCCDD, 32'h0000000A, "leer x5 y x1");

        // Probar que x0 siempre vale 0
        check_read(5'd0, 5'd2, 32'h00000000, 32'h00000014, "leer x0 y x2");

        // Intentar escribir x0
        write_reg(5'd0, 32'hFFFFFFFF, "intento escribir x0");

        // x0 debe seguir en cero
        check_read(5'd0, 5'd1, 32'h00000000, 32'h0000000A, "x0 sigue en cero");

        // Probar escritura deshabilitada
        @(negedge clk);
        A3  = 5'd3;
        WD3 = 32'h12345678;
        WE3 = 1'b0;

        @(negedge clk);
        check_read(5'd3, 5'd1, 32'hxxxxxxxx, 32'h0000000A, "x3 no escrito con WE3=0");

        $display("===== FIN TB REGISTER FILE =====");
        $finish;
    end

endmodule