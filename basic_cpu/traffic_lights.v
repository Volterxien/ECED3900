/* 
 * Traffic light device driver for XM-23 CPU.
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	traffic_lights.v
 * Module: 		traffic_lights
 * Description: Manages the CSR for the traffic light device.
 * Acknowledgements:
 */
module traffic_lights (CSR_in, CSR_out, DR_in, DR_out);
	input [7:0] CSR_in, DR_in;
	output [7:0] DR_out, CSR_out;
	
	assign DR_out = (CSR_in[4] == 1'b1) ? DR_in[7:0] : 8'd0;
	assign CSR_out = CSR_in[7:0];

endmodule