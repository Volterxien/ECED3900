module interrupt_controller(cpu_pri, device_reg, psw_out, pc, lr, cex_state, devices, interrupt_device, inter);
    input [15:0] device_reg;
    input [4:0] cpu_pri;
    input wire [15:0] devices[7:0]; //device ports
    output reg [15:0] psw_out;
    output reg [15:0] pc;
    output reg [15:0] lr;
    output reg [7:0] cex_state;
    output reg [15:0] interrupt_device;
    reg [15:0]vectors[7:0]; //device vectors
    output wire rw;
    output wire inter; // 0 = no interrupt 1 = interrupt enabled, push state
    reg [4:0] device_pri;
    
    initial begin
        device[0] = 16'h0000;
        device[1] = 16'h0002;
        device[2] = 16'h0004;
        device[3] = 16'h0006;
        device[4] = 16'h0008;
        device[5] = 16'h000A;
        device[6] = 16'h000C;
        device[7] = 16'h000E;

        vectors[0] = 16'hFFC0;
        vectors[1] = 16'hFFC4;
        vectors[2] = 16'hFFC8;
        vectors[3] = 16'hFFCC;
        vectors[4] = 16'hFFF0;
        vectors[5] = 16'hFFF4;
        vectors[6] = 16'hFFF8;
        vectors[7] = 16'hFFFC;
        rw = 1'b0;
        inter = 1'b0;
        device_pri = 4'b0000;
    end

    always @(clock) begin 
        for(i=0; i<8; i=i+1) begin
            assign rw = 1'b0;
            memory(.memoryaddress(device[i]]), .rw(rw), .datain(device_reg)) //read psw from memory location of device i
            if ([4]psw_in == 1'b1 && cpu_pri < device_pri) begin
                //signal cpu to push current state to stack
                inter = 1'b1; 
                
                //signal cpu to addopt new state
                pc = vector[i];
                lr = 16'hFFFF;
                cex_state = 0'h0000;
                interrupt_device <= vector[i]; 

                //after service, clear enable
                device_reg = device_reg & 0'b00010000;
                inter = 1'b0;       //pull cpu state from stack
            end
        end
    end
endmodule