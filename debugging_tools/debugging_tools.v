module debugging_tools (SW, HEX0, HEX1, HEX2, HEX3, LEDG, LEDG7, LEDR, LEDR16_17, KEY);
	input [17:0] SW;
	input [3:0] KEY;
	output wire [5:0] LEDG;
	output wire [15:0] LEDR;
	output reg [1:0] LEDR16_17;
	output reg LEDG7;
	output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	// Example for how to initialize memory: https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
	
	reg [7:0] memory [0:16'hffff];
	reg [15:0] reg_file [0:7];
	reg [15:0] psw;
	reg execution_type;
	reg [15:0] bkpnt;
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		psw = 16'habc8;
		reg_file[0] = 16'h1234;
		reg_file[5] = 16'h5678;
		$readmemh("memory.txt", memory, 0);
	end
	
	wire Clock;
	wire [15:0] addr, breakpnt;
	wire [3:0] reg_num;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	reg [15:0] PC = 16'h0000;
	
	
	
	assign addr = SW[15:0];
	assign breakpnt = bkpnt[15:0];
	
	assign mem_mode[1:0] = KEY[2:1];
	
	assign mem_data[15:12] = memory[addr[15:0]+1][7:4];
	assign mem_data[11:8] = memory[addr[15:0]+1][3:0];
	assign mem_data[7:4] = memory[addr[15:0]][7:4];
	assign mem_data[3:0] = memory[addr[15:0]][3:0];
	assign psw_data[15:0] = psw[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	
	// Indicator of whether CPU is currently executing instructions based on PSW SLP bit
	always @(psw[3]) begin
		if (psw[3] == 1'b1)
			LEDR16_17[0] = 1'b0;
		else
			LEDR16_17[0] = 1'b1;
	end
	
	// Selection of execution modes. SW16 = 1 for continuous. SW16 = 0 for step.
	always @(SW[16]) begin
		if (SW[16] == 1'b1)
			begin
			LEDR16_17[1] = 1'b1;
			execution_type = 1'b1;
			end
		else
			begin
			LEDR16_17[1] = 1'b0;
			execution_type = 1'b0;
			end
	end
	
	// Breakpoint setting
	always @(SW[17]) begin
		if (SW[17] == 1'b1)
			begin
			LEDG7 = 1'b1;
			bkpnt = addr[15:0];
			end
		else
			LEDG7 = 1'b0;
	end
	
	
endmodule