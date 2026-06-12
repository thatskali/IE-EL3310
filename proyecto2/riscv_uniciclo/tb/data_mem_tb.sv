`timescale 1ns/1ps

module tb_data_mem;

    logic        clk;
    logic        MemWrite;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic [3:0]  ByteEnable;
    logic [31:0] ReadData;

    data_mem dut (
        .clk        (clk),
        .MemWrite   (MemWrite),
        .ALUResult  (ALUResult),
        .WriteData  (WriteData),
        .ByteEnable (ByteEnable),
        .ReadData   (ReadData)
    );

    always #5 clk = ~clk;

    task write_mem;
        input [31:0] addr;
        input [31:0] data;
        input [3:0]  be;
        input string name;
        begin
            @(negedge clk);
            ALUResult  = addr;
            WriteData  = data;
            ByteEnable = be;
            MemWrite   = 1'b1;

            @(negedge clk);
            MemWrite   = 1'b0;

            #1;
            $display("WRITE %s: addr=%h data=%h BE=%b ReadData=%h",
                     name, addr, data, be, ReadData);
        end
    endtask

    task check_read;
        input [31:0] addr;
        input [31:0] expected;
        input string name;
        begin
            ALUResult = addr;
            #1;

            if (ReadData !== expected) begin
                $display("ERROR en %s", name);
                $display("  addr     = %h", addr);
                $display("  esperado = %h", expected);
                $display("  obtenido = %h", ReadData);
            end else begin
                $display("OK: %s -> ReadData=%h", name, ReadData);
            end
        end
    endtask

    initial begin
        clk        = 0;
        MemWrite   = 0;
        ALUResult  = 0;
        WriteData  = 0;
        ByteEnable = 0;

        $display("===== TB DATA MEM =====");

        // =========================
        // sw: escribe palabra completa
        // =========================
        write_mem(32'h00000000, 32'hAABBCCDD, 4'b1111, "sw addr 0");
        check_read(32'h00000000, 32'hAABBCCDD, "read after sw");

        // =========================
        // sb: cambia solo byte 0
        // AABBCCDD -> AABBCC11
        // =========================
        write_mem(32'h00000000, 32'h00000011, 4'b0001, "sb offset 0");
        check_read(32'h00000000, 32'hAABBCC11, "read after sb offset 0");

        // =========================
        // sb: cambia solo byte 1
        // AABBCC11 -> AABB2211
        // =========================
        write_mem(32'h00000000, 32'h00002200, 4'b0010, "sb offset 1");
        check_read(32'h00000000, 32'hAABB2211, "read after sb offset 1");

        // =========================
        // sh: cambia halfword alto
        // AABB2211 -> 33442211
        // =========================
        write_mem(32'h00000000, 32'h33440000, 4'b1100, "sh offset 2");
        check_read(32'h00000000, 32'h33442211, "read after sh offset 2");

        // =========================
        // sh: cambia halfword bajo
        // 33442211 -> 33445566
        // =========================
        write_mem(32'h00000000, 32'h00005566, 4'b0011, "sh offset 0");
        check_read(32'h00000000, 32'h33445566, "read after sh offset 0");

        // =========================
        // Escritura en otra dirección
        // =========================
        write_mem(32'h00000004, 32'h12345678, 4'b1111, "sw addr 4");
        check_read(32'h00000004, 32'h12345678, "read addr 4");

        // Verificar que addr 0 no cambió
        check_read(32'h00000000, 32'h33445566, "addr 0 preserved");

        $display("===== FIN TB DATA MEM =====");
        $finish;
    end

endmodule