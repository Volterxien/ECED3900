// TODO add psw update
// TODO add .b options
// PSW V S N Z C
module alu (SW, HEX0, HEX1, HEX2, HEX3, HEX4, OT, PSW_i, PSW_o);
	input [17:0] SW;
	input OT;
	input [15:0] PSW_i;

    output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	output wire [6:0] HEX4;
	output reg [15:0] PSW_o;
	
	reg [8:0] Reg3_1, Reg3_2;
	reg [16:0] Reg3;
	
	reg [7:0] memory [0:16'hffff];
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end


    wire Clock;
	wire [3:0] Reg1_sel, Reg2_sel;
	// wire [7:0] Reg1_1, Reg1_2, Reg2_1, Reg2_2;
	wire [15:0] Reg1, Reg2;
	wire [7:0] instr;
	wire [3:0] nib0, nib1, nib2, nib3, nib4;
	assign Clock = OT;
	assign instr = SW[17:10];
	assign carry = SW[9];
	assign do = SW[8];
	assign Reg1_sel = SW[3:0];
	assign Reg2_sel = SW[7:4];
//uncomment below for byte arithmetic
    // assign Reg1_1[7:0]=memory[Reg1_sel][7:0];
    // assign Reg1_2[7:0]=memory[Reg1_sel+1][7:0];

    // assign Reg2_1[7:0]=memory[Reg2_sel][7:0];
    // assign Reg2_2[7:0]=memory[Reg2_sel+1][7:0];


	assign Reg1 [7:0] = memory[Reg1_sel][7:0];
	assign Reg1 [15:8] = memory[Reg1_sel + 1][7:0];

	assign Reg2 [7:0] = memory[Reg2_sel][7:0];
	assign Reg2 [15:8] = memory[Reg2_sel + 1][7:0];

	// assign nib0 = Reg3_1[3:0];
	// assign nib1 = Reg3_1[7:4];
	// assign nib2 = Reg3_2[3:0];
	// assign nib3 = Reg3_2[7:4];
	assign nib4 = PSW_o[3:0];
	assign nib0 = Reg3[3:0];
	assign nib1 = Reg3[7:4];
	assign nib2 = Reg3[11:8];
	assign nib3 = Reg3[15:12];


	
//    sixteen_bit_full_adder A1(Reg1, Reg2, Reg3, cin, cout, add, Clock);
	seven_seg_decoder decode1( .Reg1 (nib0), 
										.HEX0 (HEX0), 
										.Clock (Clock));
										
	seven_seg_decoder decode2( .Reg1 (nib1), 
										.HEX0 (HEX1), 
										.Clock (Clock));
										
	seven_seg_decoder decode3( .Reg1 (nib2), 
										.HEX0 (HEX2), 
										.Clock (Clock));
										
	seven_seg_decoder decode4( .Reg1 (nib3), 
										.HEX0 (HEX3), 
										.Clock (Clock));

	seven_seg_decoder decode5( 	.Reg1 (nib4),
								.HEX0 (HEX4),
								.Clock (Clock));
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
			case (instr)
			131: begin
				Reg3 <= Reg1[7:0] + Reg2[7:0] + carry;
				Reg3[15:8] <= Reg1[15:8];			// addc.b
			end
			130: Reg3 <= Reg1 + Reg2 + carry;					// addc
			129: begin 
				Reg3[7:0] <= Reg1[7:0] + Reg2[7:0]; 			// add.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			128: Reg3 <= Reg1 + Reg2;							// add
			64: begin
				Reg3 <= Reg1 - Reg2; 							// sub	
				update_psw_logic(Reg3, 0);
			// PSW_o[2] <= Reg3[15] & 1'b1;
			// PSW_o[1] <= Reg3 ? 1'b0 : 1'b1;
			end
			66: Reg3 <= Reg1 - Reg2 + carry;					// subc
			65: begin 
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0]; 			// sub.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			67: begin
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0] + carry; 	// subc.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			68: Reg3 <= Reg1 - Reg2;							// cmp
			69: begin
				 Reg3[7:0] <= Reg1[7:0] - Reg2[7:0];				// cmp.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			32: Reg3 <= Reg1 ^ Reg2;							// xor
			33: begin
				 Reg3[7:0] <= Reg1[7:0] ^ Reg2[7:0];				// xor.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			16: Reg3 <= Reg1 & Reg2; 							// and
			17: begin
				 Reg3[7:0] <= Reg1[7:0] & Reg2[7:0];	    		// and.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			8: Reg3 <= Reg1 >> 1;							    // sra
			9: begin
				Reg3[7:0] <= Reg1[7:0] >> 1;	   					// sra.b
				Reg3[15:8] <= Reg1[15:8];		
			end
			10: begin 											// rrc
				Reg3 <= Reg1 >> 1;
				Reg3[15] <= Reg3[15] | carry;
			end
			11: begin											// rrc.b
				Reg3[7:0] <= Reg1[7:0] >> 1;
				Reg3[7] <= Reg3[7] | carry;
				Reg3[15:8] <= Reg1[15:8];		
			end

			endcase
			end
	
	task update_psw_logic;
		input [16:0] reg1;
		input byte;

		if (byte) begin
			PSW_o[2] <= reg1[7] & 1'b1;
			PSW_o[1] <= reg1[7:0] ? 1'b0 :  1'b1;
		end else begin
			PSW_o[2] <= reg1[15] & 1'b1;
			PSW_o[1] <= reg1 ? 1'b0 : 1'b1;
		end
	endtask

	task update_psw_arithmetic;
		input [8:0] reg1_1, reg1_2, src_1, src_2, dst_1, dst_2;
		input byte;

		if (byte) begin
			PSW_o[1] <= reg1_1[7:0] ? 1'b0 : 1'b1;
			PSW_o[2] <= reg1_1[7] & 1;
		end else begin
			PSW_o[1] <= (reg1_1[7:0] | reg1_2[7:0]) ? 1'b0 : 1'b1;
			PSW_o[2] <= reg1_2[7] & 1;
		end

	
	endtask

endmodule