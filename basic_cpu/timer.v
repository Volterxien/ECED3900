module timer(CSR_in, DR_in, CSR_out, clock);
	input [7:0] CSR_in, DR_in;
	input clock;
	output reg [7:0] CSR_out;
	
	reg [31:0] clock_table [0:255];	// Table storing the number of clock cycles needed per tick for each prescaler
	reg [31:0] count = 32'd0;
	
	initial begin
		$readmemh("clock_table.txt", clock_table, 0);
		CSR_out = 8'd0;
	end
	
	always @(posedge clock) begin
		if (CSR_in[4]) begin
			if (count == clock_table[DR_in[7:0]][31:0]) begin	// Count reached for specific prescaler
				count <= 32'b0;					// Clear the count
				CSR_out[2] <= 1'b1;				// Set the DBA bit
				if (CSR_in[2]) 
					CSR_out[3] <= 1'b1;			// Set the OF bit if the DBA bit was already set
			end
			else
				count <= count + 32'b1;			// Increment the count
		end
	end
endmodule