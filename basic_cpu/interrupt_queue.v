module interrupt_queue(datain, dataout, en, rw, clk);
    input en, rw, clk;
    input  [15:0]datain; 
    output reg [15:0]dataout;

    reg [3:0]readcount1 = 0;
    reg [3:0]readcount2 = 0;
    reg [3:0]readcount3 = 0;
    reg [3:0]readcount4 = 0;
    reg [3:0]readcount5 = 0;
    reg [3:0]readcount6 = 0;
    reg [3:0]readcount7 = 0;
    reg [3:0]readcount8 = 0;

    reg [3:0]writecount1 = 0;
    reg [3:0]writecount2 = 0;
    reg [3:0]writecount3 = 0;
    reg [3:0]writecount4 = 0;
    reg [3:0]writecount5 = 0;
    reg [3:0]writecount6 = 0;
    reg [3:0]writecount7 = 0;
    reg [3:0]writecount8 = 0;

    wire [3:0] count1, count2, count3, count4, count5, count6, count7, count8;
    reg [7:0]priority_1[0:7]; //all 8 devices could be in the queue at once
    reg [7:0]priority_2[0:7];
    reg [7:0]priority_3[0:7];
    reg [7:0]priority_4[0:7];
    reg [7:0]priority_5[0:7];
    reg [7:0]priority_6[0:7];
    reg [7:0]priority_7[0:7];
    reg [7:0]priority_8[0:7];

    reg [3:0] pri;
    //count of unread items
    assign count1 = 0;
    assign count2 = 0;
    assign count3 = 0;
    assign count4 = 0;
    assign count5 = 0;
    assign count6 = 0;
    assign count7 = 0;
    assign count8 = 0;

    always @(clk) begin
        pri = datain[5:7];

        if (en == 1'b1) begin //1 for enable interrupts
            if(rw == 1'b0 ) begin//0 for read from queue
                if(count8 != 0) begin
                    dataout = priority_8[readcount8];
                    readcount8 = readcount8 + 1; //index of next device to be read
                    count8 = count8 + 1;

                end else if(count7 != 0) begin
                    dataout = priority_7[readcount7];
                    readcount7 = readcount7 + 1;
                    count7 = count7 + 1;

                end else if(count6 != 0) begin
                    dataout = priority_6[readcount6];
                    readcount6 = readcount6 + 1;
                    count6 = count6 + 1;

                end else if(count5 != 0) begin
                    dataout = priority_5[readcount5];
                    readcount5 = readcount5 + 1;
                    count4 = count4 + 1;

                end else if(count4 != 0) begin
                    dataout = priority_4[readcount4];
                    readcount4 = readcount4 + 1;
                    count4 = count4 + 1;

                end else if(count3 != 0) begin
                    dataout = priority_3[readcount3];
                    readcount3 = readcount3 + 1;
                    count3 = count3 + 1;

                end else if(count2 != 0) begin
                    dataout = priority_2[readcount2];
                    readcount2 = readcount2 + 1;
                    count2 = count2 + 1;

                end else if(count1 != 0) begin
                    dataout = priority_7[readcount1];
                    readcount1 = readcount1 + 1;
                    count1 = count1 + 1;

                end
            end else begin
                case(pri):
                    4'b0001: begin 
                        priority_1[writecount1] = datain;
                        writecount1 = writecount1 + 1; //index of next location to be written
                        count1 = count1 - 1;
                    end

                    4'b0010: begin
                        priority_2[writecount2] = datain;
                        writecount2 = writecount2 + 1; //index of next location to be written
                        count2 = count2 - 1;
                    end

                    4'b0011: begin
                        priority_3[writecount3] = datain;
                        writecount3 = writecount3 + 1; //index of next location to be written
                        count3 = count3 - 1;
                    end
                    4'b0100: begin
                        priority_4[writecount4] = datain;
                        writecount4 = writecount4 + 1; //index of next location to be written
                        count4 = count4 - 1;
                    end
                    4'b0101: begin
                        priority_5[writecount5] = datain;
                        writecount5 = writecount5 + 1; //index of next location to be written
                        count5 = count5 - 1;
                    end

                    4'b0110: begin
                        priority_6[writecount6] = datain;
                        writecount6 = writecount6 + 1; //index of next location to be written
                        count6 = count6 - 1;
                    end
                    
                    4'b0111: begin
                        priority_7[writecount7] = datain;
                        writecount7 = writecount7 + 1; //index of next location to be written
                        count7 = count7 - 1;
                    end

                    4'b1000: begin
                        priority_8[writecount8] = datain;
                        writecount8 = writecount8 + 1; //index of next location to be written
                        count8 = count8 - 1;
                    end
                
                endcase
            end
            //exhausted list, start again from low memory
            if (readcount == 8) 
                readcount = 0;
            if (writecount == 8)
                writecount = 0;
        end
    end

endmodule