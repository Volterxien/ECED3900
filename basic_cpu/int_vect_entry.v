module int_vect_entry (counter, operands, word_byte, inc_iv, dec_iv, iv_cpu_rst, psw_entry_update, 
						clear_cex, PSW_ENT, data_src_iv, addr_src_iv, data_dst_iv, inst_type,
						rst_counter, iv_enter, iv_return, load_cex, clr_slp_bit, rec_pre_pri,
						psw_bus_ctrl_iv, new_curr_pri, svc_inst, curr_pri, call_pri_flt, prev_pri, 
						pic_in, use_pic_vect, data_bus_ctrl_iv, addr_bus_ctrl_iv, prpo_iv);
	input [3:0] counter;
	input iv_enter, iv_return;
	input svc_inst;							// Whether the trap instruction is executed
	input [2:0] new_curr_pri, curr_pri, prev_pri;
	input [7:0] pic_in;
	
	output reg operands, word_byte, inc_iv, dec_iv, iv_cpu_rst, psw_entry_update, clear_cex, rst_counter;
	output reg load_cex, clr_slp_bit, rec_pre_pri, call_pri_flt, use_pic_vect, prpo_iv;
	output reg [6:0] data_bus_ctrl_iv, addr_bus_ctrl_iv, inst_type;
	output reg [1:0] PSW_ENT, psw_bus_ctrl_iv;
	output reg [4:0] data_src_iv, addr_src_iv, data_dst_iv;
	
	wire E;
	reg svc_in_prog;					// Storage of the trap indicator
	
	initial begin
		operands = 1'b0;					// Default to using operands from instruction decoder
		clear_cex = 1'b0;					// Default to not clearing the CEX state
		load_cex = 1'b0;					// Default to not loading value of CEX from MDR
		clr_slp_bit = 1'b0;					// Default to not clearing the PSW SLP bit
		iv_cpu_rst <= 1'b0;					// Default to not resetting the CPU to step 5
		rec_pre_pri = 1'b0;					// Default to not recording the previous priority
		psw_entry_update = 1'b0;			// Default to not updating the new PSW with new values
		rst_counter = 1'b0;					// Default to not reset the interrupt vector counter
		call_pri_flt = 1'b0;				// Default to not calling a priority fault from the trap
		use_pic_vect = 1'b0;				// Default to not using the PIC vector number
		svc_in_prog = 1'b0;
		data_bus_ctrl_iv = 7'b1111111;
		addr_bus_ctrl_iv = 7'b1111111;
		psw_bus_ctrl_iv = 2'b11;
	end
	
	
	always @(counter, iv_enter, iv_return) begin
		operands = 1'b0;					// Default to using operands from instruction decoder
		clear_cex = 1'b0;					// Default to not clearing the CEX state
		load_cex = 1'b0;					// Default to not loading value of CEX from MDR
		clr_slp_bit = 1'b0;					// Default to not clearing the PSW SLP bit
		iv_cpu_rst <= 1'b0;					// Default to not resetting the CPU to step 5
		rec_pre_pri = 1'b0;					// Default to not recording the previous priority
		psw_entry_update = 1'b0;			// Default to not updating the new PSW with new values
		rst_counter = 1'b0;					// Default to not reset the interrupt vector counter
		call_pri_flt = 1'b0;				// Default to not calling a priority fault from the trap
		use_pic_vect = 1'b0;				// Default to not using the PIC vector number
		psw_bus_ctrl_iv = 2'b11;
		data_bus_ctrl_iv = 7'b1111111;
		addr_bus_ctrl_iv = 7'b1111111;
		
		if (iv_enter == 1'b1) begin			// Entry Routine
			case (counter)
				1: begin						// Load the PSW of the interrupt vector
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					svc_in_prog = svc_inst;				// Assign whether a trap is taking place
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
				2: begin						// Push PC to stack
					if ((svc_in_prog == 1'b1) && (new_curr_pri < curr_pri)) begin
						call_pri_flt = 1'b1;				// Call the priority fault
						rst_counter = 1'b1;					// Signal to reset the interrupt vector counter
					end
					else begin
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
						data_dst_iv <= 5'd6;				// Destination to update post-dec value
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
				end
				3: begin						// Push LR to stack
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
					data_dst_iv <= 5'd6;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				4: begin						// Push PSW to stack and record the PSW's current priority
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					data_bus_ctrl_iv <= 7'b0100000;		// Read from PSW into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to DST)
					data_src_iv <= 5'd5;				// Source for the data bus (LR) (equivalent to SRCCON)
					data_dst_iv <= 5'd6;				// Destination to update post-dec value
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				5: begin						// Push CEX state to stack
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd34;					// Use ST.W
					word_byte <= 1'b0;					// Word operation
					prpo_iv <= 1'b0;					// Post decrement
					inc_iv <= 1'b0;
					dec_iv <= 1'b1;
					data_bus_ctrl_iv <= 7'b0101000;		// Read from CEX state into MDR
					addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
					addr_src_iv <= 5'd6;				// Source for the address bus (SP) (equivalent to DST)
					data_src_iv <= 5'd5;				// Source for the data bus (LR) (equivalent to SRCCON)
					data_dst_iv <= 5'd6;				// Destination to update post-dec value
					rec_pre_pri = 1'b1;					// Record the previous CPU priority
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				6: begin						// Assign the PSW to the PSW of the vector, clear the SLP bit, 
												// and assign the previous priority of the new PSW the value of the stored priority
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd50;					// Use invalid instruction					
					psw_bus_ctrl_iv <= 2'b10;			// Use the PSW from the interrupt vector (stored in temp reg)
					data_src_iv <= 5'd16;				// Read the temp register into the PSW
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				7: begin						// Assign the entry point of the handler to the PC
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					psw_entry_update = 1'b1;			// Signal assign the previous priority of the new PSW to the value of the stored PSW
					clr_slp_bit = 1'b1;					// Clear the SLP bit
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
				8: begin						// Assign #FFFF to LR
					operands = 1'b1;					// Utilize operands from interrupt vector entry block
					inst_type <= 7'd21;					// Use MOV.W
					data_dst_iv <= 5'd5;				// Select the destination register for the data bus (LR)
					data_src_iv <= 5'd15;				// Select the source register for the data bus (-1)
					data_bus_ctrl_iv <= 7'b0001001;		// Write the src register to the dst register
					iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
				end
				9: begin						// Clear the CEX state
					operands = 1'b1;
					clear_cex = 1'b1;					// Signal to clear the CEX state
					rst_counter = 1'b1;					// Signal to reset the interrupt vector counter
				end
				10: begin						// Ensure counter is reset
					operands = 1'b1;
					inst_type <= 7'd50;					// Use invalid instruction to reset CPU cycle
					rst_counter = 1'b1;					// Signal to reset the interrupt vector counter
				end
			endcase
		end
		else if (iv_return == 1'b1) begin
			if ((pic_in[7] == 1'b0) || ((pic_in[7] == 1'b1) && (pic_in[6:4] < prev_pri[2:0]))) begin
				case (counter)
					1: begin						// Pull the CEX state 
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd33;					// Use LD.W
						load_cex = 1'b1;					// Signal to load value of CEX from MDR
						word_byte <= 1'b0;					// Word operation
						prpo_iv <= 1'b0;					// Post increment
						inc_iv <= 1'b1;
						dec_iv <= 1'b0;
						data_bus_ctrl_iv <= 7'b0111111;		// Invalid option 
						data_dst_iv <= 5'd6;				// Destination to update post-dec value
						addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
						addr_src_iv <= 5'd6;				// Source for the address bus (SP) (equivalent to DST)
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					2: begin						// Pull PSW from stack
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd33;					// Use LD.W
						word_byte <= 1'b0;					// Word operation
						prpo_iv <= 1'b0;					// Post increment
						inc_iv <= 1'b1;
						dec_iv <= 1'b0;
						data_bus_ctrl_iv <= 7'b0111111;		// Invalid option 
						data_dst_iv <= 5'd6;				// Destination to update post-dec value
						addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
						addr_src_iv <= 5'd6;				// Source for the address bus (SP) (equivalent to DST)
						psw_bus_ctrl_iv <= 2'b01;			// Read from MDR into PSW
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					3: begin						// Set PSW SLP bit to 0
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd50;					// Use invalid instruction
						clr_slp_bit = 1'b1;					// Clear the SLP bit
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					4: begin						// Pull LR from stack
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd33;					// Use LD.W
						word_byte <= 1'b0;					// Word operation
						data_bus_ctrl_iv <= 7'b0001000;		// Read from MDR into LR
						data_dst_iv <= 5'd6;				// Destination to update post-dec value
						addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
						addr_src_iv <= 5'd6;				// Source for the address bus (SP) (equivalent to DST)
						prpo_iv <= 1'b0;					// Post increment
						inc_iv <= 1'b1;
						dec_iv <= 1'b0;
						addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to SRC)
						data_dst_iv <= 5'd5;				// Destination for the data bus (LR) (equivalent to DST)
						data_src_iv <= 5'd6;				// Destination to update post-dec value
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					5: begin						// Pull PC from stack
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd33;					// Use LD.W
						word_byte <= 1'b0;					// Word operation
						data_bus_ctrl_iv <= 7'b0001000;		// Read from MDR into PC
						addr_bus_ctrl_iv <= 7'b0001000;		// Write the SP to MAR
						prpo_iv <= 1'b0;					// Post increment
						inc_iv <= 1'b1;
						dec_iv <= 1'b0;
						addr_src_iv<= 5'd6;					// Source for the address bus (SP) (equivalent to SRC)
						data_dst_iv <= 5'd7;				// Destination for the data bus (PC) (equivalent to DST)
						data_src_iv <= 5'd6;				// Destination to update post-dec value
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
						rst_counter = 1'b1;					// Signal to reset the interrupt vector counter
					end
				endcase
			end
			else begin
				case (counter)
					1: begin
						rec_pre_pri = 1'b1;					// Record the previous CPU priority
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					2: begin
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd33;					// Use LD.W
						use_pic_vect = 1'b1;				// Use the vector number stored in the PIC input
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
					3: begin						// Assign the PSW to the PSW of the vector, clear the SLP bit, 
													// and assign the previous priority of the new PSW the value of the stored priority
						operands = 1'b1;					// Utilize operands from interrupt vector entry block
						inst_type <= 7'd50;					// Use invalid instruction					
						psw_bus_ctrl_iv <= 2'b10;			// Use the PSW from the interrupt vector (stored in temp reg)
						data_src_iv <= 5'd16;				// Read the temp register into the PSW
						psw_entry_update = 1'b1;			// Signal assign the previous priority of the new PSW to the value of the stored PSW
						clr_slp_bit = 1'b1;					// Clear the SLP bit
						iv_cpu_rst <= 1'b1;					// Signal to indicate reset cpucycle to 5 rather than 1 during this
					end
					4: begin						// Assign the entry point of the handler to the PC
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
						rst_counter = 1'b1;					// Signal to reset the interrupt vector counter
					end
				endcase
			end
		end
	end

endmodule