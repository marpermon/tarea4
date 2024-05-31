`include "transmisor.v"
`include "receptor.v"
  

// Testbench Code Goes here
module mdio_tb;

reg         clk, reset, start_stb, CKP, CPH;

wire        MISO, MOSI, SCK, CS, reset_rec;

initial begin
	$dumpfile("resultados.vcd");
	$dumpvars(-1, U0);
	$dumpvars(-1, U1);
end


initial begin
  clk = 0;
  reset = 1;
  CKP=0;
  CPH=0;
  start_stb = 0;
  #25 reset = 0;
  #10 reset = 1;
  #20 start_stb = 1;
  #10 start_stb = 0;
  #4000 $finish;
end

always begin
 #5 clk = !clk;
end


receptor U0 (
/*AUTOINST*/
	     // Outputs
	     .MISO			(MISO),
	     // Inputs
	     .reset_rec			(reset_rec),
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
		   .reset_rec			(reset_rec),
	       // Inputs
	       .clk			(clk),
	       .reset			(reset),
	       .start_stb		(start_stb),
	       .CKP			(CKP),
	       .CPH			(CPH),
	       .MISO			(MISO),
		   .CS			(CS));


endmodule
