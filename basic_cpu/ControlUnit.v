//`include "regfile.v"

module ControlUnit;
	
	// Control Unit Registers
	reg [5:0]PSW;
	reg ctrlReg; //contains rw bit
	reg CEX;
	reg [15:0] mdr, mar, IR;
	

	wire [15:0]address, data, memAddr, memData;
	wire rw, ena, clk;

	//inputs
	wire [5:0]opcode;
	wire [15:0] modifiers, operand;
	wire [12:0]offset;
	wire [3:0]cccc;
	wire [2:0]ttt, fff, pr, dst, src;
	wire [4:0]pswInst, pswAlu;
	wire wb, rc, cexState;
	wire [7:0]imm;
	wire prpo, dec, inc, flt;
	wire [15:0]pswIV, instr;

	//unique outputs (some outputs use input bus)
	wire idEnable, irEnable, crEnable, pcIncrementEna;
	wire [4:0]aluFunction;
	
	
	
	
	//* fetch *//
	wire PC = 7; 
	wire R = 0;
	
	regfile FETCHPC(.regnum(PC),.data(mar),.rw(R));
	
	
	//* decode *//
	assign instr = IR;
	//add decoder supported for this
	
	//** decoder spits out opcode **//
	
	//execute
	/** Instruction Executed Here */

endmodule
