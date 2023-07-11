module control_unit(FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, psw_in, psw_out);
	
	// Instruction Decoder Parameters
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
	input [7:0] ImByte;
	input PRPO;
	input DEC;
	input INC;
	input [15:0] psw_in;
	input clock;
	
	output [15:0] enables; 						// [ALU_E, ID_E, SXT_E, BM_E,
	output [2:0] ctrl_reg_bus; 					// [ENA, R/W, W/B]
	output [4:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 2b for src, 2b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU)]
	output s_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	output [15:0] offset;						// Offset for memory instructions
	output sxt_bit_num;							// The bit to extend for sign extensions
	output [15:0] psw_out;
	output psw_update;							// 1 = update PSW in ALU, 0 = do not update PSW in ALU
	output [5:0] alu_op;						// ALU operation
	output [4:0] dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src;	// Temp register is 5'b10000
	
	assign psw_out = psw[15:0];					// Assign the output wires for the PSW
	
	reg [15:0] psw;
	reg [3:0] code;
	wire code_result;
	
	//unique outputs (some outputs use input bus)
	cpucyle = 1;
	
	initial begin
		psw = 16'h60e0;						// Initialize PSW to default values
	end
	
	always @(psw_in) begin
		psw <= psw_in[15:0];
	end
	
	cex_code cex_code_ctrl(psw_out, code, code_result);

	always @(posedge clock) begin
		case(cpucyle)
			1: /* Fetch */
			begin
				dbus_rnum_src <= 5'd7;			// Select the PC
				addr_bus_ctrl <= 7'b0001000;	// Write PC to MAR
				ctrl_reg_bus <= 3'b001;			// Read memory from MAR address to MDR
				data_bus_ctrl <= 7'b0000010;	// Write MDR to Instruction Register
			end
			2: /* Finish Fetching from Memory (Add 2 to PC) */
			begin
				psw_update <= 1'b1;				// Set ALU to not update the PSW for fetching
				dbus_rnum_dst <= 5'd7;			// Select the PC to write on the data bus
				alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
				alu_rnum_src <= 5'd10;			// Select the constant 2 to add to the PC after the fetch
				alu_function <= 5'b00000;		// Add 2 to PC
				data_bus_ctrl <= 7'b0011001;	// Write ALU output to PC
				enables[15] <= 1'b1;			// Enable the ALU
			3: /* Decode */
			begin
				psw_update <= 1'b0;			// Set ALU to update the PSW after fetching
				enables[15] <= 1'b0;		// Disable the ALU
				enables[14] <= 1'b1;		// Enable the instruction decoder
			end
			4: /* Execute */
			begin
				enables[15] <= 1'b0;		// Disable the instruction decoder
				case(OP)
					0: // BL (Multi-step)
					begin
						dbus_rnum_dst <= 5'd5;			// Select the LR as the dst reg for the data bus
						dbus_rnum_src <= 5'd7;			// Select the PC as the src reg for the data bus
						data_bus_ctrl <= 7'b0001001;	// Write the PC to the LR
						
						// For second step
						sxt_bit_num <= 4'd13;			// Provide sign bit to sign extender
						sxt_bus_ctrl <= 1'b1;			// Use the offset from the instruction decoder
						psw_update <= 1'b1;				// Set ALU to not update the PSW for updating of instruction
						s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
						alu_op <= 5'd0;					// Use the add instruction on the ALU
						alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
						dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
						data_bus_ctrl <= 7'b0011001;	// Write ALU output to PC
						enables[15] <= 1'b1;			// Enable the ALU
						enables[13] <= 1'b1;			// Enable the sign extender
					end
					1,2,3,4,5,6,7,8: // BEQ to BRA
					begin
						case(OP)
							1,2,3,4,5: 	code <= OP[6:0] - 6'd1;
							6,7,8: 	code <= OP[6:0] + 6'd4;
						endcase
						
						if (code_result == 1'b1) begin
							sxt_bit_num <= 4'd10;			// Provide sign bit to sign extender
							sxt_bus_ctrl <= 1'b1;			// Use the offset from the control unit
							psw_update <= 1'b1;				// Set ALU to not update the PSW for updating of instruction
							s_bus_ctrl <= 1'b1;				// Use the sign extender output in the ALU
							alu_op <= 5'd0;					// Use the add instruction on the ALU
							alu_rnum_dst <= 5'd7;			// Select the PC as the dst register for the ALU
							dbus_rnum_dst <= 5'd7;			// Select the PC to add the offset to and to write back
							data_bus_ctrl <= 7'b0011001;	// Write ALU output to register file
							enables[15] <= 1'b1;			// Enable the ALU
							enables[13] <= 1'b1;			// Enable the sign extender
						end
					end
					9,10,11,12,13,14,15,16,17,18,19,20: // ADD to BIS
					begin
						alu_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the ALU
						alu_rnum_src <= 5'd0 + SRCCON[2:0] + (RC<<3);	// Select the source register for the ALU
						dbus_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the data bus
						psw_update <= 1'b0;								// Set ALU to update the PSW
						s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
						alu_op <= ((OP[6:0] - 6'd9)<<1) + WB;			// Set ALU operation
						data_bus_ctrl <= 7'b0011001 + (WB<<6);			// Write ALU output to register file
						enables[15] <= 1'b1;							// Enable the ALU
					end
					21:	// MOV
					begin
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the data bus
						dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the source register for the data bus
						data_bus_ctrl <= 7'b0001001 + (WB<<6);	// Write the src register to the dst register
					end
					22:	// SWAP (Multi-step)
					begin
						dbus_rnum_dst <= 5'b10000;				// Select the temp reg as the dst reg for the data bus
						dbus_rnum_src <= 5'd0 + SRCCON[2:0];	// Select the source register for the data bus
						data_bus_ctrl <= 7'b0001001;			// Write the src register to the temp register
						
						// For second step
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						dbus_rnum_src <= 5'b10000;				// Select the temp reg as the src reg for the data bus
						data_bus_ctrl <= 7'b0001001;			// Write the temp register to the dst register
					end
					23,24:	// SRA, RRC
					begin
						alu_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the ALU
						alu_rnum_src <= 5'd0 + SRCCON[2:0] + (RC<<3);	// Select the source register for the ALU
						dbus_rnum_dst <= 5'd0 + DST[2:0];				// Select the destination register for the data bus
						psw_update <= 1'b0;								// Set ALU to update the PSW
						s_bus_ctrl <= 1'b0;								// Use the register file on the S-bus for the ALU
						alu_op <= ((OP[6:0] - 6'd11)<<1) + WB;			// Set ALU operation
						data_bus_ctrl <= 7'b0011001 + (WB<<6);			// Write ALU output to register file
						enables[15] <= 1'b1;							// Enable the ALU
					end
					25:	// SWPB
					begin
						bm_op <= 3'd4;							// Set the Byte Manipulation block operation to SWPB
						bm_rnum <= 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						data_bus_ctrl <= 7'b0101001;			// Write the Byte Manipulation block output to the dst register
						enables[12] <= 1'b1;					// Enable the Byte Manipulation block
					end
					26:	// SXT
					begin
						sxt_rnum <= 5'd0 + DST[2:0];			// Select the input register to the sign extender
						sxt_bit_num <= 4'd7;					// Provide sign bit to sign extender
						sxt_bus_ctrl <= 1'b0;					// Use the register file as input to the sign extender
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						data_bus_ctrl <= 7'b0100001;			// Write the sign extender output to the dst register
						enables[13] <= 1'b1;					// Enable the sign extender
					end
					27:	// SETPRI
					begin
						// Leaving blank for now
					end
					28:	// SVC
					begin
						// Leaving blank for now
					end
					29:	// SETCC
					begin
						psw[4:0] <= psw[4:0] | PSWb[4:0];
					end
					30:	// CLRCC
					begin
						psw[4:0] <= psw[4:0] & ~(PSWb[4:0]);
					end
					31:	// CEX
					begin
						// Leaving blank for now
					end
					32:	// LD (Multi-step)
					begin
					
					end
					33:	// ST (Multi-step)
					begin
					
					end
					34,35,36,37:	// MOVL to MOVH
					begin
						bm_op <= OP[6:0] - 6'd34;				// Set the Byte Manipulation block operation
						bm_rnum <= 5'd0 + DST[2:0];				// Select the input register to the Byte Manipulation block
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						data_bus_ctrl <= 7'b0101001;			// Write the Byte Manipulation block output to the dst register
						enables[12] <= 1'b1;					// Enable the Byte Manipulation block
					end
					38:	// LDR (Multi-step)
					begin
						alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
						alu_rnum_src <= 5'd0 + SRCCON[2:0];		// Select the source register for the ALU
						sxt_bit_num <= 4'd6;					// Provide sign bit to sign extender
						sxt_bus_ctrl <= 1'b1;					// Use the offset from the instruction decoder
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
						ctrl_reg_bus <= 3'b001 + (WB<<2);		// Read memory from MAR address to MDR
						data_bus_ctrl <= 7'b0000001 + (WB<<6);	// Write the data from the MDR to the dst register
						enables[13] <= 1'b1;					// Enable the sign extender
						enables[15] <= 1'b1;					// Enable the ALU
						
						// Second step
						// Wait for write to dst reg to be complete
					end
					39:	// STR (Multi-step)
					begin
						alu_rnum_dst <= 5'd0 + DST[2:0];		// Select the destination register for the ALU
						alu_rnum_src <= 5'd0 + SRCCON[2:0];		// Select the source register for the ALU
						sxt_bit_num <= 4'd6;					// Provide sign bit to sign extender
						sxt_bus_ctrl <= 1'b1;					// Use the offset from the instruction decoder
						dbus_rnum_dst <= 5'd0 + DST[2:0];		// Select the the dst reg for the data bus
						data_bus_ctrl <= 7'b0001000 + (WB<<6);	// Write the data from the src register to the MDR
						addr_bus_ctrl <= 7'b0011000;			// Write the ALU output to the MAR
						ctrl_reg_bus <= 3'b001 + (WB<<2);		// Write data from MDR to memory at MAR address
						enables[13] <= 1'b1;					// Enable the sign extender
						enables[15] <= 1'b1;					// Enable the ALU
						
						// Second step
						// Wait for write to memory to be complete
					end
				endcase
			end
			5:
			begin
				
			end
		endcase	
		cpucycle = 1
	end
		

endmodule
