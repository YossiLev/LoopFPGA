// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================

`define ENABLE_HPS
`define VERSION   32'h00001171
`define MAGIC     32'h11347698

//
// do chip select 1 shot set of the write bit 
// every 100,000 cycles (every 1msec).
//
`define PID_PREDICTOR2_CS_LIMIT 32'h186A0   

module pid_top(

      
      ///////// ADC /////////
      inout              ADC_CS_N,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,

      ///////// AUD /////////
      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,

      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      input              CLOCK4_50,

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// DRAM /////////
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,

      ///////// FAN /////////
      output             FAN_CTRL,

      ///////// FPGA /////////
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,

//////        ///////// GPIO /////////
//////      inout     [35:0]         GPIO_0,
       output      GPIO_034,
//////      inout     [35:0]         GPIO_1,
//////   
      //////////////////////////// GPIO ///////////////////////
      output		       ADC_CLK_A,
      output		       ADC_CLK_B,
      input		  [13:0]  ADC_DA,
      input		  [13:0]	 ADC_DB,
      output		       ADC_OEB_A,
      output		       ADC_OEB_B,
      input		          ADC_OTR_A,
      input		          ADC_OTR_B,

      output		       DAC_CLK_A,
      output		       DAC_CLK_B,
      output	  [13:0]   DAC_DA,
      output	  [13:0]   DAC_DB,
      output		       DAC_MODE,
      output		       DAC_WRT_A,
      output		       DAC_WRT_B,

      output		       POWER_ON,
      output             OSC_SMA_ADC4,
      output             SMA_DAC4,

      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,

      ///////// HEX2 /////////
      output      [6:0]  HEX2,

      ///////// HEX3 /////////
      output      [6:0]  HEX3,

      ///////// HEX4 /////////
      output      [6:0]  HEX4,

      ///////// HEX5 /////////
      output      [6:0]  HEX5,

`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

      ///////// IRDA /////////
      input              IRDA_RXD,
      output             IRDA_TXD,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// PS2 /////////
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// TD /////////
      input              TD_CLK27,
      input      [7:0]  TD_DATA,
      input             TD_HS,
      output             TD_RESET_N,
      input             TD_VS,


      ///////// VGA /////////
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS
);



// internal wires and registers declaration
  wire [3:0]  fpga_debounced_buttons;
  wire [9:0]  fpga_led_internal;
  wire        hps_fpga_reset_n;
  wire [2:0]  hps_reset_req;
  wire        hps_cold_reset;
  wire        hps_warm_reset;
  wire        hps_debug_reset;
  wire [27:0] stm_hw_events;

  wire PLL_CLOCK_400;       // PLL clock outputs
  wire PLL_CLOCK_300;       // PLL clock outputs
  wire PLL_CLOCK_200;       // PLL clock outputs
  wire PLL_CLOCK_100;
  wire PLL_CLOCK_50 ;
  wire PLL_LOCKED   ;

  wire LOCKED_PLL_CLOCK_400 ;   
  wire LOCKED_PLL_CLOCK_300 ;   
  wire LOCKED_PLL_CLOCK_200 ;   
  wire LOCKED_PLL_CLOCK_100 ;
  wire LOCKED_PLL_CLOCK_50  ;

  wire [31:0] w_version = `VERSION;
  wire [31:0] w_magic = `MAGIC;

  //wire FAST_SYSTEM_CLOCK = LOCKED_PLL_CLOCK_200;
  wire FAST_SYSTEM_CLOCK = LOCKED_PLL_CLOCK_100;
//  wire FAST_SYSTEM_CLOCK    ;
//  wire [3:0]  fast_clock_select = {SW[9:6]}; 
//
//
//
//  assign  FAST_SYSTEM_CLOCK =   (   (fast_clock_select == 4'd0 ? LOCKED_PLL_CLOCK_200   
//                                  : (fast_clock_select == 4'd1 ? LOCKED_PLL_CLOCK_300
//                                  : (fast_clock_select == 4'd2 ? LOCKED_PLL_CLOCK_400
//                                  : (fast_clock_select == 4'd3 ? LOCKED_PLL_CLOCK_100
//                                  : (fast_clock_select == 4'd4 ? LOCKED_PLL_CLOCK_50
//                                  :                              LOCKED_PLL_CLOCK_50
//                                  )
//                                  )
//                                  )
//                                  )
//                                  )
//                                  )
//                                  ;
//


  wire BOARD_CLOCK          = CLOCK_50               ;   // Clock before the PLL and independent of the PLL
  wire PLL_CLOCK_SOURCE     = BOARD_CLOCK            ;   // PLL is fed from this ref clock.
  wire SYSTEM_CLOCK         = LOCKED_PLL_CLOCK_50    ;   // System (i.e., the soc_system module below) is driven by this clock
  wire PID_REG_CLOCK        = SYSTEM_CLOCK           ;   // PID register access at 100MHz (slower than logic!)
  //wire PID_LOGIC_CLOCK      = LOCKED_PLL_CLOCK_200   ;   // PID logic runs at 200MHz.
  wire PID_LOGIC_CLOCK      = FAST_SYSTEM_CLOCK      ;   // PID logic runs at 200MHz.
  wire PREDICTOR_REG_CLOCK  = SYSTEM_CLOCK           ;   // Predictor register access aligns with PID register access and system clock
  //wire PREDICTOR_LOGIC_CLOCK= LOCKED_PLL_CLOCK_200   ;   // Predictor logic, for now, runs slower, due to glitches in its purely combinatorial logic
  wire PREDICTOR_LOGIC_CLOCK= FAST_SYSTEM_CLOCK      ;   // Predictor logic, for now, runs slower, due to glitches in its purely combinatorial logic
  //wire ANALOG_CLOCK         = LOCKED_PLL_CLOCK_100   ;   // Analog clock, mostly due to ADC constraints.
  wire ANALOG_CLOCK         = LOCKED_PLL_CLOCK_50    ;   // Analog clock, mostly due to ADC constraints.
  wire SYSTEM_RESET         = ~hps_cold_reset        ;
  
  wire ADC_ANALOG_CLOCK ;
  wire DAC_ANALOG_CLOCK ;

  assign ADC_ANALOG_CLOCK = (SW[9] == 1'b0  ?  ANALOG_CLOCK : ~ANALOG_CLOCK) ;
  assign DAC_ANALOG_CLOCK = (SW[8] == 1'b0  ?  ANALOG_CLOCK : ~ANALOG_CLOCK) ;


  //
  // Predcitor registers #2 (reusing space which was reserved for original pid H/W)
  //
  wire   [15:0] pid_predictor2_hw_regs_cs = 16'hffff;
  wire          pid_predictor2_hw_regs_read = 0;
  reg           pid_predictor2_hw_regs_write;
  reg    [31:0] pid_predictor2_cs_counter;  // to simulate chp select - do this every few cycles.
  
  
  wire   [31:0] pid_predctor_o_pre_dither_manual_value  ;
  wire   [31:0] pid_predctor_i_pre_dither_manual_value  ;

  wire   [31:0] pid_predictor2_hw_regs_i_dither_config_1;  
  wire   [31:0] pid_predictor2_hw_regs_i_dither_config_2;  
  wire   [31:0] pid_predictor2_hw_regs_i_dither_config_3;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_3       ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_4       ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_5       ;  
  wire   [31:0] pid_predictor2_hw_regs_i_2nd_out_offset ;  
  wire   [31:0] pid_predictor2_hw_regs_i_2nd_config     ;  
  wire   [31:0] pid_predictor2_hw_regs_i_3rd_config     ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_9       ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_10      ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_11      ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_12      ;  
  wire   [31:0] pid_predictor2_hw_regs_i_2nd_output_set ;
  wire   [31:0] pid_predictor2_hw_regs_i_manual_dac_output
                                                        ;  
  wire   [31:0] pid_predictor2_hw_regs_i_unused_15      ;  

  wire   [31:0] pid_predictor2_hw_regs_o_dither_config_1;  
  wire   [31:0] pid_predictor2_hw_regs_o_dither_config_2;  
  wire   [31:0] pid_predictor2_hw_regs_o_dither_config_3;  
  wire   [31:0] pid_predictor2_hw_regs_o_dither_count_1 ;  
  wire   [31:0] pid_predictor2_hw_regs_o_dither_count_2 ;  
  wire   [31:0] pid_predictor2_hw_regs_o_dither_count_3 ;  
  wire   [31:0] pid_predictor2_hw_regs_o_2nd_out_offset ;  
  wire   [31:0] pid_predictor2_hw_regs_o_2nd_config     ;  
  wire   [31:0] pid_predictor2_hw_regs_o_3rd_config     ;  
  wire   [31:0] pid_predictor2_hw_regs_o_unused_9       ;  
  wire   [31:0] pid_predictor2_hw_regs_o_unused_10      ;  
  wire   [31:0] pid_predictor2_hw_regs_o_unused_11      ;  
  wire   [31:0] pid_predictor2_hw_regs_o_unused_12      ;  
  wire   [31:0] pid_predictor2_hw_regs_o_2nd_output     ;  
  wire   [31:0] pid_predictor2_hw_regs_o_debug_reg_1    ;
  wire   [31:0] pid_predictor2_hw_regs_o_manual_dac_output
                                                        ;  
  wire   [31:0] pid_predictor2_hw_regs_o_unused_15      ;  

   //
   // PID Predictor inputs and outputs
   //
   wire   [31:0]  pid_predictor_hw_i_sw_yn          ; 
   wire   [31:0]  pid_predictor_hw_i_q0_q4          ; 
   wire   [31:0]  pid_predictor_hw_i_q1_q5          ; 
   wire   [31:0]  pid_predictor_hw_i_q2_q6          ; 
   wire   [31:0]  pid_predictor_hw_i_q3_q7          ; 
   wire   [31:0]  pid_predictor_hw_i_config         ; 
   wire   [31:0]  pid_predictor_hw_i_out_offset     ; 
   wire   [31:0]  pid_predictor_hw_i_y_reference    ; 
   wire   [31:0]  pid_predictor_hw_i_i0             ; 
   wire   [31:0]  pid_predictor_hw_i_delay_count    ; 


   wire   [31:0]  pid_predictor_hw_o_y_n     ; 
   wire   [31:0]  pid_predictor2_hw_o_y_n_1  ; 
   wire   [31:0]  pid_predictor2_hw_o_y_n_2  ; 
   wire   [31:0]  pid_predictor_hw_o_y_n_3   ; 
   wire   [31:0]  pid_predictor2_hw_o_y_n_4  ;  
   wire   [31:0]  pid_predictor2_hw_o_y_n_5  ;
   wire   [31:0]  pid_predictor2_hw_o_y_n_6  ;
   wire   [31:0]  pid_predictor2_hw_o_y_n_7  ;
   wire   [31:0]  pid_predictor_hw_o_integral_sum
                                             ; 
   wire   [31:0]  pid_predictor_hw_o_q0_q4; 
   wire   [31:0]  pid_predictor_hw_o_q1_q5; 
   wire   [31:0]  pid_predictor_hw_o_q2_q6; 
   wire   [31:0]  pid_predictor_hw_o_q3_q7; 

   wire   [31:0]  pid_predictor_hw_o_config ; 
   wire   [31:0]  pid_predictor_hw_o_magic  ; 
   wire   [31:0]  pid_predictor_hw_o_count  ; 
   wire   [31:0]  pid_predictor_hw_o_z_n    ; 
   wire   [31:0]  pid_predictor_hw_o_y_reference    ; 
   wire   [31:0]  pid_predictor_hw_o_i0             ; 

   wire           pid_predictor_hw_o_continuous ;
   wire   [31:0]  pid_predictor_hw_o_delay_count    ; 

   wire   [31:0]  pid_predictor_hw_o_out_offset; 

   wire   [31:0]  pid_predictor_hw_o_z_n_no_integral;
   wire   [31:0]  pid_predictor_hw_o_y_input        ;

   reg    [31:0]  debug_output_dacb_config   ;
   wire   [31:0]  debug_output_dacb          ;


   reg            pid_predictor_hw_write;
   wire           pid_predictor_hw_read= 0;
   wire   [15:0]  pid_predictor_hw_chipselect = 16'hffff;
   wire   [31:0]  pid_predictor_hw_o_delay_counter;
   wire   [31:0]  pid_predictor_hw_o_dither_input_polarity_shifted;
   wire   [31:0]  pid_predictor_hw_o_dither_input_state           ;
   wire   [31:0]  pid_predictor_hw_o_dither_input_counter         ;

	wire   [31:0] pid_o_current_sum_before_rebase;
	wire   [31:0] pid_o_total_sum_high;
	wire   [31:0] pid_o_total_sum_low;
	wire   [31:0] pid_o_dac_output;
  wire   [31:0] pid_o_test_1;
  wire   [31:0] pid_o_test_2;
  wire   [31:0] pid_o_test_3;
  wire   [31:0] pid_o_test_4;
  wire   [31:0] pid_o_test_5;
  wire   [31:0] pid_o_test_6;
  wire   [31:0] pid_o_test_7;
  wire   [31:0] pid_o_test_8;
  wire   [31:0] pid_o_test_9;
  wire   [31:0] pid_o_test_10;
  wire   [31:0] pid_o_test_11;
  wire   [31:0] pid_o_test_12;
  wire   [31:0] pid_o_test_13;
  wire   [31:0] pid_o_test_14;
  wire   [31:0] pid_o_test_15;
  wire   [31:0] pid_o_test_16;
  wire   [15:0] soc_system_recorder_i3_cs        ;
  wire          soc_system_recorder_i3_write      ;
  wire          soc_system_recorder_i3_read       ;
  wire   [31:0] soc_system_recorder_i3_data_in   ;
  wire   [31:0] soc_system_recorder_o3_data_out  ;
  wire   [31:0] soc_system_recorder_o3_status    ;
  //
  // Recorder (i3 bus) signals.
  // i3_cs[0] write : {[8]=enable, [7:4]=rec_index_B, [3:0]=rec_index_A}
  // i3_cs[1] write : [9:0] = rec_read_addr
  // i3_cs[2] write : [31:0] = rec_interval  (1=every tick, N=every Nth tick)
  // i3_cs[3] read  : buf_A[rec_read_addr]
  // i3_cs[4] read  : buf_B[rec_read_addr]
  // i3_cs[5] read  : {21'b0, rec_counter[9:0], rec_enable}
  //
  // NOTE: connect these to soc_system PIO ports when the Qsys/Platform Designer
  //       project is updated.  Until then they are stubbed out below.
  //
  wire   [15:0] pid_recorder_i3_cs        ;
  wire          pid_recorder_i3_write      ;
  wire          pid_recorder_i3_read       ;
  wire   [31:0] pid_recorder_i3_data_in   ;
  wire   [31:0] pid_recorder_o3_data_out  ;
  wire   [31:0] pid_recorder_o3_status    ;

  assign pid_recorder_i3_cs      = soc_system_recorder_i3_cs;
  assign pid_recorder_i3_write   = soc_system_recorder_i3_write;
  assign pid_recorder_i3_read    = soc_system_recorder_i3_read;
  assign pid_recorder_i3_data_in = soc_system_recorder_i3_data_in;
  assign soc_system_recorder_o3_data_out = pid_recorder_o3_data_out;
  assign soc_system_recorder_o3_status   = pid_recorder_o3_status;
	
  wire   [13:0] cpu_dac_a_output ;
  wire   [13:0] cpu_dac_b_output ; 
  wire   LOCKED_CLOCK_200     ;

  reg  [31:0] pid_top_counter;


  reg  [15:0] dac_a_copy;
  reg  [15:0] dac_b_copy;


// connection of internal logics
  assign stm_hw_events    = {{3{1'b0}},SW, fpga_led_internal, fpga_debounced_buttons};

  
////  pll  pll_200mhz
////  (
////    .refclk(CLOCK_50),
////    .rst(hps_cold_reset),
////    .outclk_0(CLOCK_200),
////    .locked(CLOCK_200_LOCKED)
////  );
  
    pll_main pll_main
    (
      .refclk(PLL_CLOCK_SOURCE),
      .rst(hps_cold_reset),
      .outclk_0(PLL_CLOCK_200),
      .outclk_1(PLL_CLOCK_100),
      .outclk_2(PLL_CLOCK_50),
      .locked(PLL_LOCKED)
     );

//  fast_pll fast_pll
//  (
//    .refclk(PLL_CLOCK_SOURCE),
//    .rst(hps_cold_reset),
//    .outclk_4(PLL_CLOCK_400),
//    .outclk_3(PLL_CLOCK_300),
//    .outclk_2(PLL_CLOCK_200),
//    .outclk_1(PLL_CLOCK_100),
//    .outclk_0(PLL_CLOCK_50),
//    .locked(PLL_LOCKED)
//   );

  
 
   assign  LOCKED_PLL_CLOCK_400 = PLL_CLOCK_200  && PLL_LOCKED ;
   assign  LOCKED_PLL_CLOCK_300 = PLL_CLOCK_200  && PLL_LOCKED ;
   assign  LOCKED_PLL_CLOCK_200 = PLL_CLOCK_200  && PLL_LOCKED ;
   assign  LOCKED_PLL_CLOCK_100 = PLL_CLOCK_100  && PLL_LOCKED ;
   assign  LOCKED_PLL_CLOCK_50  = PLL_CLOCK_50   && PLL_LOCKED ;

   assign  GPIO_034             = SYSTEM_CLOCK;


    soc_system u0 (
        .memory_mem_a                          ( HPS_DDR3_ADDR),                          //          memory.mem_a
        .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
        .memory_mem_ck                         ( HPS_DDR3_CK_P),                         //                .mem_ck
        .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
        .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
        .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
        .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
        .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
        .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
        .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
        .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
        .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                        //                .mem_dqs
        .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
        .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
        .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
        .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                      //                .oct_rzqin
       		
	    .hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK), //                   hps_0_hps_io.hps_io_emac1_inst_TX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //                               .hps_io_emac1_inst_TXD0
        .hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //                               .hps_io_emac1_inst_TXD1
        .hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //                               .hps_io_emac1_inst_TXD2
        .hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //                               .hps_io_emac1_inst_TXD3
        .hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //                               .hps_io_emac1_inst_RXD0
        .hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),   //                               .hps_io_emac1_inst_MDIO
        .hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC  ),    //                               .hps_io_emac1_inst_MDC
        .hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV), //                               .hps_io_emac1_inst_RX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN), //                               .hps_io_emac1_inst_TX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK), //                               .hps_io_emac1_inst_RX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //                               .hps_io_emac1_inst_RXD1
        .hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //                               .hps_io_emac1_inst_RXD2
        .hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //                               .hps_io_emac1_inst_RXD3
        
		  
		.hps_0_hps_io_hps_io_qspi_inst_IO0     ( HPS_FLASH_DATA[0]    ),     //                               .hps_io_qspi_inst_IO0
        .hps_0_hps_io_hps_io_qspi_inst_IO1     ( HPS_FLASH_DATA[1]    ),     //                               .hps_io_qspi_inst_IO1
        .hps_0_hps_io_hps_io_qspi_inst_IO2     ( HPS_FLASH_DATA[2]    ),     //                               .hps_io_qspi_inst_IO2
        .hps_0_hps_io_hps_io_qspi_inst_IO3     ( HPS_FLASH_DATA[3]    ),     //                               .hps_io_qspi_inst_IO3
        .hps_0_hps_io_hps_io_qspi_inst_SS0     ( HPS_FLASH_NCSO    ),     //                               .hps_io_qspi_inst_SS0
        .hps_0_hps_io_hps_io_qspi_inst_CLK     ( HPS_FLASH_DCLK    ),     //                               .hps_io_qspi_inst_CLK
        
		.hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD    ),     //                               .hps_io_sdio_inst_CMD
        .hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
        .hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
        .hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK   ),     //                               .hps_io_sdio_inst_CLK
        .hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
        .hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
        		  
		.hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
        .hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
        .hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
        .hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
        .hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
        .hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
        .hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
        .hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
        .hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT    ),     //                               .hps_io_usb1_inst_CLK
        .hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP    ),     //                               .hps_io_usb1_inst_STP
        .hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR    ),     //                               .hps_io_usb1_inst_DIR
        .hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT    ),     //                               .hps_io_usb1_inst_NXT
        		  
		.hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),    //                               .hps_io_spim1_inst_CLK
        .hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),   //                               .hps_io_spim1_inst_MOSI
        .hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),   //                               .hps_io_spim1_inst_MISO
        .hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS ),    //                               .hps_io_spim1_inst_SS0
      		
		.hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX    ),     //                               .hps_io_uart0_inst_RX
        .hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX    ),     //                               .hps_io_uart0_inst_TX
		
		.hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT    ),     //                               .hps_io_i2c0_inst_SDA
        .hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK    ),     //                               .hps_io_i2c0_inst_SCL
		
		.hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT    ),     //                               .hps_io_i2c1_inst_SDA
        .hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK    ),     //                               .hps_io_i2c1_inst_SCL
        
		.hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N),  //                               .hps_io_gpio_inst_GPIO09
        .hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N),  //                               .hps_io_gpio_inst_GPIO35
        .hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO),  //                               .hps_io_gpio_inst_GPIO40
        //.hps_0_hps_io_hps_io_gpio_inst_GPIO41  ( HPS_GPIO[1]),  //                               .hps_io_gpio_inst_GPIO41
        .hps_0_hps_io_hps_io_gpio_inst_GPIO48  ( HPS_I2C_CONTROL),  //                               .hps_io_gpio_inst_GPIO48
        .hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED),  //                               .hps_io_gpio_inst_GPIO53
        .hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY),  //                               .hps_io_gpio_inst_GPIO54
        .hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT),  //                               .hps_io_gpio_inst_GPIO61
		.hps_0_f2h_stm_hw_events_stm_hwevents  (stm_hw_events),   //        hps_0_f2h_stm_hw_events.stm_hwevents
        .clk_clk                               (SYSTEM_CLOCK),                               //                            clk.clk
        .reset_reset_n                         (hps_fpga_reset_n),                         //                          reset.reset_n
		.hps_0_h2f_cold_reset_reset_n               (hps_fpga_reset_n),               //                hps_0_h2f_reset.reset_n
        .hps_0_f2h_warm_reset_req_reset_n      (~hps_warm_reset),      //       hps_0_f2h_warm_reset_req.reset_n
        .hps_0_f2h_debug_reset_req_reset_n     (~hps_debug_reset),     //      hps_0_f2h_debug_reset_req.reset_n
        .hps_0_f2h_cold_reset_req_reset_n      (~hps_cold_reset),       //       hps_0_f2h_cold_reset_req.reset_n

        /* PIO's (registers) */
      .pid_o_y_n_external_connection_in_port(pid_predictor_hw_o_y_n)    ,
      .pid_o_y_n_external_connection_out_port(pid_predictor_hw_i_sw_yn)    ,
      .pid_live_counter_external_connection_export(pid_top_counter)    ,
      .pid_magic_external_connection_export(w_magic)    ,

      .pid_o_2nd_config_external_connection_out_port(pid_predictor2_hw_regs_i_2nd_config)    ,
      .pid_o_2nd_config_external_connection_in_port(pid_predictor2_hw_regs_o_2nd_config)    ,

      .pid_o_3rd_config_external_connection_in_port(pid_predictor2_hw_regs_o_3rd_config)    ,
      .pid_o_3rd_config_external_connection_out_port(pid_predictor2_hw_regs_i_3rd_config)    ,

      .pid_o_2nd_output_external_connection_in_port(pid_predictor2_hw_regs_o_2nd_output)    ,
      .pid_o_debug_reg_1_external_connection_export(pid_predictor2_hw_regs_o_debug_reg_1),

      .pid_o_config_external_connection_in_port(pid_predictor_hw_o_config)    ,
      .pid_o_config_external_connection_out_port(pid_predictor_hw_i_config)    ,
      .pid_o_count_external_connection_in_port(pid_predictor_hw_o_count)    ,
      // .pid_o_count_external_connection_out_port(),  // input only
      .pid_o_dacb_output_external_connection_in_port(debug_output_dacb_config)    ,
      .pid_o_dacb_output_external_connection_out_port(debug_output_dacb)    ,
      .pid_o_delay_count_external_connection_in_port(pid_predictor_hw_o_delay_count)    ,
      .pid_o_delay_count_external_connection_out_port(pid_predictor_hw_i_delay_count)    ,
      .pid_o_delay_counter_external_connection_in_port(pid_predictor_hw_o_delay_counter)    ,
      // .pid_o_delay_counter_external_connection_out_port()    , // input only
      .pid_o_dither_config_1_external_connection_in_port(pid_predictor2_hw_regs_o_dither_config_1)    ,
      .pid_o_dither_config_1_external_connection_out_port(pid_predictor2_hw_regs_i_dither_config_1)    ,
      .pid_o_dither_config_2_external_connection_in_port(pid_predictor2_hw_regs_o_dither_config_2)    ,
      .pid_o_dither_config_2_external_connection_out_port(pid_predictor2_hw_regs_i_dither_config_2)    ,
      .pid_o_dither_config_3_external_connection_in_port(pid_predictor2_hw_regs_o_dither_config_3)    ,
      .pid_o_dither_config_3_external_connection_out_port(pid_predictor2_hw_regs_i_dither_config_3)    ,
      .pid_o_dither_count_1_external_connection_in_port(pid_predictor2_hw_regs_o_dither_count_1)    ,
      .pid_o_dither_count_1_external_connection_out_port(pid_predictor2_hw_regs_i_unused_3)    , 
      .pid_o_dither_count_2_external_connection_in_port(pid_predictor2_hw_regs_o_dither_count_2)    ,
      .pid_o_dither_count_2_external_connection_out_port(pid_predictor2_hw_regs_i_unused_4)    ,  
      .pid_o_dither_count_3_external_connection_in_port(pid_predictor2_hw_regs_o_dither_count_3)    ,
      .pid_o_dither_count_3_external_connection_out_port(pid_predictor2_hw_regs_i_unused_5),
      .pid_o_i0_external_connection_in_port(pid_predictor_hw_o_i0)    ,
      .pid_o_i0_external_connection_out_port(pid_predictor_hw_i_i0)    ,
      .pid_o_magic_external_connection_in_port(pid_predictor_hw_o_magic)    ,
      // .pid_o_magic_external_connection_out_port()    , // input only
      .pid_o_manual_dac_output_external_connection_in_port(pid_predictor2_hw_regs_o_manual_dac_output)    ,
      .pid_o_manual_dac_output_external_connection_out_port(pid_predictor2_hw_regs_i_manual_dac_output)    ,
      .pid_o_out_offset_external_connection_in_port(pid_predictor_hw_o_out_offset)    ,
      .pid_o_out_offset_external_connection_out_port(pid_predictor_hw_i_out_offset)    ,
      .pid_o_q0_q4_external_connection_in_port(pid_predictor_hw_o_q0_q4)    ,
      .pid_o_q0_q4_external_connection_out_port(pid_predictor_hw_i_q0_q4)    ,
      .pid_o_q1_q5_external_connection_in_port(pid_predictor_hw_o_q1_q5)    ,
      .pid_o_q1_q5_external_connection_out_port(pid_predictor_hw_i_q1_q5)    ,
      .pid_o_q2_q6_external_connection_in_port(pid_predictor_hw_o_q2_q6)    ,
      .pid_o_q2_q6_external_connection_out_port(pid_predictor_hw_i_q2_q6)    ,
      .pid_o_q3_q7_external_connection_in_port(pid_predictor_hw_o_q3_q7)    ,
      .pid_o_q3_q7_external_connection_out_port(pid_predictor_hw_i_q3_q7)    ,
      .pid_o_y_input_external_connection_in_port(pid_predictor_hw_o_y_input)    ,
      .pid_o_y_input_external_connection_out_port(pid_predictor2_hw_regs_i_unused_15)    ,
      .pid_o_y_n_3_external_connection_in_port(pid_predictor_hw_o_y_n_3)    ,
      // .pid_o_y_n_3_external_connection_out_port()    , // input only
      .pid_o_y_n_4_external_connection_in_port(pid_predictor2_hw_o_y_n_4)    ,
      .pid_o_y_n_4_external_connection_out_port(pid_predictor2_hw_regs_i_unused_9)    ,
      .pid_o_y_n_5_external_connection_in_port(pid_predictor2_hw_o_y_n_5)    ,
      .pid_o_y_n_5_external_connection_out_port(pid_predictor2_hw_regs_i_unused_10)    ,
      .pid_o_y_n_6_external_connection_in_port(pid_predictor2_hw_o_y_n_6)    ,
      .pid_o_y_n_6_external_connection_out_port(pid_predictor2_hw_regs_i_unused_11)    ,
      .pid_o_y_n_7_external_connection_in_port(pid_predictor2_hw_o_y_n_7)    ,
      .pid_o_y_n_7_external_connection_out_port(pid_predictor2_hw_regs_i_unused_12)    ,
      .pid_o_y_reference_external_connection_in_port(pid_predictor_hw_o_y_reference)    ,
      .pid_o_y_reference_external_connection_out_port(pid_predictor_hw_i_y_reference)    ,
      .pid_o_z_n_external_connection_in_port(pid_predictor_hw_o_z_n)    ,
      .pid_o_dac_a_external_connection_in_port(dac_a_copy)    ,
      .pid_o_dac_b_external_connection_in_port(dac_b_copy)    ,
      //.pid_o_z_n_external_connection_out_port()    , // input only
      .pid_version_external_connection_export(w_version),
      .pid_o_pre_dither_manual_value_external_connection_in_port(pid_predctor_o_pre_dither_manual_value),
      .pid_o_pre_dither_manual_value_external_connection_out_port(pid_predctor_i_pre_dither_manual_value),

		
		
		  .pid_o_current_sum_before_rebase_external_connection_in_port  (pid_o_current_sum_before_rebase),  // pid_o_current_sum_before_rebase_external_connection.in_port
        .pid_o_current_total_sum_high_external_connection_in_port     (pid_o_total_sum_high),     //    pid_o_current_total_sum_high_external_connection.in_port
        .pid_o_current_total_sum_low_external_connection_in_port      (pid_o_total_sum_low),      //     pid_o_current_total_sum_low_external_connection.in_port

        .pid_o_dac_output_external_connection_in_port                 (pid_o_dac_output),
        .pid_o_test_1_external_connection_out_port                 (pid_i_test_1),
        .pid_o_test_2_external_connection_out_port                 (pid_i_test_2),
        .pid_o_test_3_external_connection_out_port                 (pid_i_test_3),
        .pid_o_test_4_external_connection_out_port                 (pid_i_test_4),
        .pid_o_test_5_external_connection_out_port                 (pid_i_test_5),
        .pid_o_test_6_external_connection_out_port                 (pid_i_test_6),
        .pid_o_test_7_external_connection_out_port                 (pid_i_test_7),
        .pid_o_test_8_external_connection_out_port                 (pid_i_test_8),
        .pid_o_test_9_external_connection_out_port                 (pid_i_test_9),
        .pid_o_test_10_external_connection_out_port                 (pid_i_test_10),
        .pid_o_test_11_external_connection_out_port                 (pid_i_test_11),
        .pid_o_test_12_external_connection_out_port                 (pid_i_test_12),
        .pid_o_test_13_external_connection_out_port                 (pid_i_test_13),
        .pid_o_test_14_external_connection_out_port                 (pid_i_test_14),
        .pid_o_test_15_external_connection_out_port                 (pid_i_test_15),
        .pid_o_test_16_external_connection_out_port                 (pid_i_test_16),
        .pid_o_test_1_external_connection_in_port                 (pid_o_test_1),
        .pid_o_test_2_external_connection_in_port                 (pid_o_test_2),
        .pid_o_test_3_external_connection_in_port                 (pid_o_test_3),
        .pid_o_test_4_external_connection_in_port                 (pid_o_test_4),
        .pid_o_test_5_external_connection_in_port                 (pid_o_test_5),
        .pid_o_test_6_external_connection_in_port                 (pid_o_test_6),
        .pid_o_test_7_external_connection_in_port                 (pid_o_test_7),
        .pid_o_test_8_external_connection_in_port                 (pid_o_test_8),
        .pid_o_test_9_external_connection_in_port                 (pid_o_test_9),
        .pid_o_test_10_external_connection_in_port                 (pid_o_test_10),
        .pid_o_test_11_external_connection_in_port                 (pid_o_test_11),
        .pid_o_test_12_external_connection_in_port                 (pid_o_test_12),
        .pid_o_test_13_external_connection_in_port                 (pid_o_test_13),
        .pid_o_test_14_external_connection_in_port                 (pid_o_test_14),
        .pid_o_test_15_external_connection_in_port                 (pid_o_test_15),
        .pid_o_test_16_external_connection_in_port                 (pid_o_test_16),		  
			  .recorder_i3_cs_external_connection_export          (soc_system_recorder_i3_cs),
	      .recorder_i3_write_external_connection_export          (soc_system_recorder_i3_write),
	      .recorder_i3_read_external_connection_export          (soc_system_recorder_i3_read),
	      .recorder_i3_data_in_external_connection_export          (soc_system_recorder_i3_data_in),
	      .recorder_o3_data_out_external_connection_export          (soc_system_recorder_o3_data_out),
	      .recorder_o3_status_external_connection_export          (soc_system_recorder_o3_status)
    );
  
// Source/Probe megawizard instance
hps_reset hps_reset_inst (
  .source_clk (BOARD_CLOCK),
  .source     (hps_reset_req)
);

altera_edge_detector pulse_cold_reset (
  .clk       (BOARD_CLOCK),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[0]),
  .pulse_out (hps_cold_reset)
);
  defparam pulse_cold_reset.PULSE_EXT = 6;
  defparam pulse_cold_reset.EDGE_TYPE = 1;
  defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
  .clk       (BOARD_CLOCK),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[1]),
  .pulse_out (hps_warm_reset)
);
  defparam pulse_warm_reset.PULSE_EXT = 2;
  defparam pulse_warm_reset.EDGE_TYPE = 1;
  defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;
  
altera_edge_detector pulse_debug_reset (
  .clk       (BOARD_CLOCK),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[2]),
  .pulse_out (hps_debug_reset)
);
  defparam pulse_debug_reset.PULSE_EXT = 32;
  defparam pulse_debug_reset.EDGE_TYPE = 1;
  defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;


assign  DAC_CLK_B = DAC_ANALOG_CLOCK & SW[5];
assign  DAC_CLK_A = DAC_ANALOG_CLOCK & SW[4]; 	    //PLL Clock to DAC_A
 
assign  ADC_CLK_B = ADC_ANALOG_CLOCK & SW[3];  	    //PLL Clock to ADC_B
assign  ADC_CLK_A = ADC_ANALOG_CLOCK & SW[2];  	    //PLL Clock to ADC_A

assign  ADC_OEB_A = SW[0];  // Output Enable for ADC_A
assign  ADC_OEB_B = SW[1];  // Output Enable for ADC_B

assign LEDR[5:0] = {SW[5:0]};

assign LEDR[9:6] = {SW[9:6]};

assign POWER_ON = 1;
  

assign DAC_MODE = 1 ;  // DAC in dual port mode, and not single port interleaved mode.
assign DAC_WRT_A = DAC_CLK_A ;
assign DAC_WRT_B = DAC_CLK_B ;

                
assign DAC_DB = (    (debug_output_dacb_config[ 0] == 1'b1) ?   ADC_DA
                 : ( (debug_output_dacb_config[ 1] == 1'b1) ?   14'h2000 
                 : ( (debug_output_dacb_config[ 2] == 1'b1) ?   pid_predictor_hw_o_y_n                  [13: 0] 
                 : ( (debug_output_dacb_config[ 3] == 1'b1) ?   pid_predictor2_hw_o_y_n_1               [13: 0] 
                 : ( (debug_output_dacb_config[ 4] == 1'b1) ?   pid_predictor2_hw_o_y_n_2               [13: 0] 
                 : ( (debug_output_dacb_config[ 5] == 1'b1) ?   pid_predictor_hw_o_y_n_3                [13: 0] 
                 : ( (debug_output_dacb_config[ 6] == 1'b1) ?   pid_predictor2_hw_o_y_n_4               [13: 0] 
                 : ( (debug_output_dacb_config[ 7] == 1'b1) ?   pid_predictor_hw_o_z_n                  [13: 0] 
                 : ( (debug_output_dacb_config[ 8] == 1'b1) ?   pid_predictor2_hw_o_y_n_5               [13: 0] 
                 : ( (debug_output_dacb_config[ 9] == 1'b1) ?   pid_predictor_hw_o_count                [13: 0] 
                 : ( (debug_output_dacb_config[10] == 1'b1) ?   pid_predictor2_hw_o_y_n_6               [13: 0] 
                 : ( (debug_output_dacb_config[11] == 1'b1) ?   pid_predictor2_hw_o_y_n_7               [13: 0]
                 : ( (debug_output_dacb_config[12] == 1'b1) ?   pid_predictor_hw_o_dither_input_counter [13:0] 
                 : ( (debug_output_dacb_config[13] == 1'b1) ?   pid_predictor_hw_o_z_n_no_integral      [13:0] 
                 : ( (debug_output_dacb_config[14] == 1'b1) ?   pid_predictor_hw_o_y_input              [13:0] 
                 : ( (debug_output_dacb_config[15] == 1'b1) ?   pid_predictor_hw_o_integral_sum         [13:0]
                 : ( (debug_output_dacb_config[16] == 1'b1) ?   pid_predictor2_hw_regs_o_2nd_output     [13:0]
                 : ( (debug_output_dacb_config[17] == 1'b1) ?   14'b0
                 :   14'b0
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 )
                 ;
                     


//assign DAC_DA = pid_predictor2_hw_regs_o_2nd_output[13:0] ;
assign DAC_DA = pid_predictor_hw_o_z_n[13:0] ;

predictor  pid_6_predictor (
        .reg_clk    ( PREDICTOR_REG_CLOCK           ),  // Clock by which predictor logic registers are read/modified
        .logic_clk  ( PREDICTOR_LOGIC_CLOCK         ),  // Clock by which predictor logic runs
        .adc_clk    ( ADC_ANALOG_CLOCK              ),  // Clock which is used to sample the ADC 
        .rst        ( ~hps_cold_reset               ),
        .i_cs       ( pid_predictor_hw_chipselect   ),
        .i_read     ( pid_predictor_hw_read         ),
        .i_write    ( pid_predictor_hw_write        ),
        .i_sw_yn    ( pid_predictor_hw_i_sw_yn      ),
        .i_yn1      ( {16'b0, 2'b0, ADC_DA}         ),
        .i_yn2      ( {16'b0, 2'b0, ADC_DB}         ),
        .i_q0_q4    ( pid_predictor_hw_i_q0_q4      ),
        .i_q1_q5    ( pid_predictor_hw_i_q1_q5      ),
        .i_q2_q6    ( pid_predictor_hw_i_q2_q6      ),
        .i_q3_q7    ( pid_predictor_hw_i_q3_q7      ),
        .i_config   ( pid_predictor_hw_i_config     ),
        .i_out_offset
                    ( pid_predictor_hw_i_out_offset ),
        .i_i0       ( pid_predictor_hw_i_i0         ),
        .i_y_reference
                    ( pid_predictor_hw_i_y_reference),

        .i2_cs      ( pid_predictor2_hw_regs_cs    ),
        .i2_read    ( pid_predictor2_hw_regs_read  ),
        .i2_write   ( pid_predictor2_hw_regs_write ),
        .i2_dither_config_1
                    ( pid_predictor2_hw_regs_i_dither_config_1),
        .i2_dither_config_2
                    ( pid_predictor2_hw_regs_i_dither_config_2),
        .i2_dither_config_3
                    ( pid_predictor2_hw_regs_i_dither_config_3),
        .o_y_n         ( pid_predictor_hw_o_y_n          ), 
        .o2_y_n_1      ( pid_predictor2_hw_o_y_n_1       ), 
        .o2_y_n_2      ( pid_predictor2_hw_o_y_n_2       ), 
        .o_y_n_3       ( pid_predictor_hw_o_y_n_3        ), 
        .o2_y_n_4      ( pid_predictor2_hw_o_y_n_4       ),         
        .o2_y_n_5      ( pid_predictor2_hw_o_y_n_5       ),
        .o2_y_n_6      ( pid_predictor2_hw_o_y_n_6       ),
        .o2_y_n_7      ( pid_predictor2_hw_o_y_n_7       ),

        .o_q0_q4       ( pid_predictor_hw_o_q0_q4        ),
        .o_q1_q5       ( pid_predictor_hw_o_q1_q5        ),
        .o_q2_q6       ( pid_predictor_hw_o_q2_q6        ),
        .o_q3_q7       ( pid_predictor_hw_o_q3_q7        ),
        .o_config      ( pid_predictor_hw_o_config       ), 
        .o_magic       ( pid_predictor_hw_o_magic        ),
        .o_count       ( pid_predictor_hw_o_count        ),
        .o_z_n         ( pid_predictor_hw_o_z_n          ),
        .o_out_offset  ( pid_predictor_hw_o_out_offset   ),
        .o_continuous  ( pid_predictor_hw_o_continuous   ),
        .o_y_reference ( pid_predictor_hw_o_y_reference  ),
        .o_i0          ( pid_predictor_hw_o_i0           ),
        .o_integral_sum( pid_predictor_hw_o_integral_sum ),
        .o_z_n_no_integral
                       ( pid_predictor_hw_o_z_n_no_integral
                                                         ),
        .o_y_input     ( pid_predictor_hw_o_y_input      ),


        .i_delay_count  ( pid_predictor_hw_i_delay_count ),
        .o_delay_count  ( pid_predictor_hw_o_delay_count ),
        .o_delay_counter( pid_predictor_hw_o_delay_counter),
        .o2_dither_config_1
                    ( pid_predictor2_hw_regs_o_dither_config_1),
        .o2_dither_config_2
                    ( pid_predictor2_hw_regs_o_dither_config_2),
        .o2_dither_config_3
                    ( pid_predictor2_hw_regs_o_dither_config_3),
        .o2_dither_count_1
                    ( pid_predictor2_hw_regs_o_dither_count_1 ),
        .o2_dither_count_2
                    ( pid_predictor2_hw_regs_o_dither_count_2 ),
        .o2_dither_count_3
                    ( pid_predictor2_hw_regs_o_dither_count_3 ),


        .i2_2nd_out_offset(pid_predictor2_hw_regs_i_2nd_out_offset),
        .i2_2nd_config    (pid_predictor2_hw_regs_i_2nd_config    ),
        .i2_3rd_config    (pid_predictor2_hw_regs_i_3rd_config    ),
        .i2_2nd_output_set(pid_predictor2_hw_regs_i_2nd_output_set),


        .o2_2nd_out_offset(pid_predictor2_hw_regs_o_2nd_out_offset),
        .o2_2nd_config    (pid_predictor2_hw_regs_o_2nd_config    ),
        .o2_3rd_config    (pid_predictor2_hw_regs_o_3rd_config    ),
        .o_2nd_integral   (pid_predictor2_hw_regs_o_2nd_output    ), 
        .o_debug_reg1     (pid_predictor2_hw_regs_o_debug_reg_1   ),

        .o_dither_input_polarity_shifted( pid_predictor_hw_o_dither_input_polarity_shifted),  
        .o_dither_input_state           ( pid_predictor_hw_o_dither_input_state           ),
        .o_dither_input_counter         ( pid_predictor_hw_o_dither_input_counter         ),
        .i2_manual_dac_output           ( pid_predictor2_hw_regs_i_manual_dac_output      ),
        .o2_manual_dac_output           ( pid_predictor2_hw_regs_o_manual_dac_output      ),
        .i_pre_dither_manual_value(pid_predctor_i_pre_dither_manual_value),
        .o_pre_dither_manual_value(pid_predctor_o_pre_dither_manual_value),
		  
			.o_current_sum_before_rebase(pid_o_current_sum_before_rebase),
			.o_current_total_sum_high(pid_o_total_sum_high),
		   .o_current_total_sum_low(pid_o_total_sum_low),
			.o_dac_output(pid_o_dac_output),
      .i_test_1(pid_i_test_1),
      .i_test_2(pid_i_test_2),
      .i_test_3(pid_i_test_3),
      .i_test_4(pid_i_test_4),
      .i_test_5(pid_i_test_5),
      .i_test_6(pid_i_test_6),
      .i_test_7(pid_i_test_7),
      .i_test_8(pid_i_test_8),
      .i_test_9(pid_i_test_9),
      .i_test_10(pid_i_test_10),
      .i_test_11(pid_i_test_11),
      .i_test_12(pid_i_test_12),
      .i_test_13(pid_i_test_13),
      .i_test_14(pid_i_test_14),
      .i_test_15(pid_i_test_15),
      .i_test_16(pid_i_test_16),
      .o_test_1(pid_o_test_1),
      .o_test_2(pid_o_test_2),
      .o_test_3(pid_o_test_3),
      .o_test_4(pid_o_test_4),
      .o_test_5(pid_o_test_5),
      .o_test_6(pid_o_test_6),
      .o_test_7(pid_o_test_7),
      .o_test_8(pid_o_test_8),
      .o_test_9(pid_o_test_9),
      .o_test_10(pid_o_test_10),
      .o_test_11(pid_o_test_11),
      .o_test_12(pid_o_test_12),
      .o_test_13(pid_o_test_13),
      .o_test_14(pid_o_test_14),
      .o_test_15(pid_o_test_15),
      .o_test_16(pid_o_test_16),

        // ---- Recorder (i3 bus) ----
        .i3_cs       ( pid_recorder_i3_cs      ),
        .i3_write    ( pid_recorder_i3_write    ),
        .i3_read     ( pid_recorder_i3_read     ),
        .i3_data_in  ( pid_recorder_i3_data_in  ),
        .o3_data_out ( pid_recorder_o3_data_out ),
        .o3_recorder_status
                     ( pid_recorder_o3_status   )
);    



always@(posedge SYSTEM_CLOCK or negedge SYSTEM_RESET)
    if (!SYSTEM_RESET) begin
        debug_output_dacb_config  <= 32'b0;
        pid_top_counter <= 32'b0;
        dac_a_copy <= 16'b0;
        dac_b_copy <= 16'b0;
		  pid_predictor2_cs_counter <= 0;
    end
    else 
    begin
        pid_top_counter <= pid_top_counter + 1;
		  pid_predictor2_cs_counter <= pid_predictor2_cs_counter  + 1;
		  
      dac_a_copy <= DAC_DA;
      dac_b_copy <= DAC_DB;

		  if (pid_predictor2_cs_counter >= `PID_PREDICTOR2_CS_LIMIT)
		  begin
		     pid_predictor2_cs_counter <= 0;

			   pid_predictor_hw_write <= 1;
			   pid_predictor2_hw_regs_write <= 1;
			  
		  end
		  
      if (pid_predictor_hw_write)
      begin
          pid_predictor_hw_write <= 0;
          pid_predictor2_hw_regs_write  <= 0;
          if (pid_predictor_hw_chipselect[15])
          begin
              debug_output_dacb_config  <= debug_output_dacb ;
          end
      end
    end


 
endmodule

