module loader (SW, HEX0, HEX1, HEX2, HEX3);
   input [16:0] SW;
   output reg [6:0] HEX0;
	output reg [6:0] HEX1;
	output reg [6:0] HEX2;
	output reg [6:0] HEX3;
	
	// Guide for memory initialization: https://projectf.io/posts/initialize-memory-in-verilog/
	
	reg [7:0] memory [0:16'hffff];
	initial begin
		$readmemh("memory.txt", memory, 0);
		$display("Data: %h", memory[7]);
	end
	
	wire Clock;
	wire [15:0] addr;
	wire [3:0] nib0, nib1, nib2, nib3;
	assign Clock = SW[16];
	assign addr = SW[15:0];
	assign nib0 = memory[addr][3:0];
	assign nib1 = memory[addr][7:4];
	assign nib2 = memory[addr+1][3:0];
	assign nib3 = memory[addr+1][7:4];
   
   always @(posedge Clock) begin
		case (nib0)
			0: HEX0 = 7'b1000000;
			1: HEX0 = 7'b1111001;
			2: HEX0 = 7'b0100100;
			3: HEX0 = 7'b0110000;
			4: HEX0 = 7'b0011001;
			5: HEX0 = 7'b0010010;
			6: HEX0 = 7'b0000010;
			7: HEX0 = 7'b1111000;
			8: HEX0 = 7'b0000000;
			9: HEX0 = 7'b0010000;
         10: HEX0 = 7'b0001000;
         11: HEX0 = 7'b0000011;
         12: HEX0 = 7'b1000110;
         13: HEX0 = 7'b0100001;
         14: HEX0 = 7'b0000110;
         15: HEX0 = 7'b0001110;
			default HEX0 = 7'b0000000;
		endcase
	end
	always @(posedge Clock) begin
		case (nib1)
         0: HEX1 = 7'b1000000;
			1: HEX1 = 7'b1111001;
			2: HEX1 = 7'b0100100;
			3: HEX1 = 7'b0110000;
			4: HEX1 = 7'b0011001;
			5: HEX1 = 7'b0010010;
			6: HEX1 = 7'b0000010;
			7: HEX1 = 7'b1111000;
			8: HEX1 = 7'b0000000;
			9: HEX1 = 7'b0010000;
			10: HEX1 = 7'b0001000;
			11: HEX1 = 7'b0000011;
			12: HEX1 = 7'b1000110;
			13: HEX1 = 7'b0100001;
			14: HEX1 = 7'b0000110;
			15: HEX1 = 7'b0001110;
			default HEX1 = 7'b0000000;
		endcase
	end
	always @(posedge Clock) begin
		case (nib2)
         0: HEX2 = 7'b1000000;
			1: HEX2 = 7'b1111001;
			2: HEX2 = 7'b0100100;
			3: HEX2 = 7'b0110000;
			4: HEX2 = 7'b0011001;
			5: HEX2 = 7'b0010010;
			6: HEX2 = 7'b0000010;
			7: HEX2 = 7'b1111000;
			8: HEX2 = 7'b0000000;
			9: HEX2 = 7'b0010000;
         10: HEX2 = 7'b0001000;
         11: HEX2 = 7'b0000011;
         12: HEX2 = 7'b1000110;
         13: HEX2 = 7'b0100001;
         14: HEX2 = 7'b0000110;
         15: HEX2 = 7'b0001110;
         default HEX2 = 7'b0000000;
       endcase
	end
	always @(posedge Clock) begin
		case (nib3)
         0: HEX3 = 7'b1000000;
			1: HEX3 = 7'b1111001;
			2: HEX3 = 7'b0100100;
			3: HEX3 = 7'b0110000;
			4: HEX3 = 7'b0011001;
			5: HEX3 = 7'b0010010;
			6: HEX3 = 7'b0000010;
			7: HEX3 = 7'b1111000;
			8: HEX3 = 7'b0000000;
			9: HEX3 = 7'b0010000;
         10: HEX3 = 7'b0001000;
         11: HEX3 = 7'b0000011;
         12: HEX3 = 7'b1000110;
         13: HEX3 = 7'b0100001;
         14: HEX3 = 7'b0000110;
         15: HEX3 = 7'b0001110;
         default HEX3 = 7'b0000000;
       endcase
	end
endmodule
	
	