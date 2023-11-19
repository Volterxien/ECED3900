module interrupt_controller(clk, deviceinput, deviceoutput, pri, read);
input clk, read;
input [2:0]pri;
input [7:0]deviceinput;
output [7:0]deviceoutput;
reg [7:0] out;

reg [7:0]devicein [0:7];
wire [7:0]deviceout[0:7];
reg wr[0:7], pi[0:7];
wire empty[0:7], full[0:7];
wire [2:0]count [0:7];

assign deviceoutput = out;
//Clears read bit so only one item is read
always @(deviceout[0]) begin
    pi[0] = 0; out = deviceout[0];
end
always @(deviceout[1]) begin
    pi[1] = 0; out = deviceout[1];
end
always @(deviceout[2]) begin
    pi[2] = 0; out = deviceout[2];
end
always @(deviceout[3]) begin
    pi[3] = 0; out = deviceout[3];
end
always @(deviceout[4]) begin
    pi[4] = 0; out = deviceout[4];
end
always @(deviceout[5]) begin 
    pi[5] = 0; out = deviceout[5];
end
always @(deviceout[6]) begin
    pi[6] = 0; out = deviceout[6];
end
always @(deviceout[7]) begin
    pi[7] = 0; out = deviceout[7];
end

always @(count[0]) wr[0] = 0;
always @(count[1]) wr[1] = 0;
always @(count[2]) wr[2] = 0;
always @(count[3]) wr[3] = 0;
always @(count[4]) wr[4] = 0;
always @(count[5]) wr[5] = 0;
always @(count[6]) wr[6] = 0;
always @(count[7]) wr[7] = 0;

newfifo u1(.clock(clk), .data(devicein[0]), .q(deviceout[0]), .rdreq(pi[0]), .wrreq(wr[0]), .usedw(count[0]), .empty(empty[0]), .full(full[0]));
newfifo u2(.clock(clk), .data(devicein[1]), .q(deviceout[1]), .rdreq(pi[1]), .wrreq(wr[1]), .usedw(count[1]), .empty(empty[1]), .full(full[1]));
newfifo u3(.clock(clk), .data(devicein[2]), .q(deviceout[2]), .rdreq(pi[2]), .wrreq(wr[2]), .usedw(count[2]), .empty(empty[2]), .full(full[2]));
newfifo u4(.clock(clk), .data(devicein[3]), .q(deviceout[3]), .rdreq(pi[3]), .wrreq(wr[3]), .usedw(count[3]), .empty(empty[3]), .full(full[3]));
newfifo u5(.clock(clk), .data(devicein[4]), .q(deviceout[4]), .rdreq(pi[4]), .wrreq(wr[4]), .usedw(count[4]), .empty(empty[4]), .full(full[4]));
newfifo u6(.clock(clk), .data(devicein[5]), .q(deviceout[5]), .rdreq(pi[5]), .wrreq(wr[5]), .usedw(count[5]), .empty(empty[5]), .full(full[5]));
newfifo u7(.clock(clk), .data(devicein[6]), .q(deviceout[6]), .rdreq(pi[6]), .wrreq(wr[6]), .usedw(count[6]), .empty(empty[6]), .full(full[6]));
newfifo u8(.clock(clk), .data(devicein[7]), .q(deviceout[7]), .rdreq(pi[7]), .wrreq(wr[7]), .usedw(count[7]), .empty(empty[7]), .full(full[7]));
always @(posedge clk) begin
    if(read) begin
        wr[0] = 0; wr[1] = 0; wr[2] = 0; wr[3] = 0; wr[4] = 0; wr[5] = 0; wr[6] = 0; wr[7] = 0;
        if(!empty[7]) begin
            pi[7] = 1;
        end else if (!empty[6])begin
            pi[6] = 1;
        end else if (!empty[5])begin
            pi[5] = 1;
        end else if (!empty[4])begin
            pi[4] = 1;
            
        end else if (!empty[3])begin
            pi[3] = 1;
            out <= deviceout[3];
        end else if (!empty[2])begin
            pi[2] = 1;
            out <= deviceout[2];
        end else if (!empty[1])begin
            pi[1] = 1;
            
        end else if (!empty[5])begin
            pi[0] = 1;
            
        end
    end else begin
        //set write enable for queue and clear read enable for all queues
        wr[pri] = 1;               
        devicein[pri] = deviceinput;
    end
end


endmodule