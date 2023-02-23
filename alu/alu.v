// TODO add psw update
// TODO add .b options
// PSW V S N Z C
module alu (SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, OT, PSW_i, PSW_o);
	input [17:0] SW;
	input OT;
	input [15:0] PSW_i;

    output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	output wire [6:0] HEX4;
	output wire [6:0] HEX5;
	output wire [6:0] HEX6;
	output wire [6:0] HEX7;
	output reg [15:0] PSW_o;
	
	reg [15:0] Reg3;
	
	reg [7:0] memory [0:16'hffff];
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end


    wire Clock;
	wire [3:0] Reg1_sel, Reg2_sel;
	wire [15:0] Reg1, Reg2;
	wire [7:0] instr;
	wire [3:0] nib0, nib1, nib2, nib3, nib4, nib5, nib6, nib7;
	assign Clock = OT;
	assign instr = SW[17:10];
	assign carry = SW[9];
	assign Reg1_sel = SW[3:0];
	assign Reg2_sel = SW[7:4];

	assign Reg1 [7:0] = memory[Reg1_sel][7:0];
	assign Reg1 [15:8] = memory[Reg1_sel + 1][7:0];

	assign Reg2 [7:0] = memory[Reg2_sel][7:0];
	assign Reg2 [15:8] = memory[Reg2_sel + 1][7:0];

	assign nib4 = PSW_o[3:0];
	assign nib0 = Reg3[3:0];
	assign nib1 = Reg3[7:4];
	assign nib2 = Reg3[11:8];
	assign nib3 = Reg3[15:12];
	assign nib5 = PSW_o[7:4];

	assign nib6 = sdr_b;
	assign nib7 = sdr_w;


	//MSB of src, dst, res in order
	wire [2:0] sdr_b;
	wire [2:0] sdr_w;

	assign sdr_b[2] = Reg2[7];
	assign sdr_b[1] = Reg1[7];
	assign sdr_b[0] = Reg3[7]; 

	assign sdr_w[2] = Reg2[15];
	assign sdr_w[1] = Reg1[15];
	assign sdr_w[0] = Reg3[15]; 

	
//    sixteen_bit_full_adder A1(Reg1, Reg2, Reg3, cin, cout, add, Clock);
	seven_seg_decoder decode1( 	.Reg1 (nib0), 
								.HEX0 (HEX0), 
								.Clock (Clock));
										
	seven_seg_decoder decode2( 	.Reg1 (nib1), 
								.HEX0 (HEX1), 
								.Clock (Clock));
										
	seven_seg_decoder decode3( 	.Reg1 (nib2), 
								.HEX0 (HEX2), 
								.Clock (Clock));
										
	seven_seg_decoder decode4( 	.Reg1 (nib3), 
								.HEX0 (HEX3), 
								.Clock (Clock));

	seven_seg_decoder decodepsw1(	.Reg1 (nib4),
									.HEX0 (HEX4),
									.Clock (Clock));
	seven_seg_decoder decodepsw2(	.Reg1(nib5),
									.HEX0(HEX5),
									.Clock(Clock));
				
	seven_seg_decoder decodepsdrb(	.Reg1(nib6),
									.HEX0(HEX6),
									.Clock(Clock));

	seven_seg_decoder decodesdr_w(	.Reg1(nib7),
									.HEX0(HEX7),
									.Clock(Clock));
	/* Switch assignment for instructions:
	add 	-> 17
	addc 	-> 17 + 11
	sub 	-> 16
	subc	-> 16 + 11
	cmp 	-> 16 + 12 (doesn't do anything different than sub atm)
	xor 	-> 15
	and		-> 14
	sra		-> 13
	rrc 	-> 13 + 11
	set carry to 1 -> 10
	*/
	always @(posedge Clock) begin
		memory[0] <= Reg3[7:0];
		memory[1] <= Reg3[15:8];
			case (instr)
			5'b00000: begin	// add
				Reg3 <= Reg1 + Reg2;						
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00001: begin // add.b
				Reg3[7:0] <= Reg1[7:0] + Reg2[7:0]; 			
				Reg3[15:8] <= Reg1[15:8];
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00010: begin // addc
				Reg3 <= Reg1 + Reg2 + carry;
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]); 	
			end
			5'b00011: begin	// addc.b
				Reg3 <= Reg1[7:0] + Reg2[7:0] + carry;
				Reg3[15:8] <= Reg1[15:8];						
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00100: begin	// sub	
				Reg3 <= Reg1 - Reg2; 							
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00101: begin // sub.b
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0]; 			
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00110: begin // subc
				Reg3 <= Reg1 - Reg2 + carry;					
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00111: begin // subc.b
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0] + carry; 	
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b01001: begin // dadd 
			end
			68: begin
				Reg3 <= Reg1 - Reg2;							// cmp
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			69: begin
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0];				// cmp.b
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			32: begin
				Reg3 <= Reg1 ^ Reg2;							// xor
				update_psw_logic(Reg3, instr[0]);
			end
			33: begin
				Reg3[7:0] <= Reg1[7:0] ^ Reg2[7:0];				// xor.b
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_logic(Reg3, instr[0]);
			end
			16: begin
				Reg3 <= Reg1 & Reg2; 							// and
				update_psw_logic(Reg3, instr[0]);
			end
			17: begin
				Reg3[7:0] <= Reg1[7:0] & Reg2[7:0];	    		// and.b
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_logic(Reg3, instr[0]);
			end
			//TODO add sign extension
			8: Reg3 <= Reg1 >> 1;							    // sra
			9: begin
				Reg3[7:0] <= Reg1[7:0] >> 1;	   				// sra.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			10: begin 											// rrc
				PSW_o [0] <= Reg1[0];
				Reg3 <= Reg1 >> 1;
				Reg3[15] <= Reg3[15] | carry;
			end
			11: begin											// rrc.b
				PSW_o[0] <= Reg1[0];
				Reg3[7:0] <= Reg1[7:0] >> 1;
				Reg3[7] <= Reg3[7] | carry;
				Reg3[15:8] <= Reg1[15:8];		
			end

			endcase
			end
	
	task update_psw_logic;
		input [15:0] reg1;
		input b;

		if (b) begin
			//Negative
			PSW_o[2] <= reg1[7] & 1'b1;
			//Zero
			PSW_o[1] <= reg1[7:0] ? 1'b0 :  1'b1;
		end else begin
			//Negative
			PSW_o[2] <= reg1[15] & 1'b1;
			//Zero
			PSW_o[1] <= reg1 ? 1'b0 : 1'b1;
		end
	endtask

	/* S	D	R	C	V
	 * 0	0	0 	0	0
	 * 0	0	1	0	1
	 * 0	1	0	1	0
	 * 0 	1	1	0	0
	 * 1	0	0	1	0
	 * 1	0	1	0	0
	 * 1	1 	0	1	1	
	 * 1	1	1	1	0
	 */
	task update_psw_arithmetic;
		input [15:0] reg1, src, dst;
		input b;
			

		if (b) begin
			case(sdr_b) 
			3'b000: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b001: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 1;
			end
			3'b010: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b011: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b100: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b101: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b110: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 1;
			end
			3'b111: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			endcase	
		end else begin
			case(sdr_w) 
			3'b000: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b001: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 1;
			end
			3'b010: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b011: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b100: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b101: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b110: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 1;
			end
			3'b111: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			endcase	
		end
		update_psw_logic(reg1, b);	
	endtask

endmodule