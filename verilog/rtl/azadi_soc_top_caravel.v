// Designed by a Team at Micro Electronics Research Lab, Usman Institute of Technology.
// https://www.merledupk.org
`default_nettype wire

module azadi_soc_top_caravel (
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif

    // Wishbone Slave ports (WB MI A)
    input         wb_clk_i,
    input         wb_rst_i,

    // Logic Analyzer Signals
    input  [15:0] la_data_in,

    // IOs, MPRJ_IO_PADS = 38
    input  [`MPRJ_IO_PADS-1:0] io_in,  
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);

  wire prog;
  
  // Clocks per bit
  wire [15:0] clks_per_bit;  

  // gpios interface
  wire [31:0] gpio_i;
  wire [31:0] gpio_o;
  wire [31:0] gpio_oe;

  // uart-periph interface
  wire uart_tx;
  wire uart_rx;

  // PWM interface  
  wire pwm_o_1;
  wire pwm_o_2;
  wire pwm1_oe;
  wire pwm2_oe;

  // SPI interface
  wire [3:0] ss_o;        
  wire       sclk_o;      
  wire       sd_o;
  wire       sd_oe;       
  wire       sd_i;

  // unused wires
  wire unused_00;
  wire unused_01;
  wire unused_02;
  wire unused_03;

  // Note: Output enable is active low for IO pads
  assign io_oeb[ 0]    = ~gpio_oe[30];
  assign gpio_i[30]    =  io_in  [ 0];
  assign io_out[ 0]    =  gpio_o [30];

  // SPI 0
  assign io_oeb[1]     = ~sd_oe;
  assign io_out[1]     =  sd_o;
  assign unused_00     =  io_in[1];

  assign io_oeb[2]     =  1'b1;
  assign io_out[2]     =  1'b0; 
  assign sd_i          =  io_in[2];

  assign io_oeb[3]     = ~sd_oe;
  assign io_out[3]     =  ss_o[0];
  assign unused_01     =  io_in[3];

  assign io_oeb[4]     =  1'b0;
  assign io_out[4]     =  sclk_o;
  assign unused_02     =  io_in[4];

  // UART 
  assign io_oeb[5]     =  1'b1;
  assign io_out[2]     =  1'b0;
  assign uart_rx       =  io_in[5];

  assign io_oeb[6]     =  1'b0;
  assign io_out[6]     =  uart_tx;
  assign unused_03     =  io_in[6];
    
  // Programming Button 
  assign io_oeb[7]     =  1'b1;
  assign io_out[2]     =  1'b0;
  assign prog          =  io_in[7];

  // GPIO 0-18
  assign io_oeb[25:8]  = ~gpio_oe[18:0];
  assign gpio_i[18:0]  =  io_in  [25:8];
  assign io_out[25:8]  =  gpio_o [18:0];

  assign io_oeb[26]    = ~gpio_oe[31];
  assign gpio_i[31]    =  io_in  [26];
  assign io_out[26]    =  gpio_o [31];
  
  // GPIO 19-21, SPI SS
  assign io_oeb[27]    = ~(sd_oe | gpio_oe[19]);
  assign io_out[27]    =  sd_oe ?  ss_o[1] :  gpio_o [19];  // SPI slave sel[1]
  assign gpio_i[19]    =  io_in[27];

  assign io_oeb[28]    = ~(sd_oe | gpio_oe[20]);
  assign io_out[28]    =  sd_oe ?  ss_o[2] :  gpio_o [20];  // SPI slave sel[2]
  assign gpio_i[20]    =  io_in[28];

  assign io_oeb[29]    = ~(sd_oe | gpio_oe[21]);
  assign io_out[29]    =  sd_oe ?  ss_o[3] :  gpio_o [21];  // SPI slave sel[3]
  assign gpio_i[21]    =  io_in[29];

  // GPIO 22-24
  assign io_oeb[30]    =  ~gpio_oe[22];
  assign io_out[30]    =   gpio_o [22];  
  assign gpio_i[22]    =   io_in[30];

  assign io_oeb[31]    =  ~gpio_oe[23];
  assign io_out[31]    =   gpio_o [23];  
  assign gpio_i[23]    =   io_in[31];

  assign io_oeb[32]    =  ~gpio_oe[24];
  assign io_out[32]    =   gpio_o [24];  
  assign gpio_i[24]    =   io_in[32];
  
  // GPIO 25-26, PWM 1, 2
  assign io_oeb[33]     = ~(pwm1_oe | gpio_oe[25]);  // PWM1 
  assign io_out[33]     =   pwm1_oe ?  pwm_o_1 : gpio_o [25];
  assign gpio_i[25]     =   io_in[33];

  assign io_oeb[34]     = ~(pwm2_oe | gpio_oe[26]);  // PWM2 
  assign io_out[34]     =  pwm2_oe  ?  pwm_o_2 :  gpio_o [26];
  assign gpio_i[26]     =  io_in[34];

  // GPIO 27-29
  assign io_oeb[37:35]  = ~gpio_oe[29:27];
  assign gpio_i[29:27]  =  io_in  [37:35];
  assign io_out[37:35]  =  gpio_o [29:27];

  // Logic Analyzer ports
  assign clks_per_bit  = la_data_in[15:0];

  azadi_soc_top soc_top(
  `ifdef USE_POWER_PINS
    .VPWR(vccd1),
    .VGND(vssd1),
  `endif
    .clk_i(wb_clk_i),
    .rst_ni(wb_rst_i),
    .prog(prog),

    // Clocks per bits
    .clks_per_bit(clks_per_bit), 

    // gpios interface
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_oe(gpio_oe),

    // uart-periph interface
    .uart_tx(uart_tx), // output
    .uart_rx(uart_rx), // input

    // PWM interface  
    .pwm_o(pwm_o_1),
    .pwm_o_2(pwm_o_2),
    .pwm1_oe(pwm1_oe),
    .pwm2_oe(pwm2_oe),

    // SPI interface
    .ss_o(ss_o),        // [3:0] 
    .sclk_o(sclk_o),      
    .sd_o(sd_o),
    .sd_oe(sd_oe),       
    .sd_i(sd_i)
  );

endmodule
