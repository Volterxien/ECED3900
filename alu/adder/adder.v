module adder (SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, OT);
    input [17:0] SW;
	 input OT;
    output wire [6:0] HEX0;
	 output wire [6:0] HEX1;
	 output wire [6:0] HEX2;
	 output wire [6:0] HEX3;
	 output wire [6:0] HEX4;
	 output wire [6:0] HEX5;
	 output wire [6:0] HEX6;
	 output wire [6:0] HEX7;
	
	reg [15:0] Reg1;
	reg [15:0] Reg2;
	reg [15:0] Reg3;
	

    wire Clock, add, c1, c2, s1, cin;
	wire [3:0] nib0, nib1, nib2, nib3;
	assign Sel = SW[16];
	assign Clock = OT;
	assign add = SW[17];
	assign nib0 = Reg1[3:0];
	assign nib1 = Reg1[7:4];
	assign nib2 = Reg1[11:8];
	assign nib3 = Reg1[15:12];
   
//    sixteen_bit_full_adder A1(Reg1, Reg2, Reg3, cin, cout, add, Clock);
	seven_seg_decoder decode1( .Reg1 (nib0), 
										.HEX0 (HEX0), 
										.Clock (Clock));
										
	// seven_seg_decoder decode2( .Reg1 (nib1), 
	// 									.HEX0 (HEX1), 
	// 									.Clock (Clock));
										
	// seven_seg_decoder decode3( .Reg1 (nib2), 
	// 									.HEX0 (HEX2), 
	// 									.Clock (Clock));
										
	// seven_seg_decoder decode4( .Reg1 (nib3), 
	// 									.HEX0 (HEX3), 
	// 									.Clock (Clock));

	seven_seg_decoder decode5( .Reg1 (Reg2[3:0]), 
										.HEX0 (HEX4), 
										.Clock (Clock));
		
	// seven_seg_decoder decode6( .Reg1 (Reg2[7:4]), 
	// 									.HEX0 (HEX5), 
	// 									.Clock (Clock));
		
	// seven_seg_decoder decode7( .Reg1 (Reg2[11:8]), 
	// 									.HEX0 (HEX6), 
	// 									.Clock (Clock));
		
	// seven_seg_decoder decode8( .Reg1 (Reg2[15:12]), 
	// 									.HEX0 (HEX7), 
	// 									.Clock (Clock));
	seven_seg_decoder decode9 ( .Reg1 (Reg3[3:0]),
								.HEX0 (HEX7),
								.Clock (Clock));

	always @(posedge Clock) begin
			if (! add) begin
				Reg3 <= Reg1 + Reg2;
			end else if (! Sel) begin
				Reg1 <= SW[15:0];
			end else begin
				Reg2 <= SW[15:0];
				end
			end
	

	

endmodule