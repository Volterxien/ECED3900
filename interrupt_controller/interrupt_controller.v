module interrupt_controller(in, deviceoutput, read, psw1, psw2, psw3, 
									psw4, psw5, psw6, psw7, psw8, out_ack);
input read;
input [7:0]in;
input [15:0] psw1, psw2, psw3, psw4, psw5, psw6, psw7, psw8;
output [7:0]deviceoutput;
output [7:0]out_ack;

reg [7:0] out;
reg [2:0] queue_id;
reg [7:0] devicein[0:7];
reg service_list[0:7];
reg [7:0] toqueue;
wire [7:0] deviceout[0:7];
reg wr[0:7], pi[0:7];
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

//last byte of device address
parameter d1 = 8'hC2, d2 = 8'hC6, d3 = 8'hCA, d4 = 8'hCE, d5 = 8'hD2, d6 = 8'hD6, d7 = 8'hEE, d8 =  8'hF2; 

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
	if(in[0] & !ack[0] & !interrupt_pending[pri[0]]) begin
		interrupt_pending[pri[0]] = d1;
		ack = 8'b00000001;
	end
	
	if(in[1] & !ack[1] & !interrupt_pending[pri[1]]) begin
		interrupt_pending[pri[1]] = d2;
		ack = 8'b00000010;
	end
	
	if(in[2] & !ack[2] & !interrupt_pending[pri[2]]) begin
		interrupt_pending[pri[2]] = d3;
		ack = 8'b00000100;
	end
	
	if(in[3] & !ack[3] & !interrupt_pending[pri[3]]) begin
		interrupt_pending[pri[3]] = d4;
		ack = ack || 8'b00001000;
	end
	
	if(in[4] & !ack[4] & !interrupt_pending[pri[4]]) begin
		interrupt_pending[pri[4]] = d5;
		ack = ack || 8'b00010000;
	end
	
	if(in[5] & !ack[5] & !interrupt_pending[pri[5]]) begin
		interrupt_pending[pri[5]] = d6;
		ack = ack || 8'b00100000;
	end
	
	if(in[6] & !ack[6] & !interrupt_pending[pri[6]]) begin
		interrupt_pending[pri[6]] = d7;
		ack = ack || 8'b01000000;
	end
	
	if(in[7] & !ack[7] & !interrupt_pending[pri[7]]) begin
		interrupt_pending[pri[7]] = d8;
		ack = ack || 8'b10000000;
	end
	
	if(read) begin
		if(interrupt_pending[7]) begin
			out = interrupt_pending[7];
			interrupt_pending[7] = 8'h00;
			end
		else if(interrupt_pending[6]) begin
			out = interrupt_pending[6];
			interrupt_pending[6] = 8'h00;
			end
		else if(interrupt_pending[5]) begin
			out = interrupt_pending[5];
			interrupt_pending[5] = 8'h00;
			end
		else if(interrupt_pending[4]) 
			out = interrupt_pending[4];
		else if(interrupt_pending[3]) begin
			out = interrupt_pending[3];
			interrupt_pending[3] = 8'h00;
			end
		else if(interrupt_pending[2]) begin
			out = interrupt_pending[2];
			interrupt_pending[2] = 8'h00;
			end
		else if(interrupt_pending[1]) begin
			out = interrupt_pending[1];
			interrupt_pending[1] = 8'h00;
			end
		else if(interrupt_pending[0]) begin
			out = interrupt_pending[0];
			interrupt_pending[0] = 8'h00;
			end
	end
	
end

endmodule