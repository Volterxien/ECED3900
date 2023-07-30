module sign_extender(in, out, msb_num, shift_first, E);
	input [15:0] in;
	input [3:0] msb_num;
	input shift_first, E;
	output reg [15:0] out;
	
	reg [15:0] extension = 16'hffff;
	reg [15:0] intermediate;
	
	always @(posedge E) begin
		if (shift_first)
			intermediate = in[15:0] << 1;
		else
			intermediate = in[15:0];
		
		if (intermediate[msb_num[3:0]] == 1'b1)
			out = intermediate[15:0] | (extension[15:0] << msb_num[3:0]);
		else
			out = intermediate[15:0];
	end
endmodule