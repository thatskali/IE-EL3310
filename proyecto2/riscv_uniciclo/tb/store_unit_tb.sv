`timescale 1ns/1ps

module tb_store_unit;

    logic [31:0] rs2;
    logic [31:0] ALUResult;
    logic [1:0]  StoreType;
    logic [31:0] WriteData;
    logic [3:0]  ByteEnable;

    store_unit dut (
        .rs2        (rs2),
        .ALUResult  (ALUResult),
        .StoreType  (StoreType),
        .WriteData  (WriteData),
        .ByteEnable (ByteEnable)
    );

    task check;
        input [1:0]  st;
        input [31:0] addr;
        input [31:0] data;
        input [31:0] expected_wd;
        input [3:0]  expected_be;
        input string name;
        begin
            StoreType = st;
            ALUResult = addr;
            rs2       = data;
            #1;

            if ((WriteData !== expected_wd) || (ByteEnable !== expected_be)) begin
                $display("ERROR en %s", name);
                $display("  rs2        = %h", rs2);
                $display("  ALUResult  = %h", ALUResult);
                $display("  StoreType  = %b", StoreType);
                $display("  esperado WD = %h", expected_wd);
                $display("  obtenido WD = %h", WriteData);
                $display("  esperado BE = %b", expected_be);
                $display("  obtenido BE = %b", ByteEnable);
            end else begin
                $display("OK: %s -> WriteData=%h ByteEnable=%b", name, WriteData, ByteEnable);
            end
        end
    endtask

    initial begin
        $display("===== TB STORE UNIT =====");

        // rs2 = 0xAABBCCDD
        // byte bajo = DD
        // halfword bajo = CCDD

        // =========================
        // sb: Store Byte
        // StoreType = 00
        // =========================
        check(2'b00, 32'h00000000, 32'hAABBCCDD, 32'h000000DD, 4'b0001, "sb offset 0");
        check(2'b00, 32'h00000001, 32'hAABBCCDD, 32'h0000DD00, 4'b0010, "sb offset 1");
        check(2'b00, 32'h00000002, 32'hAABBCCDD, 32'h00DD0000, 4'b0100, "sb offset 2");
        check(2'b00, 32'h00000003, 32'hAABBCCDD, 32'hDD000000, 4'b1000, "sb offset 3");

        // =========================
        // sh: Store Halfword
        // StoreType = 01
        // =========================
        check(2'b01, 32'h00000000, 32'hAABBCCDD, 32'h0000CCDD, 4'b0011, "sh offset 0");
        check(2'b01, 32'h00000002, 32'hAABBCCDD, 32'hCCDD0000, 4'b1100, "sh offset 2");

        // =========================
        // sw: Store Word
        // StoreType = 10
        // =========================
        check(2'b10, 32'h00000000, 32'hAABBCCDD, 32'hAABBCCDD, 4'b1111, "sw");

        $display("===== FIN TB STORE UNIT =====");
        $finish;
    end

endmodule