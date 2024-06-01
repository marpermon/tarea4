module receptor(
   // Outputs
   MISO, SCK, CS,
   // Inputs
   reset, CKP, CPH, MOSI
   );

  //Entradas y salidas
  output MISO;
  input  reset,CKP,CPH, MOSI, SCK, CS;

  //Variables intermedias
  reg [1:0]  estado_rec, prox_estado_rec;
  reg [15:0] dato_recep, prox_dato_recep;
  reg [4:0]  cuenta_bits, prox_cuenta_bits; //Cuenta bits de la transacción
 

  localparam IDLE         = 2'b01;
  localparam TRANSMISSION = 2'b10;

  assign edge_c = (CKP==CPH)? 1:0;//leemos en el flanco creciente?
  assign MISO = (estado_rec==TRANSMISSION)? dato_recep[15]:0;
  //Fip flops
  always @(posedge SCK || ~reset) begin
  if (edge_c)begin
    if (~reset) begin
      estado_rec        <= IDLE;
      dato_recep    <= 16'h0106;
      cuenta_bits   <= 0;
    end else begin
      estado_rec    <= prox_estado_rec;
      dato_recep    <= prox_dato_recep;
      cuenta_bits   <= prox_cuenta_bits;
    end
  end
  end
  
  always @(posedge ~SCK || ~reset) begin
  if (~edge_c)begin
    if (~reset) begin
      estado_rec        <= IDLE;
      dato_recep    <= 16'h0106;
      cuenta_bits   <= 0;
    end else begin
      estado_rec        <= prox_estado_rec;
      dato_recep    <= prox_dato_recep;
      cuenta_bits   <= prox_cuenta_bits;
    end
  end
  end


  //LOGICA COMBINACIONAL
 always @(*) begin

  prox_estado_rec = estado_rec;
  prox_dato_recep = dato_recep;
  prox_cuenta_bits = cuenta_bits;
  
    case (estado_rec)
      IDLE:begin
        prox_cuenta_bits = 0; 
      if (~CS)  begin 
          prox_estado_rec = TRANSMISSION; 
          prox_dato_recep= (dato_recep<<1)+MOSI;
          prox_cuenta_bits = cuenta_bits+1;
        end
        end
      TRANSMISSION: 
        begin
          prox_dato_recep= (dato_recep<<1)+MOSI;
          if (cuenta_bits == 15) begin
            prox_estado_rec = IDLE;// se pone antes que eltransmisor para que agarre el sck antes de que este se apague
            prox_cuenta_bits = 0; 
          end
          else prox_cuenta_bits = cuenta_bits+1;
        end
	  
      default:  
        begin
	  prox_estado_rec = IDLE;
	  prox_dato_recep = 0;
	end
    endcase;
  end

endmodule
