module receptor(
   // Outputs
   MISO, SCK, CS,
   // Inputs
   reset_rec, CKP, CPH, MOSI
   );

  //Entradas y salidas
  output reg MISO;
  input  reset_rec,CKP,CPH, MOSI, SCK, CS;

  //Variables intermedias
  reg [1:0]  estado_rec, prox_estado_rec;
  reg [15:0] dato_recep, prox_dato_recep;
  reg [4:0]  cuenta_bits, prox_cuenta_bits; //Cuenta bits de la transacción
  reg nxt_MISO;

  localparam IDLE         = 2'b01;
  localparam TRANSMISSION = 2'b10;

  assign edge_c = (CKP==CPH)? 1:0;//leemos en el flanco creciente?
  //Fip flops
  always @(posedge SCK || reset) begin
  if (edge_c)begin
    if (~reset_rec) begin
      estado_rec        <= IDLE;
      dato_recep    <= 16'h0106;
      MISO          <=0;
      cuenta_bits   <= 0;
    end else begin
      estado_rec    <= prox_estado_rec;
      dato_recep    <= prox_dato_recep;
      cuenta_bits   <= prox_cuenta_bits;
      MISO          <= nxt_MISO;
    end
  end
  end
  
  always @(posedge ~SCK) begin
  if (~edge_c)begin
    if (~reset_rec) begin
      estado_rec        <= IDLE;
      dato_recep    <= 16'h0106;
      MISO          <= 0;
      cuenta_bits   <= 0;
    end else begin
      estado_rec        <= prox_estado_rec;
      dato_recep    <= prox_dato_recep;
      MISO          <= nxt_MISO;
      cuenta_bits   <= prox_cuenta_bits;
    end
  end
  end


  //LOGICA COMBINACIONAL
 always @(*) begin

  prox_estado_rec        = estado_rec;
  prox_dato_recep = dato_recep;
  nxt_MISO = MISO;
  //MISO=0;
  prox_cuenta_bits = cuenta_bits;
  
    case (estado_rec)
      IDLE:begin
        prox_cuenta_bits = 0; 
      if (~CS)  prox_estado_rec = TRANSMISSION;
        end
      TRANSMISSION: 
        begin
          //MISO = dato_recep[15]
          nxt_MISO = dato_recep[15];
          prox_dato_recep= (dato_recep<<1)+MOSI;
          if (cuenta_bits == 31) prox_estado_rec = IDLE;
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
