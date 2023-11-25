/* 
 * The interrupt vector entry routine module for the XM-23 CPU
 * Author:		Mark McCoy, Jacques Bosse, Tori Ebanks
 * Date:		November 25, 2023	
 * File Name: 	int_vect_entry.v
 * Module: 		int_vect_entry
 * Description: Pushes required data to the stack and pulls data from entry in IVT corresponding to the interrupt, trap, or fault called.
 * Acknowledgements:
 */
module interrupt_controller(in, deviceoutput, read, psw1, psw2, psw3, 
									psw4, psw5, psw6, psw7, psw8, out_ack, pi, dev_pri);
input read;
input [7:0]in;
input [15:0] psw1, psw2, psw3, psw4, psw5, psw6, psw7, psw8;
output [7:0]deviceoutput;
output [7:0]out_ack;
output pi;
output [2:0]dev_pri;

reg [7:0] out;
reg [2:0] queue_id;
reg [7:0] devicein[0:7];
reg service_list[0:7];
reg [7:0] toqueue;
wire [7:0] deviceout[0:7];
reg wr[0:7];
wire empty[0:7], full[0:7];
wire [2:0]count [0:7];
reg write_ack[0:7];
reg [2:0] prev_count[0:7];
reg r_req;
wire [2:0] pri[0:7];
integer temp_count;
integer i;
reg [7:0]interrupt_pending[0:7];
reg [7:0]ack;
reg [2:0] pri_out;
reg pending;

//last byte of device address
parameter d1 = 8'h02, d2 = 8'h06, d3 = 8'h0A, d4 = 8'hE, d5 = 8'h12, d6 = 8'h16, d7 = 8'h1A, d8 =  8'h1E; 

assign pri[0] = psw1[7:5];
assign pri[1] = psw2[7:5];
assign pri[2] = psw3[7:5];
assign pri[3] = psw4[7:5];
assign pri[4] = psw5[7:5];
assign pri[5] = psw6[7:5];
assign pri[6] = psw7[7:5];
assign pri[7] = psw8[7:5];

//attach ack bits for device request acknowledgement



assign deviceoutput = out;
assign dev_pri = pri_out;
assign pi = pending;



assign out_ack = ack;

initial begin
	interrupt_pending[0] = 8'h00;
	interrupt_pending[1] = 8'h00;
	interrupt_pending[2] = 8'h00;
	interrupt_pending[3] = 8'h00;
	interrupt_pending[4] = 8'h00;
	interrupt_pending[5] = 8'h00;
	interrupt_pending[6] = 8'h00;
	interrupt_pending[7] = 8'h00;
	ack = 8'h00;
end

always @* begin
	if(interrupt_pending[0] | interrupt_pending[1] | interrupt_pending[2] | interrupt_pending[3] | interrupt_pending[4] | interrupt_pending[5] | interrupt_pending[6] | interrupt_pending[7]) 
	begin pending = 1'b1;
	end  else pending = 1'b0;
	if(in[0] & !ack[0] & !interrupt_pending[pri[0]]) begin
		interrupt_pending[pri[0]] = d1;
		ack = 8'b00000001;
		pending = 1'b1;
	end
	
	if(in[1] & !ack[1] & !interrupt_pending[pri[1]]) begin
		interrupt_pending[pri[1]] = d2;
		ack = 8'b00000010;
		pending = 1'b1;
	end
	
	if(in[2] & !ack[2] & !interrupt_pending[pri[2]]) begin
		interrupt_pending[pri[2]] = d3;
		ack = 8'b00000100;
		pending = 1'b1;
	end
	
	if(in[3] & !ack[3] & !interrupt_pending[pri[3]]) begin
		interrupt_pending[pri[3]] = d4;
		ack = ack || 8'b00001000;
		pending = 1'b1;
	end
	
	if(in[4] & !ack[4] & !interrupt_pending[pri[4]]) begin
		interrupt_pending[pri[4]] = d5;
		ack = ack || 8'b00010000;
		pending = 1'b1;
	end
	
	if(in[5] & !ack[5] & !interrupt_pending[pri[5]]) begin
		interrupt_pending[pri[5]] = d6;
		ack = ack || 8'b00100000;
		pending = 1'b1;
	end
	
	if(in[6] & !ack[6] & !interrupt_pending[pri[6]]) begin
		interrupt_pending[pri[6]] = d7;
		ack = ack || 8'b01000000;
		pending = 1'b1;
	end
	
	if(in[7] & !ack[7] & !interrupt_pending[pri[7]]) begin
		interrupt_pending[pri[7]] = d8;
		ack = ack || 8'b10000000;
		pending = 1'b1;
	end
	
	if(read) begin
		if(interrupt_pending[7]) begin
			out = interrupt_pending[7];
			pri_out = 3'h7;
			interrupt_pending[7] = 8'h00;
			end
		else if(interrupt_pending[6]) begin
			out = interrupt_pending[6];
			pri_out = 3'h6;
			interrupt_pending[6] = 8'h00;
			end
		else if(interrupt_pending[5]) begin
			out = interrupt_pending[5];
			pri_out = 3'h5;
			interrupt_pending[5] = 8'h00;
			end
		else if(interrupt_pending[4]) begin
			out = interrupt_pending[4];
			pri_out = 3'h4;
			end
		else if(interrupt_pending[3]) begin
			out = interrupt_pending[3];
			pri_out = 3'h3;
			interrupt_pending[3] = 8'h00;
			end
		else if(interrupt_pending[2]) begin
			out = interrupt_pending[2];
			pri_out = 3'h2;
			interrupt_pending[2] = 8'h00;
			end
		else if(interrupt_pending[1]) begin
			out = interrupt_pending[1];
			pri_out = 3'h1;
			interrupt_pending[1] = 8'h00;
			end
		else if(interrupt_pending[0]) begin
			out = interrupt_pending[0];
			pri_out = 3'h0;
			interrupt_pending[0] = 8'h00;
			end
	end
	
end


endmodule