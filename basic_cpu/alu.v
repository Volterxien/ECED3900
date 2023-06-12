// PSW V S N Z C
// TODO change carry bit -> PSW_i[0] for full implementation
// TODO add dadd.b bit bis bic after meeting
module alu (op1, op2, result, instr, PSW_i, PSW_o, E);
	input E;
	input [15:0] op1;
	input [15:0] op2;
	input [5:0] instr;
	input [15:0] PSW_i;
	output reg [15:0] PSW_o;
	output reg [15:0] result;
	reg [15:0] Reg3;
	
	wire [15:0] Reg1, Reg2, sum1;
	wire [4:0] instr;
	wire carry;

	assign Reg1 [15:0] = op1[15:0];
	assign Reg2 [15:0] = op2[15:0];

	//MSB of src, dst, res in order
	wire [2:0] sdr_b;
	wire [2:0] sdr_w;

	//for psw updates
	assign sdr_b[2] = Reg2[7];
	assign sdr_b[1] = Reg1[7];
	assign sdr_b[0] = Reg3[7];

	assign sdr_w[2] = Reg2[15];
	assign sdr_w[1] = Reg1[15];
	assign sdr_w[0] = Reg3[15]; 

	// for dadd instruction
	assign sum1 = (Reg1 + Reg2);
	
	assign carry = PSW_i[0];
	
	always @(posedge E) begin
			case (instr)
			5'b00000: begin	// add
				Reg3 <= Reg1 + Reg2;						
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00001: begin // add.b
				Reg3[7:0] <= Reg1[7:0] + Reg2[7:0]; 			
				Reg3[15:8] <= Reg1[15:8];
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00010: begin // addc
				Reg3 <= Reg1 + Reg2 + carry;
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]); 	
			end
			5'b00011: begin	// addc.b
				Reg3 <= Reg1[7:0] + Reg2[7:0] + carry;
				Reg3[15:8] <= Reg1[15:8];						
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00100: begin	// sub	
				Reg3 <= Reg1 - Reg2; 							
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00101: begin // sub.b
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0]; 			
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00110: begin // subc
				// subc == dst <- dst + ~src + carry
				// since minus sign does 2s complement, subtract 1 if carry is clear
				Reg3 <= Reg1 - Reg2 - ~carry;					
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b00111: begin // subc.b
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0] - ~carry; 	
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b01000: begin // dadd 
				if(sum1[3:0] >= 4'ha) begin
					Reg3[7:0] <= (sum1[3:0] - 10) & 4'hf;
					if(sum1[15:8] + 1 >= 4'ha) begin
						Reg3[15:8] <= (sum1[11:8] + 1 - 10) & 4'hf;
						PSW_o[0] <= 1'b1;
					end 
					else
						Reg3[15:8] <= (sum1[11:8]) & 4'hf;
				end 
				else begin
					Reg3[7:0] <= (sum1[3:0]) & 4'hf;
					if (sum1[11:8] >= 4'ha) begin
						Reg3[15:8] <= (sum1[11:8] - 10) & 4'hf;
						PSW_o[0] <= 1'b1;
					end
					else 
						Reg3[15:8] <= (sum1[11:8]) & 4'hf;
				end
			end
			5'b01001: begin //dadd.b
				if(sum1[3:0] >= 4'ha) begin
					Reg3[7:0] <= (sum1[3:0] - 10) & 4'hf;
					PSW_o[0] <= 1'b1;
				end 
				else
					Reg3[7:0] <= (sum1[3:0]) & 4'hf;
			end
			5'b01010: begin // cmp
				Reg3 <= Reg1 - Reg2;							
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b01011: begin //cmp.b
				Reg3[7:0] <= Reg1[7:0] - Reg2[7:0];
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_arithmetic(Reg3, Reg2, Reg1, instr[0]);
			end
			5'b01100: begin // xor
				Reg3 <= Reg1 ^ Reg2;							
				update_psw_logic(Reg3, instr[0]);
			end
			5'b01101: begin // xor.b
				Reg3[7:0] <= Reg1[7:0] ^ Reg2[7:0];				
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_logic(Reg3, instr[0]);
			end
			5'b01110: begin // and
				Reg3 <= Reg1 & Reg2; 							
				update_psw_logic(Reg3, instr[0]);
			end
			5'b01111: begin // and.b
				Reg3[7:0] <= Reg1[7:0] & Reg2[7:0];	    		
				Reg3[15:8] <= Reg1[15:8];		
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10000: begin // or
				Reg3 <= Reg1 | Reg2;
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10001: begin // or.b
				Reg3[7:0] <= Reg1[7:0] | Reg2[7:0];
				Reg3[15:8] <= Reg1[15:8];
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10010: begin // bit
				if(Reg2 > 15)
					Reg3 <= Reg1 & (1 << 15);	
				else
					Reg3 <= Reg1 & (1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10011: begin // bit.b
				if(Reg2 > 7)
					Reg3 <= Reg1 & (1 << 7);
				else
					Reg3 <= Reg1 & (1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10100: begin // bic
				if(Reg2 > 15)
					Reg3 <= Reg1 & ~(1 << 15);	
				else
					Reg3 <= Reg1 & ~(1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10101: begin // bic.b
				if(Reg2 > 7)
					Reg3 <= Reg1 & ~(1 << 7);
				else
					Reg3 <= Reg1 & ~(1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10110: begin // bis
				if(Reg2 > 15)
					Reg3 <= Reg1 | (1 << 15);	
				else
					Reg3 <= Reg1 | (1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b10111: begin // bis.b
				if(Reg2 > 7)
					Reg3 <= Reg1 | (1 << 7);
				else
					Reg3 <= Reg1 | (1 << Reg2);
				update_psw_logic(Reg3, instr[0]);
			end
			5'b11000: begin //sra
				Reg3 <= Reg1 >> 1;					    
				// if the prev MSB is set, new MSB is set
				if(Reg1[14])
					Reg3[15] <= 1'b1;
			end
			5'b11001: begin // sra.b
				Reg3[7:0] <= Reg1[7:0] >> 1;	   				
				if(Reg1[6])
					Reg3[7] <= 1'b1;
				Reg3[15:8] <= Reg1[15:8];		
			end
			5'b11010: begin // rrc
				PSW_o [0] <= Reg1[0];
				Reg3 <= Reg1 >> 1;
				Reg3[15] <= carry;
			end
			5'b11011: begin // rrc.b
				PSW_o[0] <= Reg1[0];
				Reg3[7:0] <= Reg1[7:0] >> 1;
				Reg3[7] <= carry;
				Reg3[15:8] <= Reg1[15:8];		
			end

		endcase
		result[15:0] <= Reg3[15:0];
	end
	
	task update_psw_logic;
		input [15:0] reg1;
		input b;

		if (b) begin
			//Negative
			PSW_o[2] <= reg1[7] & 1'b1;
			//Zero
			PSW_o[1] <= reg1[7:0] ? 1'b0 :  1'b1;
		end else begin
			//Negative
			PSW_o[2] <= reg1[15] & 1'b1;
			//Zero
			PSW_o[1] <= reg1 ? 1'b0 : 1'b1;
		end
	endtask

	/* S	D	R	C	V
	 * 0	0	0 	0	0
	 * 0	0	1	0	1
	 * 0	1	0	1	0
	 * 0 	1	1	0	0
	 * 1	0	0	1	0
	 * 1	0	1	0	0
	 * 1	1 	0	1	1	
	 * 1	1	1	1	0
	 */
	task update_psw_arithmetic;
		input [15:0] reg1, src, dst;
		input b;
			

		if (b) begin
			case(sdr_b) 
			3'b000: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b001: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 1;
			end
			3'b010: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b011: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b100: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b101: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b110: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 1;
			end
			3'b111: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			endcase	
		end else begin
			case(sdr_w) 
			3'b000: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b001: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 1;
			end
			3'b010: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b011: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b100: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			3'b101: begin
				PSW_o[0] <= 0;
				PSW_o[4] <= 0;
			end
			3'b110: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 1;
			end
			3'b111: begin
				PSW_o[0] <= 1;
				PSW_o[4] <= 0;
			end
			endcase	
		end
		update_psw_logic(reg1, b);	
	endtask

endmodule