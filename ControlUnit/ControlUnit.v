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
	wire ena, clk;

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
	cpucyle = 1

	always @(*)
	begin
		case(cpucyle)
			1: //* fetch *//
			begin
				//Latch MAR to address bus
				assign address = mar
				PC = 7
				
				// Set to read and signal MAR to write to data bus
				ctrlReg = 1'b0
				regfile SETPC(.regnum(PC),.datain(address),.rw(ctrRel), .dataout(data));
				
				//Latch data bus to MDR
				mdr = data
				regFile INCREMENTPC(.inc)
				cpucycle = 2
			end
			2: //* decode *//
			begin
				assign instr = IR;
				//instruction input, opcode and operands output
				decoder(.instruction(instr), .opcode(opcode), .operands(operands))
				cpucycle = 3
			end
			3: //execute
			begin
				/** Instruction Executed Here */	
				case(instr)
					1: //BL
						begin
							sext(.offset(offset), .len(length), .res(result))
							rw = 0'b1
							//Store PC in link register
							LR = 5
							regFile STOREPC(.regnum(PC), .regnumstr(LR))

							//get value in PC and send to adder
							rw = 0'b0
							reg [7:0]currentPC
							regFile FETCHPC(.regnum(PC), .rw(rw), .dataout(currentPC))
							adder(.PC(currentPC), .res(result))
						end
					2: // BEQ
						begin
							exe(offset)
						end 
					3: exe(offset)
					4: exe(offset)
					5: exe(offset)
					6: exe(offset)
					7: exe(offset)
					8: exe(offset)
					9: //BRA
						begin
							sext(.offset(offset), .len(length), .res(result))
							rw = 0'b0
							reg [7:0]currentPC
							regFile FETCHPC(.regnum(PC), .rw(rw), .dataout(currentPC))
							adder(.PC(currentPC), .res(result))
						end
					10: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					11: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					12: alu(.dst(dst), .src(src), .carry(carry), .wb(wb) , .funccode(code))
					13: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					14: alu(.dst(dst), .src(src), .carry(carry), .wb(wb), .funccode(code))
					15: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					17: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					18: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					19: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					20: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					21: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					22: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
					23: alu(.dst(dst), .src(src), .rc(rc), .wb(wb), .funccode(code))
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
				cpucycle = 1
			end
		endcase	
	end
		

endmodule
