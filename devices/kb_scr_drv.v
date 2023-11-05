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

    // output wire [7:0] CSR_scr_o,
    // output wire [7:0] CSR_kb_o,

    input clk
);

  wire read_ok, write_en;

  wire scr_en_i, scr_of_i, scr_dba_i, scr_io_i, scr_ie_i;
  reg scr_of_o, scr_dba_o;

  wire kb_en_i, kb_of_i, kb_dba_i, kb_io_i, kb_ie_i;
  reg kb_of_o, kb_dba_o;

  reg data_read = 1'b0, write_en_signal = 1'b0;

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

  assign write_en = control_i[1];
  assign read_ok = control_i[0];

  reg read_en, write_ok; //control_o[1], control[0]
  
    // assign CSR_kb_o = CSR_kb_i | kb_dba_o << 2 | kb_of_o << 3;
    // assign CSR_scr_o = (scr_of_o ? (CSR_scr_i | scr_dba_o << 2 | scr_of_o << 3) : (CSR_scr_i | scr_dba_o << 2) & ~(scr_of_o << 3));

  initial begin
    scr_of_o = 1'b0;
    scr_dba_o = 1'b1;
    kb_of_o = 1'b0;
    kb_dba_o = 1'b0;
    control_o = 2'b11;
    data_reg_kb = 8'b0;
    read_en = 1;
    write_ok = 1;

  end


  initial begin
      kb_of_o = 0;
      kb_dba_o = 0;
      scr_dba_o = 1;
      scr_of_o = 0;
  end

/*solution to issue found here: 
https://stackoverflow.com/questions/52232515/cannot-match-operands-in-the-condition-to-the-corresponding-edges-in-the-enclo
*/
  always @(posedge write_en, posedge data_read ) begin
    write_en_signal = (data_read) ? 1'b0 : 1'b1;
  end

  always @(posedge clk ) begin
    scr_of_o = scr_of_i;
    scr_dba_o = scr_dba_i;
    kb_of_o = kb_of_i;
    kb_dba_o = kb_dba_i;
    if(write_ok) begin
      control_o[0] = 1;
    end
    else begin
      control_o[0] = 0;
    end
    if(read_en) begin
      control_o[1] = 1;
    end
    else begin
      control_o[1] = 0;
    end
    // control_o =  2'b11;
    CSR_kb_o = CSR_kb_i;
    CSR_scr_o = CSR_scr_i; 

    //write == kb
    if (~write_en_signal) begin
      data_read = 1'b0;
    end

    if (kb_en_i) begin
      //pending byte
      if (write_en) begin
        data_reg_kb = data_bus_i;
        write_ok = 1'b0;
        if(write_en_signal) begin
          if (kb_dba_i) begin
            kb_of_o = 1'b1;
          end
          else begin
            kb_dba_o = 1'b1;
          end
          data_read = 1'b1;
        end
      end
      else begin
        write_ok = 1'b1;
      end
    end
    //read == scr
    if (scr_en_i && ~scr_dba_i) begin
      if (read_ok) begin
        read_en = 1'b1;
        scr_dba_o = 1'b1;
        scr_of_o = 1'b0;
      end
      else begin
        data_bus_o = ~data_reg_scr;
        read_en =  1'b0;
      end
    end


    CSR_kb_o = CSR_kb_i | kb_dba_o << 2 | kb_of_o << 3;
    CSR_scr_o[3] = scr_of_o;
    CSR_scr_o[2] = scr_dba_o;
    // (scr_of_o ? (CSR_scr_i | scr_dba_o << 2 | scr_of_o << 3) : (CSR_scr_i | scr_dba_o << 2) & ~(scr_of_o << 3));
    

  end
endmodule