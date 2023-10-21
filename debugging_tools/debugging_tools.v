module debugging_tools (SW, CLOCK_50, HEX0, HEX1, HEX2, HEX3, LEDG, LEDG7, LEDR, LEDR16_17, KEY);
	input [17:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
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
	
	reg [15:0] reg_file [0:16];
	reg [15:0] mar = 16'h0000;
	reg [15:0] mdr = 16'h0000;
	reg [15:0] psw_in = 16'h60f0;
	reg [2:0] ctrl_reg = 3'b011;
	reg execution_type = 1'b0;
	reg [15:0] brkpnt;
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		reg_file[0] = 16'h1234;
		reg_file[1] = 16'h5678;
		reg_file[2] = 16'h9abc;
		reg_file[3] = 16'hdef0;
		reg_file[4] = 16'd0;
		reg_file[5] = 16'd0;
		reg_file[6] = 16'd0;
		reg_file[7] = 16'd0;
		reg_file[8] = 16'd0;
		reg_file[9] = 16'd1;
		reg_file[10] = 16'd2;
		reg_file[11] = 16'd4;
		reg_file[12] = 16'd8;
		reg_file[13] = 16'd16;
		reg_file[14] = 16'd32;
		reg_file[15] = 16'hffff;
		reg_file[16] = 16'h0000;
		brkpnt = 16'h0004;
	end
	
	wire Clock;
	wire [15:0] addr, stop_pnt;
	wire [3:0] reg_num;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	reg [15:0] PC = 16'h0000;
	wire [15:0] mem_ub_addr, mem_lb_addr;
	wire [7:0] mem_ub, mem_lb;
	wire [15:0] breakpoint;
	
	
	assign addr = SW[15:0];
	assign breakpoint = brkpnt[15:0];
	assign mem_mode[1:0] = KEY[2:1];
	//assign Clock = (execution_type == 1'b0) ? KEY[0] : CLOCK_50;
	assign Clock = KEY[0];
	assign mem_ub_addr = (psw_data[3] == 1'b0) ? (mar[15:0] + 1) : (addr + 1);
	assign mem_lb_addr = (psw_data[3] == 1'b0) ? mar[15:0] : addr;
	
	assign mem_data = mdr[15:0];
	assign psw_data[15:0] = psw_in[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	memory ram(Clock, mdr[7:0], mdr[15:8], mem_lb_addr, mem_ub_addr, 1, 1, mem_lb, mem_ub);
	
	// Indicator of whether CPU is currently executing instructions based on PSW SLP bit
	always @(psw_data[3]) begin
		if (psw_data[3] == 1'b1)
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
			brkpnt = addr[15:0];
			end
		else
			LEDG7 = 1'b0;
	end
	
	always @(negedge Clock) begin
		mdr[7:0] <= mem_lb[7:0];
		mdr[15:8] <= mem_ub[7:0];
	end
	
endmodule