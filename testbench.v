`include "transmisor.v"
`include "receptor.v"
  

// Testbench Code Goes here
module mdio_tb;

reg         clk, reset, start_stb, CKP, CPH;

wire        MISO, MOSI, SCK, CS;

initial begin
	$dumpfile("resultados.vcd");
	$dumpvars(-1, U0);
	$dumpvars(-1, U1);
end


initial begin
  //Prueba 1: Modo0
  clk = 0;
  reset = 1;
  CKP=0;
  CPH=0;
  start_stb = 0;
  #25 reset = 0;
  #10 reset = 1;
  #60 start_stb = 1;
  #10 start_stb = 0;
  //Prueba 2: Modo1
  #1500 CPH=1;
  #60 start_stb = 1;
  #10 start_stb = 0;
  //Prueba 3: Modo2
  #1500 CKP=1;
  CPH=0;
  #60 start_stb = 1;
  #10 start_stb = 0;
  //Prueba 4: Modo3
  #1500 CKP=1;
  CPH=1;
  #60 start_stb = 1;
  #10 start_stb = 0;
  #1500 $finish;
end

always begin
 #5 clk = !clk;
end


receptor U0 (
/*AUTOINST*/
	     // Outputs
	     .MISO			(MISO),
	     // Inputs
	     .reset			(reset),
	     .CKP			(CKP),
	     .CPH			(CPH),
	     .MOSI			(MOSI),
	     .SCK			(SCK),
		 .CS			(CS));


transmisor U1 (
/*AUTOINST*/
	       // Outputs
	       .MOSI			(MOSI),
	       .SCK			(SCK),
		   //.reset			(reset),
	       // Inputs
	       .clk			(clk),
	       .reset			(reset),
	       .start_stb		(start_stb),
	       .CKP			(CKP),
	       .CPH			(CPH),
	       .MISO			(MISO),
		   .CS			(CS));


endmodule
