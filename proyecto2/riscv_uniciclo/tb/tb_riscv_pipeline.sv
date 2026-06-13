`timescale 1ns/1ps

module tb_riscv_pipeline;

    logic clk;
    logic rst;

    string memfile;
    integer i;

    riscv_pipeline dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check;
        input [31:0] obtenido;
        input [31:0] esperado;
        input [255:0] mensaje;
        begin
            if (obtenido === esperado)
                $display("PASS: %s = %h", mensaje, obtenido);
            else
                $display("FAIL: %s = %h (esperado %h)",
                         mensaje, obtenido, esperado);
        end
    endtask

    task verificar_programa1;
        begin
            $display("Verificando programa1...");

            check(dut.rf.regs[1],  32'h00000064, "x1");
            check(dut.rf.regs[2],  32'h12345000, "x2");
            check(dut.rf.regs[3],  32'h0000007f, "x3");
            check(dut.rf.regs[4],  32'h0000007f, "x4");
            check(dut.rf.regs[5],  32'h0000012c, "x5");
            check(dut.rf.regs[6],  32'h0000012c, "x6");
            check(dut.rf.regs[7],  32'h12345000, "x7");

            check(dut.rf.regs[8],  32'h0000000a, "x8");
            check(dut.rf.regs[9],  32'h00000003, "x9");
            check(dut.rf.regs[10], 32'h0000000d, "x10");
            check(dut.rf.regs[11], 32'h00000007, "x11");
            check(dut.rf.regs[12], 32'h00000009, "x12");
            check(dut.rf.regs[13], 32'h0000000f, "x13");
            check(dut.rf.regs[14], 32'h0000000b, "x14");
            check(dut.rf.regs[15], 32'h0000000b, "x15");
        end
    endtask

    task verificar_programa2;
        begin
            $display("Verificando programa2...");

            check(dut.rf.regs[1],  32'd5,        "x1");
            check(dut.rf.regs[2],  32'd5,        "x2");
            check(dut.rf.regs[3],  32'd2,        "x3");

            check(dut.rf.regs[5],  32'h12345000, "x5 (LUI)");
            check(dut.rf.regs[6],  32'hABCDE000, "x6 (LUI)");
            check(dut.rf.regs[7],  32'h12345001, "x7 (ADDI)");

            check(dut.rf.regs[8],  32'd1,        "x8");
            check(dut.rf.regs[10], 32'd0,        "x10");

            check(dut.rf.regs[20], 32'd0,  "x20");
            check(dut.rf.regs[21], 32'd1,  "x21");
            check(dut.rf.regs[22], 32'd99, "x22");
        end
    endtask

    initial begin
        if (!$value$plusargs("MEM=%s", memfile)) begin
            $display("ERROR: no se paso +MEM=archivo.mem");
            $finish;
        end

        $display("Cargando programa: %s", memfile);

        rst = 1;
        #20;
        rst = 0;

        repeat (120)
            @(posedge clk);

        $display("");
        $display("====================================");
        $display(" REGISTER FILE FINAL");
        $display("====================================");

        for (i = 0; i < 32; i = i + 1)
            $display("x%-2d = %h", i, dut.rf.regs[i]);

       

        $display("");
        $display("====================================");
        $display(" BRANCH PREDICTOR STATS");
        $display("====================================");

        $display("Branches evaluados        = %0d",
                dut.BranchCount);

        $display("Predicciones tomadas   = %0d",
                dut.CorrectPredictions);


        $display("====================================");


        $display("");
        $display("====================================");
        $display(" RESULTADOS FINALES");
        $display("====================================");

        if (memfile == "programas/programa1.mem")
            verificar_programa1();
        else if (memfile == "programas/programa2.mem")
            verificar_programa2();
        else
            $display("ERROR: programa no reconocido: %s", memfile);



        $display("");
        $display("====================================");
        $display(" FIN DE SIMULACION");
        $display("====================================");

        $finish;
    end




    always @(posedge clk) begin
        if (!rst && (dut.BranchE || dut.MispredictE)) begin
            $display(
                "t=%0t | PCF=%h | InstrD=%h | PredF=%b PredE=%b | BranchE=%b TakenE=%b | Mispredict=%b | PCSrcE=%b | FlushD=%b FlushE=%b",
                $time,
                dut.PCF,
                dut.InstrD,
                dut.PredictTakenF,
                dut.PredictedTakenE,
                dut.BranchE,
                dut.BranchTakenE,
                dut.MispredictE,
                dut.PCSrcE,
                dut.FlushD,
                dut.FlushE
            );
        end
    end



endmodule