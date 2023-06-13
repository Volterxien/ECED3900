module regfile(regnum, rw, datain, dataout);
	input [7:0]regnum;
	input rw;
	input [15:0]datain;
	output [15:0] dataout;
	
	reg [15:0]regFile[15:0]; 

	/*regFile[8]  = 16'h00;
	regFile[9]  = 16'h01;
	regFile[10] = 16'h02;
	regFile[11] = 16'h04;
	regFile[12] = 16'h08;
	regFile[13] = 16'h10;
	regFile[14] = 16'h20;
	regFile[15] = 16'hff;*/
	
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