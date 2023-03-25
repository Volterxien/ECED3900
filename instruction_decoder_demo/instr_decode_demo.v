module instr_decode_demo (SW, HEX0, HEX1, HEX2, HEX3, KEY);
	input [16:0] SW;
	input KEY;
	output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	// Example for how to initialize memory: https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
	
	
	reg [7:0] memory [0:16'hffff];
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end
	
	wire Clock;
	wire [15:0] addr;
	wire [3:0] nib0, nib1, nib2, nib3;
	reg [15:0] PC = 16'h0000;
	
	wire [15:0] Instr;
	wire [6:0] OP;
	wire [12:0] OFF;
	wire [3:0] C;
	wire [2:0] T;
	wire [2:0] F;
	wire [2:0] PR;
	wire [3:0] SA;
	wire [4:0] PSWb;
	wire [2:0] DST;
	wire [2:0] SRCCON;
	wire WB;
	wire RC;
	wire [7:0] ImByte;
	wire PRPO;
	wire DEC;
	wire INC;
	wire FLTo;
	
	assign Clock = SW[16];
	assign addr = SW[15:0];
	assign nib2 = memory[addr[15:0]+1][3:0];
	assign nib3 = memory[addr[15:0]+1][7:4];
	assign nib0 = memory[addr[15:0]][3:0];
	assign nib1 = memory[addr[15:0]][7:4];
	
	
	assign Instr[15:8] = memory[PC[15:0]+1];
	assign Instr[7:0] = memory[PC[15:0]];
	assign E = 1'd1;		// Decoder enabled
	assign FLTi = 1'd0;		// Input faults?
   
	seven_seg_decoder decode1( .Reg1 (nib0), .HEX0 (HEX0), .Clock (Clock));
	seven_seg_decoder decode2( .Reg1 (nib1), .HEX0 (HEX1), .Clock (Clock));
	seven_seg_decoder decode3( .Reg1 (nib2), .HEX0 (HEX2), .Clock (Clock));
	seven_seg_decoder decode4( .Reg1 (nib3), .HEX0 (HEX3), .Clock (Clock));
	instruction_decoder ID( Instr, E, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, FLTo, Clock);
	
	always @(posedge Clock) begin
		memory[16'h2000] <= OP;
		memory[16'h2001] <= OFF[7:0];
		memory[16'h2002] <= OFF[12:8];
		memory[16'h2003] <= C;
		memory[16'h2004] <= T;
		memory[16'h2005] <= F;
		memory[16'h2006] <= PR;
		memory[16'h2007] <= SA;
		memory[16'h2008] <= PSWb;
		memory[16'h2009] <= DST;
		memory[16'h200a] <= SRCCON;
		memory[16'h200b] <= WB;
		memory[16'h200c] <= RC;
		memory[16'h200d] <= ImByte;
		memory[16'h200e] <= PRPO;
		memory[16'h200f] <= DEC;
		memory[16'h2010] <= INC;
		memory[16'h2011] <= FLTo;
	end
	
	always @(posedge KEY) begin
		PC <= PC + 2'd2;
	end
endmodule