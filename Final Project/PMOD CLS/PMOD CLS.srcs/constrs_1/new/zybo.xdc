## This file is a general .xdc for the Zybo Z7 Rev. B
## It is compatible with the Zybo Z7-20 and Zybo Z7-10
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##Clock signal
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { XCLK }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { XCLK }];


##Switches
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { XSWITCHES[0] }]; #IO_L19N_T3_VREF_35 Sch=sw[0]
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { XSWITCHES[1] }]; #IO_L24P_T3_34 Sch=sw[1]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { XSWITCHES[2] }]; #IO_L4N_T0_34 Sch=sw[2]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { XSWITCHES[3] }]; #IO_L9P_T1_DQS_34 Sch=sw[3]


##Buttons
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { XRESET }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { START_CLS }]; #IO_L24N_T3_34 Sch=btn[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { CLEAR_CLS }]; #IO_L10P_T1_AD11P_35 Sch=btn[2]
#set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L7P_T1_34 Sch=btn[3]


##LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { LED }]; #IO_L23P_T3_35 Sch=led[0]
#set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { XLEDS[1] }]; #IO_L23N_T3_35 Sch=led[1]
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { XLEDS[2] }]; #IO_0_35 Sch=led[2]
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { XLEDS[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=led[3]


##RGB LED 5 (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS33 } [get_ports { led5_r }]; #IO_L18N_T2_13 Sch=led5_r
#set_property -dict { PACKAGE_PIN T5    IOSTANDARD LVCMOS33 } [get_ports { led5_g }]; #IO_L19P_T3_13 Sch=led5_g
#set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS33 } [get_ports { led5_b }]; #IO_L20P_T3_13 Sch=led5_b

##RGB LED 6
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {XLOCKED}]; #IO_L18P_T2_34 Sch=led6_r
#set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports {}]; #IO_L6N_T0_VREF_35 Sch=led6_g
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports {}]; #IO_L8P_T1_AD10P_35 Sch=led6_b


##Audio Codec
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { ac_bclk }]; #IO_0_34 Sch=ac_bclk
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ac_mclk }]; #IO_L19N_T3_VREF_34 Sch=ac_mclk
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { ac_muten }]; #IO_L23N_T3_34 Sch=ac_muten
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { ac_pbdat }]; #IO_L20N_T3_34 Sch=ac_pbdat
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { ac_pblrc }]; #IO_25_34 Sch=ac_pblrc
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ac_recdat }]; #IO_L19P_T3_34 Sch=ac_recdat
#set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { ac_reclrc }]; #IO_L17P_T2_34 Sch=ac_reclrc
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { ac_scl }]; #IO_L13P_T2_MRCC_34 Sch=ac_scl
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { ac_sda }]; #IO_L23P_T3_34 Sch=ac_sda
 
 
##Additional Ethernet signals
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33  PULLUP true    } [get_ports { eth_int_pu_b }]; #IO_L6P_T0_35 Sch=eth_int_pu_b
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { eth_rst_b }]; #IO_L3P_T0_DQS_AD1P_35 Sch=eth_rst_b


##USB-OTG over-current detect pin
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { otg_oc }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=otg_oc


##Fan (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS33  PULLUP true    } [get_ports { fan_fb_pu }]; #IO_L20N_T3_13 Sch=fan_fb_pu


##HDMI RX
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]; #IO_L22N_T3_34 Sch=hdmi_rx_hpd
#set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_scl }]; #IO_L22P_T3_34 Sch=hdmi_rx_scl
#set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_sda }]; #IO_L17N_T2_34 Sch=hdmi_rx_sda
#set_property -dict { PACKAGE_PIN U19   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_n }]; #IO_L12N_T1_MRCC_34 Sch=hdmi_rx_clk_n
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_p }]; #IO_L12P_T1_MRCC_34 Sch=hdmi_rx_clk_p
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[0] }]; #IO_L16N_T2_34 Sch=hdmi_rx_n[0]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[0] }]; #IO_L16P_T2_34 Sch=hdmi_rx_p[0]
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[1] }]; #IO_L15N_T2_DQS_34 Sch=hdmi_rx_n[1]
#set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[1] }]; #IO_L15P_T2_DQS_34 Sch=hdmi_rx_p[1]
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[2] }]; #IO_L14N_T2_SRCC_34 Sch=hdmi_rx_n[2]
#set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[2] }]; #IO_L14P_T2_SRCC_34 Sch=hdmi_rx_p[2]

##HDMI RX CEC (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L14N_T2_SRCC_13 Sch=hdmi_rx_cec


##HDMI TX
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_hpd }]; #IO_L5P_T0_AD9P_35 Sch=hdmi_tx_hpd
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_scl }]; #IO_L16P_T2_35 Sch=hdmi_tx_scl
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_sda }]; #IO_L16N_T2_35 Sch=hdmi_tx_sda
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_clk_n }]; #IO_L13N_T2_MRCC_35 Sch=hdmi_tx_clk_n
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_clk_p }]; #IO_L13P_T2_MRCC_35 Sch=hdmi_tx_clk_p
#set_property -dict { PACKAGE_PIN D20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[0] }]; #IO_L4N_T0_35 Sch=hdmi_tx_n[0]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[0] }]; #IO_L4P_T0_35 Sch=hdmi_tx_p[0]
#set_property -dict { PACKAGE_PIN B20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[1] }]; #IO_L1N_T0_AD0N_35 Sch=hdmi_tx_n[1]
#set_property -dict { PACKAGE_PIN C20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[1] }]; #IO_L1P_T0_AD0P_35 Sch=hdmi_tx_p[1]
#set_property -dict { PACKAGE_PIN A20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[2] }]; #IO_L2N_T0_AD8N_35 Sch=hdmi_tx_n[2]
#set_property -dict { PACKAGE_PIN B19   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[2] }]; #IO_L2P_T0_AD8P_35 Sch=hdmi_tx_p[2]

##HDMI TX CEC 
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L5N_T0_AD9N_35 Sch=hdmi_tx_cec
 

##Pmod Header JA (XADC)
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { IRQ }]; #IO_L21P_T3_DQS_AD14P_35 Sch=JA1_R_p		   
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { SS_ToF }]; #IO_L22P_T3_AD7P_35 Sch=JA2_R_P             
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SCL }]; #IO_L24P_T3_AD15P_35 Sch=JA3_R_P            
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { SDA }]; #IO_L20P_T3_AD6P_35 Sch=JA4_R_P             
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports {  }]; #IO_L21N_T3_DQS_AD14N_35 Sch=JA1_R_N        
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports {  }]; #IO_L22N_T3_AD7N_35 Sch=JA2_R_N             
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports {  }]; #IO_L24N_T3_AD15N_35 Sch=JA3_R_N            
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports {  }]; #IO_L20N_T3_AD6N_35 Sch=JA4_R_N             
 

##Pmod Header JB (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33     } [get_ports { jb[0] }]; #IO_L15P_T2_DQS_13 Sch=jb_p[1]		 
#set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33     } [get_ports { jb[1] }]; #IO_L15N_T2_DQS_13 Sch=jb_n[1]         
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33     } [get_ports { jb[2] }]; #IO_L11P_T1_SRCC_13 Sch=jb_p[2]        
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33     } [get_ports { jb[3] }]; #IO_L11N_T1_SRCC_13 Sch=jb_n[2]        
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33     } [get_ports { jb[4] }]; #IO_L13P_T2_MRCC_13 Sch=jb_p[3]        
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33     } [get_ports { jb[5] }]; #IO_L13N_T2_MRCC_13 Sch=jb_n[3]        
#set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33     } [get_ports { jb[6] }]; #IO_L22P_T3_13 Sch=jb_p[4]             
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33     } [get_ports { jb[7] }]; #IO_L22N_T3_13 Sch=jb_n[4]             
                                                                                                                                 
                                                                                                                                 
##Pmod Header JC                                                                                                                  
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports {SS_CLS}]; #IO_L10P_T1_34 Sch=jc_p[1]   			 
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports {MOSI}]; #IO_L10N_T1_34 Sch=jc_n[1]		     
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports {MISO}]; #IO_L1P_T0_34 Sch=jc_p[2]              
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports {SCK}]; #IO_L1N_T0_34 Sch=jc_n[2]              
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { XSEVEN_SEGMENT[0] }]; #IO_L8P_T1_34 Sch=jc_p[3]              
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { XSEVEN_SEGMENT[1] }]; #IO_L8N_T1_34 Sch=jc_n[3]              
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { XSEVEN_SEGMENT[2] }]; #IO_L2P_T0_34 Sch=jc_p[4]              
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports { XSEVEN_SEGMENT[3] }]; #IO_L2N_T0_34 Sch=jc_n[4]              