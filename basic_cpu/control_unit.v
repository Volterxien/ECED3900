module control_unit(clock, ID_FLT, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, PRPO, DEC, INC, psw_in, psw_out, 
					ID_en, ctrl_reg_bus, data_bus_ctrl, addr_bus_ctrl, s_bus_ctrl, sxt_bit_num, sxt_rnum, sxt_shift, alu_op, 
					psw_update, dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, sxt_bus_ctrl, bm_rnum, bm_op,
					brkpnt, PC, addr_rnum_src, psw_bus_ctrl, cu_out1, cu_out2, cu_out3, vect_num, PSW_ENT, cex_state_out,
					cex_in, new_curr_pri, pic_in, pic_read, breakpnt_set);
	
	// Instruction Decoder Parameters
	input [15:0] PC;
	input [15:0] brkpnt;
	input [6:0] OP;
	input [12:0] OFF;
	input [3:0] C;
	input [2:0] T;
	input [2:0] F;
	input [2:0] PR;
	input [3:0] SA;
	input [4:0] PSWb;
	input [2:0] DST;
	input [2:0] SRCCON;
	input WB;
	input RC;
	input PRPO;
	input DEC;
	input INC;
	input [15:0] psw_in;
	input clock;
	input ID_FLT;
	input [7:0] cex_in;
	input [2:0] new_curr_pri;
	input [7:0] pic_in;								// Input from the PIC [1b for pending interrupt, 3b for priority, 4b for vect num]
	
	output reg ID_en; 
	output reg [2:0] ctrl_reg_bus; 					// [ENA, R/W, W/B]
	output reg [6:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 2b for src, 2b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU)]
	output reg [1:0] psw_bus_ctrl;					// [2b for src (Codes: 0=ALU, 1=MDR, 2=No Update location)]
	output reg s_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	output reg sxt_bus_ctrl;						// 0 = use Reg File, 1 = use offset from control unit
	output reg sxt_shift;							// 0 = no shift, 1 = shift OFF by 1
	output wire breakpnt_set;
	output reg [4:0] sxt_bit_num;					// The bit to extend for sign extensions
	output reg [4:0] sxt_rnum, bm_rnum;
	output wire [15:0] psw_out;
	output reg psw_update;							// 1 = update PSW in ALU, 0 = do not update PSW in ALU
	output reg [5:0] alu_op;						// ALU operation
	output reg [2:0] bm_op;
	output reg [4:0] dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, addr_rnum_src;	// Temp register is 5'b10000
	output wire [3:0] cu_out1, cu_out2, cu_out3;
	output reg [3:0] vect_num;
	output reg pic_read;							// Indicator to the PIC whether it has been read
	output wire [1:0] PSW_ENT;
	output wire [7:0] cex_state_out;
	
	reg [15:0] psw;
	reg [3:0] cpucycle;
	reg [3:0] iv_cnt;
	reg [6:0] step, cpu_OP;
	reg cpu_WB, cpu_INC, cpu_DEC, cpu_PRPO;
	reg [7:0] cex_state;					// [1b for CEX in progress (1 = in progress, 0 = not in progress), 
											// 1b for code result, 3b for true count, 3b for false count]
	reg [3:0] code;
	reg cpucycle_rst;						// Reset the CPU cycle (1 = reset, 0 = do not reset)
	reg brkpnt_set;							// 1 if breakpoint reached, 0 if not reached
	reg PC_FLT, DBL_FLT, PRI_FLT, iv_enter, iv_return, svc_inst, in_fault, pri_flt_called;
	
	reg [2:0] prev_priority;
	wire [1:0] psw_bus_ctrl_iv;
	wire iv_cnt_rst, psw_entry_update, clear_cex, load_cex, clr_slp_bit, rec_pre_pri;
	wire call_pri_flt, use_pic_vect;
	
	wire operands, word_byte, inc_iv, dec_iv, prpo_iv, iv_cpu_rst;
	wire [6:0] data_bus_ctrl_iv, addr_bus_ctrl_iv, OP_iv;
	wire [4:0] data_src_iv, addr_src_iv, data_dst_iv;
	
	reg code_result;
	wire [3:0] cpucycle_new;
	wire iv_result;
	
	initial begin
		psw = 16'h60e0;						// Initialize PSW to default values
		cpucycle = 4'b0001;					// Initialize CPU cycle
		step = 7'b0001;						// Initialize CPU step register
		iv_cnt = 4'b0;						// Initialize the Interrupt Vector Routine Counter
		cex_state = 8'b00000000;			// Initialize CEX state
		brkpnt_set = 1'b0;					// Initialize Breakpoint set state
		s_bus_ctrl = 1'b0;					// Initialize S-bus control to use Reg File
		alu_rnum_src = 4'd10;				// Initialize ALU operand to be 2
		dbus_rnum_dst = 5'd7;				// Initialize dst for ALU result
		PC_FLT = 1'b0;
		DBL_FLT = 1'b0;
		PRI_FLT = 1'b0;
		vect_num = 4'b0;
		svc_inst = 1'b0;
		in_fault = 1'b0;
		pri_flt_called = 1'b0;
	end
	
	assign psw_out = psw[15:0];					// Assign the output wires for the PSW
	assign cpucycle_new = cpucycle;
	assign cu_out1 = cpucycle;
	assign cu_out2 = DBL_FLT;
	assign cu_out3 = iv_cnt;
	assign cex_state_out = cex_state[7:0];
	assign breakpnt_set = brkpnt_set;
	
	int_vect_entry iv_ent(iv_cnt, operands, word_byte, inc_iv, dec_iv, iv_cpu_rst, psw_entry_update, 
						  clear_cex, PSW_ENT, data_src_iv, addr_src_iv, data_dst_iv, OP_iv, 
						  iv_cnt_rst, iv_enter, iv_return, load_cex, clr_slp_bit, rec_pre_pri,
						  psw_bus_ctrl_iv, new_curr_pri, svc_inst, psw_out[7:5], call_pri_flt, psw_out[15:13],
						  pic_in, use_pic_vect, data_bus_ctrl_iv, addr_bus_ctrl_iv, prpo_iv, iv_result);
	
	
	always @(negedge clock) begin
		if (cpucycle_rst == 1'b1)
			step = 7'b1;						// Reset the CPU cycle
		else begin
			if (brkpnt_set == 1'b0)				// Do only if breakpoint not reached
				step = step << 1;				// Increment CPU cycle	
		end
		
		if ((cpucycle_rst == 1'b1) && ((iv_enter == 1'b1) || (iv_return == 1'b1))) begin
			step = 7'b10000;
			iv_cnt = iv_cnt + 1;				// Increment interrupt vector counter
		end
		
		if ((iv_enter == 1'b0) && (iv_return == 1'b0))
			iv_cnt = 4'b0;						// Reset the counter
		
		if (step[0])
			cpucycle <= 4'd1;
		else if (step[1])
			cpucycle <= 4'd2;
		else if (step[2])
			cpucycle <= 4'd3;
		else if (step[3])
			cpucycle <= 4'd4;
		else if (step[4])
			cpucycle <= 4'd5;
		else if (step[5])
			cpucycle <= 4'd6;
		else if (step[6])
			cpucycle <= 4'd7;
	end

	always @(posedge clock) begin
		psw = psw_in[15:0];
		ID_en <= 1'b0;					// Clear all enables
		ctrl_reg_bus <= 3'b000;			// Set to read only
		data_bus_ctrl = 7'b1111111;		// Make an invalid option
		addr_bus_ctrl <= 7'b1111111;	// Make an invalid option
		psw_bus_ctrl <= 2'b11;			// Make an invalid option
		psw_update <= 1'b0;				// Set to default of not updating
		cpucycle_rst <= 1'b0;			// Set to default of not resetting
		svc_inst = 1'b0;				// Default to not executing trap
		pic_read <= 1'b0;				// Default to indicate PIC not read
		
		if (PC[15:0] != brkpnt[15:0])
			brkpnt_set = 1'b0;
		
		if (clear_cex == 1'b1)
			cex_state = 8'd0;			// Clear the CEX if signaled to
			
		if (clr_slp_bit == 1'b1)		// Clear the PSW SLP bit
			psw[3] = 1'b0;
		
		if (rec_pre_pri == 1'b1)		// Record the PSW previous priority
			prev_priority = psw[7:5];
		
		if (psw_entry_update == 1'b1)	// Update the new PSW's previous priority
			psw[15:13] = prev_priority[2:0];
			
		if (load_cex == 1'b1)
			cex_state = cex_in[7:0];	// Load the CEX state from memory
		
		if (iv_cnt_rst == 1'b1) begin
			if ((iv_return == 1'b1) && (psw[8] == 1'b1)) begin // Returning from fault handler
				psw[8] = 1'b0;			// Clear the FLT bit
				in_fault <= 1'b0;
			end
			pri_flt_called = 1'b0;	// Clear the priority fault called bit
			iv_enter <= 1'b0;			// Clear the entry enable
			iv_return <= 1'b0;			// Clear the return enable
		end
		
		if (call_pri_flt == 1'b1)
			pri_flt_called = 1'b1;
		
		if ((pri_flt_called == 1'b1) && (iv_enter == 1'b0) && (iv_return == 1'b0)) begin
			if (in_fault == 1'b1)
				DBL_FLT = 1'b1;					// Stop execution on double fault
			else begin
				PRI_FLT <= 1'b1;
				in_fault <= 1'b1;
				vect_num <= 4'd10;
				iv_enter <= 1'b1;				// Enter the interrupt vector entry routine
				psw[8] = 1'b1;					// Set the FLT bit
			end
		end
		
		if (operands == 1'b1)
			psw_bus_ctrl <= psw_bus_ctrl_iv[1:0];
		
		if (use_pic_vect == 1'b1)
			vect_num <= pic_in[3:0];		// Set the vector number
		
		if ((pic_in[7] == 1'b1) && (cpucycle == 4'd0)) begin	// If pending interrupt and instruction finished
			if ((pic_in[6:4] > psw[7:5]) && (iv_enter != 1'b1) && (iv_return != 1'b1)) begin
				vect_num <= pic_in[3:0];	// Set the vector number
				iv_enter <= 1'b1;			// Enter the interrupt vector entry routine
				pic_read <= 1'b1;			// Indicate the the PIC has been read
			end
		end
		
		if ((brkpnt_set == 1'b0) && (psw[3] == 1'b0) && (DBL_FLT == 1'b0)) begin
			case(cpucycle)
				1: /* Fetch */
				begin
					if (PC[15:0] == 16'hffff) begin
						iv_return <= 1'b1;					// Enter the interrupt vector return routine
						cpucycle_rst <= 1'b1;				// Reset the CPU cycle
					end
					else if (PC[0] == 1'b1) begin
						if ((in_fault == 1'b1) && (iv_enter == 1'b0) && (iv_return == 1'b0))
							DBL_FLT = 1'b1;					// Stop execution on double fault
						else begin
							PC_FLT <= 1'b1;
							in_fault <= 1'b1;
							vect_num <= 4'd9;
							psw[8] = 1'b1;					// Set the FLT bit
							iv_enter <= 1'b1;				// Enter the interrupt vector entry routine
							cpucycle_rst <= 1'b1;			// Reset the CPU cycle
						end
					end
					else if (PC[15:0] != brkpnt[15:0]) begin
						if (pri_flt_called == 1'b0) begin
							psw_update <= 1'b0;				// Set ALU to not update the PSW for fetching
							dbus_rnum_dst <= 5'd7;			// Select the PC to read from the data bus
							alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
							alu_rnum_src <= 5'd10;			// Select the constant 2 to add to the PC after the fetch
							s_bus_ctrl <= 1'd0;				// Use the register file
							alu_op <= 5'b00000;				// Add 2 to PC
							addr_rnum_src <= 5'd7;			// Select the PC to write to the MAR
							addr_bus_ctrl <= 7'b0001000;	// Write PC to MAR
							ctrl_reg_bus <= 3'b000;			// Read memory from MAR address to MDR
						end
						else
							cpucycle_rst <= 1'b1;			// Reset the CPU cycle
					end
					else begin
						brkpnt_set = 1'b1;				// PC is at the breakpoint
						cpucycle_rst <= 1'b1;			// Reset the CPU cycle
					end
					
				end
				2: /* Finish Fetching from Memory (Add 2 to PC) */
				begin
					data_bus_ctrl = 7'b0011001;		// Write ALU output to PC
				end
				3: /* Finish Fetching from Memory (Add 2 to PC) */
				begin
					data_bus_ctrl = 7'b0000010;	// Write MDR to Instruction Register
				end
				4: /* Decode */
				begin
					if ((cex_state[7] == 1'b0) || ((cex_state[7] == 1'b1) && cex_state[6] && (cex_state[5:3] > 1'b0)) 
						|| ((cex_state[7] == 1'b1) && !cex_state[6] && (cex_state[2:0] > 1'b0) && (cex_state[5:3] <= 1'b0))) begin
						ID_en <= 1'b1;		// Enable the instruction decoder
					end
					else
						cpucycle_rst <= 1;					// Reset the cycle
					
					if (cex_state[5:3] > 1'b0)
						cex_state[5:3] = cex_state[5:3] - 1'b1;
					else if (cex_state[2:0] > 1'b0)
						cex_state[2:0] = cex_state[2:0] - 1'b1;
					if ((cex_state[5:3] == 1'b0) && (cex_state[2:0] == 1'b0))
						cex_state[7] = 1'b0;
				end
				5: /* Execute */
				begin
					if ((ID_FLT == 1'b1) && (iv_enter == 1'b0) && (iv_return == 1'b0)) begin
						if (in_fault == 1'b1)
							DBL_FLT = 1'b1;					// Stop execution on double fault
						else begin
							vect_num <= 4'd8;
							in_fault <= 1'b1;
							psw[8] = 1'b1;					// Set the FLT bit
							iv_enter <= 1'b1;				// Enter the interrupt vector entry routine
							cpu_OP = 7'd50;					// Set to invalid so nothing executes
						end
					end
					else
						cpu_OP = (operands == 1'b0) ? OP[6:0] : OP_iv[6:0];
					
					cpu_WB = (operands == 1'b0) ? WB : word_byte;
					cpu_INC = (operands == 1'b0) ? INC : inc_iv;
					cpu_DEC = (operands == 1'b0) ? DEC : dec_iv;
					cpu_PRPO = (operands == 1'b0) ? PRPO : prpo_iv;
					if (operands == 1'b1) begin
						dbus_rnum_src <= data_src_iv[4:0];
					end
					
					case(cpu_OP)
						0: // BL (Multi-step)
						begin
							dbus_rnum_dst <= 5'd5;			// Select the LR as the dst reg for the data bus
							dbus_rnum_src <= 5'd7;			// Select the PC as the src reg for the data bus
							data_bus_ctrl = 7'b0001001;		// Write the PC to the LR
							sxt_bit_num = 4'd13;			// Provide sign bit to sign extender
							sxt_bus_ctrl = 1'b1;			// Use the offset from the instruction decoder
							sxt_shift = 1'b1;				// Shift the offset by 1
							psw_update <= 1'b1;				// Set ALU to not update the PSW
							s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
							alu_op <= 5'd0;					// Use the add instruction on the ALU
							alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
						end
						1,2,3,4,5,6,7,8: // BEQ to BRA
						begin
							case(OP)
								1,2,3,4,5: 	code = OP[6:0] - 7'd1;
								6,7,8: 		code = OP[6:0] + 7'd4;
							endcase
							cex_code(psw, code);
							if (code_result == 1'b1) begin
								psw_update <= 1'b0;				// Set ALU to not update the PSW
								s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
								sxt_bit_num = 4'd10;			// Provide sign bit to sign extender
								sxt_shift = 1'b1;				// Shift the offset by 1
								sxt_bus_ctrl = 1'b1;			// Use the offset from the instruction decoder
								alu_op <= 5'd0;					// Use the add instruction on the ALU
								alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
								dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
								data_bus_ctrl = 7'b0011001;		// Write ALU output to register file
							end
							cpucycle_rst <= 1;					// Reset the cycle
						end
						9,10,11,12,13,14,15,16,17,18,19,20: // ADD to BIS
						begin
							psw_bus_ctrl <= 2'b00;							// Update the PSW from the ALU output
							alu_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the ALU
							alu_rnum_src <= 5'd0 + SRCCON[2:0] + (RC<<3);	// Select the source register for the ALU
							dbus_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the data bus
							psw_update <= 1'b1;								// Set ALU to update the PSW
							s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
							alu_op <= ((OP[6:0] - 6'd9)<<1) + WB;			// Set ALU operation
							data_bus_ctrl = 7'b0011001 + (WB<<6);			// Write ALU output to register file
							cpucycle_rst <= 1;								// Reset the cycle
						end
						21:	// MOV
						begin
							dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : data_dst_iv[4:0];				// Select the destination register for the data bus
							dbus_rnum_src <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];			// Select the source register for the data bus
							data_bus_ctrl = (operands == 1'b0) ? (7'b0001001 + (WB<<6)) : data_bus_ctrl_iv[6:0];	// Write the src register to the dst register
							cpucycle_rst <= 1'b1;																	// Reset the cycle
						end
						22:	// SWAP (Multi-step)
						begin
							dbus_rnum_dst <= 5'b10000;				// Select the temp reg as the dst reg for the data bus
							dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the source register for the data bus
							data_bus_ctrl = 7'b0001001;			// Write the src register to the temp register
						end
						23,24:	// SRA, RRC
						begin
							psw_bus_ctrl <= 2'b00;							// Update the PSW from the ALU output
							alu_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the ALU
							alu_rnum_src <= 5'd0 + SRCCON[2:0] + (RC<<3);	// Select the source register for the ALU
							dbus_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the data bus
							psw_update <= 1'b1;								// Set ALU to update the PSW
							s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
							alu_op <= ((OP[6:0] - 6'd11)<<1) + WB;			// Set ALU operation
							data_bus_ctrl = 7'b0011001 + (WB<<6);			// Write ALU output to register file
							cpucycle_rst <= 1;								// Reset the cycle
						end
						25:	// SWPB
						begin
							bm_op = 3'd4;							// Set the Byte Manipulation block operation to SWPB
							bm_rnum = 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							data_bus_ctrl = 7'b0101001;				// Write the Byte Manipulation block output to the dst register
							cpucycle_rst <= 1;						// Reset the cycle
						end
						26:	// SXT
						begin
							sxt_bit_num = 4'd7;						// Provide sign bit to sign extender
							sxt_rnum = 4'd0 + DST[2:0];				// Assign the register input
							sxt_bus_ctrl = 1'b0;					// Use the reg file as input
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							sxt_shift = 1'b0;						// No shifting
							data_bus_ctrl = 7'b0100001;				// Write the sign extender output to the dst register
							cpucycle_rst <= 1;						// Reset the cycle
						end
						27:	// SETPRI
						begin
							if (PR[2:0] < psw[7:5])					// If new priority less than current priority
								psw[7:5] <= PR[2:0];				// Set current priority to new priority
							else begin
								if ((in_fault == 1'b1) && (iv_enter == 1'b0) && (iv_return == 1'b0))
									DBL_FLT = 1'b1;					// Stop execution on double fault
								else begin
									PRI_FLT <= 1'b1;
									in_fault <= 1'b1;
									vect_num <= 4'd10;
									iv_enter <= 1'b1;				// Enter the interrupt vector entry routine
									psw[8] = 1'b1;					// Set the FLT bit
								end
							end
							cpucycle_rst <= 1'b1;				// Reset the cycle
						end
						28:	// SVC
						begin
							vect_num <= SA[3:0];				// Assign the interrupt vector
							svc_inst <= 1'b1;					// A trap is taking place
							iv_enter <= 1'b1;					// Enter the interrupt vector entry routine
							cpucycle_rst <= 1'b1;				// Reset the cycle
						end
						29:	// SETCC
						begin
							psw[4:0] <= psw[4:0] | PSWb[4:0];
							cpucycle_rst <= 1;	// Reset the cycle
						end
						30:	// CLRCC
						begin
							psw[4:0] <= psw[4:0] & ~(PSWb[4:0]);
							cpucycle_rst <= 1;	// Reset the cycle
						end
						31:	// CEX
						begin
							code = C[3:0];
							cex_code(psw, code);
							cex_state[7] = 1'b1;					// Set the CEX state to active
							cex_state[6] = code_result;				// Assign the result of the code
							cex_state[5:3] = T[2:0];
							cex_state[2:0] = F[2:0];
							cpucycle_rst <= 1;						// Reset the cycle
						end
						32:	// LD (Multi-step)
						begin
							if (cpu_PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								alu_rnum_dst <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - cpu_WB;				// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;									// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (cpu_DEC<<2);			// Determine whether the operation is addition or subtraction
								psw_update <= 1'b0;							// Set ALU to not update the PSW
								addr_bus_ctrl <= 7'b0011000;				// Write the ALU output to the MAR
								data_bus_ctrl = 7'b0011001;				// Write the ALU output to the register file
								dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];	// Select the dst reg for the data bus
							end
							else				// Post-Inc/Dec
							begin
								dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : data_dst_iv[4:0];		// Select the dst reg for the data bus
								addr_rnum_src <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : addr_src_iv[4:0];	// Select the src reg for the addr bus
								addr_bus_ctrl <= (operands == 1'b0) ? 7'b0001000 : addr_bus_ctrl_iv[6:0];			// Write the register file reg to the MAR
								ctrl_reg_bus <= (operands == 1'b0) ? (3'b000 + (WB<<2)) : 3'b000;						// Read memory from MAR address to MDR
							end
						end
						33:	// ST (Multi-step)
						begin
							if (cpu_PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - WB;		// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;						// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (DEC<<2);				// Determine whether the operation is addition or subtraction
								psw_update <= 1'b0;						// Set ALU to not update the PSW
								addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
								data_bus_ctrl = 7'b0011001;			// Write the ALU output to the register file
								dbus_rnum_dst <= 5'd0 + DST[2:0];	// Select the dst reg for the data bus
							end
							else				// Post-Inc/Dec
							begin
								dbus_rnum_src <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];			// Select the src reg for the data bus
								addr_rnum_src <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : addr_src_iv[4:0];				// Select the dst reg for the addr bus
								addr_bus_ctrl <= (operands == 1'b0) ? 7'b0001000 : addr_bus_ctrl_iv[6:0];				// Write the register file reg to the MAR
								data_bus_ctrl = (operands == 1'b0) ? (7'b0001000 + (WB<<6)) : data_bus_ctrl_iv[6:0];	// Write the data from the dst register to the MDR
								ctrl_reg_bus <= (operands == 1'b0) ? (3'b011 & ~(WB<<1)) : 3'b011;						// Write memory to MAR address from MDR
							end
						end
						34,35,36,37:	// MOVL to MOVH
						begin
							bm_op = OP[6:0] - 6'd34;				// Set the Byte Manipulation block operation
							bm_rnum = 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							data_bus_ctrl = 7'b0101001;				// Write the Byte Manipulation block output to the dst register
							cpucycle_rst <= 1;	// Reset the cycle
						end
						38:	// LDR (Multi-step)
						begin
							sxt_bit_num = 4'd6;						// Provide sign bit to sign extender
							sxt_bus_ctrl = 1'b1;					// Use the offset from the instruction decode
							sxt_shift = 1'b0;						// No shifting
							alu_rnum_dst <= 5'd0 + SRCCON[2:0];		// Select the destination register for the ALU
							s_bus_ctrl <= 1'b1;						// Use the sign extender output on the S-bus for the ALU
							psw_update <= 1'b0;						// Set ALU to not update the PSW
							alu_op <= 5'd0;							// Use the add instruction on the ALU
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
							ctrl_reg_bus <= 3'b000 + (WB<<2);		// Read memory from MAR address to MDR
						end
						39:	// STR (Multi-step)
						begin
							sxt_bit_num = 4'd6;						// Provide sign bit to sign extender
							sxt_bus_ctrl = 1'b1;					// Use the offset from the instruction decode
							sxt_shift = 1'b0;						// No shifting
							alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
							s_bus_ctrl <= 1'b1;						// Use the sign extender output on the S-bus for the ALU
							psw_update <= 1'b0;						// Set ALU to not update the PSW
							alu_op <= 5'd0;							// Use the add instruction on the ALU
							dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the src reg for the data bus
							addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
						end
						default:
							cpucycle_rst <= 1'b1;
					endcase
				end
				6:
				begin
					case(cpu_OP)
						0: 	// BL (Second Step)
						begin
							dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
							data_bus_ctrl = 7'b0011001;		// Write ALU output to PC
							cpucycle_rst <= 1;				// Reset the cycle
						end
						22: // SWAP (Second Step)
						begin
							dbus_rnum_dst <= 5'd0 + SRCCON[2:0];	// Select the src reg for the data bus
							dbus_rnum_src <= 5'b0 + DST[2:0];		// Select the dst reg as the src for the data bus
							data_bus_ctrl = 7'b0001001;				// Write the dst register to the src register
						end
						32:	// LD (Second Step)
						begin
							dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : data_dst_iv[4:0];		// Select the dst reg for the data bus
							data_bus_ctrl = (operands == 1'b0) ? (7'b0000001 + (cpu_WB<<6)) : data_bus_ctrl_iv[6:0];										// Write the data from the MDR to the dst register
							ctrl_reg_bus <= (operands == 1'b0) ? (3'b000 + (WB<<2)) : 3'b000;				// Read memory from MAR address to MDR
						end
						33: // ST (Second Step)
						begin
							if (cpu_PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the dst reg for the data bus
								data_bus_ctrl = 7'b0001000;				// Write the data from the dst to the dst register
								ctrl_reg_bus <= 3'b011 & ~(WB<<1);		// Write memory to MAR address from MDR
							end
							else if ((cpu_INC == 1'b1) || (cpu_DEC == 1'b1))	// Post-Inc/Dec
							begin
								alu_rnum_dst <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : data_dst_iv[4:0];			// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - cpu_WB;			// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;							// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (cpu_DEC<<2);			// Determine whether the operation is addition or subtraction
								psw_update <= 1'b1;							// Set ALU to not update the PSW
								data_bus_ctrl = 7'b0011001;					// Write the ALU output to the register file
								dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + DST[2:0]) : data_dst_iv[4:0];			// Select the dst reg for the data bus
							end
						end
						38:	// LDR (Second Step)
							// Wait for memory read to complete
							data_bus_ctrl = 7'b0000001 + (WB<<6);	// Write the data from the MDR to the dst register
						39:	// STR (Second Step)
						begin
							data_bus_ctrl = 7'b0001000 + (WB<<6);	// Write the data from the src register to the MDR
							ctrl_reg_bus <= 3'b011 & ~(WB<<1);		// Write data from MDR to memory at MAR address
						end
					endcase
				end
				7:
				begin
					case(cpu_OP)
					22:	// SWAP (Third Step)
					begin
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
						dbus_rnum_src <= 5'b10000;				// Select the temp reg as the src reg for the data bus
						data_bus_ctrl = 7'b0001001;				// Write the temp register to the dst register
						cpucycle_rst <= 1;	// Reset the cycle
					end
					32: // LD (Third Step)
					begin
						if ((cpu_PRPO == 1'b0) && ((cpu_INC == 1'b1) || (cpu_DEC == 1'b1))) begin
							alu_rnum_dst <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];	// Select the destination register for the ALU
							alu_rnum_src <= 5'b01010 - cpu_WB;				// Select the source register for the ALU (constant 1 or 2)
							s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
							alu_op <= 5'd0 + (cpu_DEC<<2);				// Determine whether the operation is addition or subtraction
							psw_update <= 1'b1;								// Set ALU to not update the PSW
							data_bus_ctrl = 7'b0011001;						// Write the ALU output to the register file
							dbus_rnum_dst <= (operands == 1'b0) ? (5'd0 + SRCCON[2:0]) : data_src_iv[4:0];	// Select the dst reg for the data bus
						end
						cpucycle_rst <= 1'b1;	// Reset the cycle
					end
					33:	// ST (Third Step)
						// Wait for memory write to complete
						cpucycle_rst <= 1'b1;	// Reset the cycle
					38:	// LDR (Third Step)
						// Wait for memory write to complete
						cpucycle_rst <= 1;	// Reset the cycle
					39:	// STR (Third Step)
						// Wait for memory write to complete
						cpucycle_rst <= 1;	// Reset the cycle
					endcase
				end
				default
					cpucycle_rst <= 1;	// Reset the cycle
			endcase
		end
	end
		

	task cex_code;
		input [15:0] psw_in;
		input [3:0] code;
		
		// Formatting of tasks from https://nandland.com/task/
		begin
			case (code)
				0: 	// EQ/EZ
				begin
					if (psw_in[1] == 1'b1)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				1:	// NE/NEZ
				begin
					if (psw_in[1] == 1'b0)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				2:	// CS/HS
				begin
					if (psw_in[0] == 1'b1)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				3:	// CC/LO
				begin
					if (psw_in[0] == 1'b0)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				4:	// MI
				begin
					if (psw_in[2] == 1'b1)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				5:	// PL
				begin
					if (psw_in[2] == 1'b0)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				6:	// VS
				begin
					if (psw_in[4] == 1'b1)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				7:	// VC
				begin
					if (psw_in[4] == 1'b0)
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				8:	// HI
				begin
					if ((psw_in[0] == 1'b1) && (psw_in[1] == 1'b0))
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				9:	// LS
				begin
					if ((psw_in[0] == 1'b0) || (psw_in[1] == 1'b1))
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				10:	// GE
				begin
					if (psw_in[2] == psw_in[4])
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				11:	// LT
				begin
					if (psw_in[2] != psw_in[4])
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				12:	// GT
				begin
					if ((psw_in[1] == 1'b0) && (psw_in[2] == psw_in[4]))
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				13:	// LE
				begin
					if ((psw_in[1] == 1'b1) || (psw_in[2] != psw_in[4]))
						code_result = 1'b1;
					else
						code_result = 1'b0;
				end
				14:	// AL
					code_result = 1'b1;
			endcase
		end
	endtask
endmodule
