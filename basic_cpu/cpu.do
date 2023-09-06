onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Inputs -label SW -radix hexadecimal -childformat {{{/xm23_cpu/SW[17]} -radix hexadecimal} {{/xm23_cpu/SW[16]} -radix hexadecimal} {{/xm23_cpu/SW[15]} -radix hexadecimal} {{/xm23_cpu/SW[14]} -radix hexadecimal} {{/xm23_cpu/SW[13]} -radix hexadecimal} {{/xm23_cpu/SW[12]} -radix hexadecimal} {{/xm23_cpu/SW[11]} -radix hexadecimal} {{/xm23_cpu/SW[10]} -radix hexadecimal} {{/xm23_cpu/SW[9]} -radix hexadecimal} {{/xm23_cpu/SW[8]} -radix hexadecimal} {{/xm23_cpu/SW[7]} -radix hexadecimal} {{/xm23_cpu/SW[6]} -radix hexadecimal} {{/xm23_cpu/SW[5]} -radix hexadecimal} {{/xm23_cpu/SW[4]} -radix hexadecimal} {{/xm23_cpu/SW[3]} -radix hexadecimal} {{/xm23_cpu/SW[2]} -radix hexadecimal} {{/xm23_cpu/SW[1]} -radix hexadecimal} {{/xm23_cpu/SW[0]} -radix hexadecimal}} -expand -subitemconfig {{/xm23_cpu/SW[17]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[16]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[15]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[14]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[13]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[12]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[11]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[10]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[9]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[8]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[7]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[6]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[5]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[4]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[3]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[2]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[1]} {-height 15 -radix hexadecimal} {/xm23_cpu/SW[0]} {-height 15 -radix hexadecimal}} /xm23_cpu/SW
add wave -noupdate -expand -group Inputs -label KEY -expand /xm23_cpu/KEY
add wave -noupdate -expand -group Inputs -label GPIO_EXT_CLK /xm23_cpu/GPIO
add wave -noupdate -expand -group Inputs -label CLOCK_50MHz /xm23_cpu/CLOCK_50
add wave -noupdate -expand -group {Important Regs} -label Reg_File -radix hexadecimal -childformat {{{/xm23_cpu/reg_file[0]} -radix hexadecimal} {{/xm23_cpu/reg_file[1]} -radix hexadecimal} {{/xm23_cpu/reg_file[2]} -radix hexadecimal} {{/xm23_cpu/reg_file[3]} -radix hexadecimal} {{/xm23_cpu/reg_file[4]} -radix hexadecimal} {{/xm23_cpu/reg_file[5]} -radix hexadecimal} {{/xm23_cpu/reg_file[6]} -radix hexadecimal} {{/xm23_cpu/reg_file[7]} -radix hexadecimal -childformat {{{/xm23_cpu/reg_file[7][15]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][14]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][13]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][12]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][11]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][10]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][9]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][8]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][7]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][6]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][5]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][4]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][3]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][2]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][1]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][0]} -radix hexadecimal}}} {{/xm23_cpu/reg_file[8]} -radix hexadecimal} {{/xm23_cpu/reg_file[9]} -radix hexadecimal} {{/xm23_cpu/reg_file[10]} -radix hexadecimal} {{/xm23_cpu/reg_file[11]} -radix hexadecimal} {{/xm23_cpu/reg_file[12]} -radix hexadecimal} {{/xm23_cpu/reg_file[13]} -radix hexadecimal} {{/xm23_cpu/reg_file[14]} -radix hexadecimal} {{/xm23_cpu/reg_file[15]} -radix hexadecimal} {{/xm23_cpu/reg_file[16]} -radix hexadecimal}} -expand -subitemconfig {{/xm23_cpu/reg_file[0]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[1]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[2]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[3]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[4]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[5]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[6]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7]} {-height 15 -radix hexadecimal -childformat {{{/xm23_cpu/reg_file[7][15]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][14]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][13]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][12]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][11]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][10]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][9]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][8]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][7]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][6]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][5]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][4]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][3]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][2]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][1]} -radix hexadecimal} {{/xm23_cpu/reg_file[7][0]} -radix hexadecimal}}} {/xm23_cpu/reg_file[7][15]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][14]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][13]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][12]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][11]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][10]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][9]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][8]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][7]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][6]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][5]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][4]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][3]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][2]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][1]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[7][0]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[8]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[9]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[10]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[11]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[12]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[13]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[14]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[15]} {-height 15 -radix hexadecimal} {/xm23_cpu/reg_file[16]} {-height 15 -radix hexadecimal}} /xm23_cpu/reg_file
add wave -noupdate -expand -group {Important Regs} -label Instr_Reg -radix hexadecimal /xm23_cpu/instr_reg
add wave -noupdate -expand -group {Important Regs} -label MAR -radix hexadecimal /xm23_cpu/mar
add wave -noupdate -expand -group {Important Regs} -label MDR -radix hexadecimal /xm23_cpu/mdr
add wave -noupdate -expand -group {Important Regs} -label BKPNT -radix hexadecimal /xm23_cpu/bkpnt
add wave -noupdate -expand -group {Important Regs} -label PSW -radix hexadecimal /xm23_cpu/psw_data
add wave -noupdate -expand -group {Control Signals} -label CPU_Cycle /xm23_cpu/ctrl_unit/cpucycle
add wave -noupdate -expand -group {Control Signals} -label Ctrl_Reg /xm23_cpu/ctrl_reg
add wave -noupdate -expand -group {Control Signals} -label Data_Bus_Ctrl /xm23_cpu/data_bus_ctrl
add wave -noupdate -expand -group {Control Signals} -label Addr_Bus_Ctrl /xm23_cpu/addr_bus_ctrl
add wave -noupdate -expand -group {Control Signals} -label S_Bus_Ctrl /xm23_cpu/s_bus_ctrl
add wave -noupdate -expand -group {Control Signals} -label Sxt_Bus_Ctrl /xm23_cpu/sxt_bus_ctrl
add wave -noupdate -expand -group {Control Signals} -label PSW_Bus_Ctrl /xm23_cpu/psw_bus_ctrl
add wave -noupdate -expand -group {Control Signals} -label ALU_OP /xm23_cpu/alu_op
add wave -noupdate -expand -group {Control Signals} -label BM_OP /xm23_cpu/bm_op
add wave -noupdate -expand -group {Control Signals} -label ID_E /xm23_cpu/id_E
add wave -noupdate -expand -group {Control Signals} -label PSW_Update /xm23_cpu/psw_update
add wave -noupdate -expand -group {Control Signals} -label Code /xm23_cpu/ctrl_unit/code
add wave -noupdate -expand -group {Control Signals} -label {Code Result} /xm23_cpu/ctrl_unit/code_result
add wave -noupdate -expand -group {Control Signals} -label BKPNT_Set /xm23_cpu/ctrl_unit/brkpnt_set
add wave -noupdate -expand -group {Control Signals} -label CEX_State /xm23_cpu/ctrl_unit/cex_state
add wave -noupdate -expand -group {Control Signals} -label Int_Sum -radix hexadecimal /xm23_cpu/arithmetic_logic_unit/sum1
add wave -noupdate -expand -group {Control Signals} -label SDR_B /xm23_cpu/arithmetic_logic_unit/sdr_b
add wave -noupdate -expand -group {Control Signals} -label SDR_W /xm23_cpu/arithmetic_logic_unit/sdr_w
add wave -noupdate -expand -group Indices -label dbus_rnum_dst -radix decimal /xm23_cpu/dbus_rnum_dst
add wave -noupdate -expand -group Indices -label dbus_rnum_src -radix decimal /xm23_cpu/dbus_rnum_src
add wave -noupdate -expand -group Indices -label addr_rnum_src -radix decimal /xm23_cpu/addr_rnum_src
add wave -noupdate -expand -group Indices -label alu_rnum_dst -radix decimal /xm23_cpu/alu_rnum_dst
add wave -noupdate -expand -group Indices -label alu_rnum_src -radix decimal /xm23_cpu/alu_rnum_src
add wave -noupdate -expand -group Indices -label bm_rnum /xm23_cpu/bm_rnum
add wave -noupdate -expand -group Indices -label sxt_rnum /xm23_cpu/sxt_rnum
add wave -noupdate -expand -group Indices -label sxt_bit_num /xm23_cpu/sxt_bit_num
add wave -noupdate -expand -group Buses -label S_Bus -radix hexadecimal /xm23_cpu/s_bus
add wave -noupdate -expand -group Buses -label D_Bus -radix hexadecimal /xm23_cpu/d_bus
add wave -noupdate -expand -group Buses -label CR_Bus /xm23_cpu/CR_bus
add wave -noupdate -expand -group ID_Outputs -label OP -radix decimal /xm23_cpu/OP
add wave -noupdate -expand -group ID_Outputs -label OFF /xm23_cpu/OFF
add wave -noupdate -expand -group ID_Outputs -label CCCC /xm23_cpu/C
add wave -noupdate -expand -group ID_Outputs -label TTT /xm23_cpu/T
add wave -noupdate -expand -group ID_Outputs -label FFF /xm23_cpu/F
add wave -noupdate -expand -group ID_Outputs -label PR /xm23_cpu/PR
add wave -noupdate -expand -group ID_Outputs -label SA /xm23_cpu/SA
add wave -noupdate -expand -group ID_Outputs -label PSWb /xm23_cpu/PSWb
add wave -noupdate -expand -group ID_Outputs -label DST /xm23_cpu/DST
add wave -noupdate -expand -group ID_Outputs -label SRCCON /xm23_cpu/SRCCON
add wave -noupdate -expand -group ID_Outputs -label WB /xm23_cpu/WB
add wave -noupdate -expand -group ID_Outputs -label RC /xm23_cpu/RC
add wave -noupdate -expand -group ID_Outputs -label ImByte -radix hexadecimal /xm23_cpu/ImByte
add wave -noupdate -expand -group ID_Outputs -label PRPO /xm23_cpu/PRPO
add wave -noupdate -expand -group ID_Outputs -label DEC /xm23_cpu/DEC
add wave -noupdate -expand -group ID_Outputs -label INC /xm23_cpu/INC
add wave -noupdate -expand -group ID_Outputs -label FLTo /xm23_cpu/ID_FLTo
add wave -noupdate -group {Block I/O} -label BM_Out -radix hexadecimal /xm23_cpu/bm_out
add wave -noupdate -group {Block I/O} -label SXT_Out -radix hexadecimal /xm23_cpu/sxt_out
add wave -noupdate -group {Block I/O} -label ALU_PSW_Out -radix hexadecimal /xm23_cpu/alu_psw_out
add wave -noupdate -group {Block I/O} -label BM_In -radix hexadecimal /xm23_cpu/bm_in
add wave -noupdate -group {Block I/O} -label SXT_In -radix hexadecimal /xm23_cpu/sxt_in
add wave -noupdate -group {Block I/O} -label PSW_In -radix hexadecimal /xm23_cpu/psw_in
add wave -noupdate -group {Block I/O} -label ALU_Out -radix hexadecimal /xm23_cpu/alu_out
add wave -noupdate -group Outputs -label LEDG /xm23_cpu/LEDG
add wave -noupdate -group Outputs -label LEDG7 /xm23_cpu/LEDG7
add wave -noupdate -group Outputs -label LEDR -radix hexadecimal /xm23_cpu/LEDR
add wave -noupdate -group Outputs -label LEDR16_17 /xm23_cpu/LEDR16_17
add wave -noupdate -group Outputs -label HEX0 /xm23_cpu/HEX0
add wave -noupdate -group Outputs -label HEX1 /xm23_cpu/HEX1
add wave -noupdate -group Outputs -label HEX2 /xm23_cpu/HEX2
add wave -noupdate -group Outputs -label HEX3 /xm23_cpu/HEX3
add wave -noupdate -group {Data Viewer} -label Update -radix hexadecimal /xm23_cpu/data_viewer/update
add wave -noupdate -group {Data Viewer} -label Mem_Mode -radix binary /xm23_cpu/data_viewer/mem_mode
add wave -noupdate -group {Data Viewer} -label Mem_Data -radix hexadecimal /xm23_cpu/data_viewer/mem_data
add wave -noupdate -group {Data Viewer} -label Reg_Data -radix hexadecimal /xm23_cpu/data_viewer/reg_data
add wave -noupdate -group {Data Viewer} -label PSW_Data -radix hexadecimal /xm23_cpu/data_viewer/psw_data
add wave -noupdate -group {Data Viewer} -label Address -radix hexadecimal /xm23_cpu/data_viewer/addr
add wave -noupdate -expand -group {IV Signals/Data} -label {Vector No.} -radix unsigned /xm23_cpu/vect_num
add wave -noupdate -expand -group {IV Signals/Data} -label IV_Cnt -radix binary /xm23_cpu/ctrl_unit/iv_cnt
add wave -noupdate -expand -group {IV Signals/Data} -label CEX_State_In /xm23_cpu/cex_state_in
add wave -noupdate -expand -group {IV Signals/Data} -label PIC_in /xm23_cpu/pic_in
add wave -noupdate -expand -group {IV Signals/Data} -label CPU_OP -radix decimal /xm23_cpu/ctrl_unit/cpu_OP
add wave -noupdate -expand -group {IV Signals/Data} -label CPU_WB /xm23_cpu/ctrl_unit/cpu_WB
add wave -noupdate -expand -group {IV Signals/Data} -label CPU_INC /xm23_cpu/ctrl_unit/cpu_INC
add wave -noupdate -expand -group {IV Signals/Data} -label CPU_DEC /xm23_cpu/ctrl_unit/cpu_DEC
add wave -noupdate -expand -group {IV Signals/Data} -label CPU_PRPO /xm23_cpu/ctrl_unit/cpu_PRPO
add wave -noupdate -expand -group {IV Signals/Data} -label PC_FLT /xm23_cpu/ctrl_unit/PC_FLT
add wave -noupdate -expand -group {IV Signals/Data} -label DBL_FLT /xm23_cpu/ctrl_unit/DBL_FLT
add wave -noupdate -expand -group {IV Signals/Data} -label PRI_FLT /xm23_cpu/ctrl_unit/PRI_FLT
add wave -noupdate -expand -group {IV Signals/Data} -label IV_Enter /xm23_cpu/ctrl_unit/iv_enter
add wave -noupdate -expand -group {IV Signals/Data} -label IV_Return /xm23_cpu/ctrl_unit/iv_return
add wave -noupdate -expand -group {IV Signals/Data} -label SVC_Inst /xm23_cpu/ctrl_unit/svc_inst
add wave -noupdate -expand -group {IV Signals/Data} -label In_Fault /xm23_cpu/ctrl_unit/in_fault
add wave -noupdate -expand -group {IV Signals/Data} -label Prev_Pri -radix unsigned /xm23_cpu/ctrl_unit/prev_priority
add wave -noupdate -expand -group {IV Signals/Data} -label PSW_Bus_Ctrl_IV /xm23_cpu/ctrl_unit/psw_bus_ctrl_iv
add wave -noupdate -expand -group {IV Signals/Data} -label IV_Cnt_RST /xm23_cpu/ctrl_unit/iv_cnt_rst
add wave -noupdate -expand -group {IV Signals/Data} -label PSW_Entry_Update /xm23_cpu/ctrl_unit/psw_entry_update
add wave -noupdate -expand -group {IV Signals/Data} -label Clear_CEX /xm23_cpu/ctrl_unit/clear_cex
add wave -noupdate -expand -group {IV Signals/Data} -label Load_CEX /xm23_cpu/ctrl_unit/load_cex
add wave -noupdate -expand -group {IV Signals/Data} -label CLR_SLP_Bit /xm23_cpu/ctrl_unit/clr_slp_bit
add wave -noupdate -expand -group {IV Signals/Data} -label Rec_Pre_Pri /xm23_cpu/ctrl_unit/rec_pre_pri
add wave -noupdate -expand -group {IV Signals/Data} -label Call_Pri_FLT /xm23_cpu/ctrl_unit/call_pri_flt
add wave -noupdate -expand -group {IV Signals/Data} -label Use_PIC_Vect /xm23_cpu/ctrl_unit/use_pic_vect
add wave -noupdate -expand -group {IV Signals/Data} -label Operands /xm23_cpu/ctrl_unit/operands
add wave -noupdate -expand -group {IV Signals/Data} -label Word_Byte /xm23_cpu/ctrl_unit/word_byte
add wave -noupdate -expand -group {IV Signals/Data} -label INC_IV /xm23_cpu/ctrl_unit/inc_iv
add wave -noupdate -expand -group {IV Signals/Data} -label DEC_IV /xm23_cpu/ctrl_unit/dec_iv
add wave -noupdate -expand -group {IV Signals/Data} -label PRPO_IV /xm23_cpu/ctrl_unit/prpo_iv
add wave -noupdate -expand -group {IV Signals/Data} -label IV_CPU_RST /xm23_cpu/ctrl_unit/iv_cpu_rst
add wave -noupdate -expand -group {IV Signals/Data} -label Data_Bus_Ctrl_IV /xm23_cpu/ctrl_unit/data_bus_ctrl_iv
add wave -noupdate -expand -group {IV Signals/Data} -label Addr_Bus_Ctrl_IV /xm23_cpu/ctrl_unit/addr_bus_ctrl_iv
add wave -noupdate -expand -group {IV Signals/Data} -label OP_IV -radix decimal /xm23_cpu/ctrl_unit/OP_iv
add wave -noupdate -expand -group {IV Signals/Data} -label Data_SRC_IV -radix unsigned /xm23_cpu/ctrl_unit/data_src_iv
add wave -noupdate -expand -group {IV Signals/Data} -label Addr_SRC_IV -radix unsigned /xm23_cpu/ctrl_unit/addr_src_iv
add wave -noupdate -expand -group {IV Signals/Data} -label Data_DST_IV -radix unsigned /xm23_cpu/ctrl_unit/data_dst_iv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5609696 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {545 ns} {645 ns}
