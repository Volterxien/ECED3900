module int_vect_entry (counter, clock, E, );
	input [3:0] counter;
	input clock, E;
	
	
	always @(negedge clock) begin
		operands = 1'b0;					// Default to using operands from instruction decoder
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
					PSW_PC <= 2'b00;					// Use the PSW
					data_rnum_dst <= 5'd16;				// Destination for the data bus (temp) (equivalent to DST)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
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
					addr_src <= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_rnum_src <= 5'd7;				// Source for the data bus (PC) (equivalent to SRCCON)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
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
					addr_src <= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_rnum_src <= 5'd5;				// Source for the data bus (LR) (equivalent to SRCCON)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
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
					addr_src <= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
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
					addr_src <= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
				end
				5: begin						// Assign the PSW to the PSW of the vector, clear the SLP bit, 
												// and assign the previous priority of the new PSW the value of the stored priority
					psw_bus_ctrl_iv <= 2'b01;			// Use the PSW from the interrupt vector
					
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
					data_rnum_dst <= 5'd7;				// Destination for the data bus (PC) (equivalent to DST)
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
				end
				7: begin						// Assign #FFFF to LR
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd21;					// Use MOV.W
					dbus_rnum_dst_iv <= 5'd5;			// Select the destination register for the data bus (LR)
					dbus_rnum_src_iv <= 5'd15;			// Select the source register for the data bus (-1)
					data_bus_ctrl = 7'b0001001;			// Write the src register to the dst register
					// Signal to indicate reset cpucycle to 4 rather than 1 during this
				end
				8: begin						// Clear the CEX state
					// Signal to clear the CEX state
				end
			endcase
		end
	end

endmodule