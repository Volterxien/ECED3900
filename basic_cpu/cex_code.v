module cex_code(psw_in, code, result);
	input [15:0] psw_in;
	input [3:0] code;
	
	output result;
	
	always @(code, psw) begin
		case (code)
			0: 	// EQ/EZ
			begin
				if (psw_in[1] == 1'b1)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			1:	// NE/NEZ
			begin
				if (psw_in[1] == 1'b0)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			2:	// CS/HS
			begin
				if (psw_in[0] == 1'b1)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			3:	// CC/LO
			begin
				if (psw_in[0] == 1'b0)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			4:	// MI
			begin
				if (psw_in[2] == 1'b1)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			5:	// PL
			begin
				if (psw_in[2] == 1'b0)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			6:	// VS
			begin
				if (psw_in[4] == 1'b1)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			7:	// VC
			begin
				if (psw_in[4] == 1'b0)
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			8:	// HI
			begin
				if ((psw_in[0] == 1'b1) && (psw_in[1] == 1'b0))
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			9:	// LS
			begin
				if ((psw_in[0] == 1'b0) || (psw_in[1] == 1'b1))
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			10:	// GE
			begin
				if (psw_in[2] == psw_in[4])
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			11:	// LT
			begin
				if (psw_in[2] != psw_in[4])
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			12:	// GT
			begin
				if ((psw_in[1] == 1'b0) && (psw_in[2] == psw_in[4]))
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			13:	// LE
			begin
				if ((psw_in[1] == 1'b1) || (psw_in[2] != psw_in[4]))
					result <= 1'b1;
				else
					result <= 1'b0;
			end
			14:	// AL
				result <= 1'b1;
		endcase
	end
endmodule