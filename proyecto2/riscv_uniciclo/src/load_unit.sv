module load_unit (
    input  logic [31:0] read_data, //Salida de la memoria
    input  logic [2:0]  load_type, //Señal de control que indica el tipo de carga (lb, lh, lw, lbu, lhu)
    input  logic [31:0] alu_result, //Resultado de la ALU, usado para determinar el byte/halfword a cargar
    output logic [31:0] load_data // Datos finales a escribir en el registro destino después de la carga
);

    logic [7:0]  byte_selected;
    logic [15:0] half_selected;

    always_comb begin

        // =========================
        // Selección de byte
        // =========================
        case (alu_result[1:0])
            2'b00: byte_selected = read_data[7:0]; //Se toma el byte menos significativo de la ALUResult para determinar qué byte cargar
            2'b01: byte_selected = read_data[15:8];
            2'b10: byte_selected = read_data[23:16];
            2'b11: byte_selected = read_data[31:24];
            default: byte_selected = 8'b0;
        endcase

        // =========================
        // Selección de halfword
        // =========================
        case (alu_result[1])
            1'b0: half_selected = read_data[15:0]; //Se toma el bit 1 de la ALUResult para determinar qué halfword cargar (0 para los 16 bits menos significativos, 1 para los 16 bits más significativos)
            1'b1: half_selected = read_data[31:16];
            default: half_selected = 16'b0;
        endcase

        // =========================
        // Tipo de carga
        // =========================
        case (load_type)

            // lb
            3'b000:
                load_data = {{24{byte_selected[7]}}, byte_selected}; //Extensión de signo: se replica el bit más significativo del byte seleccionado (byte_selected[7]) 24 veces a la izquierda y luego se concatena con el byte seleccionado para formar un valor de 32 bits. Esto asegura que si el byte es negativo (bit 7 es 1), los bits superiores también serán 1, manteniendo el valor negativo en la extensión de signo.

            // lh
            3'b001:
                load_data = {{16{half_selected[15]}}, half_selected}; //Extensión de signo: se replica el bit más significativo del halfword seleccionado (half_selected[15]) 16 veces a la izquierda y luego se concatena con el halfword seleccionado para formar un valor de 32 bits. Esto asegura que si el halfword es negativo (bit 15 es 1), los bits superiores también serán 1, manteniendo el valor negativo en la extensión de signo.

            // lw
            3'b010:
                load_data = read_data; //Para lw, no se necesita extensión de signo ni selección de bytes, ya que se carga la palabra completa de 32 bits directamente desde la memoria.

            // lbu
            3'b100:
                load_data = {24'b0, byte_selected}; //Extensión de cero: se rellenan los 24 bits superiores con ceros y se concatena con el byte seleccionado para formar un valor de 32 bits. Esto asegura que el valor cargado siempre sea positivo, incluso si el byte seleccionado tiene su bit más significativo (bit 7) en 1.

            // lhu
            3'b101:
                load_data = {16'b0, half_selected}; //Extensión de cero: se rellenan los 16 bits superiores con ceros y se concatena con el halfword seleccionado para formar un valor de 32 bits. Esto asegura que el valor cargado siempre sea positivo, incluso si el halfword seleccionado tiene su bit más significativo (bit 15) en 1.

            default:
                load_data = 32'b0; 

        endcase
    end

endmodule