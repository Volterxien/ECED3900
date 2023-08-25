module int_vect_entry (counter, operands, word_byte, inc_iv, dec_iv, iv_cpu_rst, psw_entry_update, 
						clear_cex, PSW_ENT, data_src_iv, addr_src_iv, data_dst_iv, inst_type,
						iv_flags);
	input [3:0] counter;
	input [15:0] iv_flags;
	
	output reg operands, word_byte, inc_iv, dec_iv, iv_cpu_rst, psw_entry_update, clear_cex;
	output reg [6:0] data_bus_ctrl_iv, addr_bus_ctrl_iv, inst_type;
	output reg [1:0] PSW_ENT;
	output reg [4:0] data_src_iv, addr_src_iv, data_dst_iv;
	
	wire E;
	assign E = (iv_flags == 15'b0) ? 1'b0 : 1'b1;	// Set enable if any flag set
	
	
	always @(counter, E) begin
		operands = 1'b0;					// Default to using operands from instruction decoder
		clear_cex = 1'b0;					// Default to not clearing the CEX state
		psw_entry_update = 1'b0;			// Default to not updating the new PSW with new values
		if (E) begin
			case (counter)
				0: begin						// Load the PSW of the interrupt vector
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd33;					// Use LD.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// No pre/post inc/dec
					inc_iv <= 1'b0;
					dec_iv <= 1'b0;
					data_bus_ctrl_iv <= 7'b0000001;		// Read from MDR into Temp Register
					addr_bus_ctrl_iv <= 7'b0100000;		// Set the MAR to the address of the vector PSW
					PSW_ENT <= 2'b00;					// Use the PSW
					data_dst_iv <= 5'd16;				// Destination for the data bus (temp) (equivalent to DST)
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				1: begin						// Push PC to stack
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					data_bus_ctrl_iv <= 7'b0001000;		// Read from PC into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					addr_src_iv <= 5'd6;				// Source for the address bus (SP) (equivalent to DST)
					data_src_iv <= 5'd7;				// Source for the data bus (PC) (equivalent to SRCCON)
					data_dst_iv <= 5'd5;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				2: begin						// Push LR to stack
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					data_bus_ctrl_iv <= 7'b0001000;		// Read from LR into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_src_iv <= 5'd5;				// Source for the data bus (LR) (equivalent to SRCCON)
					data_dst_iv <= 5'd5;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				3: begin						// Push PSW to stack and record the PSW's current priority
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					data_bus_ctrl_iv <= 7'b0100000;		// Read from PSW into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_dst_iv <= 5'd5;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				4: begin						// Push CEX state to stack
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					data_bus_ctrl_iv <= 7'b0101000;		// Read from CEX state into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_dst_iv <= 5'd5;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				5: begin						// Assign the PSW to the PSW of the vector, clear the SLP bit, 
												// and assign the previous priority of the new PSW the value of the stored priority
					psw_bus_ctrl_iv <= 2'b10;			// Use the PSW from the interrupt vector (stored in temp reg
					data_src_iv <= 5'd16;				// Read the temp register into the PSW
					psw_entry_update = 1'b1;			// Signal to clear the SLP bit and assign the previous priority of
														// the new PSW to the value of the stored PSW
				end
				6: begin						// Assign the entry point of the handler to the PC
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd33;					// Use LD.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// No pre/post inc/dec
					inc_iv <= 1'b0;
					dec_iv <= 1'b0;
					data_bus_ctrl_iv <= 7'b0000001;		// Read from MDR into register file
					addr_bus_ctrl_iv <= 7'b0100000;		// Set the MAR to the address of the vector PSW
					PSW_ENT <= 2'b10;					// Use the entry point
					data_dst_iv <= 5'd7;				// Destination for the data bus (PC) (equivalent to DST)
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				7: begin						// Assign #FFFF to LR
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd21;					// Use MOV.W
					data_dst_iv <= 5'd5;				// Select the destination register for the data bus (LR)
					data_src_iv <= 5'd15;				// Select the source register for the data bus (-1)
					data_bus_ctrl_iv <= 7'b0001001;		// Write the src register to the dst register
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				8: begin						// Clear the CEX state
					clear_cex = 1'b1;					// Signal to clear the CEX state
				end
			endcase
		end
	end

endmodule