module transmisor(
   // Outputs
   MOSI, SCK, CS, reset_rec,
     // Inputs
   clk, reset, start_stb, CKP, CPH, MISO
   );

  //Entradas y salidas
  input clk,reset,start_stb,CKP,CPH, MISO;
  output reg MOSI, CS,reset_rec;
  output     SCK;

  localparam IDLE         = 2'b01;
  localparam TRANSMISSION = 2'b10;
  localparam DIV_FREQ = 3;

  //Variables intermedias
  reg [1:0]  estado_trans, prox_estado_trans;
  reg [15:0] dato_trans, prox_dato_trans;
  reg [4:0]  cuenta_bits, prox_cuenta_bits; //Cuenta bits de la transacción
  reg [DIV_FREQ-1:0] div_freq;
  reg SCK_anterior;
  reg nxt_MOSI;
  reg nxt_reset_rec;
  wire edge_c;
   
  

  assign SCK = div_freq[DIV_FREQ-1];
  assign edge_c = (CKP==CPH)? 1:0;
  

   always @(posedge clk) begin
    if (~reset) begin
      estado_trans        <= IDLE;
      dato_trans    <= 0;
      SCK_anterior  <= 0;
      div_freq      <= CKP<<DIV_FREQ-1;
      cuenta_bits   <= 0;
      dato_trans    <= 16'h0509; //luego veremos si podemos hacer una entrada
      MOSI          <= 0;
      reset_rec     <= 1;
    end else begin
      estado_trans  <= prox_estado_trans;
      if (estado_trans==IDLE) div_freq <= CKP<<DIV_FREQ-1; //vamos a ver si esto lo enciende en el momento adecuado
      else div_freq <= div_freq+1;
      reset_rec     <= nxt_reset_rec;
    end
  end

  always @(posedge SCK) begin
    if (edge_c==1)begin
      dato_trans    <= prox_dato_trans;
      SCK_anterior  <= SCK;
      cuenta_bits   <= prox_cuenta_bits;
      MOSI          <=nxt_MOSI; 
    end
  end

  always @(posedge ~SCK) begin
    if (edge_c==0)begin
      dato_trans    <= prox_dato_trans;
      SCK_anterior  <= SCK;
      cuenta_bits   <= prox_cuenta_bits;
      MOSI          <=nxt_MOSI;
    end
  end

  //Logica combinacional
  always @(*) begin
  prox_estado_trans        = estado_trans;
  prox_dato_trans = dato_trans;
  //MOSI=0;
  nxt_MOSI = MOSI;
  prox_cuenta_bits = cuenta_bits;
  nxt_reset_rec=reset_rec;
  CS=1;
  
    case (estado_trans)
      IDLE:
        begin
          prox_cuenta_bits = 0;
          CS=1;
      if (start_stb) begin 
        prox_estado_trans = TRANSMISSION;        
          end
        end
      
      /*RESETEAR_REC:begin
          if (div_freq<(2**DIV_FREQ)-1) nxt_reset_rec=0;//7
          else begin 
          nxt_reset_rec=1;
          prox_estado_trans=TRANSMISSION;
          end
            //CS=0; //para que se prenda de una vez, sino main y subnode se van a descoordinar  
          end*/

      TRANSMISSION: begin  
        CS=0;
          nxt_MOSI =dato_trans[15];
          prox_dato_trans= (dato_trans<<1)+MISO;
          if (cuenta_bits == 31) prox_estado_trans = IDLE;
          else prox_cuenta_bits = cuenta_bits+1;
        end
      default:  
        begin
          prox_estado_trans = IDLE;
          prox_dato_trans = dato_trans;
        end
    endcase;
  end


endmodule
