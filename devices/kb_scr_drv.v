//CSR bits: 4 - ena, 3 - of, 2 - dba, 1 - io, 0 - ie
module kb_scr_drv (
    output reg [7:0] data_reg_kb,
    input [7:0] data_reg_scr,
    input [7:0] CSR_kb_i,
    input [7:0] CSR_scr_i,

    input [7:0] data_bus_i,
    output reg [7:0] data_bus_o,

    input [1:0] control_i,
    output reg [1:0] control_o,

    output reg [7:0] CSR_scr_o,
    output reg [7:0] CSR_kb_o,


    input clk
);

  wire read_en, read_ok, write_en, write_ok;

  wire scr_en_i, scr_of_i, scr_dba_i, scr_io_i, scr_ie_i;
  reg scr_en_o, scr_of_o, scr_dba_o, scr_io_o, scr_ie_o;

  wire kb_en_i, kb_of_i, kb_dba_i, kb_io_i, kb_ie_i;
  reg kb_en_o, kb_of_o, kb_dba_o, kb_io_o, kb_ie_o;


  assign scr_en_i = CSR_scr_i[4];
  assign scr_of_i = CSR_scr_i[3];
  assign scr_dba_i = CSR_scr_i[2];
  assign scr_io_i = CSR_scr_i[1];
  assign scr_ie_i = CSR_scr_i[0];

  assign kb_en_i = CSR_kb_i[4];
  assign kb_of_i = CSR_kb_i[3];
  assign kb_dba_i = CSR_kb_i[2];
  assign kb_io_i = CSR_kb_i[1];
  assign kb_ie_i = CSR_kb_i[0];

  assign read_en = control_o[1];
  assign write_ok = control_o[0];

  assign write_en = control_i[1];
  assign read_ok = control_i[0];



  initial begin
      kb_of_o = 0;
      kb_dba_o = 0;
      scr_dba_o = 0;
      scr_of_o = 0;
  end
  always @(posedge clk ) begin
    CSR_kb_o = CSR_kb_i;
    CSR_scr_o = CSR_scr_i; 
    //write == kb
    if (kb_en_i) begin
      //pending byte
      if (write_en) begin
        data_reg_kb = data_bus_i;
        control_o[0] = 1'b1;
        if (kb_dba_i) begin
          kb_of_o = 1'b1;
        end
        else begin
          kb_dba_o = 1'b1;
        end
      end
    end
    //read == scr
    if (scr_en_i && ~scr_dba_i) begin
      if (read_ok) begin
        control_o[1] = 1'b0;
        scr_dba_o = 1'b1;
        scr_of_o = 1'b0;
      end
      else begin
        data_bus_o = data_reg_scr;
        control_o[1] =  1'b1;
      end
    end


//shift
    CSR_kb_o = CSR_kb_o | kb_dba_o << 2 | kb_of_o << 3;
    CSR_scr_o = CSR_scr_o | scr_dba_o << 2 | scr_of_o << 3;

  end
endmodule