module adder (SW, HEX0, HEX1, HEX2, HEX3, OT);
    input [17:0] SW;
	 input OT;
    output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	
	reg [15:0] Reg1;
	

    wire Clock, add;
	wire [3:0] nib0, nib1, nib2, nib3;
	assign Clock = OT;
	assign nib0 = Reg1[3:0];
	assign nib1 = Reg1[7:4];
	assign nib2 = Reg1[11:8];
	assign nib3 = Reg1[15:12];
   
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
        Reg1 <= SW[15:0];
	end
	

	

endmodule