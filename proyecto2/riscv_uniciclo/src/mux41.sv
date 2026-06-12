//multiplexor de 3 entradas de 32 bits
//selecciona entre tres valores según la señal de control 'sel'
module mux41 (
    input  logic [1:0]  sel,  // señal de control: 00, 01 o 10
    input  logic [31:0] ina,  // entrada 0: sale cuando sel=00
    input  logic [31:0] inb,  // entrada 1: sale cuando sel=01
    input  logic [31:0] inc,  // entrada 2: sale cuando sel=10
    output logic [31:0] out   // salida: el valor seleccionado
);
    assign out = (sel == 2'b00) ? ina :  // sel=00 → sale ina
                 (sel == 2'b01) ? inb :  // sel=01 → sale inb
                                  inc;   // sel=10 → sale inc

endmodule