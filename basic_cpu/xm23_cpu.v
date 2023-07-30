module xm23_cpu (SW, HEX0, HEX1, HEX2, HEX3, LEDG, LEDG7, LEDR, LEDR16_17, KEY, CLOCK_50);
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
	reg [15:0] instr_reg, mar, mdr, psw_in;
	reg [15:0] data_bus, addr_bus;
	reg [2:0] ctrl_reg;
	reg execution_type;
	reg [15:0] bkpnt;
	reg [15:0] extension = 16'hffff;
	
	/* The following 3 lines are where memory is loaded */
	initial begin
		reg_file[0] = 16'd0;
		reg_file[1] = 16'd0;
		reg_file[2] = 16'd0;
		reg_file[3] = 16'd0;
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
		bkpnt = 16'h00f8;
		psw_in = 16'h60e0;
	end
	
	wire Clock;
	wire [6:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 3b for src, 3b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU, 4=SXT_out, 5=BMB_out, 6=PSW)]
	wire s_bus_ctrl, sxt_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	wire [15:0] addr, breakpnt;
	wire [4:0] dbus_rnum_dst, dbus_rnum_src, addr_rnum_src, alu_rnum_dst, alu_rnum_src, bm_rnum, sxt_rnum;
	wire [3:0] sxt_bit_num;
	wire [1:0] psw_bus_ctrl;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	wire [15:0] mar_mem_bus, mdr_mem_bus;
	wire [15:0] sxt_in, sxt_out, alu_psw_out, psw_out, enables;
	wire [15:0] bm_in, bm_out;
	wire [2:0] bm_op;
	wire [5:0] alu_op;
	wire [15:0] s_bus, d_bus, alu_out;
	wire [2:0] CR_bus;
	wire sxt_E, bm_E, alu_E, id_E;
	
	
	wire [15:0] mem_ub_addr, mem_lb_addr;
	wire [7:0] mem_ub, mem_lb;
	
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
	
	wire psw_update;
	
	assign addr = SW[15:0];
	assign breakpnt = bkpnt[15:0];
	
	assign mem_mode[1:0] = KEY[2:1];
	
	assign mem_data = mdr[15:0];
	assign psw_data = psw_out[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];
	
	assign Clock = (execution_type == 1'b0) ? KEY[0] : CLOCK_50;
	
	assign mar_mem_bus = mar[15:0];
	assign mem_ub_addr = (psw_data[3] == 1'b0) ? (mar[15:0] + 1) : (addr + 1);
	assign mem_lb_addr = (psw_data[3] == 1'b0) ? mar[15:0] : addr;
	
	
	
	assign d_bus = reg_file[alu_rnum_dst[4:0]][15:0];
	assign bm_in = reg_file[bm_rnum[3:0]][15:0];
	assign sxt_in = (sxt_bus_ctrl == 1'b0) ? reg_file[sxt_rnum[3:0]][15:0] : (OFF[12:0]<<1);
	assign s_bus = (s_bus_ctrl == 1'b0) ? reg_file[alu_rnum_src[4:0]][15:0] : sxt_out[15:0];
	
	// Assign enables
	assign alu_E = enables[15];
	assign id_E = enables[14];
	assign sxt_E = enables[13];
	assign bm_E = enables[12];
	
	
	memory ram(Clock, mdr[7:0], mdr[15:8], mem_lb_addr, mem_ub_addr, ctrl_reg[0], ctrl_reg[1], mem_lb, mem_ub);

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	
	sign_extender sxt_ext(sxt_in, sxt_out, sxt_bit_num, sxt_E);
	
	byte_manip byte_manipulator(bm_op, bm_in, bm_out, ImByte, bm_E);
	
	instruction_decoder ID(instr_reg, id_E, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, FLTo, Clock);
	
	control_unit ctrl_unit(Clock, FLTi, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, PRPO, DEC, INC, psw_in, psw_out, 
							enables, CR_bus, data_bus_ctrl, addr_bus_ctrl, s_bus_ctrl, sxt_bit_num, sxt_rnum, alu_op, 
							psw_update, dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, sxt_bus_ctrl, bm_rnum, bm_op,
							breakpnt, reg_file[7][15:0], addr_rnum_src, psw_bus_ctrl);
	
	alu arithmetic_logic_unit(d_bus, s_bus, alu_out, alu_op, psw_out, alu_psw_out, alu_E, psw_update);
	
	// Indicator of whether CPU is currently executing instructions based on PSW SLP bit
	always @(psw_data[3]) begin
		if (psw_data[3] == 1'b1)
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
			bkpnt <= addr[15:0];
		end
		else
			LEDG7 = 1'b0;
	end
	
	// Update registers
	always @(negedge Clock) begin
		ctrl_reg = CR_bus[2:0];
		if (psw_bus_ctrl == 2'b00)
			psw_in <= alu_psw_out[15:0];
		else if (psw_bus_ctrl == 2'b01)
			psw_in <= mdr[15:0];
		else if (psw_bus_ctrl == 2'b11)
			psw_in <= psw_data[15:0];
	end

	// Bus Assignment (MUX)
	always @(negedge Clock) begin
		mdr[7:0] = mem_lb[7:0];
		mdr[15:8] = mem_ub[7:0];
		
		// Data Bus Updating
		if (data_bus_ctrl[2:0] == 3'b000) begin 			// MDR
			if (data_bus_ctrl[5:3] == 3'b001)				// Read from Register File into MDR
				mdr <= reg_file[dbus_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b011)			// Read from ALU Output into MDR
				mdr = alu_out[15:0];
		end
		else if (data_bus_ctrl[2:0] == 3'b001) begin 		// Register File
			if (data_bus_ctrl[5:3] == 3'b000)				// Read from MDR into Register File
				if (ctrl_reg == 3'b100)						// Byte
					reg_file[dbus_rnum_dst[4:0]][7:0] = mdr[7:0];
				else										// Word
					reg_file[dbus_rnum_dst[4:0]] = mdr[15:0];
			else if (data_bus_ctrl[5:3] == 3'b011) begin	// Read from ALU Output into Register File
				if (data_bus_ctrl[6] == 1'b1)				// Byte
					reg_file[dbus_rnum_dst[4:0]][7:0] = alu_out[7:0];
				else										// Word
					reg_file[dbus_rnum_dst[4:0]] = alu_out[15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b001) begin 	// Read from Register File into Register File
				if (data_bus_ctrl[6] == 1'b1)				// Byte
					reg_file[dbus_rnum_dst[4:0]][7:0] = reg_file[dbus_rnum_src[4:0]][7:0];
				else										// Word
					reg_file[dbus_rnum_dst[4:0]] = reg_file[dbus_rnum_src[4:0]][15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b100) begin 	// Read from Sign Extender Output into Register File
				reg_file[dbus_rnum_dst[4:0]] = sxt_out[15:0];
			end
			else if (data_bus_ctrl[5:3] == 3'b101) begin 	// Read from Byte Manipulator Output into Register File
				reg_file[dbus_rnum_dst[4:0]] = bm_out[15:0];
			end
		end
		else if (data_bus_ctrl[2:0] == 3'b010) begin 		// Instruction Register
			if (data_bus_ctrl[5:3] == 3'b001)				// Read from Register File into Instruction Register
				instr_reg = reg_file[dbus_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b000)			// Read from MDR into Instruction Register
				instr_reg = mdr[15:0];
		end
		
		// Address Bus Updating
		if (addr_bus_ctrl[2:0] == 3'b000) begin 			// MAR
			if (addr_bus_ctrl[5:3] == 3'b001)				// Read from Register File into MAR
				mar = reg_file[addr_rnum_src[4:0]][15:0];
			else if (data_bus_ctrl[5:3] == 3'b011) 			// Read from ALU Output into MAR
				mar = alu_out[15:0];
		end	
	end
endmodule