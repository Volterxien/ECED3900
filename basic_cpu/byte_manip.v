/* 
 * Module for manipulating bytes
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	byte_manip.v
 * Module: 		byte_manip
 * Description: Handles the MOV* and SWPB instructions for XM-23
 * Acknowledgements:
 *		See xm23_cpu.v
 */
module byte_manip(op, dst_in, dst_out, byte_val);
	input [2:0] op;
	input [15:0] dst_in;
	input [7:0] byte_val;
	
	output reg [15:0] dst_out;
	
	reg [15:0] dst_val;
	reg [15:0] high_clr = 16'h00ff;
	reg [15:0] high_set = 16'hff00;
	reg [7:0] temp;
	
	always @(op, dst_in, byte_val) begin
		dst_val = dst_in[15:0];
		case(op)
			0: 	begin	// MOVL
				dst_val[7:0] = byte_val[7:0];
				dst_out = dst_val[15:0];
				end
			1:	begin	// MOVLZ
				dst_val[7:0] = byte_val[7:0];
				dst_out = dst_val[15:0] & high_clr[15:0];
				end
			2:	begin	// MOVLS
				dst_val[7:0] = byte_val[7:0];
				dst_out = dst_val[15:0] | high_set[15:0];
				end
			3:	begin	// MOVH
				dst_val[15:8] = byte_val[7:0];
				dst_out = dst_val[15:0];
				end
			4:	begin	// SWPB
				temp = dst_val[15:8];
				dst_val[15:8] = dst_val[7:0];
				dst_val[7:0] = temp[7:0];
				dst_out = dst_val[15:0];
				end
		endcase		
	end
endmodule