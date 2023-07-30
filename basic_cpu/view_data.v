module view_data (mem_data, reg_data, psw_data, addr, update, mem_mode, HEX0, HEX1, HEX2, HEX3, LEDG, LEDR);
	input [15:0] addr;
	input [15:0] mem_data;
	input [15:0] reg_data;
	input [15:0] psw_data;
	input update;
	input [1:0] mem_mode;
	
	output reg [5:0] LEDG;
	output reg [15:0] LEDR;
	output wire [6:0] HEX0;
	output wire [6:0] HEX1;
	output wire [6:0] HEX2;
	output wire [6:0] HEX3;
	
	reg [15:0] data;
	reg [1:0] view_mode;
	
	wire [3:0] nib0, nib1, nib2, nib3;
	assign nib3 = data[15:12];
	assign nib2 = data[11:8];
	assign nib1 = data[7:4];
	assign nib0 = data[3:0];
	
	seven_seg_decoder decode1( .Reg1 (nib0), .HEX0 (HEX0), .Clock (update));
	seven_seg_decoder decode2( .Reg1 (nib1), .HEX0 (HEX1), .Clock (update));
	seven_seg_decoder decode3( .Reg1 (nib2), .HEX0 (HEX2), .Clock (update));
	seven_seg_decoder decode4( .Reg1 (nib3), .HEX0 (HEX3), .Clock (update));
	
	// Knowledge for how to use two inputs for always block from https://verilogguide.readthedocs.io/en/latest/verilog/procedure.html#always-block
	
	always @(mem_mode, update) begin
		if (mem_mode == 2'b10) 
			begin
			LEDG = 6'b000001;
			view_mode <= 2'b01;
			end
		else if (mem_mode == 2'b01) 
			begin
			LEDG = 2'b10;
			LEDR = 16'h0000;
			view_mode <= 2'b10;
			end
		if (update == 1'b0)
			begin
			if (view_mode[0] == 1'b1) 
				begin
				LEDR = addr[15:0];
				data <= mem_data[15:0];
				end
			else if (view_mode[1] == 1'b1) 
				begin
				LEDG[5:2] = addr[3:0];
				if (addr[3:0] == 4'd8)
					data <= psw_data[15:0];
				else
					data <= reg_data[15:0];
				end
			end
	end
	
endmodule