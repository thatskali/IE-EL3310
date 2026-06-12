// multiplexor de 4 entradas de 32 bits
// selecciona entre cuatro valores según la señal de control 'sel'
module mux41 (
    input  logic [1:0]  sel,   // señal de control: 00, 01, 10, 11
    input  logic [31:0] ina,   // entrada 0: sale cuando sel=00
    input  logic [31:0] inb,   // entrada 1: sale cuando sel=01
    input  logic [31:0] inc,   // entrada 2: sale cuando sel=10
    input  logic [31:0] ind,   // entrada 3: sale cuando sel=11 ← agregar
    output logic [31:0] out
);
    assign out = (sel == 2'b00) ? ina :
                 (sel == 2'b01) ? inb :
                 (sel == 2'b10) ? inc :  // ← hacer explícito
                                   ind;  // sel=11 → LUI

endmodule