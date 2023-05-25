module debugging_tools (SW, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR, KEY);
	input [16:0] SW;
	input [3:0] KEY;
	output reg [5:0] LEDG;
	output reg [15:0] LEDR;
	output reg [6:0] HEX0;
	output reg [6:0] HEX1;
	output reg [6:0] HEX2;
	output reg [6:0] HEX3;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	// Example for how to initialize memory: https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
	
	reg [7:0] memory [0:16'hffff];
	reg [15:0] reg_file [0:7];
	reg [15:0] psw;
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end
	
	wire Clock;
	wire [15:0] addr;
	wire [3:0] reg_num;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	reg [15:0] PC = 16'h0000;
	
	assign Clock = SW[16];
	assign addr = SW[15:0];
	
	assign mem_mode[1:0] = KEY[2:1];
	
	assign mem_data[15:12] = memory[addr[15:0]+1][7:4];
	assign mem_data[11:8] = memory[addr[15:0]+1][3:0];
	assign mem_data[7:4] = memory[addr[15:0]][7:4];
	assign mem_data[3:0] = memory[addr[15:0]][3:0];
	assign psw_data[15:0] = psw[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	
	
endmodule