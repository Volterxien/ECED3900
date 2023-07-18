module loader_demo (SW, HEX0, HEX1, HEX2, HEX3);
	input [16:0] SW;
	output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	// Example for how to initialize memory: https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
	// How to use while integer from: https://nandland.com/while-loop/
	
	reg [7:0] memory [0:16'hffff];
	
	/* The following lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end
	
	wire Clock;
	wire [15:0] addr;
	reg [3:0] nib0, nib1, nib2, nib3;
	assign Clock = SW[16];
	assign addr = SW[15:0];
	assign nib2 = memory[addr[15:0]][3:0];
	assign nib3 = memory[addr[15:0]][7:4];
	assign nib0 = memory[addr[15:0]+1][3:0];
	assign nib1 = memory[addr[15:0]+1][7:4];
   
	seven_seg_decoder decode1( .Reg1 (nib0), .HEX0 (HEX0), .Clock (Clock));
	seven_seg_decoder decode2( .Reg1 (nib1), .HEX0 (HEX1), .Clock (Clock));
	seven_seg_decoder decode3( .Reg1 (nib2), .HEX0 (HEX2), .Clock (Clock));
	seven_seg_decoder decode4( .Reg1 (nib3), .HEX0 (HEX3), .Clock (Clock));
	
endmodule