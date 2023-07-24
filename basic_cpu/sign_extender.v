module sign_extender(in, out, msb_num, E);
	input [15:0] in;
	input [3:0] msb_num;
	input E;
	output reg [15:0] out;
	
	reg [15:0] extension = 16'hffff;
	
	always @(posedge E) begin
		if (in[msb_num] == 1'b1)
			out <= in[15:0] | (extension[15:0] << msb_num[3:0]);
		else
			out <= in[15:0];
	end
endmodule