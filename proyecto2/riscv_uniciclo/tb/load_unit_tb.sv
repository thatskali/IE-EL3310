`timescale 1ns/1ps

module tb_load_unit;

    logic [31:0] read_data;
    logic [2:0]  load_type;
    logic [31:0] alu_result;
    logic [31:0] load_data;

    load_unit dut (
        .read_data  (read_data),
        .load_type  (load_type),
        .alu_result (alu_result),
        .load_data  (load_data)
    );

    task check;
        input [2:0]  lt;
        input [31:0] addr;
        input [31:0] data;
        input [31:0] expected;
        input string name;
        begin
            load_type  = lt;
            alu_result = addr;
            read_data  = data;
            #1;

            if (load_data !== expected) begin
                $display("ERROR en %s", name);
                $display("  read_data  = %h", read_data);
                $display("  alu_result = %h", alu_result);
                $display("  load_type  = %b", load_type);
                $display("  esperado   = %h", expected);
                $display("  obtenido   = %h", load_data);
            end else begin
                $display("OK: %s -> %h", name, load_data);
            end
        end
    endtask

    initial begin
        $display("===== TB LOAD UNIT =====");

        // read_data = 0x80_7F_FF_01
        // byte0 = 01
        // byte1 = FF
        // byte2 = 7F
        // byte3 = 80
        read_data = 32'h807FFF01;

        // =========================
        // lb: Load Byte signed
        // =========================
        check(3'b000, 32'h00000000, 32'h807FFF01, 32'h00000001, "lb offset 0");
        check(3'b000, 32'h00000001, 32'h807FFF01, 32'hFFFFFFFF, "lb offset 1");
        check(3'b000, 32'h00000002, 32'h807FFF01, 32'h0000007F, "lb offset 2");
        check(3'b000, 32'h00000003, 32'h807FFF01, 32'hFFFFFF80, "lb offset 3");

        // =========================
        // lbu: Load Byte unsigned
        // =========================
        check(3'b100, 32'h00000000, 32'h807FFF01, 32'h00000001, "lbu offset 0");
        check(3'b100, 32'h00000001, 32'h807FFF01, 32'h000000FF, "lbu offset 1");
        check(3'b100, 32'h00000002, 32'h807FFF01, 32'h0000007F, "lbu offset 2");
        check(3'b100, 32'h00000003, 32'h807FFF01, 32'h00000080, "lbu offset 3");

        // =========================
        // lh: Load Half signed
        // half bajo = FF01
        // half alto = 807F
        // =========================
        check(3'b001, 32'h00000000, 32'h807FFF01, 32'hFFFFFF01, "lh offset 0");
        check(3'b001, 32'h00000002, 32'h807FFF01, 32'hFFFF807F, "lh offset 2");

        // =========================
        // lhu: Load Half unsigned
        // =========================
        check(3'b101, 32'h00000000, 32'h807FFF01, 32'h0000FF01, "lhu offset 0");
        check(3'b101, 32'h00000002, 32'h807FFF01, 32'h0000807F, "lhu offset 2");

        // =========================
        // lw: Load Word
        // =========================
        check(3'b010, 32'h00000000, 32'h807FFF01, 32'h807FFF01, "lw");

        $display("===== FIN TB LOAD UNIT =====");
        $finish;
    end

endmodule 