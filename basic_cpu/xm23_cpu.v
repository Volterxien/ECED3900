module xm23_cpu (SW, HEX0, HEX1, HEX2, HEX3, LEDG, LEDG7, LEDR, LEDR16_17, KEY);
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
	reg [16:0] reg_file [0:7];
	reg [15:0] psw_in, instr_reg, mar, mdr;
	reg [15:0] data_bus, addr_bus;
	reg [2:0] ctrl_reg;
	reg execution_type;
	reg [15:0] bkpnt;
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		$readmemh("memory.txt", memory, 0);
	end
	
	wire Clock;
	wire [6:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 3b for src, 3b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU, 4=SXT_out, 5=BMB_out, 6=PSW)]
	wire s_bus_ctrl, sxt_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	wire [15:0] addr, breakpnt;
	wire [4:0] dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, sxt_bit_num, bm_rnum, sxt_rnum;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	wire [15:0] mar_mem_bus, mdr_mem_bus;
	wire [15:0] sxt_in, sxt_out;
	wire [15:0] bm_in, bm_out;
	wire [2:0] bm_op;
	wire [5:0] alu_op;
	wire [15:0] s_bus, d_bus, alu_out;
	wire [2:0] CR_bus;
	wire sxt_E, bm_E, alu_E, mov_E;
	
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
	wire [7:0] ImByte, bm_byte;
	wire PRPO;
	wire DEC;
	wire INC;
	wire FLTo;
	
	wire psw_update;
	
	assign addr = SW[15:0];
	assign breakpnt = bkpnt[15:0];
	
	assign mem_mode[1:0] = KEY[2:1];
	
	assign mem_data[15:12] = memory[addr[15:0]+1][7:4];
	assign mem_data[11:8] = memory[addr[15:0]+1][3:0];
	assign mem_data[7:4] = memory[addr[15:0]][7:4];
	assign mem_data[3:0] = memory[addr[15:0]][3:0];
	assign psw_data = psw[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];
	
	assign mar_mem_bus = mar[15:0];
	assign d_bus = reg_file[alu_rnum_dst[3:0]][15:0];
	assign bm_in = reg_file[bm_rnum[3:0]][15:0];
	assign bm_byte = ImByte[7:0];
	assign sxt_in = (sxt_bus_ctrl == 1'b0) ? reg_file[sxt_rnum[3:0]][15:0] : (OFF[12:0]<<2);
	assign s_bus = (s_bus_ctrl == 1'b0) ? source_bus <= reg_file[alu_rnum_src[4:0]][15:0] : sxt_out[15:0];

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	sign_extender sxt_ext(sxt_in, sxt_out, sxt_bit_num, sxt_E);
	byte_manip byte_manipulator(bm_op, bm_in, bm_out, bm_byte, bm_E);
	instruction_decoder ID(Instr, E, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, FLTo, Clock);
	control_unit ctrl_unit(FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, psw);
	alu arithmetic_logic_unit(s_bus, d_bus, alu_out, alu_op, PSW_in, PSW_out, alu_E, psw_update);
	
	// Indicator of whether CPU is currently executing instructions based on PSW SLP bit
	always @(psw[3]) begin
		if (psw[3] == 1'b1)
			LEDR16_17[0] = 1'b0;	// Not executing
		else
			LEDR16_17[0] = 1'b1;	// Executing
	end
	
	// Selection of execution modes. SW16 = 1 for continuous. SW16 = 0 for step.
	always @(SW[16]) begin
		if (SW[16] == 1'b1) begin
			LEDR16_17[1] = 1'b1;
			execution_type = 1'b1;
		end
		else begin
			LEDR16_17[1] = 1'b0;
			execution_type = 1'b0;
		end
	end
	
	// Breakpoint setting
	always @(SW[17]) begin
		if (SW[17] == 1'b1) begin
			LEDG7 = 1'b1;
			bkpnt = addr[15:0];
		end
		else
			LEDG7 = 1'b0;
	end
	
	// Update registers
	always @(posedge Clock) begin
		ctrl_reg <= CR_bus[2:0];
		instr_reg <= data_bus[15:0];
	end
	
	// Memory Accessing
	always @(posedge ctrl_reg[0]) begin		// Enable is toggled
		if (ctrl_reg[1] == 1'd0) begin		// Reading
			if (ctrl_reg[2] == 1'd0) begin	// Read Word
				mdr[15:8] <= memory[mar_mem_bus[15:0]+1];
				mdr[7:0] <= memory[mar_mem_bus[15:0]];
			end
			else begin						// Read Byte
				mdr[15:8] <= 8'd0;
				mdr[7:0] <= memory[mar_mem_bus[15:0]];
			end
		end
		else if (ctrl_reg[1] == 1'd1) begin	// Writing
			if (ctrl_reg[2] == 1'd0) begin	// Write Word
				memory[mar_mem_bus[15:0]+1] <= mdr[15:8];
				memory[mar_mem_bus[15:0]] <= mdr[7:0];
			end
			else begin						// Write Byte
				memory[mar_mem_bus[15:0]] <= mdr[7:0];
			end
		end
	end
	
	// Bus Assignment (MUX)
	always @(negedge Clock) begin
		// Data Bus Updating
		if (data_bus_ctrl[2:0] == 3'b000) begin 			// MDR
			if (data_bus_ctrl[5:3] == 3'b001)				// Read from Register File into MDR
				mdr <= reg_file[dbus_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b011)			// Read from ALU Output into MDR
				mdr <= alu_output[15:0];
		end
		else if (data_bus_ctrl[2:0] == 3'b001) begin 		// Register File
			if (data_bus_ctrl[5:3] == 3'b000)				// Read from MDR into Register File
				reg_file[dbus_rnum_dst[4:0]] <= mdr[15:0];
			else if (data_bus_ctrl[5:3] == 3'b011) begin	// Read from ALU Output into Register File
				if (data_bus_ctrl[4] == 1'b1)				// Byte
					reg_file[dbus_rnum_dst[4:0]][7:0] <= alu_output[7:0];
				else										// Word
					reg_file[dbus_rnum_dst[4:0]] <= alu_output[15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b001) begin 	// Read from Register File into Register File
				if (data_bus_ctrl[4] == 1'b1)
					reg_file[dbus_rnum_dst[4:0]][7:0] <= reg_file[dbus_rnum_src[4:0]][7:0];
				else										// Word
					reg_file[dbus_rnum_dst[4:0]] <= reg_file[dbus_rnum_src[4:0]][15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b100) begin 	// Read from Sign Extender Output into Register File
				reg_file[dbus_rnum_dst[4:0]] <= sxt_out[15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b101) begin 	// Read from Byte Manipulator Output into Register File
				reg_file[dbus_rnum_dst[4:0]] <= bm_out[15:0];
			end
		end
		else if (data_bus_ctrl[2:0] == 3'b010) begin 		// Instruction Register
			if (data_bus_ctrl[5:3] == 3'b001)				// Read from Register File into Instruction Register
				instr_reg <= reg_file[dbus_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b000)			// Read from MDR into Instruction Register
				instr_reg <= mdr[15:0];
		end
		else if (data_bus_ctrl[2:0] == 3'b110) begin 		// PSW
			if (data_bus_ctrl[5:3] == 3'b000)				// Read from MDR into PSW
				psw_in <= mdr[15:0];
		end
		
		// Address Bus Updating
		if (addr_bus_ctrl[2:0] == 3'b000) begin 			// MAR
			if (addr_bus_ctrl[5:3] == 3'b001)				// Read from Register File into MAR
				mar <= reg_file[dbus_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b011) 			// Read from ALU Output into MAR
				mar <= alu_output[15:0];
		end	
	end
endmodule