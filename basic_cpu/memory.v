/* 
 * The inferred RAM main memory for the XM-23 CPU
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	memory.v
 * Module: 		memory
 * Description: Module for instantiating and accessing main memory
 * Acknowledgements:
 * 		See xm23_cpu.v
 */
module memory (Clock, lb_in, ub_in, lb_addr, ub_addr, we_lb, we_ub, lb_out, ub_out);

	input Clock, we_lb, we_ub;
	input [7:0] lb_in, ub_in;
	input [15:0] lb_addr, ub_addr;
	
	output reg [7:0] lb_out, ub_out;

	reg [7:0] memory [0:16'hffff];
	
	initial begin
		$readmemh("memory.txt", memory, 0);
	end
	
	// Memory Upper Byte
	always @(posedge Clock) begin
		if (we_ub == 1'd1)
			memory[ub_addr[15:0]] <= ub_in[7:0];
		ub_out[7:0] <= memory[ub_addr[15:0]];
	end
	
	// Memory Lower Byte
	always @(posedge Clock) begin
		if (we_lb == 1'd1)
			memory[lb_addr[15:0]] <= lb_in[7:0];
		lb_out[7:0] <= memory[lb_addr[15:0]];
	end
	
endmodule