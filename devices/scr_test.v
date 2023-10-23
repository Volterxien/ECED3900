`timescale 1ps/1ps
module scr_test();

reg clk;

    wire [7:0] data_reg_kb;
    reg [7:0] data_reg_scr;
    reg [7:0] CSR_kb_i;
    reg [7:0] CSR_scr_i;

    reg [7:0] data_bus_i;
    wire [7:0] data_bus_o;

    reg [1:0] control_i;
    wire [1:0] control_o;

    wire [7:0] CSR_scr_o;
    wire [7:0] CSR_kb_o;

kb_scr_drv test(data_reg_kb, data_reg_scr, CSR_kb_i, CSR_scr_i, data_bus_i, data_bus_o, control_i, control_o, CSR_scr_o, CSR_kb_o, clk);
initial begin
    clk = 0;
forever begin
    #100clk = ~clk;
end
end

initial begin
    data_reg_scr = 8'h61;
    CSR_scr_i = 8'b00010000;
    #150control_i = 2'b01;
end


endmodule