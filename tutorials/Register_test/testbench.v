`timescale 1ns / 1ps

module testbench ( );
    	// declare reg signals for inputs to the design under test
    	reg [16:0] SW;
    	
    	// declare wire signals for outputs from the design under test
    	wire [6:0] HEX0;
	wire [6:0] HEX1;
	wire [6:0] HEX2;
	wire [6:0] HEX3;

    	// instantiate the design under test
    	register_test U1 (SW, HEX0, HEX1, HEX2, HEX3);

    	// assign values to the DUT inputs at various simulation times
    	initial 
    	begin
        	SW <= 0;
		SW[16] <= 1'b1;
        	#20 SW <= 16'hFFFF;
		#5 SW[16] <= 1'b0;
		#5 SW[16] <= 1'b1;
        	#20 SW <= 16'hFFFE;
		#5 SW[16] <= 1'b0;
		#5 SW[16] <= 1'b1;
		#5 SW[16] <= 1'b0;
		#5 SW[16] <= 1'b1;
		#5 SW[16] <= 1'b0;
		#5 SW[16] <= 1'b1;
    	end // initial
endmodule
