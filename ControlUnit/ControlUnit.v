//`include "regfile.v"

module ControlUnit;
	
	// Control Unit Registers
	reg [5:0]PSW;
	reg ctrlReg; //contains rw bit
	reg CEX;
	reg [15:0] mdr, mar, IR;
	reg [15:0] fault, exception
	reg [2560:0] stack //not final size
	

	wire [15:0]address, data, memAddr, memData;
	wire rw, ena, clk;

	//inputs
	wire [5:0]opcode;
	wire [15:0] modifiers, operand;
	wire [12:0]offset;
	wire [3:0]cccc;
	wire [3:0]ttt, fff, pr, dst, src;
	wire [4:0]pswInst, pswAlu;
	wire wb, rc, cexState;
	wire [7:0]imm;
	wire prpo, dec, inc, flt;
	wire [15:0]pswIV, instr;
	wire [2:0] carry

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
	if (exception != 0) begin
	
	case(instr)
		1: exe(offset) //BL
		2: exe(offset) //BEQ/BZ
		3: exe(offset)
		4: exe(offset)
		5: exe(offset)
		6: exe(offset)
		7: exe(offset)
		8: exe(offset)
		9: exe(offset)
		10: alu(dst, src, rc, wb)
		11: alu(dst, src, rc, wb)
		12: alu(dst, src, carry), wb
		13: alu(dst, src, rc, wb)
		14: alu(dst, src, carry, wb)
		15: alu(dst, src, rc, wb)
		17: alu(dst, src, rc, wb)
		18: alu(dst, src, rc, wb)
		19: alu(dst, src, rc, wb)
		20: alu(dst, src, rc, wb)
		21: alu(dst, src, rc, wb)
		22: alu(dst, src, rc, wb)
		23: alu(dst, src, rc, wb)
		24: shift(dst)
		25: shift(dst)
		26: shift(dst)
		27: signext(dst)
		28: mem(dst, src, wb, rw)
		29: mem(dst, src, wb, rw)
		31: regfile(dst, imm)
		32: regfile(dst, imm)
		33: regfile(dst, imm)
		34: mem(dst, src, wb, rw)
		35: mem(dst, src, wb, rw)
	endcase 
		

endmodule
