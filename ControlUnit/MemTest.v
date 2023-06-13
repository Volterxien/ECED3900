module MemTest(SW, LED, clk);

	input [7:0]SW, clk;
	output [7:0]LED;
	reg [15:0]regfile[15:0], instr; 
/*
	assign regfile[8]  = 16'h00;
	assign regfile[9]  = 16'h01;
	assign regfile[10] = 16'h02;
	assign regfile[11] = 16'h04;
	assign regfile[12] = 16'h08;
	assign regfile[13] = 16'h10;
	assign regfile[14] = 16'h20;
	assign regfile[15] = 16'hff;
	
	
	
	wire [15:0]memAddr;
	wire [15:0]memData;
	wire [16:0]dataFromMem;
	
	//begin CPU
	reg [15:0] psw;
	reg [15:0] mdr;
	reg [15:0] mar;
	
	reg rw; // 0 for read, 1 for write
	wire [15:0] bus;
	//end CPU
	
	wire [15:0]in;
	assign in = SW;
	
	assign bus = mdr;
	instr = bus;

	
always @ (posedge clk)
begin
	regfile[0] = in;
end

if (rwmode == 0) begin 	
end
*/
endmodule