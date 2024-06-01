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
  reg nxt_MOSI;
  reg nxt_reset_rec;
  wire edge_c;
   
  

  assign SCK = div_freq[DIV_FREQ-1];
  assign edge_c = (CKP==CPH)? 1:0;
  

   always @(posedge clk) begin
    if (~reset) begin
      estado_trans        <= IDLE;
      dato_trans    <= 0;
      div_freq      <= CKP<<DIV_FREQ-1;
      cuenta_bits   <= 0;
      dato_trans    <= 16'h0509; //luego veremos si podemos hacer una entrada
      //MOSI          <= 0;
      reset_rec     <= 1;
    end else begin
      estado_trans  <= prox_estado_trans;
      if (estado_trans==IDLE) div_freq <= CKP<<DIV_FREQ-1; //vamos a ver si esto lo enciende en el momento adecuado
      else div_freq <= div_freq+1;
      reset_rec     <= nxt_reset_rec;
      cuenta_bits   <= prox_cuenta_bits;
    end
  end

  always @(posedge SCK) begin
    if (edge_c==1)begin
      dato_trans    <= prox_dato_trans;
      
      //MOSI          <=nxt_MOSI; 
    end
  end

  always @(posedge ~SCK) begin
    if (edge_c==0)begin
      dato_trans    <= prox_dato_trans;
      //cuenta_bits   <= prox_cuenta_bits;
      //MOSI          <=nxt_MOSI;
    end
  end

  //Logica combinacional
  always @(*) begin
  prox_estado_trans        = estado_trans;
  prox_dato_trans = dato_trans;
  MOSI=0;
  //MOSI = MOSI;
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
    

      TRANSMISSION: begin  
        CS=0;
          MOSI =dato_trans[15];
          prox_dato_trans= (dato_trans<<1)+MISO;
          if (cuenta_bits == 16) prox_estado_trans = IDLE;
          else begin 
            if (((edge_c)&&(div_freq == (2**(DIV_FREQ-1))-1)) || ((~edge_c)&&(div_freq == (2**(DIV_FREQ))-1))) prox_cuenta_bits = cuenta_bits+1;

          end
        end
      default:  
        begin
          prox_estado_trans = IDLE;
          prox_dato_trans = dato_trans;
        end
    endcase;
  end


endmodule
