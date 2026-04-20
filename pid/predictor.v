       /* 
        *
        *  Predictor:
        *
        *  *NOTE: 7-mar-2018 - even though this was an 8th order predictor, we
        *                      clammed it down to 6. Still, most 8th order
        *                      configuration (registers) exist. Just the usage
        *                      of the 6th and 7th order cofficients is not
        *                      made.
        *
        *
        * Note - we accumulate on every _2nd cycle_, in anticipating that the ADC clock = 1/2 sys clock (or logic clock).
        *
        */

`define    STATE_0A 12'b000000000000
`define    STATE_0B 12'b000000000001    //     0x1
`define    STATE_1  12'b000000000010    //     0x2
`define    STATE_2  12'b000000000100    //     0x4   
`define    STATE_3  12'b000000001000    //     0x8
`define    STATE_4  12'b000000010000    //     0x10
`define    STATE_5  12'b000000100000    //     0x20
`define    STATE_6  12'b000001000000    //     0x40


`define    INTERNAL_BIT_WIDTH       64
`define    INTERNAL_HIGH_ORDER_BIT  63


module predictor
(
    input   wire        reg_clk    ,  // clock from which S/W configurable registers are driven
    input   wire        logic_clk  ,  // clock which drives the logic (the "real" clock)
    input   wire        adc_clk    ,  // clock which drives the ADC.
                                      // We need this to ensure sampling is
                                      // correct.
    input   wire        rst        ,  // reset when high
    
    //
    //    inputs
    //
    input   wire [15:0] i_cs       ,  // Chip select
    input   wire        i_read     ,  // Read op?
    input   wire        i_write    ,  // Write op?

    input   wire [15:0] i2_cs      ,  // (#2 set of registers) Chip select
    input   wire        i2_read    ,  // (#2 set of registers) Read op?
    input   wire        i2_write   ,  // (#2 set of registers) Write op?

    input   wire [31:0] i2_dither_config_1,
    input   wire [31:0] i2_dither_config_2,
    input   wire [31:0] i2_dither_config_3,

    input   wire [31:0] i2_2nd_out_offset,
                                      // output offset of the 2nd integral
    input   wire [31:0] i2_2nd_config    ,                                      
                                      // configuration of the 2nd integration
                                      // output (and extra shift for the 1st
                                      // integration)
    input   wire [31:0] i2_3rd_config    ,                                      
                                      // 3rd configuration (i0_2nd factor)
    input   wire [31:0] i2_2nd_output_set,
                                      // in case 2nd integrator output is
                                      // enabled, but the integrator itself is
                                      // not enabled, the S/W may write the
                                      // actual value of the integrator.

    input   wire [31:0] i2_manual_dac_output
                                   ,

    input   wire [31:0] i_pre_dither_manual_value
                                   ,  // in case pre-dither manual override is enabled, this is the value
                                      // that is fed to the dither output (instead of the standard pid result).

    input   wire [31:0] i_sw_yn    ,  // sw y_n   = S/W version of y_n (non-continuous mode of operation).
    input   wire [31:0] i_yn1      ,  // y_n1     = 1st source of y_n (continuous mode only)
    input   wire [31:0] i_yn2      ,  // y_n2     = 2nd source of y_n (continuous mode only)
    input   wire [31:0] i_i0       ,  // i_0      = coefficient of the integration part
    input   wire [31:0] i_q0_q4    ,  // q_0, q_4 = coefficient of the signal itself (y_n = y_input - y_reference)
    input   wire [31:0] i_q1_q5    ,  // q_1, q_5 = coefficient of 1st derivative of y_n
    input   wire [31:0] i_q2_q6    ,  // q_2, q_6 = coefficient of 2nd derivative of y_n
    input   wire [31:0] i_q3_q7    ,  // q_3, q_7 = coefficient of 3rd derivative of y_n
                                      //  (coefficients q_6 and q_7 are not
                                      //  really used!)
    input   wire [31:0] i_config   ,  // S/W      = originated configuration (which includes optional reset signal).

                                      // Config bits:
                                      // bit[0] = S/W reset 
                                      // bit[1] = "1" ==> continuous mode (!!)
                                      //                  work sampling 
                                      //                  using either i_yn1
                                      //                  or i_yn2 (see below)
                                      //          "0" ==> S/W mode, work with
                                      //                  i_sw_yn
                                      //
                                      // bit[2] = continuous mode selector:
                                      //          "0" ==> y_n = i_yn1
                                      //                  (continous mode only!)
                                      //          "1" ==> y_n = i_yn2
                                      //
                                      // bit[3] = pre dither manual override
                                      //          "0" ==> standard input to dither output (= output of pid), the default.
                                      //          "1" ==> manual input to dither output (pre_dither_manual_value)
                                      //
                                      // bits[8:4] = output precision size
                                      //           = # bits from non-shifted 
                                      //             value which would be used
                                      //             to modulate the DAC
                                      //             output and obtain
                                      //             effective higher
                                      //             resolution DAC.
                                      //
                                      // bit[9]    = "1" ==> use aligned ADC
                                      //   <<<<<<< REMOVED >>>>>>>>>>>>>>
                                      //                     clock sample.
                                      //             "0" ==> use standard
                                      //                     input as-is.
                                      //
                                      // bit[10]   = "1" ==> use delay_count
                                      //                     to count
                                      //                     2 x number of
                                      //                     cycles before
                                      //                     doing the next
                                      //                     predictor
                                      //                     iteration. 
                                      //
                                      // bit[11]   = "1" ==> manual DAC output enable
                                      // bit[12]   = "1" ==> invery y_n
                                      // bit[13]   = "1" ==> invert final output
                                      // bit[14]   = "1" ==> output precision
                                      //                     enable
                                      // bit[15]   = "1" ==> input averager
                                      //                     enable
                                      // bits[21:16] = output shift = 
                                      //             specify how many bits to
                                      //             shift right the output
                                      //             (essentially divides the
                                      //              output by 2 raised this
                                      //              power).
                                      // bits[28:24] = output precision shift 
                                      //             = bit offset of the
                                      //               output precision value 
                                      //               taken to be used to
                                      //               modulate the output.
                                      // bit[29]   = "1" ==> y input difference enable.
                                      //                     this means that y_input = y_in2 - y_in1.
                                      // bit[30]   = "1" ==> 2nd integrator output enable.
                                      // bit[31]   = "1" ==> 2nd integrator enable.
                                      //
    input  wire  [31:0] i_out_offset , //              
    input  wire  [31:0] i_delay_count,
    input  wire  [31:0] i_y_reference,// Reference signal for y_n input.
                                      // This means that the actual signal is
                                      // y_n - y_reference

    //
    //    outputs
    //
    output  wire [31:0] o_y_n       ,  // 
    output  wire [31:0] o_y_n_3     ,  // 
    output  wire [31:0] o_q0_q4     ,  // [31:16] = q4, [15: 0] = q0
    output  wire [31:0] o_q1_q5     ,  // [31:16] = q5, [15: 0] = q1
    output  wire [31:0] o_q2_q6     ,  // [31:16] = q6, [15: 0] = q2
    output  wire [31:0] o_q3_q7     ,  // [31:16] = q7, [15: 0] = q3
    output  wire [31:0] o_config    ,  // A reflection of the current configuration
    
    output  wire [31:0] o_out_offset, //              
    output  wire [31:0] o_i0        ,
    output  wire [31:0] o_integral_sum
                                    ,

    output  wire [31:0] o_magic     ,  // magic = stam magic sequence to indicate validity...
    output  wire [31:0] o_count     ,  // count = # of times un has been calculated.
    output  wire [31:0] o_z_n       ,  // z_{n} = the predicted output
    output  wire [31:0] o_2nd_integral
                                   ,  // z_{n} = the predicted output
    output  wire [31:0] o_z_n_no_integral
                                   ,  // z_n as if integral_sum was not summed into it
    output  wire [31:0] o_y_reference,// Reference signal for y_n input.
    output  wire [31:0] o_y_input  ,  // Reference signal for y_n input.
    output  wire        o_continuous  // report to top whether we work in continous mode or not.
                                   ,
    output  wire [31:0] o_delay_count   ,
    output  wire [31:0] o_delay_counter ,
                           
    output   wire [31:0] o2_y_n_1     ,  
    output   wire [31:0] o2_y_n_2     ,  
    output   wire [31:0] o2_y_n_4     ,  // 
    output   wire [31:0] o2_y_n_5     ,  // 
    output   wire [31:0] o2_y_n_6     ,  // 
    output   wire [31:0] o2_y_n_7     ,  // 
    output   wire [31:0] o2_dither_config_1,
    output   wire [31:0] o2_dither_config_2,
    output   wire [31:0] o2_dither_config_3,
    output   wire [31:0] o2_dither_count_1,
    output   wire [31:0] o2_dither_count_2,
    output   wire [31:0] o2_dither_count_3,
    output   wire [31:0] o2_2nd_out_offset,
    output   wire [31:0] o2_2nd_config    ,                                      
    output   wire [31:0] o2_3rd_config    ,                                      
 
    //
    // For debugging input dithering
    //
    output   wire [31:0] o_dither_input_polarity_shifted,      
    output   wire [31:0] o_dither_input_state,      
    output   wire [31:0] o_dither_input_counter ,

    output   wire [31:0] o2_manual_dac_output,
    output   wire [31:0] o_pre_dither_manual_value,
	 
	 output   wire [31:0] o_current_sum_before_rebase,
	 output   wire [31:0] o_current_total_sum_high,
	 output   wire [31:0] o_current_total_sum_low,

    output   wire [31:0] o_debug_reg1,
    output   wire [31:0] o_dac_output
);


//
// Work registers (some of which are reflected to the bus)
//
reg   [31:0]    r0            ;    // Coefficient of y_n = y_input - y_reference
reg   [31:0]    r1            ;
reg   [31:0]    r2            ;
reg   [31:0]    r3            ;
reg   [31:0]    r4            ;    
reg   [31:0]    r5            ;
reg   [31:0]    r6            ;
reg   [31:0]    r7            ;
reg   [31:0]    i0            ;
reg   [31:0]    i0_2nd        ;    // Coefficient of the double integrator
reg   [31:0]    y_n           ;
reg   [31:0]    y_n_1         ;    
reg   [31:0]    y_n_2         ;    
reg   [31:0]    y_n_3         ;    
reg   [31:0]    y_n_4         ;    
reg   [31:0]    y_n_5         ;    
reg   [31:0]    y_n_6         ;    
reg   [31:0]    y_n_7         ;    

reg   [31:0]    save_y_n      ;
reg   [31:0]    save_y_n_1    ;
reg   [31:0]    save_y_n_2    ;
reg   [31:0]    save_y_n_3    ;
reg   [31:0]    save_y_n_4    ;
reg   [31:0]    save_y_n_5    ;
reg   [31:0]    save_y_n_6    ;

reg   [31:0]    out_offset    ;    
reg   [31:0]    out_offset_2nd;    
reg   [31:0]    out_offset_plus_dither_amplitude
                              ;   // Keep out_offset + dither_amplitude for timing
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    i0_y_n        ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    i0_y_n_shifted;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r0_y_n        ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r1_y_n_1      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r2_y_n_2      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r3_y_n_3      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r4_y_n_4      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r5_y_n_5      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r6_y_n_6      ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    r7_y_n_7      ;

reg   [31:0]    delay_count   ;   // Delay cycles = # of state machine cycles (in units of 2 cycles to remain even!)
                                  // after the predictor has finished,
                                  // before returning to the original state.
                                  // This allows working with much slower
                                  // signals and predicting them.

reg   [31:0]    delay_counter              ;                                    
reg   [31:0]    delay_counter_intermediate ;                                    

reg   [`INTERNAL_HIGH_ORDER_BIT:0]    sum_r0_yn_r2_yn2           ;
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    sum_r3_yn3_r5_yn5          ;

reg   [`INTERNAL_HIGH_ORDER_BIT:0]    current_sum_total          ;    
reg   [31:0]    current_sum_shifted_before_rebase
                                           ;    
reg   [31:0]    current_sum_shifted_before_rebase_2nd
                                           ;    // Keep a copy to ease timings 
                                                // Copy is for 2nd integration
reg   [31:0]    current_sum_shifted_rebased;         
wire  [`INTERNAL_HIGH_ORDER_BIT:0]    w_predictor_high_precision_output
                                           ;
                                
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    integral_sum      ;    // 
reg   [`INTERNAL_HIGH_ORDER_BIT:0]    integral_2nd_sum  ;    // 

reg             input_averaging_enable
                                ;    // If '1' ==> each ADC clock the input is summed 
                                     //            and in the next iteration
                                     //            of the predictor (including
                                     //            any intentional delay
                                     //            added) the resultant sum is
                                     //            introduced as the next
                                     //            input to the predictor.
                                     //            
reg     [15:0]    output_shift_2nd;  // Output shift of the 2nd integrator                                   
reg     [15:0]    output_shift  ;    // Right shift value the output by this amount
                                     // (useful for renormalizing the output
                                     // after fixed point arithmetic was done)
reg     [15:0]    i0_shift      ;    // Amount of right shift for the integrated multiplication
                                     // before adding it to the overall sum.
                                     // This allows finer resolution of the
                                     // integrator coefficient, which normally
                                     // can be very small
reg     [31:0]    output_counter_1_limit
                                ;    // For high precision PWM output shaping:
                                     // In order to generate a more precise DAC output, 
                                     // then the DAC is set to high and then low values corresponding
                                     // the high precision bits as set in the output_precision_size
                                     // and output_precision_shift.
                                     // The 'output_counter_1_limit' is actually set to the value 
                                     // of the selected bits, reflecting the # of times the DAC has to output
                                     // the rounded up valur of the DAC before switching to the rounded down 
                                     // value.
                                     //
reg               output_precision_enable
                                ;      
reg     [4:0]     output_precision_size
                                ;    // # of bits from the _unshifted output_ which are used to modulate the 
                                     // output of the predictor.
reg     [4:0]     output_precision_shift
                                ;    // offset of 1st bit to be used for output precision.
reg     [5:0]     output_precision_1st_output_bit_shift
                                ;    // Defines the 1st bit which is actually would be output to  
                                     // the DAC = output_precision_shift + output_precision_size
reg    [31:0]     output_precision_and_value
                                ;    // Value to and the shifted result to obtain the correct bit
                                     // size as specified in output_precision_size
                                     // (essentially:
                                     // output_precision_and_value = (1 << output_precision_size) - 1
reg     [31:0]    output_precision_current_value
                                ;    // The current value of the PWM output shaper.
                                     //
                                     // 

reg               do_delay      ;    // If '1' ==> after predictor finishes predicting, it does not return
                                     // to its original state, but begins
                                     // a counter that runs until delay_count
                                     // is reached.

reg               output_precision_real_enable
                                ;

reg     [31:0]    second_output_value                               
                                ;

reg               second_integrator_output_enable
                                ;    // is second integration output enabled?
                                     // (if not, it is just the copy of the
                                     //  1st).
reg               second_integrator_enable
                                ;    // If not enabled, it just retains its last value.
                                


reg               continuous    ;    // Indicates whether continuous operation mode is running
reg               continuous_input_select
                                ;    // Indicates which input is selected for the continuous input select.
reg               pre_dither_manual_enable
                                ;    // "0" = normal input to dither output (= output of pid).
                                     // "1" = manual input to dither output (= manual register value, pid result is discarded)
reg     [31:0]    pre_dither_manual_value
                                ;    // Value of input to dither's output, in case pre-dither manual is enabled (see line above).


reg               sw_reset_request
                                ;    // S/W reset signal                                
reg     [31:0]    y_reference   ;    // The reference point from which y_input is subtracted.
                                     // (i.e., the aim of the system is to
                                     // reduce this difference y_n = y_input - y_reference
                                     // to 0)
                                     // NOTE: y_input may further be
                                     // subtracted from some delta in order to
                                     // align its values with DAC, at the
                                     // discretion of the user...

reg     [31:0]    y_average_sum ;                                     

reg     [31:0]    y_input       ;

reg               manual_dac_output_enable     
                                ;
reg     [31:0]    manual_dac_output
                                ;
reg               invert_y_n    ;
reg               invert_output ;
reg               y_input_diff_enable
                                ;    // Indicates that y_input is not one of the inputs, but rather the difference between them

//
// Output precision = ability to modulate the output value 
// (dither it between two values) = essentially PWM of the output.
// This can give effectively higher resolution of the DAC result. 
//
reg     [15:0]    output_precision_counter   ;
reg     [31:0]    output_precision_high_value;
reg     [31:0]    output_precision_low_value ; 

reg     [31:0]    counter       ;
reg     [31:0]    count_input   ;
wire    [31:0]    count_output  ;
wire              w_continuous  ;
//wire              w_continuous_input_select  ;

wire    [63:0]    w_shifter_output_64 ;

assign  w_continuous                = continuous                ; 
//assign  w_continuous_input_select   = continuous_input_select   ;

wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r0_y_n       ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r1_y_n_1     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r2_y_n_2     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r3_y_n_3     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r4_y_n_4     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r5_y_n_5     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r6_y_n_6     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_r7_y_n_7     ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_i0_y_n       ; 
wire [`INTERNAL_HIGH_ORDER_BIT:0]  w_i0_2nd_sum   ;

//
// --------------------------------------------------------------------------------
// Dither configuration
// *NOTE: this has nothing to do with output precision!
//        real dithering of the output between two values is 
//        required to jitter the cavity in order to get out of local minima.
//        So this feature is not related and should not be confused with output precision
// --------------------------------------------------------------------------------
//  
// -----------------------------------  ----------- --------------------------------------------------------
// signal                               Set By      Description
// -----------------------------------  ----------- --------------------------------------------------------
// dither_output_amplitude              S/W         Amount to add or decrement from current output of the 
//                                                  predictor.
// dither_output_polarity               H/W         "0" for add, "1" for decrement. Toggles on each DAC 
//                                                  cycle (= every second cycle of the predictor).
// dither_output_count                  H/W         current polarity counter of the output
// dither_output_init_count             S/W         S/W defined polarity counter after which we switch polarity
// dither_input_enable                  S/W         "0" ==> dithering of output/input DISABLED
// dither_output_enable                 S/W         "1" ==> dithering of output/input ENABLED.
//                                                  
// dither_input_polarity                H/W         Current polarity if input dither. 
//                                                  "0" ==> the current sample is added.
//                                                  "1" ==> the current sample is subtracted. 
// dither_input_state                   H/W         "001" init polarity is loaded, init count is loaded
//                                                  "002" counting down until count reaches zero
//                                                  "004" toggling polarity, loading next count
//                                                  "008" counting down until count reaches zero
//                                                  "010" toggling polarity, loading next count with ffff
//                                                  state ends with predictor restarts its operating cycle.
// dither_input_init_polarity           S/W         "0" input begins at (+), "1" at (-)
// dither_input_init_count              S/W         # of ADC (= DAC) cycles before switching polarity
// dither_input_next_count              S/W         # of ADC (= DAC) cycles after switching polarity.
//                                                  Once the 'next' state had exhausted, we toggle the polarity
//                                                  again but never toggle it back
// dither_input_count                   H/W         current polarity counter 
// dither_input_polarity                H/W         current polarity
//                                                  
//
//

reg  [15:0]  dither_output_amplitude    ;   
reg          dither_output_polarity     ;   
reg  [15:0]  dither_output_count        ;
reg  [15:0]  dither_output_init_count   ;
reg          dither_input_enable        ;   
reg          dither_output_enable       ;   
reg  [4:0]   dither_input_state         ;   
reg          dither_input_init_polarity ;   
reg          dither_input_polarity      ;   
reg  [15:0]  dither_input_init_count    ;   
reg  [15:0]  dither_input_next_count    ;   
reg  [15:0]  dither_input_count         ;
reg  [31:0]  dac_output                 ;
reg  [31:0]  reg_o_z_n                  ;

reg  [31:0]  dac_2nd_output             ;



mult_32_32  mult_r0_y_n   (  .clock(logic_clk), .dataa(r0), .datab(y_n  ), .result(w_r0_y_n   )   ) ;     
mult_32_32  mult_r1_y_n_1 (  .clock(logic_clk), .dataa(r1), .datab(y_n_1), .result(w_r1_y_n_1 )   ) ;
mult_32_32  mult_r2_y_n_2 (  .clock(logic_clk), .dataa(r2), .datab(y_n_2), .result(w_r2_y_n_2 )   ) ;
mult_32_32  mult_r3_y_n_3 (  .clock(logic_clk), .dataa(r3), .datab(y_n_3), .result(w_r3_y_n_3 )   ) ;
mult_32_32  mult_r4_y_n_4 (  .clock(logic_clk), .dataa(r4), .datab(y_n_4), .result(w_r4_y_n_4 )   ) ;
mult_32_32  mult_r5_y_n_5 (  .clock(logic_clk), .dataa(r5), .datab(y_n_5), .result(w_r5_y_n_5 )   ) ;
mult_32_32  mult_r6_y_n_6 (  .clock(logic_clk), .dataa(r6), .datab(y_n_6), .result(w_r6_y_n_6 )   ) ;
mult_32_32  mult_r7_y_n_7 (  .clock(logic_clk), .dataa(r7), .datab(y_n_7), .result(w_r7_y_n_7 )   ) ;
mult_32_32  mult_i0_y_n   (  .clock(logic_clk), .dataa(i0    ), .datab(y_n  ), .result(w_i0_y_n   )   ) ;
mult_32_32  mult_i0_2nd   (  .clock(logic_clk), .dataa(i0_2nd), .datab(current_sum_shifted_before_rebase_2nd), .result(w_i0_2nd_sum)   ) ;
//
// state machine No.1
// Handles host writes to regs
//
always@(posedge reg_clk or negedge rst)
    if(!rst)
    begin
        i0                          <=  0   ;
        r0                          <=  0   ;
        r1                          <=  0   ;
        r2                          <=  0   ;
        r3                          <=  0   ;
        r4                          <=  0   ;
        r5                          <=  0   ;
        r6                          <=  0   ;
        r7                          <=  0   ;
        sw_reset_request            <=  0   ;
        continuous                  <=  0   ;
        output_shift                <=  0   ;
        continuous_input_select     <=  0   ;
        pre_dither_manual_enable    <=  0   ;
        out_offset                  <=  0   ;
        y_reference                 <=  0   ;
        delay_count                 <=  0   ;
        do_delay                    <=  0   ;
        manual_dac_output_enable    <=  0   ;
        invert_y_n                  <=  0   ;
        invert_output               <=  0   ;
        output_precision_shift      <=  0   ;
        output_precision_size       <=  0   ;
        output_precision_enable     <=  0   ;
        input_averaging_enable      <=  0   ;
        output_precision_and_value  <=  0   ;
        output_precision_real_enable<=  0   ;
        output_precision_1st_output_bit_shift
                                    <=  0   ;
        y_input_diff_enable         <=  0   ;
        second_integrator_output_enable
                                    <=  0   ;
        second_integrator_enable    <=  0   ;
        pre_dither_manual_value     <=  0   ;                                    

        end
    else begin
	     //
		  // normal operation - we pickup the scan value all the time
		  //
        pre_dither_manual_value  <= i_pre_dither_manual_value;
        if  (sw_reset_request)
            begin
                sw_reset_request  <= 0;
            end

        if    (i_write)
        begin
            if (i_cs[1])
            begin
                r0   <= {16*i_q0_q4[15], i_q0_q4[15:0]};
                r4   <= {16*i_q0_q4[31], i_q0_q4[31:16]};
            end

            if (i_cs[2])
            begin
                r1 <= {16*i_q1_q5[15], i_q1_q5[15:0]};
                r5 <= {16*i_q1_q5[31], i_q1_q5[31:16]};
            end

            if (i_cs[3])
            begin
                r2 <= {16*i_q2_q6[15], i_q2_q6[15:0]};
                r6 <= {16*i_q2_q6[31], i_q2_q6[31:16]};
            end

            if (i_cs[4])
            begin
                r3 <= {16*i_q3_q7[15], i_q3_q7[15:0]};
                r7 <= {16*i_q3_q7[31], i_q3_q7[31:16]};
            end

            if    (i_cs[5])
            begin
                sw_reset_request         <= i_config[0];
                continuous               <= i_config[1] ;
                continuous_input_select  <= i_config[2];   // "0" = A, "1" = B
                pre_dither_manual_enable <= i_config[3];
                output_shift             <= {10'b0, i_config[21:16]} ;
                output_precision_size    <= i_config[8:4];
                output_precision_shift   <= i_config[28:24];
                do_delay                 <= i_config[10];                                         
                manual_dac_output_enable <= i_config[11];
                invert_y_n               <= i_config[12];
                invert_output            <= i_config[13];
                output_precision_enable  <= i_config[14];
                input_averaging_enable   <= i_config[15];
                output_precision_and_value <= ((32'd1 << output_precision_size) - 1);
                output_precision_real_enable <= i_config[14] && (i_config[8:4] != 0);
                output_precision_1st_output_bit_shift <= i_config[8:4] + i_config[28:24];
                y_input_diff_enable      <= i_config[29];
                second_integrator_output_enable
                                         <= i_config[30];
                second_integrator_enable <= i_config[31];
            end

            if    (i_cs[6])
            begin
                y_reference              <= i_y_reference[31:0];
            end

            if    (i_cs[7])
            begin
                i0                       <= {16*i_i0[15], i_i0[15:0]};
            end

            if    (i_cs[11])
            begin
                delay_count              <= i_delay_count;
            end


            if (i_cs[13])
            begin
                out_offset <= i_out_offset;
            end
        end
    end



//
// state machine No.1.1
// Handles registers writes via secondary register bank
// (previously, this register bank was used for the original PID.v
//  H/W, which is now not compiled)
//
always@(posedge reg_clk or negedge rst)
    if(!rst)begin
            dither_output_amplitude    <= 0;
            dither_input_enable        <= 0;
            dither_output_enable       <= 0;
            dither_input_init_polarity <= 0;
            dither_output_init_count   <= 0;
            dither_input_init_count    <= 0;
            dither_input_next_count    <= 0;
            out_offset_plus_dither_amplitude
                                       <= 0;
            output_shift_2nd           <= 0;
            i0_shift                   <= 0;
            i0_2nd                     <= 0;
            second_output_value        <= 0;
            manual_dac_output          <= 0;
    end
    else begin

        if    (i2_write)
        begin
            //
            // Chip select bit masks select values:
            // (see below, each bit in i_cs[...] designated the register which we write to
            //
            if (i2_cs[0])
            begin
                //
                // Dither configuration #1
                //
                dither_output_amplitude <= i2_dither_config_1[15: 0];
                dither_input_init_count <= i2_dither_config_1[31:16];
                out_offset_plus_dither_amplitude <= out_offset + i2_dither_config_1[15: 0];
            end

            if (i2_cs[1])
            begin
                //
                // Dither configuration #2
                //
                dither_input_next_count    <= i2_dither_config_2[15: 0];
                dither_output_init_count   <= i2_dither_config_2[31:16];
            end

            if (i2_cs[2])
            begin
                //
                // Dither configuration #3
                //
                dither_input_enable        <= i2_dither_config_3[31];
                dither_output_enable       <= i2_dither_config_3[30];
                dither_input_init_polarity <= i2_dither_config_3[29];
                if (i2_dither_config_3[30])  // if dither is now being enabled then... 
                begin
                    out_offset_plus_dither_amplitude <= out_offset + dither_output_amplitude; 
                end
                else
                begin
                    out_offset_plus_dither_amplitude <= out_offset ; 
                end
            end

            if (i2_cs[6])
            begin
                //
                // 2nd output offset
                // (rebase of the 2nd integrator offset)
                //
                out_offset_2nd <= i2_2nd_out_offset;
            end

            if (i2_cs[7])
            begin
                //
                // 2nd config
                // (2nd configuration register...)
                // [15: 0] = shift of the 2nd integration 
                // [31:16] = shift of the 1st integration result
                //           before it is added to the overall sum.
                //
                output_shift_2nd <= i2_2nd_config[15: 0];
                i0_shift         <= i2_2nd_config[31:16];
            end

            if (i2_cs[8])
            begin
                //
                // 3rd config
                //
                i0_2nd <= {16*i2_3rd_config[15], i2_3rd_config[15: 0]};
            end

            if (i2_cs[13])
            begin
                //
                // 2nd config
                // (2nd configuration register...)
                //
                second_output_value <= i2_2nd_output_set;
            end

            if (i2_cs[14])
            begin
                manual_dac_output   <= i2_manual_dac_output;
            end
                
        end
    end





//
// state machine No.2
// Handles the predictor core logic itself
//
reg [11:0] state_1;


reg reset_pending;


//
// indicates whether predictor should start working.
// This is either self generated whenever working in continuous mode
// (which is the intended mode), or triggered by S/W.
//
wire      kick_predictor    ;    // Once kick is detected, the predictor begins to work

//
// Continous operation support:
// PID can be continously kicked, in which case it measures the i_PV_c 
// signal and not the i_pv register.
//
assign    kick_predictor    =    w_continuous; // Writing to PV kicks the pid                                                                            

reg       [31:0]   y_input_raw_1;
reg       [31:0]   y_input_raw_2;


//
// A clear "name" for the high precision result of the predictor,
// before any shifts and PWM shaping of the output signal.
//
assign    w_predictor_high_precision_output
                          = current_sum_total;

//
// The actual predictor FSM
//
always@(posedge logic_clk or negedge rst)
    if (!rst) begin
        state_1      <= `STATE_0A        ;
        y_input      <= 0                ;
        y_input_raw_1<= 0                ;
        y_input_raw_2<= 0                ;
        save_y_n     <= 0                ;
        save_y_n_1   <= 0                ;
        save_y_n_2   <= 0                ;
        save_y_n_3   <= 0                ;
        save_y_n_4   <= 0                ;
        save_y_n_5   <= 0                ;
        save_y_n_6   <= 0                ;
        y_n          <= 0                ;
        y_n_1        <= 0                ;
        y_n_2        <= 0                ;
        y_n_3        <= 0                ;
        y_n_4        <= 0                ;
        y_n_5        <= 0                ;
        y_n_6        <= 0                ;
        y_n_7        <= 0                ;
        r0_y_n       <= 0                ;
        r1_y_n_1     <= 0                ;
        r2_y_n_2     <= 0                ;
        r3_y_n_3     <= 0                ;
        r4_y_n_4     <= 0                ;
        r5_y_n_5     <= 0                ;
        r6_y_n_6     <= 0                ;
        r7_y_n_7     <= 0                ;
        i0_y_n       <= 0                ;
        i0_y_n_shifted
                     <= 0                ;
        sum_r0_yn_r2_yn2         
                     <= 0                ;
        sum_r3_yn3_r5_yn5         
                     <= 0                ;
        current_sum_total         
                     <= 0                ;
        current_sum_shifted_before_rebase
                     <= 0                ;
        current_sum_shifted_rebased 
                     <= 0                ;
        count_input  <= 32'b0            ;
        counter      <= 32'b0            ;
        reset_pending<= 0                ;
        integral_sum <= 0                ;
        integral_2nd_sum  
                     <= 0                ;
        delay_counter<= 0                ;
        delay_counter_intermediate
                     <= 0                ;
        y_average_sum<= 0                ;
        output_precision_counter 
                     <= 0                ;
        output_precision_high_value 
                     <= 0                ;
        output_precision_low_value       
                     <= 0                ;
        output_precision_current_value          
                     <= 0                ;
        dither_input_state
                     <= 0                ;
        dither_input_count
                     <= 0                ;
        dither_output_polarity
                     <= 0                ;
        dither_input_polarity
                     <= 0                ;
        dither_output_count
                     <= 0                ;
        dac_output   <= 0                ;
        dac_2nd_output
                     <= 0                ;
    end
    else begin
        reset_pending <= reset_pending;
        if (sw_reset_request) begin
            reset_pending <= 1;
        end
        case(state_1)
        `STATE_0A:   begin
            if(reset_pending)begin   
                y_input      <= 0                ;
                y_n          <= 0                ;
                y_n_1        <= 0                ;
                y_n_2        <= 0                ;
                y_n_3        <= 0                ;
                y_n_4        <= 0                ;
                y_n_5        <= 0                ;
                y_n_6        <= 0                ;
                y_n_7        <= 0                ;
                r0_y_n       <= 0                ;
                r1_y_n_1     <= 0                ;
                r2_y_n_2     <= 0                ;
                r3_y_n_3     <= 0                ;
                r4_y_n_4     <= 0                ;
                r5_y_n_5     <= 0                ;
                r6_y_n_6     <= 0                ;
                r7_y_n_7     <= 0                ;
                i0_y_n       <= 0                ;
                sum_r0_yn_r2_yn2         <= 0                ;
                sum_r3_yn3_r5_yn5         <= 0                ;
                current_sum_total         <= 0                ;
                delay_counter<= 0                ;
                delay_counter_intermediate
                             <= 0                ;
                y_average_sum<= 0                ;
                output_counter_1_limit 
                             <= 0                ;
                output_precision_low_value
                             <= 0                ;
                output_precision_high_value
                             <= 0                ;
                output_precision_current_value
                             <= 0                ;
                reset_pending<= 0                ;

                dither_output_polarity
                             <= 0                ;
                dither_input_state 
                             <= 5'b00000         ;
                integral_2nd_sum  
                             <= 0                ;
                integral_sum <= 0                ;
            end
            //
            // always move to STATE_0B, 
            // to ensure we always transition to STATE_1 
            // on an even clock cycle
            //
            state_1 <= `STATE_0B;
            //
            // Take a sample on an even clock cycle!
            //
            y_input_raw_1 <= (y_input_diff_enable ? i_yn1 : (continuous_input_select ? i_yn2 : i_yn1) )  ;
            y_input_raw_2 <= (y_input_diff_enable ? i_yn2 : 0                                         )  ;
            //
            // When just beginning contintuous operation, we assuume
            // difference input
            //
            y_input       <= i_yn1 - i_yn2 - y_reference ;
        end

        `STATE_0B:   begin
            //
            // Force additional cycle to ensure we always start working 
            // on an even clock cycle
            //
            if (kick_predictor)  // kick_predictor = continuous mode of operation!
            begin
                state_1 <= `STATE_1;
            end
            else
            begin
                state_1 <= `STATE_0A;
            end
        end

        `STATE_1:    begin
            //
            // current_sum_shifted_rebased is the standard DAC output
            // before output dither is applied.
            // In this stage, both dac_output (which is the real output of the
            // predictor) is calculated in the same way.
            //
            current_sum_shifted_rebased <= current_sum_shifted_before_rebase - out_offset;
            //
            // Keep a copy of the current sum for the 2nd integration
            //
            current_sum_shifted_before_rebase_2nd 
                                        <= current_sum_shifted_before_rebase;
            //
            // 'dac_output' is the real output - we evaluate it in the same
            // way as the 'current_sum_shifted_rebased'.
            // If output dithering is enabled, we always assume the output dithering
            // begins with a negative sign and we take the out_offset as well
            // as the dither apmplitude.
            //

            if (!pre_dither_manual_enable)
            begin
                //
                // standard dither or non-dithered operation
                // pid output goes to dither or without dither.
                //
                if (dither_output_enable)
                begin
                    dac_output <= current_sum_shifted_before_rebase - out_offset_plus_dither_amplitude;
                end
                else
                begin
                    dac_output <= current_sum_shifted_before_rebase - out_offset; 
                end
            end
            else
            begin
                //
                // manual pre-dither output
                //
                if (dither_output_enable)
                begin
                    dac_output <= pre_dither_manual_value - out_offset_plus_dither_amplitude;
                end
                else
                begin
                    dac_output <= pre_dither_manual_value - out_offset; 
                end
            end


            //
            // If diff operation - we sample both ADC's input.
            // Otherwise, the 'lower end' is 0 and the 'higher end' is the 
            // ADC selected by 'continuous_input_select' signal.
            // The actual difference is taken in the next step.
            //
            y_input_raw_1 <= (y_input_diff_enable ? i_yn1 : (continuous_input_select ? i_yn2 : i_yn1) )  ;
            y_input_raw_2 <= (y_input_diff_enable ? i_yn2 : 0                                         )  ;

            //
            // Grab the output of the pipelined (1 cycle) multipliers
            // which multiple coefficient ri and y_n_i where 0 <= i <= 5
            // (note that y_n_0 is named y_n).
            //
            r0_y_n    <=  w_r0_y_n   ; 
            r1_y_n_1  <=  w_r1_y_n_1 ; 
            r2_y_n_2  <=  w_r2_y_n_2 ; 
            r3_y_n_3  <=  w_r3_y_n_3 ; 
            r4_y_n_4  <=  w_r4_y_n_4 ; 
            r5_y_n_5  <=  w_r5_y_n_5 ; 
            r6_y_n_6  <=  w_r6_y_n_6 ; 
            r7_y_n_7  <=  w_r7_y_n_7 ; 
            i0_y_n    <=  w_i0_y_n; 
            
            //
            // Dithering input:
            // Input dithering has possibly 3 states, all
            // with alternating polarity.
            // The 1st 2 states are called 'init' and 'next', 
            // each with its own count definition
            // 'dither_input_init_count' is the the stage with the init
            // polarity.
            // y_average_sum is essentially a sum of the input which is used
            // if input averaging is applied.
            // Note that we don't really average - but take the sum, which
            // increases the amount of bits needed for the calculation, and
            // requires the final output shift to pick up the relevant bits.
            //
            if (dither_input_enable)
            begin
                //
                // Input dithering - pickup the input subject to input
                // dithering polarity and phase.
                //
                if (dither_input_init_count == 16'b0)   
                begin
                    dither_input_state <= 5'b00010;     // If init phase is 0, begin with next phase
                end
                else
                begin
                    dither_input_state <= 5'b00001;
                end

                dither_input_polarity
                                    <= dither_input_init_polarity;

                dither_input_count  <= 1'b1;

                y_average_sum <= (dither_input_init_polarity ? y_input : -y_input);
            end
            else
            begin
                //
                // No input dithering, just pick up the input
                //
                y_average_sum 
                          <= y_input;
            end

            if (dither_output_enable)
            begin
                dither_output_polarity <= 0;

                dither_output_count <= 1'b1;

            end

            state_1   <= `STATE_2;

            //
            // Output precision is PWM dithering of the output 
            // in order to achieve higher precision (regardless of the
            // 'standard output dithering' which has a different purpose).
            // At the moment, this feature is not tested.
            // 
            if (output_precision_real_enable)
            begin
                output_counter_1_limit <= 
                        w_predictor_high_precision_output[output_precision_shift +: 32]
                        & 
                        output_precision_and_value 
                        ;
                output_precision_counter    <= 1;
                output_precision_low_value  <=     w_predictor_high_precision_output[output_precision_1st_output_bit_shift +: 32] ;
                output_precision_high_value <= 1 + w_predictor_high_precision_output[output_precision_1st_output_bit_shift +: 32] ;

                output_precision_current_value <= output_precision_high_value;
            end

            //
            // Once integration coefficient becomes zero, no use in retaining
            // history, just clear the integration so far.
            //
            if (i0 == 32'b0)
            begin
                integral_sum <= 32'b0;
            end


        end

        `STATE_2:    begin

            //
            // resolving timeing issue with o_z_n:
            // do logic in a register and output the register
            //
            if (manual_dac_output)
            begin
                reg_o_z_n <= manual_dac_output;
            end
            else if (!invert_output)
            begin
                reg_o_z_n <= dac_output;
            end
            else
            begin
                reg_o_z_n <= ~dac_output;
            end

            //
            // y_input is taken as the difference and realigns with the 
            // y_reference input. Note that if input difference is disabled, 
            // y_input_raw_2 is essentially 0.
            //
            y_input         <= y_input_raw_1 - y_input_raw_2 - y_reference ;
            i0_y_n_shifted  <= i0_y_n[i0_shift +:48];

            //
            // Evaluate the sums (part of them)
            //
            sum_r0_yn_r2_yn2 <= r0_y_n   + r1_y_n_1 + r2_y_n_2 ;
            
            // TODO: does this quadruple clears timing?
            sum_r3_yn3_r5_yn5<= r3_y_n_3 + r4_y_n_4 + r5_y_n_5 + r6_y_n_6 + r7_y_n_7 ;

            state_1 <= `STATE_3;
           
            if (second_integrator_enable)
            begin
                integral_2nd_sum <= integral_2nd_sum + w_i0_2nd_sum;
            end
        end

        `STATE_3:    begin
            integral_sum     <= i0_y_n_shifted + integral_sum;
            //
            // Can take the input to the next stage here
            //
            y_input_raw_1     <= (y_input_diff_enable ? i_yn1 : (continuous_input_select ? i_yn2 : i_yn1) )  ;
            y_input_raw_2     <= (y_input_diff_enable ? i_yn2 : 0                                         )  ;
            //
            // Evaluate the total output of the predictor - note that this is
            // before shifting, so it ain't ready for output yet.
            //
            //                                                          |integral_sum after the latest summation |
            current_sum_total <= sum_r0_yn_r2_yn2 + sum_r3_yn3_r5_yn5 + (integral_sum + i0_y_n_shifted           );

            //
            // Propagate input dithering
            //
            if (dither_input_enable)
            begin
                if (dither_input_init_count == 16'b1)
                    begin
                        dither_input_state <= 5'b00010;
                    end

                if (dither_input_polarity == 0)
                    begin
                        y_average_sum <= y_average_sum - y_input ;
                    end
                else
                    begin
                        y_average_sum <= y_average_sum + y_input ;
                    end

                dither_input_count <= 2;
            end
            else
            begin
                //
                // Take the sum of the previous sample (in STATE_2).
                //
                y_average_sum <= y_average_sum + y_input ;
            end


            if (dither_output_enable)
            begin
                if (dither_output_init_count <= 1'b1)
                begin
                    dither_output_polarity <= ~dither_output_polarity;
                end
                dither_output_count <= 2;
            end


            state_1      <= `STATE_4 ;
            count_input  <= counter  ;   // count++


            //
            // Save the signals (mostly to relax timing constraints - not sure
            // this is really needed)
            //
            save_y_n   <= y_n;
            save_y_n_1 <= y_n_1;
            save_y_n_2 <= y_n_2;
            save_y_n_3 <= y_n_3;
            save_y_n_4 <= y_n_4;
            save_y_n_5 <= y_n_5;
            save_y_n_6 <= y_n_6;

            if (output_precision_real_enable)
            begin
                if (output_counter_1_limit <= 1) 
                begin
                    output_precision_current_value <= output_precision_low_value ;
                end
                else
                begin
                    output_precision_counter <= output_precision_counter + 16'b1;
                end
            end

            if (second_integrator_enable)
            begin
                dac_2nd_output <= integral_2nd_sum[output_shift_2nd +: 32] - out_offset_2nd;
            end
            

        end

        `STATE_4:    begin

            current_sum_shifted_before_rebase <= current_sum_total[output_shift +: 32]; 

            //
            // 2nd take of y_input in a single predictor 4 cycle operation
            // (if more than 4 cycles, this is taken again in state 6).
            // 
            y_input <= y_input_raw_1 - y_input_raw_2 - y_reference ;

            counter <= count_output;// count++

            count_input <= 32'b0;   

            y_n_7  <= save_y_n_6 ;
            y_n_6  <= save_y_n_5 ;
            y_n_5  <= save_y_n_4 ;
            y_n_4  <= save_y_n_3 ;
            y_n_3  <= save_y_n_2 ;
            y_n_2  <= save_y_n_1 ;
            y_n_1  <= save_y_n   ;
          
            if (input_averaging_enable)
            begin
                y_n <= (invert_y_n ? ~y_average_sum : y_average_sum);
            end
            else
            begin
                y_n <= (invert_y_n ? ~y_input       : y_input      );
            end

            if (!pre_dither_manual_value)
            begin
                //
                // normal operation - either with/without output dither.
                // pid output goes to dither or straight forward.
                //
                if (dither_output_enable)
                begin
                    if (dither_output_polarity)
                    begin
                        dac_output <= current_sum_shifted_rebased + dither_output_amplitude;
                    end
                    else
                    begin
                        dac_output <= current_sum_shifted_rebased - dither_output_amplitude;
                    end
                end
            end
            else
            begin
                //
                // pre-dither manual override.
                // the manual value either goes dithered output or just straight to output.
                //
                if (dither_output_enable)
                begin
                    if (dither_output_polarity)
                    begin
                        dac_output <= pre_dither_manual_value + dither_output_amplitude;
                    end
                    else
                    begin
                        dac_output <= pre_dither_manual_value - dither_output_amplitude;
                    end
                end
            end

            if (do_delay)
            begin
                delay_counter               <= 0;
                delay_counter_intermediate  <= 0;
                state_1                     <= `STATE_5;
            end
            else
            begin
                //
                // State machine returning to its original state:
                // 1. If can continue rolling, move straight to state #1
                // 2. Otherwise, roll back to initial state #0
                //
                if (kick_predictor && !reset_pending)
                begin
                    state_1 <= `STATE_1;
                end
                else
                begin
                    state_1 <= `STATE_0A;
                end
            end
        end

        `STATE_5:  begin
            //
            // resolving timeing issue with o_z_n:
            // do logic in a register and output the register
            //
            if (manual_dac_output)
            begin
                reg_o_z_n <= manual_dac_output;
            end
            else if (!invert_output)
            begin
                reg_o_z_n <= dac_output;
            end
            else
            begin
                reg_o_z_n <= ~dac_output;
            end

            //
            // If we get here then there's a non-zero delay count, which means
            // we increase the predictor cycle to sum more input signal to
            // increase the input signal precision.
            //
            if (delay_counter == 0)
            begin
                current_sum_shifted_before_rebase <= current_sum_total[output_shift +: 32];
            end

            //
            // Can take the input to the next stage here
            //
            y_input_raw_1     <= (y_input_diff_enable ? i_yn1 : (continuous_input_select ? i_yn2 : i_yn1) )  ;
            y_input_raw_2     <= (y_input_diff_enable ? i_yn2 : 0                                         )  ;

            delay_counter_intermediate <= delay_counter + 1;
            state_1       <= `STATE_6;
            if (output_precision_real_enable)
            begin
                if (output_precision_counter > output_counter_1_limit) 
                begin
                    output_precision_current_value <= output_precision_low_value ;
                end
                else
                begin
                    output_precision_counter <= output_precision_counter + 16'b1;
                end
            end

            if (dither_input_enable)
            begin
                //
                // Dithering IS enabled - sum according to polarity
                //
                if (dither_input_polarity)
                begin
                    y_average_sum <= y_average_sum + y_input  ;
                end
                else
                begin
                    y_average_sum <= y_average_sum - y_input  ;
                end

                case(dither_input_state)
                5'b00001: 
                    begin 
                        if (dither_input_count >= dither_input_init_count)
                        begin
                            dither_input_state <= 5'b00010;
                            dither_input_count <= 0;
                            dither_input_polarity <= ~dither_input_polarity;
                        end
                        else
                        begin
                           dither_input_count <= dither_input_count + 16'b1;
                        end
                    end

                5'b00010: 
                    begin 
                        if (dither_input_count >= dither_input_next_count)
                        begin
                            dither_input_state <= 5'b00100;
                            dither_input_count <= 0;
                            dither_input_polarity <= ~dither_input_polarity;
                        end
                        else
                        begin
                           dither_input_count <= dither_input_count + 16'b1;
                        end
                    end

                5'b00100: 
                    begin 
                        dither_input_count <= dither_input_count + 16'b1;
                    end
                endcase
            end
            else
            begin
                //
                // Dithering not enabled - just normal averaging
                //
                y_average_sum <= y_average_sum + y_input ;
            end

            if (!pre_dither_manual_enable)
            begin
                //
                // normal operation - pid output either goes to dither output 
                // or pid output goes straight to output.
                //
                if (dither_output_enable)
                begin
                    if (dither_output_polarity)
                    begin
                        dac_output <= current_sum_shifted_rebased + dither_output_amplitude;
                    end
                    else
                    begin
                        dac_output <= current_sum_shifted_rebased - dither_output_amplitude;
                    end
                end
                else
                begin
                    dac_output <= current_sum_shifted_rebased;
                end
            end
            else
            begin
                //
                // pe-dither manual operation - input to dither output or non-dithered output is the manual override value.
                //
                if (dither_output_enable)
                begin
                    if (dither_output_polarity)
                    begin
                        dac_output <= pre_dither_manual_value + dither_output_amplitude;
                    end
                    else
                    begin
                        dac_output <= pre_dither_manual_value - dither_output_amplitude;
                    end
                end
                else
                begin
                    dac_output <= pre_dither_manual_value;
                end
            end

            //
            // regardless of pre-dither manual or standard input,
            // we ik the dither output state (if dither output is enabled)
            //
            if (dither_input_enable)
            begin
                if (dither_output_count >= dither_output_init_count)
                begin
                    // dither_output_count <= 0;
                    
                    dither_output_polarity <= 1;   // ~dither_output_polarity;
                end
                else
                begin
                    dither_output_count <= dither_output_count + 16'b1;
                end
            end
        end

        `STATE_6:  begin

            //
            // resolving timeing issue with o_z_n:
            // do logic in a register and output the register
            //
            if (manual_dac_output)
            begin
                reg_o_z_n <= manual_dac_output;
            end
            else if (!invert_output)
            begin
                reg_o_z_n <= dac_output;
            end
            else
            begin
                reg_o_z_n <= ~dac_output;
            end


            if (input_averaging_enable)
            begin
                y_n <= (invert_y_n ? ~y_average_sum : y_average_sum);
            end
            else
            begin
                y_n <= (invert_y_n ? ~y_input       : y_input      );
            end

            //
            // 2nd take of y_input in a single predictor 4 cycle operation
            // (if more than 4 cycles, this is taken again in state 6).
            // 
            y_input <= y_input_raw_1 - y_input_raw_2 - y_reference ;

            delay_counter <= delay_counter_intermediate;

            if (delay_counter_intermediate < delay_count)
                begin
                    state_1 <= `STATE_5;
                end
            else
                begin
                    //
                    // State machine returning to its original state:
                    // 1. If can continue rolling, move straight to state #1
                    // 2. Otherwise, roll back to initial state #0
                    //
                    if (kick_predictor && !reset_pending)
                    begin
                        state_1 <= `STATE_1;
                    end
                    else
                    begin
                        state_1 <= `STATE_0A;
                    end
                end
        end

        endcase
    end


wire    ready;


                                       
                                                             

counter   un_counter( .dataa(count_input), .result(count_output));

assign    o_config  =    {  /* bit [31   ] */ second_integrator_enable      , 
                            /* bit [30   ] */ second_integrator_output_enable,
                            /* bit [29   ] */ y_input_diff_enable           ,
                            /* bits[28:24] */ output_precision_shift        , 
                            /* bits[23   ] */ 1'b0                          , 
                            /* bits[22   ] */ kick_predictor                , 
                            /* bits[21:16] */ output_shift[5:0]             , 
                            /* bit [ 15  ] */ input_averaging_enable        , 
                            /* bit [ 14  ] */ output_precision_enable       , 
                            /* bit [ 13  ] */ invert_output                 , 
                            /* bit [ 12  ] */ invert_y_n                    , 
                            /* bit [ 11  ] */ manual_dac_output_enable      ,    
                            /* bit [ 10  ] */ do_delay                      , 
                            /* bit [  9  ] */ 1'b0                          ,  
                            /* bits[ 8:4 ] */ output_precision_size         , 
                            /* bit [  3  ] */ pre_dither_manual_enable      , 
                            /* bit [  2  ] */ continuous_input_select       , 
                            /* bit [  1  ] */ continuous                    ,
                            /* bit [  0  ] */ 1'b0 /* no sw_reset_request bit on output */} ;

assign    o_magic      = {16'h`INTERNAL_HIGH_ORDER_BIT, 4'b0, state_1 /* 12 bits */ }; 
assign    o_count      = counter ;

assign    o_y_n        = y_n  ;
assign    o2_y_n_1     = y_n_1;
assign    o2_y_n_2     = y_n_2;
assign    o_y_n_3      = y_n_3;
assign    o2_y_n_4     = y_n_4;
assign    o2_y_n_5     = y_n_5;
assign    o2_y_n_6     = y_n_6;
assign    o2_y_n_7     = y_n_7;
assign    o_q0_q4      = {r4, r0};
assign    o_q1_q5      = {r5, r1};
assign    o_q2_q6      = {r6, r2};
assign    o_q3_q7      = {r7, r3};
assign    o_continuous = continuous;
assign    o_out_offset = out_offset;
assign    o_i0         = i0;
assign    o_integral_sum
                       = integral_sum[31:0];
assign    o_y_reference= y_reference;                       
assign    o_z_n_no_integral
                       = current_sum_total[31:0];
assign    o_y_input    = {y_input};


assign    o_delay_count   = delay_count   ;                          
assign    o_delay_counter = delay_counter ;                          

assign    o_z_n           = reg_o_z_n;
//
// if 2nd integrator is NOT enabled, the 2nd output is a copy of the 1st
// output
//
assign    o_2nd_integral  = ( 
                                second_integrator_output_enable
                                ?   (
                                        second_integrator_enable
                                        ?   dac_2nd_output 
                                        :   second_output_value
                                    ) 
                                :   o_z_n
                            ); 

assign    o2_dither_config_1 = {dither_input_init_count   , dither_output_amplitude          };
assign    o2_dither_config_2 = {dither_output_init_count  , dither_input_next_count          };
assign    o2_dither_config_3 = {dither_input_enable       , dither_output_enable     , dither_input_init_polarity, 29'b0};
assign    o2_dither_count_1  = {dither_input_count        , dither_output_count              };
assign    o2_dither_count_2  = {/*  5 */ dither_input_state     , 
                                /*  1 */ dither_output_polarity , 
                                /*  1 */ dither_input_polarity  , 
                                /* 25 */ 25'b0                  };
assign    o2_dither_count_3  = {out_offset_plus_dither_amplitude};                                

assign    o_dither_input_polarity_shifted = {16'b0, 2'b0, dither_input_polarity, 13'b0};
assign    o_dither_input_state            = {16'b0, 2'b0, dither_input_state   , 9'b0 };
assign    o_dither_input_counter          = {16'b0, 2'b0, dither_input_count[13:0]    };
assign    o2_2nd_out_offset               = out_offset_2nd ;
assign    o2_2nd_config                   = {i0_shift, output_shift_2nd};
assign    o2_3rd_config                   = {16'b0, i0_2nd};
assign    o2_manual_dac_output            = manual_dac_output;

assign    o_debug_reg1                    = {16'h4567, 14'b0, second_integrator_output_enable, second_integrator_enable};
assign    o_pre_dither_manual_value       = pre_dither_manual_value;

assign o_current_sum_before_rebase = current_sum_shifted_before_rebase ;
assign o_current_total_sum_high = {current_sum_total[`INTERNAL_HIGH_ORDER_BIT:32]};
assign o_current_total_sum_low = current_sum_total[31:0];
assign o_dac_output = dac_output;


endmodule
