module pedest_button (CSR_in, CSR_out, button, DR_out);
	input [7:0] CSR_in;
	input button;
	output reg [7:0] CSR_out, DR_out;
	
	initial begin
		CSR_out = 8'd0;
		DR_out = 8'd0;
	end
	
	always @(posedge button) begin
		if (CSR_in[4]) begin
			DR_out[0] <= button;
			CSR_out[2] <= 1'b1;	// Set the DBA bit
		end
	end	
endmodule