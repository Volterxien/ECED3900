/* 
 * Timer device driver for XM-23 CPU.
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	timer.v
 * Module: 		timer
 * Description: Manages the CSR for the timer device.
 * Acknowledgements:
 */
module timer(CSR_in, DR_in, CSR_out, clock);
	input [7:0] CSR_in, DR_in;
	input clock;
	output wire [7:0] CSR_out;
	
	reg [31:0] clock_table [0:255];	// Table storing the number of clock cycles needed per tick for each prescaler
	reg [31:0] count = 32'd0;
	reg [7:0] CSR;
	
	initial begin
		$readmemh("clock_table.txt", clock_table, 0);
		CSR = CSR_in[7:0];
	end
	
	assign CSR_out = CSR[7:0];
	
	always @(posedge clock) begin
		CSR = CSR_in[7:0];
		if (CSR_in[4]) begin
			if (count == clock_table[DR_in[7:0]][31:0]) begin	// Count reached for specific prescaler
				count <= 32'b0;					// Clear the count
				CSR[2] = 1'b1;				// Set the DBA bit
				if (CSR_in[2]) 
					CSR[3] = 1'b1;			// Set the OF bit if the DBA bit was already set
			end
			else
				count <= count + 32'b1;			// Increment the count
		end
	end
endmodule