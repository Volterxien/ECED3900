module testbench ();
	// reg signals to provide inputs to the DUT
	reg [3:0] KEY;
	reg CLOCK_50;
	reg [17:0] SW;
	// wire signals to connect to outputs from the DUT
	wire [5:0] LEDG;
	wire [15:0] LEDR;
	wire [1:0] LEDR16_17;
	wire LEDG7;
	wire [6:0] HEX0;
	wire [6:0] HEX1;
	wire [6:0] HEX2;
	wire [6:0] HEX3;

	// instantiate the design under test
	xm23_cpu CPU(SW, HEX0, HEX1, HEX2, HEX3, LEDG, LEDG7, LEDR, LEDR16_17, KEY, CLOCK_50);

	// generate a 50 MHz periodic clock waveform
	always
		#10 CLOCK_50 <= ~CLOCK_50;

	initial
	begin
		CLOCK_50 <= 0;
		KEY[0] <= 0;
		KEY[3:1] <= 3'b111;
		SW <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		#10 KEY[0] <= 1;
		#10 KEY[0] <= 0;
		
	end // initial
endmodule