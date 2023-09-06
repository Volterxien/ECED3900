module instruction_decoder (Instr, E, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, FLTo, Clock);
	input [15:0] Instr;
	input E;
	input Clock;
	
	output reg [6:0] OP;
	output reg [12:0] OFF;
	output reg [3:0] C;
	output reg [2:0] T;
	output reg [2:0] F;
	output reg [2:0] PR;
	output reg [3:0] SA;
	output reg [4:0] PSWb;
	output reg [2:0] DST;
	output reg [2:0] SRCCON;
	output reg WB;
	output reg RC;
	output reg [7:0] ImByte;
	output reg PRPO;
	output reg DEC;
	output reg INC;
	output reg FLTo = 1'd0;
	
	// How to do multiple cases in one line came from: https://stackoverflow.com/questions/47702202/case-statement-with-multiple-cases-doing-same-operation
	
	wire [2:0] bits13to15;
	wire [2:0] bits10to12;
	wire [3:0] bits8to11;
	wire [2:0] bits7to9;
	wire [3:0] bits5to6;
	wire [3:0] bits3to5;
	
	assign bits13to15 = Instr[15:13];
	assign bits10to12 = Instr[12:10];
	assign bits8to11 = Instr[11:8];
	assign bits7to9 = Instr[9:7];
	assign bits5to6 = Instr[6:5];
	assign bits3to5 = Instr[5:3];
	
	always @(posedge E) begin
		FLTo = 1'd0;	// Default to no faults
		case(bits13to15)
			0: 	begin
				OP = 6'd0; 		// BL
				OFF <= Instr[12:0];
				end
			1: 	begin
				OP <= 6'd1 + bits10to12;	// BEQ to BRA
				OFF <= Instr[9:0];
				end
			2:	begin
				case(bits10to12)
					0,1,2:	begin
						case(bits8to11)
							0:	OP = 6'd9;	// ADD
							1:	OP = 6'd10;	// ADDC
							2:	OP = 6'd11;	// SUB
							3: 	OP = 6'd12;	// SUBC
							4:	OP = 6'd13;	// DADD
							5:	OP = 6'd14;	// CMP
							6:	OP = 6'd15;	// XOR
							7:	OP = 6'd16;	// AND
							8:	OP = 6'd17;	// OR
							9:	OP = 6'd18;	// BIT
							10:	OP = 6'd19;	// BIC
							11: OP = 6'd20; // BIS
						endcase
						RC <= Instr[7];
						WB <= Instr[6];
						SRCCON <= Instr[5:3];
						DST <= Instr[2:0];
						end
							
					3:	begin
						case(bits7to9)
							0,1:	begin
								OP = 6'd21 + Instr[7];	// MOV, SWAP
								WB <= Instr[6];  // Can update, but will not be used for SWAP
								SRCCON <= Instr[5:3];
								DST <= Instr[2:0];
								end
								
							2:	begin		// SRA, RRC, SWPB, SXT
								OP <= 6'd23 + bits3to5;
								WB <= Instr[6]; // Can update, but will not be used for SWPB or SXT
								DST <= Instr[2:0];
								end
									
							3:	begin		// SETPRI, SVC, SETCC, CLRCC
								OP = 6'd28 + bits5to6;
								if (bits5to6 == 2'd0) begin
									if (Instr[4] == 1'b0)
										PR <= Instr[2:0];
									else
										OP = OP[6:0] + 1'b1;
										SA <= Instr[3:0];
								end
								else
									OP = OP[6:0] + 1'b1;
									PSWb <= Instr[4:0];
								end
						endcase
						end
							
					4:	begin
						OP = 6'd32;	// CEX
						C <= Instr[9:6];
						T <= Instr[5:3];
						F <= Instr[2:0];
						end
						
					5: 	begin
						if(Instr[9:0] == 6'd0)
							OP = 6'd41;	// BREAKPOINT
						else
							FLTo = 1'b1; // Only case for INVALID INSTR
						end
						
					6,7: begin
						if (bits10to12 == 3'd6)
							OP = 6'd33;	// LD
						else
							OP = 6'd34;	// ST
						PRPO <= Instr[9];
						DEC <= Instr[8];
						INC <= Instr[7];
						WB <= Instr[6];
						SRCCON <= Instr[5:3];
						DST <= Instr[2:0];
						end
				endcase
				end
					
			3:	begin
				case(bits10to12)
					0,1:	OP = 6'd35;	// MOVL
					2,3:	OP = 6'd36;	// MOVLZ
					4,5:	OP = 6'd37;	// MOVLS
					6,7:	OP = 6'd38;	// MOVH			
				endcase
				ImByte <= Instr[10:3];
				DST <= Instr[2:0];
				end
			4,5,6,7: begin
					if (bits13to15 >= 3'd6)
						OP = 6'd40;	// STR
					else
						OP = 6'd39;	// LDR
					OFF <= Instr[13:7];
					WB <= Instr[6];
					SRCCON <= Instr[5:3];
					DST <= Instr[2:0];
					end
		endcase
	end
endmodule