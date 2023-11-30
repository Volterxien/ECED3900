/* 
 * Top level module for XM-23 CPU.
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	xm23_cpu.v
 * Module: 		xm23_cpu
 * Description: Module that instantiates all other modules and handles memory bus allocation.
 * Acknowledgements:
 *		This project was built using the XM3 document provided by Dr. Larry Hughes (2020).
 *		The basics for programming in Verilog were learned through tutorials provided by Dr. Ma (n.d.).
 *		We greatly appreciate their help in this project.
 *
 * 		How to do multiple cases (throughout project) in one line came from Greg (2017).
 *		How to implement inferred ram in memory.v came from Intel (n.d.).
 *		How to implement tasks (throughout project) came from NANDLAND (n.d.-a).
 *		How to initialize memory (throughout project) came from examples in Green (2021) and Bissa (2021).
 *		How to utilize blocking and non-blocking assignment (throughout project) came from NANDLAND (n.d.-b).
 *		How to make an always block have multiple sensitivities (throughout project) came from (FPGAcademy, 2022).
 *		Logic for the CEX execution came from McCoy (2022).
 *
 * References:
 *	Bissa, P. (2021, November 29). Re: read from file to memory in verilog [Comment]. 
 *		https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
 *
 * 	FPGAcademy. (2022, March). Using the ModelSim-Intel FPGA Simulator with Verilog testbenches.
 *		https://github.com/fpgacademy/Tutorials/releases/download/v21.1/ModelSim_Testbenches_Verilog.pdf
 *
 *	Green, W. (2021, July 20). Initialize memory in Verilog. Project F. Retrieved November 26, 2023, from 
 *		https://projectf.io/posts/initialize-memory-in-verilog/
 *
 *	Greg. (2017, December 7). Re: case statement with multiple cases doing same operation [Comment]. 
 *		https://stackoverflow.com/questions/47702202/case-statement-with-multiple-cases-doing-same-operation
 *	
 *	Hughes, L. (2020). Introduction to the XM3 Instruction Set Architecture. Retrieved January 
 *		20, 2023, via email from Dr. Larry Hughes.
 *
 *	Intel. (n.d.). Intel® Quartus® Prime Pro Edition User Guide: Design recommendations: 1.4.1.8. True Dual-Port 
 *		Synchronous RAM. Retrieved November 18, 2023, from 
 *		https://www.intel.com/content/www/us/en/docs/programmable/683082/22-3/true-dual-port-synchronous-ram.html
 *	
 *	Ma, Y. (n.d.). ECED 4260 – IC Design and Fabrication. Advanced MicroElectroMechanical Systems (A-MEMS) 
 *			and Application Laboratory. Retrieved April 4, 2023, from http://mems.ece.dal.ca/eced4260/labs.php
 *
 * 	McCoy, M. (2022). debug.c [Unpublished code]. Electrical and Computer Engineering Department, Dalhousie University.
 *
 *	NANDLAND. (n.d.-a). Task – Verilog example. Retrieved November 18, 2023, from https://nandland.com/task/
 *
 *	NANDLAND. (n.d.-b). Blocking vs. Nonblocking in Verilog. Retrieved November 29, 2023, from 
 *		https://nandland.com/blocking-vs-nonblocking-in-verilog/
 *	
 */
module xm23_cpu (SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, LEDG, LEDG7, LEDR, LEDR16_17, KEY, CLOCK_50, GPIO,
				traffic_lights, push_button, arduino_data_i, arduino_data_o, arduino_ctrl_i, arduino_ctrl_o, test_gpio, test_gpio2);
	input [17:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	input GPIO;
	input push_button;
	output wire [5:0] LEDG;
	output wire [15:0] LEDR;
	output reg [1:0] LEDR16_17;
	output reg LEDG7;
	output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	output wire [6:0] HEX4;
	output wire [6:0] HEX5;
	output wire [6:0] HEX6;
	output wire [6:0] HEX7;
	output wire [3:0] traffic_lights;

	output wire [7:0] arduino_data_o;
	input [7:0] arduino_data_i;
	output wire [1:0] arduino_ctrl_o;
	input [1:0] arduino_ctrl_i;

	output reg test_gpio;
	output reg test_gpio2;
	parameter initial_PC = 16'h1000;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	// Example for how to initialize memory: https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog

	reg [15:0] reg_file [0:16];			// Declare the register file
	reg [7:0] dev_mem [0:15];
	reg [15:0] instr_reg, mar, mdr, psw_in;
	reg [15:0] data_bus, addr_bus;
	reg [2:0] ctrl_reg;
	reg execution_type = 1'b0;
	reg [15:0] bkpnt;
	reg [15:0] extension = 16'hffff;

	initial begin
		$readmemh("device_memory.txt", dev_mem, 0);
	end
	reg access_dev_mem;
	reg register_access_flag;
	reg word_rf_mdr;
	reg byte_rf_mdr;
	wire [7:0] kb_data_output, tl_data_output, pb_data_output;
	parameter tmr_csr = 0, tmr_data = 1;
	parameter kb_csr = 2, kb_data = 3;
	parameter scr_csr = 4, scr_data = 5;
	parameter tl_csr = 6, tl_data = 7; 
	parameter pb_csr = 8, pb_data = 9;

	wire [7:0] /*arduino_data_i, arduino_data_o, */csr_kb_o, csr_scr_o, csr_tmr_o, csr_tl_o, csr_pb_o;
	// wire [1:0] arduino_ctrl_i, arduino_ctrl_o;


	reg [7:0] iv_mem [0:63];
	reg access_iv_mem = 1'b0;

	initial begin
		$readmemh("int_vect_memory.txt", iv_mem, 0);
	end

	
	initial begin
		reg_file[0] = 16'd0;
		reg_file[1] = 16'd0;
		reg_file[2] = 16'd0;
		reg_file[3] = 16'd0;
		reg_file[4] = 16'd0;
		reg_file[5] = 16'd0;
		reg_file[6] = 16'h0800;
		reg_file[7] = initial_PC;
		reg_file[8] = 16'd0;
		reg_file[9] = 16'd1;
		reg_file[10] = 16'd2;
		reg_file[11] = 16'd4;
		reg_file[12] = 16'd8;
		reg_file[13] = 16'd16;
		reg_file[14] = 16'd32;
		reg_file[15] = 16'hffff;
		reg_file[16] = 16'h0000;
		ctrl_reg = 3'b000;
		bkpnt = 16'h1014;
		psw_in = 16'h60e0;
		mar = 16'h0000;
		mdr = 16'h0000;	
		
		register_access_flag = 1'b0;
	end
	
	wire Clock;
	wire [6:0] data_bus_ctrl, addr_bus_ctrl; 	// [1b for W/B, 3b for src, 3b for dst (Codes: 0=MDR/MAR, 1=Reg File, 2=IR, 3=ALU, 4=SXT_out, 5=BMB_out, 6=PSW)]
	wire s_bus_ctrl, sxt_bus_ctrl;							// 0 = use Reg File, 1 = use calculated offset
	wire [15:0] addr, breakpnt, PC;
	wire [4:0] dbus_rnum_dst, dbus_rnum_src, addr_rnum_src, alu_rnum_dst, alu_rnum_src, bm_rnum, sxt_rnum;
	wire [3:0] sxt_bit_num;
	wire [1:0] psw_bus_ctrl;
	wire [1:0] mem_mode;
	wire [15:0] mem_data, reg_data, psw_data;
	wire [15:0] mar_mem_bus, mdr_mem_bus;
	wire [15:0] sxt_in, sxt_out, alu_psw_out, psw_out;
	wire [15:0] bm_in, bm_out;
	wire [2:0] bm_op;
	wire [5:0] alu_op;
	wire [15:0] s_bus, d_bus, alu_out;
	wire [2:0] CR_bus;
	wire [3:0] cu_out1, cu_out2, cu_out3;
	wire id_E, ID_en;
	wire sxt_shift;
	
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
	wire ID_FLTo, dbl_flt;
	wire [3:0] vect_num;
	wire [7:0] cex_state_out, cex_state_in;
	wire [1:0] PSW_ENT;
	wire pic_read, breakpnt_set;
	wire [7:0] pic_in;
	
	wire psw_update;
	wire [2:0] new_curr_pri;	// Priority of the new interrupt
	
	wire [3:0] nib4, nib5, nib6, nib7;
	
	assign pic_in = 8'b00000000;
	assign addr = SW[15:0];
	assign breakpnt = bkpnt[15:0];
	assign PC = reg_file[7][15:0];
	assign cex_state_in = mdr[7:0];
	
	assign mem_mode[1:0] = KEY[2:1];
	
	assign mem_data = ((addr <= 15 && addr >=0) ? {dev_mem[addr[3:0]+1], dev_mem[addr]} : 
						((addr <= 16'hffff && addr >= 16'hffc0) ? {iv_mem[addr[7:0]-8'hc0+1], iv_mem[addr[7:0]-8'hc0]} : mdr[15:0]));
	assign psw_data = psw_out[15:0];
	assign reg_data = reg_file[addr[3:0]][15:0];
	
	//assign Clock = (execution_type == 1'b0) ? KEY[0] : CLOCK_50;
	assign Clock = GPIO;
	assign mar_mem_bus = mar[15:0];
	assign mem_ub_addr = (breakpnt_set == 1'b0) ? (mar[15:0] + 1) : (addr + 1);
	assign mem_lb_addr = (breakpnt_set == 1'b0) ? mar[15:0] : addr;
	
	assign new_curr_pri = reg_file[16][7:5];	// The new PSW is stored in the temp register (new pri accessed through this)
	
	assign d_bus = reg_file[alu_rnum_dst[4:0]][15:0];
	assign bm_in = reg_file[bm_rnum[3:0]][15:0];
	assign sxt_in = (sxt_bus_ctrl == 1'b0) ? reg_file[sxt_rnum[3:0]][15:0] : OFF[12:0];
	assign s_bus = (s_bus_ctrl == 1'b0) ? reg_file[alu_rnum_src[4:0]][15:0] : sxt_out[15:0];
	
	// Assign enable
	assign id_E = ID_en;
	
	//assign nib4 = cu_out2[3:0];
	//assign nib5 = cu_out3[3:0];
	//assign nib6 = s_bus[3:0];
	assign nib7 = cu_out1;
	assign nib6 = dev_mem[tl_csr][7:4];
	assign nib5 = dev_mem[tl_csr][3:0];
	assign nib4 = dev_mem[tmr_csr][3:0];
	
	// Devices
	assign traffic_lights = tl_data_output;
	
	seven_seg_decoder decode5( .Reg1 (nib4), .HEX0 (HEX4), .Clock (Clock));
	seven_seg_decoder decode6( .Reg1 (nib5), .HEX0 (HEX5), .Clock (Clock));
	seven_seg_decoder decode7( .Reg1 (nib6), .HEX0 (HEX6), .Clock (Clock));
	seven_seg_decoder decode8( .Reg1 (nib7), .HEX0 (HEX7), .Clock (~Clock));
	
	
	memory ram(Clock, mdr[7:0], mdr[15:8], mem_lb_addr, mem_ub_addr, ctrl_reg[0], ctrl_reg[1], mem_lb, mem_ub);

	view_data data_viewer(mem_data, reg_data, psw_data, addr, KEY[3], mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	
	sign_extender sxt_ext(sxt_in, sxt_out, sxt_bit_num, sxt_shift);
	
	byte_manip byte_manipulator(bm_op, bm_in, bm_out, ImByte);
	
	instruction_decoder ID(instr_reg, id_E, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, ImByte, PRPO, DEC, INC, ID_FLTo, Clock);
	
	control_unit ctrl_unit(Clock, ID_FLTo, OP, OFF, C, T, F, PR, SA, PSWb, DST, SRCCON, WB, RC, PRPO, DEC, INC, psw_in, psw_out, 
							ID_en, CR_bus, data_bus_ctrl, addr_bus_ctrl, s_bus_ctrl, sxt_bit_num, sxt_rnum, sxt_shift, alu_op, 
							psw_update, dbus_rnum_dst, dbus_rnum_src, alu_rnum_dst, alu_rnum_src, sxt_bus_ctrl, bm_rnum, bm_op,
							breakpnt, PC, addr_rnum_src, psw_bus_ctrl, cu_out1, cu_out2, cu_out3, vect_num, PSW_ENT, cex_state_out,
							cex_state_in, new_curr_pri, pic_in, pic_read, breakpnt_set, dbl_flt);
	
	alu arithmetic_logic_unit(d_bus, s_bus, alu_out, alu_op, psw_out, alu_psw_out, psw_update);

	kb_scr_drv kb_scr(kb_data_output, dev_mem[scr_data][7:0], dev_mem[kb_csr][7:0], dev_mem[scr_csr][7:0], arduino_data_i, 
						arduino_data_o, arduino_ctrl_i, arduino_ctrl_o, csr_scr_o, csr_kb_o, Clock);
	
	timer TMR (dev_mem[tmr_csr][7:0], dev_mem[tmr_data][7:0], csr_tmr_o, Clock);
	
	traffic_lights TL (dev_mem[tl_csr][7:0], csr_tl_o, dev_mem[tl_data][7:0], tl_data_output);
	
	pedest_button PB (dev_mem[pb_csr][7:0], csr_pb_o, push_button, pb_data_output);

	// Indicator of whether CPU is currently executing instructions based on breakpoint
	always @(PC) begin
		if (PC == breakpnt)
			LEDR16_17[0] = 1'b0;	// Not executing
		else
			LEDR16_17[0] = 1'b1;	// Executing
	end
	
	// Indicator to if a Double Fault Occurred
	always @(dbl_flt) begin
		if (dbl_flt == 1'b1) begin
			LEDR16_17[1] = 1'b1;
		end
		else begin
			LEDR16_17[1] = 1'b0;
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
		else if (psw_bus_ctrl == 2'b10)
			psw_in <= reg_file[dbus_rnum_src[4:0]][15:0];
		else if (psw_bus_ctrl == 2'b11)
			psw_in <= psw_data[15:0];
	end

	// Bus Assignment (MUX)
	always @(negedge Clock) begin
		access_dev_mem = 1'b0;
		register_access_flag = 1'b0;
		access_iv_mem = 1'b0;
		word_rf_mdr = 1'b0;
		byte_rf_mdr = 1'b0;
		//clear flag
		
		//Address Bus Updating
		if (addr_bus_ctrl[2:0] == 3'b000) begin 			// MAR
			if (addr_bus_ctrl[5:3] == 3'b001)				// Read from Register File into MAR
				mar = reg_file[addr_rnum_src[4:0]][15:0];
			else if (addr_bus_ctrl[5:3] == 3'b011) 			// Read from ALU Output into MAR
				mar = alu_out[15:0];
			else if (addr_bus_ctrl[5:3] == 3'b100)			// Read from Interrupt Vector addresses
				mar = 16'hffc0 + (vect_num[3:0] << 2) + PSW_ENT[1:0];	// Determine address from vector number and option
		end	

		if (mar <= 15 && mar >= 0) begin
			access_dev_mem = 1'b1;
		end

		if (mar <= 16'hffff && mar >= 16'hffc0) begin
			access_iv_mem = 1'b1;
		end
		
		mdr[7:0] = mem_lb[7:0];
		mdr[15:8] = mem_ub[7:0];
		
		// Data Bus Updating
		if (data_bus_ctrl[2:0] == 3'b000) begin 			// MDR
			if (data_bus_ctrl[5:3] == 3'b001) begin			// Read from Register File into MDR
				mdr = reg_file[dbus_rnum_src[4:0]][15:0]; 
				if(access_dev_mem || access_iv_mem) begin
					register_access_flag = 1'b1;
				end
			end
			else if (data_bus_ctrl[5:3] == 3'b011) begin	// Read from ALU Output into MDR
				mdr = alu_out[15:0];
				if(access_dev_mem || access_iv_mem) begin
					register_access_flag = 1'b1;
				end
			end
			else if (data_bus_ctrl[5:3] == 3'b100)			// Read from PSW into MDR
				mdr = psw_data[15:0];
			else if (data_bus_ctrl[5:3] == 3'b101)			// Read from CEX into MDR
				mdr = 16'h0 + cex_state_out[7:0];
		end
		else if (data_bus_ctrl[2:0] == 3'b001) begin 		// Register File
			if (data_bus_ctrl[5:3] == 3'b000)	begin			// Read from MDR into Register File
				if (data_bus_ctrl[6] == 1'b1)	begin		// Byte
					reg_file[dbus_rnum_dst[4:0]][7:0] = mdr[7:0];
					byte_rf_mdr = 1'b1;
				end
				else begin								// Word
					reg_file[dbus_rnum_dst[4:0]] = mdr[15:0];
					word_rf_mdr = 1'b1;
				end
			end
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
		
		dev_mem[kb_csr] = (!register_access_flag ? csr_kb_o : (mar[3:0] == kb_csr) ? mdr : dev_mem[kb_csr]);
		dev_mem[scr_csr] = (!register_access_flag ? csr_scr_o : (mar[3:0] == scr_csr) ? mdr : dev_mem[scr_csr]); //of/dba set here?
		dev_mem[tmr_csr] = (!register_access_flag ? csr_tmr_o : (mar[3:0] == tmr_csr) ? mdr : dev_mem[tmr_csr]);
		dev_mem[pb_csr] = (!register_access_flag ? csr_pb_o : (mar[3:0] == pb_csr) ? mdr : dev_mem[pb_csr]);
		dev_mem[tl_csr] = (!register_access_flag ? csr_tl_o : (mar[3:0] == tl_csr) ? mdr : dev_mem[tl_csr]);

		if(access_iv_mem && register_access_flag) begin
			iv_mem[mar[7:0] - 8'hc0 + 1] = mdr[15:8];
			iv_mem[mar[7:0] - 8'hc0] = mdr[7:0];
		end

		
		if (register_access_flag && mar[3:0] == tmr_data)
			dev_mem[tmr_data] = mdr[7:0];
			
		if (register_access_flag && mar[3:0] == tl_data)
			dev_mem[tl_data] = mdr[7:0];
		
		if (register_access_flag && mar[3:0] == scr_data) begin
			dev_mem[scr_data] = mdr;
			if (~dev_mem[scr_csr][2]) begin //check dba
				dev_mem[scr_csr][3] = 1'b1;
			end
			dev_mem[scr_csr][2] = 1'b0;
		end
		dev_mem[kb_data][7:0] = kb_data_output;
		dev_mem[pb_data][7:0] = pb_data_output;

		if (access_iv_mem && byte_rf_mdr) begin
			reg_file[dbus_rnum_dst[4:0]][7:0] = iv_mem[mar[5:0] - 8'hc0][7:0];
		end
		else if (access_iv_mem && word_rf_mdr) begin
			reg_file[dbus_rnum_dst[4:0]] = iv_mem[mar[7:0] - 8'hc0 + 1][7:0] << 8 | iv_mem[mar[7:0] - 8'hc0][7:0];
		end

		//read
		if (access_dev_mem && byte_rf_mdr) begin
			reg_file[dbus_rnum_dst[4:0]][7:0] = dev_mem[mar[3:0]][7:0];
		end
		else if (access_dev_mem && word_rf_mdr) begin
			reg_file[dbus_rnum_dst[4:0]] = dev_mem[mar[3:0]][7:0] << 8 | dev_mem[mar[3:0] + 1][7:0];
		end
		if (access_dev_mem && (byte_rf_mdr || word_rf_mdr)) begin
				if(mar[3:0] == kb_csr) begin
					dev_mem[kb_csr][2] = 1'b0;//dev_mem[kb_csr] & ~(1'b1 << 2); //dba clear
					dev_mem[kb_csr][3] = 1'b0;//dev_mem[kb_csr] & ~(1'b1 << 3); //of clear
				end
				if(mar[3:0] == tmr_csr) begin
					dev_mem[tmr_csr][2] = 1'b0;//dev_mem[tmr_csr] & ~(1'b1 << 2); //dba clear
					dev_mem[tmr_csr][3] = 1'b0;//dev_mem[tmr_csr] & ~(1'b1 << 3); //of clear
				end
				if(mar[3:0] == pb_csr) begin
					dev_mem[pb_csr][2] = 1'b0;//dev_mem[pb_csr] & ~(1'b1 << 2); //dba clear
					dev_mem[pb_csr][3] = 1'b0;//dev_mem[pb_csr] & ~(1'b1 << 3); //of clear
				end
			end
	end
endmodule