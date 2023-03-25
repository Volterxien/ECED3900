module instruction_decoder (Instr, E, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, FLTo, Clock);
	input [15:0] Instr;
	input E;
	input FLTi;	// Needed?
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
	wire [3:0] bits4to6;
	
	assign bits13to15 = Instr[15:13];
	assign bits10to12 = Instr[12:10];
	assign bits8to11 = Instr[11:8];
	assign bits7to9 = Instr[9:7];
	assign bits4to6 = Instr[6:4];
	
	always @(posedge Clock) begin
		if (E == 1'b1)
			case(bits13to15)
				0: 	begin
					OP = 6'd0; 		// BL
					OFF <= Instr[12:0];
					end
				1: begin
					case(bits10to12)
						0:	begin
							OP = 6'd1;	// BRA
							OFF <= Instr[9:0];
							end
							
						1:	begin
							OP = 6'd2;	// CEX
							C <= Instr[9:6];
							T <= Instr[5:3];
							F <= Instr[2:0];
							end
						
						2:
							case(bits4to6)
								0:	begin
									OP = 6'd3;	// SETPRI
									PR <= Instr[2:0];
									end
								
								1:	begin
									OP = 6'd4;	// SVC
									SA <= Instr[3:0];
									end
								
								2,3:	begin
										OP = 6'd5;	// SETCC
										PSWb <= Instr[4:0];
										end
								
								4,5:	begin
										OP = 6'd6;	// CLRCC
										PSWb <= Instr[4:0];
										end
							endcase
					endcase
					end
				2:	begin
					case(bits10to12)
						0,1,2:	begin
							case(bits8to11)
								0:	OP = 6'd7;	// ADD
								1:	OP = 6'd8;	// ADDC
								2:	OP = 6'd9;	// SUB
								3: 	OP = 6'd10;	// SUBC
								4:	OP = 6'd11;	// DADD
								5:	OP = 6'd12;	// CMP
								6:	OP = 6'd13;	// XOR
								7:	OP = 6'd14;	// AND
								8:	OP = 6'd15;	// BIT
								9:	OP = 6'd16;	// BIC
								10:	OP = 6'd17;	// BIS
							endcase
							RC <= Instr[7];
							WB <= Instr[6];
							SRCCON <= Instr[5:3];
							DST <= Instr[2:0];
							end
							
						3:	begin
							case(bits7to9)
								0:	begin
									OP = 6'd18;	// MOV
									WB <= Instr[6];
									SRCCON <= Instr[5:3];
									end
									
								1:	begin
									OP = 6'd19;	// SWAP
									SRCCON <= Instr[5:3];
									end
									
								2:	begin
									OP = 6'd20;	// SRA
									WB <= Instr[6];
									end
									
								3:	begin
									OP = 6'd21;	// RRC
									WB <= Instr[6];
									end
								
								4:	begin
									if(Instr[3] == 1'd1)
										OP = 6'd23;	// SXT
									else
										OP = 6'd22; // SWPB
									end
							endcase
							DST <= Instr[2:0];
							end
							
						4:	OP = 6'd32;	// BREAKPOINT
						
						5: FLTo = 1'b1; // Only case for INVALID INSTR
						
						6,7: begin
							if (bits10to12 == 3'd6)
								OP = 6'd24;	// LD
							else
								OP = 6'd25;	// ST
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
						0,1:	OP = 6'd26;	// MOVL
						2,3:	OP = 6'd27;	// MOVLZ
						4,5:	OP = 6'd28;	// MOVLS
						6,7:	OP = 6'd29;	// MOVH			
					endcase
					ImByte <= Instr[10:3];
					DST <= Instr[2:0];
					end
				4,5,6,7: begin
						if (bits13to15 >= 3'd6)
							OP = 6'd31;	// STR
						else
							OP = 6'd30;	// LDR
						OFF <= Instr[13:7];
						WB <= Instr[6];
						SRCCON <= Instr[5:3];
						DST <= Instr[2:0];
						end
			endcase
	end
endmodule