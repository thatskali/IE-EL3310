//multiplexor de 2 entradas de 32 bits
//selecciona entre dos valores según la señal de control 'sel'
module mux21 (
    input  logic        sel,  // señal de control: 0 o 1
    input  logic [31:0] ina,  // entrada 0: sale cuando sel=0
    input  logic [31:0] inb,  // entrada 1: sale cuando sel=1
    output logic [31:0] out   // salida: el valor seleccionado
);
    assign out = (sel) ? inb : ina;

endmodule