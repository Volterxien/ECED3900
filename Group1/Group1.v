module Group1 (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    output reg [6:0] HEX0;
	output reg [6:0] HEX1;
	output reg [6:0] HEX2;
	output reg [6:0] HEX3;
	output reg [6:0] HEX4;
	output reg [6:0] HEX5;
	
	initial begin
		HEX0 = 7'b1111001;
		HEX1 = 7'b1111111;
		HEX1 = 7'b0001100;
		HEX2 = 7'b0011101;
		HEX3 = 7'b0011100;
		HEX4 = 7'b1011110;
		HEX5 = 7'b0010000;
	end
	
endmodule