// TODO add psw update
module alu (SW, HEX0, HEX1, HEX2, HEX3, OT, PSW_i, PSW_o);
	input [17:0] SW;
	input OT;
	input PSW_i;

    output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	output wire PSW_o;
	
	reg [16:0] Reg3;
	
	reg [7:0] memory [0:16'hffff];
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end


    wire Clock;
	wire [3:0] Reg1_sel, Reg2_sel;
	wire [15:0] Reg1;
	wire [15:0] Reg2;	
	wire [6:0] instr;
	wire [3:0] nib0, nib1, nib2, nib3;
	assign Clock = OT;
	assign instr = SW[17:11];
	assign carry = SW[10];
	assign do = SW[8];
	assign Reg1_sel = SW[3:0];
	assign Reg2_sel = SW[7:4];

    assign Reg1[7:0]=memory[Reg1_sel][7:0];
    assign Reg1[15:8]=memory[Reg1_sel+1][7:0];

    assign Reg2[7:0]=memory[Reg2_sel][7:0];
    assign Reg2[15:8]=memory[Reg2_sel+1][7:0];

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

	always @(posedge Clock) begin
			case (instr)
			64: Reg3 <= Reg1 + Reg2;
			65: Reg3 <= Reg1 + Reg2 + carry;
			32: Reg3 <= Reg1 - Reg2;
			33: Reg3 <= Reg1 - Reg2 + carry;
			34: Reg3 <= Reg1 - Reg2;
			16: Reg3 <= Reg1 ^ Reg2;
			8: Reg3 <= Reg1 & Reg2;
			4: Reg3 <= Reg1 >> 1;
			5: begin 
				Reg3 <= Reg1 >> 1;
				Reg3[15] <= Reg3[15] | carry;
			end

			endcase
			end
	

	

endmodule