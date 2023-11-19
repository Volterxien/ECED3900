module interrupt_controller(clk, in1, in2, in3, in4, in5, in6, in7, 
									in8, deviceoutput, read, psw1, psw2, psw3, 
									psw4, psw5, psw6, psw7, psw8, ack1, ack2, 
									ack3, ack4, ack5, ack6, ack7, ack8);
input clk, read;
input in1, in2, in3, in4, in5, in6, in7, in8;
input [15:0] psw1, psw2, psw3, psw4, psw5, psw6, psw7, psw8;
output [7:0]deviceoutput;
output ack1, ack2, ack3, ack4, ack5, ack6, ack7, ack8;

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
assign ack1 = write_ack[0];
assign ack2 = write_ack[1];
assign ack3 = write_ack[2];
assign ack4 = write_ack[3];
assign ack5 = write_ack[4];
assign ack6 = write_ack[5];
assign ack7 = write_ack[6];
assign ack8 = write_ack[7];


assign deviceoutput = out;

// implement individual fifo modules for priority queues
newfifo u1(.clock(clk), .data(devicein[0]), .q(deviceout[0]), .rdreq(pi[0]), .wrreq(wr[0]), .usedw(count[0]), .empty(empty[0]), .full(full[0]));
newfifo u2(.clock(clk), .data(devicein[1]), .q(deviceout[1]), .rdreq(pi[1]), .wrreq(wr[1]), .usedw(count[1]), .empty(empty[1]), .full(full[1]));
newfifo u3(.clock(clk), .data(devicein[2]), .q(deviceout[2]), .rdreq(pi[2]), .wrreq(wr[2]), .usedw(count[2]), .empty(empty[2]), .full(full[2]));
newfifo u4(.clock(clk), .data(devicein[3]), .q(deviceout[3]), .rdreq(pi[3]), .wrreq(wr[3]), .usedw(count[3]), .empty(empty[3]), .full(full[3]));
newfifo u5(.clock(clk), .data(devicein[4]), .q(deviceout[4]), .rdreq(pi[4]), .wrreq(wr[4]), .usedw(count[4]), .empty(empty[4]), .full(full[4]));
newfifo u6(.clock(clk), .data(devicein[5]), .q(deviceout[5]), .rdreq(pi[5]), .wrreq(wr[5]), .usedw(count[5]), .empty(empty[5]), .full(full[5]));
newfifo u7(.clock(clk), .data(devicein[6]), .q(deviceout[6]), .rdreq(pi[6]), .wrreq(wr[6]), .usedw(count[6]), .empty(empty[6]), .full(full[6]));
newfifo u8(.clock(clk), .data(devicein[7]), .q(deviceout[7]), .rdreq(pi[7]), .wrreq(wr[7]), .usedw(count[7]), .empty(empty[7]), .full(full[7]));
always @(posedge clk) begin
	/*prev_count[0] = count[0];
	prev_count[1] = count[1];
	prev_count[2] = count[2];
	prev_count[3] = count[3];
	prev_count[4] = count[4];
	prev_count[5] = count[5];
	prev_count[6] = count[6];
	prev_count[7] = count[7];*/
	
    if(read) begin
        //start read from priority queues
        wr[0] = 0; wr[1] = 0; wr[2] = 0; wr[3] = 0; wr[4] = 0; wr[5] = 0; wr[6] = 0; wr[7] = 0;

        //read from first buffer that is not empty from highest priority to lowest priority
        if(!empty[7]) begin
            //signal read bit of  queue to read from
            pi[7] = 1; 
				pi[6] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[6])begin
            pi[6] = 1;
				pi[7] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[5])begin
            pi[5] = 1;
				pi[7] = 0; 
				pi[6] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[4])begin
            pi[4] = 1;
            pi[7] = 0; 
				pi[6] = 0;
				pi[5] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[3])begin
            pi[3] = 1;
				pi[7] = 0; 
				pi[6] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[2] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[2])begin
            pi[2] = 1;
				pi[7] = 0; 
				pi[6] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[1] = 0;
				pi[0] = 0;
        end else if (!empty[1])begin
            pi[1] = 1;
            pi[7] = 0; 
				pi[6] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[0] = 0;
        end else if (!empty[0])begin
            pi[0] = 1;
            pi[7] = 0; 
				pi[6] = 0;
				pi[5] = 0;
				pi[4] = 0;
				pi[3] = 0;
				pi[2] = 0;
				pi[1] = 0;
				if(prev_count[0] > count[0]) pi[0] = 0;
        end
		  
    end else begin
        //start write operation

	 pi[0] = 0; pi[1] = 0; pi[2] = 0; pi[3] = 0; pi[4] = 0; pi[5] = 0; pi[6] = 0; pi[7] = 0;
        if(in1) begin
            toqueue = d1; //assign data of queue to be written to as device address
            write_ack[0] = 1; //send ack to device that request has been receied
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[0]; //signal which priority queue to write to based on devce priority
        end
        if(in2) begin 
            toqueue = d2;
            write_ack[1] = 1;
				write_ack[0] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[1];
        end
        if(in3) begin 
            toqueue = d3;
            write_ack[2] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[2];
        end
        else if(in4) begin
            toqueue = d4;
            write_ack[3] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[3];
        end
        if(in5) begin
            toqueue = d5;
            write_ack[4] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[4];
        end
        else if(in6) begin
            toqueue = d6;
            write_ack[5] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[6] = 0;
				write_ack[7] = 0;
            queue_id = pri[5];
        end
        if(in7) begin
            toqueue = d7;
            write_ack[6] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[7] = 0;
            queue_id = pri[6];
        end
        if(in8) begin
            toqueue = d8;
            write_ack[7] = 1;
				write_ack[0] = 0;
				write_ack[1] = 0;
				write_ack[2] = 0;
				write_ack[3] = 0;
				write_ack[4] = 0;
				write_ack[5] = 0;
				write_ack[6] = 0;
            queue_id = pri[7];
        end
        wr[queue_id] = 1;               
        devicein[queue_id] = toqueue;
    end
	
        //clear ack bits of every device except one most recently acknowledged
		if(ack1 == 1) begin 
			wr[pri[0]] = 0;
			write_ack[1] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack2 == 1) begin
			wr[pri[1]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack3 == 1) begin
			wr[pri[2]] = 0;
			write_ack[0] = 0;
			write_ack[1] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack4 == 1) begin
			wr[pri[3]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[1] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack5 == 1) begin
			wr[pri[4]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[1] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack6 == 1) begin
			wr[pri[1]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[1] = 0;
			write_ack[6] = 0;
			write_ack[7] = 0;
		end
		if(ack7 == 1) begin
			wr[pri[5]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[1] = 0;
			write_ack[7] = 0;
		end
		if(ack8 == 1) begin
			wr[pri[6]] = 0;
			write_ack[0] = 0;
			write_ack[2] = 0;
			write_ack[3] = 0;
			write_ack[4] = 0;
			write_ack[5] = 0;
			write_ack[6] = 0;
			write_ack[1] = 0;
		end
		
		//output devices read from priority buffer in order of highst priority to lowest
		if(deviceout[7]) begin
			temp_count = count[7];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[7];
		end
		if(deviceout[6]) begin
			temp_count = count[6];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[6];
		end
		if(deviceout[5]) begin
			temp_count = count[5];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[5];
		end
		if(deviceout[4]) begin
			temp_count = count[4];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[4];
		end
		if(deviceout[3]) begin
			temp_count = count[3];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[3];
		end
		if(deviceout[2]) begin
			temp_count = count[2];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[2];
		end
		if(deviceout[1]) begin
			temp_count = count[1];
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[1];
		end
		if(deviceout[0]) begin
			temp_count = count[0];
			/*if(temp_count != 0) begin
				out = devicout[0];
				temp_count = temp_count - 1;*/
			for(i = 0; i <= temp_count; i = i+1)
				out =  deviceout[0];
		end
		
		
end


endmodule