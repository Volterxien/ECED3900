module interrupt_controller(cpu_pri, psw_out, pc, lr, cex_state, interrupt_device, inter, clock, psw_in);
    input [4:0] cpu_pri;
    input clock;
    input [15:0]psw_in;
    output reg [15:0] psw_out;
    output reg [15:0] pc;
    output reg [15:0] lr;
    output reg [7:0] cex_state;
    output reg [15:0] interrupt_device;
    reg [15:0] device_reg;
    reg [15:0]vectors[7:0]; //device vectors
    wire rw;
    output inter; // 0 = no interrupt, pop state 1 = interrupt enabled, push state
    reg [4:0] device_pri;
    reg [15:0]devices[7:0]; //device ports
    reg i, read_write, interrupt;
    
    initial begin
        devices[0] = 16'h0000;
        devices[1] = 16'h0002;
        devices[2] = 16'h0004;
        devices[3] = 16'h0006;
        devices[4] = 16'h0008;
        devices[5] = 16'h000A;
        devices[6] = 16'h000C;
        devices[7] = 16'h000E;

        vectors[0] = 16'hFFC0;
        vectors[1] = 16'hFFC4;
        vectors[2] = 16'hFFC8;
        vectors[3] = 16'hFFCC;
        vectors[4] = 16'hFFF0;
        vectors[5] = 16'hFFF4;
        vectors[6] = 16'hFFF8;
        vectors[7] = 16'hFFFC;
        read_write = 1'b0;
        interrupt = 1'b0;
        device_pri = 4'b0000;
    end

    always @(clock) begin 
        for(i=0; i<8; i=i+1) begin
            read_write = 1'b0;
            // memory(.memoryaddress(device[i]]), .rw(rw), .datain(device_reg)) //read psw from memory location of device i 
            //this will need to be modified

            
            //Move to new section
            if (psw_in[4] == 1'b1 && (cpu_pri < device_pri)) begin
                //signal cpu to push current state to stack
                interrupt = 1'b1; 
                
                //signal cpu to addopt new state
                pc = vectors[i];
                lr = 16'hFFFF;
                cex_state = 4'b0000;
                interrupt_device <= vectors[i]; 

                //after service, clear enable
                device_reg = device_reg & 8'b00010000;
                interrupt = 1'b0;       //pull cpu state from stack
            end
        end
    end

    assign rw = read_write;
    assign inter = interrupt;

endmodule

