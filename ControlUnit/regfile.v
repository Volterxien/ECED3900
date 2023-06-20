module regfile(regnum, rw, datain, dataout, inc, regnumstr);
	input [7:0]regnum;
	input rw;
	input [15:0]datain;
	output [15:0] dataout;
	input inc; //1 if PC to be incremented
	input [7:0]regnumstr
	
	reg [15:0]regFile[15:0]; 

	/*regFile[8]  = 16'h00;
	regFile[9]  = 16'h01;
	regFile[10] = 16'h02;
	regFile[11] = 16'h04;
	regFile[12] = 16'h08;
	regFile[13] = 16'h10;
	regFile[14] = 16'h20;
	regFile[15] = 16'hff;*/
	
	always @* 
	begin
		if (inc == 1)
			regFile[7] = regFile[7] + 2
		else if (regnumstr)
			regnumstr <= regnum
		else
			if (rw) //0 read or 1 write
				regFile[regnum] <= dataout;
			else 
				temp = regFile[regnum];
	end
	
	assign dataout = temp;
	
	
endmodule