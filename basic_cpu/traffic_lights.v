module traffic_lights (CSR_in, CSR_out, DR_in, DR_out);
	input [7:0] CSR_in, DR_in;
	output [7:0] DR_out, CSR_out;
	
	assign DR_out = (CSR_in[4] == 1'b1) ? DR_in[7:0] : 8'd0;
	assign CSR_out = CSR_in[7:0];

endmodule