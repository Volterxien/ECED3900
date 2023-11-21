module pedest_button (CSR_in, CSR_out, button, DR_out);
	input [7:0] CSR_in;
	input button;
	output reg [7:0] DR_out;
	output wire [7:0] CSR_out;
	
	reg [7:0] CSR;
	
	initial begin
		CSR = CSR_in[7:0];
		DR_out = 8'd0;
	end
	
	assign CSR_out = CSR[7:0];
	
	always @(button, CSR_in) begin
		CSR = CSR_in[7:0];
		if (CSR_in[4] && button) begin
			DR_out[0] <= button;
			CSR[2] = 1'b1;	// Set the DBA bit
		end
	end	
endmodule