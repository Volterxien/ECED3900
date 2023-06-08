module seven_seg_decoder(Reg1, HEX0, Clock);
	input Clock;
	input [3:0] Reg1;
	output reg [6:0] HEX0;
	
	
	always @(posedge Clock) begin
        case (Reg1)
			0: HEX0 = 7'b1000000;
			1: HEX0 = 7'b1111001;
			2: HEX0 = 7'b0100100;
			3: HEX0 = 7'b0110000;
			4: HEX0 = 7'b0011001;
			5: HEX0 = 7'b0010010;
			6: HEX0 = 7'b0000010;
			7: HEX0 = 7'b1111000;
			8: HEX0 = 7'b0000000;
			9: HEX0 = 7'b0010000;
            10: HEX0 = 7'b0001000;
            11: HEX0 = 7'b0000011;
            12: HEX0 = 7'b1000110;
            13: HEX0 = 7'b0100001;
            14: HEX0 = 7'b0000110;
            15: HEX0 = 7'b0001110;
            default HEX0 = 7'b0000000;
        endcase
	end
endmodule