module control_unit(clock, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, PRPO, DEC, INC, psw_in, psw_out, 
					enables, ctrl_reg_bus, data_bus_ctrl, addr_bus_ctrl, s_bus_ctrl, sxt_bit_num, sxt_rnum, alu_op, 
					psw_update, dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, sxt_bus_ctrl, bm_rnum, bm_op,
					brkpnt, PC, addr_rnum_src, psw_bus_ctrl);
	
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
	
	input FLTi;
	output reg [15:0] enables; 						// [ALU_E, ID_E, SXT_E, BM_E,
	output reg [2:0] ctrl_reg_bus; 					// [ENA, R/W, W/B]
	output reg [6:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 2b for src, 2b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU)]
	output reg [1:0] psw_bus_ctrl;					// [2b for src (Codes: 0=ALU, 1=MDR, 2=No Update location)]
	output reg s_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	output reg sxt_bus_ctrl;						// 0 = use Reg File, 1 = use offset from control unit
	output reg [4:0] sxt_bit_num;					// The bit to extend for sign extensions
	output reg [4:0] sxt_rnum, bm_rnum;
	output wire [15:0] psw_out;
	output reg psw_update;							// 1 = update PSW in ALU, 0 = do not update PSW in ALU
	output reg [5:0] alu_op;						// ALU operation
	output reg [2:0] bm_op;
	output reg [4:0] dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, addr_rnum_src;	// Temp register is 5'b10000
	
	reg [15:0] psw;
	reg [3:0] cpucycle;
	reg [7:0] cex_state;					// [1b for CEX in progress (1 = in progress, 0 = not in progress), 
											// 1b for code result, 3b for true count, 3b for false count]
	reg [3:0] code;
	reg cpucycle_rst;						// Reset the CPU cycle (1 = reset, 0 = do not reset)
	
	wire code_result;
	wire [3:0] cpucycle_new;
	
	initial begin
		psw = 16'h60e0;						// Initialize PSW to default values
		cpucycle = 4'b0001;					// Initialize CPU cycle
		cex_state = 8'b00000000;			// Initialize CEX state
	end

	assign psw_out = psw[15:0];					// Assign the output wires for the PSW
	assign cpucycle_new = cpucycle;
	
	cex_code cex_code_ctrl(psw_out, code, code_result);
	
	always @(negedge clock) begin
		if (cpucycle_rst == 1'b1)
			cpucycle <= 1;				// Reset the cycle
		else
			cpucycle <= cpucycle_new + 1;	// Increment CPU cycle
			
		if (cpucycle == 4'd4)	begin
			case(cpucycle)
				0:	sxt_bit_num <= 4'd13;			// Provide sign bit to sign extender
				1,2,3,4,5,6,7,8:
					sxt_bit_num <= 4'd10;			// Provide sign bit to sign extender	
			endcase
			sxt_bus_ctrl <= 1'b1;			// Use the offset from the instruction decoder
			enables[13] <= 1'b1;			// Enable the sign extender
		end
	end

	always @(posedge clock) begin
		psw <= psw_in[15:0];
		enables <= 16'h0000;			// Clear all enables
		ctrl_reg_bus <= 3'b000;			// Set to read only
		data_bus_ctrl <= 7'b1111111;	// Make an invalid option
		addr_bus_ctrl <= 7'b1111111;	// Make an invalid option
		psw_bus_ctrl <= 2'b11;			// Make an invalid option
		psw_update <= 1'b0;				// Set to default of not updating
		cpucycle_rst <= 1'b0;			// Set to default of not resetting
		if (PC[15:0] != brkpnt[15:0]) begin
			psw[3] <= 1'b0;					// Execution in progress (SLP bit clear)
			case(cpucycle)
				1: /* Fetch */
				begin
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
				2: /* Finish Fetching from Memory (Add 2 to PC) */
				begin
					enables[15] <= 1'b1;			// Enable the ALU
					data_bus_ctrl <= 7'b0011001;	// Write ALU output to PC
				end
				3: /* Finish Fetching from Memory (Add 2 to PC) */
				begin
					data_bus_ctrl <= 7'b0000010;	// Write MDR to Instruction Register
				end
				4: /* Decode */
				begin
					if ((cex_state[7] == 1'b0) || ((cex_state[7] == 1'b1) && cex_state[6] && (cex_state[5:3] > 1'b0)) 
						|| ((cex_state[7] == 1'b1) && !cex_state[6] && (cex_state[2:0] > 1'b0) && (cex_state[5:3] <= 1'b0))) begin
						enables[14] <= 1'b1;		// Enable the instruction decoder
						if (cex_state[5:3] > 1'b0)
							cex_state[5:3] <= cex_state[5:3] - 1'b1;
						else if (cex_state[2:0] > 1'b0)
							cex_state[2:0] <= cex_state[2:0] - 1'b1;
						if ((cex_state[5:3] == 1'b0) && (cex_state[2:0] == 1'b0))
							cex_state[7] <= 1'b0;
					end
				end
				5: /* Execute */
				begin
					enables[15] <= 1'b0;		// Disable the instruction decoder
					case(OP)
						0: // BL (Multi-step)
						begin
							dbus_rnum_dst <= 5'd5;			// Select the LR as the dst reg for the data bus
							dbus_rnum_src <= 5'd7;			// Select the PC as the src reg for the data bus
							data_bus_ctrl <= 7'b0001001;	// Write the PC to the LR
							psw_update <= 1'b1;				// Set ALU to not update the PSW
							s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
							alu_op <= 5'd0;					// Use the add instruction on the ALU
							alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
						end
						1,2,3,4,5,6,7,8: // BEQ to BRA
						begin
							case(OP)
								1,2,3,4,5: 	code <= OP[6:0] - 7'd1;
								6,7,8: 	code <= OP[6:0] + 7'd4;
							endcase
							
							if (code_result == 1'b1) begin
								psw_update <= 1'b0;				// Set ALU to not update the PSW
								s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
								alu_op <= 5'd0;					// Use the add instruction on the ALU
								alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
								dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
								data_bus_ctrl <= 7'b0011001;	// Write ALU output to register file
								enables[15] <= 1'b1;			// Enable the ALU
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
							data_bus_ctrl <= 7'b0011001 + (WB<<6);			// Write ALU output to register file
							enables[15] <= 1'b1;							// Enable the ALU
							cpucycle_rst <= 1;								// Reset the cycle
						end
						21:	// MOV
						begin
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the data bus
							dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the source register for the data bus
							data_bus_ctrl <= 7'b0001001 + (WB<<6);	// Write the src register to the dst register
							cpucycle_rst <= 1;	// Reset the cycle
						end
						22:	// SWAP (Multi-step)
						begin
							dbus_rnum_dst <= 5'b10000;				// Select the temp reg as the dst reg for the data bus
							dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the source register for the data bus
							data_bus_ctrl <= 7'b0001001;			// Write the src register to the temp register
						end
						23,24:	// SRA, RRC
						begin
							alu_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the ALU
							alu_rnum_src <= 5'd0 + SRCCON[2:0] + (RC<<3);	// Select the source register for the ALU
							dbus_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the data bus
							psw_update <= 1'b1;								// Set ALU to update the PSW
							s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
							alu_op <= ((OP[6:0] - 6'd11)<<1) + WB;			// Set ALU operation
							data_bus_ctrl <= 7'b0011001 + (WB<<6);			// Write ALU output to register file
							enables[15] <= 1'b1;							// Enable the ALU
							cpucycle_rst <= 1;								// Reset the cycle
						end
						25:	// SWPB
						begin
							bm_op <= 3'd4;							// Set the Byte Manipulation block operation to SWPB
							bm_rnum <= 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							data_bus_ctrl <= 7'b0101001;			// Write the Byte Manipulation block output to the dst register
							enables[12] <= 1'b1;					// Enable the Byte Manipulation block
							cpucycle_rst <= 1;						// Reset the cycle
						end
						26:	// SXT
						begin
							sxt_rnum <= 5'd0 + DST[2:0];			// Select the input register to the sign extender
							sxt_bit_num <= 4'd7;					// Provide sign bit to sign extender
							sxt_bus_ctrl <= 1'b0;					// Use the register file as input to the sign extender
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							data_bus_ctrl <= 7'b0100001;			// Write the sign extender output to the dst register
							enables[13] <= 1'b1;					// Enable the sign extender
							cpucycle_rst <= 1;						// Reset the cycle
						end
						27:	// SETPRI
						begin
							if (PR[2:0] < psw[7:5])					// If new priority less than current priority
								psw[7:5] <= PR[2:0];				// Set current priority to new priority
							else
								// Fault
								enables[0] <= 1'b1;	// Filler
						end
						28:	// SVC
						begin
							// Leaving blank for now
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
							code <= C[3:0];
							cex_state[7] <= 1'b1;					// Set the CEX state to active
							cex_state[6] <= code_result;			// Assign the result of the code
							cex_state[5:3] <= T[2:0];
							cex_state[2:0] <= F[2:0];
							cpucycle_rst <= 1;	// Reset the cycle
						end
						32:	// LD (Multi-step)
						begin
							if (PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								alu_rnum_dst <= 5'd0 + SRCCON[2:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - WB;			// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;						// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (DEC<<2) + INC;		// Determine whether the operation is addition or subtraction
								psw_update <= 1'b0;						// Set ALU to not update the PSW
								addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
								data_bus_ctrl <= 7'b0011001;			// Write the ALU output to the register file
								dbus_rnum_dst <= 5'd0 + SRCCON[2:0];	// Select the dst reg for the data bus
								enables[15] <= 1'b1;					// Enable the ALU
							end
							else				// Post-Inc/Dec
							begin
								dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
								addr_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the src reg for the addr bus
								addr_bus_ctrl <= 7'b0001000;			// Write the register file reg to the MAR
								data_bus_ctrl <= 7'b0000001 + (WB<<6);	// Write the data from the MDR to the dst register
								ctrl_reg_bus <= 3'b000 + (WB<<2);		// Read memory from MAR address to MDR
							end
						end
						33:	// ST (Multi-step)
						begin
							if (PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - WB;			// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;						// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (DEC<<2) + INC;		// Determine whether the operation is addition or subtraction
								psw_update <= 1'b0;						// Set ALU to not update the PSW
								addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
								data_bus_ctrl <= 7'b0011001;			// Write the ALU output to the register file
								dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
								enables[15] <= 1'b1;					// Enable the ALU
							end
							else				// Post-Inc/Dec
							begin
								dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the src reg for the data bus
								addr_rnum_src <= 5'd0 + DST[2:0];		// Select the dst reg for the addr bus
								addr_bus_ctrl <= 7'b0001000;			// Write the register file reg to the MAR
								data_bus_ctrl <= 7'b0001000 + (WB<<6);	// Write the data from the dst register to the MDR
								ctrl_reg_bus <= 3'b001 + (WB<<1);		// Write memory to MAR address from MDR
							end
						end
						34,35,36,37:	// MOVL to MOVH
						begin
							bm_op <= OP[6:0] - 6'd34;				// Set the Byte Manipulation block operation
							bm_rnum <= 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							data_bus_ctrl <= 7'b0101001;			// Write the Byte Manipulation block output to the dst register
							enables[12] <= 1'b1;					// Enable the Byte Manipulation block
							cpucycle_rst <= 1;	// Reset the cycle
						end
						38:	// LDR (Multi-step)
						begin
							alu_rnum_dst <= 5'd0 + SRCCON[2:0];		// Select the destination register for the ALU
							s_bus_ctrl <= 1'b1;						// Use the sign extender output on the S-bus for the ALU
							psw_update <= 1'b0;						// Set ALU to not update the PSW
							alu_op <= 5'd0;							// Use the add instruction on the ALU
							sxt_bit_num <= 4'd6;					// Provide sign bit to sign extender
							sxt_bus_ctrl <= 1'b1;					// Use the offset from the instruction decoder
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
							data_bus_ctrl <= 7'b0000001 + (WB<<6);	// Write the data from the MDR to the dst register
							ctrl_reg_bus <= 3'b000 + (WB<<2);		// Read memory from MAR address to MDR
							enables[13] <= 1'b1;					// Enable the sign extender
							enables[15] <= 1'b1;					// Enable the ALU
						end
						39:	// STR (Multi-step)
						begin
							alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
							s_bus_ctrl <= 1'b1;						// Use the sign extender output on the S-bus for the ALU
							psw_update <= 1'b0;						// Set ALU to not update the PSW
							alu_op <= 5'd0;							// Use the add instruction on the ALU
							sxt_bit_num <= 4'd6;					// Provide sign bit to sign extender
							sxt_bus_ctrl <= 1'b1;					// Use the offset from the instruction decoder
							dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the dst reg for the data bus
							data_bus_ctrl <= 7'b0001000 + (WB<<6);	// Write the data from the src register to the MDR
							addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
							ctrl_reg_bus <= 3'b001 + (WB<<1);		// Write data from MDR to memory at MAR address
							enables[13] <= 1'b1;					// Enable the sign extender
							enables[15] <= 1'b1;					// Enable the ALU
						end
					endcase
				end
				6:
				begin
					case(OP[6:0])
						0: 	// BL (Second Step)
						begin
							dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
							data_bus_ctrl <= 7'b0011001;	// Write ALU output to PC
							enables[15] <= 1'b1;			// Enable the ALU
							cpucycle_rst <= 1;				// Reset the cycle
						end
						22: // SWAP (Second Step)
						begin
							dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
							dbus_rnum_src <= 5'b10000;				// Select the temp reg as the src reg for the data bus
							data_bus_ctrl <= 7'b0001001;			// Write the temp register to the dst register
							cpucycle_rst <= 1;	// Reset the cycle
						end
						32:	// LD (Second Step)
						begin
							if (PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
								data_bus_ctrl <= 7'b0000001 + (WB<<6);	// Write the data from the MDR to the dst register
								ctrl_reg_bus <= 3'b000 + (WB<<2);		// Read memory from MAR address to MDR
							end
							else				// Post-Inc/Dec
							begin
								alu_rnum_dst <= 5'd0 + SRCCON[2:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - WB;			// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;						// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (DEC<<2) + INC;		// Determine whether the operation is addition or subtraction
								psw_update <= 1'b1;						// Set ALU to not update the PSW
								data_bus_ctrl <= 7'b0011001;			// Write the ALU output to the register file
								dbus_rnum_dst <= 5'd0 + SRCCON[2:0];	// Select the dst reg for the data bus
								enables[15] <= 1'b1;					// Enable the ALU
							end
						end
						33: // ST (Second Step)
						begin
							if (PRPO == 1'b1) 	// Pre-Inc/Dec
							begin
								dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the dst reg for the data bus
								data_bus_ctrl <= 7'b0000001 + (WB<<6);	// Write the data from the dst to the dst register
								ctrl_reg_bus <= 3'b001 + (WB<<1);		// Write memory to MAR address from MDR
							end
							else				// Post-Inc/Dec
							begin
								alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
								alu_rnum_src <= 5'b01010 - WB;			// Select the source register for the ALU (constant 1 or 2)
								s_bus_ctrl <= 1'b0;						// Use the register file on the S-bus for the ALU
								alu_op <= 5'd0 + (DEC<<2) + INC;		// Determine whether the operation is addition or subtraction
								psw_update <= 1'b1;						// Set ALU to not update the PSW
								data_bus_ctrl <= 7'b0011001;			// Write the ALU output to the register file
								dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the dst reg for the data bus
								enables[15] <= 1'b1;					// Enable the ALU
							end
						end
						38:	// LDR (Second Step)
							// Wait for memory read to complete
							cpucycle_rst <= 1;	// Reset the cycle
						39:	// STR (Second Step)
							// Wait for memory write to complete
							cpucycle_rst <= 1;	// Reset the cycle
						endcase
				end
				7:
				begin
					case(OP[6:0])
					32: // LD (Third Step)
						// Wait for memory read to compelete
						cpucycle_rst <= 1;	// Reset the cycle
					33:	// ST (Third Step)
						// Wait for memory write to complete
						cpucycle_rst <= 1;	// Reset the cycle
					endcase
				end
			endcase
		end
		else
			psw[3] <= 1'b1;					// Execution not in progress (SLP bit set)
	end
		

endmodule
