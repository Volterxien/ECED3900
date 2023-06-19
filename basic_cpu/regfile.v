module regfile(regnum, rw, datain, dataout);
	input [7:0]regnum;
	input rw;
	input [15:0]datain;
	output [15:0] dataout;
	
	reg [15:0] regFile[7:0];
	
	initial begin
		reg_file[0] = 16'h0000;
		reg_file[1] = 16'h0000;
		reg_file[2] = 16'h0000;
		reg_file[3] = 16'h0000;
		reg_file[4] = 16'h0000;
		reg_file[5] = 16'h0000;
		reg_file[6] = 16'h0800;
		reg_file[7] = 16'h0000;
	end
	
	reg [15:0] temp;
	always @*begin
	if(rw) //0 read or 1 write
		begin
		regFile[regnum] = dataout;
		end
	 else 
		begin
		temp = regFile[regnum];
		end
	end
	
	assign dataout = temp;

endmodule