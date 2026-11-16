// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Nov 16 09:42:45 2026
// Host        : LAPTOP-A70MCDSC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               D:/fpga-labs/08a-epitrochoid-generator/08a-epitrochoid-generator.srcs/sources_1/ip/singen/singen_sim_netlist.v
// Design      : singen
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "singen,dds_compiler_v6_0_18,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dds_compiler_v6_0_18,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module singen
   (aclk,
    aclken,
    aresetn,
    s_axis_config_tvalid,
    s_axis_config_tdata,
    s_axis_config_tlast,
    m_axis_data_tvalid,
    m_axis_data_tdata,
    event_s_config_tlast_missing,
    event_s_config_tlast_unexpected);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_PHASE:S_AXIS_CONFIG:M_AXIS_DATA:S_AXIS_PHASE, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input aclk;
  (* x_interface_info = "xilinx.com:signal:clockenable:1.0 aclken_intf CE" *) (* x_interface_parameter = "XIL_INTERFACENAME aclken_intf, POLARITY ACTIVE_LOW" *) input aclken;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 aresetn_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME aresetn_intf, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_CONFIG TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_CONFIG, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_config_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_CONFIG TDATA" *) input [15:0]s_axis_config_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_CONFIG TLAST" *) input s_axis_config_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DATA TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_DATA, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_data_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DATA TDATA" *) output [31:0]m_axis_data_tdata;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_config_tlast_missing_intf INTERRUPT" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_config_tlast_missing_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_config_tlast_missing;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_config_tlast_unexpected_intf INTERRUPT" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_config_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_config_tlast_unexpected;

  wire aclk;
  wire aclken;
  wire aresetn;
  wire event_s_config_tlast_missing;
  wire event_s_config_tlast_unexpected;
  wire [31:0]m_axis_data_tdata;
  wire m_axis_data_tvalid;
  wire [15:0]s_axis_config_tdata;
  wire s_axis_config_tlast;
  wire s_axis_config_tvalid;
  wire NLW_U0_debug_axi_resync_in_UNCONNECTED;
  wire NLW_U0_debug_core_nd_UNCONNECTED;
  wire NLW_U0_debug_phase_nd_UNCONNECTED;
  wire NLW_U0_event_phase_in_invalid_UNCONNECTED;
  wire NLW_U0_event_pinc_invalid_UNCONNECTED;
  wire NLW_U0_event_poff_invalid_UNCONNECTED;
  wire NLW_U0_event_s_phase_chanid_incorrect_UNCONNECTED;
  wire NLW_U0_event_s_phase_tlast_missing_UNCONNECTED;
  wire NLW_U0_event_s_phase_tlast_unexpected_UNCONNECTED;
  wire NLW_U0_m_axis_data_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_phase_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_phase_tvalid_UNCONNECTED;
  wire NLW_U0_s_axis_config_tready_UNCONNECTED;
  wire NLW_U0_s_axis_phase_tready_UNCONNECTED;
  wire [0:0]NLW_U0_debug_axi_chan_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_axi_pinc_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_axi_poff_in_UNCONNECTED;
  wire [15:0]NLW_U0_debug_phase_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_data_tuser_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_phase_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_phase_tuser_UNCONNECTED;

  (* C_ACCUMULATOR_WIDTH = "16" *) 
  (* C_AMPLITUDE = "0" *) 
  (* C_CHANNELS = "2" *) 
  (* C_CHAN_WIDTH = "1" *) 
  (* C_DEBUG_INTERFACE = "0" *) 
  (* C_HAS_ACLKEN = "1" *) 
  (* C_HAS_ARESETN = "1" *) 
  (* C_HAS_M_DATA = "1" *) 
  (* C_HAS_M_PHASE = "0" *) 
  (* C_HAS_PHASEGEN = "1" *) 
  (* C_HAS_PHASE_OUT = "0" *) 
  (* C_HAS_SINCOS = "1" *) 
  (* C_HAS_S_CONFIG = "1" *) 
  (* C_HAS_S_PHASE = "0" *) 
  (* C_HAS_TLAST = "0" *) 
  (* C_HAS_TREADY = "0" *) 
  (* C_LATENCY = "4" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MODE_OF_OPERATION = "0" *) 
  (* C_MODULUS = "9" *) 
  (* C_M_DATA_HAS_TUSER = "0" *) 
  (* C_M_DATA_TDATA_WIDTH = "32" *) 
  (* C_M_DATA_TUSER_WIDTH = "1" *) 
  (* C_M_PHASE_HAS_TUSER = "0" *) 
  (* C_M_PHASE_TDATA_WIDTH = "1" *) 
  (* C_M_PHASE_TUSER_WIDTH = "1" *) 
  (* C_NEGATIVE_COSINE = "0" *) 
  (* C_NEGATIVE_SINE = "0" *) 
  (* C_NOISE_SHAPING = "0" *) 
  (* C_OPTIMISE_GOAL = "0" *) 
  (* C_OUTPUTS_REQUIRED = "2" *) 
  (* C_OUTPUT_FORM = "0" *) 
  (* C_OUTPUT_WIDTH = "11" *) 
  (* C_PHASE_ANGLE_WIDTH = "11" *) 
  (* C_PHASE_INCREMENT = "1" *) 
  (* C_PHASE_INCREMENT_VALUE = "100000000,100000000,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_PHASE_OFFSET = "0" *) 
  (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_POR_MODE = "0" *) 
  (* C_RESYNC = "0" *) 
  (* C_S_CONFIG_SYNC_MODE = "0" *) 
  (* C_S_CONFIG_TDATA_WIDTH = "16" *) 
  (* C_S_PHASE_HAS_TUSER = "0" *) 
  (* C_S_PHASE_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_TUSER_WIDTH = "1" *) 
  (* C_USE_DSP48 = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  singen_dds_compiler_v6_0_18 U0
       (.aclk(aclk),
        .aclken(aclken),
        .aresetn(aresetn),
        .debug_axi_chan_in(NLW_U0_debug_axi_chan_in_UNCONNECTED[0]),
        .debug_axi_pinc_in(NLW_U0_debug_axi_pinc_in_UNCONNECTED[15:0]),
        .debug_axi_poff_in(NLW_U0_debug_axi_poff_in_UNCONNECTED[15:0]),
        .debug_axi_resync_in(NLW_U0_debug_axi_resync_in_UNCONNECTED),
        .debug_core_nd(NLW_U0_debug_core_nd_UNCONNECTED),
        .debug_phase(NLW_U0_debug_phase_UNCONNECTED[15:0]),
        .debug_phase_nd(NLW_U0_debug_phase_nd_UNCONNECTED),
        .event_phase_in_invalid(NLW_U0_event_phase_in_invalid_UNCONNECTED),
        .event_pinc_invalid(NLW_U0_event_pinc_invalid_UNCONNECTED),
        .event_poff_invalid(NLW_U0_event_poff_invalid_UNCONNECTED),
        .event_s_config_tlast_missing(event_s_config_tlast_missing),
        .event_s_config_tlast_unexpected(event_s_config_tlast_unexpected),
        .event_s_phase_chanid_incorrect(NLW_U0_event_s_phase_chanid_incorrect_UNCONNECTED),
        .event_s_phase_tlast_missing(NLW_U0_event_s_phase_tlast_missing_UNCONNECTED),
        .event_s_phase_tlast_unexpected(NLW_U0_event_s_phase_tlast_unexpected_UNCONNECTED),
        .m_axis_data_tdata(m_axis_data_tdata),
        .m_axis_data_tlast(NLW_U0_m_axis_data_tlast_UNCONNECTED),
        .m_axis_data_tready(1'b0),
        .m_axis_data_tuser(NLW_U0_m_axis_data_tuser_UNCONNECTED[0]),
        .m_axis_data_tvalid(m_axis_data_tvalid),
        .m_axis_phase_tdata(NLW_U0_m_axis_phase_tdata_UNCONNECTED[0]),
        .m_axis_phase_tlast(NLW_U0_m_axis_phase_tlast_UNCONNECTED),
        .m_axis_phase_tready(1'b0),
        .m_axis_phase_tuser(NLW_U0_m_axis_phase_tuser_UNCONNECTED[0]),
        .m_axis_phase_tvalid(NLW_U0_m_axis_phase_tvalid_UNCONNECTED),
        .s_axis_config_tdata(s_axis_config_tdata),
        .s_axis_config_tlast(s_axis_config_tlast),
        .s_axis_config_tready(NLW_U0_s_axis_config_tready_UNCONNECTED),
        .s_axis_config_tvalid(s_axis_config_tvalid),
        .s_axis_phase_tdata(1'b0),
        .s_axis_phase_tlast(1'b0),
        .s_axis_phase_tready(NLW_U0_s_axis_phase_tready_UNCONNECTED),
        .s_axis_phase_tuser(1'b0),
        .s_axis_phase_tvalid(1'b0));
endmodule

(* C_ACCUMULATOR_WIDTH = "16" *) (* C_AMPLITUDE = "0" *) (* C_CHANNELS = "2" *) 
(* C_CHAN_WIDTH = "1" *) (* C_DEBUG_INTERFACE = "0" *) (* C_HAS_ACLKEN = "1" *) 
(* C_HAS_ARESETN = "1" *) (* C_HAS_M_DATA = "1" *) (* C_HAS_M_PHASE = "0" *) 
(* C_HAS_PHASEGEN = "1" *) (* C_HAS_PHASE_OUT = "0" *) (* C_HAS_SINCOS = "1" *) 
(* C_HAS_S_CONFIG = "1" *) (* C_HAS_S_PHASE = "0" *) (* C_HAS_TLAST = "0" *) 
(* C_HAS_TREADY = "0" *) (* C_LATENCY = "4" *) (* C_MEM_TYPE = "1" *) 
(* C_MODE_OF_OPERATION = "0" *) (* C_MODULUS = "9" *) (* C_M_DATA_HAS_TUSER = "0" *) 
(* C_M_DATA_TDATA_WIDTH = "32" *) (* C_M_DATA_TUSER_WIDTH = "1" *) (* C_M_PHASE_HAS_TUSER = "0" *) 
(* C_M_PHASE_TDATA_WIDTH = "1" *) (* C_M_PHASE_TUSER_WIDTH = "1" *) (* C_NEGATIVE_COSINE = "0" *) 
(* C_NEGATIVE_SINE = "0" *) (* C_NOISE_SHAPING = "0" *) (* C_OPTIMISE_GOAL = "0" *) 
(* C_OUTPUTS_REQUIRED = "2" *) (* C_OUTPUT_FORM = "0" *) (* C_OUTPUT_WIDTH = "11" *) 
(* C_PHASE_ANGLE_WIDTH = "11" *) (* C_PHASE_INCREMENT = "1" *) (* C_PHASE_INCREMENT_VALUE = "100000000,100000000,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
(* C_PHASE_OFFSET = "0" *) (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) (* C_POR_MODE = "0" *) 
(* C_RESYNC = "0" *) (* C_S_CONFIG_SYNC_MODE = "0" *) (* C_S_CONFIG_TDATA_WIDTH = "16" *) 
(* C_S_PHASE_HAS_TUSER = "0" *) (* C_S_PHASE_TDATA_WIDTH = "1" *) (* C_S_PHASE_TUSER_WIDTH = "1" *) 
(* C_USE_DSP48 = "0" *) (* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "dds_compiler_v6_0_18" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module singen_dds_compiler_v6_0_18
   (aclk,
    aclken,
    aresetn,
    s_axis_phase_tvalid,
    s_axis_phase_tready,
    s_axis_phase_tdata,
    s_axis_phase_tlast,
    s_axis_phase_tuser,
    s_axis_config_tvalid,
    s_axis_config_tready,
    s_axis_config_tdata,
    s_axis_config_tlast,
    m_axis_data_tvalid,
    m_axis_data_tready,
    m_axis_data_tdata,
    m_axis_data_tlast,
    m_axis_data_tuser,
    m_axis_phase_tvalid,
    m_axis_phase_tready,
    m_axis_phase_tdata,
    m_axis_phase_tlast,
    m_axis_phase_tuser,
    event_pinc_invalid,
    event_poff_invalid,
    event_phase_in_invalid,
    event_s_phase_tlast_missing,
    event_s_phase_tlast_unexpected,
    event_s_phase_chanid_incorrect,
    event_s_config_tlast_missing,
    event_s_config_tlast_unexpected,
    debug_axi_pinc_in,
    debug_axi_poff_in,
    debug_axi_resync_in,
    debug_axi_chan_in,
    debug_core_nd,
    debug_phase,
    debug_phase_nd);
  input aclk;
  input aclken;
  input aresetn;
  input s_axis_phase_tvalid;
  output s_axis_phase_tready;
  input [0:0]s_axis_phase_tdata;
  input s_axis_phase_tlast;
  input [0:0]s_axis_phase_tuser;
  input s_axis_config_tvalid;
  output s_axis_config_tready;
  input [15:0]s_axis_config_tdata;
  input s_axis_config_tlast;
  output m_axis_data_tvalid;
  input m_axis_data_tready;
  output [31:0]m_axis_data_tdata;
  output m_axis_data_tlast;
  output [0:0]m_axis_data_tuser;
  output m_axis_phase_tvalid;
  input m_axis_phase_tready;
  output [0:0]m_axis_phase_tdata;
  output m_axis_phase_tlast;
  output [0:0]m_axis_phase_tuser;
  output event_pinc_invalid;
  output event_poff_invalid;
  output event_phase_in_invalid;
  output event_s_phase_tlast_missing;
  output event_s_phase_tlast_unexpected;
  output event_s_phase_chanid_incorrect;
  output event_s_config_tlast_missing;
  output event_s_config_tlast_unexpected;
  output [15:0]debug_axi_pinc_in;
  output [15:0]debug_axi_poff_in;
  output debug_axi_resync_in;
  output [0:0]debug_axi_chan_in;
  output debug_core_nd;
  output [15:0]debug_phase;
  output debug_phase_nd;

  wire \<const0> ;
  wire aclk;
  wire aclken;
  wire aresetn;
  wire event_s_config_tlast_missing;
  wire event_s_config_tlast_unexpected;
  wire [26:0]\^m_axis_data_tdata ;
  wire m_axis_data_tvalid;
  wire [15:0]s_axis_config_tdata;
  wire s_axis_config_tlast;
  wire s_axis_config_tready;
  wire s_axis_config_tvalid;
  wire NLW_i_synth_debug_axi_resync_in_UNCONNECTED;
  wire NLW_i_synth_debug_core_nd_UNCONNECTED;
  wire NLW_i_synth_debug_phase_nd_UNCONNECTED;
  wire NLW_i_synth_event_phase_in_invalid_UNCONNECTED;
  wire NLW_i_synth_event_pinc_invalid_UNCONNECTED;
  wire NLW_i_synth_event_poff_invalid_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_chanid_incorrect_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_tlast_missing_UNCONNECTED;
  wire NLW_i_synth_event_s_phase_tlast_unexpected_UNCONNECTED;
  wire NLW_i_synth_m_axis_data_tlast_UNCONNECTED;
  wire NLW_i_synth_m_axis_phase_tlast_UNCONNECTED;
  wire NLW_i_synth_m_axis_phase_tvalid_UNCONNECTED;
  wire NLW_i_synth_s_axis_phase_tready_UNCONNECTED;
  wire [0:0]NLW_i_synth_debug_axi_chan_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_axi_pinc_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_axi_poff_in_UNCONNECTED;
  wire [15:0]NLW_i_synth_debug_phase_UNCONNECTED;
  wire [30:10]NLW_i_synth_m_axis_data_tdata_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_data_tuser_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_phase_tdata_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_phase_tuser_UNCONNECTED;

  assign debug_axi_chan_in[0] = \<const0> ;
  assign debug_axi_pinc_in[15] = \<const0> ;
  assign debug_axi_pinc_in[14] = \<const0> ;
  assign debug_axi_pinc_in[13] = \<const0> ;
  assign debug_axi_pinc_in[12] = \<const0> ;
  assign debug_axi_pinc_in[11] = \<const0> ;
  assign debug_axi_pinc_in[10] = \<const0> ;
  assign debug_axi_pinc_in[9] = \<const0> ;
  assign debug_axi_pinc_in[8] = \<const0> ;
  assign debug_axi_pinc_in[7] = \<const0> ;
  assign debug_axi_pinc_in[6] = \<const0> ;
  assign debug_axi_pinc_in[5] = \<const0> ;
  assign debug_axi_pinc_in[4] = \<const0> ;
  assign debug_axi_pinc_in[3] = \<const0> ;
  assign debug_axi_pinc_in[2] = \<const0> ;
  assign debug_axi_pinc_in[1] = \<const0> ;
  assign debug_axi_pinc_in[0] = \<const0> ;
  assign debug_axi_poff_in[15] = \<const0> ;
  assign debug_axi_poff_in[14] = \<const0> ;
  assign debug_axi_poff_in[13] = \<const0> ;
  assign debug_axi_poff_in[12] = \<const0> ;
  assign debug_axi_poff_in[11] = \<const0> ;
  assign debug_axi_poff_in[10] = \<const0> ;
  assign debug_axi_poff_in[9] = \<const0> ;
  assign debug_axi_poff_in[8] = \<const0> ;
  assign debug_axi_poff_in[7] = \<const0> ;
  assign debug_axi_poff_in[6] = \<const0> ;
  assign debug_axi_poff_in[5] = \<const0> ;
  assign debug_axi_poff_in[4] = \<const0> ;
  assign debug_axi_poff_in[3] = \<const0> ;
  assign debug_axi_poff_in[2] = \<const0> ;
  assign debug_axi_poff_in[1] = \<const0> ;
  assign debug_axi_poff_in[0] = \<const0> ;
  assign debug_axi_resync_in = \<const0> ;
  assign debug_core_nd = \<const0> ;
  assign debug_phase[15] = \<const0> ;
  assign debug_phase[14] = \<const0> ;
  assign debug_phase[13] = \<const0> ;
  assign debug_phase[12] = \<const0> ;
  assign debug_phase[11] = \<const0> ;
  assign debug_phase[10] = \<const0> ;
  assign debug_phase[9] = \<const0> ;
  assign debug_phase[8] = \<const0> ;
  assign debug_phase[7] = \<const0> ;
  assign debug_phase[6] = \<const0> ;
  assign debug_phase[5] = \<const0> ;
  assign debug_phase[4] = \<const0> ;
  assign debug_phase[3] = \<const0> ;
  assign debug_phase[2] = \<const0> ;
  assign debug_phase[1] = \<const0> ;
  assign debug_phase[0] = \<const0> ;
  assign debug_phase_nd = \<const0> ;
  assign event_phase_in_invalid = \<const0> ;
  assign event_pinc_invalid = \<const0> ;
  assign event_poff_invalid = \<const0> ;
  assign event_s_phase_chanid_incorrect = \<const0> ;
  assign event_s_phase_tlast_missing = \<const0> ;
  assign event_s_phase_tlast_unexpected = \<const0> ;
  assign m_axis_data_tdata[31] = \^m_axis_data_tdata [26];
  assign m_axis_data_tdata[30] = \^m_axis_data_tdata [26];
  assign m_axis_data_tdata[29] = \^m_axis_data_tdata [26];
  assign m_axis_data_tdata[28] = \^m_axis_data_tdata [26];
  assign m_axis_data_tdata[27] = \^m_axis_data_tdata [26];
  assign m_axis_data_tdata[26:16] = \^m_axis_data_tdata [26:16];
  assign m_axis_data_tdata[15] = \^m_axis_data_tdata [10];
  assign m_axis_data_tdata[14] = \^m_axis_data_tdata [10];
  assign m_axis_data_tdata[13] = \^m_axis_data_tdata [10];
  assign m_axis_data_tdata[12] = \^m_axis_data_tdata [10];
  assign m_axis_data_tdata[11] = \^m_axis_data_tdata [10];
  assign m_axis_data_tdata[10:0] = \^m_axis_data_tdata [10:0];
  assign m_axis_data_tlast = \<const0> ;
  assign m_axis_data_tuser[0] = \<const0> ;
  assign m_axis_phase_tdata[0] = \<const0> ;
  assign m_axis_phase_tlast = \<const0> ;
  assign m_axis_phase_tuser[0] = \<const0> ;
  assign m_axis_phase_tvalid = \<const0> ;
  assign s_axis_phase_tready = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_ACCUMULATOR_WIDTH = "16" *) 
  (* C_AMPLITUDE = "0" *) 
  (* C_CHANNELS = "2" *) 
  (* C_CHAN_WIDTH = "1" *) 
  (* C_DEBUG_INTERFACE = "0" *) 
  (* C_HAS_ACLKEN = "1" *) 
  (* C_HAS_ARESETN = "1" *) 
  (* C_HAS_M_DATA = "1" *) 
  (* C_HAS_M_PHASE = "0" *) 
  (* C_HAS_PHASEGEN = "1" *) 
  (* C_HAS_PHASE_OUT = "0" *) 
  (* C_HAS_SINCOS = "1" *) 
  (* C_HAS_S_CONFIG = "1" *) 
  (* C_HAS_S_PHASE = "0" *) 
  (* C_HAS_TLAST = "0" *) 
  (* C_HAS_TREADY = "0" *) 
  (* C_LATENCY = "4" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MODE_OF_OPERATION = "0" *) 
  (* C_MODULUS = "9" *) 
  (* C_M_DATA_HAS_TUSER = "0" *) 
  (* C_M_DATA_TDATA_WIDTH = "32" *) 
  (* C_M_DATA_TUSER_WIDTH = "1" *) 
  (* C_M_PHASE_HAS_TUSER = "0" *) 
  (* C_M_PHASE_TDATA_WIDTH = "1" *) 
  (* C_M_PHASE_TUSER_WIDTH = "1" *) 
  (* C_NEGATIVE_COSINE = "0" *) 
  (* C_NEGATIVE_SINE = "0" *) 
  (* C_NOISE_SHAPING = "0" *) 
  (* C_OPTIMISE_GOAL = "0" *) 
  (* C_OUTPUTS_REQUIRED = "2" *) 
  (* C_OUTPUT_FORM = "0" *) 
  (* C_OUTPUT_WIDTH = "11" *) 
  (* C_PHASE_ANGLE_WIDTH = "11" *) 
  (* C_PHASE_INCREMENT = "1" *) 
  (* C_PHASE_INCREMENT_VALUE = "100000000,100000000,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_PHASE_OFFSET = "0" *) 
  (* C_PHASE_OFFSET_VALUE = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" *) 
  (* C_POR_MODE = "0" *) 
  (* C_RESYNC = "0" *) 
  (* C_S_CONFIG_SYNC_MODE = "0" *) 
  (* C_S_CONFIG_TDATA_WIDTH = "16" *) 
  (* C_S_PHASE_HAS_TUSER = "0" *) 
  (* C_S_PHASE_TDATA_WIDTH = "1" *) 
  (* C_S_PHASE_TUSER_WIDTH = "1" *) 
  (* C_USE_DSP48 = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  singen_dds_compiler_v6_0_18_viv i_synth
       (.aclk(aclk),
        .aclken(aclken),
        .aresetn(aresetn),
        .debug_axi_chan_in(NLW_i_synth_debug_axi_chan_in_UNCONNECTED[0]),
        .debug_axi_pinc_in(NLW_i_synth_debug_axi_pinc_in_UNCONNECTED[15:0]),
        .debug_axi_poff_in(NLW_i_synth_debug_axi_poff_in_UNCONNECTED[15:0]),
        .debug_axi_resync_in(NLW_i_synth_debug_axi_resync_in_UNCONNECTED),
        .debug_core_nd(NLW_i_synth_debug_core_nd_UNCONNECTED),
        .debug_phase(NLW_i_synth_debug_phase_UNCONNECTED[15:0]),
        .debug_phase_nd(NLW_i_synth_debug_phase_nd_UNCONNECTED),
        .event_phase_in_invalid(NLW_i_synth_event_phase_in_invalid_UNCONNECTED),
        .event_pinc_invalid(NLW_i_synth_event_pinc_invalid_UNCONNECTED),
        .event_poff_invalid(NLW_i_synth_event_poff_invalid_UNCONNECTED),
        .event_s_config_tlast_missing(event_s_config_tlast_missing),
        .event_s_config_tlast_unexpected(event_s_config_tlast_unexpected),
        .event_s_phase_chanid_incorrect(NLW_i_synth_event_s_phase_chanid_incorrect_UNCONNECTED),
        .event_s_phase_tlast_missing(NLW_i_synth_event_s_phase_tlast_missing_UNCONNECTED),
        .event_s_phase_tlast_unexpected(NLW_i_synth_event_s_phase_tlast_unexpected_UNCONNECTED),
        .m_axis_data_tdata({\^m_axis_data_tdata [26],NLW_i_synth_m_axis_data_tdata_UNCONNECTED[30:26],\^m_axis_data_tdata [25:16],\^m_axis_data_tdata [10],NLW_i_synth_m_axis_data_tdata_UNCONNECTED[14:10],\^m_axis_data_tdata [9:0]}),
        .m_axis_data_tlast(NLW_i_synth_m_axis_data_tlast_UNCONNECTED),
        .m_axis_data_tready(1'b0),
        .m_axis_data_tuser(NLW_i_synth_m_axis_data_tuser_UNCONNECTED[0]),
        .m_axis_data_tvalid(m_axis_data_tvalid),
        .m_axis_phase_tdata(NLW_i_synth_m_axis_phase_tdata_UNCONNECTED[0]),
        .m_axis_phase_tlast(NLW_i_synth_m_axis_phase_tlast_UNCONNECTED),
        .m_axis_phase_tready(1'b0),
        .m_axis_phase_tuser(NLW_i_synth_m_axis_phase_tuser_UNCONNECTED[0]),
        .m_axis_phase_tvalid(NLW_i_synth_m_axis_phase_tvalid_UNCONNECTED),
        .s_axis_config_tdata(s_axis_config_tdata),
        .s_axis_config_tlast(s_axis_config_tlast),
        .s_axis_config_tready(s_axis_config_tready),
        .s_axis_config_tvalid(s_axis_config_tvalid),
        .s_axis_phase_tdata(1'b0),
        .s_axis_phase_tlast(1'b0),
        .s_axis_phase_tready(NLW_i_synth_s_axis_phase_tready_UNCONNECTED),
        .s_axis_phase_tuser(1'b0),
        .s_axis_phase_tvalid(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2019.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
ag49RSaXLOG4xxULlDyO1h9Bt1tXxD8QSYAdgfsZmsYA2qz7wg+SSUXB8JjzU2owt7o4eSmQVBkv
9kufty+oIQ==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
beER7wF1A3pmXiXm1TFX9IvmAFUcJ13uMC6TseJWrR0JDHD/O3dKRM6PO4Up/CFQ2H37nKClSGcK
Xug89GBtLfoDpFLh+xP2Vy07zuqOy7uywLvaukELsTzPf+0n/Xp60hkmPlC81KPi1DXhJUhJdbqA
yi5TP4w1WPUjCtK/688=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uJZzBmpzrESHK9uJTBRGbyDZMxFeU9+2SClZZYLsPBAU9V9oQiK75ubhJObpnmwewUOoBxz3zJhu
34asP1BGbunyLgeJYr0OiNow3a8XihoRSYbIdKxKq3vjl4MLatqJEBLCN8Uqf0Pu+E+jWbMFfcxy
YAnzqN8sgF4OZI5wLBzPXafQi1767wu3Wtw/sQe5anCy8TAyLarP9ast1O9Vj15Rk2tLtgm/LZqR
yZd0qKSqmW4A81G6x+ixR2y/IqQ1qALI1NCgPfvH4Ieyq7XPyblqlNyParNLhG2wjr0y4ofNWp/3
h4o2c+vYiIrkx6rmzrp/rUIybZ9A9HDZaA+ciA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MfuZTTml919Hbg0Ib2VBuKuYX6+OjqUB2INt3NN2eutVeJhuMufRcsa0q1J3vztEmpkdGV6+RTfb
HKoQKFD6EwJ10b0AcDFjpD8+L6fGReFnvS0g731shB/OodUdaV8giQpoNHCm2XtoKsv/Lgqn+U27
EV3lJK6Lt+nUx6DUsocHc5RcvRHw58/myY6ZtXqFDMXJfFOVK18LSGHnEg1OXkFqEApSxPVexe3t
s0jVQDZRqkFortHzVNrWx73GPD4RFe+7vmA/hegviTOrtvw99UpoL8yyjZyO3WOlde1quROnWZtl
8BwV/r+EPBUPh50jKc+nVMUwLKYH8/iDFUIpsA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_02", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bJsfCx8emG9lVb/vjASSH6y78U+06ketn/XvcxXkuwOnvwxs7wpKbvKxuP4Ht/qw/W2x/0Yf02kE
WBxMF+BnpDUX67X5j60mOzT2j0ZYCuFJN9kbpdHjz3Ekw/u9MBVbJppIZsHCWkzk8bOejCc+dey6
uKr6E3w+/K97/Rld2HkJp2oTONv039xGcZEjeSi0lePhlRX0rhSfD0ixFje/nMEadDX5qmjf3+jt
/VeShbed51E8U6v7e1T5QOk3TdFmkYjH+NGfYuQg3iCCVd/1LP9eqPJHZkzv46tJ9yquR6upFVae
N2f7q08udoFP14ZZMSWY0FVcj+R8uc1SpoZ08w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
DD7F0WIA2tCJDGGyuiJBMJ6VkyzlY4wTm+PBxGw32rno1Lc5XJ6R/MdpajSKtZkvW3jP5SII6hW8
/NoKV4ROiGDYzmMIubH+jq3u0TtkWxCL8+cj3SNuMEayY39+8F4sUjaZEFERxcl1JK64XpQCcPdd
qDExjxIvRWRuuTD424M=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Z8r/pZDFkssalgvLpiT5lxxnKwN27AIWvhfsYdefLfSuxYTC5pbsQO/glsRgaQ+pfMXTafAs1c8M
dypCXo6c0EAVYWrPv6LXzncAvpvkgF3equA0GovqWA9u1DpNOwpg1+9zyuK298jIW0FY3V+8XZYP
i9enkYei0sCGexSdPzqATDbRzjzApbpnBZpWe6z4en7Wb9o0cFYVvU0I2D694fRndQa2DDTk5yRa
yG9QYOCPabDGrsr3xHF371LpdUv9XcgOm45jMWa9bZ1oL2S9hL6xUIjS0C8vlmUWEtNohYiiamIC
mjfkGqLNOX02xYC0DG4kzfO01bAlP3sDf4JdCw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XyLjUntODJjNT0yDcp7tKBv2+dfxFjuoAnNQygASCMxeCasMRjsyVhoQMlN11duJ13bU5MJ5BUZP
Fkfo/joVBnTmO5cq4G3fFBxjpMrnU3sdj6nrpF3+O8qIl1ktvDk/ZglEN5/45c+0Q/0Fx3F+Mq3x
7QjJUUK2pZ6LRVyZtJ1pGqDcyCnjKxvkiwgQA9+cOpf8owGDx9EmQ9kA2V3G6W8S+J4oRq99/+4M
N2eC1SIV7MNGgZ3JaXuNPA/8eXF1uVwDHZp8zb0xb2xTVikpbGmnOMUkuxB2CopvtXafRAgH4NI+
kanznd6scrhuE922OpweVLmBoWDwotf5dAITvA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uMJxONN1HX/QNmDkts5AO0vT/UnM7Cx15h2rxe+aOjrhEpS1RgZEGxg8vo6KC03Rn5puQGxg9P3v
efPCgVgvYB8Oq2waO3tM+k7VV8p//xNZjScGj3Ez2noD0MWnDiKZivXK7WX1G/Iihm3QOolcf910
3v0XLztIRJkubT4zxCWeBw0zucRqQOBg73WCLdIPaptOv31X4cgOGt1nCjwbq5RLzNNdDMbOGpEZ
GWOJ6UQQ+UzTloATLwhp/+r5att/D0spfxdWitIFHpYgbBSEv/kDPVBTXKH9XhBG57W9XclGn+2p
4qh27wnksgrJSCjP9kdiitu9jz4Go169Zeq2XA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 61536)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
