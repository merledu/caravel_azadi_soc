// Designed by a Team at Micro Electronics Research Lab, Usman Institute of Technology.
// https://www.merledupk.org

module azadi_soc_top_caravel #(
    parameter BITS = 32
) (
  `ifdef USE_POWER_PINS
      inout vdda1,	// User area 1 3.3V supply
      inout vdda2,	// User area 2 3.3V supply
      inout vssa1,	// User area 1 analog ground
      inout vssa2,	// User area 2 analog ground
      inout vccd1,	// User area 1 1.8V supply
      inout vccd2,	// User area 2 1.8v supply
      inout vssd1,	// User area 1 digital ground
      inout vssd2,	// User area 2 digital ground
  `endif

    // Wishbone Slave ports (WB MI A)
    input         wb_clk_i,
    input         wb_rst_i,
    input         wbs_stb_i,
    input         wbs_cyc_i,
    input         wbs_we_i,
    input [3:0]   wbs_sel_i,
    input [31:0]  wbs_dat_i,
    input [31:0]  wbs_adr_i,
    output        wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,  // MPRJ_IO_PADS = 38
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

  logic clk_i;  
  logic rst_ni; 
  logic prog;
  
  // Clocks per bit
  logic [15:0] clk_per_bits;  

  // gpios interface
  logic [31:0] gpio_i;
  logic [31:0] gpio_o;
  logic [31:0] gpio_oe;

  // jtag interface 
  logic jtag_tck_i;   
  logic jtag_tms_i;   
  logic jtag_trst_ni; 
  logic jtag_tdi_i;   
  logic jtag_tdo_o;   
  logic jtag_tdo_oe_o;

  // uart-periph interface
  logic uart_tx;
  logic tx_en_o;
  logic uart_rx;

  // PWM interface  
  logic pwm_o_1;
  logic pwm_o_2;
  logic pwm1_oe;
  logic pwm2_oe;

  // SPI interface
  logic ss_o;        
  logic sclk_o;      
  logic sd_o;
  logic sd_oe;       
  logic sd_i;

  // Note: Output enable is active low for IO pads
  assign io_oeb[0]    =  ~jtag_tdo_oe_o;
  assign jtag_tdi_i   =   io_in[0];
  assign io_out[0]    =   jtag_tdo_o;

  assign io_oeb[0]     =  jtag_tdo_oe_o ? ~jtag_tdo_oe_o : ~gpio_oe[0];  
  assign io_out[0]     =  jtag_tdo_oe_o ?  jtag_tdo_oe_o :  gpio_o [0];  // JTAG data IO
  assign gpio_i[0]     =  io_in[0]; 

  assign io_oeb[1]     =  pwm2_oe ? ~pwm2_oe : ~gpio_oe[1];  // PWM2 is prior
  assign io_out[1]     =  pwm2_oe ?  pwm_o_2 :  gpio_o [1];
  assign gpio_i[1]     =  io_in[1];
  
  assign io_oeb[25:2]  = ~gpio_oe[25:2];
  assign gpio_i[25:2]  =  io_in  [25:2];
  assign io_out[25:2]  =  gpio_o [25:2];

  assign io_oeb[26]    =  sd_oe ? ~sd_oe   : ~gpio_oe[26]; 
  assign io_out[26]    =  sd_oe ?  ss_o[0] :  gpio_o [26];  // SPI slave sel[0]
  assign gpio_i[26]    =  io_in[26];
  
  assign io_oeb[27]    =  sd_oe ? ~sd_oe   : ~gpio_oe[27];
  assign io_out[27]    =  sd_oe ?  sd_o[1] :  gpio_o [27];  // SPI slave sel[1]
  assign gpio_i[27]    =  io_in[27];

  assign io_oeb[28]    =  sd_oe ? ~sd_oe   : ~gpio_oe[28];
  assign io_out[28]    =  sd_oe ?  sd_o[2] :  gpio_o [28];  // SPI slave sel[2]
  assign gpio_i[28]    =  io_in[28];

  assign io_oeb[29]    =  sd_oe ? ~sd_oe   : ~gpio_oe[29];
  assign io_out[29]    =  sd_oe ?  sd_o[3] :  gpio_o [29];  // SPI slave sel[3]
  assign gpio_i[29]    =  io_in[29];
  
  assign io_oeb[30]    =  sd_oe ? ~sd_oe   : ~gpio_oe[30];
  assign io_out[30]    =  sd_oe ?  sclk_o  :  gpio_o [30];  // SPI clock_out
  assign gpio_i[30]    =  io_in[30]

  assign io_oeb[31]    = ~(sd_oe | gpio_oe[31]);
  assign io_out[31]    =  sd_oe ? sd_o : gpio_o[31];
  assign gpio_i[31]    =  io_in[31];
  assign sd_i  [31]    =  io_in[31];

  assign io_oeb[32]    =  1'b1;
  assign jtag_tck_i    =  io_in[32];
  assign io_out[32]    =  1'b0;
  
  assign io_oeb[33]    =  1'b1;
  assign jtag_tms_i    =  io_in[33];
  assign io_out[33]    =  1'b0;

  assign jtag_trst_ni  =  io_in[34];
  assign io_oeb[34]    =  1'b1;
  assign io_out[34]    =  1'b0;

  assign io_oeb[35]    = ~jtag_tdo_oe_o;
  assign jtag_tdi_i    =  io_in[35];
  assign io_out[35]    =  jtag_tdo_o;

  // assign io_oeb[36]    = ~tx_en_o;
  // assign io_out[36]    =  uart_tx;

  assign prog          = io_in[35];
  assign io_oeb        = 1'b1;
  
  assign io_oeb[37]    =  1'b1;
  assign uart_rx       =  io_in[37];
  assign io_out[37]    =  1'b0;  

  // Logic Analyzer ports
  assign la_oenb[15:0] = 16'hffff;
  assign clk_per_bits  = la_data_in[15:0];

  azadi_soc_top azadi_soc(
    .clk_i(wb_clk_i),
    .rst_ni(wb_rst_i),
    .prog(prog),

    // Clocks per bits
    .clk_per_bits(clk_per_bits), 

    // gpios interface
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_oe(gpio_oe),

    // jtag interface 
    .jtag_tck_i(jtag_tck_i),
    .jtag_tms_i(jtag_tms_i),
    .jtag_trst_ni(jtag_trst_ni),
    .jtag_tdi_i(jtag_tdi_i),
    .jtag_tdo_o(jtag_tdo_o),
    .jtag_tdo_oe_o(jtag_tdo_oe_o),

    // uart-periph interface
    .uart_tx(uart_tx),
    .tx_en_o(tx_en_o),
    .uart_rx(uart_rx),

    // PWM interface  
    .pwm_o(pwm_o_1),
    .pwm_o_2(pwm_o_2),
    .pwm1_oe(pwm1_oe),
    .pwm2_oe(pwm2_oe),

    // SPI interface
    .ss_o(ss_o),        
    .sclk_o(sclk_o),      
    .sd_o(sd_o),
    .sd_oe(sd_oe),       
    .sd_i(sd_i)
  );

endmodule