/*azadi_soc_top_conv-v0.6*/

`default_nettype wire
module azadi_soc_top (
	`ifdef USE_POWER_PINS
    inout VPWR,	// User area 1 1.8V supply
    inout VGND,	// User area 1 digital ground
  `endif
	clk_i,
	rst_ni,
	prog,
	clks_per_bit,
	gpio_i,
	gpio_o,
	gpio_oe,
	uart_tx,
	uart_rx,
	pwm_o,
	pwm_o_2,
	pwm1_oe,
	pwm2_oe,
	ss_o,
	sclk_o,
	sd_o,
	sd_oe,
	sd_i
);
	input wire clk_i;
	input wire rst_ni;
	input wire prog;
	input wire [15:0] clks_per_bit;
	input wire [31:0] gpio_i;
	output wire [31:0] gpio_o;
	output wire [31:0] gpio_oe;
	output wire uart_tx;
	input wire uart_rx;
	output wire pwm_o;
	output wire pwm_o_2;
	output wire pwm1_oe;
	output wire pwm2_oe;
	output wire [3:0] ss_o;
	output wire sclk_o;
	output wire sd_o;
	output wire sd_oe;
	input wire sd_i;
	wire prog_rst_n;
	wire system_rst_ni;
	wire [31:0] gpio_in;
	wire [31:0] gpio_out;
	assign gpio_in = gpio_i;
	assign gpio_o = gpio_out;
	wire instr_valid;
	wire [11:0] tlul_addr;
	wire req_i;
	wire [31:0] tlul_data;
	wire instr_csb;
	wire [11:0] instr_addr;
	wire [31:0] instr_wdata;
	wire [3:0] instr_wmask;
	wire instr_we;
	wire [31:0] instr_rdata;
	wire data_csb;
	wire [11:0] data_addr;
	wire [31:0] data_wdata;
	wire [3:0] data_wmask;
	wire data_we;
	wire [31:0] data_rdata;
	wire [31:0] iccm_ctrl_data;
	wire iccm_ctrl_we;
	wire [11:0] iccm_ctrl_addr_o;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	wire [85:0] ifu_to_xbar;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	wire [51:0] xbar_to_ifu;
	wire [85:0] xbar_to_iccm;
	wire [51:0] iccm_to_xbar;
	wire [85:0] lsu_to_xbar;
	wire [51:0] xbar_to_lsu;
	wire [85:0] xbar_to_dccm;
	wire [51:0] dccm_to_xbar;
	wire [85:0] xbarp_to_gpio;
	wire [51:0] gpio_to_xbarp;
	wire [85:0] plic_req;
	wire [51:0] plic_resp;
	wire [85:0] xbar_to_uart;
	wire [51:0] uart_to_xbar;
	wire [85:0] xbar_to_timer;
	wire [51:0] timer_to_xbar;
	wire [85:0] xbar_to_pwm;
	wire [51:0] pwm_to_xbar;
	wire [85:0] xbar_to_spi;
	wire [51:0] spi_to_xbar;
	wire [35:0] intr_vector;
	wire [31:0] intr_gpio;
	wire intr_uart0_tx_watermark;
	wire intr_uart0_rx_watermark;
	wire intr_uart0_tx_empty;
	wire intr_uart0_rx_overflow;
	wire intr_uart0_rx_frame_err;
	wire intr_uart0_rx_break_err;
	wire intr_uart0_rx_timeout;
	wire intr_uart0_rx_parity_err;
	wire intr_req;
	wire intr_srx;
	wire intr_stx;
	wire intr_timer;
	wire intr_u_tx;
	assign intr_vector = {intr_srx, intr_stx, intr_u_tx, intr_gpio, 1'b0};
	localparam integer brq_pkg_RV32BNone = 0;
	localparam integer brq_pkg_RV32MSlow = 1;
	localparam integer brq_pkg_RegFileFF = 0;
	brq_core_top #(
		.PMPEnable(1'b0),
		.PMPGranularity(0),
		.PMPNumRegions(4),
		.MHPMCounterNum(0),
		.MHPMCounterWidth(40),
		.RV32E(1'b0),
		.RV32M(brq_pkg_RV32MSlow),
		.RV32B(brq_pkg_RV32BNone),
		.RegFile(brq_pkg_RegFileFF),
		.BranchTargetALU(1'b0),
		.WritebackStage(1'b1),
		.ICache(1'b0),
		.ICacheECC(1'b0),
		.BranchPredictor(1'b0),
		.DbgTriggerEn(1'b1),
		.DbgHwBreakNum(1),
		.Securebrq(1'b0),
		.DmHaltAddr(1'sb0),
		.DmExceptionAddr(1'sb0)
	) u_top(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i_i(xbar_to_ifu),
		.tl_i_o(ifu_to_xbar),
		.tl_d_i(xbar_to_lsu),
		.tl_d_o(lsu_to_xbar),
		.hart_id_i(32'b00000000000000000000000000000000),
		.boot_addr_i(32'h20000000),
		.irq_software_i(1'b0),
		.irq_timer_i(intr_timer),
		.irq_external_i(intr_req),
		.irq_fast_i({15 {1'sb0}}),
		.irq_nm_i(1'b0),
		.debug_req_i(1'b0),
		.fetch_enable_i(1'b1),
		.alert_minor_o(),
		.alert_major_o(),
		.core_sleep_o()
	);
	tl_xbar_main main_swith(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_brqif_i(ifu_to_xbar),
		.tl_brqif_o(xbar_to_ifu),
		.tl_brqlsu_i(lsu_to_xbar),
		.tl_brqlsu_o(xbar_to_lsu),
		.tl_iccm_o(xbar_to_iccm),
		.tl_iccm_i(iccm_to_xbar),
		.tl_dccm_o(xbar_to_dccm),
		.tl_dccm_i(dccm_to_xbar),
		.tl_timer0_o(xbar_to_timer),
		.tl_timer0_i(timer_to_xbar),
		.tl_uart_o(xbar_to_uart),
		.tl_uart_i(uart_to_xbar),
		.tl_spi_o(xbar_to_spi),
		.tl_spi_i(spi_to_xbar),
		.tl_pwm_o(xbar_to_pwm),
		.tl_pwm_i(pwm_to_xbar),
		.tl_gpio_o(xbarp_to_gpio),
		.tl_gpio_i(gpio_to_xbarp),
		.tl_plic_o(plic_req),
		.tl_plic_i(plic_resp)
	);
	rv_timer timer0(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbar_to_timer),
		.tl_o(timer_to_xbar),
		.intr_timer_expired_0_0_o(intr_timer)
	);
	pwm_top u_pwm(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbar_to_pwm),
		.tl_o(pwm_to_xbar),
		.pwm_o(pwm_o),
		.pwm_o_2(pwm_o_2),
		.pwm1_oe(pwm1_oe),
		.pwm2_oe(pwm2_oe)
	);
	spi_top u_spi_host(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbar_to_spi),
		.tl_o(spi_to_xbar),
		.intr_rx_o(intr_srx),
		.intr_tx_o(intr_stx),
		.ss_o(ss_o),
		.sclk_o(sclk_o),
		.sd_o(sd_o),
		.sd_oe(sd_oe),
		.sd_i(sd_i)
	);
	gpio GPIO(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbarp_to_gpio),
		.tl_o(gpio_to_xbarp),
		.cio_gpio_i(gpio_in),
		.cio_gpio_o(gpio_out),
		.cio_gpio_en_o(gpio_oe),
		.intr_gpio_o(intr_gpio)
	);
	wire prog_rst_ni;
	rstmgr reset_manager(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.prog_rst_ni(prog_rst_ni),
		.sys_rst_ni(system_rst_ni)
	);
	rv_plic intr_controller(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(plic_req),
		.tl_o(plic_resp),
		.intr_src_i(intr_vector),
		.irq_o(intr_req),
		.msip_o()
	);
	uart_top u_uart(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbar_to_uart),
		.tl_o(uart_to_xbar),
		.tx_o(uart_tx),
		.rx_i(uart_rx),
		.intr_tx(intr_u_tx)
	);
	wire rx_dv_i;
	wire [7:0] rx_byte_i;
	iccm_controller iccm_controller(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.prog_i(prog),
		.rx_dv_i(rx_dv_i),
		.rx_byte_i(rx_byte_i),
		.we_o(iccm_ctrl_we),
		.addr_o(iccm_ctrl_addr_o),
		.wdata_o(iccm_ctrl_data),
		.reset_o(prog_rst_ni)
	);
	uart_rx_prog u_uart_rx_prog(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.i_Rx_Serial(uart_rx),
		.CLKS_PER_BIT(clks_per_bit),
		.o_Rx_DV(rx_dv_i),
		.o_Rx_Byte(rx_byte_i)
	);

	instr_mem_top iccm_adapter(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_i(xbar_to_iccm),
		.tl_o(iccm_to_xbar),
		.iccm_ctrl_addr(iccm_ctrl_addr_o),
		.iccm_ctrl_wdata(iccm_ctrl_data),
		.iccm_ctrl_we(iccm_ctrl_we),
		.prog_rst_ni(prog_rst_ni),
		.csb(instr_csb),
		.addr_o(instr_addr),
		.wdata_o(instr_wdata),
		.wmask_o(instr_wmask),
		.we_o(instr_we),
		.rdata_i(instr_rdata)
	);

    wire [3:0] WE_instr;
    assign WE_instr = instr_wmask & {4{~instr_we}};

    DFFRAM #(
			.COLS(2)
		)u_iccm(
	    `ifdef USE_POWER_PINS
	        .VPWR(VPWR),
	        .VGND(VGND),
    	`endif
		.CLK(clk_i),
		.WE(WE_instr),
		.EN(~instr_csb),
		.Di(instr_wdata),
		.Do(instr_rdata),
		.A(instr_addr[8:0])
	);
	data_mem_top dccm_adapter(
		.clk_i(clk_i),
		.rst_ni(system_rst_ni),
		.tl_d_i(xbar_to_dccm),
		.tl_d_o(dccm_to_xbar),
		.csb(data_csb),
		.addr_o(data_addr),
		.wdata_o(data_wdata),
		.wmask_o(data_wmask),
		.we_o(data_we),
		.rdata_i(data_rdata)
	);
	wire [3:0] WE_data;
    assign WE_data = data_wmask & {4{~data_we}};
    DFFRAM #(
			.COLS(2)
		)u_dccm(
	    `ifdef USE_POWER_PINS
	        .VPWR(VPWR),
	        .VGND(VGND),
    	`endif
		.CLK(clk_i),
		.WE(WE_data),
		.EN(~data_csb),
		.Di(data_wdata),
		.Do(data_rdata),
		.A(data_addr[8:0])
	);
endmodule
module brq_core (
	clk_i,
	rst_ni,
	hart_id_i,
	boot_addr_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	data_err_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	debug_req_i,
	fetch_enable_i,
	alert_minor_o,
	alert_major_o,
	core_sleep_o
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	localparam integer brq_pkg_RegFileFF = 0;
	parameter integer RegFile = brq_pkg_RegFileFF;
	localparam integer brq_pkg_RV32FSingle = 1;
	parameter integer RVF = brq_pkg_RV32FSingle;
	parameter [31:0] FloatingPoint = 1'b1;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b1;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] Securebrq = 1'b0;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire data_err_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	input wire fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_o;
	output wire core_sleep_o;
	wire test_en_i;
	assign test_en_i = 1'b0;
	localparam [31:0] W = 32;
	wire fp_flush;
	wire in_ready_c2fpu;
	wire in_valid_c2fpu;
	wire out_ready_fpu2c;
	wire out_valid_fpu2c;
	wire valid_id_fpu;
	wire fp_rm_dynamic;
	wire fp_alu_op_mod;
	wire [4:0] fp_rf_raddr_a;
	wire [4:0] fp_rf_raddr_b;
	wire [4:0] fp_rf_raddr_c;
	wire [31:0] fp_rf_rdata_a;
	wire [31:0] fp_rf_rdata_b;
	wire [31:0] fp_rf_rdata_c;
	wire fp_rf_wen_id;
	wire is_fp_instr;
	wire [95:0] fp_operands;
	wire fp_busy;
	wire fpu_busy_idu;
	wire [31:0] fp_result;
	wire [31:0] data_wb;
	wire [4:0] fp_rf_waddr_id;
	wire [4:0] fp_rf_waddr_wb;
	wire fp_rf_we;
	wire fp_rf_wen_wb;
	wire use_fp_rs1;
	wire use_fp_rs2;
	wire use_fp_rd;
	wire fp_rf_write_wb;
	wire [31:0] rf_int_fp_lsu;
	wire fp_swap_oprnds;
	wire fpu_is_busy;
	wire fp_load;
	wire [31:0] fp_rf_wdata_wb;
	wire [4:0] fp_status;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	wire [3:0] fp_operation;
	wire [2:0] fp_rounding_mode;
	wire [2:0] fp_frm_csr;
	wire [2:0] fp_frm_fpnew;
	wire [3:0] fp_alu_operator;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	wire [1:0] fp_src_fmt;
	wire [1:0] fp_dst_fmt;
	localparam [31:0] PMP_NUM_CHAN = 2;
	localparam [0:0] DataIndTiming = Securebrq;
	localparam [0:0] DummyInstructions = Securebrq;
	localparam [0:0] PCIncrCheck = Securebrq;
	localparam [0:0] ShadowCSR = Securebrq;
	localparam [0:0] SpecBranch = PMPEnable & (PMPNumRegions == 16);
	localparam [0:0] RegFileECC = Securebrq;
	localparam [31:0] RegFileDataWidth = (RegFileECC ? 39 : 32);
	wire dummy_instr_id;
	wire instr_valid_id;
	wire instr_new_id;
	wire [31:0] instr_rdata_id;
	wire [31:0] instr_rdata_alu_id;
	wire [15:0] instr_rdata_c_id;
	wire instr_is_compressed_id;
	wire instr_perf_count_id;
	wire instr_fetch_err;
	wire instr_fetch_err_plus2;
	wire illegal_c_insn_id;
	wire [31:0] pc_if;
	wire [31:0] pc_id;
	wire [31:0] pc_wb;
	wire [67:0] imd_val_d_ex;
	wire [67:0] imd_val_q_ex;
	wire [1:0] imd_val_we_ex;
	wire data_ind_timing;
	wire dummy_instr_en;
	wire [2:0] dummy_instr_mask;
	wire dummy_instr_seed_en;
	wire [31:0] dummy_instr_seed;
	wire icache_enable;
	wire icache_inval;
	wire pc_mismatch_alert;
	wire csr_shadow_err;
	wire instr_first_cycle_id;
	wire instr_valid_clear;
	wire pc_set;
	wire pc_set_spec;
	wire [2:0] pc_mux_id;
	wire [1:0] exc_pc_mux_id;
	wire [5:0] exc_cause;
	wire lsu_load_err;
	wire lsu_store_err;
	wire lsu_addr_incr_req;
	wire [31:0] lsu_addr_last;
	wire [31:0] branch_target_ex;
	wire branch_decision;
	wire ctrl_busy;
	wire if_busy;
	wire lsu_busy;
	wire core_busy_d;
	reg core_busy_q;
	wire [4:0] rf_raddr_a;
	wire [31:0] rf_rdata_a;
	wire [4:0] rf_raddr_b;
	wire [31:0] rf_rdata_b;
	wire rf_ren_a;
	wire rf_ren_b;
	wire [4:0] rf_waddr_wb;
	wire [31:0] rf_wdata_wb;
	wire [31:0] rf_wdata_fwd_wb;
	wire [31:0] rf_wdata_lsu;
	wire rf_we_wb;
	wire rf_we_lsu;
	wire [4:0] rf_waddr_id;
	wire [31:0] rf_wdata_id;
	wire rf_we_id;
	wire rf_rd_a_wb_match;
	wire rf_rd_b_wb_match;
	wire [5:0] alu_operator_ex;
	wire [31:0] alu_operand_a_ex;
	wire [31:0] alu_operand_b_ex;
	wire [31:0] bt_a_operand;
	wire [31:0] bt_b_operand;
	wire [31:0] alu_adder_result_ex;
	wire [31:0] result_ex;
	wire mult_en_ex;
	wire div_en_ex;
	wire mult_sel_ex;
	wire div_sel_ex;
	wire [1:0] multdiv_operator_ex;
	wire [1:0] multdiv_signed_mode_ex;
	wire [31:0] multdiv_operand_a_ex;
	wire [31:0] multdiv_operand_b_ex;
	wire multdiv_ready_id;
	wire csr_access;
	wire [1:0] csr_op;
	wire csr_op_en;
	wire [11:0] csr_addr;
	wire [31:0] csr_rdata;
	wire [31:0] csr_wdata;
	wire illegal_csr_insn_id;
	wire lsu_we;
	wire [1:0] lsu_type;
	wire lsu_sign_ext;
	wire lsu_req;
	wire [31:0] lsu_wdata;
	wire lsu_req_done;
	wire id_in_ready;
	wire ex_valid;
	wire lsu_resp_valid;
	wire lsu_resp_err;
	wire instr_req_int;
	wire en_wb;
	wire [1:0] instr_type_wb;
	wire ready_wb;
	wire rf_write_wb;
	wire outstanding_load_wb;
	wire outstanding_store_wb;
	wire irq_pending;
	wire nmi_mode;
	wire [17:0] irqs;
	wire csr_mstatus_mie;
	wire [31:0] csr_mepc;
	wire [31:0] csr_depc;
	wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr;
	wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg;
	wire [0:1] pmp_req_err;
	wire instr_req_out;
	wire data_req_out;
	wire csr_save_if;
	wire csr_save_id;
	wire csr_save_wb;
	wire csr_restore_mret_id;
	wire csr_restore_dret_id;
	wire csr_save_cause;
	wire csr_mtvec_init;
	wire [31:0] csr_mtvec;
	wire [31:0] csr_mtval;
	wire csr_mstatus_tw;
	wire [1:0] priv_mode_id;
	wire [1:0] priv_mode_if;
	wire [1:0] priv_mode_lsu;
	wire debug_mode;
	wire [2:0] debug_cause;
	wire debug_csr_save;
	wire debug_single_step;
	wire debug_ebreakm;
	wire debug_ebreaku;
	wire trigger_match;
	wire instr_id_done;
	wire instr_done_wb;
	wire perf_instr_ret_wb;
	wire perf_instr_ret_compressed_wb;
	wire perf_iside_wait;
	wire perf_dside_wait;
	wire perf_mul_wait;
	wire perf_div_wait;
	wire perf_jump;
	wire perf_branch;
	wire perf_tbranch;
	wire perf_load;
	wire perf_store;
	wire illegal_insn_id;
	wire unused_illegal_insn_id;
	wire clk;
	wire clock_en;
	assign core_busy_d = ((ctrl_busy | if_busy) | lsu_busy) | fp_busy;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			core_busy_q <= 1'b0;
		else
			core_busy_q <= core_busy_d;
	reg fetch_enable_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			fetch_enable_q <= 1'b0;
		else if (fetch_enable_i)
			fetch_enable_q <= 1'b1;
	assign clock_en = fetch_enable_q & (((core_busy_q | debug_req_i) | irq_pending) | irq_nm_i);
	assign core_sleep_o = ~clock_en;
	prim_clock_gating core_clock_gate_i(
		.clk_i(clk_i),
		.en_i(1'b1),
		.test_en_i(test_en_i),
		.clk_o(clk)
	);
	localparam [31:0] brq_pkg_PMP_I = 0;
	brq_ifu #(
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr),
		.DummyInstructions(DummyInstructions),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.PCIncrCheck(PCIncrCheck),
		.BranchPredictor(BranchPredictor)
	) if_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.boot_addr_i(boot_addr_i),
		.req_i(instr_req_int),
		.instr_req_o(instr_req_out),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_i(instr_err_i),
		.instr_pmp_err_i(pmp_req_err[brq_pkg_PMP_I]),
		.instr_valid_id_o(instr_valid_id),
		.instr_new_id_o(instr_new_id),
		.instr_rdata_id_o(instr_rdata_id),
		.instr_rdata_alu_id_o(instr_rdata_alu_id),
		.instr_rdata_c_id_o(instr_rdata_c_id),
		.instr_is_compressed_id_o(instr_is_compressed_id),
		.instr_fetch_err_o(instr_fetch_err),
		.instr_fetch_err_plus2_o(instr_fetch_err_plus2),
		.illegal_c_insn_id_o(illegal_c_insn_id),
		.pc_if_o(pc_if),
		.pc_id_o(pc_id),
		.instr_valid_clear_i(instr_valid_clear),
		.pc_set_i(pc_set),
		.pc_set_spec_i(pc_set_spec),
		.pc_mux_i(pc_mux_id),
		.exc_pc_mux_i(exc_pc_mux_id),
		.branch_target_ex_i(branch_target_ex),
		.csr_mepc_i(csr_mepc),
		.csr_depc_i(csr_depc),
		.csr_mtvec_i(csr_mtvec),
		.csr_mtvec_init_o(csr_mtvec_init),
		.id_in_ready_i(id_in_ready),
		.pc_mismatch_alert_o(pc_mismatch_alert),
		.if_busy_o(if_busy)
	);
	assign perf_iside_wait = id_in_ready & ~instr_valid_id;
	assign instr_req_o = instr_req_out & ~pmp_req_err[brq_pkg_PMP_I];
	wire use_fp_rs3;
	brq_idu #(
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU),
		.DataIndTiming(DataIndTiming),
		.SpecBranch(SpecBranch),
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor)
	) id_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.ctrl_busy_o(ctrl_busy),
		.illegal_insn_o(illegal_insn_id),
		.instr_valid_i(instr_valid_id),
		.instr_rdata_i(instr_rdata_id),
		.instr_rdata_alu_i(instr_rdata_alu_id),
		.instr_rdata_c_i(instr_rdata_c_id),
		.instr_is_compressed_i(instr_is_compressed_id),
		.branch_decision_i(branch_decision),
		.instr_first_cycle_id_o(instr_first_cycle_id),
		.instr_valid_clear_o(instr_valid_clear),
		.id_in_ready_o(id_in_ready),
		.instr_req_o(instr_req_int),
		.pc_set_o(pc_set),
		.pc_set_spec_o(pc_set_spec),
		.pc_mux_o(pc_mux_id),
		.exc_pc_mux_o(exc_pc_mux_id),
		.exc_cause_o(exc_cause),
		.icache_inval_o(icache_inval),
		.instr_fetch_err_i(instr_fetch_err),
		.instr_fetch_err_plus2_i(instr_fetch_err_plus2),
		.illegal_c_insn_i(illegal_c_insn_id),
		.pc_id_i(pc_id),
		.ex_valid_i(valid_id_fpu),
		.lsu_resp_valid_i(lsu_resp_valid),
		.alu_operator_ex_o(alu_operator_ex),
		.alu_operand_a_ex_o(alu_operand_a_ex),
		.alu_operand_b_ex_o(alu_operand_b_ex),
		.imd_val_q_ex_o(imd_val_q_ex),
		.imd_val_d_ex_i(imd_val_d_ex),
		.imd_val_we_ex_i(imd_val_we_ex),
		.bt_a_operand_o(bt_a_operand),
		.bt_b_operand_o(bt_b_operand),
		.mult_en_ex_o(mult_en_ex),
		.div_en_ex_o(div_en_ex),
		.mult_sel_ex_o(mult_sel_ex),
		.div_sel_ex_o(div_sel_ex),
		.multdiv_operator_ex_o(multdiv_operator_ex),
		.multdiv_signed_mode_ex_o(multdiv_signed_mode_ex),
		.multdiv_operand_a_ex_o(multdiv_operand_a_ex),
		.multdiv_operand_b_ex_o(multdiv_operand_b_ex),
		.multdiv_ready_id_o(multdiv_ready_id),
		.csr_access_o(csr_access),
		.csr_op_o(csr_op),
		.csr_op_en_o(csr_op_en),
		.csr_save_if_o(csr_save_if),
		.csr_save_id_o(csr_save_id),
		.csr_save_wb_o(csr_save_wb),
		.csr_restore_mret_id_o(csr_restore_mret_id),
		.csr_restore_dret_id_o(csr_restore_dret_id),
		.csr_save_cause_o(csr_save_cause),
		.csr_mtval_o(csr_mtval),
		.priv_mode_i(priv_mode_id),
		.csr_mstatus_tw_i(csr_mstatus_tw),
		.illegal_csr_insn_i(illegal_csr_insn_id),
		.data_ind_timing_i(data_ind_timing),
		.lsu_req_o(lsu_req),
		.lsu_we_o(lsu_we),
		.lsu_type_o(lsu_type),
		.lsu_sign_ext_o(lsu_sign_ext),
		.lsu_wdata_o(lsu_wdata),
		.lsu_req_done_i(lsu_req_done),
		.lsu_addr_incr_req_i(lsu_addr_incr_req),
		.lsu_addr_last_i(lsu_addr_last),
		.lsu_load_err_i(lsu_load_err),
		.lsu_store_err_i(lsu_store_err),
		.csr_mstatus_mie_i(csr_mstatus_mie),
		.irq_pending_i(irq_pending),
		.irqs_i(irqs),
		.irq_nm_i(irq_nm_i),
		.nmi_mode_o(nmi_mode),
		.debug_mode_o(debug_mode),
		.debug_cause_o(debug_cause),
		.debug_csr_save_o(debug_csr_save),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step),
		.debug_ebreakm_i(debug_ebreakm),
		.debug_ebreaku_i(debug_ebreaku),
		.trigger_match_i(trigger_match),
		.result_ex_i(data_wb),
		.csr_rdata_i(csr_rdata),
		.rf_raddr_a_o(rf_raddr_a),
		.rf_rdata_a_i(rf_rdata_a),
		.rf_raddr_b_o(rf_raddr_b),
		.rf_rdata_b_i(rf_int_fp_lsu),
		.rf_ren_a_o(rf_ren_a),
		.rf_ren_b_o(rf_ren_b),
		.rf_waddr_id_o(rf_waddr_id),
		.rf_wdata_id_o(rf_wdata_id),
		.rf_we_id_o(rf_we_id),
		.rf_rd_a_wb_match_o(rf_rd_a_wb_match),
		.rf_rd_b_wb_match_o(rf_rd_b_wb_match),
		.rf_waddr_wb_i(rf_waddr_wb),
		.rf_wdata_fwd_wb_i(rf_wdata_fwd_wb),
		.rf_write_wb_i(rf_write_wb),
		.en_wb_o(en_wb),
		.instr_type_wb_o(instr_type_wb),
		.instr_perf_count_id_o(instr_perf_count_id),
		.ready_wb_i(ready_wb),
		.outstanding_load_wb_i(outstanding_load_wb),
		.outstanding_store_wb_i(outstanding_store_wb),
		.perf_jump_o(perf_jump),
		.perf_branch_o(perf_branch),
		.perf_tbranch_o(perf_tbranch),
		.perf_dside_wait_o(perf_dside_wait),
		.perf_mul_wait_o(perf_mul_wait),
		.perf_div_wait_o(perf_div_wait),
		.instr_id_done_o(instr_id_done),
		.fp_rounding_mode_o(fp_rounding_mode),
		.fp_rf_rdata_a_i(fp_rf_rdata_a),
		.fp_rf_rdata_b_i(fp_rf_rdata_b),
		.fp_rf_rdata_c_i(fp_rf_rdata_c),
		.fp_rf_raddr_a_o(fp_rf_raddr_a),
		.fp_rf_raddr_b_o(fp_rf_raddr_b),
		.fp_rf_raddr_c_o(fp_rf_raddr_c),
		.fp_rf_waddr_o(fp_rf_waddr_id),
		.fp_rf_we_o(fp_rf_wen_id),
		.fp_alu_operator_o(fp_alu_operator),
		.fp_alu_op_mod_o(fp_alu_op_mod),
		.fp_src_fmt_o(fp_src_fmt),
		.fp_dst_fmt_o(fp_dst_fmt),
		.fp_rm_dynamic_o(fp_rm_dynamic),
		.fp_flush_o(fp_flush),
		.is_fp_instr_o(is_fp_instr),
		.use_fp_rs1_o(use_fp_rs1),
		.use_fp_rs2_o(use_fp_rs2),
		.use_fp_rs3_o(use_fp_rs3),
		.use_fp_rd_o(use_fp_rd),
		.fpu_busy_i(fpu_busy_idu),
		.fp_rf_write_wb_i(fp_rf_write_wb),
		.fp_rf_wdata_fwd_wb_i(fp_rf_wdata_wb),
		.fp_operands_o(fp_operands),
		.fp_load_o(fp_load)
	);
	assign unused_illegal_insn_id = illegal_insn_id;
	brq_exu #(
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU)
	) ex_block_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.alu_operator_i(alu_operator_ex),
		.alu_operand_a_i(alu_operand_a_ex),
		.alu_operand_b_i(alu_operand_b_ex),
		.alu_instr_first_cycle_i(instr_first_cycle_id),
		.bt_a_operand_i(bt_a_operand),
		.bt_b_operand_i(bt_b_operand),
		.multdiv_operator_i(multdiv_operator_ex),
		.mult_en_i(mult_en_ex),
		.div_en_i(div_en_ex),
		.mult_sel_i(mult_sel_ex),
		.div_sel_i(div_sel_ex),
		.multdiv_signed_mode_i(multdiv_signed_mode_ex),
		.multdiv_operand_a_i(multdiv_operand_a_ex),
		.multdiv_operand_b_i(multdiv_operand_b_ex),
		.multdiv_ready_id_i(multdiv_ready_id),
		.data_ind_timing_i(data_ind_timing),
		.imd_val_we_o(imd_val_we_ex),
		.imd_val_d_o(imd_val_d_ex),
		.imd_val_q_i(imd_val_q_ex),
		.alu_adder_result_ex_o(alu_adder_result_ex),
		.result_ex_o(result_ex),
		.branch_target_o(branch_target_ex),
		.branch_decision_o(branch_decision),
		.ex_valid_o(ex_valid)
	);
	localparam [31:0] brq_pkg_PMP_D = 1;
	assign data_req_o = data_req_out & ~pmp_req_err[brq_pkg_PMP_D];
	assign lsu_resp_err = lsu_load_err | lsu_store_err;
	brq_lsu load_store_unit_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.data_req_o(data_req_out),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_err_i(data_err_i),
		.data_pmp_err_i(pmp_req_err[brq_pkg_PMP_D]),
		.data_addr_o(data_addr_o),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.lsu_we_i(lsu_we),
		.lsu_type_i(lsu_type),
		.lsu_wdata_i(lsu_wdata),
		.lsu_sign_ext_i(lsu_sign_ext),
		.lsu_rdata_o(rf_wdata_lsu),
		.lsu_rdata_valid_o(rf_we_lsu),
		.lsu_req_i(lsu_req),
		.lsu_req_done_o(lsu_req_done),
		.adder_result_ex_i(alu_adder_result_ex),
		.addr_incr_req_o(lsu_addr_incr_req),
		.addr_last_o(lsu_addr_last),
		.lsu_resp_valid_o(lsu_resp_valid),
		.load_err_o(lsu_load_err),
		.store_err_o(lsu_store_err),
		.busy_o(lsu_busy),
		.perf_load_o(perf_load),
		.perf_store_o(perf_store)
	);
	brq_wbu #(.WritebackStage(WritebackStage)) wb_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.en_wb_i(en_wb),
		.instr_type_wb_i(instr_type_wb),
		.pc_id_i(pc_id),
		.instr_is_compressed_id_i(instr_is_compressed_id),
		.instr_perf_count_id_i(instr_perf_count_id),
		.ready_wb_o(ready_wb),
		.rf_write_wb_o(rf_write_wb),
		.outstanding_load_wb_o(outstanding_load_wb),
		.outstanding_store_wb_o(outstanding_store_wb),
		.pc_wb_o(pc_wb),
		.perf_instr_ret_wb_o(perf_instr_ret_wb),
		.perf_instr_ret_compressed_wb_o(perf_instr_ret_compressed_wb),
		.rf_waddr_id_i(rf_waddr_id),
		.rf_wdata_id_i(rf_wdata_id),
		.rf_we_id_i(rf_we_id),
		.rf_wdata_lsu_i(rf_wdata_lsu),
		.rf_we_lsu_i(rf_we_lsu),
		.rf_wdata_fwd_wb_o(rf_wdata_fwd_wb),
		.rf_waddr_wb_o(rf_waddr_wb),
		.rf_wdata_wb_o(rf_wdata_wb),
		.rf_we_wb_o(rf_we_wb),
		.lsu_resp_valid_i(lsu_resp_valid),
		.lsu_resp_err_i(lsu_resp_err),
		.instr_done_wb_o(instr_done_wb),
		.fp_rf_write_wb_o(fp_rf_write_wb),
		.fp_rf_wen_wb_o(fp_rf_wen_wb),
		.fp_rf_waddr_wb_o(fp_rf_waddr_wb),
		.fp_rf_wen_id_i(fp_rf_wen_id),
		.fp_rf_waddr_id_i(fp_rf_waddr_id),
		.fp_rf_wdata_wb_o(fp_rf_wdata_wb),
		.fp_load_i(fp_load)
	);
	wire [RegFileDataWidth - 1:0] rf_wdata_wb_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_a_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_b_ecc;
	wire rf_ecc_err_comb;
	generate
		if (RegFileECC) begin : gen_regfile_ecc
			wire [1:0] rf_ecc_err_a;
			wire [1:0] rf_ecc_err_b;
			wire rf_ecc_err_a_id;
			wire rf_ecc_err_b_id;
			prim_secded_39_32_enc regfile_ecc_enc(
				.in(rf_wdata_wb),
				.out(rf_wdata_wb_ecc)
			);
			prim_secded_39_32_dec regfile_ecc_dec_a(
				.in(rf_rdata_a_ecc),
				.d_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_a)
			);
			prim_secded_39_32_dec regfile_ecc_dec_b(
				.in(rf_rdata_b_ecc),
				.d_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_b)
			);
			assign rf_rdata_a = rf_rdata_a_ecc[31:0];
			assign rf_rdata_b = rf_rdata_b_ecc[31:0];
			assign rf_ecc_err_a_id = (|rf_ecc_err_a & rf_ren_a) & ~rf_rd_a_wb_match;
			assign rf_ecc_err_b_id = (|rf_ecc_err_b & rf_ren_b) & ~rf_rd_b_wb_match;
			assign rf_ecc_err_comb = instr_valid_id & (rf_ecc_err_a_id | rf_ecc_err_b_id);
		end
		else begin : gen_no_regfile_ecc
			wire unused_rf_ren_a;
			wire unused_rf_ren_b;
			wire unused_rf_rd_a_wb_match;
			wire unused_rf_rd_b_wb_match;
			assign unused_rf_ren_a = rf_ren_a;
			assign unused_rf_ren_b = rf_ren_b;
			assign unused_rf_rd_a_wb_match = rf_rd_a_wb_match;
			assign unused_rf_rd_b_wb_match = rf_rd_b_wb_match;
			assign rf_wdata_wb_ecc = rf_wdata_wb;
			assign rf_rdata_a = rf_rdata_a_ecc;
			assign rf_rdata_b = rf_rdata_b_ecc;
			assign rf_ecc_err_comb = 1'b0;
		end
	endgenerate
	assign rf_int_fp_lsu = (is_fp_instr & use_fp_rs2 ? fp_rf_rdata_b : rf_rdata_b);
	localparam integer brq_pkg_RegFileFPGA = 1;
	localparam integer brq_pkg_RegFileLatch = 2;
	generate
		if (RegFile == brq_pkg_RegFileFF) begin : gen_regfile_ff
			brq_register_file_ff #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
		else if (RegFile == brq_pkg_RegFileFPGA) begin : gen_regfile_fpga
			brq_register_file_fpga #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
		else if (RegFile == brq_pkg_RegFileLatch) begin : gen_regfile_latch
			brq_register_file_latch #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
	endgenerate
	generate
		if (FloatingPoint) begin : gen_fp_regfile
			brq_fp_register_file_ff #(
				.RVF(RVF),
				.DataWidth(W)
			) fp_register_file(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.raddr_a_i(fp_rf_raddr_a),
				.rdata_a_o(fp_rf_rdata_a),
				.raddr_b_i(fp_rf_raddr_b),
				.rdata_b_o(fp_rf_rdata_b),
				.raddr_c_i(fp_rf_raddr_c),
				.rdata_c_o(fp_rf_rdata_c),
				.waddr_a_i(fp_rf_waddr_wb),
				.wdata_a_i(fp_rf_wdata_wb),
				.we_a_i(fp_rf_wen_wb)
			);
		end
	endgenerate
	assign alert_minor_o = 1'b0;
	assign alert_major_o = (rf_ecc_err_comb | pc_mismatch_alert) | csr_shadow_err;
	assign csr_wdata = alu_operand_a_ex;
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	assign csr_addr = sv2v_cast_12((csr_access ? alu_operand_b_ex[11:0] : 12'b000000000000));
	brq_cs_registers #(
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.DataIndTiming(DataIndTiming),
		.DummyInstructions(DummyInstructions),
		.ShadowCSR(ShadowCSR),
		.ICache(ICache),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.RV32E(RV32E),
		.RV32M(RV32M)
	) cs_registers_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.hart_id_i(hart_id_i),
		.priv_mode_id_o(priv_mode_id),
		.priv_mode_if_o(priv_mode_if),
		.priv_mode_lsu_o(priv_mode_lsu),
		.csr_mtvec_o(csr_mtvec),
		.csr_mtvec_init_i(csr_mtvec_init),
		.boot_addr_i(boot_addr_i),
		.csr_access_i(csr_access),
		.csr_addr_i(csr_addr),
		.csr_wdata_i(csr_wdata),
		.csr_op_i(csr_op),
		.csr_op_en_i(csr_op_en),
		.csr_rdata_o(csr_rdata),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.nmi_mode_i(nmi_mode),
		.irq_pending_o(irq_pending),
		.irqs_o(irqs),
		.csr_mstatus_mie_o(csr_mstatus_mie),
		.csr_mstatus_tw_o(csr_mstatus_tw),
		.csr_mepc_o(csr_mepc),
		.csr_pmp_cfg_o(csr_pmp_cfg),
		.csr_pmp_addr_o(csr_pmp_addr),
		.csr_depc_o(csr_depc),
		.debug_mode_i(debug_mode),
		.debug_cause_i(debug_cause),
		.debug_csr_save_i(debug_csr_save),
		.debug_single_step_o(debug_single_step),
		.debug_ebreakm_o(debug_ebreakm),
		.debug_ebreaku_o(debug_ebreaku),
		.trigger_match_o(trigger_match),
		.pc_if_i(pc_if),
		.pc_id_i(pc_id),
		.pc_wb_i(pc_wb),
		.data_ind_timing_o(data_ind_timing),
		.csr_shadow_err_o(csr_shadow_err),
		.csr_save_if_i(csr_save_if),
		.csr_save_id_i(csr_save_id),
		.csr_save_wb_i(csr_save_wb),
		.csr_restore_mret_i(csr_restore_mret_id),
		.csr_restore_dret_i(csr_restore_dret_id),
		.csr_save_cause_i(csr_save_cause),
		.csr_mcause_i(exc_cause),
		.csr_mtval_i(csr_mtval),
		.illegal_csr_insn_o(illegal_csr_insn_id),
		.instr_ret_i(perf_instr_ret_wb),
		.instr_ret_compressed_i(perf_instr_ret_compressed_wb),
		.iside_wait_i(perf_iside_wait),
		.jump_i(perf_jump),
		.branch_i(perf_branch),
		.branch_taken_i(perf_tbranch),
		.mem_load_i(perf_load),
		.mem_store_i(perf_store),
		.dside_wait_i(perf_dside_wait),
		.mul_wait_i(perf_mul_wait),
		.div_wait_i(perf_div_wait),
		.fp_rm_dynamic_i(fp_rm_dynamic),
		.fp_frm_o(fp_frm_csr),
		.fp_status_i(fp_status),
		.is_fp_instr_i(is_fp_instr)
	);
	assign fp_frm_fpnew = (fp_rm_dynamic ? fp_frm_csr : fp_rounding_mode);
	assign in_ready_c2fpu = id_in_ready;
	assign in_valid_c2fpu = instr_valid_id & is_fp_instr;
	assign valid_id_fpu = (is_fp_instr ? out_valid_fpu2c : ex_valid);
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	localparam [1:0] fpnew_pkg_MERGED = 2;
	localparam [1:0] fpnew_pkg_PARALLEL = 1;
	function automatic [127:0] sv2v_cast_CC116;
		input reg [127:0] inp;
		sv2v_cast_CC116 = inp;
	endfunction
	function automatic [511:0] sv2v_cast_512;
		input reg [511:0] inp;
		sv2v_cast_512 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [545:0] fpnew_pkg_DEFAULT_NOREGS = {sv2v_cast_512({fpnew_pkg_NUM_OPGROUPS {sv2v_cast_CC116(0)}}), sv2v_cast_32({{fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_MERGED}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_MERGED}}}), fpnew_pkg_BEFORE};
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	localparam [41:0] fpnew_pkg_RV32F = {34'b0000000000000000000000000010000001, sv2v_cast_4(5'b10000), 4'b0010};
	localparam [1:0] fpnew_pkg_INT32 = 2;
	fpnew_top_F1920 #(
		.Features(fpnew_pkg_RV32F),
		.Implementation(fpnew_pkg_DEFAULT_NOREGS)
	) i_fpnew_top(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.operands_i(fp_operands),
		.rnd_mode_i(fp_frm_fpnew),
		.op_i(fp_alu_operator),
		.op_mod_i(fp_alu_op_mod),
		.src_fmt_i(fp_src_fmt),
		.dst_fmt_i(fp_dst_fmt),
		.int_fmt_i(fpnew_pkg_INT32),
		.vectorial_op_i(1'b0),
		.tag_i(1'b1),
		.in_valid_i(in_valid_c2fpu),
		.in_ready_o(out_ready_fpu2c),
		.flush_i(fp_flush),
		.result_o(fp_result),
		.status_o(fp_status),
		.tag_o(),
		.out_valid_o(out_valid_fpu2c),
		.out_ready_i(in_ready_c2fpu),
		.busy_o(fp_busy)
	);
	assign fpu_busy_idu = fp_busy & ~out_valid_fpu2c;
	assign data_wb = (is_fp_instr ? fp_result : result_ex);
	localparam [1:0] brq_pkg_PMP_ACC_EXEC = 2'b00;
	localparam [1:0] brq_pkg_PMP_ACC_READ = 2'b10;
	localparam [1:0] brq_pkg_PMP_ACC_WRITE = 2'b01;
	generate
		if (PMPEnable) begin : g_pmp
			wire [67:0] pmp_req_addr;
			wire [3:0] pmp_req_type;
			wire [3:0] pmp_priv_lvl;
			assign pmp_req_addr[34+:34] = {2'b00, instr_addr_o[31:0]};
			assign pmp_req_type[2+:2] = brq_pkg_PMP_ACC_EXEC;
			assign pmp_priv_lvl[2+:2] = priv_mode_if;
			assign pmp_req_addr[0+:34] = {2'b00, data_addr_o[31:0]};
			assign pmp_req_type[0+:2] = (data_we_o ? brq_pkg_PMP_ACC_WRITE : brq_pkg_PMP_ACC_READ);
			assign pmp_priv_lvl[0+:2] = priv_mode_lsu;
			brq_pmp #(
				.PMPGranularity(PMPGranularity),
				.PMPNumChan(PMP_NUM_CHAN),
				.PMPNumRegions(PMPNumRegions)
			) pmp_i(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.csr_pmp_cfg_i(csr_pmp_cfg),
				.csr_pmp_addr_i(csr_pmp_addr),
				.priv_mode_i(pmp_priv_lvl),
				.pmp_req_addr_i(pmp_req_addr),
				.pmp_req_type_i(pmp_req_type),
				.pmp_req_err_o(pmp_req_err)
			);
		end
		else begin : g_no_pmp
			wire [1:0] unused_priv_lvl_if;
			wire [1:0] unused_priv_lvl_ls;
			wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] unused_csr_pmp_addr;
			wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] unused_csr_pmp_cfg;
			assign unused_priv_lvl_if = priv_mode_if;
			assign unused_priv_lvl_ls = priv_mode_lsu;
			assign unused_csr_pmp_addr = csr_pmp_addr;
			assign unused_csr_pmp_cfg = csr_pmp_cfg;
			assign pmp_req_err[brq_pkg_PMP_I] = 1'b0;
			assign pmp_req_err[brq_pkg_PMP_D] = 1'b0;
		end
	endgenerate
	wire unused_instr_new_id;
	wire unused_instr_done_wb;
	assign unused_instr_new_id = instr_new_id;
	assign unused_instr_done_wb = instr_done_wb;
endmodule
module brq_core_top (
	clk_i,
	rst_ni,
	tl_i_i,
	tl_i_o,
	tl_d_i,
	tl_d_o,
	hart_id_i,
	boot_addr_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	debug_req_i,
	fetch_enable_i,
	alert_minor_o,
	alert_major_o,
	core_sleep_o
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	localparam integer brq_pkg_RegFileFF = 0;
	parameter integer RegFile = brq_pkg_RegFileFF;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b1;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] Securebrq = 1'b0;
	parameter [31:0] DmHaltAddr = 0;
	parameter [31:0] DmExceptionAddr = 0;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [51:0] tl_i_i;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	output wire [85:0] tl_i_o;
	input wire [51:0] tl_d_i;
	output wire [85:0] tl_d_o;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	input wire fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_o;
	output wire core_sleep_o;
	wire instr_req;
	wire instr_gnt;
	wire instr_rvalid;
	wire [31:0] instr_addr;
	wire [31:0] instr_rdata;
	wire instr_err;
	wire data_req;
	wire data_gnt;
	wire data_rvalid;
	wire data_we;
	wire [3:0] data_be;
	wire [31:0] data_addr;
	wire [31:0] data_wdata;
	wire [31:0] data_rdata;
	wire data_err;
	brq_core #(
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.RegFile(RegFile),
		.BranchTargetALU(BranchTargetALU),
		.WritebackStage(WritebackStage),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BranchPredictor(BranchPredictor),
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.Securebrq(Securebrq),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr)
	) u_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req),
		.instr_gnt_i(instr_gnt),
		.instr_rvalid_i(instr_rvalid),
		.instr_addr_o(instr_addr),
		.instr_rdata_i(instr_rdata),
		.instr_err_i(instr_err),
		.data_req_o(data_req),
		.data_gnt_i(data_gnt),
		.data_rvalid_i(data_rvalid),
		.data_we_o(data_we),
		.data_be_o(data_be),
		.data_addr_o(data_addr),
		.data_wdata_o(data_wdata),
		.data_rdata_i(data_rdata),
		.data_err_i(data_err),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.irq_nm_i(irq_nm_i),
		.debug_req_i(debug_req_i),
		.fetch_enable_i(fetch_enable_i),
		.alert_minor_o(alert_minor_o),
		.alert_major_o(alert_major_o),
		.core_sleep_o(core_sleep_o)
	);
	tlul_host_adapter #(.MAX_REQS(2)) instr_interface(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(instr_req),
		.gnt_o(instr_gnt),
		.addr_i(instr_addr),
		.we_i(1'b0),
		.wdata_i(32'b00000000000000000000000000000000),
		.be_i(4'hf),
		.valid_o(instr_rvalid),
		.rdata_o(instr_rdata),
		.err_o(instr_err),
		.tl_h_c_a(tl_i_o),
		.tl_h_c_d(tl_i_i)
	);
	tlul_host_adapter #(.MAX_REQS(2)) data_interface(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(data_req),
		.gnt_o(data_gnt),
		.addr_i(data_addr),
		.we_i(data_we),
		.wdata_i(data_wdata),
		.be_i(data_be),
		.valid_o(data_rvalid),
		.rdata_o(data_rdata),
		.err_o(data_err),
		.tl_h_c_a(tl_d_o),
		.tl_h_c_d(tl_d_i)
	);
endmodule
module rstmgr (
	clk_i,
	rst_ni,
	prog_rst_ni,
	sys_rst_ni
);
	input clk_i;
	input rst_ni;
	input prog_rst_ni;
	output reg sys_rst_ni;
	reg [1:0] rst_fsm_cs;
	reg [1:0] rst_fsm_ns;
	reg rst_run_d;
	reg rst_run_q;
	localparam [1:0] IDLE = 1;
	localparam [1:0] PROG = 2;
	localparam [1:0] RESET = 0;
	localparam [1:0] RUN = 3;
	always @(*) begin : comb_part
		rst_fsm_ns = rst_fsm_cs;
		sys_rst_ni = 1'b0;
		case (rst_fsm_cs)
			RESET: begin
				sys_rst_ni = 1'b0;
				rst_fsm_ns = IDLE;
			end
			IDLE: begin
				sys_rst_ni = 1'b0;
				rst_run_d = 1'b0;
				if (rst_run_q)
					rst_fsm_ns = RUN;
				else if (!prog_rst_ni)
					rst_fsm_ns = PROG;
				else
					rst_fsm_ns = IDLE;
			end
			PROG: begin
				sys_rst_ni = 1'b0;
				rst_run_d = 1'b0;
				if (!prog_rst_ni)
					rst_fsm_ns = PROG;
				else
					rst_fsm_ns = RUN;
			end
			RUN: begin
				sys_rst_ni = 1'b1;
				rst_run_d = 1'b0;
				if (!rst_ni) begin
					rst_run_d = 1'b1;
					rst_fsm_ns = RESET;
				end
				else if (!prog_rst_ni)
					rst_fsm_ns = PROG;
				else
					rst_fsm_ns = RUN;
			end
			default: begin
				rst_fsm_ns = rst_fsm_cs;
				sys_rst_ni = 1'b0;
				rst_run_d = 1'b0;
			end
		endcase
	end
	always @(posedge clk_i or negedge rst_ni) begin : seq_part
		if (!rst_ni) begin
			rst_fsm_cs <= RESET;
			rst_run_q <= 1'b0;
		end
		else begin
			rst_fsm_cs <= rst_fsm_ns;
			rst_run_q <= rst_run_d;
		end
	end
endmodule
module tl_xbar_main (
	clk_i,
	rst_ni,
	tl_brqif_i,
	tl_brqif_o,
	tl_brqlsu_i,
	tl_brqlsu_o,
	tl_iccm_o,
	tl_iccm_i,
	tl_dccm_o,
	tl_dccm_i,
	tl_timer0_o,
	tl_timer0_i,
	tl_uart_o,
	tl_uart_i,
	tl_spi_o,
	tl_spi_i,
	tl_pwm_o,
	tl_pwm_i,
	tl_gpio_o,
	tl_gpio_i,
	tl_plic_o,
	tl_plic_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_brqif_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_brqif_o;
	input wire [85:0] tl_brqlsu_i;
	output wire [51:0] tl_brqlsu_o;
	output wire [85:0] tl_iccm_o;
	input wire [51:0] tl_iccm_i;
	output wire [85:0] tl_dccm_o;
	input wire [51:0] tl_dccm_i;
	output wire [85:0] tl_timer0_o;
	input wire [51:0] tl_timer0_i;
	output wire [85:0] tl_uart_o;
	input wire [51:0] tl_uart_i;
	output wire [85:0] tl_spi_o;
	input wire [51:0] tl_spi_i;
	output wire [85:0] tl_pwm_o;
	input wire [51:0] tl_pwm_i;
	output wire [85:0] tl_gpio_o;
	input wire [51:0] tl_gpio_i;
	output wire [85:0] tl_plic_o;
	input wire [51:0] tl_plic_i;
	wire [85:0] brqlsu_to_s1n;
	wire [51:0] s1n_to_brqlsu;
	reg [3:0] device_sel;
	wire [601:0] h_dv_o;
	wire [363:0] h_dv_i;
	assign brqlsu_to_s1n = tl_brqlsu_i;
	assign tl_brqlsu_o = s1n_to_brqlsu;
	assign tl_iccm_o = tl_brqif_i;
	assign tl_brqif_o = tl_iccm_i;
	assign tl_dccm_o = h_dv_o[516+:86];
	assign h_dv_i[312+:52] = tl_dccm_i;
	assign tl_timer0_o = h_dv_o[430+:86];
	assign h_dv_i[260+:52] = tl_timer0_i;
	assign tl_uart_o = h_dv_o[344+:86];
	assign h_dv_i[208+:52] = tl_uart_i;
	assign tl_spi_o = h_dv_o[258+:86];
	assign h_dv_i[156+:52] = tl_spi_i;
	assign tl_pwm_o = h_dv_o[172+:86];
	assign h_dv_i[104+:52] = tl_pwm_i;
	assign tl_gpio_o = h_dv_o[86+:86];
	assign h_dv_i[52+:52] = tl_gpio_i;
	assign tl_plic_o = h_dv_o[0+:86];
	assign h_dv_i[0+:52] = tl_plic_i;
	localparam [31:0] tl_main_pkg_ADDR_MASK_DCCM = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_GPIO = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_PLIC = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_PWM = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_SPI0 = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_TIMER0 = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_MASK_UART0 = 32'h0000ffff;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_DCCM = 32'h10000000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_GPIO = 32'h400c0000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_PLIC = 32'h40050000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_PWM = 32'h400b0000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_SPI0 = 32'h40080000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_TIMER0 = 32'h40000000;
	localparam [31:0] tl_main_pkg_ADDR_SPACE_UART0 = 32'h40060000;
	always @(*) begin
		device_sel = 4'd9;
		if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_DCCM) == tl_main_pkg_ADDR_SPACE_DCCM)
			device_sel = 4'd0;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_TIMER0) == tl_main_pkg_ADDR_SPACE_TIMER0)
			device_sel = 4'd1;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_UART0) == tl_main_pkg_ADDR_SPACE_UART0)
			device_sel = 4'd2;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_SPI0) == tl_main_pkg_ADDR_SPACE_SPI0)
			device_sel = 4'd3;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_PWM) == tl_main_pkg_ADDR_SPACE_PWM)
			device_sel = 4'd4;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_GPIO) == tl_main_pkg_ADDR_SPACE_GPIO)
			device_sel = 4'd5;
		else if ((brqlsu_to_s1n[68-:32] & ~tl_main_pkg_ADDR_MASK_PLIC) == tl_main_pkg_ADDR_SPACE_PLIC)
			device_sel = 4'd6;
	end
	tlul_socket_1n #(
		.HReqDepth(4'h0),
		.HRspDepth(4'h0),
		.DReqDepth(36'h000000000),
		.DRspDepth(36'h000000000),
		.N(7)
	) host_lsu(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(brqlsu_to_s1n),
		.tl_h_o(s1n_to_brqlsu),
		.tl_d_o(h_dv_o),
		.tl_d_i(h_dv_i),
		.dev_select_i(device_sel)
	);
endmodule
module brq_counter (
	clk_i,
	rst_ni,
	counter_inc_i,
	counterh_we_i,
	counter_we_i,
	counter_val_i,
	counter_val_o
);
	parameter signed [31:0] CounterWidth = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire counter_inc_i;
	input wire counterh_we_i;
	input wire counter_we_i;
	input wire [31:0] counter_val_i;
	output wire [63:0] counter_val_o;
	wire [63:0] counter;
	reg [CounterWidth - 1:0] counter_upd;
	reg [63:0] counter_load;
	reg we;
	reg [CounterWidth - 1:0] counter_d;
	always @(*) begin
		we = counter_we_i | counterh_we_i;
		counter_load[63:32] = counter[63:32];
		counter_load[31:0] = counter_val_i;
		if (counterh_we_i) begin
			counter_load[63:32] = counter_val_i;
			counter_load[31:0] = counter[31:0];
		end
		counter_upd = counter[CounterWidth - 1:0] + {{CounterWidth - 1 {1'b0}}, 1'b1};
		if (we)
			counter_d = counter_load[CounterWidth - 1:0];
		else if (counter_inc_i)
			counter_d = counter_upd[CounterWidth - 1:0];
		else
			counter_d = counter[CounterWidth - 1:0];
	end
	reg [CounterWidth - 1:0] counter_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			counter_q <= {CounterWidth {1'sb0}};
		else
			counter_q <= counter_d;
	generate
		if (CounterWidth < 64) begin : g_counter_narrow
			wire [63:CounterWidth] unused_counter_load;
			assign counter[CounterWidth - 1:0] = counter_q;
			assign counter[63:CounterWidth] = {(63 >= CounterWidth ? 64 - CounterWidth : CounterWidth - 62) {1'sb0}};
			assign unused_counter_load = counter_load[63:CounterWidth];
		end
		else begin : g_counter_full
			assign counter = counter_q;
		end
	endgenerate
	assign counter_val_o = counter;
endmodule
module brq_cs_registers (
	clk_i,
	rst_ni,
	hart_id_i,
	priv_mode_id_o,
	priv_mode_if_o,
	priv_mode_lsu_o,
	csr_mstatus_tw_o,
	csr_mtvec_o,
	csr_mtvec_init_i,
	boot_addr_i,
	csr_access_i,
	csr_addr_i,
	csr_wdata_i,
	csr_op_i,
	csr_op_en_i,
	csr_rdata_o,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	nmi_mode_i,
	irq_pending_o,
	irqs_o,
	csr_mstatus_mie_o,
	csr_mepc_o,
	csr_pmp_cfg_o,
	csr_pmp_addr_o,
	debug_mode_i,
	debug_cause_i,
	debug_csr_save_i,
	csr_depc_o,
	debug_single_step_o,
	debug_ebreakm_o,
	debug_ebreaku_o,
	trigger_match_o,
	pc_if_i,
	pc_id_i,
	pc_wb_i,
	data_ind_timing_o,
	csr_shadow_err_o,
	csr_save_if_i,
	csr_save_id_i,
	csr_save_wb_i,
	csr_restore_mret_i,
	csr_restore_dret_i,
	csr_save_cause_i,
	csr_mcause_i,
	csr_mtval_i,
	illegal_csr_insn_o,
	instr_ret_i,
	instr_ret_compressed_i,
	iside_wait_i,
	jump_i,
	branch_i,
	branch_taken_i,
	mem_load_i,
	mem_store_i,
	dside_wait_i,
	mul_wait_i,
	div_wait_i,
	fp_rm_dynamic_i,
	fp_frm_o,
	fp_status_i,
	is_fp_instr_i
);
	parameter [0:0] DbgTriggerEn = 0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] DataIndTiming = 1'b0;
	parameter [0:0] DummyInstructions = 1'b0;
	parameter [0:0] ShadowCSR = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [31:0] MHPMCounterNum = 10;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] PMPEnable = 0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [0:0] RV32E = 0;
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV64FDouble = 2;
	parameter integer RVF = brq_pkg_RV64FDouble;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] hart_id_i;
	output wire [1:0] priv_mode_id_o;
	output wire [1:0] priv_mode_if_o;
	output wire [1:0] priv_mode_lsu_o;
	output wire csr_mstatus_tw_o;
	output wire [31:0] csr_mtvec_o;
	input wire csr_mtvec_init_i;
	input wire [31:0] boot_addr_i;
	input wire csr_access_i;
	input wire [11:0] csr_addr_i;
	input wire [31:0] csr_wdata_i;
	input wire [1:0] csr_op_i;
	input wire csr_op_en_i;
	output wire [31:0] csr_rdata_o;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire nmi_mode_i;
	output wire irq_pending_o;
	output wire [17:0] irqs_o;
	output wire csr_mstatus_mie_o;
	output wire [31:0] csr_mepc_o;
	output wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg_o;
	output wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr_o;
	input wire debug_mode_i;
	input wire [2:0] debug_cause_i;
	input wire debug_csr_save_i;
	output wire [31:0] csr_depc_o;
	output wire debug_single_step_o;
	output wire debug_ebreakm_o;
	output wire debug_ebreaku_o;
	output wire trigger_match_o;
	input wire [31:0] pc_if_i;
	input wire [31:0] pc_id_i;
	input wire [31:0] pc_wb_i;
	output wire data_ind_timing_o;
	output wire csr_shadow_err_o;
	input wire csr_save_if_i;
	input wire csr_save_id_i;
	input wire csr_save_wb_i;
	input wire csr_restore_mret_i;
	input wire csr_restore_dret_i;
	input wire csr_save_cause_i;
	input wire [5:0] csr_mcause_i;
	input wire [31:0] csr_mtval_i;
	output wire illegal_csr_insn_o;
	input wire instr_ret_i;
	input wire instr_ret_compressed_i;
	input wire iside_wait_i;
	input wire jump_i;
	input wire branch_i;
	input wire branch_taken_i;
	input wire mem_load_i;
	input wire mem_store_i;
	input wire dside_wait_i;
	input wire mul_wait_i;
	input wire div_wait_i;
	input wire fp_rm_dynamic_i;
	output reg [2:0] fp_frm_o;
	input wire [4:0] fp_status_i;
	input wire is_fp_instr_i;
	wire dummy_instr_en_o;
	wire [2:0] dummy_instr_mask_o;
	wire dummy_instr_seed_en_o;
	wire [31:0] dummy_instr_seed_o;
	wire icache_enable_o;
	localparam integer brq_pkg_RV32MNone = 0;
	localparam [31:0] RV32MEnabled = (RV32M == brq_pkg_RV32MNone ? 0 : 1);
	localparam [31:0] PMPAddrWidth = (PMPGranularity > 0 ? 33 - PMPGranularity : 32);
	localparam integer brq_pkg_RV32FSingle = 1;
	localparam [31:0] SinglePrecision = (RVF == brq_pkg_RV32FSingle ? 1 : 0);
	localparam [31:0] DoublePrecision = (RVF == brq_pkg_RV64FDouble ? 1 : 0);
	localparam [1:0] brq_pkg_CSR_MISA_MXL = 2'd1;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [31:0] MISA_VALUE = ((((((((((0 | 4) | (DoublePrecision << 3)) | (sv2v_cast_32(RV32E) << 4)) | (SinglePrecision << 5)) | (sv2v_cast_32(!RV32E) << 8)) | (RV32MEnabled << 12)) | 0) | 0) | 1048576) | 0) | (sv2v_cast_32(brq_pkg_CSR_MISA_MXL) << 30);
	reg [31:0] exception_pc;
	wire [4:0] fflags_q;
	reg [4:0] fflags_d;
	wire [4:0] fflag_wdata;
	reg fflags_en;
	reg frm_en;
	wire [2:0] frm_q;
	reg [2:0] frm_d;
	reg [1:0] priv_lvl_q;
	reg [1:0] priv_lvl_d;
	wire [5:0] mstatus_q;
	reg [5:0] mstatus_d;
	wire mstatus_err;
	reg mstatus_en;
	wire [17:0] mie_q;
	wire [17:0] mie_d;
	reg mie_en;
	wire [31:0] mscratch_q;
	reg mscratch_en;
	wire [31:0] mepc_q;
	reg [31:0] mepc_d;
	reg mepc_en;
	wire [5:0] mcause_q;
	reg [5:0] mcause_d;
	reg mcause_en;
	wire [31:0] mtval_q;
	reg [31:0] mtval_d;
	reg mtval_en;
	wire [31:0] mtvec_q;
	reg [31:0] mtvec_d;
	wire mtvec_err;
	reg mtvec_en;
	wire [17:0] mip;
	wire [31:0] dcsr_q;
	reg [31:0] dcsr_d;
	reg dcsr_en;
	wire [31:0] depc_q;
	reg [31:0] depc_d;
	reg depc_en;
	wire [31:0] dscratch0_q;
	wire [31:0] dscratch1_q;
	reg dscratch0_en;
	reg dscratch1_en;
	wire [2:0] mstack_q;
	reg [2:0] mstack_d;
	reg mstack_en;
	wire [31:0] mstack_epc_q;
	reg [31:0] mstack_epc_d;
	wire [5:0] mstack_cause_q;
	reg [5:0] mstack_cause_d;
	localparam [31:0] brq_pkg_PMP_MAX_REGIONS = 16;
	reg [31:0] pmp_addr_rdata [0:15];
	localparam [31:0] brq_pkg_PMP_CFG_W = 8;
	wire [7:0] pmp_cfg_rdata [0:15];
	wire pmp_csr_err;
	wire [31:0] mcountinhibit;
	reg [MHPMCounterNum + 2:0] mcountinhibit_d;
	reg [MHPMCounterNum + 2:0] mcountinhibit_q;
	reg mcountinhibit_we;
	wire [63:0] mhpmcounter [0:31];
	reg [31:0] mhpmcounter_we;
	reg [31:0] mhpmcounterh_we;
	reg [31:0] mhpmcounter_incr;
	reg [31:0] mhpmevent [0:31];
	wire [4:0] mhpmcounter_idx;
	wire unused_mhpmcounter_we_1;
	wire unused_mhpmcounterh_we_1;
	wire unused_mhpmcounter_incr_1;
	wire [31:0] tselect_rdata;
	wire [31:0] tmatch_control_rdata;
	wire [31:0] tmatch_value_rdata;
	wire [5:0] cpuctrl_q;
	wire [5:0] cpuctrl_d;
	wire [5:0] cpuctrl_wdata;
	reg cpuctrl_we;
	wire cpuctrl_err;
	reg [31:0] csr_wdata_int;
	reg [31:0] csr_rdata_int;
	wire csr_we_int;
	wire csr_wreq;
	reg illegal_csr;
	wire illegal_csr_priv;
	wire illegal_csr_write;
	wire [7:0] unused_boot_addr;
	wire [2:0] unused_csr_addr;
	assign unused_boot_addr = boot_addr_i[7:0];
	reg illegal_dyn_mod;
	wire illegal_csr_dyn_mod;
	wire [11:0] csr_addr;
	assign csr_addr = {csr_addr_i};
	assign unused_csr_addr = csr_addr[7:5];
	assign mhpmcounter_idx = csr_addr[4:0];
	assign illegal_csr_dyn_mod = illegal_dyn_mod & fp_rm_dynamic_i;
	assign illegal_csr_priv = csr_addr[9:8] > {priv_lvl_q};
	assign illegal_csr_write = (csr_addr[11:10] == 2'b11) && csr_wreq;
	assign illegal_csr_insn_o = (csr_access_i & ((illegal_csr | illegal_csr_write) | illegal_csr_priv)) | illegal_csr_dyn_mod;
	assign mip[17] = irq_software_i;
	assign mip[16] = irq_timer_i;
	assign mip[15] = irq_external_i;
	assign mip[14-:15] = irq_fast_i;
	always @(*) begin
		case (frm_q)
			3'b000, 3'b001, 3'b010, 3'b011, 3'b100: illegal_dyn_mod = 1'b0;
			3'b101, 3'b110, 3'b111: illegal_dyn_mod = 1'b1;
		endcase
		fp_frm_o = frm_q;
	end
	localparam [31:0] brq_pkg_CSR_MEIX_BIT = 11;
	localparam [31:0] brq_pkg_CSR_MFIX_BIT_HIGH = 30;
	localparam [31:0] brq_pkg_CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] brq_pkg_CSR_MSIX_BIT = 3;
	localparam [31:0] brq_pkg_CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] brq_pkg_CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] brq_pkg_CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] brq_pkg_CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] brq_pkg_CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] brq_pkg_CSR_MSTATUS_TW_BIT = 21;
	localparam [31:0] brq_pkg_CSR_MTIX_BIT = 7;
	localparam [11:0] brq_pkg_CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] brq_pkg_CSR_DCSR = 12'h7b0;
	localparam [11:0] brq_pkg_CSR_DPC = 12'h7b1;
	localparam [11:0] brq_pkg_CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] brq_pkg_CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] brq_pkg_CSR_FCSR = 12'h003;
	localparam [11:0] brq_pkg_CSR_FFLAG = 12'h001;
	localparam [11:0] brq_pkg_CSR_FRM = 12'h002;
	localparam [11:0] brq_pkg_CSR_MCAUSE = 12'h342;
	localparam [11:0] brq_pkg_CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] brq_pkg_CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] brq_pkg_CSR_MCYCLE = 12'hb00;
	localparam [11:0] brq_pkg_CSR_MCYCLEH = 12'hb80;
	localparam [11:0] brq_pkg_CSR_MEPC = 12'h341;
	localparam [11:0] brq_pkg_CSR_MHARTID = 12'hf14;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] brq_pkg_CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] brq_pkg_CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] brq_pkg_CSR_MIE = 12'h304;
	localparam [11:0] brq_pkg_CSR_MINSTRET = 12'hb02;
	localparam [11:0] brq_pkg_CSR_MINSTRETH = 12'hb82;
	localparam [11:0] brq_pkg_CSR_MIP = 12'h344;
	localparam [11:0] brq_pkg_CSR_MISA = 12'h301;
	localparam [11:0] brq_pkg_CSR_MSCRATCH = 12'h340;
	localparam [11:0] brq_pkg_CSR_MSTATUS = 12'h300;
	localparam [11:0] brq_pkg_CSR_MTVAL = 12'h343;
	localparam [11:0] brq_pkg_CSR_MTVEC = 12'h305;
	localparam [11:0] brq_pkg_CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] brq_pkg_CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] brq_pkg_CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] brq_pkg_CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] brq_pkg_CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] brq_pkg_CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] brq_pkg_CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] brq_pkg_CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] brq_pkg_CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] brq_pkg_CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] brq_pkg_CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] brq_pkg_CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] brq_pkg_CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] brq_pkg_CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] brq_pkg_CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] brq_pkg_CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] brq_pkg_CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] brq_pkg_CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] brq_pkg_CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] brq_pkg_CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] brq_pkg_CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] brq_pkg_CSR_SECURESEED = 12'h7c1;
	localparam [11:0] brq_pkg_CSR_TDATA1 = 12'h7a1;
	localparam [11:0] brq_pkg_CSR_TDATA2 = 12'h7a2;
	localparam [11:0] brq_pkg_CSR_TDATA3 = 12'h7a3;
	localparam [11:0] brq_pkg_CSR_TSELECT = 12'h7a0;
	always @(*) begin
		csr_rdata_int = {32 {1'sb0}};
		illegal_csr = 1'b0;
		case (csr_addr_i)
			brq_pkg_CSR_FCSR: csr_rdata_int = {24'b000000000000000000000000, frm_q, fflags_q};
			brq_pkg_CSR_FFLAG: csr_rdata_int = {27'b000000000000000000000000000, fflags_q};
			brq_pkg_CSR_FRM: csr_rdata_int = {29'b00000000000000000000000000000, frm_q};
			brq_pkg_CSR_MHARTID: csr_rdata_int = hart_id_i;
			brq_pkg_CSR_MSTATUS: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[brq_pkg_CSR_MSTATUS_MIE_BIT] = mstatus_q[5];
				csr_rdata_int[brq_pkg_CSR_MSTATUS_MPIE_BIT] = mstatus_q[4];
				csr_rdata_int[brq_pkg_CSR_MSTATUS_MPP_BIT_HIGH:brq_pkg_CSR_MSTATUS_MPP_BIT_LOW] = mstatus_q[3-:2];
				csr_rdata_int[brq_pkg_CSR_MSTATUS_MPRV_BIT] = mstatus_q[1];
				csr_rdata_int[brq_pkg_CSR_MSTATUS_TW_BIT] = mstatus_q[0];
			end
			brq_pkg_CSR_MISA: csr_rdata_int = MISA_VALUE;
			brq_pkg_CSR_MIE: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[brq_pkg_CSR_MSIX_BIT] = mie_q[17];
				csr_rdata_int[brq_pkg_CSR_MTIX_BIT] = mie_q[16];
				csr_rdata_int[brq_pkg_CSR_MEIX_BIT] = mie_q[15];
				csr_rdata_int[brq_pkg_CSR_MFIX_BIT_HIGH:brq_pkg_CSR_MFIX_BIT_LOW] = mie_q[14-:15];
			end
			brq_pkg_CSR_MSCRATCH: csr_rdata_int = mscratch_q;
			brq_pkg_CSR_MTVEC: csr_rdata_int = mtvec_q;
			brq_pkg_CSR_MEPC: csr_rdata_int = mepc_q;
			brq_pkg_CSR_MCAUSE: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
			brq_pkg_CSR_MTVAL: csr_rdata_int = mtval_q;
			brq_pkg_CSR_MIP: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[brq_pkg_CSR_MSIX_BIT] = mip[17];
				csr_rdata_int[brq_pkg_CSR_MTIX_BIT] = mip[16];
				csr_rdata_int[brq_pkg_CSR_MEIX_BIT] = mip[15];
				csr_rdata_int[brq_pkg_CSR_MFIX_BIT_HIGH:brq_pkg_CSR_MFIX_BIT_LOW] = mip[14-:15];
			end
			brq_pkg_CSR_PMPCFG0: csr_rdata_int = {pmp_cfg_rdata[3], pmp_cfg_rdata[2], pmp_cfg_rdata[1], pmp_cfg_rdata[0]};
			brq_pkg_CSR_PMPCFG1: csr_rdata_int = {pmp_cfg_rdata[7], pmp_cfg_rdata[6], pmp_cfg_rdata[5], pmp_cfg_rdata[4]};
			brq_pkg_CSR_PMPCFG2: csr_rdata_int = {pmp_cfg_rdata[11], pmp_cfg_rdata[10], pmp_cfg_rdata[9], pmp_cfg_rdata[8]};
			brq_pkg_CSR_PMPCFG3: csr_rdata_int = {pmp_cfg_rdata[15], pmp_cfg_rdata[14], pmp_cfg_rdata[13], pmp_cfg_rdata[12]};
			brq_pkg_CSR_PMPADDR0: csr_rdata_int = pmp_addr_rdata[0];
			brq_pkg_CSR_PMPADDR1: csr_rdata_int = pmp_addr_rdata[1];
			brq_pkg_CSR_PMPADDR2: csr_rdata_int = pmp_addr_rdata[2];
			brq_pkg_CSR_PMPADDR3: csr_rdata_int = pmp_addr_rdata[3];
			brq_pkg_CSR_PMPADDR4: csr_rdata_int = pmp_addr_rdata[4];
			brq_pkg_CSR_PMPADDR5: csr_rdata_int = pmp_addr_rdata[5];
			brq_pkg_CSR_PMPADDR6: csr_rdata_int = pmp_addr_rdata[6];
			brq_pkg_CSR_PMPADDR7: csr_rdata_int = pmp_addr_rdata[7];
			brq_pkg_CSR_PMPADDR8: csr_rdata_int = pmp_addr_rdata[8];
			brq_pkg_CSR_PMPADDR9: csr_rdata_int = pmp_addr_rdata[9];
			brq_pkg_CSR_PMPADDR10: csr_rdata_int = pmp_addr_rdata[10];
			brq_pkg_CSR_PMPADDR11: csr_rdata_int = pmp_addr_rdata[11];
			brq_pkg_CSR_PMPADDR12: csr_rdata_int = pmp_addr_rdata[12];
			brq_pkg_CSR_PMPADDR13: csr_rdata_int = pmp_addr_rdata[13];
			brq_pkg_CSR_PMPADDR14: csr_rdata_int = pmp_addr_rdata[14];
			brq_pkg_CSR_PMPADDR15: csr_rdata_int = pmp_addr_rdata[15];
			brq_pkg_CSR_DCSR: begin
				csr_rdata_int = dcsr_q;
				illegal_csr = ~debug_mode_i;
			end
			brq_pkg_CSR_DPC: begin
				csr_rdata_int = depc_q;
				illegal_csr = ~debug_mode_i;
			end
			brq_pkg_CSR_DSCRATCH0: begin
				csr_rdata_int = dscratch0_q;
				illegal_csr = ~debug_mode_i;
			end
			brq_pkg_CSR_DSCRATCH1: begin
				csr_rdata_int = dscratch1_q;
				illegal_csr = ~debug_mode_i;
			end
			brq_pkg_CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit;
			brq_pkg_CSR_MHPMEVENT3, brq_pkg_CSR_MHPMEVENT4, brq_pkg_CSR_MHPMEVENT5, brq_pkg_CSR_MHPMEVENT6, brq_pkg_CSR_MHPMEVENT7, brq_pkg_CSR_MHPMEVENT8, brq_pkg_CSR_MHPMEVENT9, brq_pkg_CSR_MHPMEVENT10, brq_pkg_CSR_MHPMEVENT11, brq_pkg_CSR_MHPMEVENT12, brq_pkg_CSR_MHPMEVENT13, brq_pkg_CSR_MHPMEVENT14, brq_pkg_CSR_MHPMEVENT15, brq_pkg_CSR_MHPMEVENT16, brq_pkg_CSR_MHPMEVENT17, brq_pkg_CSR_MHPMEVENT18, brq_pkg_CSR_MHPMEVENT19, brq_pkg_CSR_MHPMEVENT20, brq_pkg_CSR_MHPMEVENT21, brq_pkg_CSR_MHPMEVENT22, brq_pkg_CSR_MHPMEVENT23, brq_pkg_CSR_MHPMEVENT24, brq_pkg_CSR_MHPMEVENT25, brq_pkg_CSR_MHPMEVENT26, brq_pkg_CSR_MHPMEVENT27, brq_pkg_CSR_MHPMEVENT28, brq_pkg_CSR_MHPMEVENT29, brq_pkg_CSR_MHPMEVENT30, brq_pkg_CSR_MHPMEVENT31: csr_rdata_int = mhpmevent[mhpmcounter_idx];
			brq_pkg_CSR_MCYCLE, brq_pkg_CSR_MINSTRET, brq_pkg_CSR_MHPMCOUNTER3, brq_pkg_CSR_MHPMCOUNTER4, brq_pkg_CSR_MHPMCOUNTER5, brq_pkg_CSR_MHPMCOUNTER6, brq_pkg_CSR_MHPMCOUNTER7, brq_pkg_CSR_MHPMCOUNTER8, brq_pkg_CSR_MHPMCOUNTER9, brq_pkg_CSR_MHPMCOUNTER10, brq_pkg_CSR_MHPMCOUNTER11, brq_pkg_CSR_MHPMCOUNTER12, brq_pkg_CSR_MHPMCOUNTER13, brq_pkg_CSR_MHPMCOUNTER14, brq_pkg_CSR_MHPMCOUNTER15, brq_pkg_CSR_MHPMCOUNTER16, brq_pkg_CSR_MHPMCOUNTER17, brq_pkg_CSR_MHPMCOUNTER18, brq_pkg_CSR_MHPMCOUNTER19, brq_pkg_CSR_MHPMCOUNTER20, brq_pkg_CSR_MHPMCOUNTER21, brq_pkg_CSR_MHPMCOUNTER22, brq_pkg_CSR_MHPMCOUNTER23, brq_pkg_CSR_MHPMCOUNTER24, brq_pkg_CSR_MHPMCOUNTER25, brq_pkg_CSR_MHPMCOUNTER26, brq_pkg_CSR_MHPMCOUNTER27, brq_pkg_CSR_MHPMCOUNTER28, brq_pkg_CSR_MHPMCOUNTER29, brq_pkg_CSR_MHPMCOUNTER30, brq_pkg_CSR_MHPMCOUNTER31: csr_rdata_int = mhpmcounter[mhpmcounter_idx][31:0];
			brq_pkg_CSR_MCYCLEH, brq_pkg_CSR_MINSTRETH, brq_pkg_CSR_MHPMCOUNTER3H, brq_pkg_CSR_MHPMCOUNTER4H, brq_pkg_CSR_MHPMCOUNTER5H, brq_pkg_CSR_MHPMCOUNTER6H, brq_pkg_CSR_MHPMCOUNTER7H, brq_pkg_CSR_MHPMCOUNTER8H, brq_pkg_CSR_MHPMCOUNTER9H, brq_pkg_CSR_MHPMCOUNTER10H, brq_pkg_CSR_MHPMCOUNTER11H, brq_pkg_CSR_MHPMCOUNTER12H, brq_pkg_CSR_MHPMCOUNTER13H, brq_pkg_CSR_MHPMCOUNTER14H, brq_pkg_CSR_MHPMCOUNTER15H, brq_pkg_CSR_MHPMCOUNTER16H, brq_pkg_CSR_MHPMCOUNTER17H, brq_pkg_CSR_MHPMCOUNTER18H, brq_pkg_CSR_MHPMCOUNTER19H, brq_pkg_CSR_MHPMCOUNTER20H, brq_pkg_CSR_MHPMCOUNTER21H, brq_pkg_CSR_MHPMCOUNTER22H, brq_pkg_CSR_MHPMCOUNTER23H, brq_pkg_CSR_MHPMCOUNTER24H, brq_pkg_CSR_MHPMCOUNTER25H, brq_pkg_CSR_MHPMCOUNTER26H, brq_pkg_CSR_MHPMCOUNTER27H, brq_pkg_CSR_MHPMCOUNTER28H, brq_pkg_CSR_MHPMCOUNTER29H, brq_pkg_CSR_MHPMCOUNTER30H, brq_pkg_CSR_MHPMCOUNTER31H: csr_rdata_int = mhpmcounter[mhpmcounter_idx][63:32];
			brq_pkg_CSR_TSELECT: begin
				csr_rdata_int = tselect_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_TDATA1: begin
				csr_rdata_int = tmatch_control_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_TDATA2: begin
				csr_rdata_int = tmatch_value_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_TDATA3: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_MCONTEXT: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_SCONTEXT: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			brq_pkg_CSR_CPUCTRL: csr_rdata_int = {{26 {1'b0}}, cpuctrl_q};
			brq_pkg_CSR_SECURESEED: csr_rdata_int = {32 {1'sb0}};
			default: illegal_csr = 1'b1;
		endcase
	end
	localparam [1:0] brq_pkg_PRIV_LVL_M = 2'b11;
	localparam [1:0] brq_pkg_PRIV_LVL_U = 2'b00;
	localparam [3:0] brq_pkg_XDEBUGVER_STD = 4'd4;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin
		exception_pc = pc_id_i;
		fflags_d = fflags_q;
		fflags_en = 1'b0;
		frm_d = frm_q;
		frm_en = 1'b0;
		priv_lvl_d = priv_lvl_q;
		mstatus_en = 1'b0;
		mstatus_d = mstatus_q;
		mie_en = 1'b0;
		mscratch_en = 1'b0;
		mepc_en = 1'b0;
		mepc_d = {csr_wdata_int[31:1], 1'b0};
		mcause_en = 1'b0;
		mcause_d = {csr_wdata_int[31], csr_wdata_int[4:0]};
		mtval_en = 1'b0;
		mtval_d = csr_wdata_int;
		mtvec_en = csr_mtvec_init_i;
		mtvec_d = (csr_mtvec_init_i ? {boot_addr_i[31:2], 2'b00} : {csr_wdata_int[31:2], 2'b00});
		dcsr_en = 1'b0;
		dcsr_d = dcsr_q;
		depc_d = {csr_wdata_int[31:1], 1'b0};
		depc_en = 1'b0;
		dscratch0_en = 1'b0;
		dscratch1_en = 1'b0;
		mstack_en = 1'b0;
		mstack_d[2] = mstatus_q[4];
		mstack_d[1-:2] = mstatus_q[3-:2];
		mstack_epc_d = mepc_q;
		mstack_cause_d = mcause_q;
		mcountinhibit_we = 1'b0;
		mhpmcounter_we = {32 {1'sb0}};
		mhpmcounterh_we = {32 {1'sb0}};
		cpuctrl_we = 1'b0;
		if (csr_we_int)
			case (csr_addr_i)
				brq_pkg_CSR_FCSR: begin
					fflags_en = 1'b1;
					frm_en = 1'b1;
					fflags_d = csr_wdata_int[4:0];
					frm_d = csr_wdata_int[7:5];
				end
				brq_pkg_CSR_FFLAG: begin
					fflags_en = 1'b1;
					fflags_d = csr_wdata_int[4:0];
				end
				brq_pkg_CSR_FRM: begin
					frm_en = 1'b1;
					frm_d = csr_wdata_int[2:0];
				end
				brq_pkg_CSR_MSTATUS: begin
					mstatus_en = 1'b1;
					mstatus_d = {csr_wdata_int[brq_pkg_CSR_MSTATUS_MIE_BIT], csr_wdata_int[brq_pkg_CSR_MSTATUS_MPIE_BIT], sv2v_cast_2(csr_wdata_int[brq_pkg_CSR_MSTATUS_MPP_BIT_HIGH:brq_pkg_CSR_MSTATUS_MPP_BIT_LOW]), csr_wdata_int[brq_pkg_CSR_MSTATUS_MPRV_BIT], csr_wdata_int[brq_pkg_CSR_MSTATUS_TW_BIT]};
					if ((mstatus_d[3-:2] != brq_pkg_PRIV_LVL_M) && (mstatus_d[3-:2] != brq_pkg_PRIV_LVL_U))
						mstatus_d[3-:2] = brq_pkg_PRIV_LVL_M;
				end
				brq_pkg_CSR_MIE: mie_en = 1'b1;
				brq_pkg_CSR_MSCRATCH: mscratch_en = 1'b1;
				brq_pkg_CSR_MEPC: mepc_en = 1'b1;
				brq_pkg_CSR_MCAUSE: mcause_en = 1'b1;
				brq_pkg_CSR_MTVAL: mtval_en = 1'b1;
				brq_pkg_CSR_MTVEC: mtvec_en = 1'b1;
				brq_pkg_CSR_DCSR: begin
					dcsr_d = csr_wdata_int;
					dcsr_d[31-:4] = brq_pkg_XDEBUGVER_STD;
					if ((dcsr_d[1-:2] != brq_pkg_PRIV_LVL_M) && (dcsr_d[1-:2] != brq_pkg_PRIV_LVL_U))
						dcsr_d[1-:2] = brq_pkg_PRIV_LVL_M;
					dcsr_d[8-:3] = dcsr_q[8-:3];
					dcsr_d[3] = 1'b0;
					dcsr_d[4] = 1'b0;
					dcsr_d[10] = 1'b0;
					dcsr_d[9] = 1'b0;
					dcsr_d[5] = 1'b0;
					dcsr_d[14] = 1'b0;
					dcsr_d[27-:12] = 12'h000;
					dcsr_en = 1'b1;
				end
				brq_pkg_CSR_DPC: depc_en = 1'b1;
				brq_pkg_CSR_DSCRATCH0: dscratch0_en = 1'b1;
				brq_pkg_CSR_DSCRATCH1: dscratch1_en = 1'b1;
				brq_pkg_CSR_MCOUNTINHIBIT: mcountinhibit_we = 1'b1;
				brq_pkg_CSR_MCYCLE, brq_pkg_CSR_MINSTRET, brq_pkg_CSR_MHPMCOUNTER3, brq_pkg_CSR_MHPMCOUNTER4, brq_pkg_CSR_MHPMCOUNTER5, brq_pkg_CSR_MHPMCOUNTER6, brq_pkg_CSR_MHPMCOUNTER7, brq_pkg_CSR_MHPMCOUNTER8, brq_pkg_CSR_MHPMCOUNTER9, brq_pkg_CSR_MHPMCOUNTER10, brq_pkg_CSR_MHPMCOUNTER11, brq_pkg_CSR_MHPMCOUNTER12, brq_pkg_CSR_MHPMCOUNTER13, brq_pkg_CSR_MHPMCOUNTER14, brq_pkg_CSR_MHPMCOUNTER15, brq_pkg_CSR_MHPMCOUNTER16, brq_pkg_CSR_MHPMCOUNTER17, brq_pkg_CSR_MHPMCOUNTER18, brq_pkg_CSR_MHPMCOUNTER19, brq_pkg_CSR_MHPMCOUNTER20, brq_pkg_CSR_MHPMCOUNTER21, brq_pkg_CSR_MHPMCOUNTER22, brq_pkg_CSR_MHPMCOUNTER23, brq_pkg_CSR_MHPMCOUNTER24, brq_pkg_CSR_MHPMCOUNTER25, brq_pkg_CSR_MHPMCOUNTER26, brq_pkg_CSR_MHPMCOUNTER27, brq_pkg_CSR_MHPMCOUNTER28, brq_pkg_CSR_MHPMCOUNTER29, brq_pkg_CSR_MHPMCOUNTER30, brq_pkg_CSR_MHPMCOUNTER31: mhpmcounter_we[mhpmcounter_idx] = 1'b1;
				brq_pkg_CSR_MCYCLEH, brq_pkg_CSR_MINSTRETH, brq_pkg_CSR_MHPMCOUNTER3H, brq_pkg_CSR_MHPMCOUNTER4H, brq_pkg_CSR_MHPMCOUNTER5H, brq_pkg_CSR_MHPMCOUNTER6H, brq_pkg_CSR_MHPMCOUNTER7H, brq_pkg_CSR_MHPMCOUNTER8H, brq_pkg_CSR_MHPMCOUNTER9H, brq_pkg_CSR_MHPMCOUNTER10H, brq_pkg_CSR_MHPMCOUNTER11H, brq_pkg_CSR_MHPMCOUNTER12H, brq_pkg_CSR_MHPMCOUNTER13H, brq_pkg_CSR_MHPMCOUNTER14H, brq_pkg_CSR_MHPMCOUNTER15H, brq_pkg_CSR_MHPMCOUNTER16H, brq_pkg_CSR_MHPMCOUNTER17H, brq_pkg_CSR_MHPMCOUNTER18H, brq_pkg_CSR_MHPMCOUNTER19H, brq_pkg_CSR_MHPMCOUNTER20H, brq_pkg_CSR_MHPMCOUNTER21H, brq_pkg_CSR_MHPMCOUNTER22H, brq_pkg_CSR_MHPMCOUNTER23H, brq_pkg_CSR_MHPMCOUNTER24H, brq_pkg_CSR_MHPMCOUNTER25H, brq_pkg_CSR_MHPMCOUNTER26H, brq_pkg_CSR_MHPMCOUNTER27H, brq_pkg_CSR_MHPMCOUNTER28H, brq_pkg_CSR_MHPMCOUNTER29H, brq_pkg_CSR_MHPMCOUNTER30H, brq_pkg_CSR_MHPMCOUNTER31H: mhpmcounterh_we[mhpmcounter_idx] = 1'b1;
				brq_pkg_CSR_CPUCTRL: cpuctrl_we = 1'b1;
				default:
					;
			endcase
		case (1'b1)
			csr_save_cause_i: begin
				case (1'b1)
					csr_save_if_i: exception_pc = pc_if_i;
					csr_save_id_i: exception_pc = pc_id_i;
					csr_save_wb_i: exception_pc = pc_wb_i;
					default:
						;
				endcase
				priv_lvl_d = brq_pkg_PRIV_LVL_M;
				if (debug_csr_save_i) begin
					dcsr_d[1-:2] = priv_lvl_q;
					dcsr_d[8-:3] = debug_cause_i;
					dcsr_en = 1'b1;
					depc_d = exception_pc;
					depc_en = 1'b1;
				end
				else if (!debug_mode_i) begin
					mtval_en = 1'b1;
					mtval_d = csr_mtval_i;
					mstatus_en = 1'b1;
					mstatus_d[5] = 1'b0;
					mstatus_d[4] = mstatus_q[5];
					mstatus_d[3-:2] = priv_lvl_q;
					mepc_en = 1'b1;
					mepc_d = exception_pc;
					mcause_en = 1'b1;
					mcause_d = {csr_mcause_i};
					mstack_en = 1'b1;
				end
			end
			csr_restore_dret_i: priv_lvl_d = dcsr_q[1-:2];
			csr_restore_mret_i: begin
				priv_lvl_d = mstatus_q[3-:2];
				mstatus_en = 1'b1;
				mstatus_d[5] = mstatus_q[4];
				if (nmi_mode_i) begin
					mstatus_d[4] = mstack_q[2];
					mstatus_d[3-:2] = mstack_q[1-:2];
					mepc_en = 1'b1;
					mepc_d = mstack_epc_q;
					mcause_en = 1'b1;
					mcause_d = mstack_cause_q;
				end
				else begin
					mstatus_d[4] = 1'b1;
					mstatus_d[3-:2] = brq_pkg_PRIV_LVL_U;
				end
			end
			default:
				;
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			priv_lvl_q <= brq_pkg_PRIV_LVL_M;
		else
			priv_lvl_q <= priv_lvl_d;
	assign priv_mode_id_o = priv_lvl_q;
	assign priv_mode_if_o = priv_lvl_d;
	assign priv_mode_lsu_o = (mstatus_q[1] ? mstatus_q[3-:2] : priv_lvl_q);
	localparam [1:0] brq_pkg_CSR_OP_CLEAR = 3;
	localparam [1:0] brq_pkg_CSR_OP_READ = 0;
	localparam [1:0] brq_pkg_CSR_OP_SET = 2;
	localparam [1:0] brq_pkg_CSR_OP_WRITE = 1;
	always @(*)
		case (csr_op_i)
			brq_pkg_CSR_OP_WRITE: csr_wdata_int = csr_wdata_i;
			brq_pkg_CSR_OP_SET: csr_wdata_int = csr_wdata_i | csr_rdata_o;
			brq_pkg_CSR_OP_CLEAR: csr_wdata_int = ~csr_wdata_i & csr_rdata_o;
			brq_pkg_CSR_OP_READ: csr_wdata_int = csr_wdata_i;
		endcase
	assign csr_wreq = csr_op_en_i & |{csr_op_i == brq_pkg_CSR_OP_WRITE, csr_op_i == brq_pkg_CSR_OP_SET, csr_op_i == brq_pkg_CSR_OP_CLEAR};
	assign csr_we_int = csr_wreq & ~illegal_csr_insn_o;
	assign csr_rdata_o = csr_rdata_int;
	assign csr_mepc_o = mepc_q;
	assign csr_depc_o = depc_q;
	assign csr_mtvec_o = mtvec_q;
	assign csr_mstatus_mie_o = mstatus_q[5];
	assign csr_mstatus_tw_o = mstatus_q[0];
	assign debug_single_step_o = dcsr_q[2];
	assign debug_ebreakm_o = dcsr_q[15];
	assign debug_ebreaku_o = dcsr_q[12];
	assign irqs_o = mip & mie_q;
	assign irq_pending_o = |irqs_o;
	wire unused_error1;
	wire unused_error2;
	wire unused_error3;
	wire unused_error4;
	wire unused_error5;
	wire unused_error6;
	wire unused_error7;
	wire unused_error8;
	wire unused_error9;
	wire unused_error10;
	wire unused_error11;
	wire unused_error12;
	wire unused_error13;
	wire unused_error14;
	wire unused_error15;
	wire unused_error16;
	wire unused_error17;
	localparam [5:0] MSTATUS_RST_VAL = {2'b01, brq_pkg_PRIV_LVL_U, 1'b0, 1'b0};
	brq_csr #(
		.Width(6),
		.ShadowCopy(ShadowCSR),
		.ResetValue({MSTATUS_RST_VAL})
	) u_mstatus_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i({mstatus_d}),
		.wr_en_i(mstatus_en),
		.rd_data_o(mstatus_q),
		.rd_error_o(mstatus_err)
	);
	assign fflag_wdata = (is_fp_instr_i ? fp_status_i : fflags_d);
	brq_csr #(
		.Width(5),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) fflags_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(fflag_wdata),
		.wr_en_i(fflags_en | is_fp_instr_i),
		.rd_data_o(fflags_q),
		.rd_error_o(unused_error1)
	);
	wire [2:0] frmd;
	wire [2:0] frmq;
	assign frm_q = frmq;
	assign frmd = frm_d;
	brq_csr #(
		.Width(3),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) frm_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(frmd),
		.wr_en_i(frm_en),
		.rd_data_o(frmq),
		.rd_error_o(unused_error2)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mepc_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mepc_d),
		.wr_en_i(mepc_en),
		.rd_data_o(mepc_q),
		.rd_error_o(unused_error3)
	);
	assign mie_d[17] = csr_wdata_int[brq_pkg_CSR_MSIX_BIT];
	assign mie_d[16] = csr_wdata_int[brq_pkg_CSR_MTIX_BIT];
	assign mie_d[15] = csr_wdata_int[brq_pkg_CSR_MEIX_BIT];
	assign mie_d[14-:15] = csr_wdata_int[brq_pkg_CSR_MFIX_BIT_HIGH:brq_pkg_CSR_MFIX_BIT_LOW];
	brq_csr #(
		.Width(18),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mie_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i({mie_d}),
		.wr_en_i(mie_en),
		.rd_data_o(mie_q),
		.rd_error_o(unused_error4)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mscratch_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(csr_wdata_int),
		.wr_en_i(mscratch_en),
		.rd_data_o(mscratch_q),
		.rd_error_o(unused_error5)
	);
	brq_csr #(
		.Width(6),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mcause_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mcause_d),
		.wr_en_i(mcause_en),
		.rd_data_o(mcause_q),
		.rd_error_o(unused_error6)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mtval_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mtval_d),
		.wr_en_i(mtval_en),
		.rd_data_o(mtval_q),
		.rd_error_o(unused_error7)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(ShadowCSR),
		.ResetValue(32'd0)
	) u_mtvec_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mtvec_d),
		.wr_en_i(mtvec_en),
		.rd_data_o(mtvec_q),
		.rd_error_o(mtvec_err)
	);
	localparam [2:0] brq_pkg_DBG_CAUSE_NONE = 3'h0;
	localparam [31:0] DCSR_RESET_VAL = {brq_pkg_XDEBUGVER_STD, 12'b000000000000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, brq_pkg_DBG_CAUSE_NONE, 1'b0, 1'b0, 1'b0, 1'b0, brq_pkg_PRIV_LVL_M};
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue({DCSR_RESET_VAL})
	) u_dcsr_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i({dcsr_d}),
		.wr_en_i(dcsr_en),
		.rd_data_o(dcsr_q),
		.rd_error_o(unused_error8)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_depc_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(depc_d),
		.wr_en_i(depc_en),
		.rd_data_o(depc_q),
		.rd_error_o(unused_error9)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_dscratch0_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(csr_wdata_int),
		.wr_en_i(dscratch0_en),
		.rd_data_o(dscratch0_q),
		.rd_error_o(unused_error10)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_dscratch1_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(csr_wdata_int),
		.wr_en_i(dscratch1_en),
		.rd_data_o(dscratch1_q),
		.rd_error_o(unused_error11)
	);
	localparam [2:0] MSTACK_RESET_VAL = {1'b1, brq_pkg_PRIV_LVL_U};
	brq_csr #(
		.Width(3),
		.ShadowCopy(1'b0),
		.ResetValue({MSTACK_RESET_VAL})
	) u_mstack_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i({mstack_d}),
		.wr_en_i(mstack_en),
		.rd_data_o(mstack_q),
		.rd_error_o(unused_error12)
	);
	brq_csr #(
		.Width(32),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mstack_epc_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mstack_epc_d),
		.wr_en_i(mstack_en),
		.rd_data_o(mstack_epc_q),
		.rd_error_o(unused_error13)
	);
	brq_csr #(
		.Width(6),
		.ShadowCopy(1'b0),
		.ResetValue(1'sb0)
	) u_mstack_cause_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i(mstack_cause_d),
		.wr_en_i(mstack_en),
		.rd_data_o(mstack_cause_q),
		.rd_error_o(unused_error14)
	);
	localparam [11:0] brq_pkg_CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [11:0] brq_pkg_CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [1:0] brq_pkg_PMP_MODE_NA4 = 2'b10;
	localparam [1:0] brq_pkg_PMP_MODE_NAPOT = 2'b11;
	localparam [1:0] brq_pkg_PMP_MODE_OFF = 2'b00;
	localparam [1:0] brq_pkg_PMP_MODE_TOR = 2'b01;
	generate
		if (PMPEnable) begin : g_pmp_registers
			wire [5:0] pmp_cfg [0:PMPNumRegions - 1];
			reg [5:0] pmp_cfg_wdata [0:PMPNumRegions - 1];
			wire [PMPAddrWidth - 1:0] pmp_addr [0:PMPNumRegions - 1];
			wire [PMPNumRegions - 1:0] pmp_cfg_we;
			wire [PMPNumRegions - 1:0] pmp_cfg_err;
			wire [PMPNumRegions - 1:0] pmp_addr_we;
			wire [PMPNumRegions - 1:0] pmp_addr_err;
			genvar i;
			for (i = 0; i < brq_pkg_PMP_MAX_REGIONS; i = i + 1) begin : g_exp_rd_data
				if (i < PMPNumRegions) begin : g_implemented_regions
					assign pmp_cfg_rdata[i] = {pmp_cfg[i][5], 2'b00, pmp_cfg[i][4-:2], pmp_cfg[i][2], pmp_cfg[i][1], pmp_cfg[i][0]};
					if (PMPGranularity == 0) begin : g_pmp_g0
						wire [32:1] sv2v_tmp_D3A6A;
						assign sv2v_tmp_D3A6A = pmp_addr[i];
						always @(*) pmp_addr_rdata[i] = sv2v_tmp_D3A6A;
					end
					else if (PMPGranularity == 1) begin : g_pmp_g1
						always @(*) begin
							pmp_addr_rdata[i] = pmp_addr[i];
							if ((pmp_cfg[i][4-:2] == brq_pkg_PMP_MODE_OFF) || (pmp_cfg[i][4-:2] == brq_pkg_PMP_MODE_TOR))
								pmp_addr_rdata[i][PMPGranularity - 1:0] = {PMPGranularity {1'sb0}};
						end
					end
					else begin : g_pmp_g2
						always @(*) begin
							pmp_addr_rdata[i] = {pmp_addr[i], {PMPGranularity - 1 {1'b1}}};
							if ((pmp_cfg[i][4-:2] == brq_pkg_PMP_MODE_OFF) || (pmp_cfg[i][4-:2] == brq_pkg_PMP_MODE_TOR))
								pmp_addr_rdata[i][PMPGranularity - 1:0] = {PMPGranularity {1'sb0}};
						end
					end
				end
				else begin : g_other_regions
					assign pmp_cfg_rdata[i] = {8 {1'sb0}};
					wire [32:1] sv2v_tmp_313D8;
					assign sv2v_tmp_313D8 = {32 {1'sb0}};
					always @(*) pmp_addr_rdata[i] = sv2v_tmp_313D8;
				end
			end
			for (i = 0; i < PMPNumRegions; i = i + 1) begin : g_pmp_csrs
				assign pmp_cfg_we[i] = (csr_we_int & ~pmp_cfg[i][5]) & (csr_addr == (brq_pkg_CSR_OFF_PMP_CFG + (i[11:0] >> 2)));
				wire [1:1] sv2v_tmp_5B5A1;
				assign sv2v_tmp_5B5A1 = csr_wdata_int[((i % 4) * brq_pkg_PMP_CFG_W) + 7];
				always @(*) pmp_cfg_wdata[i][5] = sv2v_tmp_5B5A1;
				always @(*)
					case (csr_wdata_int[((i % 4) * brq_pkg_PMP_CFG_W) + 3+:2])
						2'b00: pmp_cfg_wdata[i][4-:2] = brq_pkg_PMP_MODE_OFF;
						2'b01: pmp_cfg_wdata[i][4-:2] = brq_pkg_PMP_MODE_TOR;
						2'b10: pmp_cfg_wdata[i][4-:2] = (PMPGranularity == 0 ? brq_pkg_PMP_MODE_NA4 : brq_pkg_PMP_MODE_OFF);
						2'b11: pmp_cfg_wdata[i][4-:2] = brq_pkg_PMP_MODE_NAPOT;
						default: pmp_cfg_wdata[i][4-:2] = brq_pkg_PMP_MODE_OFF;
					endcase
				wire [1:1] sv2v_tmp_7A6DE;
				assign sv2v_tmp_7A6DE = csr_wdata_int[((i % 4) * brq_pkg_PMP_CFG_W) + 2];
				always @(*) pmp_cfg_wdata[i][2] = sv2v_tmp_7A6DE;
				wire [1:1] sv2v_tmp_65F7E;
				assign sv2v_tmp_65F7E = &csr_wdata_int[(i % 4) * brq_pkg_PMP_CFG_W+:2];
				always @(*) pmp_cfg_wdata[i][1] = sv2v_tmp_65F7E;
				wire [1:1] sv2v_tmp_54FD8;
				assign sv2v_tmp_54FD8 = csr_wdata_int[(i % 4) * brq_pkg_PMP_CFG_W];
				always @(*) pmp_cfg_wdata[i][0] = sv2v_tmp_54FD8;
				brq_csr #(
					.Width(6),
					.ShadowCopy(ShadowCSR),
					.ResetValue(1'sb0)
				) u_pmp_cfg_csr(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.wr_data_i({pmp_cfg_wdata[i]}),
					.wr_en_i(pmp_cfg_we[i]),
					.rd_data_o(pmp_cfg[i]),
					.rd_error_o(pmp_cfg_err[i])
				);
				if (i < (PMPNumRegions - 1)) begin : g_lower
					assign pmp_addr_we[i] = ((csr_we_int & ~pmp_cfg[i][5]) & (~pmp_cfg[i + 1][5] | (pmp_cfg[i + 1][4-:2] != brq_pkg_PMP_MODE_TOR))) & (csr_addr == (brq_pkg_CSR_OFF_PMP_ADDR + i[11:0]));
				end
				else begin : g_upper
					assign pmp_addr_we[i] = (csr_we_int & ~pmp_cfg[i][5]) & (csr_addr == (brq_pkg_CSR_OFF_PMP_ADDR + i[11:0]));
				end
				brq_csr #(
					.Width(PMPAddrWidth),
					.ShadowCopy(ShadowCSR),
					.ResetValue(1'sb0)
				) u_pmp_addr_csr(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.wr_data_i(csr_wdata_int[31-:PMPAddrWidth]),
					.wr_en_i(pmp_addr_we[i]),
					.rd_data_o(pmp_addr[i]),
					.rd_error_o(pmp_addr_err[i])
				);
				assign csr_pmp_cfg_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 6+:6] = pmp_cfg[i];
				assign csr_pmp_addr_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 34+:34] = {pmp_addr_rdata[i], 2'b00};
			end
			assign pmp_csr_err = |pmp_cfg_err | |pmp_addr_err;
		end
		else begin : g_no_pmp_tieoffs
			genvar i;
			for (i = 0; i < brq_pkg_PMP_MAX_REGIONS; i = i + 1) begin : g_rdata
				wire [32:1] sv2v_tmp_313D8;
				assign sv2v_tmp_313D8 = {32 {1'sb0}};
				always @(*) pmp_addr_rdata[i] = sv2v_tmp_313D8;
				assign pmp_cfg_rdata[i] = {8 {1'sb0}};
			end
			for (i = 0; i < PMPNumRegions; i = i + 1) begin : g_outputs
				function automatic [5:0] sv2v_cast_6;
					input reg [5:0] inp;
					sv2v_cast_6 = inp;
				endfunction
				assign csr_pmp_cfg_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 6+:6] = sv2v_cast_6(1'b0);
				assign csr_pmp_addr_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 34+:34] = {34 {1'sb0}};
			end
			assign pmp_csr_err = 1'b0;
		end
	endgenerate
	always @(*) begin : mcountinhibit_update
		if (mcountinhibit_we == 1'b1)
			mcountinhibit_d = {csr_wdata_int[MHPMCounterNum + 2:2], 1'b0, csr_wdata_int[0]};
		else
			mcountinhibit_d = mcountinhibit_q;
	end
	always @(*) begin : gen_mhpmcounter_incr
		begin : sv2v_autoblock_83
			reg [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				begin : gen_mhpmcounter_incr_inactive
					mhpmcounter_incr[i] = 1'b0;
				end
		end
		mhpmcounter_incr[0] = 1'b1;
		mhpmcounter_incr[1] = 1'b0;
		mhpmcounter_incr[2] = instr_ret_i;
		mhpmcounter_incr[3] = dside_wait_i;
		mhpmcounter_incr[4] = iside_wait_i;
		mhpmcounter_incr[5] = mem_load_i;
		mhpmcounter_incr[6] = mem_store_i;
		mhpmcounter_incr[7] = jump_i;
		mhpmcounter_incr[8] = branch_i;
		mhpmcounter_incr[9] = branch_taken_i;
		mhpmcounter_incr[10] = instr_ret_compressed_i;
		mhpmcounter_incr[11] = mul_wait_i;
		mhpmcounter_incr[12] = div_wait_i;
	end
	always @(*) begin : gen_mhpmevent
		begin : sv2v_autoblock_84
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				begin : gen_mhpmevent_active
					mhpmevent[i] = {32 {1'sb0}};
					mhpmevent[i][i] = 1'b1;
				end
		end
		mhpmevent[1] = {32 {1'sb0}};
		begin : sv2v_autoblock_85
			reg [31:0] i;
			for (i = 3 + MHPMCounterNum; i < 32; i = i + 1)
				begin : gen_mhpmevent_inactive
					mhpmevent[i] = {32 {1'sb0}};
				end
		end
	end
	brq_counter #(.CounterWidth(64)) mcycle_counter_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.counter_inc_i(mhpmcounter_incr[0] & ~mcountinhibit[0]),
		.counterh_we_i(mhpmcounterh_we[0]),
		.counter_we_i(mhpmcounter_we[0]),
		.counter_val_i(csr_wdata_int),
		.counter_val_o(mhpmcounter[0])
	);
	brq_counter #(.CounterWidth(64)) minstret_counter_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.counter_inc_i(mhpmcounter_incr[2] & ~mcountinhibit[2]),
		.counterh_we_i(mhpmcounterh_we[2]),
		.counter_we_i(mhpmcounter_we[2]),
		.counter_val_i(csr_wdata_int),
		.counter_val_o(mhpmcounter[2])
	);
	assign mhpmcounter[1] = {64 {1'sb0}};
	assign unused_mhpmcounter_we_1 = mhpmcounter_we[1];
	assign unused_mhpmcounterh_we_1 = mhpmcounterh_we[1];
	assign unused_mhpmcounter_incr_1 = mhpmcounter_incr[1];
	generate
		genvar cnt;
		for (cnt = 0; cnt < 29; cnt = cnt + 1) begin : gen_cntrs
			if (cnt < MHPMCounterNum) begin : gen_imp
				brq_counter #(.CounterWidth(MHPMCounterWidth)) mcounters_variable_i(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.counter_inc_i(mhpmcounter_incr[cnt + 3] & ~mcountinhibit[cnt + 3]),
					.counterh_we_i(mhpmcounterh_we[cnt + 3]),
					.counter_we_i(mhpmcounter_we[cnt + 3]),
					.counter_val_i(csr_wdata_int),
					.counter_val_o(mhpmcounter[cnt + 3])
				);
			end
			else begin : gen_unimp
				assign mhpmcounter[cnt + 3] = {64 {1'sb0}};
			end
		end
	endgenerate
	generate
		if (MHPMCounterNum < 29) begin : g_mcountinhibit_reduced
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounter_we;
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounterh_we;
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounter_incr;
			assign mcountinhibit = {{29 - MHPMCounterNum {1'b1}}, mcountinhibit_q};
			assign unused_mhphcounter_we = mhpmcounter_we[31:MHPMCounterNum + 3];
			assign unused_mhphcounterh_we = mhpmcounterh_we[31:MHPMCounterNum + 3];
			assign unused_mhphcounter_incr = mhpmcounter_incr[31:MHPMCounterNum + 3];
		end
		else begin : g_mcountinhibit_full
			assign mcountinhibit = mcountinhibit_q;
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			mcountinhibit_q <= {((MHPMCounterNum + 2) >= 0 ? MHPMCounterNum + 3 : 1 - (MHPMCounterNum + 2)) {1'sb0}};
		else
			mcountinhibit_q <= mcountinhibit_d;
	generate
		if (DbgTriggerEn) begin : gen_trigger_regs
			localparam [31:0] DbgHwNumLen = (DbgHwBreakNum > 1 ? $clog2(DbgHwBreakNum) : 1);
			wire [DbgHwNumLen - 1:0] tselect_d;
			wire [DbgHwNumLen - 1:0] tselect_q;
			wire tmatch_control_d;
			wire [DbgHwBreakNum - 1:0] tmatch_control_q;
			wire [31:0] tmatch_value_d;
			wire [31:0] tmatch_value_q [0:DbgHwBreakNum - 1];
			wire tselect_we;
			wire [DbgHwBreakNum - 1:0] tmatch_control_we;
			wire [DbgHwBreakNum - 1:0] tmatch_value_we;
			wire [DbgHwBreakNum - 1:0] trigger_match;
			assign tselect_we = (csr_we_int & debug_mode_i) & (csr_addr_i == brq_pkg_CSR_TSELECT);
			genvar i;
			for (i = 0; i < DbgHwBreakNum; i = i + 1) begin : g_dbg_tmatch_we
				assign tmatch_control_we[i] = (((i[DbgHwNumLen - 1:0] == tselect_q) & csr_we_int) & debug_mode_i) & (csr_addr_i == brq_pkg_CSR_TDATA1);
				assign tmatch_value_we[i] = (((i[DbgHwNumLen - 1:0] == tselect_q) & csr_we_int) & debug_mode_i) & (csr_addr_i == brq_pkg_CSR_TDATA2);
			end
			assign tselect_d = (csr_wdata_int < DbgHwBreakNum ? csr_wdata_int[DbgHwNumLen - 1:0] : DbgHwBreakNum - 1);
			assign tmatch_control_d = csr_wdata_int[2];
			assign tmatch_value_d = csr_wdata_int[31:0];
			brq_csr #(
				.Width(DbgHwNumLen),
				.ShadowCopy(1'b0),
				.ResetValue(1'sb0)
			) u_tselect_csr(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.wr_data_i(tselect_d),
				.wr_en_i(tselect_we),
				.rd_data_o(tselect_q),
				.rd_error_o(unused_error15)
			);
			for (i = 0; i < DbgHwBreakNum; i = i + 1) begin : g_dbg_tmatch_reg
				brq_csr #(
					.Width(1),
					.ShadowCopy(1'b0),
					.ResetValue(1'sb0)
				) u_tmatch_control_csr(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.wr_data_i(tmatch_control_d),
					.wr_en_i(tmatch_control_we[i]),
					.rd_data_o(tmatch_control_q[i]),
					.rd_error_o(unused_error16)
				);
				brq_csr #(
					.Width(32),
					.ShadowCopy(1'b0),
					.ResetValue(1'sb0)
				) u_tmatch_value_csr(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.wr_data_i(tmatch_value_d),
					.wr_en_i(tmatch_value_we[i]),
					.rd_data_o(tmatch_value_q[i]),
					.rd_error_o(unused_error17)
				);
			end
			localparam [31:0] TSelectRdataPadlen = (DbgHwNumLen >= 32 ? 0 : 32 - DbgHwNumLen);
			assign tselect_rdata = {{TSelectRdataPadlen {1'b0}}, tselect_q};
			assign tmatch_control_rdata = {29'b00101000000000000001000001001, tmatch_control_q[tselect_q], 1'b0, 1'b0};
			assign tmatch_value_rdata = tmatch_value_q[tselect_q];
			for (i = 0; i < DbgHwBreakNum; i = i + 1) begin : g_dbg_trigger_match
				assign trigger_match[i] = tmatch_control_q[i] & (pc_if_i[31:0] == tmatch_value_q[i]);
			end
			assign trigger_match_o = |trigger_match;
		end
		else begin : gen_no_trigger_regs
			assign tselect_rdata = 'b0;
			assign tmatch_control_rdata = 'b0;
			assign tmatch_value_rdata = 'b0;
			assign trigger_match_o = 'b0;
		end
	endgenerate
	assign cpuctrl_wdata = csr_wdata_int[5:0];
	generate
		if (DataIndTiming) begin : gen_dit
			assign cpuctrl_d[1] = cpuctrl_wdata[1];
		end
		else begin : gen_no_dit
			wire unused_dit;
			assign unused_dit = cpuctrl_wdata[1];
			assign cpuctrl_d[1] = 1'b0;
		end
	endgenerate
	assign data_ind_timing_o = cpuctrl_q[1];
	generate
		if (DummyInstructions) begin : gen_dummy
			assign cpuctrl_d[2] = cpuctrl_wdata[2];
			assign cpuctrl_d[5-:3] = cpuctrl_wdata[5-:3];
			assign dummy_instr_seed_en_o = csr_we_int && (csr_addr == brq_pkg_CSR_SECURESEED);
			assign dummy_instr_seed_o = csr_wdata_int;
		end
		else begin : gen_no_dummy
			wire unused_dummy_en;
			wire [2:0] unused_dummy_mask;
			assign unused_dummy_en = cpuctrl_wdata[2];
			assign unused_dummy_mask = cpuctrl_wdata[5-:3];
			assign cpuctrl_d[2] = 1'b0;
			assign cpuctrl_d[5-:3] = 3'b000;
			assign dummy_instr_seed_en_o = 1'b0;
			assign dummy_instr_seed_o = {32 {1'sb0}};
		end
	endgenerate
	assign dummy_instr_en_o = cpuctrl_q[2];
	assign dummy_instr_mask_o = cpuctrl_q[5-:3];
	generate
		if (ICache) begin : gen_icache_enable
			assign cpuctrl_d[0] = cpuctrl_wdata[0];
		end
		else begin : gen_no_icache
			wire unused_icen;
			assign unused_icen = cpuctrl_wdata[0];
			assign cpuctrl_d[0] = 1'b0;
		end
	endgenerate
	assign icache_enable_o = cpuctrl_q[0];
	brq_csr #(
		.Width(6),
		.ShadowCopy(ShadowCSR),
		.ResetValue(1'sb0)
	) u_cpuctrl_csr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.wr_data_i({cpuctrl_d}),
		.wr_en_i(cpuctrl_we),
		.rd_data_o(cpuctrl_q),
		.rd_error_o(cpuctrl_err)
	);
	assign csr_shadow_err_o = ((mstatus_err | mtvec_err) | pmp_csr_err) | cpuctrl_err;
endmodule
module brq_csr (
	clk_i,
	rst_ni,
	wr_data_i,
	wr_en_i,
	rd_data_o,
	rd_error_o
);
	parameter [31:0] Width = 32;
	parameter [0:0] ShadowCopy = 1'b0;
	parameter [Width - 1:0] ResetValue = 1'sb0;
	input wire clk_i;
	input wire rst_ni;
	input wire [Width - 1:0] wr_data_i;
	input wire wr_en_i;
	output wire [Width - 1:0] rd_data_o;
	output wire rd_error_o;
	reg [Width - 1:0] rdata_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rdata_q <= ResetValue;
		else if (wr_en_i)
			rdata_q <= wr_data_i;
	assign rd_data_o = rdata_q;
	generate
		if (ShadowCopy) begin : gen_shadow
			reg [Width - 1:0] shadow_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					shadow_q <= ~ResetValue;
				else if (wr_en_i)
					shadow_q <= ~wr_data_i;
			assign rd_error_o = rdata_q != ~shadow_q;
		end
		else begin : gen_no_shadow
			assign rd_error_o = 1'b0;
		end
	endgenerate
endmodule
module brq_exu_alu (
	operator_i,
	operand_a_i,
	operand_b_i,
	instr_first_cycle_i,
	multdiv_operand_a_i,
	multdiv_operand_b_i,
	multdiv_sel_i,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	adder_result_o,
	adder_result_ext_o,
	result_o,
	comparison_result_o,
	is_equal_result_o
);
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	input wire [5:0] operator_i;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	input wire instr_first_cycle_i;
	input wire [32:0] multdiv_operand_a_i;
	input wire [32:0] multdiv_operand_b_i;
	input wire multdiv_sel_i;
	input wire [63:0] imd_val_q_i;
	output reg [63:0] imd_val_d_o;
	output reg [1:0] imd_val_we_o;
	output wire [31:0] adder_result_o;
	output wire [33:0] adder_result_ext_o;
	output reg [31:0] result_o;
	output wire comparison_result_o;
	output wire is_equal_result_o;
	wire [31:0] operand_a_rev;
	wire [32:0] operand_b_neg;
	generate
		genvar k;
		for (k = 0; k < 32; k = k + 1) begin : gen_rev_operand_a
			assign operand_a_rev[k] = operand_a_i[31 - k];
		end
	endgenerate
	reg adder_op_b_negate;
	wire [32:0] adder_in_a;
	reg [32:0] adder_in_b;
	wire [31:0] adder_result;
	localparam [5:0] brq_pkg_ALU_EQ = 23;
	localparam [5:0] brq_pkg_ALU_GE = 21;
	localparam [5:0] brq_pkg_ALU_GEU = 22;
	localparam [5:0] brq_pkg_ALU_LT = 19;
	localparam [5:0] brq_pkg_ALU_LTU = 20;
	localparam [5:0] brq_pkg_ALU_MAX = 27;
	localparam [5:0] brq_pkg_ALU_MAXU = 28;
	localparam [5:0] brq_pkg_ALU_MIN = 25;
	localparam [5:0] brq_pkg_ALU_MINU = 26;
	localparam [5:0] brq_pkg_ALU_NE = 24;
	localparam [5:0] brq_pkg_ALU_SLT = 37;
	localparam [5:0] brq_pkg_ALU_SLTU = 38;
	localparam [5:0] brq_pkg_ALU_SUB = 1;
	always @(*) begin
		adder_op_b_negate = 1'b0;
		case (operator_i)
			brq_pkg_ALU_SUB, brq_pkg_ALU_EQ, brq_pkg_ALU_NE, brq_pkg_ALU_GE, brq_pkg_ALU_GEU, brq_pkg_ALU_LT, brq_pkg_ALU_LTU, brq_pkg_ALU_SLT, brq_pkg_ALU_SLTU, brq_pkg_ALU_MIN, brq_pkg_ALU_MINU, brq_pkg_ALU_MAX, brq_pkg_ALU_MAXU: adder_op_b_negate = 1'b1;
			default:
				;
		endcase
	end
	assign adder_in_a = (multdiv_sel_i ? multdiv_operand_a_i : {operand_a_i, 1'b1});
	assign operand_b_neg = {operand_b_i, 1'b0} ^ {33 {1'b1}};
	always @(*)
		case (1'b1)
			multdiv_sel_i: adder_in_b = multdiv_operand_b_i;
			adder_op_b_negate: adder_in_b = operand_b_neg;
			default: adder_in_b = {operand_b_i, 1'b0};
		endcase
	assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);
	assign adder_result = adder_result_ext_o[32:1];
	assign adder_result_o = adder_result;
	wire is_equal;
	reg is_greater_equal;
	reg cmp_signed;
	always @(*)
		case (operator_i)
			brq_pkg_ALU_GE, brq_pkg_ALU_LT, brq_pkg_ALU_SLT, brq_pkg_ALU_MIN, brq_pkg_ALU_MAX: cmp_signed = 1'b1;
			default: cmp_signed = 1'b0;
		endcase
	assign is_equal = adder_result == 32'b00000000000000000000000000000000;
	assign is_equal_result_o = is_equal;
	always @(*)
		if ((operand_a_i[31] ^ operand_b_i[31]) == 1'b0)
			is_greater_equal = adder_result[31] == 1'b0;
		else
			is_greater_equal = operand_a_i[31] ^ cmp_signed;
	reg cmp_result;
	always @(*)
		case (operator_i)
			brq_pkg_ALU_EQ: cmp_result = is_equal;
			brq_pkg_ALU_NE: cmp_result = ~is_equal;
			brq_pkg_ALU_GE, brq_pkg_ALU_GEU, brq_pkg_ALU_MAX, brq_pkg_ALU_MAXU: cmp_result = is_greater_equal;
			brq_pkg_ALU_LT, brq_pkg_ALU_LTU, brq_pkg_ALU_MIN, brq_pkg_ALU_MINU, brq_pkg_ALU_SLT, brq_pkg_ALU_SLTU: cmp_result = ~is_greater_equal;
			default: cmp_result = is_equal;
		endcase
	assign comparison_result_o = cmp_result;
	reg shift_left;
	wire shift_ones;
	wire shift_arith;
	wire shift_funnel;
	wire shift_sbmode;
	reg [5:0] shift_amt;
	wire [5:0] shift_amt_compl;
	reg [31:0] shift_operand;
	reg [32:0] shift_result_ext;
	reg unused_shift_result_ext;
	reg [31:0] shift_result;
	reg [31:0] shift_result_rev;
	wire bfp_op;
	wire [4:0] bfp_len;
	wire [4:0] bfp_off;
	wire [31:0] bfp_mask;
	wire [31:0] bfp_mask_rev;
	wire [31:0] bfp_result;
	localparam [5:0] brq_pkg_ALU_BFP = 49;
	assign bfp_op = (RV32B != brq_pkg_RV32BNone ? operator_i == brq_pkg_ALU_BFP : 1'b0);
	assign bfp_len = {~(|operand_b_i[27:24]), operand_b_i[27:24]};
	assign bfp_off = operand_b_i[20:16];
	assign bfp_mask = (RV32B != brq_pkg_RV32BNone ? ~(32'hffffffff << bfp_len) : {32 {1'sb0}});
	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin : gen_rev_bfp_mask
			assign bfp_mask_rev[i] = bfp_mask[31 - i];
		end
	endgenerate
	assign bfp_result = (RV32B != brq_pkg_RV32BNone ? (~shift_result & operand_a_i) | ((operand_b_i & bfp_mask) << bfp_off) : {32 {1'sb0}});
	wire [1:1] sv2v_tmp_86907;
	assign sv2v_tmp_86907 = operand_b_i[5] & shift_funnel;
	always @(*) shift_amt[5] = sv2v_tmp_86907;
	assign shift_amt_compl = 32 - operand_b_i[4:0];
	always @(*)
		if (bfp_op)
			shift_amt[4:0] = bfp_off;
		else
			shift_amt[4:0] = (instr_first_cycle_i ? (operand_b_i[5] && shift_funnel ? shift_amt_compl[4:0] : operand_b_i[4:0]) : (operand_b_i[5] && shift_funnel ? operand_b_i[4:0] : shift_amt_compl[4:0]));
	localparam [5:0] brq_pkg_ALU_SBCLR = 44;
	localparam [5:0] brq_pkg_ALU_SBINV = 45;
	localparam [5:0] brq_pkg_ALU_SBSET = 43;
	assign shift_sbmode = (RV32B != brq_pkg_RV32BNone ? ((operator_i == brq_pkg_ALU_SBSET) | (operator_i == brq_pkg_ALU_SBCLR)) | (operator_i == brq_pkg_ALU_SBINV) : 1'b0);
	localparam [5:0] brq_pkg_ALU_FSL = 41;
	localparam [5:0] brq_pkg_ALU_FSR = 42;
	localparam [5:0] brq_pkg_ALU_ROL = 14;
	localparam [5:0] brq_pkg_ALU_ROR = 13;
	localparam [5:0] brq_pkg_ALU_SLL = 10;
	localparam [5:0] brq_pkg_ALU_SLO = 12;
	always @(*) begin
		case (operator_i)
			brq_pkg_ALU_SLL: shift_left = 1'b1;
			brq_pkg_ALU_SLO, brq_pkg_ALU_BFP: shift_left = (RV32B != brq_pkg_RV32BNone ? 1'b1 : 1'b0);
			brq_pkg_ALU_ROL: shift_left = (RV32B != brq_pkg_RV32BNone ? instr_first_cycle_i : 0);
			brq_pkg_ALU_ROR: shift_left = (RV32B != brq_pkg_RV32BNone ? ~instr_first_cycle_i : 0);
			brq_pkg_ALU_FSL: shift_left = (RV32B != brq_pkg_RV32BNone ? (shift_amt[5] ? ~instr_first_cycle_i : instr_first_cycle_i) : 1'b0);
			brq_pkg_ALU_FSR: shift_left = (RV32B != brq_pkg_RV32BNone ? (shift_amt[5] ? instr_first_cycle_i : ~instr_first_cycle_i) : 1'b0);
			default: shift_left = 1'b0;
		endcase
		if (shift_sbmode)
			shift_left = 1'b1;
	end
	localparam [5:0] brq_pkg_ALU_SRA = 8;
	assign shift_arith = operator_i == brq_pkg_ALU_SRA;
	localparam [5:0] brq_pkg_ALU_SRO = 11;
	assign shift_ones = (RV32B != brq_pkg_RV32BNone ? (operator_i == brq_pkg_ALU_SLO) | (operator_i == brq_pkg_ALU_SRO) : 1'b0);
	assign shift_funnel = (RV32B != brq_pkg_RV32BNone ? (operator_i == brq_pkg_ALU_FSL) | (operator_i == brq_pkg_ALU_FSR) : 1'b0);
	always @(*) begin
		if (RV32B == brq_pkg_RV32BNone)
			shift_operand = (shift_left ? operand_a_rev : operand_a_i);
		else
			case (1'b1)
				bfp_op: shift_operand = bfp_mask_rev;
				shift_sbmode: shift_operand = 32'h80000000;
				default: shift_operand = (shift_left ? operand_a_rev : operand_a_i);
			endcase
		shift_result_ext = $unsigned($signed({shift_ones | (shift_arith & shift_operand[31]), shift_operand}) >>> shift_amt[4:0]);
		shift_result = shift_result_ext[31:0];
		unused_shift_result_ext = shift_result_ext[32];
		begin : sv2v_autoblock_86
			reg [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				shift_result_rev[i] = shift_result[31 - i];
		end
		shift_result = (shift_left ? shift_result_rev : shift_result);
	end
	wire bwlogic_or;
	wire bwlogic_and;
	wire [31:0] bwlogic_operand_b;
	wire [31:0] bwlogic_or_result;
	wire [31:0] bwlogic_and_result;
	wire [31:0] bwlogic_xor_result;
	reg [31:0] bwlogic_result;
	reg bwlogic_op_b_negate;
	localparam [5:0] brq_pkg_ALU_ANDN = 7;
	localparam [5:0] brq_pkg_ALU_CMIX = 40;
	localparam [5:0] brq_pkg_ALU_ORN = 6;
	localparam [5:0] brq_pkg_ALU_XNOR = 5;
	always @(*)
		case (operator_i)
			brq_pkg_ALU_XNOR, brq_pkg_ALU_ORN, brq_pkg_ALU_ANDN: bwlogic_op_b_negate = (RV32B != brq_pkg_RV32BNone ? 1'b1 : 1'b0);
			brq_pkg_ALU_CMIX: bwlogic_op_b_negate = (RV32B != brq_pkg_RV32BNone ? ~instr_first_cycle_i : 1'b0);
			default: bwlogic_op_b_negate = 1'b0;
		endcase
	assign bwlogic_operand_b = (bwlogic_op_b_negate ? operand_b_neg[32:1] : operand_b_i);
	assign bwlogic_or_result = operand_a_i | bwlogic_operand_b;
	assign bwlogic_and_result = operand_a_i & bwlogic_operand_b;
	assign bwlogic_xor_result = operand_a_i ^ bwlogic_operand_b;
	localparam [5:0] brq_pkg_ALU_OR = 3;
	assign bwlogic_or = (operator_i == brq_pkg_ALU_OR) | (operator_i == brq_pkg_ALU_ORN);
	localparam [5:0] brq_pkg_ALU_AND = 4;
	assign bwlogic_and = (operator_i == brq_pkg_ALU_AND) | (operator_i == brq_pkg_ALU_ANDN);
	always @(*)
		case (1'b1)
			bwlogic_or: bwlogic_result = bwlogic_or_result;
			bwlogic_and: bwlogic_result = bwlogic_and_result;
			default: bwlogic_result = bwlogic_xor_result;
		endcase
	wire [5:0] bitcnt_result;
	wire [31:0] minmax_result;
	reg [31:0] pack_result;
	wire [31:0] sext_result;
	reg [31:0] singlebit_result;
	reg [31:0] rev_result;
	reg [31:0] shuffle_result;
	reg [31:0] butterfly_result;
	reg [31:0] invbutterfly_result;
	reg [31:0] clmul_result;
	reg [31:0] multicycle_result;
	localparam [5:0] brq_pkg_ALU_BDEP = 48;
	localparam [5:0] brq_pkg_ALU_BEXT = 47;
	localparam [5:0] brq_pkg_ALU_CLMULH = 52;
	localparam [5:0] brq_pkg_ALU_CLMULR = 51;
	localparam [5:0] brq_pkg_ALU_CLZ = 34;
	localparam [5:0] brq_pkg_ALU_CMOV = 39;
	localparam [5:0] brq_pkg_ALU_CRC32C_B = 54;
	localparam [5:0] brq_pkg_ALU_CRC32C_H = 56;
	localparam [5:0] brq_pkg_ALU_CRC32C_W = 58;
	localparam [5:0] brq_pkg_ALU_CRC32_B = 53;
	localparam [5:0] brq_pkg_ALU_CRC32_H = 55;
	localparam [5:0] brq_pkg_ALU_CRC32_W = 57;
	localparam [5:0] brq_pkg_ALU_CTZ = 35;
	localparam [5:0] brq_pkg_ALU_GORC = 16;
	localparam [5:0] brq_pkg_ALU_PACKH = 31;
	localparam [5:0] brq_pkg_ALU_PACKU = 30;
	localparam [5:0] brq_pkg_ALU_SEXTB = 32;
	localparam [5:0] brq_pkg_ALU_UNSHFL = 18;
	localparam integer brq_pkg_RV32BFull = 2;
	generate
		if (RV32B != brq_pkg_RV32BNone) begin : g_alu_rvb
			wire zbe_op;
			wire bitcnt_ctz;
			wire bitcnt_clz;
			wire bitcnt_cz;
			reg [31:0] bitcnt_bits;
			wire [31:0] bitcnt_mask_op;
			reg [31:0] bitcnt_bit_mask;
			reg [191:0] bitcnt_partial;
			wire [31:0] bitcnt_partial_lsb_d;
			wire [31:0] bitcnt_partial_msb_d;
			assign bitcnt_ctz = operator_i == brq_pkg_ALU_CTZ;
			assign bitcnt_clz = operator_i == brq_pkg_ALU_CLZ;
			assign bitcnt_cz = bitcnt_ctz | bitcnt_clz;
			assign bitcnt_result = bitcnt_partial[0+:6];
			assign bitcnt_mask_op = (bitcnt_clz ? operand_a_rev : operand_a_i);
			always @(*) begin
				bitcnt_bit_mask = bitcnt_mask_op;
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 1);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 2);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 4);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 8);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 16);
				bitcnt_bit_mask = ~bitcnt_bit_mask;
			end
			assign zbe_op = (operator_i == brq_pkg_ALU_BEXT) | (operator_i == brq_pkg_ALU_BDEP);
			always @(*)
				case (1'b1)
					zbe_op: bitcnt_bits = operand_b_i;
					bitcnt_cz: bitcnt_bits = bitcnt_bit_mask & ~bitcnt_mask_op;
					default: bitcnt_bits = operand_a_i;
				endcase
			always @(*) begin
				bitcnt_partial = {32 {6'b000000}};
				begin : sv2v_autoblock_87
					reg [31:0] i;
					for (i = 1; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = {5'h00, bitcnt_bits[i]} + {5'h00, bitcnt_bits[i - 1]};
				end
				begin : sv2v_autoblock_88
					reg [31:0] i;
					for (i = 3; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_89
					reg [31:0] i;
					for (i = 7; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_90
					reg [31:0] i;
					for (i = 15; i < 32; i = i + 16)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(39 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[0+:6] = bitcnt_partial[96+:6] + bitcnt_partial[0+:6];
				bitcnt_partial[48+:6] = bitcnt_partial[96+:6] + bitcnt_partial[48+:6];
				begin : sv2v_autoblock_91
					reg [31:0] i;
					for (i = 11; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_92
					reg [31:0] i;
					for (i = 5; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[186+:6] = {5'h00, bitcnt_bits[0]};
				begin : sv2v_autoblock_93
					reg [31:0] i;
					for (i = 2; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(32 - i) * 6+:6] + {5'h00, bitcnt_bits[i]};
				end
			end
			assign minmax_result = (cmp_result ? operand_a_i : operand_b_i);
			wire packu;
			wire packh;
			assign packu = operator_i == brq_pkg_ALU_PACKU;
			assign packh = operator_i == brq_pkg_ALU_PACKH;
			always @(*)
				case (1'b1)
					packu: pack_result = {operand_b_i[31:16], operand_a_i[31:16]};
					packh: pack_result = {16'h0000, operand_b_i[7:0], operand_a_i[7:0]};
					default: pack_result = {operand_b_i[15:0], operand_a_i[15:0]};
				endcase
			assign sext_result = (operator_i == brq_pkg_ALU_SEXTB ? {{24 {operand_a_i[7]}}, operand_a_i[7:0]} : {{16 {operand_a_i[15]}}, operand_a_i[15:0]});
			always @(*)
				case (operator_i)
					brq_pkg_ALU_SBSET: singlebit_result = operand_a_i | shift_result;
					brq_pkg_ALU_SBCLR: singlebit_result = operand_a_i & ~shift_result;
					brq_pkg_ALU_SBINV: singlebit_result = operand_a_i ^ shift_result;
					default: singlebit_result = {31'h00000000, shift_result[0]};
				endcase
			wire [4:0] zbp_shift_amt;
			wire gorc_op;
			assign gorc_op = operator_i == brq_pkg_ALU_GORC;
			assign zbp_shift_amt[2:0] = (RV32B == brq_pkg_RV32BFull ? shift_amt[2:0] : {3 {&shift_amt[2:0]}});
			assign zbp_shift_amt[4:3] = (RV32B == brq_pkg_RV32BFull ? shift_amt[4:3] : {2 {&shift_amt[4:3]}});
			always @(*) begin
				rev_result = operand_a_i;
				if (zbp_shift_amt[0])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h55555555) << 1)) | ((rev_result & 32'haaaaaaaa) >> 1);
				if (zbp_shift_amt[1])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h33333333) << 2)) | ((rev_result & 32'hcccccccc) >> 2);
				if (zbp_shift_amt[2])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h0f0f0f0f) << 4)) | ((rev_result & 32'hf0f0f0f0) >> 4);
				if (zbp_shift_amt[3])
					rev_result = ((gorc_op & (RV32B == brq_pkg_RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h00ff00ff) << 8)) | ((rev_result & 32'hff00ff00) >> 8);
				if (zbp_shift_amt[4])
					rev_result = ((gorc_op & (RV32B == brq_pkg_RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h0000ffff) << 16)) | ((rev_result & 32'hffff0000) >> 16);
			end
			wire crc_hmode;
			wire crc_bmode;
			wire [31:0] clmul_result_rev;
			if (RV32B == brq_pkg_RV32BFull) begin : gen_alu_rvb_full
				localparam [127:0] SHUFFLE_MASK_L = 128'h00ff00000f000f003030303044444444;
				localparam [127:0] SHUFFLE_MASK_R = 128'h0000ff0000f000f00c0c0c0c22222222;
				localparam [127:0] FLIP_MASK_L = 128'h22001100004400004411000011000000;
				localparam [127:0] FLIP_MASK_R = 128'h00880044000022000000882200000088;
				wire [31:0] SHUFFLE_MASK_NOT [0:3];
				for (i = 0; i < 4; i = i + 1) begin : gen_shuffle_mask_not
					assign SHUFFLE_MASK_NOT[i] = ~(SHUFFLE_MASK_L[(3 - i) * 32+:32] | SHUFFLE_MASK_R[(3 - i) * 32+:32]);
				end
				wire shuffle_flip;
				assign shuffle_flip = operator_i == brq_pkg_ALU_UNSHFL;
				reg [3:0] shuffle_mode;
				always @(*) begin
					shuffle_result = operand_a_i;
					if (shuffle_flip) begin
						shuffle_mode[3] = shift_amt[0];
						shuffle_mode[2] = shift_amt[1];
						shuffle_mode[1] = shift_amt[2];
						shuffle_mode[0] = shift_amt[3];
					end
					else
						shuffle_mode = shift_amt[3:0];
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
					if (shuffle_mode[3])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[0]) | (((shuffle_result << 8) & SHUFFLE_MASK_L[96+:32]) | ((shuffle_result >> 8) & SHUFFLE_MASK_R[96+:32]));
					if (shuffle_mode[2])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[1]) | (((shuffle_result << 4) & SHUFFLE_MASK_L[64+:32]) | ((shuffle_result >> 4) & SHUFFLE_MASK_R[64+:32]));
					if (shuffle_mode[1])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[2]) | (((shuffle_result << 2) & SHUFFLE_MASK_L[32+:32]) | ((shuffle_result >> 2) & SHUFFLE_MASK_R[32+:32]));
					if (shuffle_mode[0])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[3]) | (((shuffle_result << 1) & SHUFFLE_MASK_L[0+:32]) | ((shuffle_result >> 1) & SHUFFLE_MASK_R[0+:32]));
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
				end
				reg [191:0] bitcnt_partial_q;
				for (i = 0; i < 32; i = i + 1) begin : gen_bitcnt_reg_in_lsb
					assign bitcnt_partial_lsb_d[i] = bitcnt_partial[(31 - i) * 6];
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_bitcnt_reg_in_b1
					assign bitcnt_partial_msb_d[i] = bitcnt_partial[((31 - ((2 * i) + 1)) * 6) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_bitcnt_reg_in_b2
					assign bitcnt_partial_msb_d[16 + i] = bitcnt_partial[((31 - ((4 * i) + 3)) * 6) + 2];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_bitcnt_reg_in_b3
					assign bitcnt_partial_msb_d[24 + i] = bitcnt_partial[((31 - ((8 * i) + 7)) * 6) + 3];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_bitcnt_reg_in_b4
					assign bitcnt_partial_msb_d[28 + i] = bitcnt_partial[((31 - ((16 * i) + 15)) * 6) + 4];
				end
				assign bitcnt_partial_msb_d[30] = bitcnt_partial[5];
				assign bitcnt_partial_msb_d[31] = 1'b0;
				always @(*) begin
					bitcnt_partial_q = {32 {6'b000000}};
					begin : sv2v_autoblock_94
						reg [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							begin : gen_bitcnt_reg_out_lsb
								bitcnt_partial_q[(31 - i) * 6] = imd_val_q_i[32 + i];
							end
					end
					begin : sv2v_autoblock_95
						reg [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin : gen_bitcnt_reg_out_b1
								bitcnt_partial_q[((31 - ((2 * i) + 1)) * 6) + 1] = imd_val_q_i[i];
							end
					end
					begin : sv2v_autoblock_96
						reg [31:0] i;
						for (i = 0; i < 8; i = i + 1)
							begin : gen_bitcnt_reg_out_b2
								bitcnt_partial_q[((31 - ((4 * i) + 3)) * 6) + 2] = imd_val_q_i[16 + i];
							end
					end
					begin : sv2v_autoblock_97
						reg [31:0] i;
						for (i = 0; i < 4; i = i + 1)
							begin : gen_bitcnt_reg_out_b3
								bitcnt_partial_q[((31 - ((8 * i) + 7)) * 6) + 3] = imd_val_q_i[24 + i];
							end
					end
					begin : sv2v_autoblock_98
						reg [31:0] i;
						for (i = 0; i < 2; i = i + 1)
							begin : gen_bitcnt_reg_out_b4
								bitcnt_partial_q[((31 - ((16 * i) + 15)) * 6) + 4] = imd_val_q_i[28 + i];
							end
					end
					bitcnt_partial_q[5] = imd_val_q_i[30];
				end
				wire [31:0] butterfly_mask_l [0:4];
				wire [31:0] butterfly_mask_r [0:4];
				wire [31:0] butterfly_mask_not [0:4];
				wire [31:0] lrotc_stage [0:4];
				genvar stg;
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_ctrl_stage
					genvar seg;
					for (seg = 0; seg < (2 ** stg); seg = seg + 1) begin : gen_butterfly_ctrl
						assign lrotc_stage[stg][((2 * (16 >> stg)) * (seg + 1)) - 1:(2 * (16 >> stg)) * seg] = {{16 >> stg {1'b0}}, {16 >> stg {1'b1}}} << bitcnt_partial_q[((32 - ((16 >> stg) * ((2 * seg) + 1))) * 6) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) : ($clog2(16 >> stg) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))) - 1)-:($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = {((((16 >> stg) * ((2 * seg) + 1)) - 1) >= ((16 >> stg) * (2 * seg)) ? ((((16 >> stg) * ((2 * seg) + 1)) - 1) - ((16 >> stg) * (2 * seg))) + 1 : (((16 >> stg) * (2 * seg)) - (((16 >> stg) * ((2 * seg) + 1)) - 1)) + 1) {1'sb0}};
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = {((((16 >> stg) * ((2 * seg) + 2)) - 1) >= ((16 >> stg) * ((2 * seg) + 1)) ? ((((16 >> stg) * ((2 * seg) + 2)) - 1) - ((16 >> stg) * ((2 * seg) + 1))) + 1 : (((16 >> stg) * ((2 * seg) + 1)) - (((16 >> stg) * ((2 * seg) + 2)) - 1)) + 1) {1'sb0}};
					end
				end
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_not
					assign butterfly_mask_not[stg] = ~(butterfly_mask_l[stg] | butterfly_mask_r[stg]);
				end
				always @(*) begin
					butterfly_result = operand_a_i;
					butterfly_result = ((butterfly_result & butterfly_mask_not[0]) | ((butterfly_result & butterfly_mask_l[0]) >> 16)) | ((butterfly_result & butterfly_mask_r[0]) << 16);
					butterfly_result = ((butterfly_result & butterfly_mask_not[1]) | ((butterfly_result & butterfly_mask_l[1]) >> 8)) | ((butterfly_result & butterfly_mask_r[1]) << 8);
					butterfly_result = ((butterfly_result & butterfly_mask_not[2]) | ((butterfly_result & butterfly_mask_l[2]) >> 4)) | ((butterfly_result & butterfly_mask_r[2]) << 4);
					butterfly_result = ((butterfly_result & butterfly_mask_not[3]) | ((butterfly_result & butterfly_mask_l[3]) >> 2)) | ((butterfly_result & butterfly_mask_r[3]) << 2);
					butterfly_result = ((butterfly_result & butterfly_mask_not[4]) | ((butterfly_result & butterfly_mask_l[4]) >> 1)) | ((butterfly_result & butterfly_mask_r[4]) << 1);
					butterfly_result = butterfly_result & operand_b_i;
				end
				always @(*) begin
					invbutterfly_result = operand_a_i & operand_b_i;
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[4]) | ((invbutterfly_result & butterfly_mask_l[4]) >> 1)) | ((invbutterfly_result & butterfly_mask_r[4]) << 1);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[3]) | ((invbutterfly_result & butterfly_mask_l[3]) >> 2)) | ((invbutterfly_result & butterfly_mask_r[3]) << 2);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[2]) | ((invbutterfly_result & butterfly_mask_l[2]) >> 4)) | ((invbutterfly_result & butterfly_mask_r[2]) << 4);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[1]) | ((invbutterfly_result & butterfly_mask_l[1]) >> 8)) | ((invbutterfly_result & butterfly_mask_r[1]) << 8);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[0]) | ((invbutterfly_result & butterfly_mask_l[0]) >> 16)) | ((invbutterfly_result & butterfly_mask_r[0]) << 16);
				end
				wire clmul_rmode;
				wire clmul_hmode;
				reg [31:0] clmul_op_a;
				reg [31:0] clmul_op_b;
				wire [31:0] operand_b_rev;
				wire [31:0] clmul_and_stage [0:31];
				wire [31:0] clmul_xor_stage1 [0:15];
				wire [31:0] clmul_xor_stage2 [0:7];
				wire [31:0] clmul_xor_stage3 [0:3];
				wire [31:0] clmul_xor_stage4 [0:1];
				wire [31:0] clmul_result_raw;
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_operand_b
					assign operand_b_rev[i] = operand_b_i[31 - i];
				end
				assign clmul_rmode = operator_i == brq_pkg_ALU_CLMULR;
				assign clmul_hmode = operator_i == brq_pkg_ALU_CLMULH;
				localparam [31:0] CRC32_POLYNOMIAL = 32'h04c11db7;
				localparam [31:0] CRC32_MU_REV = 32'hf7011641;
				localparam [31:0] CRC32C_POLYNOMIAL = 32'h1edc6f41;
				localparam [31:0] CRC32C_MU_REV = 32'hdea713f1;
				wire crc_op;
				wire crc_cpoly;
				reg [31:0] crc_operand;
				wire [31:0] crc_poly;
				wire [31:0] crc_mu_rev;
				assign crc_op = (((((operator_i == brq_pkg_ALU_CRC32C_W) | (operator_i == brq_pkg_ALU_CRC32_W)) | (operator_i == brq_pkg_ALU_CRC32C_H)) | (operator_i == brq_pkg_ALU_CRC32_H)) | (operator_i == brq_pkg_ALU_CRC32C_B)) | (operator_i == brq_pkg_ALU_CRC32_B);
				assign crc_cpoly = ((operator_i == brq_pkg_ALU_CRC32C_W) | (operator_i == brq_pkg_ALU_CRC32C_H)) | (operator_i == brq_pkg_ALU_CRC32C_B);
				assign crc_hmode = (operator_i == brq_pkg_ALU_CRC32_H) | (operator_i == brq_pkg_ALU_CRC32C_H);
				assign crc_bmode = (operator_i == brq_pkg_ALU_CRC32_B) | (operator_i == brq_pkg_ALU_CRC32C_B);
				assign crc_poly = (crc_cpoly ? CRC32C_POLYNOMIAL : CRC32_POLYNOMIAL);
				assign crc_mu_rev = (crc_cpoly ? CRC32C_MU_REV : CRC32_MU_REV);
				always @(*)
					case (1'b1)
						crc_bmode: crc_operand = {operand_a_i[7:0], 24'h000000};
						crc_hmode: crc_operand = {operand_a_i[15:0], 16'h0000};
						default: crc_operand = operand_a_i;
					endcase
				always @(*)
					if (crc_op) begin
						clmul_op_a = (instr_first_cycle_i ? crc_operand : imd_val_q_i[32+:32]);
						clmul_op_b = (instr_first_cycle_i ? crc_mu_rev : crc_poly);
					end
					else begin
						clmul_op_a = (clmul_rmode | clmul_hmode ? operand_a_rev : operand_a_i);
						clmul_op_b = (clmul_rmode | clmul_hmode ? operand_b_rev : operand_b_i);
					end
				for (i = 0; i < 32; i = i + 1) begin : gen_clmul_and_op
					assign clmul_and_stage[i] = (clmul_op_b[i] ? clmul_op_a << i : {32 {1'sb0}});
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_clmul_xor_op_l1
					assign clmul_xor_stage1[i] = clmul_and_stage[2 * i] ^ clmul_and_stage[(2 * i) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_clmul_xor_op_l2
					assign clmul_xor_stage2[i] = clmul_xor_stage1[2 * i] ^ clmul_xor_stage1[(2 * i) + 1];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_clmul_xor_op_l3
					assign clmul_xor_stage3[i] = clmul_xor_stage2[2 * i] ^ clmul_xor_stage2[(2 * i) + 1];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_clmul_xor_op_l4
					assign clmul_xor_stage4[i] = clmul_xor_stage3[2 * i] ^ clmul_xor_stage3[(2 * i) + 1];
				end
				assign clmul_result_raw = clmul_xor_stage4[0] ^ clmul_xor_stage4[1];
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_clmul_result
					assign clmul_result_rev[i] = clmul_result_raw[31 - i];
				end
				always @(*)
					case (1'b1)
						clmul_rmode: clmul_result = clmul_result_rev;
						clmul_hmode: clmul_result = {1'b0, clmul_result_rev[31:1]};
						default: clmul_result = clmul_result_raw;
					endcase
			end
			else begin : gen_alu_rvb_notfull
				wire [31:0] unused_imd_val_q_1;
				assign unused_imd_val_q_1 = imd_val_q_i[0+:32];
				wire [32:1] sv2v_tmp_8C42B;
				assign sv2v_tmp_8C42B = {32 {1'sb0}};
				always @(*) shuffle_result = sv2v_tmp_8C42B;
				wire [32:1] sv2v_tmp_B0AD4;
				assign sv2v_tmp_B0AD4 = {32 {1'sb0}};
				always @(*) butterfly_result = sv2v_tmp_B0AD4;
				wire [32:1] sv2v_tmp_AFC2C;
				assign sv2v_tmp_AFC2C = {32 {1'sb0}};
				always @(*) invbutterfly_result = sv2v_tmp_AFC2C;
				wire [32:1] sv2v_tmp_3A741;
				assign sv2v_tmp_3A741 = {32 {1'sb0}};
				always @(*) clmul_result = sv2v_tmp_3A741;
				assign bitcnt_partial_lsb_d = {32 {1'sb0}};
				assign bitcnt_partial_msb_d = {32 {1'sb0}};
				assign clmul_result_rev = {32 {1'sb0}};
				assign crc_bmode = 1'b0;
				assign crc_hmode = 1'b0;
			end
			always @(*)
				case (operator_i)
					brq_pkg_ALU_CMOV: begin
						multicycle_result = (operand_b_i == 32'h00000000 ? operand_a_i : imd_val_q_i[32+:32]);
						imd_val_d_o = {operand_a_i, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					brq_pkg_ALU_CMIX: begin
						multicycle_result = imd_val_q_i[32+:32] | bwlogic_and_result;
						imd_val_d_o = {bwlogic_and_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					brq_pkg_ALU_FSR, brq_pkg_ALU_FSL, brq_pkg_ALU_ROL, brq_pkg_ALU_ROR: begin
						if (shift_amt[4:0] == 5'h00)
							multicycle_result = (shift_amt[5] ? operand_a_i : imd_val_q_i[32+:32]);
						else
							multicycle_result = imd_val_q_i[32+:32] | shift_result;
						imd_val_d_o = {shift_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					brq_pkg_ALU_CRC32_W, brq_pkg_ALU_CRC32C_W, brq_pkg_ALU_CRC32_H, brq_pkg_ALU_CRC32C_H, brq_pkg_ALU_CRC32_B, brq_pkg_ALU_CRC32C_B:
						if (RV32B == brq_pkg_RV32BFull) begin
							case (1'b1)
								crc_bmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 8);
								crc_hmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 16);
								default: multicycle_result = clmul_result_rev;
							endcase
							imd_val_d_o = {clmul_result_rev, 32'h00000000};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b01;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					brq_pkg_ALU_BEXT, brq_pkg_ALU_BDEP:
						if (RV32B == brq_pkg_RV32BFull) begin
							multicycle_result = (operator_i == brq_pkg_ALU_BDEP ? butterfly_result : invbutterfly_result);
							imd_val_d_o = {bitcnt_partial_lsb_d, bitcnt_partial_msb_d};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b11;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					default: begin
						imd_val_d_o = {operand_a_i, 32'h00000000};
						imd_val_we_o = 2'b00;
						multicycle_result = {32 {1'sb0}};
					end
				endcase
		end
		else begin : g_no_alu_rvb
			wire [63:0] unused_imd_val_q;
			assign unused_imd_val_q = imd_val_q_i;
			wire [31:0] unused_butterfly_result;
			assign unused_butterfly_result = butterfly_result;
			wire [31:0] unused_invbutterfly_result;
			assign unused_invbutterfly_result = invbutterfly_result;
			assign bitcnt_result = {6 {1'sb0}};
			assign minmax_result = {32 {1'sb0}};
			wire [32:1] sv2v_tmp_68181;
			assign sv2v_tmp_68181 = {32 {1'sb0}};
			always @(*) pack_result = sv2v_tmp_68181;
			assign sext_result = {32 {1'sb0}};
			wire [32:1] sv2v_tmp_D756E;
			assign sv2v_tmp_D756E = {32 {1'sb0}};
			always @(*) singlebit_result = sv2v_tmp_D756E;
			wire [32:1] sv2v_tmp_BAAB3;
			assign sv2v_tmp_BAAB3 = {32 {1'sb0}};
			always @(*) rev_result = sv2v_tmp_BAAB3;
			wire [32:1] sv2v_tmp_8C42B;
			assign sv2v_tmp_8C42B = {32 {1'sb0}};
			always @(*) shuffle_result = sv2v_tmp_8C42B;
			wire [32:1] sv2v_tmp_B0AD4;
			assign sv2v_tmp_B0AD4 = {32 {1'sb0}};
			always @(*) butterfly_result = sv2v_tmp_B0AD4;
			wire [32:1] sv2v_tmp_AFC2C;
			assign sv2v_tmp_AFC2C = {32 {1'sb0}};
			always @(*) invbutterfly_result = sv2v_tmp_AFC2C;
			wire [32:1] sv2v_tmp_3A741;
			assign sv2v_tmp_3A741 = {32 {1'sb0}};
			always @(*) clmul_result = sv2v_tmp_3A741;
			wire [32:1] sv2v_tmp_172E8;
			assign sv2v_tmp_172E8 = {32 {1'sb0}};
			always @(*) multicycle_result = sv2v_tmp_172E8;
			wire [64:1] sv2v_tmp_CAB3F;
			assign sv2v_tmp_CAB3F = {2 {32'b00000000000000000000000000000000}};
			always @(*) imd_val_d_o = sv2v_tmp_CAB3F;
			wire [2:1] sv2v_tmp_B65CC;
			assign sv2v_tmp_B65CC = {2 {1'b0}};
			always @(*) imd_val_we_o = sv2v_tmp_B65CC;
		end
	endgenerate
	localparam [5:0] brq_pkg_ALU_ADD = 0;
	localparam [5:0] brq_pkg_ALU_CLMUL = 50;
	localparam [5:0] brq_pkg_ALU_GREV = 15;
	localparam [5:0] brq_pkg_ALU_PACK = 29;
	localparam [5:0] brq_pkg_ALU_PCNT = 36;
	localparam [5:0] brq_pkg_ALU_SBEXT = 46;
	localparam [5:0] brq_pkg_ALU_SEXTH = 33;
	localparam [5:0] brq_pkg_ALU_SHFL = 17;
	localparam [5:0] brq_pkg_ALU_SRL = 9;
	localparam [5:0] brq_pkg_ALU_XOR = 2;
	always @(*) begin
		result_o = {32 {1'sb0}};
		case (operator_i)
			brq_pkg_ALU_XOR, brq_pkg_ALU_XNOR, brq_pkg_ALU_OR, brq_pkg_ALU_ORN, brq_pkg_ALU_AND, brq_pkg_ALU_ANDN: result_o = bwlogic_result;
			brq_pkg_ALU_ADD, brq_pkg_ALU_SUB: result_o = adder_result;
			brq_pkg_ALU_SLL, brq_pkg_ALU_SRL, brq_pkg_ALU_SRA, brq_pkg_ALU_SLO, brq_pkg_ALU_SRO: result_o = shift_result;
			brq_pkg_ALU_SHFL, brq_pkg_ALU_UNSHFL: result_o = shuffle_result;
			brq_pkg_ALU_EQ, brq_pkg_ALU_NE, brq_pkg_ALU_GE, brq_pkg_ALU_GEU, brq_pkg_ALU_LT, brq_pkg_ALU_LTU, brq_pkg_ALU_SLT, brq_pkg_ALU_SLTU: result_o = {31'h00000000, cmp_result};
			brq_pkg_ALU_MIN, brq_pkg_ALU_MAX, brq_pkg_ALU_MINU, brq_pkg_ALU_MAXU: result_o = minmax_result;
			brq_pkg_ALU_CLZ, brq_pkg_ALU_CTZ, brq_pkg_ALU_PCNT: result_o = {26'h0000000, bitcnt_result};
			brq_pkg_ALU_PACK, brq_pkg_ALU_PACKH, brq_pkg_ALU_PACKU: result_o = pack_result;
			brq_pkg_ALU_SEXTB, brq_pkg_ALU_SEXTH: result_o = sext_result;
			brq_pkg_ALU_CMIX, brq_pkg_ALU_CMOV, brq_pkg_ALU_FSL, brq_pkg_ALU_FSR, brq_pkg_ALU_ROL, brq_pkg_ALU_ROR, brq_pkg_ALU_CRC32_W, brq_pkg_ALU_CRC32C_W, brq_pkg_ALU_CRC32_H, brq_pkg_ALU_CRC32C_H, brq_pkg_ALU_CRC32_B, brq_pkg_ALU_CRC32C_B, brq_pkg_ALU_BEXT, brq_pkg_ALU_BDEP: result_o = multicycle_result;
			brq_pkg_ALU_SBSET, brq_pkg_ALU_SBCLR, brq_pkg_ALU_SBINV, brq_pkg_ALU_SBEXT: result_o = singlebit_result;
			brq_pkg_ALU_GREV, brq_pkg_ALU_GORC: result_o = rev_result;
			brq_pkg_ALU_BFP: result_o = bfp_result;
			brq_pkg_ALU_CLMUL, brq_pkg_ALU_CLMULR, brq_pkg_ALU_CLMULH: result_o = clmul_result;
			default:
				;
		endcase
	end
	wire unused_shift_amt_compl;
	assign unused_shift_amt_compl = shift_amt_compl[5];
endmodule
module brq_exu_multdiv_fast (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero_i,
	data_ind_timing_i,
	alu_operand_a_o,
	alu_operand_b_o,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	multdiv_ready_id_i,
	multdiv_result_o,
	valid_o
);
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero_i;
	input wire data_ind_timing_i;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	input wire [67:0] imd_val_q_i;
	output wire [67:0] imd_val_d_o;
	output wire [1:0] imd_val_we_o;
	input wire multdiv_ready_id_i;
	output wire [31:0] multdiv_result_o;
	output wire valid_o;
	wire signed [34:0] mac_res_signed;
	wire [34:0] mac_res_ext;
	reg [33:0] accum;
	reg sign_a;
	reg sign_b;
	reg mult_valid;
	wire signed_mult;
	reg [33:0] mac_res_d;
	reg [33:0] op_remainder_d;
	wire [33:0] mac_res;
	wire div_sign_a;
	wire div_sign_b;
	reg is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	wire [31:0] one_shift;
	wire [31:0] op_denominator_q;
	reg [31:0] op_numerator_q;
	reg [31:0] op_quotient_q;
	reg [31:0] op_denominator_d;
	reg [31:0] op_numerator_d;
	reg [31:0] op_quotient_d;
	wire [31:0] next_remainder;
	wire [32:0] next_quotient;
	wire [31:0] res_adder_h;
	reg div_valid;
	reg [4:0] div_counter_q;
	reg [4:0] div_counter_d;
	wire multdiv_en;
	reg mult_hold;
	reg div_hold;
	reg div_by_zero_d;
	reg div_by_zero_q;
	wire mult_en_internal;
	wire div_en_internal;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	wire unused_mult_sel_i;
	assign unused_mult_sel_i = mult_sel_i;
	assign mult_en_internal = mult_en_i & ~mult_hold;
	assign div_en_internal = div_en_i & ~div_hold;
	localparam [2:0] MD_IDLE = 0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			div_counter_q <= {5 {1'sb0}};
			md_state_q <= MD_IDLE;
			op_numerator_q <= {32 {1'sb0}};
			op_quotient_q <= {32 {1'sb0}};
			div_by_zero_q <= 1'b0;
		end
		else if (div_en_internal) begin
			div_counter_q <= div_counter_d;
			op_numerator_q <= op_numerator_d;
			op_quotient_q <= op_quotient_d;
			md_state_q <= md_state_d;
			div_by_zero_q <= div_by_zero_d;
		end
	assign multdiv_en = mult_en_internal | div_en_internal;
	assign imd_val_d_o[34+:34] = (div_sel_i ? op_remainder_d : mac_res_d);
	assign imd_val_we_o[0] = multdiv_en;
	assign imd_val_d_o[0+:34] = {2'b00, op_denominator_d};
	assign imd_val_we_o[1] = div_en_internal;
	assign op_denominator_q = imd_val_q_i[31-:32];
	wire [1:0] unused_imd_val;
	assign unused_imd_val = imd_val_q_i[33-:2];
	wire unused_mac_res_ext;
	assign unused_mac_res_ext = mac_res_ext[34];
	assign signed_mult = signed_mode_i != 2'b00;
	assign multdiv_result_o = (div_sel_i ? imd_val_q_i[65-:32] : mac_res_d[31:0]);
	localparam [1:0] AHBH = 3;
	localparam [1:0] AHBL = 2;
	localparam [1:0] ALBH = 1;
	localparam [1:0] ALBL = 0;
	localparam [0:0] MULH = 1;
	localparam [0:0] MULL = 0;
	localparam [1:0] brq_pkg_MD_OP_MULL = 0;
	localparam integer brq_pkg_RV32MSingleCycle = 3;
	generate
		if (RV32M == brq_pkg_RV32MSingleCycle) begin : gen_mult_single_cycle
			reg mult_state_q;
			reg mult_state_d;
			wire signed [33:0] mult1_res;
			wire signed [33:0] mult2_res;
			wire signed [33:0] mult3_res;
			wire [33:0] mult1_res_uns;
			wire [33:32] unused_mult1_res_uns;
			wire [15:0] mult1_op_a;
			wire [15:0] mult1_op_b;
			wire [15:0] mult2_op_a;
			wire [15:0] mult2_op_b;
			reg [15:0] mult3_op_a;
			reg [15:0] mult3_op_b;
			wire mult1_sign_a;
			wire mult1_sign_b;
			wire mult2_sign_a;
			wire mult2_sign_b;
			reg mult3_sign_a;
			reg mult3_sign_b;
			reg [33:0] summand1;
			reg [33:0] summand2;
			reg [33:0] summand3;
			assign mult1_res = $signed({mult1_sign_a, mult1_op_a}) * $signed({mult1_sign_b, mult1_op_b});
			assign mult2_res = $signed({mult2_sign_a, mult2_op_a}) * $signed({mult2_sign_b, mult2_op_b});
			assign mult3_res = $signed({mult3_sign_a, mult3_op_a}) * $signed({mult3_sign_b, mult3_op_b});
			assign mac_res_signed = ($signed(summand1) + $signed(summand2)) + $signed(summand3);
			assign mult1_res_uns = $unsigned(mult1_res);
			assign mac_res_ext = $unsigned(mac_res_signed);
			assign mac_res = mac_res_ext[33:0];
			wire [1:1] sv2v_tmp_1E8D3;
			assign sv2v_tmp_1E8D3 = signed_mode_i[0] & op_a_i[31];
			always @(*) sign_a = sv2v_tmp_1E8D3;
			wire [1:1] sv2v_tmp_3B65C;
			assign sv2v_tmp_3B65C = signed_mode_i[1] & op_b_i[31];
			always @(*) sign_b = sv2v_tmp_3B65C;
			assign mult1_sign_a = 1'b0;
			assign mult1_sign_b = 1'b0;
			assign mult1_op_a = op_a_i[15:0];
			assign mult1_op_b = op_b_i[15:0];
			assign mult2_sign_a = 1'b0;
			assign mult2_sign_b = sign_b;
			assign mult2_op_a = op_a_i[15:0];
			assign mult2_op_b = op_b_i[31:16];
			wire [18:1] sv2v_tmp_4D45D;
			assign sv2v_tmp_4D45D = imd_val_q_i[67-:18];
			always @(*) accum[17:0] = sv2v_tmp_4D45D;
			wire [16:1] sv2v_tmp_D5F47;
			assign sv2v_tmp_D5F47 = {16 {signed_mult & imd_val_q_i[67]}};
			always @(*) accum[33:18] = sv2v_tmp_D5F47;
			always @(*) begin
				mult3_sign_a = sign_a;
				mult3_sign_b = 1'b0;
				mult3_op_a = op_a_i[31:16];
				mult3_op_b = op_b_i[15:0];
				summand1 = {18'h00000, mult1_res_uns[31:16]};
				summand2 = $unsigned(mult2_res);
				summand3 = $unsigned(mult3_res);
				mac_res_d = {2'b00, mac_res[15:0], mult1_res_uns[15:0]};
				mult_valid = mult_en_i;
				mult_state_d = MULL;
				mult_hold = 1'b0;
				case (mult_state_q)
					MULL:
						if (operator_i != brq_pkg_MD_OP_MULL) begin
							mac_res_d = mac_res;
							mult_valid = 1'b0;
							mult_state_d = MULH;
						end
						else
							mult_hold = ~multdiv_ready_id_i;
					MULH: begin
						mult3_sign_a = sign_a;
						mult3_sign_b = sign_b;
						mult3_op_a = op_a_i[31:16];
						mult3_op_b = op_b_i[31:16];
						mac_res_d = mac_res;
						summand1 = {34 {1'sb0}};
						summand2 = accum;
						summand3 = mult3_res;
						mult_state_d = MULL;
						mult_valid = 1'b1;
						mult_hold = ~multdiv_ready_id_i;
					end
					default: mult_state_d = MULL;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mult_state_q <= MULL;
				else if (mult_en_internal)
					mult_state_q <= mult_state_d;
			assign unused_mult1_res_uns = mult1_res_uns[33:32];
		end
		else begin : gen_mult_fast
			reg [15:0] mult_op_a;
			reg [15:0] mult_op_b;
			reg [1:0] mult_state_q;
			reg [1:0] mult_state_d;
			assign mac_res_signed = ($signed({sign_a, mult_op_a}) * $signed({sign_b, mult_op_b})) + $signed(accum);
			assign mac_res_ext = $unsigned(mac_res_signed);
			assign mac_res = mac_res_ext[33:0];
			always @(*) begin
				mult_op_a = op_a_i[15:0];
				mult_op_b = op_b_i[15:0];
				sign_a = 1'b0;
				sign_b = 1'b0;
				accum = imd_val_q_i[34+:34];
				mac_res_d = mac_res;
				mult_state_d = mult_state_q;
				mult_valid = 1'b0;
				mult_hold = 1'b0;
				case (mult_state_q)
					ALBL: begin
						mult_op_a = op_a_i[15:0];
						mult_op_b = op_b_i[15:0];
						sign_a = 1'b0;
						sign_b = 1'b0;
						accum = {34 {1'sb0}};
						mac_res_d = mac_res;
						mult_state_d = ALBH;
					end
					ALBH: begin
						mult_op_a = op_a_i[15:0];
						mult_op_b = op_b_i[31:16];
						sign_a = 1'b0;
						sign_b = signed_mode_i[1] & op_b_i[31];
						accum = {18'b000000000000000000, imd_val_q_i[65-:16]};
						if (operator_i == brq_pkg_MD_OP_MULL)
							mac_res_d = {2'b00, mac_res[15:0], imd_val_q_i[49-:16]};
						else
							mac_res_d = mac_res;
						mult_state_d = AHBL;
					end
					AHBL: begin
						mult_op_a = op_a_i[31:16];
						mult_op_b = op_b_i[15:0];
						sign_a = signed_mode_i[0] & op_a_i[31];
						sign_b = 1'b0;
						if (operator_i == brq_pkg_MD_OP_MULL) begin
							accum = {18'b000000000000000000, imd_val_q_i[65-:16]};
							mac_res_d = {2'b00, mac_res[15:0], imd_val_q_i[49-:16]};
							mult_valid = 1'b1;
							mult_state_d = ALBL;
							mult_hold = ~multdiv_ready_id_i;
						end
						else begin
							accum = imd_val_q_i[34+:34];
							mac_res_d = mac_res;
							mult_state_d = AHBH;
						end
					end
					AHBH: begin
						mult_op_a = op_a_i[31:16];
						mult_op_b = op_b_i[31:16];
						sign_a = signed_mode_i[0] & op_a_i[31];
						sign_b = signed_mode_i[1] & op_b_i[31];
						accum[17:0] = imd_val_q_i[67-:18];
						accum[33:18] = {16 {signed_mult & imd_val_q_i[67]}};
						mac_res_d = mac_res;
						mult_valid = 1'b1;
						mult_state_d = ALBL;
						mult_hold = ~multdiv_ready_id_i;
					end
					default: mult_state_d = ALBL;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mult_state_q <= ALBL;
				else if (mult_en_internal)
					mult_state_q <= mult_state_d;
		end
	endgenerate
	assign res_adder_h = alu_adder_ext_i[32:1];
	wire [1:0] unused_alu_adder_ext;
	assign unused_alu_adder_ext = {alu_adder_ext_i[33], alu_adder_ext_i[0]};
	assign next_remainder = (is_greater_equal ? res_adder_h[31:0] : imd_val_q_i[65-:32]);
	assign next_quotient = (is_greater_equal ? {1'b0, op_quotient_q} | {1'b0, one_shift} : {1'b0, op_quotient_q});
	assign one_shift = 32'b00000000000000000000000000000001 << div_counter_q;
	always @(*)
		if ((imd_val_q_i[65] ^ op_denominator_q[31]) == 1'b0)
			is_greater_equal = res_adder_h[31] == 1'b0;
		else
			is_greater_equal = imd_val_q_i[65];
	assign div_sign_a = op_a_i[31] & signed_mode_i[0];
	assign div_sign_b = op_b_i[31] & signed_mode_i[1];
	assign div_change_sign = (div_sign_a ^ div_sign_b) & ~div_by_zero_q;
	assign rem_change_sign = div_sign_a;
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_FINISH = 6;
	localparam [2:0] MD_LAST = 4;
	localparam [1:0] brq_pkg_MD_OP_DIV = 2;
	always @(*) begin
		div_counter_d = div_counter_q - 5'h01;
		op_remainder_d = imd_val_q_i[34+:34];
		op_quotient_d = op_quotient_q;
		md_state_d = md_state_q;
		op_numerator_d = op_numerator_q;
		op_denominator_d = op_denominator_q;
		alu_operand_a_o = 33'b000000000000000000000000000000001;
		alu_operand_b_o = {~op_b_i, 1'b1};
		div_valid = 1'b0;
		div_hold = 1'b0;
		div_by_zero_d = div_by_zero_q;
		case (md_state_q)
			MD_IDLE: begin
				if (operator_i == brq_pkg_MD_OP_DIV) begin
					op_remainder_d = {34 {1'sb1}};
					md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
					div_by_zero_d = equal_to_zero_i;
				end
				else begin
					op_remainder_d = {2'b00, op_a_i};
					md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
				end
				alu_operand_a_o = 33'b000000000000000000000000000000001;
				alu_operand_b_o = {~op_b_i, 1'b1};
				div_counter_d = 5'd31;
			end
			MD_ABS_A: begin
				op_quotient_d = {32 {1'sb0}};
				op_numerator_d = (div_sign_a ? alu_adder_i : op_a_i);
				md_state_d = MD_ABS_B;
				div_counter_d = 5'd31;
				alu_operand_a_o = 33'b000000000000000000000000000000001;
				alu_operand_b_o = {~op_a_i, 1'b1};
			end
			MD_ABS_B: begin
				op_remainder_d = {33'h000000000, op_numerator_q[31]};
				op_denominator_d = (div_sign_b ? alu_adder_i : op_b_i);
				md_state_d = MD_COMP;
				div_counter_d = 5'd31;
				alu_operand_a_o = 33'b000000000000000000000000000000001;
				alu_operand_b_o = {~op_b_i, 1'b1};
			end
			MD_COMP: begin
				op_remainder_d = {1'b0, next_remainder[31:0], op_numerator_q[div_counter_d]};
				op_quotient_d = next_quotient[31:0];
				md_state_d = (div_counter_q == 5'd1 ? MD_LAST : MD_COMP);
				alu_operand_a_o = {imd_val_q_i[65-:32], 1'b1};
				alu_operand_b_o = {~op_denominator_q[31:0], 1'b1};
			end
			MD_LAST: begin
				if (operator_i == brq_pkg_MD_OP_DIV)
					op_remainder_d = {1'b0, next_quotient};
				else
					op_remainder_d = {2'b00, next_remainder[31:0]};
				alu_operand_a_o = {imd_val_q_i[65-:32], 1'b1};
				alu_operand_b_o = {~op_denominator_q[31:0], 1'b1};
				md_state_d = MD_CHANGE_SIGN;
			end
			MD_CHANGE_SIGN: begin
				md_state_d = MD_FINISH;
				if (operator_i == brq_pkg_MD_OP_DIV)
					op_remainder_d = (div_change_sign ? {2'h0, alu_adder_i} : imd_val_q_i[34+:34]);
				else
					op_remainder_d = (rem_change_sign ? {2'h0, alu_adder_i} : imd_val_q_i[34+:34]);
				alu_operand_a_o = 33'b000000000000000000000000000000001;
				alu_operand_b_o = {~imd_val_q_i[65-:32], 1'b1};
			end
			MD_FINISH: begin
				md_state_d = MD_IDLE;
				div_hold = ~multdiv_ready_id_i;
				div_valid = 1'b1;
			end
			default: md_state_d = MD_IDLE;
		endcase
	end
	assign valid_o = mult_valid | div_valid;
endmodule
module brq_exu_multdiv_slow (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero_i,
	data_ind_timing_i,
	alu_operand_a_o,
	alu_operand_b_o,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	multdiv_ready_id_i,
	multdiv_result_o,
	valid_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero_i;
	input wire data_ind_timing_i;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	input wire [67:0] imd_val_q_i;
	output wire [67:0] imd_val_d_o;
	output wire [1:0] imd_val_we_o;
	input wire multdiv_ready_id_i;
	output wire [31:0] multdiv_result_o;
	output wire valid_o;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	wire [32:0] accum_window_q;
	reg [32:0] accum_window_d;
	wire unused_imd_val0;
	wire [1:0] unused_imd_val1;
	wire [32:0] res_adder_l;
	wire [32:0] res_adder_h;
	reg [4:0] multdiv_count_q;
	reg [4:0] multdiv_count_d;
	reg [32:0] op_b_shift_q;
	reg [32:0] op_b_shift_d;
	reg [32:0] op_a_shift_q;
	reg [32:0] op_a_shift_d;
	wire [32:0] op_a_ext;
	wire [32:0] op_b_ext;
	wire [32:0] one_shift;
	wire [32:0] op_a_bw_pp;
	wire [32:0] op_a_bw_last_pp;
	wire [31:0] b_0;
	wire sign_a;
	wire sign_b;
	wire [32:0] next_quotient;
	wire [31:0] next_remainder;
	wire [31:0] op_numerator_q;
	reg [31:0] op_numerator_d;
	wire is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	reg div_by_zero_d;
	reg div_by_zero_q;
	reg multdiv_hold;
	wire multdiv_en;
	assign res_adder_l = alu_adder_ext_i[32:0];
	assign res_adder_h = alu_adder_ext_i[33:1];
	assign imd_val_d_o[34+:34] = {1'b0, accum_window_d};
	assign imd_val_we_o[0] = ~multdiv_hold;
	assign accum_window_q = imd_val_q_i[66-:33];
	assign unused_imd_val0 = imd_val_q_i[67];
	assign imd_val_d_o[0+:34] = {2'b00, op_numerator_d};
	assign imd_val_we_o[1] = multdiv_en;
	assign op_numerator_q = imd_val_q_i[31-:32];
	assign unused_imd_val1 = imd_val_q_i[33-:2];
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_IDLE = 0;
	localparam [2:0] MD_LAST = 4;
	localparam [1:0] brq_pkg_MD_OP_DIV = 2;
	localparam [1:0] brq_pkg_MD_OP_MULH = 1;
	localparam [1:0] brq_pkg_MD_OP_MULL = 0;
	localparam [1:0] brq_pkg_MD_OP_REM = 3;
	always @(*) begin
		alu_operand_a_o = accum_window_q;
		case (operator_i)
			brq_pkg_MD_OP_MULL: alu_operand_b_o = op_a_bw_pp;
			brq_pkg_MD_OP_MULH: alu_operand_b_o = (md_state_q == MD_LAST ? op_a_bw_last_pp : op_a_bw_pp);
			brq_pkg_MD_OP_DIV, brq_pkg_MD_OP_REM:
				case (md_state_q)
					MD_IDLE: begin
						alu_operand_a_o = 33'b000000000000000000000000000000001;
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_ABS_A: begin
						alu_operand_a_o = 33'b000000000000000000000000000000001;
						alu_operand_b_o = {~op_a_i, 1'b1};
					end
					MD_ABS_B: begin
						alu_operand_a_o = 33'b000000000000000000000000000000001;
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_CHANGE_SIGN: begin
						alu_operand_a_o = 33'b000000000000000000000000000000001;
						alu_operand_b_o = {~accum_window_q[31:0], 1'b1};
					end
					default: begin
						alu_operand_a_o = {accum_window_q[31:0], 1'b1};
						alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
					end
				endcase
		endcase
	end
	assign b_0 = {32 {op_b_shift_q[0]}};
	assign op_a_bw_pp = {~(op_a_shift_q[32] & op_b_shift_q[0]), op_a_shift_q[31:0] & b_0};
	assign op_a_bw_last_pp = {op_a_shift_q[32] & op_b_shift_q[0], ~(op_a_shift_q[31:0] & b_0)};
	assign sign_a = op_a_i[31] & signed_mode_i[0];
	assign sign_b = op_b_i[31] & signed_mode_i[1];
	assign op_a_ext = {sign_a, op_a_i};
	assign op_b_ext = {sign_b, op_b_i};
	assign is_greater_equal = (accum_window_q[31] == op_b_shift_q[31] ? ~res_adder_h[31] : accum_window_q[31]);
	assign one_shift = 33'b000000000000000000000000000000001 << multdiv_count_q;
	assign next_remainder = (is_greater_equal ? res_adder_h[31:0] : accum_window_q[31:0]);
	assign next_quotient = (is_greater_equal ? op_a_shift_q | one_shift : op_a_shift_q);
	assign div_change_sign = (sign_a ^ sign_b) & ~div_by_zero_q;
	assign rem_change_sign = sign_a;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_FINISH = 6;
	always @(*) begin
		multdiv_count_d = multdiv_count_q;
		accum_window_d = accum_window_q;
		op_b_shift_d = op_b_shift_q;
		op_a_shift_d = op_a_shift_q;
		op_numerator_d = op_numerator_q;
		md_state_d = md_state_q;
		multdiv_hold = 1'b0;
		div_by_zero_d = div_by_zero_q;
		if (mult_sel_i || div_sel_i)
			case (md_state_q)
				MD_IDLE: begin
					case (operator_i)
						brq_pkg_MD_OP_MULL: begin
							op_a_shift_d = op_a_ext << 1;
							accum_window_d = {~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:0] & {32 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = (!data_ind_timing_i && ((op_b_ext >> 1) == 0) ? MD_LAST : MD_COMP);
						end
						brq_pkg_MD_OP_MULH: begin
							op_a_shift_d = op_a_ext;
							accum_window_d = {1'b1, ~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:1] & {31 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = MD_COMP;
						end
						brq_pkg_MD_OP_DIV: begin
							accum_window_d = {33 {1'b1}};
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
							div_by_zero_d = equal_to_zero_i;
						end
						brq_pkg_MD_OP_REM: begin
							accum_window_d = op_a_ext;
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
						end
					endcase
					multdiv_count_d = 5'd31;
				end
				MD_ABS_A: begin
					op_a_shift_d = {33 {1'sb0}};
					op_numerator_d = (sign_a ? alu_adder_i : op_a_i);
					md_state_d = MD_ABS_B;
				end
				MD_ABS_B: begin
					accum_window_d = {32'h00000000, op_numerator_q[31]};
					op_b_shift_d = (sign_b ? {1'b0, alu_adder_i} : {1'b0, op_b_i});
					md_state_d = MD_COMP;
				end
				MD_COMP: begin
					multdiv_count_d = multdiv_count_q - 5'h01;
					case (operator_i)
						brq_pkg_MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							op_a_shift_d = op_a_shift_q << 1;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = ((!data_ind_timing_i && (op_b_shift_d == 0)) || (multdiv_count_q == 5'd1) ? MD_LAST : MD_COMP);
						end
						brq_pkg_MD_OP_MULH: begin
							accum_window_d = res_adder_h;
							op_a_shift_d = op_a_shift_q;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
						brq_pkg_MD_OP_DIV, brq_pkg_MD_OP_REM: begin
							accum_window_d = {next_remainder[31:0], op_numerator_q[multdiv_count_d]};
							op_a_shift_d = next_quotient;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
					endcase
				end
				MD_LAST:
					case (operator_i)
						brq_pkg_MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						brq_pkg_MD_OP_MULH: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						brq_pkg_MD_OP_DIV: begin
							accum_window_d = next_quotient;
							md_state_d = MD_CHANGE_SIGN;
						end
						brq_pkg_MD_OP_REM: begin
							accum_window_d = {1'b0, next_remainder[31:0]};
							md_state_d = MD_CHANGE_SIGN;
						end
					endcase
				MD_CHANGE_SIGN: begin
					md_state_d = MD_FINISH;
					case (operator_i)
						brq_pkg_MD_OP_DIV: accum_window_d = (div_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						brq_pkg_MD_OP_REM: accum_window_d = (rem_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						default:
							;
					endcase
				end
				MD_FINISH: begin
					md_state_d = MD_IDLE;
					multdiv_hold = ~multdiv_ready_id_i;
				end
				default: md_state_d = MD_IDLE;
			endcase
	end
	assign multdiv_en = (mult_en_i | div_en_i) & ~multdiv_hold;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			multdiv_count_q <= 5'h00;
			op_b_shift_q <= 33'h000000000;
			op_a_shift_q <= 33'h000000000;
			md_state_q <= MD_IDLE;
			div_by_zero_q <= 1'b0;
		end
		else if (multdiv_en) begin
			multdiv_count_q <= multdiv_count_d;
			op_b_shift_q <= op_b_shift_d;
			op_a_shift_q <= op_a_shift_d;
			md_state_q <= md_state_d;
			div_by_zero_q <= div_by_zero_d;
		end
	assign valid_o = (md_state_q == MD_FINISH) | ((md_state_q == MD_LAST) & ((operator_i == brq_pkg_MD_OP_MULL) | (operator_i == brq_pkg_MD_OP_MULH)));
	assign multdiv_result_o = (div_en_i ? accum_window_q[31:0] : res_adder_l[31:0]);
endmodule
module brq_exu (
	clk_i,
	rst_ni,
	alu_operator_i,
	alu_operand_a_i,
	alu_operand_b_i,
	alu_instr_first_cycle_i,
	bt_a_operand_i,
	bt_b_operand_i,
	multdiv_operator_i,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	multdiv_signed_mode_i,
	multdiv_operand_a_i,
	multdiv_operand_b_i,
	multdiv_ready_id_i,
	data_ind_timing_i,
	imd_val_we_o,
	imd_val_d_o,
	imd_val_q_i,
	alu_adder_result_ex_o,
	result_ex_o,
	branch_target_o,
	branch_decision_o,
	ex_valid_o
);
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	parameter [0:0] BranchTargetALU = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire [5:0] alu_operator_i;
	input wire [31:0] alu_operand_a_i;
	input wire [31:0] alu_operand_b_i;
	input wire alu_instr_first_cycle_i;
	input wire [31:0] bt_a_operand_i;
	input wire [31:0] bt_b_operand_i;
	input wire [1:0] multdiv_operator_i;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] multdiv_signed_mode_i;
	input wire [31:0] multdiv_operand_a_i;
	input wire [31:0] multdiv_operand_b_i;
	input wire multdiv_ready_id_i;
	input wire data_ind_timing_i;
	output wire [1:0] imd_val_we_o;
	output wire [67:0] imd_val_d_o;
	input wire [67:0] imd_val_q_i;
	output wire [31:0] alu_adder_result_ex_o;
	output wire [31:0] result_ex_o;
	output wire [31:0] branch_target_o;
	output wire branch_decision_o;
	output wire ex_valid_o;
	wire [31:0] alu_result;
	wire [31:0] multdiv_result;
	wire [32:0] multdiv_alu_operand_b;
	wire [32:0] multdiv_alu_operand_a;
	wire [33:0] alu_adder_result_ext;
	wire alu_cmp_result;
	wire alu_is_equal_result;
	wire multdiv_valid;
	wire multdiv_sel;
	wire [63:0] alu_imd_val_q;
	wire [63:0] alu_imd_val_d;
	wire [1:0] alu_imd_val_we;
	wire [67:0] multdiv_imd_val_d;
	wire [1:0] multdiv_imd_val_we;
	localparam integer brq_pkg_RV32MNone = 0;
	generate
		if (RV32M != brq_pkg_RV32MNone) begin : gen_multdiv_m
			assign multdiv_sel = mult_sel_i | div_sel_i;
		end
		else begin : gen_multdiv_no_m
			assign multdiv_sel = 1'b0;
		end
	endgenerate
	assign imd_val_d_o[34+:34] = (multdiv_sel ? multdiv_imd_val_d[34+:34] : {2'b00, alu_imd_val_d[32+:32]});
	assign imd_val_d_o[0+:34] = (multdiv_sel ? multdiv_imd_val_d[0+:34] : {2'b00, alu_imd_val_d[0+:32]});
	assign imd_val_we_o = (multdiv_sel ? multdiv_imd_val_we : alu_imd_val_we);
	assign alu_imd_val_q = {imd_val_q_i[65-:32], imd_val_q_i[31-:32]};
	assign result_ex_o = (multdiv_sel ? multdiv_result : alu_result);
	assign branch_decision_o = alu_cmp_result;
	generate
		if (BranchTargetALU) begin : g_branch_target_alu
			wire [32:0] bt_alu_result;
			wire unused_bt_carry;
			assign bt_alu_result = bt_a_operand_i + bt_b_operand_i;
			assign unused_bt_carry = bt_alu_result[32];
			assign branch_target_o = bt_alu_result[31:0];
		end
		else begin : g_no_branch_target_alu
			wire [31:0] unused_bt_a_operand;
			wire [31:0] unused_bt_b_operand;
			assign unused_bt_a_operand = bt_a_operand_i;
			assign unused_bt_b_operand = bt_b_operand_i;
			assign branch_target_o = alu_adder_result_ex_o;
		end
	endgenerate
	brq_exu_alu #(.RV32B(RV32B)) alu_i(
		.operator_i(alu_operator_i),
		.operand_a_i(alu_operand_a_i),
		.operand_b_i(alu_operand_b_i),
		.instr_first_cycle_i(alu_instr_first_cycle_i),
		.imd_val_q_i(alu_imd_val_q),
		.imd_val_we_o(alu_imd_val_we),
		.imd_val_d_o(alu_imd_val_d),
		.multdiv_operand_a_i(multdiv_alu_operand_a),
		.multdiv_operand_b_i(multdiv_alu_operand_b),
		.multdiv_sel_i(multdiv_sel),
		.adder_result_o(alu_adder_result_ex_o),
		.adder_result_ext_o(alu_adder_result_ext),
		.result_o(alu_result),
		.comparison_result_o(alu_cmp_result),
		.is_equal_result_o(alu_is_equal_result)
	);
	localparam integer brq_pkg_RV32MSingleCycle = 3;
	localparam integer brq_pkg_RV32MSlow = 1;
	generate
		if (RV32M == brq_pkg_RV32MSlow) begin : gen_multdiv_slow
			brq_exu_multdiv_slow multdiv_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.mult_en_i(mult_en_i),
				.div_en_i(div_en_i),
				.mult_sel_i(mult_sel_i),
				.div_sel_i(div_sel_i),
				.operator_i(multdiv_operator_i),
				.signed_mode_i(multdiv_signed_mode_i),
				.op_a_i(multdiv_operand_a_i),
				.op_b_i(multdiv_operand_b_i),
				.alu_adder_ext_i(alu_adder_result_ext),
				.alu_adder_i(alu_adder_result_ex_o),
				.equal_to_zero_i(alu_is_equal_result),
				.data_ind_timing_i(data_ind_timing_i),
				.valid_o(multdiv_valid),
				.alu_operand_a_o(multdiv_alu_operand_a),
				.alu_operand_b_o(multdiv_alu_operand_b),
				.imd_val_q_i(imd_val_q_i),
				.imd_val_d_o(multdiv_imd_val_d),
				.imd_val_we_o(multdiv_imd_val_we),
				.multdiv_ready_id_i(multdiv_ready_id_i),
				.multdiv_result_o(multdiv_result)
			);
		end
		else if ((RV32M == brq_pkg_RV32MFast) || (RV32M == brq_pkg_RV32MSingleCycle)) begin : gen_multdiv_fast
			brq_exu_multdiv_fast #(.RV32M(RV32M)) multdiv_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.mult_en_i(mult_en_i),
				.div_en_i(div_en_i),
				.mult_sel_i(mult_sel_i),
				.div_sel_i(div_sel_i),
				.operator_i(multdiv_operator_i),
				.signed_mode_i(multdiv_signed_mode_i),
				.op_a_i(multdiv_operand_a_i),
				.op_b_i(multdiv_operand_b_i),
				.alu_operand_a_o(multdiv_alu_operand_a),
				.alu_operand_b_o(multdiv_alu_operand_b),
				.alu_adder_ext_i(alu_adder_result_ext),
				.alu_adder_i(alu_adder_result_ex_o),
				.equal_to_zero_i(alu_is_equal_result),
				.data_ind_timing_i(data_ind_timing_i),
				.imd_val_q_i(imd_val_q_i),
				.imd_val_d_o(multdiv_imd_val_d),
				.imd_val_we_o(multdiv_imd_val_we),
				.multdiv_ready_id_i(multdiv_ready_id_i),
				.valid_o(multdiv_valid),
				.multdiv_result_o(multdiv_result)
			);
		end
	endgenerate
	assign ex_valid_o = (multdiv_sel ? multdiv_valid : ~(|alu_imd_val_we));
endmodule
module brq_fp_register_file_ff (
	clk_i,
	rst_ni,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	raddr_c_i,
	rdata_c_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i
);
	localparam integer brq_pkg_RV32FSingle = 1;
	parameter integer RVF = brq_pkg_RV32FSingle;
	parameter [31:0] DataWidth = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire [4:0] raddr_a_i;
	output wire [DataWidth - 1:0] rdata_a_o;
	input wire [4:0] raddr_b_i;
	output wire [DataWidth - 1:0] rdata_b_o;
	input wire [4:0] raddr_c_i;
	output wire [DataWidth - 1:0] rdata_c_o;
	input wire [4:0] waddr_a_i;
	input wire [DataWidth - 1:0] wdata_a_i;
	input wire we_a_i;
	localparam integer brq_pkg_RV64FDouble = 2;
	localparam [31:0] ADDR_WIDTH = (RVF == brq_pkg_RV64FDouble ? 6 : 5);
	localparam [31:0] NUM_WORDS = (RVF == brq_pkg_RV64FDouble ? 64 : 32);
	wire [(NUM_WORDS * DataWidth) - 1:0] rf_reg;
	reg [(NUM_WORDS * DataWidth) - 1:0] rf_reg_q;
	reg [NUM_WORDS - 1:0] we_a_dec;
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	always @(*) begin : we_a_decoder
		begin : sv2v_autoblock_99
			reg [31:0] i;
			for (i = 0; i < NUM_WORDS; i = i + 1)
				we_a_dec[i] = (waddr_a_i == sv2v_cast_5(i) ? we_a_i : 1'b0);
		end
	end
	generate
		genvar i;
		for (i = 0; i < NUM_WORDS; i = i + 1) begin : g_rf_flops
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rf_reg_q[i * DataWidth+:DataWidth] <= {DataWidth {1'sb0}};
				else if (we_a_dec[i])
					rf_reg_q[i * DataWidth+:DataWidth] <= wdata_a_i;
		end
	endgenerate
	assign rf_reg[DataWidth * ((NUM_WORDS - 1) - (NUM_WORDS - 1))+:DataWidth * NUM_WORDS] = rf_reg_q[DataWidth * ((NUM_WORDS - 1) - (NUM_WORDS - 1))+:DataWidth * NUM_WORDS];
	assign rdata_a_o = rf_reg[raddr_a_i * DataWidth+:DataWidth];
	assign rdata_b_o = rf_reg[raddr_b_i * DataWidth+:DataWidth];
	assign rdata_c_o = rf_reg[raddr_c_i * DataWidth+:DataWidth];
endmodule
module brq_idu_controller (
	clk_i,
	rst_ni,
	ctrl_busy_o,
	illegal_insn_i,
	ecall_insn_i,
	mret_insn_i,
	dret_insn_i,
	wfi_insn_i,
	ebrk_insn_i,
	csr_pipe_flush_i,
	instr_valid_i,
	instr_i,
	instr_compressed_i,
	instr_is_compressed_i,
	instr_fetch_err_i,
	instr_fetch_err_plus2_i,
	pc_id_i,
	instr_valid_clear_o,
	id_in_ready_o,
	controller_run_o,
	instr_req_o,
	pc_set_o,
	pc_set_spec_o,
	pc_mux_o,
	exc_pc_mux_o,
	exc_cause_o,
	lsu_addr_last_i,
	load_err_i,
	store_err_i,
	wb_exception_o,
	branch_set_i,
	branch_set_spec_i,
	jump_set_i,
	csr_mstatus_mie_i,
	irq_pending_i,
	irqs_i,
	irq_nm_i,
	nmi_mode_o,
	debug_req_i,
	debug_cause_o,
	debug_csr_save_o,
	debug_mode_o,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	trigger_match_i,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_wb_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	stall_id_i,
	stall_wb_i,
	flush_id_o,
	ready_wb_i,
	perf_jump_o,
	perf_tbranch_o,
	fpu_busy_i
);
	parameter [0:0] WritebackStage = 0;
	parameter [0:0] BranchPredictor = 0;
	input wire clk_i;
	input wire rst_ni;
	output reg ctrl_busy_o;
	input wire illegal_insn_i;
	input wire ecall_insn_i;
	input wire mret_insn_i;
	input wire dret_insn_i;
	input wire wfi_insn_i;
	input wire ebrk_insn_i;
	input wire csr_pipe_flush_i;
	input wire instr_valid_i;
	input wire [31:0] instr_i;
	input wire [15:0] instr_compressed_i;
	input wire instr_is_compressed_i;
	input wire instr_fetch_err_i;
	input wire instr_fetch_err_plus2_i;
	input wire [31:0] pc_id_i;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output reg controller_run_o;
	output reg instr_req_o;
	output reg pc_set_o;
	output reg pc_set_spec_o;
	output reg [2:0] pc_mux_o;
	output reg [1:0] exc_pc_mux_o;
	output reg [5:0] exc_cause_o;
	input wire [31:0] lsu_addr_last_i;
	input wire load_err_i;
	input wire store_err_i;
	output wire wb_exception_o;
	input wire branch_set_i;
	input wire branch_set_spec_i;
	input wire jump_set_i;
	input wire csr_mstatus_mie_i;
	input wire irq_pending_i;
	input wire [17:0] irqs_i;
	input wire irq_nm_i;
	output wire nmi_mode_o;
	input wire debug_req_i;
	output reg [2:0] debug_cause_o;
	output reg debug_csr_save_o;
	output wire debug_mode_o;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire trigger_match_i;
	output reg csr_save_if_o;
	output reg csr_save_id_o;
	output reg csr_save_wb_o;
	output reg csr_restore_mret_id_o;
	output reg csr_restore_dret_id_o;
	output reg csr_save_cause_o;
	output reg [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire stall_id_i;
	input wire stall_wb_i;
	output wire flush_id_o;
	input wire ready_wb_i;
	output reg perf_jump_o;
	output reg perf_tbranch_o;
	input wire fpu_busy_i;
	wire instr_bp_taken_i;
	assign instr_bp_taken_i = 1'b0;
	reg [3:0] ctrl_fsm_cs;
	reg [3:0] ctrl_fsm_ns;
	reg nmi_mode_q;
	reg nmi_mode_d;
	reg debug_mode_q;
	reg debug_mode_d;
	reg load_err_q;
	wire load_err_d;
	reg store_err_q;
	wire store_err_d;
	reg exc_req_q;
	wire exc_req_d;
	reg illegal_insn_q;
	wire illegal_insn_d;
	reg instr_fetch_err_prio;
	reg illegal_insn_prio;
	reg ecall_insn_prio;
	reg ebrk_insn_prio;
	reg store_err_prio;
	reg load_err_prio;
	wire stall;
	reg halt_if;
	reg retain_id;
	reg flush_id;
	wire illegal_dret;
	wire illegal_umode;
	wire exc_req_lsu;
	wire special_req_all;
	wire special_req_branch;
	wire enter_debug_mode;
	wire ebreak_into_debug;
	wire handle_irq;
	reg [3:0] mfip_id;
	wire unused_irq_timer;
	wire ecall_insn;
	wire mret_insn;
	wire dret_insn;
	wire wfi_insn;
	wire ebrk_insn;
	wire csr_pipe_flush;
	wire instr_fetch_err;
	assign load_err_d = load_err_i;
	assign store_err_d = store_err_i;
	assign ecall_insn = ecall_insn_i & instr_valid_i;
	assign mret_insn = mret_insn_i & instr_valid_i;
	assign dret_insn = dret_insn_i & instr_valid_i;
	assign wfi_insn = wfi_insn_i & instr_valid_i;
	assign ebrk_insn = ebrk_insn_i & instr_valid_i;
	assign csr_pipe_flush = csr_pipe_flush_i & instr_valid_i;
	assign instr_fetch_err = instr_fetch_err_i & instr_valid_i;
	assign illegal_dret = dret_insn & ~debug_mode_q;
	localparam [1:0] brq_pkg_PRIV_LVL_M = 2'b11;
	assign illegal_umode = (priv_mode_i != brq_pkg_PRIV_LVL_M) & (mret_insn | (csr_mstatus_tw_i & wfi_insn));
	localparam [3:0] FLUSH = 6;
	assign illegal_insn_d = ((illegal_insn_i | illegal_dret) | illegal_umode) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_d = (((ecall_insn | ebrk_insn) | illegal_insn_d) | instr_fetch_err) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_lsu = store_err_i | load_err_i;
	assign special_req_all = ((((mret_insn | dret_insn) | wfi_insn) | csr_pipe_flush) | exc_req_d) | exc_req_lsu;
	assign special_req_branch = instr_fetch_err & (ctrl_fsm_cs != FLUSH);
	generate
		if (WritebackStage) begin : g_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
				else if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
			end
			assign wb_exception_o = ((load_err_q | store_err_q) | load_err_i) | store_err_i;
		end
		else begin : g_no_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
				else if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
			end
			assign wb_exception_o = 1'b0;
		end
	endgenerate
	assign enter_debug_mode = ((debug_req_i | (debug_single_step_i & instr_valid_i)) | trigger_match_i) & ~debug_mode_q;
	localparam [1:0] brq_pkg_PRIV_LVL_U = 2'b00;
	assign ebreak_into_debug = (priv_mode_i == brq_pkg_PRIV_LVL_M ? debug_ebreakm_i : (priv_mode_i == brq_pkg_PRIV_LVL_U ? debug_ebreaku_i : 1'b0));
	assign handle_irq = (~debug_mode_q & ~nmi_mode_q) & (irq_nm_i | (irq_pending_i & csr_mstatus_mie_i));
	always @(*) begin : gen_mfip_id
		if (irqs_i[14])
			mfip_id = 4'd14;
		else if (irqs_i[13])
			mfip_id = 4'd13;
		else if (irqs_i[12])
			mfip_id = 4'd12;
		else if (irqs_i[11])
			mfip_id = 4'd11;
		else if (irqs_i[10])
			mfip_id = 4'd10;
		else if (irqs_i[9])
			mfip_id = 4'd9;
		else if (irqs_i[8])
			mfip_id = 4'd8;
		else if (irqs_i[7])
			mfip_id = 4'd7;
		else if (irqs_i[6])
			mfip_id = 4'd6;
		else if (irqs_i[5])
			mfip_id = 4'd5;
		else if (irqs_i[4])
			mfip_id = 4'd4;
		else if (irqs_i[3])
			mfip_id = 4'd3;
		else if (irqs_i[2])
			mfip_id = 4'd2;
		else if (irqs_i[1])
			mfip_id = 4'd1;
		else
			mfip_id = 4'd0;
	end
	assign unused_irq_timer = irqs_i[16];
	localparam [3:0] BOOT_SET = 1;
	localparam [3:0] DBG_TAKEN_ID = 9;
	localparam [3:0] DBG_TAKEN_IF = 8;
	localparam [3:0] DECODE = 5;
	localparam [3:0] FIRST_FETCH = 4;
	localparam [3:0] IRQ_TAKEN = 7;
	localparam [3:0] RESET = 0;
	localparam [3:0] SLEEP = 3;
	localparam [3:0] WAIT_SLEEP = 2;
	localparam [2:0] brq_pkg_DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] brq_pkg_DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] brq_pkg_DBG_CAUSE_STEP = 3'h4;
	localparam [2:0] brq_pkg_DBG_CAUSE_TRIGGER = 3'h2;
	localparam [5:0] brq_pkg_EXC_CAUSE_BREAKPOINT = 6'b000011;
	localparam [5:0] brq_pkg_EXC_CAUSE_ECALL_MMODE = 6'b001011;
	localparam [5:0] brq_pkg_EXC_CAUSE_ECALL_UMODE = 6'b001000;
	localparam [5:0] brq_pkg_EXC_CAUSE_ILLEGAL_INSN = 6'b000010;
	localparam [5:0] brq_pkg_EXC_CAUSE_INSN_ADDR_MISA = 6'b000000;
	localparam [5:0] brq_pkg_EXC_CAUSE_INSTR_ACCESS_FAULT = 6'b000001;
	localparam [5:0] brq_pkg_EXC_CAUSE_IRQ_EXTERNAL_M = 6'b101011;
	localparam [5:0] brq_pkg_EXC_CAUSE_IRQ_NM = 6'b111111;
	localparam [5:0] brq_pkg_EXC_CAUSE_IRQ_SOFTWARE_M = 6'b100011;
	localparam [5:0] brq_pkg_EXC_CAUSE_IRQ_TIMER_M = 6'b100111;
	localparam [5:0] brq_pkg_EXC_CAUSE_LOAD_ACCESS_FAULT = 6'b000101;
	localparam [5:0] brq_pkg_EXC_CAUSE_STORE_ACCESS_FAULT = 6'b000111;
	localparam [1:0] brq_pkg_EXC_PC_DBD = 2;
	localparam [1:0] brq_pkg_EXC_PC_DBG_EXC = 3;
	localparam [1:0] brq_pkg_EXC_PC_EXC = 0;
	localparam [1:0] brq_pkg_EXC_PC_IRQ = 1;
	localparam [2:0] brq_pkg_PC_BOOT = 0;
	localparam [2:0] brq_pkg_PC_DRET = 4;
	localparam [2:0] brq_pkg_PC_ERET = 3;
	localparam [2:0] brq_pkg_PC_EXC = 2;
	localparam [2:0] brq_pkg_PC_JUMP = 1;
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	always @(*) begin
		instr_req_o = 1'b1;
		csr_save_if_o = 1'b0;
		csr_save_id_o = 1'b0;
		csr_save_wb_o = 1'b0;
		csr_restore_mret_id_o = 1'b0;
		csr_restore_dret_id_o = 1'b0;
		csr_save_cause_o = 1'b0;
		csr_mtval_o = {32 {1'sb0}};
		pc_mux_o = brq_pkg_PC_BOOT;
		pc_set_o = 1'b0;
		pc_set_spec_o = 1'b0;
		exc_pc_mux_o = brq_pkg_EXC_PC_IRQ;
		exc_cause_o = brq_pkg_EXC_CAUSE_INSN_ADDR_MISA;
		ctrl_fsm_ns = ctrl_fsm_cs;
		ctrl_busy_o = 1'b1;
		halt_if = 1'b0;
		retain_id = 1'b0;
		flush_id = 1'b0;
		debug_csr_save_o = 1'b0;
		debug_cause_o = brq_pkg_DBG_CAUSE_EBREAK;
		debug_mode_d = debug_mode_q;
		nmi_mode_d = nmi_mode_q;
		perf_tbranch_o = 1'b0;
		perf_jump_o = 1'b0;
		controller_run_o = 1'b0;
		case (ctrl_fsm_cs)
			RESET: begin
				instr_req_o = 1'b0;
				pc_mux_o = brq_pkg_PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = BOOT_SET;
			end
			BOOT_SET: begin
				instr_req_o = 1'b1;
				pc_mux_o = brq_pkg_PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = FIRST_FETCH;
			end
			WAIT_SLEEP: begin
				ctrl_busy_o = 1'b0;
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = SLEEP;
			end
			SLEEP: begin
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				if ((((irq_nm_i || irq_pending_i) || debug_req_i) || debug_mode_q) || debug_single_step_i)
					ctrl_fsm_ns = FIRST_FETCH;
				else
					ctrl_busy_o = 1'b0;
			end
			FIRST_FETCH: begin
				if (id_in_ready_o)
					ctrl_fsm_ns = DECODE;
				if (handle_irq) begin
					ctrl_fsm_ns = IRQ_TAKEN;
					halt_if = 1'b1;
				end
				if (enter_debug_mode) begin
					ctrl_fsm_ns = DBG_TAKEN_IF;
					halt_if = 1'b1;
				end
			end
			DECODE: begin
				controller_run_o = 1'b1;
				pc_mux_o = brq_pkg_PC_JUMP;
				if (special_req_all) begin
					retain_id = 1'b1;
					if (ready_wb_i | wb_exception_o)
						ctrl_fsm_ns = FLUSH;
				end
				if (!special_req_branch)
					if (branch_set_i || jump_set_i) begin
						pc_set_o = (BranchPredictor ? ~instr_bp_taken_i : 1'b1);
						perf_tbranch_o = branch_set_i;
						perf_jump_o = jump_set_i;
					end
				if ((branch_set_spec_i || jump_set_i) && !special_req_branch)
					pc_set_spec_o = 1'b1;
				if ((enter_debug_mode || handle_irq) && stall)
					halt_if = 1'b1;
				if (!stall && !special_req_all)
					if (enter_debug_mode) begin
						ctrl_fsm_ns = DBG_TAKEN_IF;
						halt_if = 1'b1;
					end
					else if (handle_irq) begin
						ctrl_fsm_ns = IRQ_TAKEN;
						halt_if = 1'b1;
					end
			end
			IRQ_TAKEN: begin
				pc_mux_o = brq_pkg_PC_EXC;
				exc_pc_mux_o = brq_pkg_EXC_PC_IRQ;
				if (handle_irq) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_save_if_o = 1'b1;
					csr_save_cause_o = 1'b1;
					if (irq_nm_i && !nmi_mode_q) begin
						exc_cause_o = brq_pkg_EXC_CAUSE_IRQ_NM;
						nmi_mode_d = 1'b1;
					end
					else if (irqs_i[14-:15] != 15'b000000000000000)
						exc_cause_o = sv2v_cast_6({2'b11, mfip_id});
					else if (irqs_i[15])
						exc_cause_o = brq_pkg_EXC_CAUSE_IRQ_EXTERNAL_M;
					else if (irqs_i[17])
						exc_cause_o = brq_pkg_EXC_CAUSE_IRQ_SOFTWARE_M;
					else if (irqs_i[16])
						exc_cause_o = brq_pkg_EXC_CAUSE_IRQ_TIMER_M;
				end
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_IF: begin
				pc_mux_o = brq_pkg_PC_EXC;
				exc_pc_mux_o = brq_pkg_EXC_PC_DBD;
				if ((debug_single_step_i || debug_req_i) || trigger_match_i) begin
					flush_id = 1'b1;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_save_if_o = 1'b1;
					debug_csr_save_o = 1'b1;
					csr_save_cause_o = 1'b1;
					if (trigger_match_i)
						debug_cause_o = brq_pkg_DBG_CAUSE_TRIGGER;
					else if (debug_single_step_i)
						debug_cause_o = brq_pkg_DBG_CAUSE_STEP;
					else
						debug_cause_o = brq_pkg_DBG_CAUSE_HALTREQ;
					debug_mode_d = 1'b1;
				end
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_ID: begin
				flush_id = 1'b1;
				pc_mux_o = brq_pkg_PC_EXC;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				exc_pc_mux_o = brq_pkg_EXC_PC_DBD;
				if (ebreak_into_debug && !debug_mode_q) begin
					csr_save_cause_o = 1'b1;
					csr_save_id_o = 1'b1;
					debug_csr_save_o = 1'b1;
					debug_cause_o = brq_pkg_DBG_CAUSE_EBREAK;
				end
				debug_mode_d = 1'b1;
				ctrl_fsm_ns = DECODE;
			end
			FLUSH: begin
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = DECODE;
				if ((exc_req_q || store_err_q) || load_err_q) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					pc_mux_o = brq_pkg_PC_EXC;
					exc_pc_mux_o = (debug_mode_q ? brq_pkg_EXC_PC_DBG_EXC : brq_pkg_EXC_PC_EXC);
					if (WritebackStage) begin : g_writeback_mepc_save
						csr_save_id_o = ~(store_err_q | load_err_q);
						csr_save_wb_o = store_err_q | load_err_q;
					end
					else begin : g_no_writeback_mepc_save
						csr_save_id_o = 1'b0;
					end
					csr_save_cause_o = 1'b1;
					case (1'b1)
						instr_fetch_err_prio: begin
							exc_cause_o = brq_pkg_EXC_CAUSE_INSTR_ACCESS_FAULT;
							csr_mtval_o = (instr_fetch_err_plus2_i ? pc_id_i + 32'd2 : pc_id_i);
						end
						illegal_insn_prio: begin
							exc_cause_o = brq_pkg_EXC_CAUSE_ILLEGAL_INSN;
							csr_mtval_o = (instr_is_compressed_i ? {16'b0000000000000000, instr_compressed_i} : instr_i);
						end
						ecall_insn_prio: exc_cause_o = (priv_mode_i == brq_pkg_PRIV_LVL_M ? brq_pkg_EXC_CAUSE_ECALL_MMODE : brq_pkg_EXC_CAUSE_ECALL_UMODE);
						ebrk_insn_prio:
							if (debug_mode_q | ebreak_into_debug) begin
								pc_set_o = 1'b0;
								pc_set_spec_o = 1'b0;
								csr_save_id_o = 1'b0;
								csr_save_cause_o = 1'b0;
								ctrl_fsm_ns = DBG_TAKEN_ID;
								flush_id = 1'b0;
							end
							else
								exc_cause_o = brq_pkg_EXC_CAUSE_BREAKPOINT;
						store_err_prio: begin
							exc_cause_o = brq_pkg_EXC_CAUSE_STORE_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						load_err_prio: begin
							exc_cause_o = brq_pkg_EXC_CAUSE_LOAD_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						default:
							;
					endcase
				end
				else if (mret_insn) begin
					pc_mux_o = brq_pkg_PC_ERET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_restore_mret_id_o = 1'b1;
					if (nmi_mode_q)
						nmi_mode_d = 1'b0;
				end
				else if (dret_insn) begin
					pc_mux_o = brq_pkg_PC_DRET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					debug_mode_d = 1'b0;
					csr_restore_dret_id_o = 1'b1;
				end
				else if (wfi_insn)
					ctrl_fsm_ns = WAIT_SLEEP;
				else if (csr_pipe_flush && handle_irq)
					ctrl_fsm_ns = IRQ_TAKEN;
				if (enter_debug_mode && !(ebrk_insn_prio && ebreak_into_debug))
					ctrl_fsm_ns = DBG_TAKEN_IF;
			end
			default: begin
				instr_req_o = 1'b0;
				ctrl_fsm_ns = RESET;
			end
		endcase
	end
	assign flush_id_o = flush_id;
	assign debug_mode_o = debug_mode_q;
	assign nmi_mode_o = nmi_mode_q;
	assign stall = (stall_id_i | stall_wb_i) | fpu_busy_i;
	assign id_in_ready_o = (~stall & ~halt_if) & ~retain_id;
	assign instr_valid_clear_o = ~(stall | retain_id) | flush_id;
	always @(posedge clk_i or negedge rst_ni) begin : update_regs
		if (!rst_ni) begin
			ctrl_fsm_cs <= RESET;
			nmi_mode_q <= 1'b0;
			debug_mode_q <= 1'b0;
			load_err_q <= 1'b0;
			store_err_q <= 1'b0;
			exc_req_q <= 1'b0;
			illegal_insn_q <= 1'b0;
		end
		else begin
			ctrl_fsm_cs <= ctrl_fsm_ns;
			nmi_mode_q <= nmi_mode_d;
			debug_mode_q <= debug_mode_d;
			load_err_q <= load_err_d;
			store_err_q <= store_err_d;
			exc_req_q <= exc_req_d;
			illegal_insn_q <= illegal_insn_d;
		end
	end
endmodule
module brq_idu_decoder (
	clk_i,
	rst_ni,
	illegal_insn_o,
	ebrk_insn_o,
	mret_insn_o,
	dret_insn_o,
	ecall_insn_o,
	wfi_insn_o,
	jump_set_o,
	branch_taken_i,
	icache_inval_o,
	instr_first_cycle_i,
	instr_rdata_i,
	instr_rdata_alu_i,
	illegal_c_insn_i,
	imm_a_mux_sel_o,
	imm_b_mux_sel_o,
	bt_a_mux_sel_o,
	bt_b_mux_sel_o,
	imm_i_type_o,
	imm_s_type_o,
	imm_b_type_o,
	imm_u_type_o,
	imm_j_type_o,
	zimm_rs1_type_o,
	rf_wdata_sel_o,
	rf_we_o,
	rf_raddr_a_o,
	rf_raddr_b_o,
	rf_waddr_o,
	rf_ren_a_o,
	rf_ren_b_o,
	alu_operator_o,
	alu_op_a_mux_sel_o,
	alu_op_b_mux_sel_o,
	alu_multicycle_o,
	mult_en_o,
	div_en_o,
	mult_sel_o,
	div_sel_o,
	multdiv_operator_o,
	multdiv_signed_mode_o,
	csr_access_o,
	csr_op_o,
	data_req_o,
	data_we_o,
	data_type_o,
	data_sign_extension_o,
	jump_in_dec_o,
	branch_in_dec_o,
	fp_rounding_mode_o,
	fp_rf_raddr_a_o,
	fp_rf_raddr_b_o,
	fp_rf_raddr_c_o,
	fp_rf_waddr_o,
	fp_rf_we_o,
	fp_alu_operator_o,
	fp_alu_op_mod_o,
	fp_rm_dynamic_o,
	fp_src_fmt_o,
	fp_dst_fmt_o,
	is_fp_instr_o,
	use_fp_rs1_o,
	use_fp_rs2_o,
	use_fp_rs3_o,
	use_fp_rd_o,
	fp_swap_oprnds_o,
	fp_load_o,
	mv_instr_o
);
	parameter [0:0] RV32E = 0;
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	localparam integer brq_pkg_RV64FDouble = 2;
	parameter integer RVF = brq_pkg_RV64FDouble;
	parameter [0:0] BranchTargetALU = 0;
	input wire clk_i;
	input wire rst_ni;
	output wire illegal_insn_o;
	output reg ebrk_insn_o;
	output reg mret_insn_o;
	output reg dret_insn_o;
	output reg ecall_insn_o;
	output reg wfi_insn_o;
	output reg jump_set_o;
	input wire branch_taken_i;
	output reg icache_inval_o;
	input wire instr_first_cycle_i;
	input wire [31:0] instr_rdata_i;
	input wire [31:0] instr_rdata_alu_i;
	input wire illegal_c_insn_i;
	output reg imm_a_mux_sel_o;
	output reg [2:0] imm_b_mux_sel_o;
	output reg [1:0] bt_a_mux_sel_o;
	output reg [2:0] bt_b_mux_sel_o;
	output wire [31:0] imm_i_type_o;
	output wire [31:0] imm_s_type_o;
	output wire [31:0] imm_b_type_o;
	output wire [31:0] imm_u_type_o;
	output wire [31:0] imm_j_type_o;
	output wire [31:0] zimm_rs1_type_o;
	output reg rf_wdata_sel_o;
	output wire rf_we_o;
	output wire [4:0] rf_raddr_a_o;
	output wire [4:0] rf_raddr_b_o;
	output wire [4:0] rf_waddr_o;
	output reg rf_ren_a_o;
	output reg rf_ren_b_o;
	output reg [5:0] alu_operator_o;
	output reg [1:0] alu_op_a_mux_sel_o;
	output reg alu_op_b_mux_sel_o;
	output reg alu_multicycle_o;
	output wire mult_en_o;
	output wire div_en_o;
	output reg mult_sel_o;
	output reg div_sel_o;
	output reg [1:0] multdiv_operator_o;
	output reg [1:0] multdiv_signed_mode_o;
	output reg csr_access_o;
	output reg [1:0] csr_op_o;
	output reg data_req_o;
	output reg data_we_o;
	output reg [1:0] data_type_o;
	output reg data_sign_extension_o;
	output reg jump_in_dec_o;
	output reg branch_in_dec_o;
	output wire [2:0] fp_rounding_mode_o;
	output wire [4:0] fp_rf_raddr_a_o;
	output wire [4:0] fp_rf_raddr_b_o;
	output wire [4:0] fp_rf_raddr_c_o;
	output wire [4:0] fp_rf_waddr_o;
	output reg fp_rf_we_o;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	output reg [3:0] fp_alu_operator_o;
	output reg fp_alu_op_mod_o;
	output wire fp_rm_dynamic_o;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	output reg [1:0] fp_src_fmt_o;
	output reg [1:0] fp_dst_fmt_o;
	output reg is_fp_instr_o;
	output reg use_fp_rs1_o;
	output reg use_fp_rs2_o;
	output reg use_fp_rs3_o;
	output reg use_fp_rd_o;
	output reg fp_swap_oprnds_o;
	output reg fp_load_o;
	output reg mv_instr_o;
	wire fp_invalid_rm;
	reg illegal_insn;
	wire illegal_reg_rv32e;
	reg csr_illegal;
	reg rf_we;
	wire [31:0] instr;
	wire [31:0] instr_alu;
	wire [4:0] instr_rs1;
	wire [4:0] instr_rs2;
	wire [4:0] instr_rs3;
	wire [4:0] instr_rd;
	reg use_rs3_d;
	reg use_rs3_q;
	reg [1:0] csr_op;
	reg [6:0] opcode;
	reg [6:0] opcode_alu;
	assign instr = instr_rdata_alu_i;
	assign instr_alu = instr_rdata_alu_i;
	assign imm_i_type_o = {{20 {instr[31]}}, instr[31:20]};
	assign imm_s_type_o = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
	assign imm_b_type_o = {{19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_u_type_o = {instr[31:12], 12'b000000000000};
	assign imm_j_type_o = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	assign zimm_rs1_type_o = {27'b000000000000000000000000000, instr_rs1};
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			use_rs3_q <= 1'b0;
		else
			use_rs3_q <= use_rs3_d;
	assign instr_rs1 = instr[19:15];
	assign instr_rs2 = instr[24:20];
	assign instr_rs3 = instr[31:27];
	assign rf_raddr_a_o = (use_rs3_q & ~instr_first_cycle_i ? instr_rs3 : instr_rs1);
	assign rf_raddr_b_o = instr_rs2;
	assign instr_rd = instr[11:7];
	assign rf_waddr_o = instr_rd;
	assign fp_rf_raddr_a_o = instr_rs1;
	assign fp_rf_raddr_b_o = instr_rs2;
	assign fp_rf_raddr_c_o = instr_rs3;
	assign fp_rf_waddr_o = instr_rd;
	assign fp_rounding_mode_o = instr[14:12];
	assign fp_invalid_rm = (instr[14:12] == 3'b101 ? 1'b1 : (instr[14:12] == 3'b110 ? 1'b1 : 1'b0));
	assign fp_rm_dynamic_o = (instr[14:12] == 3'b111 ? 1'b1 : 1'b0);
	localparam [1:0] brq_pkg_OP_A_REG_A = 0;
	localparam [0:0] brq_pkg_OP_B_REG_B = 0;
	generate
		if (RV32E) begin : gen_rv32e_reg_check_active
			assign illegal_reg_rv32e = ((rf_raddr_a_o[4] & (alu_op_a_mux_sel_o == brq_pkg_OP_A_REG_A)) | (rf_raddr_b_o[4] & (alu_op_b_mux_sel_o == brq_pkg_OP_B_REG_B))) | (rf_waddr_o[4] & rf_we);
		end
		else begin : gen_rv32e_reg_check_inactive
			assign illegal_reg_rv32e = 1'b0;
		end
	endgenerate
	localparam [1:0] brq_pkg_CSR_OP_CLEAR = 3;
	localparam [1:0] brq_pkg_CSR_OP_READ = 0;
	localparam [1:0] brq_pkg_CSR_OP_SET = 2;
	always @(*) begin : csr_operand_check
		csr_op_o = csr_op;
		if (((csr_op == brq_pkg_CSR_OP_SET) || (csr_op == brq_pkg_CSR_OP_CLEAR)) && (instr_rs1 == {5 {1'sb0}}))
			csr_op_o = brq_pkg_CSR_OP_READ;
	end
	localparam [1:0] brq_pkg_CSR_OP_WRITE = 1;
	localparam [1:0] brq_pkg_MD_OP_DIV = 2;
	localparam [1:0] brq_pkg_MD_OP_MULH = 1;
	localparam [1:0] brq_pkg_MD_OP_MULL = 0;
	localparam [1:0] brq_pkg_MD_OP_REM = 3;
	localparam [6:0] brq_pkg_OPCODE_AUIPC = 7'h17;
	localparam [6:0] brq_pkg_OPCODE_BRANCH = 7'h63;
	localparam [6:0] brq_pkg_OPCODE_JAL = 7'h6f;
	localparam [6:0] brq_pkg_OPCODE_JALR = 7'h67;
	localparam [6:0] brq_pkg_OPCODE_LOAD = 7'h03;
	localparam [6:0] brq_pkg_OPCODE_LOAD_FP = 7'h07;
	localparam [6:0] brq_pkg_OPCODE_LUI = 7'h37;
	localparam [6:0] brq_pkg_OPCODE_MADD_FP = 7'h43;
	localparam [6:0] brq_pkg_OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] brq_pkg_OPCODE_MSUB_FP = 7'h47;
	localparam [6:0] brq_pkg_OPCODE_NMADD_FP = 7'h4f;
	localparam [6:0] brq_pkg_OPCODE_NMSUB_FP = 7'h4b;
	localparam [6:0] brq_pkg_OPCODE_OP = 7'h33;
	localparam [6:0] brq_pkg_OPCODE_OP_FP = 7'h53;
	localparam [6:0] brq_pkg_OPCODE_OP_IMM = 7'h13;
	localparam [6:0] brq_pkg_OPCODE_STORE = 7'h23;
	localparam [6:0] brq_pkg_OPCODE_STORE_FP = 7'h27;
	localparam [6:0] brq_pkg_OPCODE_SYSTEM = 7'h73;
	localparam [0:0] brq_pkg_RF_WD_CSR = 1;
	localparam [0:0] brq_pkg_RF_WD_EX = 0;
	localparam integer brq_pkg_RV32BBalanced = 1;
	localparam integer brq_pkg_RV32BFull = 2;
	localparam integer brq_pkg_RV32FNone = 0;
	localparam integer brq_pkg_RV32MNone = 0;
	localparam [1:0] fpnew_pkg_FP32 = 'd0;
	always @(*) begin
		jump_in_dec_o = 1'b0;
		jump_set_o = 1'b0;
		branch_in_dec_o = 1'b0;
		icache_inval_o = 1'b0;
		multdiv_operator_o = brq_pkg_MD_OP_MULL;
		multdiv_signed_mode_o = 2'b00;
		rf_wdata_sel_o = brq_pkg_RF_WD_EX;
		rf_we = 1'b0;
		rf_ren_a_o = 1'b0;
		rf_ren_b_o = 1'b0;
		csr_access_o = 1'b0;
		csr_illegal = 1'b0;
		csr_op = brq_pkg_CSR_OP_READ;
		data_we_o = 1'b0;
		data_type_o = 2'b00;
		data_sign_extension_o = 1'b0;
		data_req_o = 1'b0;
		illegal_insn = 1'b0;
		ebrk_insn_o = 1'b0;
		mret_insn_o = 1'b0;
		dret_insn_o = 1'b0;
		ecall_insn_o = 1'b0;
		wfi_insn_o = 1'b0;
		fp_rf_we_o = 1'b0;
		is_fp_instr_o = 1'b0;
		use_fp_rs1_o = 1'b0;
		use_fp_rs2_o = 1'b0;
		use_fp_rs3_o = 1'b0;
		use_fp_rd_o = 1'b0;
		fp_load_o = 1'b0;
		fp_src_fmt_o = fpnew_pkg_FP32;
		fp_dst_fmt_o = fpnew_pkg_FP32;
		fp_swap_oprnds_o = 1'b0;
		mv_instr_o = 1'b0;
		opcode = instr[6:0];
		case (opcode)
			brq_pkg_OPCODE_JAL: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
			end
			brq_pkg_OPCODE_JALR: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
				if (instr[14:12] != 3'b000)
					illegal_insn = 1'b1;
				rf_ren_a_o = 1'b1;
			end
			brq_pkg_OPCODE_BRANCH: begin
				branch_in_dec_o = 1'b1;
				case (instr[14:12])
					3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: illegal_insn = 1'b0;
					default: illegal_insn = 1'b1;
				endcase
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
			end
			brq_pkg_OPCODE_STORE: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				data_req_o = 1'b1;
				data_we_o = 1'b1;
				if (instr[14])
					illegal_insn = 1'b1;
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: data_type_o = 2'b00;
					default: illegal_insn = 1'b1;
				endcase
			end
			brq_pkg_OPCODE_LOAD: begin
				rf_ren_a_o = 1'b1;
				data_req_o = 1'b1;
				data_type_o = 2'b00;
				data_sign_extension_o = ~instr[14];
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: begin
						data_type_o = 2'b00;
						if (instr[14])
							illegal_insn = 1'b1;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			brq_pkg_OPCODE_LUI: rf_we = 1'b1;
			brq_pkg_OPCODE_AUIPC: rf_we = 1'b1;
			brq_pkg_OPCODE_OP_IMM: begin
				rf_ren_a_o = 1'b1;
				rf_we = 1'b1;
				case (instr[14:12])
					3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: illegal_insn = 1'b0;
					3'b001:
						case (instr[31:27])
							5'b00000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
							5'b00100, 5'b01001, 5'b00101, 5'b01101: illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
							5'b00001:
								if (instr[26] == 1'b0)
									illegal_insn = (RV32B == brq_pkg_RV32BFull ? 1'b0 : 1'b1);
								else
									illegal_insn = 1'b1;
							5'b01100:
								case (instr[26:20])
									7'b0000000, 7'b0000001, 7'b0000010, 7'b0000100, 7'b0000101: illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
									7'b0010000, 7'b0010001, 7'b0010010, 7'b0011000, 7'b0011001, 7'b0011010: illegal_insn = (RV32B == brq_pkg_RV32BFull ? 1'b0 : 1'b1);
									default: illegal_insn = 1'b1;
								endcase
							default: illegal_insn = 1'b1;
						endcase
					3'b101:
						if (instr[26])
							illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
						else
							case (instr[31:27])
								5'b00000, 5'b01000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
								5'b00100, 5'b01100, 5'b01001: illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
								5'b01101:
									if (RV32B == brq_pkg_RV32BFull)
										illegal_insn = 1'b0;
									else
										case (instr[24:20])
											5'b11111, 5'b11000: illegal_insn = (RV32B == brq_pkg_RV32BBalanced ? 1'b0 : 1'b1);
											default: illegal_insn = 1'b1;
										endcase
								5'b00101:
									if (RV32B == brq_pkg_RV32BFull)
										illegal_insn = 1'b0;
									else if (instr[24:20] == 5'b00111)
										illegal_insn = (RV32B == brq_pkg_RV32BBalanced ? 1'b0 : 1'b1);
								5'b00001:
									if (instr[26] == 1'b0)
										illegal_insn = (RV32B == brq_pkg_RV32BFull ? 1'b0 : 1'b1);
									else
										illegal_insn = 1'b1;
								default: illegal_insn = 1'b1;
							endcase
				endcase
			end
			brq_pkg_OPCODE_OP: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				rf_we = 1'b1;
				if ({instr[26], instr[13:12]} == 3'b101)
					illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
				else
					case ({instr[31:25], instr[14:12]})
						10'b0000000000, 10'b0100000000, 10'b0000000010, 10'b0000000011, 10'b0000000100, 10'b0000000110, 10'b0000000111, 10'b0000000001, 10'b0000000101, 10'b0100000101: illegal_insn = 1'b0;
						10'b0100000111, 10'b0100000110, 10'b0100000100, 10'b0010000001, 10'b0010000101, 10'b0110000001, 10'b0110000101, 10'b0000101100, 10'b0000101101, 10'b0000101110, 10'b0000101111, 10'b0000100100, 10'b0100100100, 10'b0000100111, 10'b0100100001, 10'b0010100001, 10'b0110100001, 10'b0100100101, 10'b0100100111: illegal_insn = (RV32B != brq_pkg_RV32BNone ? 1'b0 : 1'b1);
						10'b0100100110, 10'b0000100110, 10'b0110100101, 10'b0010100101, 10'b0000100001, 10'b0000100101, 10'b0000101001, 10'b0000101010, 10'b0000101011: illegal_insn = (RV32B == brq_pkg_RV32BFull ? 1'b0 : 1'b1);
						10'b0000001000: begin
							multdiv_operator_o = brq_pkg_MD_OP_MULL;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001001: begin
							multdiv_operator_o = brq_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001010: begin
							multdiv_operator_o = brq_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b01;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001011: begin
							multdiv_operator_o = brq_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001100: begin
							multdiv_operator_o = brq_pkg_MD_OP_DIV;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001101: begin
							multdiv_operator_o = brq_pkg_MD_OP_DIV;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001110: begin
							multdiv_operator_o = brq_pkg_MD_OP_REM;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						10'b0000001111: begin
							multdiv_operator_o = brq_pkg_MD_OP_REM;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == brq_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						default: illegal_insn = 1'b1;
					endcase
			end
			brq_pkg_OPCODE_MISC_MEM:
				case (instr[14:12])
					3'b000: rf_we = 1'b0;
					3'b001: begin
						jump_in_dec_o = 1'b1;
						rf_we = 1'b0;
						if (instr_first_cycle_i) begin
							jump_set_o = 1'b1;
							icache_inval_o = 1'b1;
						end
					end
					default: illegal_insn = 1'b1;
				endcase
			brq_pkg_OPCODE_SYSTEM:
				if (instr[14:12] == 3'b000) begin
					case (instr[31:20])
						12'h000: ecall_insn_o = 1'b1;
						12'h001: ebrk_insn_o = 1'b1;
						12'h302: mret_insn_o = 1'b1;
						12'h7b2: dret_insn_o = 1'b1;
						12'h105: wfi_insn_o = 1'b1;
						default: illegal_insn = 1'b1;
					endcase
					if ((instr_rs1 != 5'b00000) || (instr_rd != 5'b00000))
						illegal_insn = 1'b1;
				end
				else begin
					csr_access_o = 1'b1;
					rf_wdata_sel_o = brq_pkg_RF_WD_CSR;
					rf_we = 1'b1;
					if (~instr[14])
						rf_ren_a_o = 1'b1;
					case (instr[13:12])
						2'b01: csr_op = brq_pkg_CSR_OP_WRITE;
						2'b10: csr_op = brq_pkg_CSR_OP_SET;
						2'b11: csr_op = brq_pkg_CSR_OP_CLEAR;
						default: csr_illegal = 1'b1;
					endcase
					illegal_insn = csr_illegal;
				end
			brq_pkg_OPCODE_STORE_FP: begin
				data_req_o = 1'b1;
				data_we_o = 1'b1;
				data_type_o = 2'b00;
				use_fp_rs2_o = 1'b1;
				case (instr[14:12])
					3'b011: illegal_insn = (RVF == brq_pkg_RV64FDouble ? 1'b0 : 1'b1);
					3'b010: begin
						illegal_insn = (RVF == brq_pkg_RV32FNone ? 1'b1 : 1'b0);
						fp_src_fmt_o = fpnew_pkg_FP32;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			brq_pkg_OPCODE_LOAD_FP: begin
				data_req_o = 1'b1;
				data_type_o = 2'b00;
				fp_load_o = 1'b1;
				use_fp_rd_o = 1'b1;
				case (instr[14:12])
					3'b011: illegal_insn = (RVF == brq_pkg_RV64FDouble ? 1'b0 : 1'b1);
					3'b010: begin
						illegal_insn = (RVF == brq_pkg_RV32FNone ? 1'b1 : 1'b0);
						fp_src_fmt_o = fpnew_pkg_FP32;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			brq_pkg_OPCODE_MADD_FP, brq_pkg_OPCODE_MSUB_FP, brq_pkg_OPCODE_NMSUB_FP, brq_pkg_OPCODE_NMADD_FP: begin
				fp_rf_we_o = 1'b1;
				fp_src_fmt_o = fpnew_pkg_FP32;
				is_fp_instr_o = 1'b1;
				use_fp_rs1_o = 1'b1;
				use_fp_rs2_o = 1'b1;
				use_fp_rs3_o = 1'b1;
				use_fp_rd_o = 1'b1;
				case (instr[26:25])
					1: illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					0: begin
						illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
						fp_src_fmt_o = fpnew_pkg_FP32;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			brq_pkg_OPCODE_OP_FP: begin
				fp_src_fmt_o = fpnew_pkg_FP32;
				is_fp_instr_o = 1'b1;
				case (instr[31:25])
					7'b0000001, 7'b0000101: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						fp_swap_oprnds_o = 1'b1;
						illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b0001001, 7'b0001101: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b0000000, 7'b0000100: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						fp_swap_oprnds_o = 1'b1;
						illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
						fp_src_fmt_o = fpnew_pkg_FP32;
					end
					7'b0001000, 7'b0001100: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
						fp_src_fmt_o = fpnew_pkg_FP32;
					end
					7'b0101101: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[24:20])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b0101100: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[24:20]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b0010001: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~(instr[14] | &instr[13:12]))
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b0010000: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~(instr[14] | &instr[13:12])) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b0010101: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[14:13])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b0010100: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[14:13]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b0100000: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~(|instr[24:21] | ~instr[20]))
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b1100000: begin
						rf_we = 1'b1;
						use_fp_rs1_o = 1'b1;
						if (~|instr[24:21]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b0100001: begin
						fp_rf_we_o = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[24:20])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b1110000: begin
						rf_we = 1'b1;
						case ({instr[24:20], instr[14:12]})
							8'b00000000: begin
								use_fp_rs1_o = 1'b1;
								illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
								fp_src_fmt_o = fpnew_pkg_FP32;
								mv_instr_o = 1'b1;
							end
							8'b00000001: begin
								use_fp_rs1_o = 1'b1;
								illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
								fp_src_fmt_o = fpnew_pkg_FP32;
							end
							default: illegal_insn = 1'b1;
						endcase
					end
					7'b1010001: begin
						rf_we = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						if (~instr[14] | &instr[13:12])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b1010000: begin
						rf_we = 1'b1;
						use_fp_rs1_o = 1'b1;
						use_fp_rs2_o = 1'b1;
						if (~instr[14] | &instr[13:12]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b1110001: begin
						rf_we = 1'b1;
						use_fp_rs1_o = 1'b1;
						case ({instr[24:20], instr[14:12]})
							8'b00000001: illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
							default: illegal_insn = 1'b1;
						endcase
					end
					7'b1100001: begin
						rf_we = 1'b1;
						use_fp_rs1_o = 1'b1;
						if (~|instr[24:21])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b1101000: begin
						fp_rf_we_o = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[24:21]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					7'b1111001: begin
						rf_we = 1'b1;
						use_fp_rd_o = 1'b1;
						if (~|instr[24:21])
							illegal_insn = ((RVF == brq_pkg_RV64FDouble) & fp_invalid_rm ? 1'b0 : 1'b1);
					end
					7'b1111000: begin
						fp_rf_we_o = 1'b1;
						use_fp_rd_o = 1'b1;
						mv_instr_o = 1'b1;
						if (~(|instr[24:20]) | |instr[14:12]) begin
							illegal_insn = ((RVF == brq_pkg_RV32FNone) & ~fp_invalid_rm ? 1'b1 : 1'b0);
							fp_src_fmt_o = fpnew_pkg_FP32;
						end
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			default: illegal_insn = 1'b1;
		endcase
		if (illegal_c_insn_i)
			illegal_insn = 1'b1;
		if (illegal_insn) begin
			rf_we = 1'b0;
			data_req_o = 1'b0;
			data_we_o = 1'b0;
			jump_in_dec_o = 1'b0;
			jump_set_o = 1'b0;
			branch_in_dec_o = 1'b0;
			csr_access_o = 1'b0;
			fp_rf_we_o = 1'b0;
		end
	end
	localparam [5:0] brq_pkg_ALU_ADD = 0;
	localparam [5:0] brq_pkg_ALU_AND = 4;
	localparam [5:0] brq_pkg_ALU_ANDN = 7;
	localparam [5:0] brq_pkg_ALU_BDEP = 48;
	localparam [5:0] brq_pkg_ALU_BEXT = 47;
	localparam [5:0] brq_pkg_ALU_BFP = 49;
	localparam [5:0] brq_pkg_ALU_CLMUL = 50;
	localparam [5:0] brq_pkg_ALU_CLMULH = 52;
	localparam [5:0] brq_pkg_ALU_CLMULR = 51;
	localparam [5:0] brq_pkg_ALU_CLZ = 34;
	localparam [5:0] brq_pkg_ALU_CMIX = 40;
	localparam [5:0] brq_pkg_ALU_CMOV = 39;
	localparam [5:0] brq_pkg_ALU_CRC32C_B = 54;
	localparam [5:0] brq_pkg_ALU_CRC32C_H = 56;
	localparam [5:0] brq_pkg_ALU_CRC32C_W = 58;
	localparam [5:0] brq_pkg_ALU_CRC32_B = 53;
	localparam [5:0] brq_pkg_ALU_CRC32_H = 55;
	localparam [5:0] brq_pkg_ALU_CRC32_W = 57;
	localparam [5:0] brq_pkg_ALU_CTZ = 35;
	localparam [5:0] brq_pkg_ALU_EQ = 23;
	localparam [5:0] brq_pkg_ALU_FSL = 41;
	localparam [5:0] brq_pkg_ALU_FSR = 42;
	localparam [5:0] brq_pkg_ALU_GE = 21;
	localparam [5:0] brq_pkg_ALU_GEU = 22;
	localparam [5:0] brq_pkg_ALU_GORC = 16;
	localparam [5:0] brq_pkg_ALU_GREV = 15;
	localparam [5:0] brq_pkg_ALU_LT = 19;
	localparam [5:0] brq_pkg_ALU_LTU = 20;
	localparam [5:0] brq_pkg_ALU_MAX = 27;
	localparam [5:0] brq_pkg_ALU_MAXU = 28;
	localparam [5:0] brq_pkg_ALU_MIN = 25;
	localparam [5:0] brq_pkg_ALU_MINU = 26;
	localparam [5:0] brq_pkg_ALU_NE = 24;
	localparam [5:0] brq_pkg_ALU_OR = 3;
	localparam [5:0] brq_pkg_ALU_ORN = 6;
	localparam [5:0] brq_pkg_ALU_PACK = 29;
	localparam [5:0] brq_pkg_ALU_PACKH = 31;
	localparam [5:0] brq_pkg_ALU_PACKU = 30;
	localparam [5:0] brq_pkg_ALU_PCNT = 36;
	localparam [5:0] brq_pkg_ALU_ROL = 14;
	localparam [5:0] brq_pkg_ALU_ROR = 13;
	localparam [5:0] brq_pkg_ALU_SBCLR = 44;
	localparam [5:0] brq_pkg_ALU_SBEXT = 46;
	localparam [5:0] brq_pkg_ALU_SBINV = 45;
	localparam [5:0] brq_pkg_ALU_SBSET = 43;
	localparam [5:0] brq_pkg_ALU_SEXTB = 32;
	localparam [5:0] brq_pkg_ALU_SEXTH = 33;
	localparam [5:0] brq_pkg_ALU_SHFL = 17;
	localparam [5:0] brq_pkg_ALU_SLL = 10;
	localparam [5:0] brq_pkg_ALU_SLO = 12;
	localparam [5:0] brq_pkg_ALU_SLT = 37;
	localparam [5:0] brq_pkg_ALU_SLTU = 38;
	localparam [5:0] brq_pkg_ALU_SRA = 8;
	localparam [5:0] brq_pkg_ALU_SRL = 9;
	localparam [5:0] brq_pkg_ALU_SRO = 11;
	localparam [5:0] brq_pkg_ALU_SUB = 1;
	localparam [5:0] brq_pkg_ALU_UNSHFL = 18;
	localparam [5:0] brq_pkg_ALU_XNOR = 5;
	localparam [5:0] brq_pkg_ALU_XOR = 2;
	localparam [0:0] brq_pkg_IMM_A_Z = 0;
	localparam [0:0] brq_pkg_IMM_A_ZERO = 1;
	localparam [2:0] brq_pkg_IMM_B_B = 2;
	localparam [2:0] brq_pkg_IMM_B_I = 0;
	localparam [2:0] brq_pkg_IMM_B_INCR_PC = 5;
	localparam [2:0] brq_pkg_IMM_B_J = 4;
	localparam [2:0] brq_pkg_IMM_B_S = 1;
	localparam [2:0] brq_pkg_IMM_B_U = 3;
	localparam [1:0] brq_pkg_OP_A_CURRPC = 2;
	localparam [1:0] brq_pkg_OP_A_IMM = 3;
	localparam [0:0] brq_pkg_OP_B_IMM = 1;
	localparam [3:0] fpnew_pkg_ADD = 2;
	localparam [3:0] fpnew_pkg_CLASSIFY = 9;
	localparam [3:0] fpnew_pkg_CMP = 8;
	localparam [3:0] fpnew_pkg_DIV = 4;
	localparam [3:0] fpnew_pkg_F2F = 10;
	localparam [3:0] fpnew_pkg_F2I = 11;
	localparam [3:0] fpnew_pkg_FMADD = 0;
	localparam [3:0] fpnew_pkg_FNMSUB = 1;
	localparam [3:0] fpnew_pkg_I2F = 12;
	localparam [3:0] fpnew_pkg_MINMAX = 7;
	localparam [3:0] fpnew_pkg_MUL = 3;
	localparam [3:0] fpnew_pkg_SGNJ = 6;
	localparam [3:0] fpnew_pkg_SQRT = 5;
	always @(*) begin
		alu_operator_o = brq_pkg_ALU_SLTU;
		alu_op_a_mux_sel_o = brq_pkg_OP_A_IMM;
		alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
		imm_a_mux_sel_o = brq_pkg_IMM_A_ZERO;
		imm_b_mux_sel_o = brq_pkg_IMM_B_I;
		bt_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
		bt_b_mux_sel_o = brq_pkg_IMM_B_I;
		opcode_alu = instr_alu[6:0];
		use_rs3_d = 1'b0;
		alu_multicycle_o = 1'b0;
		mult_sel_o = 1'b0;
		div_sel_o = 1'b0;
		fp_alu_op_mod_o = 1'b0;
		fp_alu_operator_o = fpnew_pkg_FMADD;
		case (opcode_alu)
			brq_pkg_OPCODE_JAL: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					bt_b_mux_sel_o = brq_pkg_IMM_B_J;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_b_mux_sel_o = brq_pkg_IMM_B_J;
					alu_operator_o = brq_pkg_ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_b_mux_sel_o = brq_pkg_IMM_B_INCR_PC;
					alu_operator_o = brq_pkg_ALU_ADD;
				end
			end
			brq_pkg_OPCODE_JALR: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = brq_pkg_OP_A_REG_A;
					bt_b_mux_sel_o = brq_pkg_IMM_B_I;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_b_mux_sel_o = brq_pkg_IMM_B_I;
					alu_operator_o = brq_pkg_ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_b_mux_sel_o = brq_pkg_IMM_B_INCR_PC;
					alu_operator_o = brq_pkg_ALU_ADD;
				end
			end
			brq_pkg_OPCODE_BRANCH: begin
				case (instr_alu[14:12])
					3'b000: alu_operator_o = brq_pkg_ALU_EQ;
					3'b001: alu_operator_o = brq_pkg_ALU_NE;
					3'b100: alu_operator_o = brq_pkg_ALU_LT;
					3'b101: alu_operator_o = brq_pkg_ALU_GE;
					3'b110: alu_operator_o = brq_pkg_ALU_LTU;
					3'b111: alu_operator_o = brq_pkg_ALU_GEU;
					default:
						;
				endcase
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					bt_b_mux_sel_o = (branch_taken_i ? brq_pkg_IMM_B_B : brq_pkg_IMM_B_INCR_PC);
				end
				if (instr_first_cycle_i) begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_REG_B;
				end
				else begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_b_mux_sel_o = (branch_taken_i ? brq_pkg_IMM_B_B : brq_pkg_IMM_B_INCR_PC);
					alu_operator_o = brq_pkg_ALU_ADD;
				end
			end
			brq_pkg_OPCODE_STORE: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_REG_B;
				alu_operator_o = brq_pkg_ALU_ADD;
				if (!instr_alu[14]) begin
					imm_b_mux_sel_o = brq_pkg_IMM_B_S;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				end
			end
			brq_pkg_OPCODE_LOAD: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				alu_operator_o = brq_pkg_ALU_ADD;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				imm_b_mux_sel_o = brq_pkg_IMM_B_I;
			end
			brq_pkg_OPCODE_LUI: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_IMM;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				imm_a_mux_sel_o = brq_pkg_IMM_A_ZERO;
				imm_b_mux_sel_o = brq_pkg_IMM_B_U;
				alu_operator_o = brq_pkg_ALU_ADD;
			end
			brq_pkg_OPCODE_AUIPC: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				imm_b_mux_sel_o = brq_pkg_IMM_B_U;
				alu_operator_o = brq_pkg_ALU_ADD;
			end
			brq_pkg_OPCODE_OP_IMM: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				imm_b_mux_sel_o = brq_pkg_IMM_B_I;
				case (instr_alu[14:12])
					3'b000: alu_operator_o = brq_pkg_ALU_ADD;
					3'b010: alu_operator_o = brq_pkg_ALU_SLT;
					3'b011: alu_operator_o = brq_pkg_ALU_SLTU;
					3'b100: alu_operator_o = brq_pkg_ALU_XOR;
					3'b110: alu_operator_o = brq_pkg_ALU_OR;
					3'b111: alu_operator_o = brq_pkg_ALU_AND;
					3'b001:
						if (RV32B != brq_pkg_RV32BNone)
							case (instr_alu[31:27])
								5'b00000: alu_operator_o = brq_pkg_ALU_SLL;
								5'b00100: alu_operator_o = brq_pkg_ALU_SLO;
								5'b01001: alu_operator_o = brq_pkg_ALU_SBCLR;
								5'b00101: alu_operator_o = brq_pkg_ALU_SBSET;
								5'b01101: alu_operator_o = brq_pkg_ALU_SBINV;
								5'b00001:
									if (instr_alu[26] == 0)
										alu_operator_o = brq_pkg_ALU_SHFL;
								5'b01100:
									case (instr_alu[26:20])
										7'b0000000: alu_operator_o = brq_pkg_ALU_CLZ;
										7'b0000001: alu_operator_o = brq_pkg_ALU_CTZ;
										7'b0000010: alu_operator_o = brq_pkg_ALU_PCNT;
										7'b0000100: alu_operator_o = brq_pkg_ALU_SEXTB;
										7'b0000101: alu_operator_o = brq_pkg_ALU_SEXTH;
										7'b0010000:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0010001:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0010010:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32_W;
												alu_multicycle_o = 1'b1;
											end
										7'b0011000:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32C_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0011001:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32C_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0011010:
											if (RV32B == brq_pkg_RV32BFull) begin
												alu_operator_o = brq_pkg_ALU_CRC32C_W;
												alu_multicycle_o = 1'b1;
											end
										default:
											;
									endcase
								default:
									;
							endcase
						else
							alu_operator_o = brq_pkg_ALU_SLL;
					3'b101:
						if (RV32B != brq_pkg_RV32BNone) begin
							if (instr_alu[26] == 1'b1) begin
								alu_operator_o = brq_pkg_ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							else
								case (instr_alu[31:27])
									5'b00000: alu_operator_o = brq_pkg_ALU_SRL;
									5'b01000: alu_operator_o = brq_pkg_ALU_SRA;
									5'b00100: alu_operator_o = brq_pkg_ALU_SRO;
									5'b01001: alu_operator_o = brq_pkg_ALU_SBEXT;
									5'b01100: begin
										alu_operator_o = brq_pkg_ALU_ROR;
										alu_multicycle_o = 1'b1;
									end
									5'b01101: alu_operator_o = brq_pkg_ALU_GREV;
									5'b00101: alu_operator_o = brq_pkg_ALU_GORC;
									5'b00001:
										if (RV32B == brq_pkg_RV32BFull)
											if (instr_alu[26] == 1'b0)
												alu_operator_o = brq_pkg_ALU_UNSHFL;
									default:
										;
								endcase
						end
						else if (instr_alu[31:27] == 5'b00000)
							alu_operator_o = brq_pkg_ALU_SRL;
						else if (instr_alu[31:27] == 5'b01000)
							alu_operator_o = brq_pkg_ALU_SRA;
				endcase
			end
			brq_pkg_OPCODE_OP: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_REG_B;
				if (instr_alu[26]) begin
					if (RV32B != brq_pkg_RV32BNone)
						case ({instr_alu[26:25], instr_alu[14:12]})
							5'b11001: begin
								alu_operator_o = brq_pkg_ALU_CMIX;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							5'b11101: begin
								alu_operator_o = brq_pkg_ALU_CMOV;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							5'b10001: begin
								alu_operator_o = brq_pkg_ALU_FSL;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							5'b10101: begin
								alu_operator_o = brq_pkg_ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							default:
								;
						endcase
				end
				else
					case ({instr_alu[31:25], instr_alu[14:12]})
						10'b0000000000: alu_operator_o = brq_pkg_ALU_ADD;
						10'b0100000000: alu_operator_o = brq_pkg_ALU_SUB;
						10'b0000000010: alu_operator_o = brq_pkg_ALU_SLT;
						10'b0000000011: alu_operator_o = brq_pkg_ALU_SLTU;
						10'b0000000100: alu_operator_o = brq_pkg_ALU_XOR;
						10'b0000000110: alu_operator_o = brq_pkg_ALU_OR;
						10'b0000000111: alu_operator_o = brq_pkg_ALU_AND;
						10'b0000000001: alu_operator_o = brq_pkg_ALU_SLL;
						10'b0000000101: alu_operator_o = brq_pkg_ALU_SRL;
						10'b0100000101: alu_operator_o = brq_pkg_ALU_SRA;
						10'b0010000001:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SLO;
						10'b0010000101:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SRO;
						10'b0110000001:
							if (RV32B != brq_pkg_RV32BNone) begin
								alu_operator_o = brq_pkg_ALU_ROL;
								alu_multicycle_o = 1'b1;
							end
						10'b0110000101:
							if (RV32B != brq_pkg_RV32BNone) begin
								alu_operator_o = brq_pkg_ALU_ROR;
								alu_multicycle_o = 1'b1;
							end
						10'b0000101100:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_MIN;
						10'b0000101101:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_MAX;
						10'b0000101110:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_MINU;
						10'b0000101111:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_MAXU;
						10'b0000100100:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_PACK;
						10'b0100100100:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_PACKU;
						10'b0000100111:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_PACKH;
						10'b0100000100:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_XNOR;
						10'b0100000110:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_ORN;
						10'b0100000111:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_ANDN;
						10'b0100100001:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SBCLR;
						10'b0010100001:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SBSET;
						10'b0110100001:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SBINV;
						10'b0100100101:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_SBEXT;
						10'b0100100111:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_BFP;
						10'b0110100101:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_GREV;
						10'b0010100101:
							if (RV32B != brq_pkg_RV32BNone)
								alu_operator_o = brq_pkg_ALU_GORC;
						10'b0000100001:
							if (RV32B == brq_pkg_RV32BFull)
								alu_operator_o = brq_pkg_ALU_SHFL;
						10'b0000100101:
							if (RV32B == brq_pkg_RV32BFull)
								alu_operator_o = brq_pkg_ALU_UNSHFL;
						10'b0000101001:
							if (RV32B == brq_pkg_RV32BFull)
								alu_operator_o = brq_pkg_ALU_CLMUL;
						10'b0000101010:
							if (RV32B == brq_pkg_RV32BFull)
								alu_operator_o = brq_pkg_ALU_CLMULR;
						10'b0000101011:
							if (RV32B == brq_pkg_RV32BFull)
								alu_operator_o = brq_pkg_ALU_CLMULH;
						10'b0100100110:
							if (RV32B == brq_pkg_RV32BFull) begin
								alu_operator_o = brq_pkg_ALU_BDEP;
								alu_multicycle_o = 1'b1;
							end
						10'b0000100110:
							if (RV32B == brq_pkg_RV32BFull) begin
								alu_operator_o = brq_pkg_ALU_BEXT;
								alu_multicycle_o = 1'b1;
							end
						10'b0000001000: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							mult_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001001: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							mult_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001010: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							mult_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001011: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							mult_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001100: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							div_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001101: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							div_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001110: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							div_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						10'b0000001111: begin
							alu_operator_o = brq_pkg_ALU_ADD;
							div_sel_o = (RV32M == brq_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						default:
							;
					endcase
			end
			brq_pkg_OPCODE_MISC_MEM:
				case (instr_alu[14:12])
					3'b000: begin
						alu_operator_o = brq_pkg_ALU_ADD;
						alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
						alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					end
					3'b001:
						if (BranchTargetALU) begin
							bt_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
							bt_b_mux_sel_o = brq_pkg_IMM_B_INCR_PC;
						end
						else begin
							alu_op_a_mux_sel_o = brq_pkg_OP_A_CURRPC;
							alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
							imm_b_mux_sel_o = brq_pkg_IMM_B_INCR_PC;
							alu_operator_o = brq_pkg_ALU_ADD;
						end
					default:
						;
				endcase
			brq_pkg_OPCODE_SYSTEM:
				if (instr_alu[14:12] == 3'b000) begin
					alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
				end
				else begin
					alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					imm_a_mux_sel_o = brq_pkg_IMM_A_Z;
					imm_b_mux_sel_o = brq_pkg_IMM_B_I;
					if (instr_alu[14])
						alu_op_a_mux_sel_o = brq_pkg_OP_A_IMM;
					else
						alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				end
			brq_pkg_OPCODE_STORE_FP: begin
				alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = brq_pkg_OP_B_REG_B;
				alu_operator_o = brq_pkg_ALU_ADD;
				case (instr[14:12])
					3'b011: begin
						imm_b_mux_sel_o = brq_pkg_IMM_B_S;
						alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					end
					3'b010: begin
						imm_b_mux_sel_o = brq_pkg_IMM_B_S;
						alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
					end
					default:
						;
				endcase
			end
			brq_pkg_OPCODE_LOAD_FP:
				case (instr[14:12])
					3'b011: begin
						alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
						alu_operator_o = brq_pkg_ALU_ADD;
						alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
						imm_b_mux_sel_o = brq_pkg_IMM_B_I;
					end
					3'b010: begin
						alu_op_a_mux_sel_o = brq_pkg_OP_A_REG_A;
						alu_operator_o = brq_pkg_ALU_ADD;
						alu_op_b_mux_sel_o = brq_pkg_OP_B_IMM;
						imm_b_mux_sel_o = brq_pkg_IMM_B_I;
					end
					default:
						;
				endcase
			brq_pkg_OPCODE_MADD_FP:
				case (instr[26:25])
					1: begin
						fp_alu_operator_o = fpnew_pkg_FMADD;
						fp_alu_op_mod_o = 1'b0;
					end
					0: begin
						fp_alu_operator_o = fpnew_pkg_FMADD;
						fp_alu_op_mod_o = 1'b0;
					end
					default:
						;
				endcase
			brq_pkg_OPCODE_MSUB_FP:
				case (instr[26:25])
					1: begin
						fp_alu_operator_o = fpnew_pkg_FMADD;
						fp_alu_op_mod_o = 1'b1;
					end
					0: begin
						fp_alu_operator_o = fpnew_pkg_FMADD;
						fp_alu_op_mod_o = 1'b1;
					end
					default:
						;
				endcase
			brq_pkg_OPCODE_NMSUB_FP:
				case (instr[26:25])
					1: fp_alu_operator_o = fpnew_pkg_FNMSUB;
					0: fp_alu_operator_o = fpnew_pkg_FNMSUB;
					default:
						;
				endcase
			brq_pkg_OPCODE_NMADD_FP:
				case (instr[26:25])
					1: begin
						fp_alu_operator_o = fpnew_pkg_FNMSUB;
						fp_alu_op_mod_o = 1'b1;
					end
					0: begin
						fp_alu_operator_o = fpnew_pkg_FNMSUB;
						fp_alu_op_mod_o = 1'b1;
					end
					default:
						;
				endcase
			brq_pkg_OPCODE_OP_FP:
				case (instr[31:25])
					7'b0000001: fp_alu_operator_o = fpnew_pkg_ADD;
					7'b0000101: begin
						fp_alu_operator_o = fpnew_pkg_ADD;
						fp_alu_op_mod_o = 1'b1;
					end
					7'b0001001: fp_alu_operator_o = fpnew_pkg_MUL;
					7'b0001101: fp_alu_operator_o = fpnew_pkg_DIV;
					7'b0000000: fp_alu_operator_o = fpnew_pkg_ADD;
					7'b0000100: begin
						fp_alu_operator_o = fpnew_pkg_ADD;
						fp_alu_op_mod_o = 1'b1;
					end
					7'b0001000: fp_alu_operator_o = fpnew_pkg_MUL;
					7'b0001100: fp_alu_operator_o = fpnew_pkg_DIV;
					7'b0101101:
						if (~|instr[24:20])
							fp_alu_operator_o = fpnew_pkg_SQRT;
					7'b0101100:
						if (~|instr[24:20])
							fp_alu_operator_o = fpnew_pkg_SQRT;
					7'b0010001:
						if (~(instr[14] | &instr[13:12]))
							fp_alu_operator_o = fpnew_pkg_SGNJ;
					7'b0010000:
						if (~(instr[14] | &instr[13:12]))
							fp_alu_operator_o = fpnew_pkg_SGNJ;
					7'b0010101:
						if (~|instr[14:13])
							fp_alu_operator_o = fpnew_pkg_MINMAX;
					7'b0010100:
						if (~|instr[14:13])
							fp_alu_operator_o = fpnew_pkg_MINMAX;
					7'b0100000:
						if (~(|instr[24:21] | ~instr[20]))
							fp_alu_operator_o = fpnew_pkg_F2F;
					7'b1100000:
						if (~|instr[24:21]) begin
							fp_alu_operator_o = fpnew_pkg_F2I;
							if (instr[20])
								fp_alu_op_mod_o = 1'b1;
						end
					7'b0100001:
						if (~|instr[24:20])
							fp_alu_operator_o = fpnew_pkg_F2F;
					7'b1110000:
						case ({instr[24:20], instr[14:12]})
							6'b000001: fp_alu_operator_o = fpnew_pkg_CLASSIFY;
							default:
								;
						endcase
					7'b1010001:
						if (~instr[14] | &instr[13:12])
							fp_alu_operator_o = fpnew_pkg_CMP;
					7'b1010000:
						if (~instr[14] | &instr[13:12])
							fp_alu_operator_o = fpnew_pkg_CMP;
					7'b1110001:
						case ({instr[24:20], instr[14:12]})
							6'b000001: fp_alu_operator_o = fpnew_pkg_CLASSIFY;
							default:
								;
						endcase
					7'b1100001:
						if (~|instr[24:21]) begin
							fp_alu_operator_o = fpnew_pkg_F2I;
							if (instr[20])
								fp_alu_op_mod_o = 1'b1;
						end
					7'b1101000:
						if (~(|instr[24:21])) begin
							fp_alu_operator_o = fpnew_pkg_I2F;
							if (instr[20])
								fp_alu_op_mod_o = 1'b1;
						end
					7'b1111001:
						if (~|instr[24:21]) begin
							fp_alu_operator_o = fpnew_pkg_I2F;
							if (instr[20])
								fp_alu_op_mod_o = 1'b1;
						end
					default:
						;
				endcase
			default:
				;
		endcase
	end
	assign mult_en_o = (illegal_insn ? 1'b0 : mult_sel_o);
	assign div_en_o = (illegal_insn ? 1'b0 : div_sel_o);
	assign illegal_insn_o = illegal_insn | illegal_reg_rv32e;
	assign rf_we_o = rf_we & ~illegal_reg_rv32e;
endmodule
module brq_idu (
	clk_i,
	rst_ni,
	ctrl_busy_o,
	illegal_insn_o,
	instr_valid_i,
	instr_rdata_i,
	instr_rdata_alu_i,
	instr_rdata_c_i,
	instr_is_compressed_i,
	instr_req_o,
	instr_first_cycle_id_o,
	instr_valid_clear_o,
	id_in_ready_o,
	icache_inval_o,
	branch_decision_i,
	pc_set_o,
	pc_set_spec_o,
	pc_mux_o,
	exc_pc_mux_o,
	exc_cause_o,
	illegal_c_insn_i,
	instr_fetch_err_i,
	instr_fetch_err_plus2_i,
	pc_id_i,
	ex_valid_i,
	lsu_resp_valid_i,
	alu_operator_ex_o,
	alu_operand_a_ex_o,
	alu_operand_b_ex_o,
	imd_val_we_ex_i,
	imd_val_d_ex_i,
	imd_val_q_ex_o,
	bt_a_operand_o,
	bt_b_operand_o,
	mult_en_ex_o,
	div_en_ex_o,
	mult_sel_ex_o,
	div_sel_ex_o,
	multdiv_operator_ex_o,
	multdiv_signed_mode_ex_o,
	multdiv_operand_a_ex_o,
	multdiv_operand_b_ex_o,
	multdiv_ready_id_o,
	csr_access_o,
	csr_op_o,
	csr_op_en_o,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_wb_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	illegal_csr_insn_i,
	data_ind_timing_i,
	lsu_req_o,
	lsu_we_o,
	lsu_type_o,
	lsu_sign_ext_o,
	lsu_wdata_o,
	lsu_req_done_i,
	lsu_addr_incr_req_i,
	lsu_addr_last_i,
	csr_mstatus_mie_i,
	irq_pending_i,
	irqs_i,
	irq_nm_i,
	nmi_mode_o,
	lsu_load_err_i,
	lsu_store_err_i,
	debug_mode_o,
	debug_cause_o,
	debug_csr_save_o,
	debug_req_i,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	trigger_match_i,
	result_ex_i,
	csr_rdata_i,
	rf_raddr_a_o,
	rf_rdata_a_i,
	rf_raddr_b_o,
	rf_rdata_b_i,
	rf_ren_a_o,
	rf_ren_b_o,
	rf_waddr_id_o,
	rf_wdata_id_o,
	rf_we_id_o,
	rf_rd_a_wb_match_o,
	rf_rd_b_wb_match_o,
	rf_waddr_wb_i,
	rf_wdata_fwd_wb_i,
	rf_write_wb_i,
	en_wb_o,
	instr_type_wb_o,
	instr_perf_count_id_o,
	ready_wb_i,
	outstanding_load_wb_i,
	outstanding_store_wb_i,
	perf_jump_o,
	perf_branch_o,
	perf_tbranch_o,
	perf_dside_wait_o,
	perf_mul_wait_o,
	perf_div_wait_o,
	instr_id_done_o,
	fp_rounding_mode_o,
	fp_rf_rdata_a_i,
	fp_rf_rdata_b_i,
	fp_rf_rdata_c_i,
	fp_rf_raddr_a_o,
	fp_rf_raddr_b_o,
	fp_rf_raddr_c_o,
	fp_rf_waddr_o,
	fp_rf_we_o,
	fp_alu_operator_o,
	fp_alu_op_mod_o,
	fp_src_fmt_o,
	fp_dst_fmt_o,
	fp_rm_dynamic_o,
	fp_flush_o,
	is_fp_instr_o,
	use_fp_rs1_o,
	use_fp_rs2_o,
	use_fp_rs3_o,
	use_fp_rd_o,
	fpu_busy_i,
	fp_rf_write_wb_i,
	fp_rf_wdata_fwd_wb_i,
	fp_operands_o,
	fp_load_o
);
	parameter [0:0] RV32E = 0;
	localparam integer brq_pkg_RV32MFast = 2;
	parameter integer RV32M = brq_pkg_RV32MFast;
	localparam integer brq_pkg_RV32BNone = 0;
	parameter integer RV32B = brq_pkg_RV32BNone;
	localparam integer brq_pkg_RV64FDouble = 2;
	parameter integer RVF = brq_pkg_RV64FDouble;
	parameter [0:0] DataIndTiming = 1'b0;
	parameter [0:0] BranchTargetALU = 0;
	parameter [0:0] SpecBranch = 0;
	parameter [0:0] WritebackStage = 0;
	parameter [0:0] BranchPredictor = 0;
	input wire clk_i;
	input wire rst_ni;
	output wire ctrl_busy_o;
	output wire illegal_insn_o;
	input wire instr_valid_i;
	input wire [31:0] instr_rdata_i;
	input wire [31:0] instr_rdata_alu_i;
	input wire [15:0] instr_rdata_c_i;
	input wire instr_is_compressed_i;
	output wire instr_req_o;
	output wire instr_first_cycle_id_o;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output wire icache_inval_o;
	input wire branch_decision_i;
	output wire pc_set_o;
	output wire pc_set_spec_o;
	output wire [2:0] pc_mux_o;
	output wire [1:0] exc_pc_mux_o;
	output wire [5:0] exc_cause_o;
	input wire illegal_c_insn_i;
	input wire instr_fetch_err_i;
	input wire instr_fetch_err_plus2_i;
	input wire [31:0] pc_id_i;
	input wire ex_valid_i;
	input wire lsu_resp_valid_i;
	output wire [5:0] alu_operator_ex_o;
	output wire [31:0] alu_operand_a_ex_o;
	output wire [31:0] alu_operand_b_ex_o;
	input wire [1:0] imd_val_we_ex_i;
	input wire [67:0] imd_val_d_ex_i;
	output wire [67:0] imd_val_q_ex_o;
	output reg [31:0] bt_a_operand_o;
	output reg [31:0] bt_b_operand_o;
	output wire mult_en_ex_o;
	output wire div_en_ex_o;
	output wire mult_sel_ex_o;
	output wire div_sel_ex_o;
	output wire [1:0] multdiv_operator_ex_o;
	output wire [1:0] multdiv_signed_mode_ex_o;
	output wire [31:0] multdiv_operand_a_ex_o;
	output wire [31:0] multdiv_operand_b_ex_o;
	output wire multdiv_ready_id_o;
	output wire csr_access_o;
	output wire [1:0] csr_op_o;
	output wire csr_op_en_o;
	output wire csr_save_if_o;
	output wire csr_save_id_o;
	output wire csr_save_wb_o;
	output wire csr_restore_mret_id_o;
	output wire csr_restore_dret_id_o;
	output wire csr_save_cause_o;
	output wire [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire illegal_csr_insn_i;
	input wire data_ind_timing_i;
	output wire lsu_req_o;
	output wire lsu_we_o;
	output wire [1:0] lsu_type_o;
	output wire lsu_sign_ext_o;
	output wire [31:0] lsu_wdata_o;
	input wire lsu_req_done_i;
	input wire lsu_addr_incr_req_i;
	input wire [31:0] lsu_addr_last_i;
	input wire csr_mstatus_mie_i;
	input wire irq_pending_i;
	input wire [17:0] irqs_i;
	input wire irq_nm_i;
	output wire nmi_mode_o;
	input wire lsu_load_err_i;
	input wire lsu_store_err_i;
	output wire debug_mode_o;
	output wire [2:0] debug_cause_o;
	output wire debug_csr_save_o;
	input wire debug_req_i;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire trigger_match_i;
	input wire [31:0] result_ex_i;
	input wire [31:0] csr_rdata_i;
	output wire [4:0] rf_raddr_a_o;
	input wire [31:0] rf_rdata_a_i;
	output wire [4:0] rf_raddr_b_o;
	input wire [31:0] rf_rdata_b_i;
	output wire rf_ren_a_o;
	output wire rf_ren_b_o;
	output wire [4:0] rf_waddr_id_o;
	output reg [31:0] rf_wdata_id_o;
	output wire rf_we_id_o;
	output wire rf_rd_a_wb_match_o;
	output wire rf_rd_b_wb_match_o;
	input wire [4:0] rf_waddr_wb_i;
	input wire [31:0] rf_wdata_fwd_wb_i;
	input wire rf_write_wb_i;
	output wire en_wb_o;
	output wire [1:0] instr_type_wb_o;
	output wire instr_perf_count_id_o;
	input wire ready_wb_i;
	input wire outstanding_load_wb_i;
	input wire outstanding_store_wb_i;
	output wire perf_jump_o;
	output reg perf_branch_o;
	output wire perf_tbranch_o;
	output wire perf_dside_wait_o;
	output wire perf_mul_wait_o;
	output wire perf_div_wait_o;
	output wire instr_id_done_o;
	output wire [2:0] fp_rounding_mode_o;
	input wire [31:0] fp_rf_rdata_a_i;
	input wire [31:0] fp_rf_rdata_b_i;
	input wire [31:0] fp_rf_rdata_c_i;
	output wire [4:0] fp_rf_raddr_a_o;
	output wire [4:0] fp_rf_raddr_b_o;
	output wire [4:0] fp_rf_raddr_c_o;
	output wire [4:0] fp_rf_waddr_o;
	output wire fp_rf_we_o;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	output wire [3:0] fp_alu_operator_o;
	output wire fp_alu_op_mod_o;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	output wire [1:0] fp_src_fmt_o;
	output wire [1:0] fp_dst_fmt_o;
	output wire fp_rm_dynamic_o;
	output wire fp_flush_o;
	output wire is_fp_instr_o;
	output wire use_fp_rs1_o;
	output wire use_fp_rs2_o;
	output wire use_fp_rs3_o;
	output wire use_fp_rd_o;
	input wire fpu_busy_i;
	input wire fp_rf_write_wb_i;
	input wire [31:0] fp_rf_wdata_fwd_wb_i;
	output reg [95:0] fp_operands_o;
	output wire fp_load_o;
	wire illegal_insn_dec;
	wire ebrk_insn;
	wire mret_insn_dec;
	wire dret_insn_dec;
	wire ecall_insn_dec;
	wire wfi_insn_dec;
	wire wb_exception;
	wire branch_in_dec;
	reg branch_spec;
	wire branch_set_spec;
	wire branch_set;
	reg branch_set_d;
	reg branch_not_set;
	wire branch_taken;
	wire jump_in_dec;
	wire jump_set_dec;
	reg jump_set;
	wire instr_first_cycle;
	wire instr_executing;
	wire instr_done;
	wire controller_run;
	wire stall_ld_hz;
	wire stall_mem;
	reg stall_multdiv;
	reg stall_branch;
	reg stall_jump;
	wire stall_id;
	wire stall_wb;
	wire flush_id;
	wire multicycle_done;
	wire [31:0] imm_i_type;
	wire [31:0] imm_s_type;
	wire [31:0] imm_b_type;
	wire [31:0] imm_u_type;
	wire [31:0] imm_j_type;
	wire [31:0] zimm_rs1_type;
	wire [31:0] imm_a;
	reg [31:0] imm_b;
	wire rf_wdata_sel;
	wire rf_we_dec;
	reg rf_we_raw;
	wire rf_ren_a;
	wire rf_ren_b;
	assign rf_ren_a_o = rf_ren_a;
	assign rf_ren_b_o = rf_ren_b;
	wire [31:0] rf_rdata_a_fwd;
	wire [31:0] rf_rdata_b_fwd;
	wire [5:0] alu_operator;
	wire [1:0] alu_op_a_mux_sel;
	wire [1:0] alu_op_a_mux_sel_dec;
	wire alu_op_b_mux_sel;
	wire alu_op_b_mux_sel_dec;
	wire alu_multicycle_dec;
	reg stall_alu;
	reg [67:0] imd_val_q;
	wire [1:0] bt_a_mux_sel;
	wire [2:0] bt_b_mux_sel;
	wire imm_a_mux_sel;
	wire [2:0] imm_b_mux_sel;
	wire [2:0] imm_b_mux_sel_dec;
	wire mult_en_id;
	wire mult_en_dec;
	wire div_en_id;
	wire div_en_dec;
	wire multdiv_en_dec;
	wire [1:0] multdiv_operator;
	wire [1:0] multdiv_signed_mode;
	wire lsu_we;
	wire [1:0] lsu_type;
	wire lsu_sign_ext;
	wire lsu_req;
	wire lsu_req_dec;
	wire data_req_allowed;
	reg csr_pipe_flush;
	reg [31:0] alu_operand_a;
	wire [31:0] alu_operand_b;
	wire fp_swap_oprnds;
	wire [31:0] fp_rf_rdata_a_fwd;
	wire [31:0] fp_rf_rdata_b_fwd;
	wire [31:0] fp_rf_rdata_c_fwd;
	wire [31:0] temp;
	reg [31:0] fpu_op_a;
	reg [31:0] fpu_op_b;
	reg [31:0] fpu_op_c;
	wire mv_instr;
	wire [31:0] result_wb;
	localparam [1:0] brq_pkg_OP_A_FWD = 1;
	assign alu_op_a_mux_sel = (lsu_addr_incr_req_i ? brq_pkg_OP_A_FWD : alu_op_a_mux_sel_dec);
	localparam [0:0] brq_pkg_OP_B_IMM = 1;
	assign alu_op_b_mux_sel = (lsu_addr_incr_req_i ? brq_pkg_OP_B_IMM : alu_op_b_mux_sel_dec);
	localparam [2:0] brq_pkg_IMM_B_INCR_ADDR = 6;
	assign imm_b_mux_sel = (lsu_addr_incr_req_i ? brq_pkg_IMM_B_INCR_ADDR : imm_b_mux_sel_dec);
	localparam [0:0] brq_pkg_IMM_A_Z = 0;
	assign imm_a = (imm_a_mux_sel == brq_pkg_IMM_A_Z ? zimm_rs1_type : {32 {1'sb0}});
	localparam [1:0] brq_pkg_OP_A_CURRPC = 2;
	localparam [1:0] brq_pkg_OP_A_IMM = 3;
	localparam [1:0] brq_pkg_OP_A_REG_A = 0;
	always @(*) begin : alu_operand_a_mux
		case (alu_op_a_mux_sel)
			brq_pkg_OP_A_REG_A: alu_operand_a = rf_rdata_a_fwd;
			brq_pkg_OP_A_FWD: alu_operand_a = lsu_addr_last_i;
			brq_pkg_OP_A_CURRPC: alu_operand_a = pc_id_i;
			brq_pkg_OP_A_IMM: alu_operand_a = imm_a;
		endcase
	end
	localparam [2:0] brq_pkg_IMM_B_B = 2;
	localparam [2:0] brq_pkg_IMM_B_I = 0;
	localparam [2:0] brq_pkg_IMM_B_INCR_PC = 5;
	localparam [2:0] brq_pkg_IMM_B_J = 4;
	localparam [2:0] brq_pkg_IMM_B_S = 1;
	localparam [2:0] brq_pkg_IMM_B_U = 3;
	generate
		if (BranchTargetALU) begin : g_btalu_muxes
			always @(*) begin : bt_operand_a_mux
				case (bt_a_mux_sel)
					brq_pkg_OP_A_REG_A: bt_a_operand_o = rf_rdata_a_fwd;
					brq_pkg_OP_A_CURRPC: bt_a_operand_o = pc_id_i;
					default: bt_a_operand_o = pc_id_i;
				endcase
			end
			always @(*) begin : bt_immediate_b_mux
				case (bt_b_mux_sel)
					brq_pkg_IMM_B_I: bt_b_operand_o = imm_i_type;
					brq_pkg_IMM_B_B: bt_b_operand_o = imm_b_type;
					brq_pkg_IMM_B_J: bt_b_operand_o = imm_j_type;
					brq_pkg_IMM_B_INCR_PC: bt_b_operand_o = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					default: bt_b_operand_o = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
				endcase
			end
			always @(*) begin : immediate_b_mux
				case (imm_b_mux_sel)
					brq_pkg_IMM_B_I: imm_b = imm_i_type;
					brq_pkg_IMM_B_S: imm_b = imm_s_type;
					brq_pkg_IMM_B_U: imm_b = imm_u_type;
					brq_pkg_IMM_B_INCR_PC: imm_b = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					brq_pkg_IMM_B_INCR_ADDR: imm_b = 32'h00000004;
					default: imm_b = 32'h00000004;
				endcase
			end
		end
		else begin : g_nobtalu
			wire [1:0] unused_a_mux_sel;
			wire [2:0] unused_b_mux_sel;
			assign unused_a_mux_sel = bt_a_mux_sel;
			assign unused_b_mux_sel = bt_b_mux_sel;
			wire [32:1] sv2v_tmp_456A8;
			assign sv2v_tmp_456A8 = {32 {1'sb0}};
			always @(*) bt_a_operand_o = sv2v_tmp_456A8;
			wire [32:1] sv2v_tmp_EDBFD;
			assign sv2v_tmp_EDBFD = {32 {1'sb0}};
			always @(*) bt_b_operand_o = sv2v_tmp_EDBFD;
			always @(*) begin : immediate_b_mux
				case (imm_b_mux_sel)
					brq_pkg_IMM_B_I: imm_b = imm_i_type;
					brq_pkg_IMM_B_S: imm_b = imm_s_type;
					brq_pkg_IMM_B_B: imm_b = imm_b_type;
					brq_pkg_IMM_B_U: imm_b = imm_u_type;
					brq_pkg_IMM_B_J: imm_b = imm_j_type;
					brq_pkg_IMM_B_INCR_PC: imm_b = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					brq_pkg_IMM_B_INCR_ADDR: imm_b = 32'h00000004;
					default: imm_b = 32'h00000004;
				endcase
			end
		end
	endgenerate
	assign alu_operand_b = (alu_op_b_mux_sel == brq_pkg_OP_B_IMM ? imm_b : rf_rdata_b_fwd);
	generate
		genvar i;
		for (i = 0; i < 2; i = i + 1) begin : gen_intermediate_val_reg
			always @(posedge clk_i or negedge rst_ni) begin : intermediate_val_reg
				if (!rst_ni)
					imd_val_q[(1 - i) * 34+:34] <= {34 {1'sb0}};
				else if (imd_val_we_ex_i[i])
					imd_val_q[(1 - i) * 34+:34] <= imd_val_d_ex_i[(1 - i) * 34+:34];
			end
		end
	endgenerate
	assign imd_val_q_ex_o = imd_val_q;
	brq_idu_decoder #(
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU)
	) decoder_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.illegal_insn_o(illegal_insn_dec),
		.ebrk_insn_o(ebrk_insn),
		.mret_insn_o(mret_insn_dec),
		.dret_insn_o(dret_insn_dec),
		.ecall_insn_o(ecall_insn_dec),
		.wfi_insn_o(wfi_insn_dec),
		.jump_set_o(jump_set_dec),
		.branch_taken_i(branch_taken),
		.icache_inval_o(icache_inval_o),
		.instr_first_cycle_i(instr_first_cycle),
		.instr_rdata_i(instr_rdata_i),
		.instr_rdata_alu_i(instr_rdata_alu_i),
		.illegal_c_insn_i(illegal_c_insn_i),
		.imm_a_mux_sel_o(imm_a_mux_sel),
		.imm_b_mux_sel_o(imm_b_mux_sel_dec),
		.bt_a_mux_sel_o(bt_a_mux_sel),
		.bt_b_mux_sel_o(bt_b_mux_sel),
		.imm_i_type_o(imm_i_type),
		.imm_s_type_o(imm_s_type),
		.imm_b_type_o(imm_b_type),
		.imm_u_type_o(imm_u_type),
		.imm_j_type_o(imm_j_type),
		.zimm_rs1_type_o(zimm_rs1_type),
		.rf_wdata_sel_o(rf_wdata_sel),
		.rf_we_o(rf_we_dec),
		.rf_raddr_a_o(rf_raddr_a_o),
		.rf_raddr_b_o(rf_raddr_b_o),
		.rf_waddr_o(rf_waddr_id_o),
		.rf_ren_a_o(rf_ren_a),
		.rf_ren_b_o(rf_ren_b),
		.alu_operator_o(alu_operator),
		.alu_op_a_mux_sel_o(alu_op_a_mux_sel_dec),
		.alu_op_b_mux_sel_o(alu_op_b_mux_sel_dec),
		.alu_multicycle_o(alu_multicycle_dec),
		.mult_en_o(mult_en_dec),
		.div_en_o(div_en_dec),
		.mult_sel_o(mult_sel_ex_o),
		.div_sel_o(div_sel_ex_o),
		.multdiv_operator_o(multdiv_operator),
		.multdiv_signed_mode_o(multdiv_signed_mode),
		.csr_access_o(csr_access_o),
		.csr_op_o(csr_op_o),
		.data_req_o(lsu_req_dec),
		.data_we_o(lsu_we),
		.data_type_o(lsu_type),
		.data_sign_extension_o(lsu_sign_ext),
		.jump_in_dec_o(jump_in_dec),
		.branch_in_dec_o(branch_in_dec),
		.fp_rounding_mode_o(fp_rounding_mode_o),
		.fp_rf_raddr_a_o(fp_rf_raddr_a_o),
		.fp_rf_raddr_b_o(fp_rf_raddr_b_o),
		.fp_rf_raddr_c_o(fp_rf_raddr_c_o),
		.fp_rf_waddr_o(fp_rf_waddr_o),
		.fp_rf_we_o(fp_rf_we_o),
		.fp_alu_operator_o(fp_alu_operator_o),
		.fp_alu_op_mod_o(fp_alu_op_mod_o),
		.fp_src_fmt_o(fp_src_fmt_o),
		.fp_dst_fmt_o(fp_dst_fmt_o),
		.fp_rm_dynamic_o(fp_rm_dynamic_o),
		.is_fp_instr_o(is_fp_instr_o),
		.use_fp_rs1_o(use_fp_rs1_o),
		.use_fp_rs2_o(use_fp_rs2_o),
		.use_fp_rs3_o(use_fp_rs3_o),
		.use_fp_rd_o(use_fp_rd_o),
		.fp_swap_oprnds_o(fp_swap_oprnds),
		.fp_load_o(fp_load_o),
		.mv_instr_o(mv_instr)
	);
	assign rf_we_id_o = (rf_we_raw & instr_executing) & ~illegal_csr_insn_i;
	localparam [0:0] brq_pkg_RF_WD_CSR = 1;
	localparam [0:0] brq_pkg_RF_WD_EX = 0;
	always @(*) begin : rf_wdata_id_mux
		case (rf_wdata_sel)
			brq_pkg_RF_WD_EX: rf_wdata_id_o = result_wb;
			brq_pkg_RF_WD_CSR: rf_wdata_id_o = csr_rdata_i;
		endcase
	end
	localparam [11:0] brq_pkg_CSR_DCSR = 12'h7b0;
	localparam [11:0] brq_pkg_CSR_DPC = 12'h7b1;
	localparam [11:0] brq_pkg_CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] brq_pkg_CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] brq_pkg_CSR_MIE = 12'h304;
	localparam [11:0] brq_pkg_CSR_MSTATUS = 12'h300;
	localparam [1:0] brq_pkg_CSR_OP_READ = 0;
	localparam [1:0] brq_pkg_CSR_OP_SET = 2;
	localparam [1:0] brq_pkg_CSR_OP_WRITE = 1;
	always @(*) begin : csr_pipeline_flushes
		csr_pipe_flush = 1'b0;
		if ((csr_op_en_o == 1'b1) && ((csr_op_o == brq_pkg_CSR_OP_WRITE) || (csr_op_o == brq_pkg_CSR_OP_SET))) begin
			if ((instr_rdata_i[31:20] == brq_pkg_CSR_MSTATUS) || (instr_rdata_i[31:20] == brq_pkg_CSR_MIE))
				csr_pipe_flush = 1'b1;
		end
		else if ((csr_op_en_o == 1'b1) && (csr_op_o != brq_pkg_CSR_OP_READ))
			if ((((instr_rdata_i[31:20] == brq_pkg_CSR_DCSR) || (instr_rdata_i[31:20] == brq_pkg_CSR_DPC)) || (instr_rdata_i[31:20] == brq_pkg_CSR_DSCRATCH0)) || (instr_rdata_i[31:20] == brq_pkg_CSR_DSCRATCH1))
				csr_pipe_flush = 1'b1;
	end
	assign illegal_insn_o = instr_valid_i & (illegal_insn_dec | illegal_csr_insn_i);
	brq_idu_controller #(
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor)
	) controller_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ctrl_busy_o(ctrl_busy_o),
		.illegal_insn_i(illegal_insn_o),
		.ecall_insn_i(ecall_insn_dec),
		.mret_insn_i(mret_insn_dec),
		.dret_insn_i(dret_insn_dec),
		.wfi_insn_i(wfi_insn_dec),
		.ebrk_insn_i(ebrk_insn),
		.csr_pipe_flush_i(csr_pipe_flush),
		.instr_valid_i(instr_valid_i),
		.instr_i(instr_rdata_i),
		.instr_compressed_i(instr_rdata_c_i),
		.instr_is_compressed_i(instr_is_compressed_i),
		.instr_fetch_err_i(instr_fetch_err_i),
		.instr_fetch_err_plus2_i(instr_fetch_err_plus2_i),
		.pc_id_i(pc_id_i),
		.instr_valid_clear_o(instr_valid_clear_o),
		.id_in_ready_o(id_in_ready_o),
		.controller_run_o(controller_run),
		.instr_req_o(instr_req_o),
		.pc_set_o(pc_set_o),
		.pc_set_spec_o(pc_set_spec_o),
		.pc_mux_o(pc_mux_o),
		.exc_pc_mux_o(exc_pc_mux_o),
		.exc_cause_o(exc_cause_o),
		.lsu_addr_last_i(lsu_addr_last_i),
		.load_err_i(lsu_load_err_i),
		.store_err_i(lsu_store_err_i),
		.wb_exception_o(wb_exception),
		.branch_set_i(branch_set),
		.branch_set_spec_i(branch_set_spec),
		.jump_set_i(jump_set),
		.csr_mstatus_mie_i(csr_mstatus_mie_i),
		.irq_pending_i(irq_pending_i),
		.irqs_i(irqs_i),
		.irq_nm_i(irq_nm_i),
		.nmi_mode_o(nmi_mode_o),
		.csr_save_if_o(csr_save_if_o),
		.csr_save_id_o(csr_save_id_o),
		.csr_save_wb_o(csr_save_wb_o),
		.csr_restore_mret_id_o(csr_restore_mret_id_o),
		.csr_restore_dret_id_o(csr_restore_dret_id_o),
		.csr_save_cause_o(csr_save_cause_o),
		.csr_mtval_o(csr_mtval_o),
		.priv_mode_i(priv_mode_i),
		.csr_mstatus_tw_i(csr_mstatus_tw_i),
		.debug_mode_o(debug_mode_o),
		.debug_cause_o(debug_cause_o),
		.debug_csr_save_o(debug_csr_save_o),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step_i),
		.debug_ebreakm_i(debug_ebreakm_i),
		.debug_ebreaku_i(debug_ebreaku_i),
		.trigger_match_i(trigger_match_i),
		.stall_id_i(stall_id),
		.stall_wb_i(stall_wb),
		.flush_id_o(flush_id),
		.ready_wb_i(ready_wb_i),
		.perf_jump_o(perf_jump_o),
		.perf_tbranch_o(perf_tbranch_o),
		.fpu_busy_i(fpu_busy_i)
	);
	assign fp_flush_o = flush_id;
	assign multdiv_en_dec = mult_en_dec | div_en_dec;
	assign lsu_req = (instr_executing ? data_req_allowed & lsu_req_dec : 1'b0);
	assign mult_en_id = (instr_executing ? mult_en_dec : 1'b0);
	assign div_en_id = (instr_executing ? div_en_dec : 1'b0);
	assign lsu_req_o = lsu_req;
	assign lsu_we_o = lsu_we;
	assign lsu_type_o = lsu_type;
	assign lsu_sign_ext_o = lsu_sign_ext;
	assign lsu_wdata_o = fpu_op_b;
	assign csr_op_en_o = (csr_access_o & instr_executing) & instr_id_done_o;
	assign alu_operator_ex_o = alu_operator;
	assign alu_operand_a_ex_o = alu_operand_a;
	assign alu_operand_b_ex_o = alu_operand_b;
	assign mult_en_ex_o = mult_en_id;
	assign div_en_ex_o = div_en_id;
	assign multdiv_operator_ex_o = multdiv_operator;
	assign multdiv_signed_mode_ex_o = multdiv_signed_mode;
	assign multdiv_operand_a_ex_o = rf_rdata_a_fwd;
	assign multdiv_operand_b_ex_o = rf_rdata_b_fwd;
	generate
		if (BranchTargetALU && !DataIndTiming) begin : g_branch_set_direct
			assign branch_set = branch_set_d;
			assign branch_set_spec = branch_spec;
		end
		else begin : g_branch_set_flop
			reg branch_set_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					branch_set_q <= 1'b0;
				else
					branch_set_q <= branch_set_d;
			assign branch_set = (BranchTargetALU && !data_ind_timing_i ? branch_set_d : branch_set_q);
			assign branch_set_spec = (BranchTargetALU && !data_ind_timing_i ? branch_spec : branch_set_q);
		end
	endgenerate
	generate
		if (DataIndTiming) begin : g_sec_branch_taken
			reg branch_taken_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					branch_taken_q <= 1'b0;
				else
					branch_taken_q <= branch_decision_i;
			assign branch_taken = ~data_ind_timing_i | branch_taken_q;
		end
		else begin : g_nosec_branch_taken
			assign branch_taken = 1'b1;
		end
	endgenerate
	reg id_fsm_q;
	reg id_fsm_d;
	localparam [0:0] FIRST_CYCLE = 0;
	always @(posedge clk_i or negedge rst_ni) begin : id_pipeline_reg
		if (!rst_ni)
			id_fsm_q <= FIRST_CYCLE;
		else
			id_fsm_q <= id_fsm_d;
	end
	localparam [0:0] MULTI_CYCLE = 1;
	always @(*) begin
		id_fsm_d = id_fsm_q;
		rf_we_raw = rf_we_dec;
		stall_multdiv = 1'b0;
		stall_jump = 1'b0;
		stall_branch = 1'b0;
		stall_alu = 1'b0;
		branch_set_d = 1'b0;
		branch_spec = 1'b0;
		branch_not_set = 1'b0;
		jump_set = 1'b0;
		perf_branch_o = 1'b0;
		if (instr_executing)
			case (id_fsm_q)
				FIRST_CYCLE:
					case (1'b1)
						lsu_req_dec:
							if (!WritebackStage)
								id_fsm_d = MULTI_CYCLE;
							else if (~lsu_req_done_i)
								id_fsm_d = MULTI_CYCLE;
						multdiv_en_dec:
							if (~ex_valid_i) begin
								id_fsm_d = MULTI_CYCLE;
								rf_we_raw = 1'b0;
								stall_multdiv = 1'b1;
							end
						branch_in_dec: begin
							id_fsm_d = (data_ind_timing_i || (!BranchTargetALU && branch_decision_i) ? MULTI_CYCLE : FIRST_CYCLE);
							stall_branch = (~BranchTargetALU & branch_decision_i) | data_ind_timing_i;
							branch_set_d = branch_decision_i | data_ind_timing_i;
							if (BranchPredictor)
								branch_not_set = ~branch_decision_i;
							branch_spec = (SpecBranch ? 1'b1 : branch_decision_i);
							perf_branch_o = 1'b1;
						end
						jump_in_dec: begin
							id_fsm_d = (BranchTargetALU ? FIRST_CYCLE : MULTI_CYCLE);
							stall_jump = ~BranchTargetALU;
							jump_set = jump_set_dec;
						end
						alu_multicycle_dec: begin
							stall_alu = 1'b1;
							id_fsm_d = MULTI_CYCLE;
							rf_we_raw = 1'b0;
						end
						default: id_fsm_d = FIRST_CYCLE;
					endcase
				MULTI_CYCLE: begin
					if (multdiv_en_dec)
						rf_we_raw = rf_we_dec & ex_valid_i;
					if (multicycle_done & ready_wb_i)
						id_fsm_d = FIRST_CYCLE;
					else begin
						stall_multdiv = multdiv_en_dec;
						stall_branch = branch_in_dec;
						stall_jump = jump_in_dec;
					end
				end
			endcase
	end
	assign multdiv_ready_id_o = ready_wb_i;
	assign stall_id = ((((stall_ld_hz | stall_mem) | stall_multdiv) | stall_jump) | stall_branch) | stall_alu;
	assign instr_done = (~stall_id & ~flush_id) & instr_executing;
	assign instr_first_cycle = instr_valid_i & (id_fsm_q == FIRST_CYCLE);
	assign instr_first_cycle_id_o = instr_first_cycle;
	localparam [1:0] brq_pkg_WB_INSTR_LOAD = 0;
	localparam [1:0] brq_pkg_WB_INSTR_OTHER = 2;
	localparam [1:0] brq_pkg_WB_INSTR_STORE = 1;
	generate
		if (WritebackStage) begin : gen_stall_mem
			wire rf_rd_a_wb_match;
			wire rf_rd_b_wb_match;
			wire fp_rf_rd_a_wb_match;
			wire fp_rf_rd_b_wb_match;
			wire fp_rf_rd_c_wb_match;
			wire rf_rd_a_hz;
			wire rf_rd_b_hz;
			wire rf_rd_c_hz;
			wire outstanding_memory_access;
			wire instr_kill;
			assign multicycle_done = (lsu_req_dec ? ~stall_mem : ex_valid_i);
			assign outstanding_memory_access = (outstanding_load_wb_i | outstanding_store_wb_i) & ~lsu_resp_valid_i;
			assign data_req_allowed = ~outstanding_memory_access;
			assign instr_kill = (instr_fetch_err_i | wb_exception) | ~controller_run;
			assign instr_executing = ((instr_valid_i & ~instr_kill) & ~stall_ld_hz) & ~outstanding_memory_access;
			assign stall_mem = instr_valid_i & (outstanding_memory_access | (lsu_req_dec & ~lsu_req_done_i));
			assign rf_rd_a_wb_match = (rf_waddr_wb_i == rf_raddr_a_o) & |rf_raddr_a_o;
			assign rf_rd_b_wb_match = (rf_waddr_wb_i == rf_raddr_b_o) & |rf_raddr_b_o;
			assign fp_rf_rd_a_wb_match = rf_waddr_wb_i == rf_raddr_a_o;
			assign fp_rf_rd_b_wb_match = rf_waddr_wb_i == rf_raddr_b_o;
			assign fp_rf_rd_c_wb_match = rf_waddr_wb_i == fp_rf_raddr_c_o;
			assign rf_rd_a_wb_match_o = rf_rd_a_wb_match;
			assign rf_rd_b_wb_match_o = rf_rd_b_wb_match;
			assign rf_rd_a_hz = rf_rd_a_wb_match & (rf_ren_a | use_fp_rs1_o);
			assign rf_rd_b_hz = rf_rd_b_wb_match & (rf_ren_b | use_fp_rs2_o);
			assign rf_rd_c_hz = rf_rd_b_wb_match & use_fp_rs3_o;
			assign rf_rdata_a_fwd = (rf_rd_a_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_a_i);
			assign rf_rdata_b_fwd = (rf_rd_b_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_b_i);
			assign fp_rf_rdata_a_fwd = (fp_rf_rd_a_wb_match & fp_rf_write_wb_i ? fp_rf_wdata_fwd_wb_i : fp_rf_rdata_a_i);
			assign fp_rf_rdata_b_fwd = (fp_rf_rd_b_wb_match & fp_rf_write_wb_i ? fp_rf_wdata_fwd_wb_i : fp_rf_rdata_b_i);
			assign fp_rf_rdata_c_fwd = (fp_rf_rd_c_wb_match & fp_rf_write_wb_i ? fp_rf_wdata_fwd_wb_i : fp_rf_rdata_c_i);
			assign stall_ld_hz = outstanding_load_wb_i & ((rf_rd_a_hz | rf_rd_b_hz) | rf_rd_c_hz);
			assign instr_type_wb_o = (~lsu_req_dec ? brq_pkg_WB_INSTR_OTHER : (lsu_we ? brq_pkg_WB_INSTR_STORE : brq_pkg_WB_INSTR_LOAD));
			assign instr_id_done_o = en_wb_o & ready_wb_i;
			assign stall_wb = en_wb_o & ~ready_wb_i;
			assign perf_dside_wait_o = (instr_valid_i & ~instr_kill) & (outstanding_memory_access | stall_ld_hz);
		end
		else begin : gen_no_stall_mem
			assign multicycle_done = (lsu_req_dec ? lsu_resp_valid_i : ex_valid_i);
			assign data_req_allowed = instr_first_cycle;
			assign stall_mem = instr_valid_i & (lsu_req_dec & (~lsu_resp_valid_i | instr_first_cycle));
			assign stall_ld_hz = 1'b0;
			assign instr_executing = (instr_valid_i & ~instr_fetch_err_i) & controller_run;
			assign rf_rdata_a_fwd = rf_rdata_a_i;
			assign rf_rdata_b_fwd = rf_rdata_b_i;
			assign fp_rf_rdata_a_fwd = fp_rf_rdata_a_i;
			assign fp_rf_rdata_b_fwd = fp_rf_rdata_b_i;
			assign fp_rf_rdata_c_fwd = fp_rf_rdata_c_i;
			assign rf_rd_a_wb_match_o = 1'b0;
			assign rf_rd_b_wb_match_o = 1'b0;
			wire unused_data_req_done_ex;
			wire [4:0] unused_rf_waddr_wb;
			wire unused_rf_write_wb;
			wire unused_outstanding_load_wb;
			wire unused_outstanding_store_wb;
			wire unused_wb_exception;
			wire [31:0] unused_rf_wdata_fwd_wb;
			assign unused_data_req_done_ex = lsu_req_done_i;
			assign unused_rf_waddr_wb = rf_waddr_wb_i;
			assign unused_rf_write_wb = rf_write_wb_i;
			assign unused_outstanding_load_wb = outstanding_load_wb_i;
			assign unused_outstanding_store_wb = outstanding_store_wb_i;
			assign unused_wb_exception = wb_exception;
			assign unused_rf_wdata_fwd_wb = rf_wdata_fwd_wb_i;
			assign instr_type_wb_o = brq_pkg_WB_INSTR_OTHER;
			assign stall_wb = 1'b0;
			assign perf_dside_wait_o = (instr_executing & lsu_req_dec) & ~lsu_resp_valid_i;
			assign instr_id_done_o = instr_done;
		end
	endgenerate
	always @(*) begin : swapping
		fpu_op_a = (use_fp_rs1_o ? fp_rf_rdata_a_fwd : rf_rdata_a_fwd);
		fpu_op_b = (use_fp_rs2_o ? fp_rf_rdata_b_fwd : rf_rdata_b_fwd);
		if (fp_swap_oprnds)
			fpu_op_c = fpu_op_a;
		else
			fpu_op_c = fp_rf_rdata_c_fwd;
		fp_operands_o = {fpu_op_c, fpu_op_b, fpu_op_a};
	end
	assign result_wb = (mv_instr ? fpu_op_a : result_ex_i);
	assign instr_perf_count_id_o = (((~ebrk_insn & ~ecall_insn_dec) & ~illegal_insn_dec) & ~illegal_csr_insn_i) & ~instr_fetch_err_i;
	assign en_wb_o = instr_done;
	assign perf_mul_wait_o = stall_multdiv & mult_en_dec;
	assign perf_div_wait_o = stall_multdiv & div_en_dec;
endmodule
module brq_ifu_compressed_decoder (
	instr_i,
	instr_o,
	is_compressed_o,
	illegal_instr_o
);
	input wire [31:0] instr_i;
	output reg [31:0] instr_o;
	output wire is_compressed_o;
	output reg illegal_instr_o;
	localparam [6:0] brq_pkg_OPCODE_BRANCH = 7'h63;
	localparam [6:0] brq_pkg_OPCODE_JAL = 7'h6f;
	localparam [6:0] brq_pkg_OPCODE_JALR = 7'h67;
	localparam [6:0] brq_pkg_OPCODE_LOAD = 7'h03;
	localparam [6:0] brq_pkg_OPCODE_LUI = 7'h37;
	localparam [6:0] brq_pkg_OPCODE_OP = 7'h33;
	localparam [6:0] brq_pkg_OPCODE_OP_IMM = 7'h13;
	localparam [6:0] brq_pkg_OPCODE_STORE = 7'h23;
	always @(*) begin
		instr_o = instr_i;
		illegal_instr_o = 1'b0;
		case (instr_i[1:0])
			2'b00:
				case (instr_i[15:13])
					3'b000: begin
						instr_o = {2'b00, instr_i[10:7], instr_i[12:11], instr_i[5], instr_i[6], 2'b00, 5'h02, 3'b000, 2'b01, instr_i[4:2], {brq_pkg_OPCODE_OP_IMM}};
						if (instr_i[12:5] == 8'b00000000)
							illegal_instr_o = 1'b1;
					end
					3'b010: instr_o = {5'b00000, instr_i[5], instr_i[12:10], instr_i[6], 2'b00, 2'b01, instr_i[9:7], 3'b010, 2'b01, instr_i[4:2], {brq_pkg_OPCODE_LOAD}};
					3'b110: instr_o = {5'b00000, instr_i[5], instr_i[12], 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b010, instr_i[11:10], instr_i[6], 2'b00, {brq_pkg_OPCODE_STORE}};
					3'b001, 3'b011, 3'b100, 3'b101, 3'b111: illegal_instr_o = 1'b1;
				endcase
			2'b01:
				case (instr_i[15:13])
					3'b000: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], instr_i[11:7], 3'b000, instr_i[11:7], {brq_pkg_OPCODE_OP_IMM}};
					3'b001, 3'b101: instr_o = {instr_i[12], instr_i[8], instr_i[10:9], instr_i[6], instr_i[7], instr_i[2], instr_i[11], instr_i[5:3], {9 {instr_i[12]}}, 4'b0000, ~instr_i[15], {brq_pkg_OPCODE_JAL}};
					3'b010: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 5'b00000, 3'b000, instr_i[11:7], {brq_pkg_OPCODE_OP_IMM}};
					3'b011: begin
						instr_o = {{15 {instr_i[12]}}, instr_i[6:2], instr_i[11:7], {brq_pkg_OPCODE_LUI}};
						if (instr_i[11:7] == 5'h02)
							instr_o = {{3 {instr_i[12]}}, instr_i[4:3], instr_i[5], instr_i[2], instr_i[6], 4'b0000, 5'h02, 3'b000, 5'h02, {brq_pkg_OPCODE_OP_IMM}};
						if ({instr_i[12], instr_i[6:2]} == 6'b000000)
							illegal_instr_o = 1'b1;
					end
					3'b100:
						case (instr_i[11:10])
							2'b00, 2'b01: begin
								instr_o = {1'b0, instr_i[10], 5'b00000, instr_i[6:2], 2'b01, instr_i[9:7], 3'b101, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP_IMM}};
								if (instr_i[12] == 1'b1)
									illegal_instr_o = 1'b1;
							end
							2'b10: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP_IMM}};
							2'b11:
								case ({instr_i[12], instr_i[6:5]})
									3'b000: instr_o = {9'b010000001, instr_i[4:2], 2'b01, instr_i[9:7], 3'b000, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP}};
									3'b001: instr_o = {9'b000000001, instr_i[4:2], 2'b01, instr_i[9:7], 3'b100, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP}};
									3'b010: instr_o = {9'b000000001, instr_i[4:2], 2'b01, instr_i[9:7], 3'b110, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP}};
									3'b011: instr_o = {9'b000000001, instr_i[4:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], {brq_pkg_OPCODE_OP}};
									3'b100, 3'b101, 3'b110, 3'b111: illegal_instr_o = 1'b1;
								endcase
						endcase
					3'b110, 3'b111: instr_o = {{4 {instr_i[12]}}, instr_i[6:5], instr_i[2], 5'b00000, 2'b01, instr_i[9:7], 2'b00, instr_i[13], instr_i[11:10], instr_i[4:3], instr_i[12], {brq_pkg_OPCODE_BRANCH}};
				endcase
			2'b10:
				case (instr_i[15:13])
					3'b000: begin
						instr_o = {7'b0000000, instr_i[6:2], instr_i[11:7], 3'b001, instr_i[11:7], {brq_pkg_OPCODE_OP_IMM}};
						if (instr_i[12] == 1'b1)
							illegal_instr_o = 1'b1;
					end
					3'b010: begin
						instr_o = {4'b0000, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b00, 5'h02, 3'b010, instr_i[11:7], brq_pkg_OPCODE_LOAD};
						if (instr_i[11:7] == 5'b00000)
							illegal_instr_o = 1'b1;
					end
					3'b100:
						if (instr_i[12] == 1'b0) begin
							if (instr_i[6:2] != 5'b00000)
								instr_o = {7'b0000000, instr_i[6:2], 5'b00000, 3'b000, instr_i[11:7], {brq_pkg_OPCODE_OP}};
							else begin
								instr_o = {12'b000000000000, instr_i[11:7], 3'b000, 5'b00000, {brq_pkg_OPCODE_JALR}};
								if (instr_i[11:7] == 5'b00000)
									illegal_instr_o = 1'b1;
							end
						end
						else if (instr_i[6:2] != 5'b00000)
							instr_o = {7'b0000000, instr_i[6:2], instr_i[11:7], 3'b000, instr_i[11:7], {brq_pkg_OPCODE_OP}};
						else if (instr_i[11:7] == 5'b00000)
							instr_o = 32'h00100073;
						else
							instr_o = {12'b000000000000, instr_i[11:7], 3'b000, 5'b00001, {brq_pkg_OPCODE_JALR}};
					3'b110: instr_o = {4'b0000, instr_i[8:7], instr_i[12], instr_i[6:2], 5'h02, 3'b010, instr_i[11:9], 2'b00, {brq_pkg_OPCODE_STORE}};
					3'b001, 3'b011, 3'b101, 3'b111: illegal_instr_o = 1'b1;
				endcase
			2'b11:
				;
		endcase
	end
	assign is_compressed_o = instr_i[1:0] != 2'b11;
endmodule
module brq_ifu_fifo (
	clk_i,
	rst_ni,
	clear_i,
	busy_o,
	in_valid_i,
	in_addr_i,
	in_rdata_i,
	in_err_i,
	out_valid_o,
	out_ready_i,
	out_addr_o,
	out_addr_next_o,
	out_rdata_o,
	out_err_o,
	out_err_plus2_o
);
	parameter [31:0] NUM_REQS = 2;
	input wire clk_i;
	input wire rst_ni;
	input wire clear_i;
	output wire [NUM_REQS - 1:0] busy_o;
	input wire in_valid_i;
	input wire [31:0] in_addr_i;
	input wire [31:0] in_rdata_i;
	input wire in_err_i;
	output reg out_valid_o;
	input wire out_ready_i;
	output wire [31:0] out_addr_o;
	output wire [31:0] out_addr_next_o;
	output reg [31:0] out_rdata_o;
	output reg out_err_o;
	output reg out_err_plus2_o;
	localparam [31:0] DEPTH = NUM_REQS + 1;
	wire [(DEPTH * 32) - 1:0] rdata_d;
	reg [(DEPTH * 32) - 1:0] rdata_q;
	wire [DEPTH - 1:0] err_d;
	reg [DEPTH - 1:0] err_q;
	wire [DEPTH - 1:0] valid_d;
	reg [DEPTH - 1:0] valid_q;
	wire [DEPTH - 1:0] lowest_free_entry;
	wire [DEPTH - 1:0] valid_pushed;
	wire [DEPTH - 1:0] valid_popped;
	wire [DEPTH - 1:0] entry_en;
	wire pop_fifo;
	wire [31:0] rdata;
	wire [31:0] rdata_unaligned;
	wire err;
	wire err_unaligned;
	wire err_plus2;
	wire valid;
	wire valid_unaligned;
	wire aligned_is_compressed;
	wire unaligned_is_compressed;
	wire addr_incr_two;
	wire [31:1] instr_addr_next;
	wire [31:1] instr_addr_d;
	reg [31:1] instr_addr_q;
	wire instr_addr_en;
	wire unused_addr_in;
	assign rdata = (valid_q[0] ? rdata_q[0+:32] : in_rdata_i);
	assign err = (valid_q[0] ? err_q[0] : in_err_i);
	assign valid = valid_q[0] | in_valid_i;
	assign rdata_unaligned = (valid_q[1] ? {rdata_q[47-:16], rdata[31:16]} : {in_rdata_i[15:0], rdata[31:16]});
	assign err_unaligned = (valid_q[1] ? (err_q[1] & ~unaligned_is_compressed) | err_q[0] : (valid_q[0] & err_q[0]) | (in_err_i & (~valid_q[0] | ~unaligned_is_compressed)));
	assign err_plus2 = (valid_q[1] ? err_q[1] & ~err_q[0] : (in_err_i & valid_q[0]) & ~err_q[0]);
	assign valid_unaligned = (valid_q[1] ? 1'b1 : valid_q[0] & in_valid_i);
	assign unaligned_is_compressed = (rdata[17:16] != 2'b11) & ~err;
	assign aligned_is_compressed = (rdata[1:0] != 2'b11) & ~err;
	always @(*)
		if (out_addr_o[1]) begin
			out_rdata_o = rdata_unaligned;
			out_err_o = err_unaligned;
			out_err_plus2_o = err_plus2;
			if (unaligned_is_compressed)
				out_valid_o = valid;
			else
				out_valid_o = valid_unaligned;
		end
		else begin
			out_rdata_o = rdata;
			out_err_o = err;
			out_err_plus2_o = 1'b0;
			out_valid_o = valid;
		end
	assign instr_addr_en = clear_i | (out_ready_i & out_valid_o);
	assign addr_incr_two = (instr_addr_q[1] ? unaligned_is_compressed : aligned_is_compressed);
	assign instr_addr_next = instr_addr_q[31:1] + {29'd0, ~addr_incr_two, addr_incr_two};
	assign instr_addr_d = (clear_i ? in_addr_i[31:1] : instr_addr_next);
	always @(posedge clk_i)
		if (~rst_ni)
			instr_addr_q <= {31 {1'sb0}};
		else if (instr_addr_en)
			instr_addr_q <= instr_addr_d;
	assign out_addr_next_o = {instr_addr_next, 1'b0};
	assign out_addr_o = {instr_addr_q, 1'b0};
	assign unused_addr_in = in_addr_i[0];
	assign busy_o = valid_q[DEPTH - 1:DEPTH - NUM_REQS];
	assign pop_fifo = (out_ready_i & out_valid_o) & (~aligned_is_compressed | out_addr_o[1]);
	generate
		genvar i;
		for (i = 0; i < (DEPTH - 1); i = i + 1) begin : g_fifo_next
			if (i == 0) begin : g_ent0
				assign lowest_free_entry[i] = ~valid_q[i];
			end
			else begin : g_ent_others
				assign lowest_free_entry[i] = ~valid_q[i] & valid_q[i - 1];
			end
			assign valid_pushed[i] = (in_valid_i & lowest_free_entry[i]) | valid_q[i];
			assign valid_popped[i] = (pop_fifo ? valid_pushed[i + 1] : valid_pushed[i]);
			assign valid_d[i] = valid_popped[i] & ~clear_i;
			assign entry_en[i] = (valid_pushed[i + 1] & pop_fifo) | ((in_valid_i & lowest_free_entry[i]) & ~pop_fifo);
			assign rdata_d[i * 32+:32] = (valid_q[i + 1] ? rdata_q[(i + 1) * 32+:32] : in_rdata_i);
			assign err_d[i] = (valid_q[i + 1] ? err_q[i + 1] : in_err_i);
		end
	endgenerate
	assign lowest_free_entry[DEPTH - 1] = ~valid_q[DEPTH - 1] & valid_q[DEPTH - 2];
	assign valid_pushed[DEPTH - 1] = valid_q[DEPTH - 1] | (in_valid_i & lowest_free_entry[DEPTH - 1]);
	assign valid_popped[DEPTH - 1] = (pop_fifo ? 1'b0 : valid_pushed[DEPTH - 1]);
	assign valid_d[DEPTH - 1] = valid_popped[DEPTH - 1] & ~clear_i;
	assign entry_en[DEPTH - 1] = in_valid_i & lowest_free_entry[DEPTH - 1];
	assign rdata_d[(DEPTH - 1) * 32+:32] = in_rdata_i;
	assign err_d[DEPTH - 1] = in_err_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			valid_q <= {DEPTH {1'sb0}};
		else
			valid_q <= valid_d;
	generate
		for (i = 0; i < DEPTH; i = i + 1) begin : g_fifo_regs
			always @(posedge clk_i)
				if (~rst_ni) begin
					rdata_q[i * 32+:32] <= {32 {1'sb0}};
					err_q[i] <= 1'b0;
				end
				else if (entry_en[i]) begin
					rdata_q[i * 32+:32] <= rdata_d[i * 32+:32];
					err_q[i] <= err_d[i];
				end
		end
	endgenerate
endmodule
module brq_ifu_prefetch_buffer (
	clk_i,
	rst_ni,
	req_i,
	branch_i,
	branch_spec_i,
	predicted_branch_i,
	addr_i,
	ready_i,
	valid_o,
	rdata_o,
	addr_o,
	err_o,
	err_plus2_o,
	instr_req_o,
	instr_gnt_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	instr_pmp_err_i,
	instr_rvalid_i,
	busy_o
);
	parameter [0:0] BranchPredictor = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire req_i;
	input wire branch_i;
	input wire branch_spec_i;
	input wire predicted_branch_i;
	input wire [31:0] addr_i;
	input wire ready_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire [31:0] addr_o;
	output wire err_o;
	output wire err_plus2_o;
	output wire instr_req_o;
	input wire instr_gnt_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	input wire instr_rvalid_i;
	output wire busy_o;
	wire branch_mispredict_i;
	assign branch_mispredict_i = 1'b0;
	localparam [31:0] NUM_REQS = 2;
	wire branch_suppress;
	wire valid_new_req;
	wire valid_req;
	wire valid_req_d;
	reg valid_req_q;
	wire discard_req_d;
	reg discard_req_q;
	wire gnt_or_pmp_err;
	wire rvalid_or_pmp_err;
	wire [1:0] rdata_outstanding_n;
	wire [1:0] rdata_outstanding_s;
	reg [1:0] rdata_outstanding_q;
	wire [1:0] branch_discard_n;
	wire [1:0] branch_discard_s;
	reg [1:0] branch_discard_q;
	wire [1:0] rdata_pmp_err_n;
	wire [1:0] rdata_pmp_err_s;
	reg [1:0] rdata_pmp_err_q;
	wire [1:0] rdata_outstanding_rev;
	wire [31:0] stored_addr_d;
	reg [31:0] stored_addr_q;
	wire stored_addr_en;
	wire [31:0] fetch_addr_d;
	reg [31:0] fetch_addr_q;
	wire fetch_addr_en;
	wire [31:0] branch_mispredict_addr;
	wire [31:0] instr_addr;
	wire [31:0] instr_addr_w_aligned;
	wire instr_or_pmp_err;
	wire fifo_valid;
	wire [31:0] fifo_addr;
	wire fifo_ready;
	wire fifo_clear;
	wire [1:0] fifo_busy;
	wire valid_raw;
	wire [31:0] addr_next;
	wire branch_or_mispredict;
	assign busy_o = |rdata_outstanding_q | instr_req_o;
	assign branch_or_mispredict = branch_i | branch_mispredict_i;
	assign instr_or_pmp_err = instr_err_i | rdata_pmp_err_q[0];
	assign fifo_clear = branch_or_mispredict;
	generate
		genvar i;
		for (i = 0; i < NUM_REQS; i = i + 1) begin : gen_rd_rev
			assign rdata_outstanding_rev[i] = rdata_outstanding_q[1 - i];
		end
	endgenerate
	assign fifo_ready = ~&(fifo_busy | rdata_outstanding_rev);
	brq_ifu_fifo #(.NUM_REQS(NUM_REQS)) fifo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(fifo_clear),
		.busy_o(fifo_busy),
		.in_valid_i(fifo_valid),
		.in_addr_i(fifo_addr),
		.in_rdata_i(instr_rdata_i),
		.in_err_i(instr_or_pmp_err),
		.out_valid_o(valid_raw),
		.out_ready_i(ready_i),
		.out_rdata_o(rdata_o),
		.out_addr_o(addr_o),
		.out_addr_next_o(addr_next),
		.out_err_o(err_o),
		.out_err_plus2_o(err_plus2_o)
	);
	assign branch_suppress = branch_spec_i & ~branch_i;
	assign valid_new_req = ((~branch_suppress & req_i) & (fifo_ready | branch_or_mispredict)) & ~rdata_outstanding_q[1];
	assign valid_req = valid_req_q | valid_new_req;
	assign gnt_or_pmp_err = instr_gnt_i | instr_pmp_err_i;
	assign rvalid_or_pmp_err = rdata_outstanding_q[0] & (instr_rvalid_i | rdata_pmp_err_q[0]);
	assign valid_req_d = valid_req & ~gnt_or_pmp_err;
	assign discard_req_d = valid_req_q & (branch_or_mispredict | discard_req_q);
	assign stored_addr_en = (valid_new_req & ~valid_req_q) & ~gnt_or_pmp_err;
	assign stored_addr_d = instr_addr;
	always @(posedge clk_i)
		if (~rst_ni)
			stored_addr_q <= {32 {1'sb0}};
		else if (stored_addr_en)
			stored_addr_q <= stored_addr_d;
	generate
		if (BranchPredictor) begin : g_branch_predictor
			reg [31:0] branch_mispredict_addr_q;
			wire branch_mispredict_addr_en;
			assign branch_mispredict_addr_en = branch_i & predicted_branch_i;
			always @(posedge clk_i)
				if (~rst_ni)
					branch_mispredict_addr_q <= {32 {1'sb0}};
				else if (branch_mispredict_addr_en)
					branch_mispredict_addr_q <= addr_next;
			assign branch_mispredict_addr = branch_mispredict_addr_q;
		end
		else begin : g_no_branch_predictor
			wire unused_predicted_branch;
			wire [31:0] unused_addr_next;
			assign unused_predicted_branch = predicted_branch_i;
			assign unused_addr_next = addr_next;
			assign branch_mispredict_addr = {32 {1'sb0}};
		end
	endgenerate
	assign fetch_addr_en = branch_or_mispredict | (valid_new_req & ~valid_req_q);
	assign fetch_addr_d = (branch_i ? addr_i : (branch_mispredict_i ? {branch_mispredict_addr[31:2], 2'b00} : {fetch_addr_q[31:2], 2'b00})) + {{29 {1'b0}}, valid_new_req & ~valid_req_q, 2'b00};
	always @(posedge clk_i)
		if (~rst_ni)
			fetch_addr_q <= {32 {1'sb0}};
		else if (fetch_addr_en)
			fetch_addr_q <= fetch_addr_d;
	assign instr_addr = (valid_req_q ? stored_addr_q : (branch_spec_i ? addr_i : (branch_mispredict_i ? branch_mispredict_addr : fetch_addr_q)));
	assign instr_addr_w_aligned = {instr_addr[31:2], 2'b00};
	generate
		for (i = 0; i < NUM_REQS; i = i + 1) begin : g_outstanding_reqs
			if (i == 0) begin : g_req0
				assign rdata_outstanding_n[i] = (valid_req & gnt_or_pmp_err) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = (((valid_req & gnt_or_pmp_err) & discard_req_d) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = ((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) | rdata_pmp_err_q[i];
			end
			else begin : g_reqtop
				assign rdata_outstanding_n[i] = ((valid_req & gnt_or_pmp_err) & rdata_outstanding_q[i - 1]) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = ((((valid_req & gnt_or_pmp_err) & discard_req_d) & rdata_outstanding_q[i - 1]) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = (((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) & rdata_outstanding_q[i - 1]) | rdata_pmp_err_q[i];
			end
		end
	endgenerate
	assign rdata_outstanding_s = (rvalid_or_pmp_err ? {1'b0, rdata_outstanding_n[1:1]} : rdata_outstanding_n);
	assign branch_discard_s = (rvalid_or_pmp_err ? {1'b0, branch_discard_n[1:1]} : branch_discard_n);
	assign rdata_pmp_err_s = (rvalid_or_pmp_err ? {1'b0, rdata_pmp_err_n[1:1]} : rdata_pmp_err_n);
	assign fifo_valid = rvalid_or_pmp_err & ~branch_discard_q[0];
	assign fifo_addr = (branch_i ? addr_i : branch_mispredict_addr);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			valid_req_q <= 1'b0;
			discard_req_q <= 1'b0;
			rdata_outstanding_q <= {2 {1'sb0}};
			branch_discard_q <= {2 {1'sb0}};
			rdata_pmp_err_q <= {2 {1'sb0}};
		end
		else begin
			valid_req_q <= valid_req_d;
			discard_req_q <= discard_req_d;
			rdata_outstanding_q <= rdata_outstanding_s;
			branch_discard_q <= branch_discard_s;
			rdata_pmp_err_q <= rdata_pmp_err_s;
		end
	assign instr_req_o = valid_req;
	assign instr_addr_o = instr_addr_w_aligned;
	assign valid_o = valid_raw & ~branch_mispredict_i;
endmodule
module brq_ifu (
	clk_i,
	rst_ni,
	boot_addr_i,
	req_i,
	instr_req_o,
	instr_addr_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_rdata_i,
	instr_err_i,
	instr_pmp_err_i,
	instr_valid_id_o,
	instr_new_id_o,
	instr_rdata_id_o,
	instr_rdata_alu_id_o,
	instr_rdata_c_id_o,
	instr_is_compressed_id_o,
	instr_fetch_err_o,
	instr_fetch_err_plus2_o,
	illegal_c_insn_id_o,
	pc_if_o,
	pc_id_o,
	instr_valid_clear_i,
	pc_set_i,
	pc_set_spec_i,
	pc_mux_i,
	exc_pc_mux_i,
	branch_target_ex_i,
	csr_mepc_i,
	csr_depc_i,
	csr_mtvec_i,
	csr_mtvec_init_o,
	id_in_ready_i,
	pc_mismatch_alert_o,
	if_busy_o
);
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	parameter [0:0] DummyInstructions = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] PCIncrCheck = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] boot_addr_i;
	input wire req_i;
	output wire instr_req_o;
	output wire [31:0] instr_addr_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	output wire instr_valid_id_o;
	output wire instr_new_id_o;
	output reg [31:0] instr_rdata_id_o;
	output reg [31:0] instr_rdata_alu_id_o;
	output reg [15:0] instr_rdata_c_id_o;
	output reg instr_is_compressed_id_o;
	output reg instr_fetch_err_o;
	output reg instr_fetch_err_plus2_o;
	output reg illegal_c_insn_id_o;
	output wire [31:0] pc_if_o;
	output reg [31:0] pc_id_o;
	input wire instr_valid_clear_i;
	input wire pc_set_i;
	input wire pc_set_spec_i;
	input wire [2:0] pc_mux_i;
	input wire [1:0] exc_pc_mux_i;
	input wire [31:0] branch_target_ex_i;
	input wire [31:0] csr_mepc_i;
	input wire [31:0] csr_depc_i;
	input wire [31:0] csr_mtvec_i;
	output wire csr_mtvec_init_o;
	input wire id_in_ready_i;
	output wire pc_mismatch_alert_o;
	output wire if_busy_o;
	wire instr_valid_id_d;
	reg instr_valid_id_q;
	wire instr_new_id_d;
	reg instr_new_id_q;
	wire prefetch_busy;
	wire branch_req;
	wire branch_spec;
	wire predicted_branch;
	reg [31:0] fetch_addr_n;
	wire fetch_valid;
	wire fetch_ready;
	wire [31:0] fetch_rdata;
	wire [31:0] fetch_addr;
	wire fetch_err;
	wire fetch_err_plus2;
	wire if_instr_valid;
	wire [31:0] if_instr_rdata;
	wire [31:0] if_instr_addr;
	wire if_instr_err;
	reg [31:0] exc_pc;
	wire if_id_pipe_reg_we;
	wire [31:0] instr_out;
	wire instr_is_compressed_out;
	wire illegal_c_instr_out;
	wire instr_err_out;
	wire predict_branch_taken;
	wire [31:0] predict_branch_pc;
	wire [2:0] pc_mux_internal;
	localparam [1:0] brq_pkg_EXC_PC_DBD = 2;
	localparam [1:0] brq_pkg_EXC_PC_DBG_EXC = 3;
	localparam [1:0] brq_pkg_EXC_PC_EXC = 0;
	localparam [1:0] brq_pkg_EXC_PC_IRQ = 1;
	always @(*) begin : exc_pc_mux
		case (exc_pc_mux_i)
			brq_pkg_EXC_PC_EXC: exc_pc = {csr_mtvec_i[31:2], 2'b00};
			brq_pkg_EXC_PC_IRQ: exc_pc = {csr_mtvec_i[31:2], 2'b00};
			brq_pkg_EXC_PC_DBD: exc_pc = DmHaltAddr;
			brq_pkg_EXC_PC_DBG_EXC: exc_pc = DmExceptionAddr;
		endcase
	end
	localparam [2:0] brq_pkg_PC_BP = 5;
	assign pc_mux_internal = ((BranchPredictor && predict_branch_taken) && !pc_set_i ? brq_pkg_PC_BP : pc_mux_i);
	localparam [2:0] brq_pkg_PC_BOOT = 0;
	localparam [2:0] brq_pkg_PC_DRET = 4;
	localparam [2:0] brq_pkg_PC_ERET = 3;
	localparam [2:0] brq_pkg_PC_EXC = 2;
	localparam [2:0] brq_pkg_PC_JUMP = 1;
	always @(*) begin : fetch_addr_mux
		case (pc_mux_internal)
			brq_pkg_PC_BOOT: fetch_addr_n = {boot_addr_i[31:2], 2'b00};
			brq_pkg_PC_JUMP: fetch_addr_n = branch_target_ex_i;
			brq_pkg_PC_EXC: fetch_addr_n = exc_pc;
			brq_pkg_PC_ERET: fetch_addr_n = csr_mepc_i;
			brq_pkg_PC_DRET: fetch_addr_n = csr_depc_i;
			brq_pkg_PC_BP: fetch_addr_n = (BranchPredictor ? predict_branch_pc : {boot_addr_i[31:2], 2'b00});
			default: fetch_addr_n = {boot_addr_i[31:2], 2'b00};
		endcase
	end
	assign csr_mtvec_init_o = (pc_mux_i == brq_pkg_PC_BOOT) & pc_set_i;
	brq_ifu_prefetch_buffer #(.BranchPredictor(BranchPredictor)) ifu_prefetch_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(req_i),
		.branch_i(branch_req),
		.branch_spec_i(branch_spec),
		.predicted_branch_i(predicted_branch),
		.addr_i({fetch_addr_n[31:1], 1'b0}),
		.ready_i(fetch_ready),
		.valid_o(fetch_valid),
		.rdata_o(fetch_rdata),
		.addr_o(fetch_addr),
		.err_o(fetch_err),
		.err_plus2_o(fetch_err_plus2),
		.instr_req_o(instr_req_o),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_i(instr_err_i),
		.instr_pmp_err_i(instr_pmp_err_i),
		.busy_o(prefetch_busy)
	);
	assign branch_req = pc_set_i | predict_branch_taken;
	assign branch_spec = pc_set_spec_i | predict_branch_taken;
	assign pc_if_o = if_instr_addr;
	assign if_busy_o = prefetch_busy;
	wire [31:0] instr_decompressed;
	wire illegal_c_insn;
	wire instr_is_compressed;
	brq_ifu_compressed_decoder ifu_compressed_decoder_i(
		.instr_i(if_instr_rdata),
		.instr_o(instr_decompressed),
		.is_compressed_o(instr_is_compressed),
		.illegal_instr_o(illegal_c_insn)
	);
	assign instr_out = instr_decompressed;
	assign instr_is_compressed_out = instr_is_compressed;
	assign illegal_c_instr_out = illegal_c_insn;
	assign instr_err_out = if_instr_err;
	assign instr_valid_id_d = ((if_instr_valid & id_in_ready_i) & ~pc_set_i) | (instr_valid_id_q & ~instr_valid_clear_i);
	assign instr_new_id_d = if_instr_valid & id_in_ready_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			instr_valid_id_q <= 1'b0;
			instr_new_id_q <= 1'b0;
		end
		else begin
			instr_valid_id_q <= instr_valid_id_d;
			instr_new_id_q <= instr_new_id_d;
		end
	assign instr_valid_id_o = instr_valid_id_q;
	assign instr_new_id_o = instr_new_id_q;
	assign if_id_pipe_reg_we = instr_new_id_d;
	always @(posedge clk_i)
		if (~rst_ni) begin
			instr_rdata_id_o <= {32 {1'sb0}};
			instr_rdata_alu_id_o <= {32 {1'sb0}};
			instr_fetch_err_o <= 1'b0;
			instr_fetch_err_plus2_o <= 1'b0;
			instr_rdata_c_id_o <= {16 {1'sb0}};
			instr_is_compressed_id_o <= 1'b0;
			illegal_c_insn_id_o <= 1'b0;
			pc_id_o <= {32 {1'sb0}};
		end
		else if (if_id_pipe_reg_we) begin
			instr_rdata_id_o <= instr_out;
			instr_rdata_alu_id_o <= instr_out;
			instr_fetch_err_o <= instr_err_out;
			instr_fetch_err_plus2_o <= fetch_err_plus2;
			instr_rdata_c_id_o <= if_instr_rdata[15:0];
			instr_is_compressed_id_o <= instr_is_compressed_out;
			illegal_c_insn_id_o <= illegal_c_instr_out;
			pc_id_o <= pc_if_o;
		end
	assign pc_mismatch_alert_o = 1'b0;
	assign predict_branch_taken = 1'b0;
	assign predicted_branch = 1'b0;
	assign predict_branch_pc = 32'b00000000000000000000000000000000;
	assign if_instr_valid = fetch_valid;
	assign if_instr_rdata = fetch_rdata;
	assign if_instr_addr = fetch_addr;
	assign if_instr_err = fetch_err;
	assign fetch_ready = id_in_ready_i;
endmodule
module brq_lsu (
	clk_i,
	rst_ni,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_err_i,
	data_pmp_err_i,
	data_addr_o,
	data_we_o,
	data_be_o,
	data_wdata_o,
	data_rdata_i,
	lsu_we_i,
	lsu_type_i,
	lsu_wdata_i,
	lsu_sign_ext_i,
	lsu_rdata_o,
	lsu_rdata_valid_o,
	lsu_req_i,
	adder_result_ex_i,
	addr_incr_req_o,
	addr_last_o,
	lsu_req_done_o,
	lsu_resp_valid_o,
	load_err_o,
	store_err_o,
	busy_o,
	perf_load_o,
	perf_store_o
);
	input wire clk_i;
	input wire rst_ni;
	output reg data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	input wire data_err_i;
	input wire data_pmp_err_i;
	output wire [31:0] data_addr_o;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire lsu_we_i;
	input wire [1:0] lsu_type_i;
	input wire [31:0] lsu_wdata_i;
	input wire lsu_sign_ext_i;
	output wire [31:0] lsu_rdata_o;
	output wire lsu_rdata_valid_o;
	input wire lsu_req_i;
	input wire [31:0] adder_result_ex_i;
	output reg addr_incr_req_o;
	output wire [31:0] addr_last_o;
	output wire lsu_req_done_o;
	output wire lsu_resp_valid_o;
	output wire load_err_o;
	output wire store_err_o;
	output wire busy_o;
	output reg perf_load_o;
	output reg perf_store_o;
	wire [31:0] data_addr;
	wire [31:0] data_addr_w_aligned;
	reg [31:0] addr_last_q;
	reg addr_update;
	reg ctrl_update;
	reg rdata_update;
	reg [31:8] rdata_q;
	reg [1:0] rdata_offset_q;
	reg [1:0] data_type_q;
	reg data_sign_ext_q;
	reg data_we_q;
	wire [1:0] data_offset;
	reg [3:0] data_be;
	reg [31:0] data_wdata;
	reg [31:0] data_rdata_ext;
	reg [31:0] rdata_w_ext;
	reg [31:0] rdata_h_ext;
	reg [31:0] rdata_b_ext;
	wire split_misaligned_access;
	reg handle_misaligned_q;
	reg handle_misaligned_d;
	reg pmp_err_q;
	reg pmp_err_d;
	reg lsu_err_q;
	reg lsu_err_d;
	wire data_or_pmp_err;
	reg [2:0] ls_fsm_cs;
	reg [2:0] ls_fsm_ns;
	assign data_addr = adder_result_ex_i;
	assign data_offset = data_addr[1:0];
	always @(*)
		case (lsu_type_i)
			2'b00:
				if (!handle_misaligned_q)
					case (data_offset)
						2'b00: data_be = 4'b1111;
						2'b01: data_be = 4'b1110;
						2'b10: data_be = 4'b1100;
						2'b11: data_be = 4'b1000;
					endcase
				else
					case (data_offset)
						2'b00: data_be = 4'b0000;
						2'b01: data_be = 4'b0001;
						2'b10: data_be = 4'b0011;
						2'b11: data_be = 4'b0111;
					endcase
			2'b01:
				if (!handle_misaligned_q)
					case (data_offset)
						2'b00: data_be = 4'b0011;
						2'b01: data_be = 4'b0110;
						2'b10: data_be = 4'b1100;
						2'b11: data_be = 4'b1000;
					endcase
				else
					data_be = 4'b0001;
			2'b10, 2'b11:
				case (data_offset)
					2'b00: data_be = 4'b0001;
					2'b01: data_be = 4'b0010;
					2'b10: data_be = 4'b0100;
					2'b11: data_be = 4'b1000;
				endcase
		endcase
	always @(*)
		case (data_offset)
			2'b00: data_wdata = lsu_wdata_i[31:0];
			2'b01: data_wdata = {lsu_wdata_i[23:0], lsu_wdata_i[31:24]};
			2'b10: data_wdata = {lsu_wdata_i[15:0], lsu_wdata_i[31:16]};
			2'b11: data_wdata = {lsu_wdata_i[7:0], lsu_wdata_i[31:8]};
		endcase
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rdata_q <= {24 {1'sb0}};
		else if (rdata_update)
			rdata_q <= data_rdata_i[31:8];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata_offset_q <= 2'h0;
			data_type_q <= 2'h0;
			data_sign_ext_q <= 1'b0;
			data_we_q <= 1'b0;
		end
		else if (ctrl_update) begin
			rdata_offset_q <= data_offset;
			data_type_q <= lsu_type_i;
			data_sign_ext_q <= lsu_sign_ext_i;
			data_we_q <= lsu_we_i;
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			addr_last_q <= {32 {1'sb0}};
		else if (addr_update)
			addr_last_q <= data_addr;
	always @(*)
		case (rdata_offset_q)
			2'b00: rdata_w_ext = data_rdata_i[31:0];
			2'b01: rdata_w_ext = {data_rdata_i[7:0], rdata_q[31:8]};
			2'b10: rdata_w_ext = {data_rdata_i[15:0], rdata_q[31:16]};
			2'b11: rdata_w_ext = {data_rdata_i[23:0], rdata_q[31:24]};
		endcase
	always @(*)
		case (rdata_offset_q)
			2'b00:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[15:0]};
				else
					rdata_h_ext = {{16 {data_rdata_i[15]}}, data_rdata_i[15:0]};
			2'b01:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[23:8]};
				else
					rdata_h_ext = {{16 {data_rdata_i[23]}}, data_rdata_i[23:8]};
			2'b10:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[31:16]};
				else
					rdata_h_ext = {{16 {data_rdata_i[31]}}, data_rdata_i[31:16]};
			2'b11:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[7:0], rdata_q[31:24]};
				else
					rdata_h_ext = {{16 {data_rdata_i[7]}}, data_rdata_i[7:0], rdata_q[31:24]};
		endcase
	always @(*)
		case (rdata_offset_q)
			2'b00:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[7:0]};
				else
					rdata_b_ext = {{24 {data_rdata_i[7]}}, data_rdata_i[7:0]};
			2'b01:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[15:8]};
				else
					rdata_b_ext = {{24 {data_rdata_i[15]}}, data_rdata_i[15:8]};
			2'b10:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[23:16]};
				else
					rdata_b_ext = {{24 {data_rdata_i[23]}}, data_rdata_i[23:16]};
			2'b11:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[31:24]};
				else
					rdata_b_ext = {{24 {data_rdata_i[31]}}, data_rdata_i[31:24]};
		endcase
	always @(*)
		case (data_type_q)
			2'b00: data_rdata_ext = rdata_w_ext;
			2'b01: data_rdata_ext = rdata_h_ext;
			2'b10, 2'b11: data_rdata_ext = rdata_b_ext;
		endcase
	assign split_misaligned_access = ((lsu_type_i == 2'b00) && (data_offset != 2'b00)) || ((lsu_type_i == 2'b01) && (data_offset == 2'b11));
	localparam [2:0] IDLE = 0;
	localparam [2:0] WAIT_GNT = 3;
	localparam [2:0] WAIT_GNT_MIS = 1;
	localparam [2:0] WAIT_RVALID_MIS = 2;
	localparam [2:0] WAIT_RVALID_MIS_GNTS_DONE = 4;
	always @(*) begin
		ls_fsm_ns = ls_fsm_cs;
		data_req_o = 1'b0;
		addr_incr_req_o = 1'b0;
		handle_misaligned_d = handle_misaligned_q;
		pmp_err_d = pmp_err_q;
		lsu_err_d = lsu_err_q;
		addr_update = 1'b0;
		ctrl_update = 1'b0;
		rdata_update = 1'b0;
		perf_load_o = 1'b0;
		perf_store_o = 1'b0;
		case (ls_fsm_cs)
			IDLE: begin
				pmp_err_d = 1'b0;
				if (lsu_req_i) begin
					data_req_o = 1'b1;
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = 1'b0;
					perf_load_o = ~lsu_we_i;
					perf_store_o = lsu_we_i;
					if (data_gnt_i) begin
						ctrl_update = 1'b1;
						addr_update = 1'b1;
						handle_misaligned_d = split_misaligned_access;
						ls_fsm_ns = (split_misaligned_access ? WAIT_RVALID_MIS : IDLE);
					end
					else
						ls_fsm_ns = (split_misaligned_access ? WAIT_GNT_MIS : WAIT_GNT);
				end
			end
			WAIT_GNT_MIS: begin
				data_req_o = 1'b1;
				if (data_gnt_i || pmp_err_q) begin
					addr_update = 1'b1;
					ctrl_update = 1'b1;
					handle_misaligned_d = 1'b1;
					ls_fsm_ns = WAIT_RVALID_MIS;
				end
			end
			WAIT_RVALID_MIS: begin
				data_req_o = 1'b1;
				addr_incr_req_o = 1'b1;
				if (data_rvalid_i || pmp_err_q) begin
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = data_err_i | pmp_err_q;
					rdata_update = ~data_we_q;
					ls_fsm_ns = (data_gnt_i ? IDLE : WAIT_GNT);
					addr_update = data_gnt_i & ~(data_err_i | pmp_err_q);
					handle_misaligned_d = ~data_gnt_i;
				end
				else if (data_gnt_i) begin
					ls_fsm_ns = WAIT_RVALID_MIS_GNTS_DONE;
					handle_misaligned_d = 1'b0;
				end
			end
			WAIT_GNT: begin
				addr_incr_req_o = handle_misaligned_q;
				data_req_o = 1'b1;
				if (data_gnt_i || pmp_err_q) begin
					ctrl_update = 1'b1;
					addr_update = ~lsu_err_q;
					ls_fsm_ns = IDLE;
					handle_misaligned_d = 1'b0;
				end
			end
			WAIT_RVALID_MIS_GNTS_DONE: begin
				addr_incr_req_o = 1'b1;
				if (data_rvalid_i) begin
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = data_err_i;
					addr_update = ~data_err_i;
					rdata_update = ~data_we_q;
					ls_fsm_ns = IDLE;
				end
			end
			default: ls_fsm_ns = IDLE;
		endcase
	end
	assign lsu_req_done_o = (lsu_req_i | (ls_fsm_cs != IDLE)) & (ls_fsm_ns == IDLE);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			ls_fsm_cs <= IDLE;
			handle_misaligned_q <= 1'b0;
			pmp_err_q <= 1'b0;
			lsu_err_q <= 1'b0;
		end
		else begin
			ls_fsm_cs <= ls_fsm_ns;
			handle_misaligned_q <= handle_misaligned_d;
			pmp_err_q <= pmp_err_d;
			lsu_err_q <= lsu_err_d;
		end
	assign data_or_pmp_err = (lsu_err_q | data_err_i) | pmp_err_q;
	assign lsu_resp_valid_o = (data_rvalid_i | pmp_err_q) & (ls_fsm_cs == IDLE);
	assign lsu_rdata_valid_o = (((ls_fsm_cs == IDLE) & data_rvalid_i) & ~data_or_pmp_err) & ~data_we_q;
	assign lsu_rdata_o = data_rdata_ext;
	assign data_addr_w_aligned = {data_addr[31:2], 2'b00};
	assign data_addr_o = data_addr_w_aligned;
	assign data_wdata_o = data_wdata;
	assign data_we_o = lsu_we_i;
	assign data_be_o = data_be;
	assign addr_last_o = addr_last_q;
	assign load_err_o = (data_or_pmp_err & ~data_we_q) & lsu_resp_valid_o;
	assign store_err_o = (data_or_pmp_err & data_we_q) & lsu_resp_valid_o;
	assign busy_o = ls_fsm_cs != IDLE;
endmodule
module brq_pmp (
	clk_i,
	rst_ni,
	csr_pmp_cfg_i,
	csr_pmp_addr_i,
	priv_mode_i,
	pmp_req_addr_i,
	pmp_req_type_i,
	pmp_req_err_o
);
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumChan = 2;
	parameter [31:0] PMPNumRegions = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg_i;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] priv_mode_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 34) + (((PMPNumChan - 1) * 34) - 1) : (PMPNumChan * 34) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 34 : 0)] pmp_req_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] pmp_req_type_i;
	output wire [0:PMPNumChan - 1] pmp_req_err_o;
	wire [33:0] region_start_addr [0:PMPNumRegions - 1];
	wire [33:PMPGranularity + 2] region_addr_mask [0:PMPNumRegions - 1];
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_gt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_lt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_eq;
	reg [(PMPNumChan * PMPNumRegions) - 1:0] region_match_all;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_perm_check;
	reg [PMPNumChan - 1:0] access_fault;
	localparam [1:0] brq_pkg_PMP_MODE_NAPOT = 2'b11;
	localparam [1:0] brq_pkg_PMP_MODE_TOR = 2'b01;
	generate
		genvar r;
		for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_addr_exp
			if (r == 0) begin : g_entry0
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == brq_pkg_PMP_MODE_TOR ? 34'h000000000 : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			else begin : g_oth
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == brq_pkg_PMP_MODE_TOR ? csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r - 1 : (PMPNumRegions - 1) - (r - 1)) * 34+:34] : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			genvar b;
			for (b = PMPGranularity + 2; b < 34; b = b + 1) begin : g_bitmask
				if (b == 2) begin : g_bit0
					assign region_addr_mask[r][b] = csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != brq_pkg_PMP_MODE_NAPOT;
				end
				else begin : g_others
					assign region_addr_mask[r][b] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != brq_pkg_PMP_MODE_NAPOT) | ~&csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + ((b - 1) >= (PMPGranularity + 1) ? b - 1 : ((b - 1) + ((b - 1) >= (PMPGranularity + 1) ? ((b - 1) - (PMPGranularity + 1)) + 1 : ((PMPGranularity + 1) - (b - 1)) + 1)) - 1)-:((b - 1) >= (PMPGranularity + 1) ? ((b - 1) - (PMPGranularity + 1)) + 1 : ((PMPGranularity + 1) - (b - 1)) + 1)];
				end
			end
		end
	endgenerate
	localparam [1:0] brq_pkg_PMP_ACC_EXEC = 2'b00;
	localparam [1:0] brq_pkg_PMP_ACC_READ = 2'b10;
	localparam [1:0] brq_pkg_PMP_ACC_WRITE = 2'b01;
	localparam [1:0] brq_pkg_PMP_MODE_NA4 = 2'b10;
	localparam [1:0] brq_pkg_PMP_MODE_OFF = 2'b00;
	localparam [1:0] brq_pkg_PRIV_LVL_M = 2'b11;
	generate
		genvar c;
		for (c = 0; c < PMPNumChan; c = c + 1) begin : g_access_check
			for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_regions
				assign region_match_eq[(c * PMPNumRegions) + r] = (pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] & region_addr_mask[r]) == (region_start_addr[r][33:PMPGranularity + 2] & region_addr_mask[r]);
				assign region_match_gt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] > region_start_addr[r][33:PMPGranularity + 2];
				assign region_match_lt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] < csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)];
				always @(*) begin
					region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					case (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2])
						brq_pkg_PMP_MODE_OFF: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
						brq_pkg_PMP_MODE_NA4: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						brq_pkg_PMP_MODE_NAPOT: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						brq_pkg_PMP_MODE_TOR: region_match_all[(c * PMPNumRegions) + r] = (region_match_eq[(c * PMPNumRegions) + r] | region_match_gt[(c * PMPNumRegions) + r]) & region_match_lt[(c * PMPNumRegions) + r];
						default: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					endcase
				end
				assign region_perm_check[(c * PMPNumRegions) + r] = (((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == brq_pkg_PMP_ACC_EXEC) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 2]) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == brq_pkg_PMP_ACC_WRITE) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 1])) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == brq_pkg_PMP_ACC_READ) & csr_pmp_cfg_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6]);
			end
			always @(*) begin
				access_fault[c] = priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] != brq_pkg_PRIV_LVL_M;
				begin : sv2v_autoblock_100
					reg signed [31:0] r;
					for (r = PMPNumRegions - 1; r >= 0; r = r - 1)
						if (region_match_all[(c * PMPNumRegions) + r])
							access_fault[c] = (priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == brq_pkg_PRIV_LVL_M ? csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 5] & ~region_perm_check[(c * PMPNumRegions) + r] : ~region_perm_check[(c * PMPNumRegions) + r]);
				end
			end
			assign pmp_req_err_o[c] = access_fault[c];
		end
	endgenerate
endmodule
module brq_register_file_ff (
	clk_i,
	rst_ni,
	dummy_instr_id_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i
);
	parameter [0:0] RV32E = 0;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] DummyInstructions = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire dummy_instr_id_i;
	input wire [4:0] raddr_a_i;
	output wire [DataWidth - 1:0] rdata_a_o;
	input wire [4:0] raddr_b_i;
	output wire [DataWidth - 1:0] rdata_b_o;
	input wire [4:0] waddr_a_i;
	input wire [DataWidth - 1:0] wdata_a_i;
	input wire we_a_i;
	localparam [31:0] ADDR_WIDTH = (RV32E ? 4 : 5);
	localparam [31:0] NUM_WORDS = 2 ** ADDR_WIDTH;
	wire [(NUM_WORDS * DataWidth) - 1:0] rf_reg;
	reg [((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) * DataWidth) + (DataWidth - 1) : ((3 - NUM_WORDS) * DataWidth) + (((NUM_WORDS - 1) * DataWidth) - 1)):((NUM_WORDS - 1) >= 1 ? DataWidth : (NUM_WORDS - 1) * DataWidth)] rf_reg_q;
	reg [NUM_WORDS - 1:1] we_a_dec;
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	always @(*) begin : we_a_decoder
		begin : sv2v_autoblock_101
			reg [31:0] i;
			for (i = 1; i < NUM_WORDS; i = i + 1)
				we_a_dec[i] = (waddr_a_i == sv2v_cast_5(i) ? we_a_i : 1'b0);
		end
	end
	generate
		genvar i;
		for (i = 1; i < NUM_WORDS; i = i + 1) begin : g_rf_flops
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rf_reg_q[((NUM_WORDS - 1) >= 1 ? i : 1 - (i - (NUM_WORDS - 1))) * DataWidth+:DataWidth] <= {DataWidth {1'sb0}};
				else if (we_a_dec[i])
					rf_reg_q[((NUM_WORDS - 1) >= 1 ? i : 1 - (i - (NUM_WORDS - 1))) * DataWidth+:DataWidth] <= wdata_a_i;
		end
	endgenerate
	generate
		if (DummyInstructions) begin : g_dummy_r0
			wire we_r0_dummy;
			reg [DataWidth - 1:0] rf_r0_q;
			assign we_r0_dummy = we_a_i & dummy_instr_id_i;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rf_r0_q <= {DataWidth {1'sb0}};
				else if (we_r0_dummy)
					rf_r0_q <= wdata_a_i;
			assign rf_reg[0+:DataWidth] = (dummy_instr_id_i ? rf_r0_q : {DataWidth {1'sb0}});
		end
		else begin : g_normal_r0
			wire unused_dummy_instr_id;
			assign unused_dummy_instr_id = dummy_instr_id_i;
			assign rf_reg[0+:DataWidth] = {DataWidth {1'sb0}};
		end
	endgenerate
	assign rf_reg[DataWidth * (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1))+:DataWidth * ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)] = rf_reg_q[DataWidth * ((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1) : ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1)) : 1 - (((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1) : ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1)) - (NUM_WORDS - 1)))+:DataWidth * ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)];
	assign rdata_a_o = rf_reg[raddr_a_i * DataWidth+:DataWidth];
	assign rdata_b_o = rf_reg[raddr_b_i * DataWidth+:DataWidth];
endmodule
module brq_wbu (
	clk_i,
	rst_ni,
	en_wb_i,
	instr_type_wb_i,
	pc_id_i,
	instr_is_compressed_id_i,
	instr_perf_count_id_i,
	ready_wb_o,
	rf_write_wb_o,
	outstanding_load_wb_o,
	outstanding_store_wb_o,
	pc_wb_o,
	perf_instr_ret_wb_o,
	perf_instr_ret_compressed_wb_o,
	rf_waddr_id_i,
	rf_wdata_id_i,
	rf_we_id_i,
	rf_wdata_lsu_i,
	rf_we_lsu_i,
	rf_wdata_fwd_wb_o,
	rf_waddr_wb_o,
	rf_wdata_wb_o,
	rf_we_wb_o,
	lsu_resp_valid_i,
	lsu_resp_err_i,
	instr_done_wb_o,
	fp_rf_write_wb_o,
	fp_rf_wen_wb_o,
	fp_rf_waddr_wb_o,
	fp_rf_waddr_id_i,
	fp_rf_wen_id_i,
	fp_rf_wdata_wb_o,
	fp_load_i
);
	parameter [0:0] WritebackStage = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire en_wb_i;
	input wire [1:0] instr_type_wb_i;
	input wire [31:0] pc_id_i;
	input wire instr_is_compressed_id_i;
	input wire instr_perf_count_id_i;
	output wire ready_wb_o;
	output wire rf_write_wb_o;
	output wire outstanding_load_wb_o;
	output wire outstanding_store_wb_o;
	output wire [31:0] pc_wb_o;
	output wire perf_instr_ret_wb_o;
	output wire perf_instr_ret_compressed_wb_o;
	input wire [4:0] rf_waddr_id_i;
	input wire [31:0] rf_wdata_id_i;
	input wire rf_we_id_i;
	input wire [31:0] rf_wdata_lsu_i;
	input wire rf_we_lsu_i;
	output wire [31:0] rf_wdata_fwd_wb_o;
	output wire [4:0] rf_waddr_wb_o;
	output wire [31:0] rf_wdata_wb_o;
	output wire rf_we_wb_o;
	input wire lsu_resp_valid_i;
	input wire lsu_resp_err_i;
	output wire instr_done_wb_o;
	output wire fp_rf_write_wb_o;
	output wire fp_rf_wen_wb_o;
	output wire [4:0] fp_rf_waddr_wb_o;
	input wire [4:0] fp_rf_waddr_id_i;
	input wire fp_rf_wen_id_i;
	output wire [31:0] fp_rf_wdata_wb_o;
	input wire fp_load_i;
	wire [31:0] rf_wdata_wb_mux [0:1];
	wire [1:0] rf_wdata_wb_mux_we;
	wire [31:0] fp_rf_wdata_wb_mux [0:1];
	wire [1:0] fp_rf_wdata_wb_mux_we;
	localparam [1:0] brq_pkg_WB_INSTR_LOAD = 0;
	localparam [1:0] brq_pkg_WB_INSTR_OTHER = 2;
	localparam [1:0] brq_pkg_WB_INSTR_STORE = 1;
	generate
		if (WritebackStage) begin : g_writeback_stage
			reg [31:0] rf_wdata_wb_q;
			reg rf_we_wb_q;
			reg [4:0] rf_waddr_wb_q;
			wire wb_done;
			reg wb_valid_q;
			reg [31:0] wb_pc_q;
			reg wb_compressed_q;
			reg wb_count_q;
			reg [1:0] wb_instr_type_q;
			wire wb_valid_d;
			reg fp_rf_we_wb_q;
			reg fp_load_q;
			assign wb_valid_d = (en_wb_i & ready_wb_o) | (wb_valid_q & ~wb_done);
			assign wb_done = (wb_instr_type_q == brq_pkg_WB_INSTR_OTHER) | lsu_resp_valid_i;
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni)
					wb_valid_q <= 1'b0;
				else
					wb_valid_q <= wb_valid_d;
			always @(posedge clk_i)
				if (~rst_ni) begin
					rf_we_wb_q <= 1'b0;
					rf_waddr_wb_q <= {5 {1'sb0}};
					rf_wdata_wb_q <= {32 {1'sb0}};
					wb_instr_type_q <= {2 {1'sb0}};
					wb_pc_q <= {32 {1'sb0}};
					wb_compressed_q <= 1'b0;
					wb_count_q <= 1'b0;
					fp_rf_we_wb_q <= 1'b0;
					fp_load_q <= 1'b0;
				end
				else if (en_wb_i) begin
					rf_we_wb_q <= rf_we_id_i;
					rf_waddr_wb_q <= rf_waddr_id_i;
					rf_wdata_wb_q <= rf_wdata_id_i;
					wb_instr_type_q <= instr_type_wb_i;
					wb_pc_q <= pc_id_i;
					wb_compressed_q <= instr_is_compressed_id_i;
					wb_count_q <= instr_perf_count_id_i;
					fp_rf_we_wb_q <= fp_rf_wen_id_i;
					fp_load_q <= fp_load_i;
				end
			assign rf_waddr_wb_o = rf_waddr_wb_q;
			assign rf_wdata_wb_mux[0] = rf_wdata_wb_q;
			assign rf_wdata_wb_mux_we[0] = rf_we_wb_q & wb_valid_q;
			assign fp_rf_waddr_wb_o = rf_waddr_wb_q;
			assign fp_rf_wdata_wb_mux[0] = rf_wdata_wb_q;
			assign fp_rf_wdata_wb_mux_we[0] = fp_rf_we_wb_q & wb_valid_q;
			assign ready_wb_o = ~wb_valid_q | wb_done;
			assign rf_write_wb_o = wb_valid_q & (rf_we_wb_q | (wb_instr_type_q == brq_pkg_WB_INSTR_LOAD));
			assign fp_rf_write_wb_o = wb_valid_q & (fp_rf_we_wb_q | (wb_instr_type_q == brq_pkg_WB_INSTR_LOAD));
			assign outstanding_load_wb_o = wb_valid_q & (wb_instr_type_q == brq_pkg_WB_INSTR_LOAD);
			assign outstanding_store_wb_o = wb_valid_q & (wb_instr_type_q == brq_pkg_WB_INSTR_STORE);
			assign pc_wb_o = wb_pc_q;
			assign instr_done_wb_o = wb_valid_q & wb_done;
			assign perf_instr_ret_wb_o = (instr_done_wb_o & wb_count_q) & ~(lsu_resp_valid_i & lsu_resp_err_i);
			assign perf_instr_ret_compressed_wb_o = perf_instr_ret_wb_o & wb_compressed_q;
			assign rf_wdata_fwd_wb_o = rf_wdata_wb_q;
			assign rf_wdata_wb_mux[1] = rf_wdata_lsu_i;
			assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i & ~fp_load_q;
			assign fp_rf_wdata_wb_mux[1] = rf_wdata_lsu_i;
			assign fp_rf_wdata_wb_mux_we[1] = rf_we_lsu_i & fp_load_q;
		end
		else begin : g_bypass_wb
			assign rf_waddr_wb_o = rf_waddr_id_i;
			assign rf_wdata_wb_mux[0] = rf_wdata_id_i;
			assign rf_wdata_wb_mux_we[0] = rf_we_id_i;
			assign fp_rf_waddr_wb_o = rf_waddr_id_i;
			assign fp_rf_wdata_wb_mux[0] = rf_wdata_id_i;
			assign fp_rf_wdata_wb_mux_we[0] = fp_rf_wen_id_i;
			assign perf_instr_ret_wb_o = (instr_perf_count_id_i & en_wb_i) & ~(lsu_resp_valid_i & lsu_resp_err_i);
			assign perf_instr_ret_compressed_wb_o = perf_instr_ret_wb_o & instr_is_compressed_id_i;
			assign ready_wb_o = 1'b1;
			wire unused_clk;
			wire unused_rst;
			wire [1:0] unused_instr_type_wb;
			wire [31:0] unused_pc_id;
			assign unused_clk = clk_i;
			assign unused_rst = rst_ni;
			assign unused_instr_type_wb = instr_type_wb_i;
			assign unused_pc_id = pc_id_i;
			assign outstanding_load_wb_o = 1'b0;
			assign outstanding_store_wb_o = 1'b0;
			assign pc_wb_o = {32 {1'sb0}};
			assign rf_write_wb_o = 1'b0;
			assign rf_wdata_fwd_wb_o = 32'b00000000000000000000000000000000;
			assign instr_done_wb_o = 1'b0;
			assign rf_wdata_wb_mux[1] = rf_wdata_lsu_i;
			assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i & ~fp_load_i;
			assign fp_rf_wdata_wb_mux[1] = rf_wdata_lsu_i;
			assign fp_rf_wdata_wb_mux_we[1] = rf_we_lsu_i & fp_load_i;
		end
	endgenerate
	assign rf_wdata_wb_o = (rf_wdata_wb_mux_we[0] ? rf_wdata_wb_mux[0] : rf_wdata_wb_mux[1]);
	assign rf_we_wb_o = |rf_wdata_wb_mux_we;
	assign fp_rf_wdata_wb_o = (fp_rf_wdata_wb_mux_we[0] ? fp_rf_wdata_wb_mux[0] : fp_rf_wdata_wb_mux[1]);
	assign fp_rf_wen_wb_o = |fp_rf_wdata_wb_mux_we;
endmodule
module control_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Start_SI,
	Kill_SI,
	Special_case_SBI,
	Special_case_dly_SBI,
	Precision_ctl_SI,
	Format_sel_SI,
	Numerator_DI,
	Exp_num_DI,
	Denominator_DI,
	Exp_den_DI,
	Div_start_dly_SO,
	Sqrt_start_dly_SO,
	Div_enable_SO,
	Sqrt_enable_SO,
	Full_precision_SO,
	FP32_SO,
	FP64_SO,
	FP16_SO,
	FP16ALT_SO,
	Ready_SO,
	Done_SO,
	Mant_result_prenorm_DO,
	Exp_result_prenorm_DO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Start_SI;
	input wire Kill_SI;
	input wire Special_case_SBI;
	input wire Special_case_dly_SBI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	input wire [1:0] Format_sel_SI;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Numerator_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_num_DI;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Denominator_DI;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_den_DI;
	output wire Div_start_dly_SO;
	output wire Sqrt_start_dly_SO;
	output reg Div_enable_SO;
	output reg Sqrt_enable_SO;
	output wire Full_precision_SO;
	output wire FP32_SO;
	output wire FP64_SO;
	output wire FP16_SO;
	output wire FP16ALT_SO;
	output reg Ready_SO;
	output reg Done_SO;
	output reg [56:0] Mant_result_prenorm_DO;
	output wire [12:0] Exp_result_prenorm_DO;
	reg [57:0] Partial_remainder_DN;
	reg [57:0] Partial_remainder_DP;
	reg [56:0] Quotient_DP;
	wire [53:0] Numerator_se_D;
	wire [53:0] Denominator_se_D;
	reg [53:0] Denominator_se_DB;
	assign Numerator_se_D = {1'b0, Numerator_DI};
	assign Denominator_se_D = {1'b0, Denominator_DI};
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	always @(*)
		if (FP32_SO)
			Denominator_se_DB = {~Denominator_se_D[53:29], {29 {1'b0}}};
		else if (FP64_SO)
			Denominator_se_DB = ~Denominator_se_D;
		else if (FP16_SO)
			Denominator_se_DB = {~Denominator_se_D[53:42], {42 {1'b0}}};
		else
			Denominator_se_DB = {~Denominator_se_D[53:45], {45 {1'b0}}};
	wire [53:0] Mant_D_sqrt_Norm;
	assign Mant_D_sqrt_Norm = (Exp_num_DI[0] ? {1'b0, Numerator_DI} : {Numerator_DI, 1'b0});
	reg [1:0] Format_sel_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Format_sel_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Format_sel_S <= Format_sel_SI;
		else
			Format_sel_S <= Format_sel_S;
	assign FP32_SO = Format_sel_S == 2'b00;
	assign FP64_SO = Format_sel_S == 2'b01;
	assign FP16_SO = Format_sel_S == 2'b10;
	assign FP16ALT_SO = Format_sel_S == 2'b11;
	reg [5:0] Precision_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Precision_ctl_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Precision_ctl_S <= Precision_ctl_SI;
		else
			Precision_ctl_S <= Precision_ctl_S;
	assign Full_precision_SO = Precision_ctl_S == 6'h00;
	reg [5:0] State_ctl_S;
	wire [5:0] State_Two_iteration_unit_S;
	wire [5:0] State_Four_iteration_unit_S;
	assign State_Two_iteration_unit_S = Precision_ctl_S[5:1];
	assign State_Four_iteration_unit_S = Precision_ctl_S[5:2];
	localparam defs_div_sqrt_mvp_Iteration_unit_num_S = 2'b10;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = Precision_ctl_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h38;
						else
							State_ctl_S = Precision_ctl_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h0e;
						else
							State_ctl_S = Precision_ctl_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h0b;
						else
							State_ctl_S = Precision_ctl_S;
				endcase
			2'b01:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h05;
						else
							State_ctl_S = State_Two_iteration_unit_S;
				endcase
			2'b10:
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h08;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							default: State_ctl_S = 6'h08;
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h12;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							6'h18, 6'h19, 6'h1a: State_ctl_S = 6'h08;
							6'h1b, 6'h1c, 6'h1d: State_ctl_S = 6'h09;
							6'h1e, 6'h1f, 6'h20: State_ctl_S = 6'h0a;
							6'h21, 6'h22, 6'h23: State_ctl_S = 6'h0b;
							6'h24, 6'h25, 6'h26: State_ctl_S = 6'h0c;
							6'h27, 6'h28, 6'h29: State_ctl_S = 6'h0d;
							6'h2a, 6'h2b, 6'h2c: State_ctl_S = 6'h0e;
							6'h2d, 6'h2e, 6'h2f: State_ctl_S = 6'h0f;
							6'h30, 6'h31, 6'h32: State_ctl_S = 6'h10;
							6'h33, 6'h34, 6'h35: State_ctl_S = 6'h11;
							default: State_ctl_S = 6'h12;
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h04;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							default: State_ctl_S = 6'h04;
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h03;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							default: State_ctl_S = 6'h03;
						endcase
				endcase
			2'b11:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h03;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h02;
						else
							State_ctl_S = State_Four_iteration_unit_S;
				endcase
		endcase
	reg Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_start_dly_S <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_start_dly_S <= 1'b1;
		else
			Div_start_dly_S <= 1'b0;
	assign Div_start_dly_SO = Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_enable_SO <= 1'b0;
		else if (Kill_SI)
			Div_enable_SO <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_enable_SO <= 1'b1;
		else if (Done_SO)
			Div_enable_SO <= 1'b0;
		else
			Div_enable_SO <= Div_enable_SO;
	reg Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_start_dly_S <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_start_dly_S <= 1'b1;
		else
			Sqrt_start_dly_S <= 1'b0;
	assign Sqrt_start_dly_SO = Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_enable_SO <= 1'b0;
		else if (Kill_SI)
			Sqrt_enable_SO <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_enable_SO <= 1'b1;
		else if (Done_SO)
			Sqrt_enable_SO <= 1'b0;
		else
			Sqrt_enable_SO <= Sqrt_enable_SO;
	reg [5:0] Crtl_cnt_S;
	wire Start_dly_S;
	assign Start_dly_S = Div_start_dly_S | Sqrt_start_dly_S;
	wire Fsm_enable_S;
	assign Fsm_enable_S = ((Start_dly_S | |Crtl_cnt_S) && ~Kill_SI) && Special_case_dly_SBI;
	wire Final_state_S;
	assign Final_state_S = Crtl_cnt_S == State_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Crtl_cnt_S <= {6 {1'sb0}};
		else if (Final_state_S | Kill_SI)
			Crtl_cnt_S <= {6 {1'sb0}};
		else if (Fsm_enable_S)
			Crtl_cnt_S <= Crtl_cnt_S + 1;
		else
			Crtl_cnt_S <= {6 {1'sb0}};
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Done_SO <= 1'b0;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Done_SO <= 1'b1;
			else
				Done_SO <= 1'b0;
		end
		else if (Final_state_S)
			Done_SO <= 1'b1;
		else
			Done_SO <= 1'b0;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Ready_SO <= 1'b1;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Ready_SO <= 1'b1;
			else
				Ready_SO <= 1'b0;
		end
		else if (Final_state_S | Kill_SI)
			Ready_SO <= 1'b1;
		else
			Ready_SO <= Ready_SO;
	wire Qcnt_one_0;
	wire Qcnt_one_1;
	wire [1:0] Qcnt_one_2;
	wire [2:0] Qcnt_one_3;
	wire [3:0] Qcnt_one_4;
	wire [4:0] Qcnt_one_5;
	wire [5:0] Qcnt_one_6;
	wire [6:0] Qcnt_one_7;
	wire [7:0] Qcnt_one_8;
	wire [8:0] Qcnt_one_9;
	wire [9:0] Qcnt_one_10;
	wire [10:0] Qcnt_one_11;
	wire [11:0] Qcnt_one_12;
	wire [12:0] Qcnt_one_13;
	wire [13:0] Qcnt_one_14;
	wire [14:0] Qcnt_one_15;
	wire [15:0] Qcnt_one_16;
	wire [16:0] Qcnt_one_17;
	wire [17:0] Qcnt_one_18;
	wire [18:0] Qcnt_one_19;
	wire [19:0] Qcnt_one_20;
	wire [20:0] Qcnt_one_21;
	wire [21:0] Qcnt_one_22;
	wire [22:0] Qcnt_one_23;
	wire [23:0] Qcnt_one_24;
	wire [24:0] Qcnt_one_25;
	wire [25:0] Qcnt_one_26;
	wire [26:0] Qcnt_one_27;
	wire [27:0] Qcnt_one_28;
	wire [28:0] Qcnt_one_29;
	wire [29:0] Qcnt_one_30;
	wire [30:0] Qcnt_one_31;
	wire [31:0] Qcnt_one_32;
	wire [32:0] Qcnt_one_33;
	wire [33:0] Qcnt_one_34;
	wire [34:0] Qcnt_one_35;
	wire [35:0] Qcnt_one_36;
	wire [36:0] Qcnt_one_37;
	wire [37:0] Qcnt_one_38;
	wire [38:0] Qcnt_one_39;
	wire [39:0] Qcnt_one_40;
	wire [40:0] Qcnt_one_41;
	wire [41:0] Qcnt_one_42;
	wire [42:0] Qcnt_one_43;
	wire [43:0] Qcnt_one_44;
	wire [44:0] Qcnt_one_45;
	wire [45:0] Qcnt_one_46;
	wire [46:0] Qcnt_one_47;
	wire [47:0] Qcnt_one_48;
	wire [48:0] Qcnt_one_49;
	wire [49:0] Qcnt_one_50;
	wire [50:0] Qcnt_one_51;
	wire [51:0] Qcnt_one_52;
	wire [52:0] Qcnt_one_53;
	wire [53:0] Qcnt_one_54;
	wire [54:0] Qcnt_one_55;
	wire [55:0] Qcnt_one_56;
	wire [56:0] Qcnt_one_57;
	wire [57:0] Qcnt_one_58;
	wire [58:0] Qcnt_one_59;
	wire [59:0] Qcnt_one_60;
	wire [1:0] Qcnt_two_0;
	wire [2:0] Qcnt_two_1;
	wire [4:0] Qcnt_two_2;
	wire [6:0] Qcnt_two_3;
	wire [8:0] Qcnt_two_4;
	wire [10:0] Qcnt_two_5;
	wire [12:0] Qcnt_two_6;
	wire [14:0] Qcnt_two_7;
	wire [16:0] Qcnt_two_8;
	wire [18:0] Qcnt_two_9;
	wire [20:0] Qcnt_two_10;
	wire [22:0] Qcnt_two_11;
	wire [24:0] Qcnt_two_12;
	wire [26:0] Qcnt_two_13;
	wire [28:0] Qcnt_two_14;
	wire [30:0] Qcnt_two_15;
	wire [32:0] Qcnt_two_16;
	wire [34:0] Qcnt_two_17;
	wire [36:0] Qcnt_two_18;
	wire [38:0] Qcnt_two_19;
	wire [40:0] Qcnt_two_20;
	wire [42:0] Qcnt_two_21;
	wire [44:0] Qcnt_two_22;
	wire [46:0] Qcnt_two_23;
	wire [48:0] Qcnt_two_24;
	wire [50:0] Qcnt_two_25;
	wire [52:0] Qcnt_two_26;
	wire [54:0] Qcnt_two_27;
	wire [56:0] Qcnt_two_28;
	wire [2:0] Qcnt_three_0;
	wire [4:0] Qcnt_three_1;
	wire [7:0] Qcnt_three_2;
	wire [10:0] Qcnt_three_3;
	wire [13:0] Qcnt_three_4;
	wire [16:0] Qcnt_three_5;
	wire [19:0] Qcnt_three_6;
	wire [22:0] Qcnt_three_7;
	wire [25:0] Qcnt_three_8;
	wire [28:0] Qcnt_three_9;
	wire [31:0] Qcnt_three_10;
	wire [34:0] Qcnt_three_11;
	wire [37:0] Qcnt_three_12;
	wire [40:0] Qcnt_three_13;
	wire [43:0] Qcnt_three_14;
	wire [46:0] Qcnt_three_15;
	wire [49:0] Qcnt_three_16;
	wire [52:0] Qcnt_three_17;
	wire [55:0] Qcnt_three_18;
	wire [58:0] Qcnt_three_19;
	wire [61:0] Qcnt_three_20;
	wire [3:0] Qcnt_four_0;
	wire [6:0] Qcnt_four_1;
	wire [10:0] Qcnt_four_2;
	wire [14:0] Qcnt_four_3;
	wire [18:0] Qcnt_four_4;
	wire [22:0] Qcnt_four_5;
	wire [26:0] Qcnt_four_6;
	wire [30:0] Qcnt_four_7;
	wire [34:0] Qcnt_four_8;
	wire [38:0] Qcnt_four_9;
	wire [42:0] Qcnt_four_10;
	wire [46:0] Qcnt_four_11;
	wire [50:0] Qcnt_four_12;
	wire [54:0] Qcnt_four_13;
	wire [58:0] Qcnt_four_14;
	wire [57:0] Sqrt_R0;
	reg [57:0] Sqrt_Q0;
	reg [57:0] Q_sqrt0;
	reg [57:0] Q_sqrt_com_0;
	wire [57:0] Sqrt_R1;
	reg [57:0] Sqrt_Q1;
	reg [57:0] Q_sqrt1;
	reg [57:0] Q_sqrt_com_1;
	wire [57:0] Sqrt_R2;
	reg [57:0] Sqrt_Q2;
	reg [57:0] Q_sqrt2;
	reg [57:0] Q_sqrt_com_2;
	wire [57:0] Sqrt_R3;
	reg [57:0] Sqrt_Q3;
	reg [57:0] Q_sqrt3;
	reg [57:0] Q_sqrt_com_3;
	wire [57:0] Sqrt_R4;
	reg [1:0] Sqrt_DI [3:0];
	wire [1:0] Sqrt_DO [3:0];
	wire Sqrt_carry_DO;
	wire [57:0] Iteration_cell_a_D [3:0];
	wire [57:0] Iteration_cell_b_D [3:0];
	wire [57:0] Iteration_cell_a_BMASK_D [3:0];
	wire [57:0] Iteration_cell_b_BMASK_D [3:0];
	wire Iteration_cell_carry_D [3:0];
	wire [57:0] Iteration_cell_sum_D [3:0];
	wire [57:0] Iteration_cell_sum_AMASK_D [3:0];
	reg [3:0] Sqrt_quotinent_S;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][28], ~Iteration_cell_sum_AMASK_D[1][28], ~Iteration_cell_sum_AMASK_D[2][28], ~Iteration_cell_sum_AMASK_D[3][28]};
				Q_sqrt_com_0 = {{29 {1'b0}}, ~Q_sqrt0[28:0]};
				Q_sqrt_com_1 = {{29 {1'b0}}, ~Q_sqrt1[28:0]};
				Q_sqrt_com_2 = {{29 {1'b0}}, ~Q_sqrt2[28:0]};
				Q_sqrt_com_3 = {{29 {1'b0}}, ~Q_sqrt3[28:0]};
			end
			2'b01: begin
				Sqrt_quotinent_S = {Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]};
				Q_sqrt_com_0 = ~Q_sqrt0;
				Q_sqrt_com_1 = ~Q_sqrt1;
				Q_sqrt_com_2 = ~Q_sqrt2;
				Q_sqrt_com_3 = ~Q_sqrt3;
			end
			2'b10: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][15], ~Iteration_cell_sum_AMASK_D[1][15], ~Iteration_cell_sum_AMASK_D[2][15], ~Iteration_cell_sum_AMASK_D[3][15]};
				Q_sqrt_com_0 = {{42 {1'b0}}, ~Q_sqrt0[15:0]};
				Q_sqrt_com_1 = {{42 {1'b0}}, ~Q_sqrt1[15:0]};
				Q_sqrt_com_2 = {{42 {1'b0}}, ~Q_sqrt2[15:0]};
				Q_sqrt_com_3 = {{42 {1'b0}}, ~Q_sqrt3[15:0]};
			end
			2'b11: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][12], ~Iteration_cell_sum_AMASK_D[1][12], ~Iteration_cell_sum_AMASK_D[2][12], ~Iteration_cell_sum_AMASK_D[3][12]};
				Q_sqrt_com_0 = {{45 {1'b0}}, ~Q_sqrt0[12:0]};
				Q_sqrt_com_1 = {{45 {1'b0}}, ~Q_sqrt1[12:0]};
				Q_sqrt_com_2 = {{45 {1'b0}}, ~Q_sqrt2[12:0]};
				Q_sqrt_com_3 = {{45 {1'b0}}, ~Q_sqrt3[12:0]};
			end
		endcase
	assign Qcnt_one_0 = 1'b0;
	assign Qcnt_one_1 = {Quotient_DP[0]};
	assign Qcnt_one_2 = {Quotient_DP[1:0]};
	assign Qcnt_one_3 = {Quotient_DP[2:0]};
	assign Qcnt_one_4 = {Quotient_DP[3:0]};
	assign Qcnt_one_5 = {Quotient_DP[4:0]};
	assign Qcnt_one_6 = {Quotient_DP[5:0]};
	assign Qcnt_one_7 = {Quotient_DP[6:0]};
	assign Qcnt_one_8 = {Quotient_DP[7:0]};
	assign Qcnt_one_9 = {Quotient_DP[8:0]};
	assign Qcnt_one_10 = {Quotient_DP[9:0]};
	assign Qcnt_one_11 = {Quotient_DP[10:0]};
	assign Qcnt_one_12 = {Quotient_DP[11:0]};
	assign Qcnt_one_13 = {Quotient_DP[12:0]};
	assign Qcnt_one_14 = {Quotient_DP[13:0]};
	assign Qcnt_one_15 = {Quotient_DP[14:0]};
	assign Qcnt_one_16 = {Quotient_DP[15:0]};
	assign Qcnt_one_17 = {Quotient_DP[16:0]};
	assign Qcnt_one_18 = {Quotient_DP[17:0]};
	assign Qcnt_one_19 = {Quotient_DP[18:0]};
	assign Qcnt_one_20 = {Quotient_DP[19:0]};
	assign Qcnt_one_21 = {Quotient_DP[20:0]};
	assign Qcnt_one_22 = {Quotient_DP[21:0]};
	assign Qcnt_one_23 = {Quotient_DP[22:0]};
	assign Qcnt_one_24 = {Quotient_DP[23:0]};
	assign Qcnt_one_25 = {Quotient_DP[24:0]};
	assign Qcnt_one_26 = {Quotient_DP[25:0]};
	assign Qcnt_one_27 = {Quotient_DP[26:0]};
	assign Qcnt_one_28 = {Quotient_DP[27:0]};
	assign Qcnt_one_29 = {Quotient_DP[28:0]};
	assign Qcnt_one_30 = {Quotient_DP[29:0]};
	assign Qcnt_one_31 = {Quotient_DP[30:0]};
	assign Qcnt_one_32 = {Quotient_DP[31:0]};
	assign Qcnt_one_33 = {Quotient_DP[32:0]};
	assign Qcnt_one_34 = {Quotient_DP[33:0]};
	assign Qcnt_one_35 = {Quotient_DP[34:0]};
	assign Qcnt_one_36 = {Quotient_DP[35:0]};
	assign Qcnt_one_37 = {Quotient_DP[36:0]};
	assign Qcnt_one_38 = {Quotient_DP[37:0]};
	assign Qcnt_one_39 = {Quotient_DP[38:0]};
	assign Qcnt_one_40 = {Quotient_DP[39:0]};
	assign Qcnt_one_41 = {Quotient_DP[40:0]};
	assign Qcnt_one_42 = {Quotient_DP[41:0]};
	assign Qcnt_one_43 = {Quotient_DP[42:0]};
	assign Qcnt_one_44 = {Quotient_DP[43:0]};
	assign Qcnt_one_45 = {Quotient_DP[44:0]};
	assign Qcnt_one_46 = {Quotient_DP[45:0]};
	assign Qcnt_one_47 = {Quotient_DP[46:0]};
	assign Qcnt_one_48 = {Quotient_DP[47:0]};
	assign Qcnt_one_49 = {Quotient_DP[48:0]};
	assign Qcnt_one_50 = {Quotient_DP[49:0]};
	assign Qcnt_one_51 = {Quotient_DP[50:0]};
	assign Qcnt_one_52 = {Quotient_DP[51:0]};
	assign Qcnt_one_53 = {Quotient_DP[52:0]};
	assign Qcnt_one_54 = {Quotient_DP[53:0]};
	assign Qcnt_one_55 = {Quotient_DP[54:0]};
	assign Qcnt_one_56 = {Quotient_DP[55:0]};
	assign Qcnt_one_57 = {Quotient_DP[56:0]};
	assign Qcnt_two_0 = {1'b0, Sqrt_quotinent_S[3]};
	assign Qcnt_two_1 = {Quotient_DP[1:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_2 = {Quotient_DP[3:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_3 = {Quotient_DP[5:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_4 = {Quotient_DP[7:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_5 = {Quotient_DP[9:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_6 = {Quotient_DP[11:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_7 = {Quotient_DP[13:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_8 = {Quotient_DP[15:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_9 = {Quotient_DP[17:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_10 = {Quotient_DP[19:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_11 = {Quotient_DP[21:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_12 = {Quotient_DP[23:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_13 = {Quotient_DP[25:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_14 = {Quotient_DP[27:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_15 = {Quotient_DP[29:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_16 = {Quotient_DP[31:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_17 = {Quotient_DP[33:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_18 = {Quotient_DP[35:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_19 = {Quotient_DP[37:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_20 = {Quotient_DP[39:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_21 = {Quotient_DP[41:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_22 = {Quotient_DP[43:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_23 = {Quotient_DP[45:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_24 = {Quotient_DP[47:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_25 = {Quotient_DP[49:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_26 = {Quotient_DP[51:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_27 = {Quotient_DP[53:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_28 = {Quotient_DP[55:0], Sqrt_quotinent_S[3]};
	assign Qcnt_three_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_1 = {Quotient_DP[2:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_2 = {Quotient_DP[5:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_3 = {Quotient_DP[8:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_4 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_5 = {Quotient_DP[14:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_6 = {Quotient_DP[17:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_7 = {Quotient_DP[20:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_8 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_9 = {Quotient_DP[26:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_10 = {Quotient_DP[29:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_11 = {Quotient_DP[32:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_12 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_13 = {Quotient_DP[38:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_14 = {Quotient_DP[41:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_15 = {Quotient_DP[44:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_16 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_17 = {Quotient_DP[50:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_18 = {Quotient_DP[53:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_19 = {Quotient_DP[56:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_four_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_1 = {Quotient_DP[3:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_2 = {Quotient_DP[7:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_3 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_4 = {Quotient_DP[15:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_5 = {Quotient_DP[19:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_6 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_7 = {Quotient_DP[27:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_8 = {Quotient_DP[31:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_9 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_10 = {Quotient_DP[39:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_11 = {Quotient_DP[43:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_12 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_13 = {Quotient_DP[51:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_14 = {Quotient_DP[55:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_0};
						Sqrt_Q0 = Q_sqrt_com_0;
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_1};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_one_2};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{55 {1'b0}}, Qcnt_one_3};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_one_4};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_one_5};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_one_6};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_one_7};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_one_8};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_one_9};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_one_10};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt0 = {{47 {1'b0}}, Qcnt_one_11};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_one_12};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_one_13};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_one_14};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{43 {1'b0}}, Qcnt_one_15};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_one_16};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_one_17};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_one_18};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_one_19};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_one_20};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_one_21};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_one_22};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt0 = {{35 {1'b0}}, Qcnt_one_23};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_one_24};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_one_25};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_one_26};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{31 {1'b0}}, Qcnt_one_27};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_one_28};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_one_29};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_one_30};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_one_31};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_one_32};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_one_33};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_one_34};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{23 {1'b0}}, Qcnt_one_35};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_one_36};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_one_37};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_one_38};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{19 {1'b0}}, Qcnt_one_39};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_one_40};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_one_41};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_one_42};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_one_43};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_one_44};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_one_45};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_one_46};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{11 {1'b0}}, Qcnt_one_47};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_one_48};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_one_49};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_one_50};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{7 {1'b0}}, Qcnt_one_51};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_one_52};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_one_53};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_one_54};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_one_55};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b111000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_one_56};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					default: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {58 {1'sb0}};
						Sqrt_Q0 = {58 {1'sb0}};
					end
				endcase
			2'b01:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_two_1[2:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt1 = {{55 {1'b0}}, Qcnt_two_1[2:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_two_2[4:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_two_2[4:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_two_3[6:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{51 {1'b0}}, Qcnt_two_3[6:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_two_4[8:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{49 {1'b0}}, Qcnt_two_4[8:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_two_5[10:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_two_5[10:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_two_6[12:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{45 {1'b0}}, Qcnt_two_6[12:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_two_7[14:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt1 = {{43 {1'b0}}, Qcnt_two_7[14:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_two_8[16:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_two_8[16:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_two_9[18:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{39 {1'b0}}, Qcnt_two_9[18:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_two_10[20:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{37 {1'b0}}, Qcnt_two_10[20:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_two_11[22:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_two_11[22:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_two_12[24:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{33 {1'b0}}, Qcnt_two_12[24:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_two_13[26:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{31 {1'b0}}, Qcnt_two_13[26:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_two_14[28:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_two_14[28:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_two_15[30:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{27 {1'b0}}, Qcnt_two_15[30:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_two_16[32:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{25 {1'b0}}, Qcnt_two_16[32:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_two_17[34:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_two_17[34:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_two_18[36:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{21 {1'b0}}, Qcnt_two_18[36:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_two_19[38:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{19 {1'b0}}, Qcnt_two_19[38:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_two_20[40:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_two_20[40:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_two_21[42:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{15 {1'b0}}, Qcnt_two_21[42:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_two_22[44:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{13 {1'b0}}, Qcnt_two_22[44:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_two_23[46:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_two_23[46:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_two_24[48:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{9 {1'b0}}, Qcnt_two_24[48:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_two_25[50:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{7 {1'b0}}, Qcnt_two_25[50:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_two_26[52:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_two_26[52:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_two_27[54:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{3 {1'b0}}, Qcnt_two_27[54:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_two_28[56:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {1'b0, Qcnt_two_28[56:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
				endcase
			2'b10:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_three_1[4:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_three_1[4:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt2 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_three_1[4:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_three_2[7:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{50 {1'b0}}, Qcnt_three_2[7:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt2 = {{49 {1'b0}}, Qcnt_three_2[7:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_three_3[10:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_three_3[10:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt2 = {{46 {1'b0}}, Qcnt_three_3[10:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_three_4[13:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_three_4[13:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_three_4[13:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_three_5[16:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_three_5[16:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt2 = {{40 {1'b0}}, Qcnt_three_5[16:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_three_6[19:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{38 {1'b0}}, Qcnt_three_6[19:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt2 = {{37 {1'b0}}, Qcnt_three_6[19:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_three_7[22:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_three_7[22:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt2 = {{34 {1'b0}}, Qcnt_three_7[22:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_three_8[25:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_three_8[25:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_three_8[25:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_three_9[28:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_three_9[28:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{28 {1'b0}}, Qcnt_three_9[28:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_three_10[31:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{26 {1'b0}}, Qcnt_three_10[31:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{25 {1'b0}}, Qcnt_three_10[31:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_three_11[34:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_three_11[34:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{22 {1'b0}}, Qcnt_three_11[34:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_three_12[37:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_three_12[37:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_three_12[37:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_three_13[40:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_three_13[40:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{16 {1'b0}}, Qcnt_three_13[40:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_three_14[43:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{14 {1'b0}}, Qcnt_three_14[43:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{13 {1'b0}}, Qcnt_three_14[43:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_three_15[46:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_three_15[46:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{10 {1'b0}}, Qcnt_three_15[46:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_three_16[49:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_three_16[49:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_three_16[49:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_three_17[52:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_three_17[52:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{4 {1'b0}}, Qcnt_three_17[52:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_three_18[55:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{2 {1'b0}}, Qcnt_three_18[55:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {1'b0, Qcnt_three_18[55:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
				endcase
			2'b11:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_four_1[6:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_four_1[6:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt2 = {{51 {1'b0}}, Qcnt_four_1[6:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt3 = {{50 {1'b0}}, Qcnt_four_1[6:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_four_2[10:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{48 {1'b0}}, Qcnt_four_2[10:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt2 = {{47 {1'b0}}, Qcnt_four_2[10:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt3 = {{46 {1'b0}}, Qcnt_four_2[10:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_four_3[14:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_four_3[14:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_four_3[14:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt3 = {{42 {1'b0}}, Qcnt_four_3[14:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_four_4[18:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{40 {1'b0}}, Qcnt_four_4[18:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt2 = {{39 {1'b0}}, Qcnt_four_4[18:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt3 = {{38 {1'b0}}, Qcnt_four_4[18:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_four_5[22:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{36 {1'b0}}, Qcnt_four_5[22:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt2 = {{35 {1'b0}}, Qcnt_four_5[22:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt3 = {{34 {1'b0}}, Qcnt_four_5[22:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_four_6[26:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_four_6[26:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_four_6[26:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{30 {1'b0}}, Qcnt_four_6[26:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_four_7[30:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{28 {1'b0}}, Qcnt_four_7[30:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{27 {1'b0}}, Qcnt_four_7[30:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{26 {1'b0}}, Qcnt_four_7[30:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_four_8[34:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{24 {1'b0}}, Qcnt_four_8[34:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{23 {1'b0}}, Qcnt_four_8[34:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{22 {1'b0}}, Qcnt_four_8[34:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_four_9[38:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_four_9[38:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_four_9[38:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{18 {1'b0}}, Qcnt_four_9[38:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_four_10[42:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{16 {1'b0}}, Qcnt_four_10[42:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{15 {1'b0}}, Qcnt_four_10[42:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{14 {1'b0}}, Qcnt_four_10[42:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_four_11[46:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{12 {1'b0}}, Qcnt_four_11[46:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{11 {1'b0}}, Qcnt_four_11[46:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{10 {1'b0}}, Qcnt_four_11[46:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_four_12[50:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_four_12[50:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_four_12[50:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{6 {1'b0}}, Qcnt_four_12[50:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_four_13[54:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{4 {1'b0}}, Qcnt_four_13[54:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{3 {1'b0}}, Qcnt_four_13[54:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{2 {1'b0}}, Qcnt_four_13[54:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
				endcase
		endcase
	assign Sqrt_R0 = (Sqrt_start_dly_S ? {58 {1'sb0}} : {Partial_remainder_DP[57:0]});
	assign Sqrt_R1 = {Iteration_cell_sum_AMASK_D[0][57], Iteration_cell_sum_AMASK_D[0][54:0], Sqrt_DO[0]};
	assign Sqrt_R2 = {Iteration_cell_sum_AMASK_D[1][57], Iteration_cell_sum_AMASK_D[1][54:0], Sqrt_DO[1]};
	assign Sqrt_R3 = {Iteration_cell_sum_AMASK_D[2][57], Iteration_cell_sum_AMASK_D[2][54:0], Sqrt_DO[2]};
	assign Sqrt_R4 = {Iteration_cell_sum_AMASK_D[3][57], Iteration_cell_sum_AMASK_D[3][54:0], Sqrt_DO[3]};
	wire [57:0] Denominator_se_format_DB;
	assign Denominator_se_format_DB = {Denominator_se_DB[53:45], {(FP16ALT_SO ? FP16ALT_SO : Denominator_se_DB[44])}, Denominator_se_DB[43:42], {(FP16_SO ? FP16_SO : Denominator_se_DB[41])}, Denominator_se_DB[40:29], {(FP32_SO ? FP32_SO : Denominator_se_DB[28])}, Denominator_se_DB[27:0], FP64_SO, 3'b000};
	wire [57:0] First_iteration_cell_div_a_D;
	wire [57:0] First_iteration_cell_div_b_D;
	wire Sel_b_for_first_S;
	assign First_iteration_cell_div_a_D = (Div_start_dly_S ? {Numerator_se_D[53:45], {(FP16ALT_SO ? FP16ALT_SO : Numerator_se_D[44])}, Numerator_se_D[43:42], {(FP16_SO ? FP16_SO : Numerator_se_D[41])}, Numerator_se_D[40:29], {(FP32_SO ? FP32_SO : Numerator_se_D[28])}, Numerator_se_D[27:0], FP64_SO, 3'b000} : {Partial_remainder_DP[56:48], {(FP16ALT_SO ? Quotient_DP[0] : Partial_remainder_DP[47])}, Partial_remainder_DP[46:45], {(FP16_SO ? Quotient_DP[0] : Partial_remainder_DP[44])}, Partial_remainder_DP[43:32], {(FP32_SO ? Quotient_DP[0] : Partial_remainder_DP[31])}, Partial_remainder_DP[30:3], FP64_SO && Quotient_DP[0], 3'b000});
	assign Sel_b_for_first_S = (Div_start_dly_S ? 1 : Quotient_DP[0]);
	assign First_iteration_cell_div_b_D = (Sel_b_for_first_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
	assign Iteration_cell_a_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_R0 : {First_iteration_cell_div_a_D});
	assign Iteration_cell_b_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_Q0 : {First_iteration_cell_div_b_D});
	wire [57:0] Sec_iteration_cell_div_a_D;
	wire [57:0] Sec_iteration_cell_div_b_D;
	wire Sel_b_for_sec_S;
	generate
		if (|defs_div_sqrt_mvp_Iteration_unit_num_S) begin
			assign Sel_b_for_sec_S = ~Iteration_cell_sum_AMASK_D[0][57];
			assign Sec_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[0][56:48], {(FP16ALT_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][47])}, Iteration_cell_sum_AMASK_D[0][46:45], {(FP16_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][44])}, Iteration_cell_sum_AMASK_D[0][43:32], {(FP32_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][31])}, Iteration_cell_sum_AMASK_D[0][30:3], FP64_SO && Sel_b_for_sec_S, 3'b000};
			assign Sec_iteration_cell_div_b_D = (Sel_b_for_sec_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_R1 : {Sec_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_Q1 : {Sec_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Thi_iteration_cell_div_a_D;
	wire [57:0] Thi_iteration_cell_div_b_D;
	wire Sel_b_for_thi_S;
	generate
		if ((defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b10) | (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11)) begin
			assign Sel_b_for_thi_S = ~Iteration_cell_sum_AMASK_D[1][57];
			assign Thi_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[1][56:48], {(FP16ALT_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][47])}, Iteration_cell_sum_AMASK_D[1][46:45], {(FP16_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][44])}, Iteration_cell_sum_AMASK_D[1][43:32], {(FP32_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][31])}, Iteration_cell_sum_AMASK_D[1][30:3], FP64_SO && Sel_b_for_thi_S, 3'b000};
			assign Thi_iteration_cell_div_b_D = (Sel_b_for_thi_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_R2 : {Thi_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_Q2 : {Thi_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Fou_iteration_cell_div_a_D;
	wire [57:0] Fou_iteration_cell_div_b_D;
	wire Sel_b_for_fou_S;
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11) begin
			assign Sel_b_for_fou_S = ~Iteration_cell_sum_AMASK_D[2][57];
			assign Fou_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[2][56:48], {(FP16ALT_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][47])}, Iteration_cell_sum_AMASK_D[2][46:45], {(FP16_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][44])}, Iteration_cell_sum_AMASK_D[2][43:32], {(FP32_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][31])}, Iteration_cell_sum_AMASK_D[2][30:3], FP64_SO && Sel_b_for_fou_S, 3'b000};
			assign Fou_iteration_cell_div_b_D = (Sel_b_for_fou_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[3] = (Sqrt_enable_SO ? Sqrt_R3 : {Fou_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[3] = (Sqrt_enable_SO ? Sqrt_Q3 : {Fou_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Mask_bits_ctl_S;
	assign Mask_bits_ctl_S = 58'h3ffffffffffffff;
	wire Div_enable_SI [3:0];
	wire Div_start_dly_SI [3:0];
	wire Sqrt_enable_SI [3:0];
	generate
		genvar i;
		genvar j;
		for (i = 0; i <= defs_div_sqrt_mvp_Iteration_unit_num_S; i = i + 1) begin
			for (j = 0; j <= 57; j = j + 1) begin
				assign Iteration_cell_a_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_a_BMASK_D[i][j];
				assign Iteration_cell_b_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_b_BMASK_D[i][j];
				assign Iteration_cell_sum_AMASK_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_sum_D[i][j];
			end
			assign Div_enable_SI[i] = Div_enable_SO;
			assign Div_start_dly_SI[i] = Div_start_dly_S;
			assign Sqrt_enable_SI[i] = Sqrt_enable_SO;
			iteration_div_sqrt_mvp #(.WIDTH(58)) iteration_div_sqrt(
				.A_DI(Iteration_cell_a_D[i]),
				.B_DI(Iteration_cell_b_D[i]),
				.Div_enable_SI(Div_enable_SI[i]),
				.Div_start_dly_SI(Div_start_dly_SI[i]),
				.Sqrt_enable_SI(Sqrt_enable_SI[i]),
				.D_DI(Sqrt_DI[i]),
				.D_DO(Sqrt_DO[i]),
				.Sum_DO(Iteration_cell_sum_D[i]),
				.Carry_out_DO(Iteration_cell_carry_D[i])
			);
		end
	endgenerate
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R1 : Iteration_cell_sum_AMASK_D[0]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b01:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R2 : Iteration_cell_sum_AMASK_D[1]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b10:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R3 : Iteration_cell_sum_AMASK_D[2]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b11:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R4 : Iteration_cell_sum_AMASK_D[3]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Partial_remainder_DP <= {58 {1'sb0}};
		else
			Partial_remainder_DP <= Partial_remainder_DN;
	reg [56:0] Quotient_DN;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[55:0], Sqrt_quotinent_S[3]} : {Quotient_DP[55:0], Iteration_cell_carry_D[0]});
				else
					Quotient_DN = Quotient_DP;
			2'b01:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[54:0], Sqrt_quotinent_S[3:2]} : {Quotient_DP[54:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1]});
				else
					Quotient_DN = Quotient_DP;
			2'b10:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[53:0], Sqrt_quotinent_S[3:1]} : {Quotient_DP[53:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2]});
				else
					Quotient_DN = Quotient_DP;
			2'b11:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Sqrt_quotinent_S} : {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]});
				else
					Quotient_DN = Quotient_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Quotient_DP <= {57 {1'sb0}};
		else
			Quotient_DP <= Quotient_DN;
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b00) always @(*)
			case (Format_sel_S)
				2'b00:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h17: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
						6'h16: Mant_result_prenorm_DO = {Quotient_DP[22:0], {34 {1'b0}}};
						6'h15: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
						6'h14: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
						6'h13: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h12: Mant_result_prenorm_DO = {Quotient_DP[18:0], {38 {1'b0}}};
						6'h11: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h10: Mant_result_prenorm_DO = {Quotient_DP[16:0], {40 {1'b0}}};
						6'h0f: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0e: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0d: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
						6'h0c: Mant_result_prenorm_DO = {Quotient_DP[12:0], {44 {1'b0}}};
						6'h0b: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h0a: Mant_result_prenorm_DO = {Quotient_DP[10:0], {46 {1'b0}}};
						6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
					endcase
				2'b01:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = Quotient_DP[56:0];
						6'h34: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], {4 {1'b0}}};
						6'h33: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
						6'h32: Mant_result_prenorm_DO = {Quotient_DP[50:0], {6 {1'b0}}};
						6'h31: Mant_result_prenorm_DO = {Quotient_DP[49:0], {7 {1'b0}}};
						6'h30: Mant_result_prenorm_DO = {Quotient_DP[48:0], {8 {1'b0}}};
						6'h2f: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
						6'h2e: Mant_result_prenorm_DO = {Quotient_DP[46:0], {10 {1'b0}}};
						6'h2d: Mant_result_prenorm_DO = {Quotient_DP[45:0], {11 {1'b0}}};
						6'h2c: Mant_result_prenorm_DO = {Quotient_DP[44:0], {12 {1'b0}}};
						6'h2b: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
						6'h2a: Mant_result_prenorm_DO = {Quotient_DP[42:0], {14 {1'b0}}};
						6'h29: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
						6'h28: Mant_result_prenorm_DO = {Quotient_DP[40:0], {16 {1'b0}}};
						6'h27: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
						6'h26: Mant_result_prenorm_DO = {Quotient_DP[38:0], {18 {1'b0}}};
						6'h25: Mant_result_prenorm_DO = {Quotient_DP[37:0], {19 {1'b0}}};
						6'h24: Mant_result_prenorm_DO = {Quotient_DP[36:0], {20 {1'b0}}};
						6'h23: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
						6'h22: Mant_result_prenorm_DO = {Quotient_DP[34:0], {22 {1'b0}}};
						6'h21: Mant_result_prenorm_DO = {Quotient_DP[33:0], {23 {1'b0}}};
						6'h20: Mant_result_prenorm_DO = {Quotient_DP[32:0], {24 {1'b0}}};
						6'h1f: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
						6'h1e: Mant_result_prenorm_DO = {Quotient_DP[30:0], {26 {1'b0}}};
						6'h1d: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
						6'h1c: Mant_result_prenorm_DO = {Quotient_DP[28:0], {28 {1'b0}}};
						6'h1b: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h1a: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
						6'h19: Mant_result_prenorm_DO = {Quotient_DP[25:0], {31 {1'b0}}};
						6'h18: Mant_result_prenorm_DO = {Quotient_DP[24:0], {32 {1'b0}}};
						6'h17: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
						6'h16: Mant_result_prenorm_DO = {Quotient_DP[22:0], {34 {1'b0}}};
						6'h15: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
						6'h14: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
						6'h13: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h12: Mant_result_prenorm_DO = {Quotient_DP[18:0], {38 {1'b0}}};
						6'h11: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h10: Mant_result_prenorm_DO = {Quotient_DP[16:0], {40 {1'b0}}};
						6'h0f: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0e: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0d: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
						6'h0c: Mant_result_prenorm_DO = {Quotient_DP[12:0], {44 {1'b0}}};
						6'h0b: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h0a: Mant_result_prenorm_DO = {Quotient_DP[10:0], {46 {1'b0}}};
						6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = Quotient_DP[56:0];
					endcase
				2'b10:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0a: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16:0], {46 {1'b0}}};
						6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
					endcase
				2'b11:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
					endcase
			endcase
	endgenerate
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b01) always @(*)
			case (Format_sel_S)
				2'b00:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h17, 6'h16: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
						6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
						6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h0f, 6'h0e: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
						6'h0b, 6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
					endcase
				2'b01:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
						6'h34: Mant_result_prenorm_DO = {Quotient_DP[53:1], {4 {1'b0}}};
						6'h33, 6'h32: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
						6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[49:0], {7 {1'b0}}};
						6'h2f, 6'h2e: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
						6'h2d, 6'h2c: Mant_result_prenorm_DO = {Quotient_DP[45:0], {11 {1'b0}}};
						6'h2b, 6'h2a: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
						6'h29, 6'h28: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
						6'h27, 6'h26: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
						6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[37:0], {19 {1'b0}}};
						6'h23, 6'h22: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
						6'h21, 6'h20: Mant_result_prenorm_DO = {Quotient_DP[33:0], {23 {1'b0}}};
						6'h1f, 6'h1e: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
						6'h1d, 6'h1c: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
						6'h1b, 6'h1a: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[25:0], {31 {1'b0}}};
						6'h17, 6'h16: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
						6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
						6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h0f, 6'h0e: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
						6'h0b, 6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
					endcase
				2'b10:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
						6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
						6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
					endcase
				2'b11:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
					endcase
			endcase
	endgenerate
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b10) always @(*)
			case (Format_sel_S)
				2'b00:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
						6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
						6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
						6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
					endcase
				2'b01:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = Quotient_DP[56:0];
						6'h34, 6'h33: Mant_result_prenorm_DO = {Quotient_DP[53:1], {4 {1'b0}}};
						6'h32, 6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[50:0], {6 {1'b0}}};
						6'h2f, 6'h2e, 6'h2d: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
						6'h2c, 6'h2b, 6'h2a: Mant_result_prenorm_DO = {Quotient_DP[44:0], {12 {1'b0}}};
						6'h29, 6'h28, 6'h27: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
						6'h26, 6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[38:0], {18 {1'b0}}};
						6'h23, 6'h22, 6'h21: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
						6'h20, 6'h1f, 6'h1e: Mant_result_prenorm_DO = {Quotient_DP[32:0], {24 {1'b0}}};
						6'h1d, 6'h1c, 6'h1b: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
						6'h1a, 6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
						6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
						6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
						6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
						6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						default: Mant_result_prenorm_DO = Quotient_DP[56:0];
					endcase
				2'b10:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
						6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
					endcase
				2'b11:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:1], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
					endcase
			endcase
	endgenerate
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11) always @(*)
			case (Format_sel_S)
				2'b00:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h17, 6'h16, 6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
						6'h13, 6'h12, 6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h0f, 6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0b, 6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
					endcase
				2'b01:
					case (Precision_ctl_S)
						6'h00: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
						6'h34: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
						6'h33, 6'h32, 6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
						6'h2f, 6'h2e, 6'h2d, 6'h2c: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
						6'h2b, 6'h2a, 6'h29, 6'h28: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
						6'h27, 6'h26, 6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
						6'h23, 6'h22, 6'h21, 6'h20: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
						6'h1f, 6'h1e, 6'h1d, 6'h1c: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
						6'h1b, 6'h1a, 6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						6'h17, 6'h16, 6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
						6'h13, 6'h12, 6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
						6'h0f, 6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0b, 6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
					endcase
				2'b10:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
					endcase
				2'b11:
					case (Precision_ctl_S)
						6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
						default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
					endcase
			endcase
	endgenerate
	wire [12:0] Exp_result_prenorm_DN;
	reg [12:0] Exp_result_prenorm_DP;
	wire [12:0] Exp_add_a_D;
	wire [12:0] Exp_add_b_D;
	wire [12:0] Exp_add_c_D;
	integer C_BIAS_AONE;
	integer C_HALF_BIAS;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16 = 5'h10;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP32 = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP64 = 11'h400;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16 = 7;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP32 = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP64 = 511;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP32;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP32;
			end
			2'b01: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP64;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP64;
			end
			2'b10: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16;
			end
			2'b11: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT;
			end
		endcase
	assign Exp_add_a_D = {(Sqrt_start_dly_S ? {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64:1]} : {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI})};
	localparam defs_div_sqrt_mvp_C_EXP_ZERO_FP64 = 11'h000;
	assign Exp_add_b_D = {(Sqrt_start_dly_S ? {1'b0, {defs_div_sqrt_mvp_C_EXP_ZERO_FP64}, Exp_num_DI[0]} : {~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI})};
	assign Exp_add_c_D = {(Div_start_dly_S ? {C_BIAS_AONE} : {C_HALF_BIAS})};
	assign Exp_result_prenorm_DN = (Start_dly_S ? {(Exp_add_a_D + Exp_add_b_D) + Exp_add_c_D} : Exp_result_prenorm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_result_prenorm_DP <= {13 {1'sb0}};
		else
			Exp_result_prenorm_DP <= Exp_result_prenorm_DN;
	assign Exp_result_prenorm_DO = Exp_result_prenorm_DP;
endmodule
module data_mem_top (
	clk_i,
	rst_ni,
	tl_d_i,
	tl_d_o,
	csb,
	addr_o,
	wdata_o,
	wmask_o,
	we_o,
	rdata_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_d_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_d_o;
	output wire csb;
	output wire [11:0] addr_o;
	output wire [31:0] wdata_o;
	output wire [3:0] wmask_o;
	output wire we_o;
	input wire [31:0] rdata_i;
	wire tl_req;
	wire [31:0] tl_wmask;
	wire we_i;
	reg rvalid_o;
	assign wmask_o[0] = (tl_wmask[7:0] != 8'b00000000 ? 1'b1 : 1'b0);
	assign wmask_o[1] = (tl_wmask[15:8] != 8'b00000000 ? 1'b1 : 1'b0);
	assign wmask_o[2] = (tl_wmask[23:16] != 8'b00000000 ? 1'b1 : 1'b0);
	assign wmask_o[3] = (tl_wmask[31:24] != 8'b00000000 ? 1'b1 : 1'b0);
	assign we_o = ~we_i;
	assign csb = ~tl_req;
	tlul_sram_adapter #(
		.SramAw(12),
		.SramDw(32),
		.Outstanding(4),
		.ByteAccess(1),
		.ErrOnWrite(0),
		.ErrOnRead(0)
	) data_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_d_i),
		.tl_o(tl_d_o),
		.req_o(tl_req),
		.gnt_i(1'b1),
		.we_o(we_i),
		.addr_o(addr_o),
		.wdata_o(wdata_o),
		.wmask_o(tl_wmask),
		.rdata_i((rst_ni ? rdata_i : {32 {1'sb0}})),
		.rvalid_i(rvalid_o),
		.rerror_i(2'b00)
	);
	always @(posedge clk_i)
		if (!rst_ni)
			rvalid_o <= 1'b0;
		else if (we_i)
			rvalid_o <= 1'b0;
		else
			rvalid_o <= tl_req;
endmodule
module div_sqrt_top_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Precision_ctl_SI,
	Format_sel_SI,
	Kill_SI,
	Result_DO,
	Fflags_SO,
	Ready_SO,
	Done_SO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	input wire Kill_SI;
	output wire [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	output wire Ready_SO;
	output wire Done_SO;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_D;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_D;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_D;
	wire [12:0] Exp_z_D;
	wire [56:0] Mant_z_D;
	wire Sign_z_D;
	wire Start_S;
	wire [2:0] RM_dly_S;
	wire Div_enable_S;
	wire Sqrt_enable_S;
	wire Inf_a_S;
	wire Inf_b_S;
	wire Zero_a_S;
	wire Zero_b_S;
	wire NaN_a_S;
	wire NaN_b_S;
	wire SNaN_S;
	wire Special_case_SB;
	wire Special_case_dly_SB;
	wire Full_precision_S;
	wire FP32_S;
	wire FP64_S;
	wire FP16_S;
	wire FP16ALT_S;
	preprocess_mvp preprocess_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Ready_SI(Ready_SO),
		.Operand_a_DI(Operand_a_DI),
		.Operand_b_DI(Operand_b_DI),
		.RM_SI(RM_SI),
		.Format_sel_SI(Format_sel_SI),
		.Start_SO(Start_S),
		.Exp_a_DO_norm(Exp_a_D),
		.Exp_b_DO_norm(Exp_b_D),
		.Mant_a_DO_norm(Mant_a_D),
		.Mant_b_DO_norm(Mant_b_D),
		.RM_dly_SO(RM_dly_S),
		.Sign_z_DO(Sign_z_D),
		.Inf_a_SO(Inf_a_S),
		.Inf_b_SO(Inf_b_S),
		.Zero_a_SO(Zero_a_S),
		.Zero_b_SO(Zero_b_S),
		.NaN_a_SO(NaN_a_S),
		.NaN_b_SO(NaN_b_S),
		.SNaN_SO(SNaN_S),
		.Special_case_SBO(Special_case_SB),
		.Special_case_dly_SBO(Special_case_dly_SB)
	);
	nrbd_nrsc_mvp nrbd_nrsc_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Start_SI(Start_S),
		.Kill_SI(Kill_SI),
		.Special_case_SBI(Special_case_SB),
		.Special_case_dly_SBI(Special_case_dly_SB),
		.Div_enable_SO(Div_enable_S),
		.Sqrt_enable_SO(Sqrt_enable_S),
		.Precision_ctl_SI(Precision_ctl_SI),
		.Format_sel_SI(Format_sel_SI),
		.Exp_a_DI(Exp_a_D),
		.Exp_b_DI(Exp_b_D),
		.Mant_a_DI(Mant_a_D),
		.Mant_b_DI(Mant_b_D),
		.Full_precision_SO(Full_precision_S),
		.FP32_SO(FP32_S),
		.FP64_SO(FP64_S),
		.FP16_SO(FP16_S),
		.FP16ALT_SO(FP16ALT_S),
		.Ready_SO(Ready_SO),
		.Done_SO(Done_SO),
		.Exp_z_DO(Exp_z_D),
		.Mant_z_DO(Mant_z_D)
	);
	norm_div_sqrt_mvp fpu_norm_U0(
		.Mant_in_DI(Mant_z_D),
		.Exp_in_DI(Exp_z_D),
		.Sign_in_DI(Sign_z_D),
		.Div_enable_SI(Div_enable_S),
		.Sqrt_enable_SI(Sqrt_enable_S),
		.Inf_a_SI(Inf_a_S),
		.Inf_b_SI(Inf_b_S),
		.Zero_a_SI(Zero_a_S),
		.Zero_b_SI(Zero_b_S),
		.NaN_a_SI(NaN_a_S),
		.NaN_b_SI(NaN_b_S),
		.SNaN_SI(SNaN_S),
		.RM_SI(RM_dly_S),
		.Full_precision_SI(Full_precision_S),
		.FP32_SI(FP32_S),
		.FP64_SI(FP64_S),
		.FP16_SI(FP16_S),
		.FP16ALT_SI(FP16ALT_S),
		.Result_DO(Result_DO),
		.Fflags_SO(Fflags_SO)
	);
endmodule
module fifo_sync (
	clk_i,
	rst_ni,
	clr_i,
	wvalid_i,
	wready_o,
	wdata_i,
	rvalid_o,
	rready_i,
	rdata_o,
	full_o,
	depth_o
);
	parameter [31:0] Width = 16;
	parameter [0:0] Pass = 1'b1;
	parameter [31:0] Depth = 4;
	parameter [0:0] OutputZeroIfEmpty = 1'b1;
	function automatic integer prim_util_pkg_vbits;
		input integer value;
		prim_util_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DepthW = prim_util_pkg_vbits(Depth + 1);
	input clk_i;
	input rst_ni;
	input clr_i;
	input wvalid_i;
	output wready_o;
	input [Width - 1:0] wdata_i;
	output rvalid_o;
	input rready_i;
	output [Width - 1:0] rdata_o;
	output full_o;
	output [DepthW - 1:0] depth_o;
	generate
		if (Depth == 0) begin : gen_passthru_fifo
			assign depth_o = 1'b0;
			assign rvalid_o = wvalid_i;
			assign rdata_o = wdata_i;
			assign wready_o = rready_i;
			assign full_o = rready_i;
			wire unused_clr;
			assign unused_clr = clr_i;
		end
		else begin : gen_normal_fifo
			localparam [31:0] PTRV_W = prim_util_pkg_vbits(Depth);
			localparam [31:0] PTR_WIDTH = PTRV_W + 1;
			reg [PTR_WIDTH - 1:0] fifo_wptr;
			reg [PTR_WIDTH - 1:0] fifo_rptr;
			wire fifo_incr_wptr;
			wire fifo_incr_rptr;
			wire fifo_empty;
			reg under_rst;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					under_rst <= 1'b1;
				else if (under_rst)
					under_rst <= ~under_rst;
			wire full;
			wire empty;
			wire wptr_msb;
			wire rptr_msb;
			wire [PTRV_W - 1:0] wptr_value;
			wire [PTRV_W - 1:0] rptr_value;
			assign wptr_msb = fifo_wptr[PTR_WIDTH - 1];
			assign rptr_msb = fifo_rptr[PTR_WIDTH - 1];
			assign wptr_value = fifo_wptr[0+:PTRV_W];
			assign rptr_value = fifo_rptr[0+:PTRV_W];
			function automatic [DepthW - 1:0] sv2v_cast_703F8;
				input reg [DepthW - 1:0] inp;
				sv2v_cast_703F8 = inp;
			endfunction
			assign depth_o = (full ? sv2v_cast_703F8(Depth) : (wptr_msb == rptr_msb ? sv2v_cast_703F8(wptr_value) - sv2v_cast_703F8(rptr_value) : (sv2v_cast_703F8(Depth) - sv2v_cast_703F8(rptr_value)) + sv2v_cast_703F8(wptr_value)));
			assign fifo_incr_wptr = (wvalid_i & wready_o) & ~under_rst;
			assign fifo_incr_rptr = (rvalid_o & rready_i) & ~under_rst;
			assign wready_o = ~full & ~under_rst;
			assign full_o = full;
			assign rvalid_o = ~empty & ~under_rst;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_wptr <= {PTR_WIDTH {1'sb0}};
				else if (clr_i)
					fifo_wptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_wptr) begin : sv2v_autoblock_107
					reg [((PTR_WIDTH - 2) >= 0 ? PTR_WIDTH - 1 : 3 - PTR_WIDTH) - 1:0] sv2v_tmp_cast;
					sv2v_tmp_cast = Depth - 1;
					if (fifo_wptr[PTR_WIDTH - 2:0] == sv2v_tmp_cast)
						fifo_wptr <= {~fifo_wptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_wptr <= fifo_wptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
				end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_rptr <= {PTR_WIDTH {1'sb0}};
				else if (clr_i)
					fifo_rptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_rptr) begin : sv2v_autoblock_108
					reg [((PTR_WIDTH - 2) >= 0 ? PTR_WIDTH - 1 : 3 - PTR_WIDTH) - 1:0] sv2v_tmp_cast_1;
					sv2v_tmp_cast_1 = Depth - 1;
					if (fifo_rptr[PTR_WIDTH - 2:0] == sv2v_tmp_cast_1)
						fifo_rptr <= {~fifo_rptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_rptr <= fifo_rptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
				end
			assign full = fifo_wptr == (fifo_rptr ^ {1'b1, {PTR_WIDTH - 1 {1'b0}}});
			assign fifo_empty = fifo_wptr == fifo_rptr;
			reg [(Depth * Width) - 1:0] storage;
			wire [Width - 1:0] storage_rdata;
			if (Depth == 1) begin : gen_depth_eq1
				assign storage_rdata = storage[0+:Width];
				always @(posedge clk_i)
					if (~rst_ni)
						storage[0+:Width] <= {Width {1'sb0}};
					else if (fifo_incr_wptr)
						storage[0+:Width] <= wdata_i;
			end
			else begin : gen_depth_gt1
				assign storage_rdata = storage[fifo_rptr[PTR_WIDTH - 2:0] * Width+:Width];
				always @(posedge clk_i)
					if (~rst_ni)
						storage[fifo_wptr[PTR_WIDTH - 2:0] * Width+:Width] <= {Width {1'sb0}};
					else if (fifo_incr_wptr)
						storage[fifo_wptr[PTR_WIDTH - 2:0] * Width+:Width] <= wdata_i;
			end
			wire [Width - 1:0] rdata_int;
			if (Pass == 1'b1) begin : gen_pass
				assign rdata_int = (fifo_empty && wvalid_i ? wdata_i : storage_rdata);
				assign empty = fifo_empty & ~wvalid_i;
			end
			else begin : gen_nopass
				assign rdata_int = storage_rdata;
				assign empty = fifo_empty;
			end
			if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
				assign rdata_o = (empty ? 'b0 : rdata_int);
			end
			else begin : gen_no_output_zero
				assign rdata_o = rdata_int;
			end
		end
	endgenerate
endmodule
module fpnew_cast_multi_8A35C_87530 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtConfig = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [1:0] sv2v_cast_9359B;
		input reg [1:0] inp;
		sv2v_cast_9359B = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_109
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_9359B(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	localparam [1:0] fpnew_pkg_INT16 = 1;
	localparam [1:0] fpnew_pkg_INT32 = 2;
	localparam [1:0] fpnew_pkg_INT64 = 3;
	localparam [1:0] fpnew_pkg_INT8 = 0;
	function automatic [31:0] fpnew_pkg_int_width;
		input reg [1:0] ifmt;
		case (ifmt)
			fpnew_pkg_INT8: fpnew_pkg_int_width = 8;
			fpnew_pkg_INT16: fpnew_pkg_int_width = 16;
			fpnew_pkg_INT32: fpnew_pkg_int_width = 32;
			fpnew_pkg_INT64: fpnew_pkg_int_width = 64;
		endcase
	endfunction
	function automatic [1:0] sv2v_cast_D812A;
		input reg [1:0] inp;
		sv2v_cast_D812A = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_int_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_110
				reg signed [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					if (cfg[ifmt])
						res = fpnew_pkg_maximum(res, fpnew_pkg_int_width(sv2v_cast_D812A(ifmt)));
			end
			fpnew_pkg_max_int_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_maximum(fpnew_pkg_max_fp_width(FpFmtConfig), fpnew_pkg_max_int_width(IntFmtConfig));
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [WIDTH - 1:0] operands_i;
	input wire [3:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	input wire [1:0] int_fmt_i;
	input wire tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	always @(posedge __clk or negedge __arst_n)
		if (!__arst_n)
			__q <= __reset_value;
		else
			__q <= (__clear ? __reset_value : (__load ? __d : __q));
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			__q <= __reset_value;
		else
			__q <= (__load ? __d : __q);
	localparam [31:0] NUM_INT_FORMATS = fpnew_pkg_NUM_INT_FORMATS;
	localparam [31:0] MAX_INT_WIDTH = fpnew_pkg_max_int_width(IntFmtConfig);
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [1:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32];
	endfunction
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [1:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32];
	endfunction
	function automatic [63:0] fpnew_pkg_super_format;
		input reg [0:3] cfg;
		reg [63:0] res;
		begin
			res = {64 {1'sb0}};
			begin : sv2v_autoblock_111
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					if (cfg[fmt]) begin
						res[63-:32] = $unsigned(fpnew_pkg_maximum(res[63-:32], fpnew_pkg_exp_bits(sv2v_cast_9359B(fmt))));
						res[31-:32] = $unsigned(fpnew_pkg_maximum(res[31-:32], fpnew_pkg_man_bits(sv2v_cast_9359B(fmt))));
					end
			end
			fpnew_pkg_super_format = res;
		end
	endfunction
	localparam [63:0] SUPER_FORMAT = fpnew_pkg_super_format(FpFmtConfig);
	localparam [31:0] SUPER_EXP_BITS = SUPER_FORMAT[63-:32];
	localparam [31:0] SUPER_MAN_BITS = SUPER_FORMAT[31-:32];
	localparam [31:0] SUPER_BIAS = (2 ** (SUPER_EXP_BITS - 1)) - 1;
	localparam [31:0] INT_MAN_WIDTH = fpnew_pkg_maximum(SUPER_MAN_BITS + 1, MAX_INT_WIDTH);
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(INT_MAN_WIDTH);
	localparam [31:0] INT_EXP_WIDTH = fpnew_pkg_maximum($clog2(MAX_INT_WIDTH), fpnew_pkg_maximum(SUPER_EXP_BITS, $clog2(SUPER_BIAS + SUPER_MAN_BITS))) + 1;
	localparam [1:0] fpnew_pkg_DISTRIBUTED = 3;
	localparam NUM_INP_REGS = (PipeConfig == fpnew_pkg_BEFORE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 1) / 3 : 0));
	localparam [1:0] fpnew_pkg_INSIDE = 2;
	localparam NUM_MID_REGS = (PipeConfig == fpnew_pkg_INSIDE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 2) / 3 : 0));
	localparam [1:0] fpnew_pkg_AFTER = 1;
	localparam NUM_OUT_REGS = (PipeConfig == fpnew_pkg_AFTER ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? NumPipeRegs / 3 : 0));
	wire [WIDTH - 1:0] operands_q;
	wire [3:0] is_boxed_q;
	wire op_mod_q;
	wire [1:0] src_fmt_q;
	wire [1:0] dst_fmt_q;
	wire [1:0] int_fmt_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * WIDTH) + ((NUM_INP_REGS * WIDTH) - 1) : ((NUM_INP_REGS + 1) * WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * WIDTH : 0)] inp_pipe_operands_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0)] inp_pipe_is_boxed_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	wire [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_src_fmt_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_INT_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_INT_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_INT_FORMAT_BITS : 0)] inp_pipe_int_fmt_q;
	wire [0:NUM_INP_REGS] inp_pipe_tag_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	wire [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	assign inp_pipe_operands_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * WIDTH+:WIDTH] = operands_i;
	assign inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS+:NUM_FORMATS] = is_boxed_i;
	assign inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = rnd_mode_i;
	assign inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = op_i;
	assign inp_pipe_op_mod_q[0] = op_mod_i;
	assign inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = src_fmt_i;
	assign inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = dst_fmt_i;
	assign inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] = int_fmt_i;
	assign inp_pipe_tag_q[0] = tag_i;
	assign inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = aux_i;
	assign inp_pipe_valid_q[0] = in_valid_i;
	assign in_ready_o = inp_pipe_ready[0];
	generate
		genvar i;
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * WIDTH+:WIDTH];
	assign is_boxed_q = inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS+:NUM_FORMATS];
	assign op_mod_q = inp_pipe_op_mod_q[NUM_INP_REGS];
	assign src_fmt_q = inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign int_fmt_q = inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS];
	wire src_is_int;
	wire dst_is_int;
	localparam [3:0] fpnew_pkg_I2F = 12;
	assign src_is_int = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == fpnew_pkg_I2F;
	localparam [3:0] fpnew_pkg_F2I = 11;
	assign dst_is_int = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == fpnew_pkg_F2I;
	wire [INT_MAN_WIDTH - 1:0] encoded_mant;
	wire [3:0] fmt_sign;
	wire signed [(NUM_FORMATS * INT_EXP_WIDTH) - 1:0] fmt_exponent;
	wire [(NUM_FORMATS * INT_MAN_WIDTH) - 1:0] fmt_mantissa;
	wire signed [(NUM_FORMATS * INT_EXP_WIDTH) - 1:0] fmt_shift_compensation;
	wire [31:0] info;
	reg [(NUM_INT_FORMATS * INT_MAN_WIDTH) - 1:0] ifmt_input_val;
	wire int_sign;
	wire [INT_MAN_WIDTH - 1:0] int_value;
	wire [INT_MAN_WIDTH - 1:0] int_mantissa;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	generate
		genvar fmt;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : fmt_init_inputs
			function automatic [1:0] sv2v_cast_9359B;
				input reg [1:0] inp;
				sv2v_cast_9359B = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_9359B(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_9359B(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_9359B(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				function automatic [1:0] sv2v_cast_9359B;
					input reg [1:0] inp;
					sv2v_cast_9359B = inp;
				endfunction
				fpnew_classifier #(
					.FpFormat(sv2v_cast_9359B(fmt)),
					.NumOperands(1)
				) i_fpnew_classifier(
					.operands_i(operands_q[FP_WIDTH - 1:0]),
					.is_boxed_i(is_boxed_q[fmt]),
					.info_o(info[fmt * 8+:8])
				);
				assign fmt_sign[fmt] = operands_q[FP_WIDTH - 1];
				assign fmt_exponent[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = $signed({1'b0, operands_q[MAN_BITS+:EXP_BITS]});
				assign fmt_mantissa[fmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {info[(fmt * 8) + 7], operands_q[MAN_BITS - 1:0]};
				assign fmt_shift_compensation[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = $signed((INT_MAN_WIDTH - 1) - MAN_BITS);
			end
			else begin : inactive_format
				assign info[fmt * 8+:8] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_sign[fmt] = fpnew_pkg_DONT_CARE;
				function automatic signed [0:0] sv2v_cast_1_signed;
					input reg signed [0:0] inp;
					sv2v_cast_1_signed = inp;
				endfunction
				assign fmt_exponent[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = {INT_EXP_WIDTH {sv2v_cast_1_signed(fpnew_pkg_DONT_CARE)}};
				assign fmt_mantissa[fmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {INT_MAN_WIDTH {fpnew_pkg_DONT_CARE}};
				assign fmt_shift_compensation[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = {INT_EXP_WIDTH {sv2v_cast_1_signed(fpnew_pkg_DONT_CARE)}};
			end
		end
	endgenerate
	generate
		genvar ifmt;
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_sign_extend_int
			function automatic [1:0] sv2v_cast_D812A;
				input reg [1:0] inp;
				sv2v_cast_D812A = inp;
			endfunction
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_D812A(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				function automatic [0:0] sv2v_cast_1;
					input reg [0:0] inp;
					sv2v_cast_1 = inp;
				endfunction
				always @(*) begin : sign_ext_input
					ifmt_input_val[ifmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {INT_MAN_WIDTH {sv2v_cast_1(operands_q[INT_WIDTH - 1] & ~op_mod_q)}};
					ifmt_input_val[(ifmt * INT_MAN_WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = operands_q[INT_WIDTH - 1:0];
				end
			end
			else begin : inactive_format
				wire [INT_MAN_WIDTH:1] sv2v_tmp_F538F;
				assign sv2v_tmp_F538F = {INT_MAN_WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_input_val[ifmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = sv2v_tmp_F538F;
			end
		end
	endgenerate
	assign int_value = ifmt_input_val[int_fmt_q * INT_MAN_WIDTH+:INT_MAN_WIDTH];
	assign int_sign = int_value[INT_MAN_WIDTH - 1] & ~op_mod_q;
	assign int_mantissa = (int_sign ? $unsigned(-int_value) : int_value);
	assign encoded_mant = (src_is_int ? int_mantissa : fmt_mantissa[src_fmt_q * INT_MAN_WIDTH+:INT_MAN_WIDTH]);
	wire signed [INT_EXP_WIDTH - 1:0] src_bias;
	wire signed [INT_EXP_WIDTH - 1:0] src_exp;
	wire signed [INT_EXP_WIDTH - 1:0] src_subnormal;
	wire signed [INT_EXP_WIDTH - 1:0] src_offset;
	function automatic [31:0] fpnew_pkg_bias;
		input reg [1:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	assign src_bias = $signed(fpnew_pkg_bias(src_fmt_q));
	assign src_exp = fmt_exponent[src_fmt_q * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign src_subnormal = $signed({1'b0, info[(src_fmt_q * 8) + 6]});
	assign src_offset = fmt_shift_compensation[src_fmt_q * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	wire input_sign;
	wire signed [INT_EXP_WIDTH - 1:0] input_exp;
	wire [INT_MAN_WIDTH - 1:0] input_mant;
	wire mant_is_zero;
	wire signed [INT_EXP_WIDTH - 1:0] fp_input_exp;
	wire signed [INT_EXP_WIDTH - 1:0] int_input_exp;
	wire [LZC_RESULT_WIDTH - 1:0] renorm_shamt;
	wire [LZC_RESULT_WIDTH:0] renorm_shamt_sgn;
	lzc #(
		.WIDTH(INT_MAN_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(encoded_mant),
		.cnt_o(renorm_shamt),
		.empty_o(mant_is_zero)
	);
	assign renorm_shamt_sgn = $signed({1'b0, renorm_shamt});
	assign input_sign = (src_is_int ? int_sign : fmt_sign[src_fmt_q]);
	assign input_mant = encoded_mant << renorm_shamt;
	assign fp_input_exp = $signed((((src_exp + src_subnormal) - src_bias) - renorm_shamt_sgn) + src_offset);
	assign int_input_exp = $signed((INT_MAN_WIDTH - 1) - renorm_shamt_sgn);
	assign input_exp = (src_is_int ? int_input_exp : fp_input_exp);
	wire signed [INT_EXP_WIDTH - 1:0] destination_exp;
	assign destination_exp = input_exp + $signed(fpnew_pkg_bias(dst_fmt_q));
	wire input_sign_q;
	wire signed [INT_EXP_WIDTH - 1:0] input_exp_q;
	wire [INT_MAN_WIDTH - 1:0] input_mant_q;
	wire signed [INT_EXP_WIDTH - 1:0] destination_exp_q;
	wire src_is_int_q;
	wire dst_is_int_q;
	wire [7:0] info_q;
	wire mant_is_zero_q;
	wire op_mod_q2;
	wire [2:0] rnd_mode_q;
	wire [1:0] src_fmt_q2;
	wire [1:0] dst_fmt_q2;
	wire [1:0] int_fmt_q2;
	wire [0:NUM_MID_REGS] mid_pipe_input_sign_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_EXP_WIDTH) + ((NUM_MID_REGS * INT_EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_EXP_WIDTH : 0)] mid_pipe_input_exp_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_MAN_WIDTH) + ((NUM_MID_REGS * INT_MAN_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_MAN_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_MAN_WIDTH : 0)] mid_pipe_input_mant_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_EXP_WIDTH) + ((NUM_MID_REGS * INT_EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_EXP_WIDTH : 0)] mid_pipe_dest_exp_q;
	wire [0:NUM_MID_REGS] mid_pipe_src_is_int_q;
	wire [0:NUM_MID_REGS] mid_pipe_dst_is_int_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 8) + ((NUM_MID_REGS * 8) - 1) : ((NUM_MID_REGS + 1) * 8) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 8 : 0)] mid_pipe_info_q;
	wire [0:NUM_MID_REGS] mid_pipe_mant_zero_q;
	wire [0:NUM_MID_REGS] mid_pipe_op_mod_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_src_fmt_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_dst_fmt_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_INT_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_INT_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_INT_FORMAT_BITS : 0)] mid_pipe_int_fmt_q;
	wire [0:NUM_MID_REGS] mid_pipe_tag_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * AuxType_AUX_BITS) + ((NUM_MID_REGS * AuxType_AUX_BITS) - 1) : ((NUM_MID_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * AuxType_AUX_BITS : 0)] mid_pipe_aux_q;
	wire [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	assign mid_pipe_input_sign_q[0] = input_sign;
	assign mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH] = input_exp;
	assign mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_MAN_WIDTH+:INT_MAN_WIDTH] = input_mant;
	assign mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH] = destination_exp;
	assign mid_pipe_src_is_int_q[0] = src_is_int;
	assign mid_pipe_dst_is_int_q[0] = dst_is_int;
	assign mid_pipe_info_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 8+:8] = info[src_fmt_q * 8+:8];
	assign mid_pipe_mant_zero_q[0] = mant_is_zero;
	assign mid_pipe_op_mod_q[0] = op_mod_q;
	assign mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	assign mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = src_fmt_q;
	assign mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = dst_fmt_q;
	assign mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] = int_fmt_q;
	assign mid_pipe_tag_q[0] = inp_pipe_tag_q[NUM_INP_REGS];
	assign mid_pipe_aux_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = inp_pipe_aux_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign mid_pipe_valid_q[0] = inp_pipe_valid_q[NUM_INP_REGS];
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
		end
	endgenerate
	assign input_sign_q = mid_pipe_input_sign_q[NUM_MID_REGS];
	assign input_exp_q = mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign input_mant_q = mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_MAN_WIDTH+:INT_MAN_WIDTH];
	assign destination_exp_q = mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign src_is_int_q = mid_pipe_src_is_int_q[NUM_MID_REGS];
	assign dst_is_int_q = mid_pipe_dst_is_int_q[NUM_MID_REGS];
	assign info_q = mid_pipe_info_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 8+:8];
	assign mant_is_zero_q = mid_pipe_mant_zero_q[NUM_MID_REGS];
	assign op_mod_q2 = mid_pipe_op_mod_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign src_fmt_q2 = mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q2 = mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign int_fmt_q2 = mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS];
	reg [INT_EXP_WIDTH - 1:0] final_exp;
	reg [2 * INT_MAN_WIDTH:0] preshift_mant;
	wire [2 * INT_MAN_WIDTH:0] destination_mant;
	wire [SUPER_MAN_BITS - 1:0] final_mant;
	wire [MAX_INT_WIDTH - 1:0] final_int;
	reg [$clog2(INT_MAN_WIDTH + 1) - 1:0] denorm_shamt;
	wire [1:0] fp_round_sticky_bits;
	wire [1:0] int_round_sticky_bits;
	wire [1:0] round_sticky_bits;
	reg of_before_round;
	reg uf_before_round;
	always @(*) begin : cast_value
		final_exp = $unsigned(destination_exp_q);
		preshift_mant = {((2 * INT_MAN_WIDTH) >= 0 ? (2 * INT_MAN_WIDTH) + 1 : 1 - (2 * INT_MAN_WIDTH)) {1'sb0}};
		denorm_shamt = SUPER_MAN_BITS - fpnew_pkg_man_bits(dst_fmt_q2);
		of_before_round = 1'b0;
		uf_before_round = 1'b0;
		preshift_mant = input_mant_q << (INT_MAN_WIDTH + 1);
		if (dst_is_int_q) begin
			denorm_shamt = $unsigned((MAX_INT_WIDTH - 1) - input_exp_q);
			if (input_exp_q >= $signed((fpnew_pkg_int_width(int_fmt_q2) - 1) + op_mod_q2)) begin
				denorm_shamt = {$clog2(INT_MAN_WIDTH + 1) {1'sb0}};
				of_before_round = 1'b1;
			end
			else if (input_exp_q < -1) begin
				denorm_shamt = MAX_INT_WIDTH + 1;
				uf_before_round = 1'b1;
			end
		end
		else if ((destination_exp_q >= ($signed(2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 1)) || (~src_is_int_q && info_q[4])) begin
			final_exp = $unsigned((2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 2);
			preshift_mant = {((2 * INT_MAN_WIDTH) >= 0 ? (2 * INT_MAN_WIDTH) + 1 : 1 - (2 * INT_MAN_WIDTH)) {1'sb1}};
			of_before_round = 1'b1;
		end
		else if ((destination_exp_q < 1) && (destination_exp_q >= -$signed(fpnew_pkg_man_bits(dst_fmt_q2)))) begin
			final_exp = {INT_EXP_WIDTH {1'sb0}};
			denorm_shamt = $unsigned((denorm_shamt + 1) - destination_exp_q);
			uf_before_round = 1'b1;
		end
		else if (destination_exp_q < -$signed(fpnew_pkg_man_bits(dst_fmt_q2))) begin
			final_exp = {INT_EXP_WIDTH {1'sb0}};
			denorm_shamt = $unsigned((denorm_shamt + 2) + fpnew_pkg_man_bits(dst_fmt_q2));
			uf_before_round = 1'b1;
		end
	end
	localparam NUM_FP_STICKY = ((2 * INT_MAN_WIDTH) - SUPER_MAN_BITS) - 1;
	localparam NUM_INT_STICKY = (2 * INT_MAN_WIDTH) - MAX_INT_WIDTH;
	assign destination_mant = preshift_mant >> denorm_shamt;
	assign {final_mant, fp_round_sticky_bits[1]} = destination_mant[(2 * INT_MAN_WIDTH) - 1-:SUPER_MAN_BITS + 1];
	assign {final_int, int_round_sticky_bits[1]} = destination_mant[2 * INT_MAN_WIDTH-:MAX_INT_WIDTH + 1];
	assign fp_round_sticky_bits[0] = |{destination_mant[NUM_FP_STICKY - 1:0]};
	assign int_round_sticky_bits[0] = |{destination_mant[NUM_INT_STICKY - 1:0]};
	assign round_sticky_bits = (dst_is_int_q ? int_round_sticky_bits : fp_round_sticky_bits);
	wire [WIDTH - 1:0] pre_round_abs;
	wire of_after_round;
	wire uf_after_round;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_pre_round_abs;
	reg [3:0] fmt_of_after_round;
	reg [3:0] fmt_uf_after_round;
	reg [(NUM_INT_FORMATS * WIDTH) - 1:0] ifmt_pre_round_abs;
	wire rounded_sign;
	wire [WIDTH - 1:0] rounded_abs;
	wire result_true_zero;
	wire [WIDTH - 1:0] rounded_int_res;
	wire rounded_int_res_zero;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_res_assemble
			function automatic [1:0] sv2v_cast_9359B;
				input reg [1:0] inp;
				sv2v_cast_9359B = inp;
			endfunction
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_9359B(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_9359B(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : assemble_result
					fmt_pre_round_abs[fmt * WIDTH+:WIDTH] = {final_exp[EXP_BITS - 1:0], final_mant[MAN_BITS - 1:0]};
				end
			end
			else begin : inactive_format
				wire [WIDTH:1] sv2v_tmp_4020A;
				assign sv2v_tmp_4020A = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_pre_round_abs[fmt * WIDTH+:WIDTH] = sv2v_tmp_4020A;
			end
		end
	endgenerate
	generate
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_int_res_sign_ext
			function automatic [1:0] sv2v_cast_D812A;
				input reg [1:0] inp;
				sv2v_cast_D812A = inp;
			endfunction
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_D812A(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				always @(*) begin : assemble_result
					ifmt_pre_round_abs[ifmt * WIDTH+:WIDTH] = {WIDTH {final_int[INT_WIDTH - 1]}};
					ifmt_pre_round_abs[(ifmt * WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = final_int[INT_WIDTH - 1:0];
				end
			end
			else begin : inactive_format
				wire [WIDTH:1] sv2v_tmp_D81CB;
				assign sv2v_tmp_D81CB = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_pre_round_abs[ifmt * WIDTH+:WIDTH] = sv2v_tmp_D81CB;
			end
		end
	endgenerate
	assign pre_round_abs = (dst_is_int_q ? ifmt_pre_round_abs[int_fmt_q2 * WIDTH+:WIDTH] : fmt_pre_round_abs[dst_fmt_q2 * WIDTH+:WIDTH]);
	fpnew_rounding #(.AbsWidth(WIDTH)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(input_sign_q),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(1'b0),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_true_zero)
	);
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_sign_inject
			function automatic [1:0] sv2v_cast_9359B;
				input reg [1:0] inp;
				sv2v_cast_9359B = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_9359B(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_9359B(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_9359B(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : post_process
					fmt_uf_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb0}};
					fmt_of_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb1}};
					fmt_result[fmt * WIDTH+:WIDTH] = {WIDTH {1'sb1}};
					fmt_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = (src_is_int_q & mant_is_zero_q ? {FP_WIDTH {1'sb0}} : {rounded_sign, rounded_abs[(EXP_BITS + MAN_BITS) - 1:0]});
				end
			end
			else begin : inactive_format
				wire [1:1] sv2v_tmp_78FCE;
				assign sv2v_tmp_78FCE = fpnew_pkg_DONT_CARE;
				always @(*) fmt_uf_after_round[fmt] = sv2v_tmp_78FCE;
				wire [1:1] sv2v_tmp_C5A3B;
				assign sv2v_tmp_C5A3B = fpnew_pkg_DONT_CARE;
				always @(*) fmt_of_after_round[fmt] = sv2v_tmp_C5A3B;
				wire [WIDTH:1] sv2v_tmp_4A6B1;
				assign sv2v_tmp_4A6B1 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_4A6B1;
			end
		end
	endgenerate
	assign uf_after_round = fmt_uf_after_round[dst_fmt_q2];
	assign of_after_round = fmt_of_after_round[dst_fmt_q2];
	assign rounded_int_res = (rounded_sign ? $unsigned(-rounded_abs) : rounded_abs);
	assign rounded_int_res_zero = rounded_int_res == {WIDTH {1'sb0}};
	wire [WIDTH - 1:0] fp_special_result;
	wire [4:0] fp_special_status;
	wire fp_result_is_special;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_special_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_special_results
			function automatic [1:0] sv2v_cast_9359B;
				input reg [1:0] inp;
				sv2v_cast_9359B = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_9359B(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_9359B(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_9359B(fmt));
			localparam [EXP_BITS - 1:0] QNAN_EXPONENT = 1'sb1;
			localparam [MAN_BITS - 1:0] QNAN_MANTISSA = 2 ** (MAN_BITS - 1);
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : special_results
					reg [FP_WIDTH - 1:0] special_res;
					special_res = (info_q[5] ? input_sign_q << (FP_WIDTH - 1) : {1'b0, QNAN_EXPONENT, QNAN_MANTISSA});
					fmt_special_result[fmt * WIDTH+:WIDTH] = {WIDTH {1'sb1}};
					fmt_special_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH:1] sv2v_tmp_E5F3D;
				assign sv2v_tmp_E5F3D = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_special_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_E5F3D;
			end
		end
	endgenerate
	assign fp_result_is_special = ~src_is_int_q & ((info_q[5] | info_q[3]) | ~info_q[0]);
	assign fp_special_status = {info_q[2], 1'b0, 1'b0, 1'b0, 1'b0};
	assign fp_special_result = fmt_special_result[dst_fmt_q2 * WIDTH+:WIDTH];
	wire [WIDTH - 1:0] int_special_result;
	wire [4:0] int_special_status;
	wire int_result_is_special;
	reg [(NUM_INT_FORMATS * WIDTH) - 1:0] ifmt_special_result;
	generate
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_special_results_int
			function automatic [1:0] sv2v_cast_D812A;
				input reg [1:0] inp;
				sv2v_cast_D812A = inp;
			endfunction
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_D812A(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				always @(*) begin : special_results
					reg [INT_WIDTH - 1:0] special_res;
					special_res[INT_WIDTH - 2:0] = {((INT_WIDTH - 2) >= 0 ? INT_WIDTH - 1 : 3 - INT_WIDTH) {1'sb1}};
					special_res[INT_WIDTH - 1] = op_mod_q2;
					if (input_sign_q && !info_q[3])
						special_res = ~special_res;
					ifmt_special_result[ifmt * WIDTH+:WIDTH] = {WIDTH {special_res[INT_WIDTH - 1]}};
					ifmt_special_result[(ifmt * WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH:1] sv2v_tmp_B8B30;
				assign sv2v_tmp_B8B30 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_special_result[ifmt * WIDTH+:WIDTH] = sv2v_tmp_B8B30;
			end
		end
	endgenerate
	assign int_result_is_special = (((info_q[3] | info_q[4]) | of_before_round) | ~info_q[0]) | ((input_sign_q & op_mod_q2) & ~rounded_int_res_zero);
	assign int_special_status = 5'b10000;
	assign int_special_result = ifmt_special_result[int_fmt_q2 * WIDTH+:WIDTH];
	wire [4:0] int_regular_status;
	wire [4:0] fp_regular_status;
	wire [WIDTH - 1:0] fp_result;
	wire [WIDTH - 1:0] int_result;
	wire [4:0] fp_status;
	wire [4:0] int_status;
	assign fp_regular_status[4] = src_is_int_q & (of_before_round | of_after_round);
	assign fp_regular_status[3] = 1'b0;
	assign fp_regular_status[2] = ~src_is_int_q & (~info_q[4] & (of_before_round | of_after_round));
	assign fp_regular_status[1] = uf_after_round & fp_regular_status[0];
	assign fp_regular_status[0] = (src_is_int_q ? |fp_round_sticky_bits : |fp_round_sticky_bits | (~info_q[4] & (of_before_round | of_after_round)));
	assign int_regular_status = {4'b0000, |int_round_sticky_bits};
	assign fp_result = (fp_result_is_special ? fp_special_result : fmt_result[dst_fmt_q2 * WIDTH+:WIDTH]);
	assign fp_status = (fp_result_is_special ? fp_special_status : fp_regular_status);
	assign int_result = (int_result_is_special ? int_special_result : rounded_int_res);
	assign int_status = (int_result_is_special ? int_special_status : int_regular_status);
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	wire extension_bit;
	assign result_d = (dst_is_int_q ? int_result : fp_result);
	assign status_d = (dst_is_int_q ? int_status : fp_status);
	assign extension_bit = (dst_is_int_q ? int_result[WIDTH - 1] : 1'b1);
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	wire [0:NUM_OUT_REGS] out_pipe_ext_bit_q;
	wire [0:NUM_OUT_REGS] out_pipe_tag_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	wire [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	assign out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = result_d;
	assign out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = status_d;
	assign out_pipe_ext_bit_q[0] = extension_bit;
	assign out_pipe_tag_q[0] = mid_pipe_tag_q[NUM_MID_REGS];
	assign out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = mid_pipe_aux_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_pipe_valid_q[0] = mid_pipe_valid_q[NUM_MID_REGS];
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = out_pipe_ext_bit_q[NUM_OUT_REGS];
	assign tag_o = out_pipe_tag_q[NUM_OUT_REGS];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_classifier (
	operands_i,
	is_boxed_i,
	info_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	function automatic [1:0] sv2v_cast_9E068;
		input reg [1:0] inp;
		sv2v_cast_9E068 = inp;
	endfunction
	parameter [1:0] FpFormat = sv2v_cast_9E068(0);
	parameter [31:0] NumOperands = 1;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire [(NumOperands * WIDTH) - 1:0] operands_i;
	input wire [NumOperands - 1:0] is_boxed_i;
	output reg [(NumOperands * 8) - 1:0] info_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [1:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [1:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	generate
		genvar op;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (op = 0; op < sv2v_cast_32_signed(NumOperands); op = op + 1) begin : gen_num_values
			reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] value;
			reg is_boxed;
			reg is_normal;
			reg is_inf;
			reg is_nan;
			reg is_signalling;
			reg is_quiet;
			reg is_zero;
			reg is_subnormal;
			always @(*) begin : classify_input
				value = operands_i[op * WIDTH+:WIDTH];
				is_boxed = is_boxed_i[op];
				is_normal = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] != {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb0}})) && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] != {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb1}});
				is_zero = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb0}})) && (value[MAN_BITS - 1-:MAN_BITS] == {MAN_BITS {1'sb0}});
				is_subnormal = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb0}})) && !is_zero;
				is_inf = is_boxed && ((value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb1}}) && (value[MAN_BITS - 1-:MAN_BITS] == {MAN_BITS {1'sb0}}));
				is_nan = !is_boxed || ((value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1) {1'sb1}}) && (value[MAN_BITS - 1-:MAN_BITS] != {MAN_BITS {1'sb0}}));
				is_signalling = (is_boxed && is_nan) && (value[(MAN_BITS - 1) - ((MAN_BITS - 1) - (MAN_BITS - 1))] == 1'b0);
				is_quiet = is_nan && !is_signalling;
				info_o[(op * 8) + 7] = is_normal;
				info_o[(op * 8) + 6] = is_subnormal;
				info_o[(op * 8) + 5] = is_zero;
				info_o[(op * 8) + 4] = is_inf;
				info_o[(op * 8) + 3] = is_nan;
				info_o[(op * 8) + 2] = is_signalling;
				info_o[(op * 8) + 1] = is_quiet;
				info_o[op * 8] = is_boxed;
			end
		end
	endgenerate
endmodule
module fpnew_divsqrt_multi_28154_735ED (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	dst_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_AFTER = 1;
	parameter [1:0] PipeConfig = fpnew_pkg_AFTER;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [1:0] sv2v_cast_8C7A2;
		input reg [1:0] inp;
		sv2v_cast_8C7A2 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_112
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_8C7A2(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(2 * WIDTH) - 1:0] operands_i;
	input wire [7:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire [1:0] dst_fmt_i;
	input wire tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	localparam [1:0] fpnew_pkg_DISTRIBUTED = 3;
	localparam NUM_INP_REGS = (PipeConfig == fpnew_pkg_BEFORE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? NumPipeRegs / 2 : 0));
	localparam [1:0] fpnew_pkg_INSIDE = 2;
	localparam NUM_OUT_REGS = ((PipeConfig == fpnew_pkg_AFTER) || (PipeConfig == fpnew_pkg_INSIDE) ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 1) / 2 : 0));
	wire [(2 * WIDTH) - 1:0] operands_q;
	wire [2:0] rnd_mode_q;
	wire [3:0] op_q;
	wire [1:0] dst_fmt_q;
	wire in_valid_q;
	wire [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH)] inp_pipe_operands_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	wire [0:NUM_INP_REGS] inp_pipe_tag_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	wire [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	assign inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] = operands_i;
	assign inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = rnd_mode_i;
	assign inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = op_i;
	assign inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = dst_fmt_i;
	assign inp_pipe_tag_q[0] = tag_i;
	assign inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = aux_i;
	assign inp_pipe_valid_q[0] = in_valid_i;
	assign in_ready_o = inp_pipe_ready[0];
	generate
		genvar i;
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2];
	assign rnd_mode_q = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	assign op_q = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign in_valid_q = inp_pipe_valid_q[NUM_INP_REGS];
	reg [1:0] divsqrt_fmt;
	reg [127:0] divsqrt_operands;
	reg input_is_fp8;
	localparam [1:0] fpnew_pkg_FP16 = 'd2;
	localparam [1:0] fpnew_pkg_FP32 = 'd0;
	localparam [1:0] fpnew_pkg_FP64 = 'd1;
	localparam [1:0] fpnew_pkg_FP8 = 'd3;
	always @(*) begin : translate_fmt
		case (dst_fmt_q)
			fpnew_pkg_FP32: divsqrt_fmt = 2'b00;
			fpnew_pkg_FP64: divsqrt_fmt = 2'b01;
			fpnew_pkg_FP16: divsqrt_fmt = 2'b10;
			default: divsqrt_fmt = 2'b10;
		endcase
		input_is_fp8 = FpFmtConfig[fpnew_pkg_FP8] & (dst_fmt_q == fpnew_pkg_FP8);
		divsqrt_operands[0+:64] = (input_is_fp8 ? operands_q[0+:WIDTH] << 8 : operands_q[0+:WIDTH]);
		divsqrt_operands[64+:64] = (input_is_fp8 ? operands_q[WIDTH+:WIDTH] << 8 : operands_q[WIDTH+:WIDTH]);
	end
	reg in_ready;
	wire div_valid;
	wire sqrt_valid;
	wire unit_ready;
	wire unit_done;
	wire op_starting;
	reg out_valid;
	wire out_ready;
	reg hold_result;
	reg data_is_held;
	reg unit_busy;
	wire [1:0] state_q;
	reg [1:0] state_d;
	assign inp_pipe_ready[NUM_INP_REGS] = in_ready;
	localparam [3:0] fpnew_pkg_DIV = 4;
	assign div_valid = ((in_valid_q & (op_q == fpnew_pkg_DIV)) & in_ready) & ~flush_i;
	assign sqrt_valid = ((in_valid_q & (op_q != fpnew_pkg_DIV)) & in_ready) & ~flush_i;
	assign op_starting = div_valid | sqrt_valid;
	localparam [1:0] BUSY = 1;
	localparam [1:0] HOLD = 2;
	localparam [1:0] IDLE = 0;
	always @(*) begin : flag_fsm
		in_ready = 1'b0;
		out_valid = 1'b0;
		hold_result = 1'b0;
		data_is_held = 1'b0;
		unit_busy = 1'b0;
		state_d = state_q;
		case (state_q)
			IDLE: begin
				in_ready = 1'b1;
				if (in_valid_q && unit_ready)
					state_d = BUSY;
			end
			BUSY: begin
				unit_busy = 1'b1;
				if (unit_done) begin
					out_valid = 1'b1;
					if (out_ready) begin
						state_d = IDLE;
						if (in_valid_q && unit_ready) begin
							in_ready = 1'b1;
							state_d = BUSY;
						end
					end
					else begin
						hold_result = 1'b1;
						state_d = HOLD;
					end
				end
			end
			HOLD: begin
				unit_busy = 1'b1;
				data_is_held = 1'b1;
				out_valid = 1'b1;
				if (out_ready) begin
					state_d = IDLE;
					if (in_valid_q && unit_ready) begin
						in_ready = 1'b1;
						state_d = BUSY;
					end
				end
			end
			default: state_d = IDLE;
		endcase
		if (flush_i) begin
			unit_busy = 1'b0;
			out_valid = 1'b0;
			state_d = IDLE;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			__q <= __reset_value;
		else
			__q <= __d;
	wire result_is_fp8_q;
	wire result_tag_q;
	wire [AuxType_AUX_BITS - 1:0] result_aux_q;
	wire [63:0] unit_result;
	wire [WIDTH - 1:0] adjusted_result;
	wire [WIDTH - 1:0] held_result_q;
	wire [4:0] unit_status;
	wire [4:0] held_status_q;
	div_sqrt_top_mvp i_divsqrt_lei(
		.Clk_CI(clk_i),
		.Rst_RBI(rst_ni),
		.Div_start_SI(div_valid),
		.Sqrt_start_SI(sqrt_valid),
		.Operand_a_DI(divsqrt_operands[0+:64]),
		.Operand_b_DI(divsqrt_operands[64+:64]),
		.RM_SI(rnd_mode_q),
		.Precision_ctl_SI({6 {1'sb0}}),
		.Format_sel_SI(divsqrt_fmt),
		.Kill_SI(flush_i),
		.Result_DO(unit_result),
		.Fflags_SO(unit_status),
		.Ready_SO(unit_ready),
		.Done_SO(unit_done)
	);
	always @(posedge __clk) __q <= (__load ? __d : __q);
	assign adjusted_result = (result_is_fp8_q ? unit_result >> 8 : unit_result);
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (data_is_held ? held_result_q : adjusted_result);
	assign status_d = (data_is_held ? held_status_q : unit_status);
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	wire [0:NUM_OUT_REGS] out_pipe_tag_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	wire [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	assign out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = result_d;
	assign out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = status_d;
	assign out_pipe_tag_q[0] = result_tag_q;
	assign out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = result_aux_q;
	assign out_pipe_valid_q[0] = out_valid;
	assign out_ready = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[NUM_OUT_REGS];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, unit_busy, out_pipe_valid_q};
endmodule
module fpnew_fma_multi_E4D0A_BE123 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [1:0] sv2v_cast_3AA4D;
		input reg [1:0] inp;
		sv2v_cast_3AA4D = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_113
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_3AA4D(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(3 * WIDTH) - 1:0] operands_i;
	input wire [11:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	input wire tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [1:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32];
	endfunction
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [1:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32];
	endfunction
	function automatic [63:0] fpnew_pkg_super_format;
		input reg [0:3] cfg;
		reg [63:0] res;
		begin
			res = {64 {1'sb0}};
			begin : sv2v_autoblock_114
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					if (cfg[fmt]) begin
						res[63-:32] = $unsigned(fpnew_pkg_maximum(res[63-:32], fpnew_pkg_exp_bits(sv2v_cast_3AA4D(fmt))));
						res[31-:32] = $unsigned(fpnew_pkg_maximum(res[31-:32], fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt))));
					end
			end
			fpnew_pkg_super_format = res;
		end
	endfunction
	localparam [63:0] SUPER_FORMAT = fpnew_pkg_super_format(FpFmtConfig);
	localparam [31:0] SUPER_EXP_BITS = SUPER_FORMAT[63-:32];
	localparam [31:0] SUPER_MAN_BITS = SUPER_FORMAT[31-:32];
	localparam [31:0] PRECISION_BITS = SUPER_MAN_BITS + 1;
	localparam [31:0] LOWER_SUM_WIDTH = (2 * PRECISION_BITS) + 3;
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(LOWER_SUM_WIDTH);
	localparam [31:0] EXP_WIDTH = fpnew_pkg_maximum(SUPER_EXP_BITS + 2, LZC_RESULT_WIDTH);
	localparam [31:0] SHIFT_AMOUNT_WIDTH = $clog2((3 * PRECISION_BITS) + 3);
	localparam [1:0] fpnew_pkg_DISTRIBUTED = 3;
	localparam NUM_INP_REGS = (PipeConfig == fpnew_pkg_BEFORE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 1) / 3 : 0));
	localparam [1:0] fpnew_pkg_INSIDE = 2;
	localparam NUM_MID_REGS = (PipeConfig == fpnew_pkg_INSIDE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 2) / 3 : 0));
	localparam [1:0] fpnew_pkg_AFTER = 1;
	localparam NUM_OUT_REGS = (PipeConfig == fpnew_pkg_AFTER ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? NumPipeRegs / 3 : 0));
	wire [(3 * WIDTH) - 1:0] operands_q;
	wire [1:0] src_fmt_q;
	wire [1:0] dst_fmt_q;
	wire [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH)] inp_pipe_operands_q;
	wire [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0)) + 1) * 3) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) * 3) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)) + 1) * 3) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) * 3) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) * 3 : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) * 3)] inp_pipe_is_boxed_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	wire [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_src_fmt_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	wire [0:NUM_INP_REGS] inp_pipe_tag_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	wire [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	assign inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] = operands_i;
	assign inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS) + 3) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS) + 3) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:12] = is_boxed_i;
	assign inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = rnd_mode_i;
	assign inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = op_i;
	assign inp_pipe_op_mod_q[0] = op_mod_i;
	assign inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = src_fmt_i;
	assign inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = dst_fmt_i;
	assign inp_pipe_tag_q[0] = tag_i;
	assign inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = aux_i;
	assign inp_pipe_valid_q[0] = in_valid_i;
	assign in_ready_o = inp_pipe_ready[0];
	generate
		genvar i;
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3];
	assign src_fmt_q = inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	wire [11:0] fmt_sign;
	wire signed [(12 * SUPER_EXP_BITS) - 1:0] fmt_exponent;
	wire [(12 * SUPER_MAN_BITS) - 1:0] fmt_mantissa;
	wire [95:0] info_q;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	generate
		genvar fmt;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : fmt_init_inputs
			function automatic [1:0] sv2v_cast_3AA4D;
				input reg [1:0] inp;
				sv2v_cast_3AA4D = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_3AA4D(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_3AA4D(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				wire [(3 * FP_WIDTH) - 1:0] trimmed_ops;
				function automatic [1:0] sv2v_cast_3AA4D;
					input reg [1:0] inp;
					sv2v_cast_3AA4D = inp;
				endfunction
				fpnew_classifier #(
					.FpFormat(sv2v_cast_3AA4D(fmt)),
					.NumOperands(3)
				) i_fpnew_classifier(
					.operands_i(trimmed_ops),
					.is_boxed_i(inp_pipe_is_boxed_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS) + fmt : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS) + fmt) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1))) * 3+:3]),
					.info_o(info_q[8 * (fmt * 3)+:24])
				);
				genvar op;
				for (op = 0; op < 3; op = op + 1) begin : gen_operands
					function automatic [31:0] sv2v_cast_32;
						input reg [31:0] inp;
						sv2v_cast_32 = inp;
					endfunction
					assign trimmed_ops[op * sv2v_cast_32(fpnew_pkg_fp_width(sv2v_cast_3AA4D(fmt)))+:sv2v_cast_32(fpnew_pkg_fp_width(sv2v_cast_3AA4D(fmt)))] = operands_q[(op * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH];
					assign fmt_sign[(fmt * 3) + op] = operands_q[(op * WIDTH) + (FP_WIDTH - 1)];
					assign fmt_exponent[((fmt * 3) + op) * SUPER_EXP_BITS+:SUPER_EXP_BITS] = $signed({1'b0, operands_q[(op * WIDTH) + MAN_BITS+:EXP_BITS]});
					assign fmt_mantissa[((fmt * 3) + op) * SUPER_MAN_BITS+:SUPER_MAN_BITS] = {info_q[(((fmt * 3) + op) * 8) + 7], operands_q[(op * WIDTH) + (MAN_BITS - 1)-:MAN_BITS]} << (SUPER_MAN_BITS - MAN_BITS);
				end
			end
			else begin : inactive_format
				function automatic [7:0] sv2v_cast_8;
					input reg [7:0] inp;
					sv2v_cast_8 = inp;
				endfunction
				assign info_q[8 * (fmt * 3)+:24] = {3 {sv2v_cast_8(fpnew_pkg_DONT_CARE)}};
				assign fmt_sign[fmt * 3+:3] = fpnew_pkg_DONT_CARE;
				function automatic signed [SUPER_EXP_BITS - 1:0] sv2v_cast_153A8_signed;
					input reg signed [SUPER_EXP_BITS - 1:0] inp;
					sv2v_cast_153A8_signed = inp;
				endfunction
				assign fmt_exponent[SUPER_EXP_BITS * (fmt * 3)+:SUPER_EXP_BITS * 3] = {3 {sv2v_cast_153A8_signed(fpnew_pkg_DONT_CARE)}};
				function automatic [SUPER_MAN_BITS - 1:0] sv2v_cast_C630A;
					input reg [SUPER_MAN_BITS - 1:0] inp;
					sv2v_cast_C630A = inp;
				endfunction
				assign fmt_mantissa[SUPER_MAN_BITS * (fmt * 3)+:SUPER_MAN_BITS * 3] = {3 {sv2v_cast_C630A(fpnew_pkg_DONT_CARE)}};
			end
		end
	endgenerate
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_a;
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_b;
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_c;
	reg [7:0] info_a;
	reg [7:0] info_b;
	reg [7:0] info_c;
	function automatic [31:0] fpnew_pkg_bias;
		input reg [1:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	localparam [3:0] fpnew_pkg_ADD = 2;
	localparam [3:0] fpnew_pkg_FMADD = 0;
	localparam [3:0] fpnew_pkg_FNMSUB = 1;
	localparam [3:0] fpnew_pkg_MUL = 3;
	function automatic [SUPER_EXP_BITS - 1:0] sv2v_cast_153A8;
		input reg [SUPER_EXP_BITS - 1:0] inp;
		sv2v_cast_153A8 = inp;
	endfunction
	function automatic [SUPER_MAN_BITS - 1:0] sv2v_cast_C630A;
		input reg [SUPER_MAN_BITS - 1:0] inp;
		sv2v_cast_C630A = inp;
	endfunction
	always @(*) begin : op_select
		operand_a = {fmt_sign[src_fmt_q * 3], fmt_exponent[(src_fmt_q * 3) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[(src_fmt_q * 3) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		operand_b = {fmt_sign[(src_fmt_q * 3) + 1], fmt_exponent[((src_fmt_q * 3) + 1) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[((src_fmt_q * 3) + 1) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		operand_c = {fmt_sign[(dst_fmt_q * 3) + 2], fmt_exponent[((dst_fmt_q * 3) + 2) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[((dst_fmt_q * 3) + 2) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		info_a = info_q[(src_fmt_q * 3) * 8+:8];
		info_b = info_q[((src_fmt_q * 3) + 1) * 8+:8];
		info_c = info_q[((dst_fmt_q * 3) + 2) * 8+:8];
		operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] = operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ inp_pipe_op_mod_q[NUM_INP_REGS];
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			fpnew_pkg_FMADD:
				;
			fpnew_pkg_FNMSUB: operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] = ~operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
			fpnew_pkg_ADD: begin
				operand_a = {1'b0, sv2v_cast_153A8(fpnew_pkg_bias(src_fmt_q)), sv2v_cast_C630A(1'sb0)};
				info_a = 8'b10000001;
			end
			fpnew_pkg_MUL: begin
				operand_c = {1'b1, sv2v_cast_153A8(1'sb0), sv2v_cast_C630A(1'sb0)};
				info_c = 8'b00100001;
			end
			default: begin
				operand_a = {fpnew_pkg_DONT_CARE, sv2v_cast_153A8(fpnew_pkg_DONT_CARE), sv2v_cast_C630A(fpnew_pkg_DONT_CARE)};
				operand_b = {fpnew_pkg_DONT_CARE, sv2v_cast_153A8(fpnew_pkg_DONT_CARE), sv2v_cast_C630A(fpnew_pkg_DONT_CARE)};
				operand_c = {fpnew_pkg_DONT_CARE, sv2v_cast_153A8(fpnew_pkg_DONT_CARE), sv2v_cast_C630A(fpnew_pkg_DONT_CARE)};
				info_a = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_b = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_c = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
			end
		endcase
	end
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	wire effective_subtraction;
	wire tentative_sign;
	assign any_operand_inf = |{info_a[4], info_b[4], info_c[4]};
	assign any_operand_nan = |{info_a[3], info_b[3], info_c[3]};
	assign signalling_nan = |{info_a[2], info_b[2], info_c[2]};
	assign effective_subtraction = (operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))]) ^ operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
	assign tentative_sign = operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
	wire [WIDTH - 1:0] special_result;
	wire [4:0] special_status;
	wire result_is_special;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_special_result;
	reg [19:0] fmt_special_status;
	reg [3:0] fmt_result_is_special;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_special_results
			function automatic [1:0] sv2v_cast_3AA4D;
				input reg [1:0] inp;
				sv2v_cast_3AA4D = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_3AA4D(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_3AA4D(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt));
			localparam [EXP_BITS - 1:0] QNAN_EXPONENT = 1'sb1;
			localparam [MAN_BITS - 1:0] QNAN_MANTISSA = 2 ** (MAN_BITS - 1);
			localparam [MAN_BITS - 1:0] ZERO_MANTISSA = 1'sb0;
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : special_results
					reg [FP_WIDTH - 1:0] special_res;
					special_res = {1'b0, QNAN_EXPONENT, QNAN_MANTISSA};
					fmt_special_status[fmt * 5+:5] = {5 {1'sb0}};
					fmt_result_is_special[fmt] = 1'b0;
					if ((info_a[4] && info_b[5]) || (info_a[5] && info_b[4])) begin
						fmt_result_is_special[fmt] = 1'b1;
						fmt_special_status[(fmt * 5) + 4] = 1'b1;
					end
					else if (any_operand_nan) begin
						fmt_result_is_special[fmt] = 1'b1;
						fmt_special_status[(fmt * 5) + 4] = signalling_nan;
					end
					else if (any_operand_inf) begin
						fmt_result_is_special[fmt] = 1'b1;
						if (((info_a[4] || info_b[4]) && info_c[4]) && effective_subtraction)
							fmt_special_status[(fmt * 5) + 4] = 1'b1;
						else if (info_a[4] || info_b[4])
							special_res = {operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))], QNAN_EXPONENT, ZERO_MANTISSA};
						else if (info_c[4])
							special_res = {operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))], QNAN_EXPONENT, ZERO_MANTISSA};
					end
					fmt_special_result[fmt * WIDTH+:WIDTH] = {WIDTH {1'sb1}};
					fmt_special_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH:1] sv2v_tmp_2DFD8;
				assign sv2v_tmp_2DFD8 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_special_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_2DFD8;
				wire [5:1] sv2v_tmp_1FB62;
				assign sv2v_tmp_1FB62 = {5 {1'sb0}};
				always @(*) fmt_special_status[fmt * 5+:5] = sv2v_tmp_1FB62;
				wire [1:1] sv2v_tmp_7823E;
				assign sv2v_tmp_7823E = 1'b0;
				always @(*) fmt_result_is_special[fmt] = sv2v_tmp_7823E;
			end
		end
	endgenerate
	assign result_is_special = fmt_result_is_special[dst_fmt_q];
	assign special_status = fmt_special_status[dst_fmt_q * 5+:5];
	assign special_result = fmt_special_result[dst_fmt_q * WIDTH+:WIDTH];
	wire signed [EXP_WIDTH - 1:0] exponent_a;
	wire signed [EXP_WIDTH - 1:0] exponent_b;
	wire signed [EXP_WIDTH - 1:0] exponent_c;
	wire signed [EXP_WIDTH - 1:0] exponent_addend;
	wire signed [EXP_WIDTH - 1:0] exponent_product;
	wire signed [EXP_WIDTH - 1:0] exponent_difference;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent;
	assign exponent_a = $signed({1'b0, operand_a[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= SUPER_MAN_BITS ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - SUPER_MAN_BITS) + 1 : (SUPER_MAN_BITS - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_b = $signed({1'b0, operand_b[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= SUPER_MAN_BITS ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - SUPER_MAN_BITS) + 1 : (SUPER_MAN_BITS - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_c = $signed({1'b0, operand_c[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= SUPER_MAN_BITS ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - SUPER_MAN_BITS) + 1 : (SUPER_MAN_BITS - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_addend = $signed(exponent_c + $signed({1'b0, ~info_c[7]}));
	assign exponent_product = (info_a[5] || info_b[5] ? 2 - $signed(fpnew_pkg_bias(dst_fmt_q)) : $signed(((((exponent_a + info_a[6]) + exponent_b) + info_b[6]) - (2 * $signed(fpnew_pkg_bias(src_fmt_q)))) + $signed(fpnew_pkg_bias(dst_fmt_q))));
	assign exponent_difference = exponent_addend - exponent_product;
	assign tentative_exponent = (exponent_difference > 0 ? exponent_addend : exponent_product);
	reg [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt;
	always @(*) begin : addend_shift_amount
		if (exponent_difference <= $signed((-2 * PRECISION_BITS) - 1))
			addend_shamt = (3 * PRECISION_BITS) + 4;
		else if (exponent_difference <= $signed(PRECISION_BITS + 2))
			addend_shamt = $unsigned(($signed(PRECISION_BITS) + 3) - exponent_difference);
		else
			addend_shamt = 0;
	end
	wire [PRECISION_BITS - 1:0] mantissa_a;
	wire [PRECISION_BITS - 1:0] mantissa_b;
	wire [PRECISION_BITS - 1:0] mantissa_c;
	wire [(2 * PRECISION_BITS) - 1:0] product;
	wire [(3 * PRECISION_BITS) + 3:0] product_shifted;
	assign mantissa_a = {info_a[7], operand_a[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign mantissa_b = {info_b[7], operand_b[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign mantissa_c = {info_c[7], operand_c[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign product = mantissa_a * mantissa_b;
	assign product_shifted = product << 2;
	wire [(3 * PRECISION_BITS) + 3:0] addend_after_shift;
	wire [PRECISION_BITS - 1:0] addend_sticky_bits;
	wire sticky_before_add;
	wire [(3 * PRECISION_BITS) + 3:0] addend_shifted;
	wire inject_carry_in;
	assign {addend_after_shift, addend_sticky_bits} = (mantissa_c << ((3 * PRECISION_BITS) + 4)) >> addend_shamt;
	assign sticky_before_add = |addend_sticky_bits;
	assign addend_shifted = (effective_subtraction ? ~addend_after_shift : addend_after_shift);
	assign inject_carry_in = effective_subtraction & ~sticky_before_add;
	wire [(3 * PRECISION_BITS) + 4:0] sum_raw;
	wire sum_carry;
	wire [(3 * PRECISION_BITS) + 3:0] sum;
	wire final_sign;
	assign sum_raw = (product_shifted + addend_shifted) + inject_carry_in;
	assign sum_carry = sum_raw[(3 * PRECISION_BITS) + 4];
	assign sum = (effective_subtraction && ~sum_carry ? -sum_raw : sum_raw);
	assign final_sign = (effective_subtraction && (sum_carry == tentative_sign) ? 1'b1 : (effective_subtraction ? 1'b0 : tentative_sign));
	wire effective_subtraction_q;
	wire signed [EXP_WIDTH - 1:0] exponent_product_q;
	wire signed [EXP_WIDTH - 1:0] exponent_difference_q;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent_q;
	wire [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt_q;
	wire sticky_before_add_q;
	wire [(3 * PRECISION_BITS) + 3:0] sum_q;
	wire final_sign_q;
	wire [1:0] dst_fmt_q2;
	wire [2:0] rnd_mode_q;
	wire result_is_special_q;
	wire [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] special_result_q;
	wire [4:0] special_status_q;
	wire [0:NUM_MID_REGS] mid_pipe_eff_sub_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_prod_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_diff_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_tent_exp_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH) + ((NUM_MID_REGS * SHIFT_AMOUNT_WIDTH) - 1) : ((NUM_MID_REGS + 1) * SHIFT_AMOUNT_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * SHIFT_AMOUNT_WIDTH : 0)] mid_pipe_add_shamt_q;
	wire [0:NUM_MID_REGS] mid_pipe_sticky_q;
	wire [(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? ((1 - NUM_MID_REGS) * ((3 * PRECISION_BITS) + 4)) + ((NUM_MID_REGS * ((3 * PRECISION_BITS) + 4)) - 1) : ((1 - NUM_MID_REGS) * (1 - ((3 * PRECISION_BITS) + 3))) + ((((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) - 1)) : (((3 * PRECISION_BITS) + 3) >= 0 ? ((NUM_MID_REGS + 1) * ((3 * PRECISION_BITS) + 4)) - 1 : ((NUM_MID_REGS + 1) * (1 - ((3 * PRECISION_BITS) + 3))) + ((3 * PRECISION_BITS) + 2))):(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? NUM_MID_REGS * ((3 * PRECISION_BITS) + 4) : ((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) : (((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3))] mid_pipe_sum_q;
	wire [0:NUM_MID_REGS] mid_pipe_final_sign_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_dst_fmt_q;
	wire [0:NUM_MID_REGS] mid_pipe_res_is_spec_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) + ((NUM_MID_REGS * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) - 1) : ((NUM_MID_REGS + 1) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) : 0)] mid_pipe_spec_res_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 5) + ((NUM_MID_REGS * 5) - 1) : ((NUM_MID_REGS + 1) * 5) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 5 : 0)] mid_pipe_spec_stat_q;
	wire [0:NUM_MID_REGS] mid_pipe_tag_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * AuxType_AUX_BITS) + ((NUM_MID_REGS * AuxType_AUX_BITS) - 1) : ((NUM_MID_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * AuxType_AUX_BITS : 0)] mid_pipe_aux_q;
	wire [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	assign mid_pipe_eff_sub_q[0] = effective_subtraction;
	assign mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = exponent_product;
	assign mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = exponent_difference;
	assign mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = tentative_exponent;
	assign mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] = addend_shamt;
	assign mid_pipe_sticky_q[0] = sticky_before_add;
	assign mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] = sum;
	assign mid_pipe_final_sign_q[0] = final_sign;
	assign mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	assign mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = dst_fmt_q;
	assign mid_pipe_res_is_spec_q[0] = result_is_special;
	assign mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS] = special_result;
	assign mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 5+:5] = special_status;
	assign mid_pipe_tag_q[0] = inp_pipe_tag_q[NUM_INP_REGS];
	assign mid_pipe_aux_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = inp_pipe_aux_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign mid_pipe_valid_q[0] = inp_pipe_valid_q[NUM_INP_REGS];
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
		end
	endgenerate
	assign effective_subtraction_q = mid_pipe_eff_sub_q[NUM_MID_REGS];
	assign exponent_product_q = mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign exponent_difference_q = mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign tentative_exponent_q = mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign addend_shamt_q = mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH];
	assign sticky_before_add_q = mid_pipe_sticky_q[NUM_MID_REGS];
	assign sum_q = mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))];
	assign final_sign_q = mid_pipe_final_sign_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign dst_fmt_q2 = mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign result_is_special_q = mid_pipe_res_is_spec_q[NUM_MID_REGS];
	assign special_result_q = mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS];
	assign special_status_q = mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 5+:5];
	wire [LOWER_SUM_WIDTH - 1:0] sum_lower;
	wire [LZC_RESULT_WIDTH - 1:0] leading_zero_count;
	wire signed [LZC_RESULT_WIDTH:0] leading_zero_count_sgn;
	wire lzc_zeroes;
	reg [SHIFT_AMOUNT_WIDTH - 1:0] norm_shamt;
	reg signed [EXP_WIDTH - 1:0] normalized_exponent;
	wire [(3 * PRECISION_BITS) + 4:0] sum_shifted;
	reg [PRECISION_BITS:0] final_mantissa;
	reg [(2 * PRECISION_BITS) + 2:0] sum_sticky_bits;
	wire sticky_after_norm;
	reg signed [EXP_WIDTH - 1:0] final_exponent;
	assign sum_lower = sum_q[LOWER_SUM_WIDTH - 1:0];
	lzc #(
		.WIDTH(LOWER_SUM_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(sum_lower),
		.cnt_o(leading_zero_count),
		.empty_o(lzc_zeroes)
	);
	assign leading_zero_count_sgn = $signed({1'b0, leading_zero_count});
	always @(*) begin : norm_shift_amount
		if ((exponent_difference_q <= 0) || (effective_subtraction_q && (exponent_difference_q <= 2))) begin
			if ((((exponent_product_q - leading_zero_count_sgn) + 1) >= 0) && !lzc_zeroes) begin
				norm_shamt = (PRECISION_BITS + 2) + leading_zero_count;
				normalized_exponent = (exponent_product_q - leading_zero_count_sgn) + 1;
			end
			else begin
				norm_shamt = $unsigned($signed((PRECISION_BITS + 2) + exponent_product_q));
				normalized_exponent = 0;
			end
		end
		else begin
			norm_shamt = addend_shamt_q;
			normalized_exponent = tentative_exponent_q;
		end
	end
	assign sum_shifted = sum_q << norm_shamt;
	always @(*) begin : small_norm
		{final_mantissa, sum_sticky_bits} = sum_shifted;
		final_exponent = normalized_exponent;
		if (sum_shifted[(3 * PRECISION_BITS) + 4]) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted >> 1;
			final_exponent = normalized_exponent + 1;
		end
		else if (sum_shifted[(3 * PRECISION_BITS) + 3])
			;
		else if (normalized_exponent > 1) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted << 1;
			final_exponent = normalized_exponent - 1;
		end
		else
			final_exponent = {EXP_WIDTH {1'sb0}};
	end
	assign sticky_after_norm = |{sum_sticky_bits} | sticky_before_add_q;
	wire pre_round_sign;
	wire [(SUPER_EXP_BITS + SUPER_MAN_BITS) - 1:0] pre_round_abs;
	wire [1:0] round_sticky_bits;
	wire of_before_round;
	wire of_after_round;
	wire uf_before_round;
	wire uf_after_round;
	wire [(NUM_FORMATS * (SUPER_EXP_BITS + SUPER_MAN_BITS)) - 1:0] fmt_pre_round_abs;
	wire [7:0] fmt_round_sticky_bits;
	reg [3:0] fmt_of_after_round;
	reg [3:0] fmt_uf_after_round;
	wire rounded_sign;
	wire [(SUPER_EXP_BITS + SUPER_MAN_BITS) - 1:0] rounded_abs;
	wire result_zero;
	assign of_before_round = final_exponent >= ((2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 1);
	assign uf_before_round = final_exponent == 0;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_res_assemble
			function automatic [1:0] sv2v_cast_3AA4D;
				input reg [1:0] inp;
				sv2v_cast_3AA4D = inp;
			endfunction
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_3AA4D(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt));
			wire [EXP_BITS - 1:0] pre_round_exponent;
			wire [MAN_BITS - 1:0] pre_round_mantissa;
			if (FpFmtConfig[fmt]) begin : active_format
				assign pre_round_exponent = (of_before_round ? (2 ** EXP_BITS) - 2 : final_exponent[EXP_BITS - 1:0]);
				function automatic [31:0] sv2v_cast_32;
					input reg [31:0] inp;
					sv2v_cast_32 = inp;
				endfunction
				assign pre_round_mantissa = (of_before_round ? {sv2v_cast_32(fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt))) {1'sb1}} : final_mantissa[SUPER_MAN_BITS-:MAN_BITS]);
				assign fmt_pre_round_abs[fmt * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS] = {pre_round_exponent, pre_round_mantissa};
				assign fmt_round_sticky_bits[(fmt * 2) + 1] = final_mantissa[SUPER_MAN_BITS - MAN_BITS] | of_before_round;
				if (MAN_BITS < SUPER_MAN_BITS) begin : narrow_sticky
					assign fmt_round_sticky_bits[fmt * 2] = (|final_mantissa[(SUPER_MAN_BITS - MAN_BITS) - 1:0] | sticky_after_norm) | of_before_round;
				end
				else begin : normal_sticky
					assign fmt_round_sticky_bits[fmt * 2] = sticky_after_norm | of_before_round;
				end
			end
			else begin : inactive_format
				assign fmt_pre_round_abs[fmt * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS] = {SUPER_EXP_BITS + SUPER_MAN_BITS {fpnew_pkg_DONT_CARE}};
				assign fmt_round_sticky_bits[fmt * 2+:2] = {2 {fpnew_pkg_DONT_CARE}};
			end
		end
	endgenerate
	assign pre_round_sign = final_sign_q;
	assign pre_round_abs = fmt_pre_round_abs[dst_fmt_q2 * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS];
	assign round_sticky_bits = fmt_round_sticky_bits[dst_fmt_q2 * 2+:2];
	fpnew_rounding #(.AbsWidth(SUPER_EXP_BITS + SUPER_MAN_BITS)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(pre_round_sign),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(effective_subtraction_q),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_zero)
	);
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_sign_inject
			function automatic [1:0] sv2v_cast_3AA4D;
				input reg [1:0] inp;
				sv2v_cast_3AA4D = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_3AA4D(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_3AA4D(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_3AA4D(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : post_process
					fmt_uf_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb0}};
					fmt_of_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb1}};
					fmt_result[fmt * WIDTH+:WIDTH] = {WIDTH {1'sb1}};
					fmt_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = {rounded_sign, rounded_abs[(EXP_BITS + MAN_BITS) - 1:0]};
				end
			end
			else begin : inactive_format
				wire [1:1] sv2v_tmp_78FCE;
				assign sv2v_tmp_78FCE = fpnew_pkg_DONT_CARE;
				always @(*) fmt_uf_after_round[fmt] = sv2v_tmp_78FCE;
				wire [1:1] sv2v_tmp_C5A3B;
				assign sv2v_tmp_C5A3B = fpnew_pkg_DONT_CARE;
				always @(*) fmt_of_after_round[fmt] = sv2v_tmp_C5A3B;
				wire [WIDTH:1] sv2v_tmp_E2871;
				assign sv2v_tmp_E2871 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_E2871;
			end
		end
	endgenerate
	assign uf_after_round = fmt_uf_after_round[dst_fmt_q2];
	assign of_after_round = fmt_of_after_round[dst_fmt_q2];
	wire [WIDTH - 1:0] regular_result;
	wire [4:0] regular_status;
	assign regular_result = fmt_result[dst_fmt_q2 * WIDTH+:WIDTH];
	assign regular_status[4] = 1'b0;
	assign regular_status[3] = 1'b0;
	assign regular_status[2] = of_before_round | of_after_round;
	assign regular_status[1] = uf_after_round & regular_status[0];
	assign regular_status[0] = (|round_sticky_bits | of_before_round) | of_after_round;
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (result_is_special_q ? special_result_q : regular_result);
	assign status_d = (result_is_special_q ? special_status_q : regular_status);
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	wire [0:NUM_OUT_REGS] out_pipe_tag_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	wire [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	assign out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = result_d;
	assign out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = status_d;
	assign out_pipe_tag_q[0] = mid_pipe_tag_q[NUM_MID_REGS];
	assign out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = mid_pipe_aux_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_pipe_valid_q[0] = mid_pipe_valid_q[NUM_MID_REGS];
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[NUM_OUT_REGS];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_fma_B2D03 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	function automatic [1:0] sv2v_cast_1ED13;
		input reg [1:0] inp;
		sv2v_cast_1ED13 = inp;
	endfunction
	parameter [1:0] FpFormat = sv2v_cast_1ED13(0);
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire clk_i;
	input wire rst_ni;
	input wire [(3 * WIDTH) - 1:0] operands_i;
	input wire [2:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire tag_i;
	input wire aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [1:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [1:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_bias;
		input reg [1:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	localparam [31:0] BIAS = fpnew_pkg_bias(FpFormat);
	localparam [31:0] PRECISION_BITS = MAN_BITS + 1;
	localparam [31:0] LOWER_SUM_WIDTH = (2 * PRECISION_BITS) + 3;
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(LOWER_SUM_WIDTH);
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	localparam [31:0] EXP_WIDTH = $unsigned(fpnew_pkg_maximum(EXP_BITS + 2, LZC_RESULT_WIDTH));
	localparam [31:0] SHIFT_AMOUNT_WIDTH = $clog2((3 * PRECISION_BITS) + 3);
	localparam [1:0] fpnew_pkg_DISTRIBUTED = 3;
	localparam NUM_INP_REGS = (PipeConfig == fpnew_pkg_BEFORE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 1) / 3 : 0));
	localparam [1:0] fpnew_pkg_INSIDE = 2;
	localparam NUM_MID_REGS = (PipeConfig == fpnew_pkg_INSIDE ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 2) / 3 : 0));
	localparam [1:0] fpnew_pkg_AFTER = 1;
	localparam NUM_OUT_REGS = (PipeConfig == fpnew_pkg_AFTER ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? NumPipeRegs / 3 : 0));
	wire [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH)] inp_pipe_operands_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_is_boxed_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	wire [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	wire [0:NUM_INP_REGS] inp_pipe_tag_q;
	wire [0:NUM_INP_REGS] inp_pipe_aux_q;
	wire [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	assign inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] = operands_i;
	assign inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = is_boxed_i;
	assign inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = rnd_mode_i;
	assign inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = op_i;
	assign inp_pipe_op_mod_q[0] = op_mod_i;
	assign inp_pipe_tag_q[0] = tag_i;
	assign inp_pipe_aux_q[0] = aux_i;
	assign inp_pipe_valid_q[0] = in_valid_i;
	assign in_ready_o = inp_pipe_ready[0];
	generate
		genvar i;
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
		end
	endgenerate
	wire [23:0] info_q;
	fpnew_classifier #(
		.FpFormat(FpFormat),
		.NumOperands(3)
	) i_class_inputs(
		.operands_i(inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3]),
		.is_boxed_i(inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3]),
		.info_o(info_q)
	);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_a;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_b;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_c;
	reg [7:0] info_a;
	reg [7:0] info_b;
	reg [7:0] info_c;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	localparam [3:0] fpnew_pkg_ADD = 2;
	localparam [3:0] fpnew_pkg_FMADD = 0;
	localparam [3:0] fpnew_pkg_FNMSUB = 1;
	localparam [3:0] fpnew_pkg_MUL = 3;
	function automatic [EXP_BITS - 1:0] sv2v_cast_93512;
		input reg [EXP_BITS - 1:0] inp;
		sv2v_cast_93512 = inp;
	endfunction
	function automatic [MAN_BITS - 1:0] sv2v_cast_2A6A2;
		input reg [MAN_BITS - 1:0] inp;
		sv2v_cast_2A6A2 = inp;
	endfunction
	always @(*) begin : op_select
		operand_a = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		operand_b = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 1 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		operand_c = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		info_a = info_q[0+:8];
		info_b = info_q[8+:8];
		info_c = info_q[16+:8];
		operand_c[1 + (EXP_BITS + (MAN_BITS - 1))] = operand_c[1 + (EXP_BITS + (MAN_BITS - 1))] ^ inp_pipe_op_mod_q[NUM_INP_REGS];
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			fpnew_pkg_FMADD:
				;
			fpnew_pkg_FNMSUB: operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] = ~operand_a[1 + (EXP_BITS + (MAN_BITS - 1))];
			fpnew_pkg_ADD: begin
				operand_a = {1'b0, sv2v_cast_93512(BIAS), sv2v_cast_2A6A2(1'sb0)};
				info_a = 8'b10000001;
			end
			fpnew_pkg_MUL: begin
				operand_c = {1'b1, sv2v_cast_93512(1'sb0), sv2v_cast_2A6A2(1'sb0)};
				info_c = 8'b00100001;
			end
			default: begin
				operand_a = {fpnew_pkg_DONT_CARE, sv2v_cast_93512(fpnew_pkg_DONT_CARE), sv2v_cast_2A6A2(fpnew_pkg_DONT_CARE)};
				operand_b = {fpnew_pkg_DONT_CARE, sv2v_cast_93512(fpnew_pkg_DONT_CARE), sv2v_cast_2A6A2(fpnew_pkg_DONT_CARE)};
				operand_c = {fpnew_pkg_DONT_CARE, sv2v_cast_93512(fpnew_pkg_DONT_CARE), sv2v_cast_2A6A2(fpnew_pkg_DONT_CARE)};
				info_a = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_b = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_c = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
			end
		endcase
	end
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	wire effective_subtraction;
	wire tentative_sign;
	assign any_operand_inf = |{info_a[4], info_b[4], info_c[4]};
	assign any_operand_nan = |{info_a[3], info_b[3], info_c[3]};
	assign signalling_nan = |{info_a[2], info_b[2], info_c[2]};
	assign effective_subtraction = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))]) ^ operand_c[1 + (EXP_BITS + (MAN_BITS - 1))];
	assign tentative_sign = operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))];
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] special_result;
	reg [4:0] special_status;
	reg result_is_special;
	always @(*) begin : special_cases
		special_result = {1'b0, sv2v_cast_93512(1'sb1), sv2v_cast_2A6A2(2 ** (MAN_BITS - 1))};
		special_status = {5 {1'sb0}};
		result_is_special = 1'b0;
		if ((info_a[4] && info_b[5]) || (info_a[5] && info_b[4])) begin
			result_is_special = 1'b1;
			special_status[4] = 1'b1;
		end
		else if (any_operand_nan) begin
			result_is_special = 1'b1;
			special_status[4] = signalling_nan;
		end
		else if (any_operand_inf) begin
			result_is_special = 1'b1;
			if (((info_a[4] || info_b[4]) && info_c[4]) && effective_subtraction)
				special_status[4] = 1'b1;
			else if (info_a[4] || info_b[4])
				special_result = {operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))], sv2v_cast_93512(1'sb1), sv2v_cast_2A6A2(1'sb0)};
			else if (info_c[4])
				special_result = {operand_c[1 + (EXP_BITS + (MAN_BITS - 1))], sv2v_cast_93512(1'sb1), sv2v_cast_2A6A2(1'sb0)};
		end
	end
	wire signed [EXP_WIDTH - 1:0] exponent_a;
	wire signed [EXP_WIDTH - 1:0] exponent_b;
	wire signed [EXP_WIDTH - 1:0] exponent_c;
	wire signed [EXP_WIDTH - 1:0] exponent_addend;
	wire signed [EXP_WIDTH - 1:0] exponent_product;
	wire signed [EXP_WIDTH - 1:0] exponent_difference;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent;
	assign exponent_a = $signed({1'b0, operand_a[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_b = $signed({1'b0, operand_b[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_c = $signed({1'b0, operand_c[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= MAN_BITS ? ((EXP_BITS + (MAN_BITS - 1)) - MAN_BITS) + 1 : (MAN_BITS - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_addend = $signed(exponent_c + $signed({1'b0, ~info_c[7]}));
	assign exponent_product = (info_a[5] || info_b[5] ? 2 - $signed(BIAS) : $signed((((exponent_a + info_a[6]) + exponent_b) + info_b[6]) - $signed(BIAS)));
	assign exponent_difference = exponent_addend - exponent_product;
	assign tentative_exponent = (exponent_difference > 0 ? exponent_addend : exponent_product);
	reg [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt;
	always @(*) begin : addend_shift_amount
		if (exponent_difference <= $signed((-2 * PRECISION_BITS) - 1))
			addend_shamt = (3 * PRECISION_BITS) + 4;
		else if (exponent_difference <= $signed(PRECISION_BITS + 2))
			addend_shamt = $unsigned(($signed(PRECISION_BITS) + 3) - exponent_difference);
		else
			addend_shamt = 0;
	end
	wire [PRECISION_BITS - 1:0] mantissa_a;
	wire [PRECISION_BITS - 1:0] mantissa_b;
	wire [PRECISION_BITS - 1:0] mantissa_c;
	wire [(2 * PRECISION_BITS) - 1:0] product;
	wire [(3 * PRECISION_BITS) + 3:0] product_shifted;
	assign mantissa_a = {info_a[7], operand_a[MAN_BITS - 1-:MAN_BITS]};
	assign mantissa_b = {info_b[7], operand_b[MAN_BITS - 1-:MAN_BITS]};
	assign mantissa_c = {info_c[7], operand_c[MAN_BITS - 1-:MAN_BITS]};
	assign product = mantissa_a * mantissa_b;
	assign product_shifted = product << 2;
	wire [(3 * PRECISION_BITS) + 3:0] addend_after_shift;
	wire [PRECISION_BITS - 1:0] addend_sticky_bits;
	wire sticky_before_add;
	wire [(3 * PRECISION_BITS) + 3:0] addend_shifted;
	wire inject_carry_in;
	assign {addend_after_shift, addend_sticky_bits} = (mantissa_c << ((3 * PRECISION_BITS) + 4)) >> addend_shamt;
	assign sticky_before_add = |addend_sticky_bits;
	assign addend_shifted = (effective_subtraction ? ~addend_after_shift : addend_after_shift);
	assign inject_carry_in = effective_subtraction & ~sticky_before_add;
	wire [(3 * PRECISION_BITS) + 4:0] sum_raw;
	wire sum_carry;
	wire [(3 * PRECISION_BITS) + 3:0] sum;
	wire final_sign;
	assign sum_raw = (product_shifted + addend_shifted) + inject_carry_in;
	assign sum_carry = sum_raw[(3 * PRECISION_BITS) + 4];
	assign sum = (effective_subtraction && ~sum_carry ? -sum_raw : sum_raw);
	assign final_sign = (effective_subtraction && (sum_carry == tentative_sign) ? 1'b1 : (effective_subtraction ? 1'b0 : tentative_sign));
	wire effective_subtraction_q;
	wire signed [EXP_WIDTH - 1:0] exponent_product_q;
	wire signed [EXP_WIDTH - 1:0] exponent_difference_q;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent_q;
	wire [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt_q;
	wire sticky_before_add_q;
	wire [(3 * PRECISION_BITS) + 3:0] sum_q;
	wire final_sign_q;
	wire [2:0] rnd_mode_q;
	wire result_is_special_q;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] special_result_q;
	wire [4:0] special_status_q;
	wire [0:NUM_MID_REGS] mid_pipe_eff_sub_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_prod_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_diff_q;
	wire signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_tent_exp_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH) + ((NUM_MID_REGS * SHIFT_AMOUNT_WIDTH) - 1) : ((NUM_MID_REGS + 1) * SHIFT_AMOUNT_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * SHIFT_AMOUNT_WIDTH : 0)] mid_pipe_add_shamt_q;
	wire [0:NUM_MID_REGS] mid_pipe_sticky_q;
	wire [(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? ((1 - NUM_MID_REGS) * ((3 * PRECISION_BITS) + 4)) + ((NUM_MID_REGS * ((3 * PRECISION_BITS) + 4)) - 1) : ((1 - NUM_MID_REGS) * (1 - ((3 * PRECISION_BITS) + 3))) + ((((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) - 1)) : (((3 * PRECISION_BITS) + 3) >= 0 ? ((NUM_MID_REGS + 1) * ((3 * PRECISION_BITS) + 4)) - 1 : ((NUM_MID_REGS + 1) * (1 - ((3 * PRECISION_BITS) + 3))) + ((3 * PRECISION_BITS) + 2))):(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? NUM_MID_REGS * ((3 * PRECISION_BITS) + 4) : ((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) : (((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3))] mid_pipe_sum_q;
	wire [0:NUM_MID_REGS] mid_pipe_final_sign_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	wire [0:NUM_MID_REGS] mid_pipe_res_is_spec_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_MID_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_MID_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] mid_pipe_spec_res_q;
	wire [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 5) + ((NUM_MID_REGS * 5) - 1) : ((NUM_MID_REGS + 1) * 5) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 5 : 0)] mid_pipe_spec_stat_q;
	wire [0:NUM_MID_REGS] mid_pipe_tag_q;
	wire [0:NUM_MID_REGS] mid_pipe_aux_q;
	wire [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	assign mid_pipe_eff_sub_q[0] = effective_subtraction;
	assign mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = exponent_product;
	assign mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = exponent_difference;
	assign mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = tentative_exponent;
	assign mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] = addend_shamt;
	assign mid_pipe_sticky_q[0] = sticky_before_add;
	assign mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] = sum;
	assign mid_pipe_final_sign_q[0] = final_sign;
	assign mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	assign mid_pipe_res_is_spec_q[0] = result_is_special;
	assign mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = special_result;
	assign mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 5+:5] = special_status;
	assign mid_pipe_tag_q[0] = inp_pipe_tag_q[NUM_INP_REGS];
	assign mid_pipe_aux_q[0] = inp_pipe_aux_q[NUM_INP_REGS];
	assign mid_pipe_valid_q[0] = inp_pipe_valid_q[NUM_INP_REGS];
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
		end
	endgenerate
	assign effective_subtraction_q = mid_pipe_eff_sub_q[NUM_MID_REGS];
	assign exponent_product_q = mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign exponent_difference_q = mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign tentative_exponent_q = mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign addend_shamt_q = mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH];
	assign sticky_before_add_q = mid_pipe_sticky_q[NUM_MID_REGS];
	assign sum_q = mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))];
	assign final_sign_q = mid_pipe_final_sign_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign result_is_special_q = mid_pipe_res_is_spec_q[NUM_MID_REGS];
	assign special_result_q = mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign special_status_q = mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 5+:5];
	wire [LOWER_SUM_WIDTH - 1:0] sum_lower;
	wire [LZC_RESULT_WIDTH - 1:0] leading_zero_count;
	wire signed [LZC_RESULT_WIDTH:0] leading_zero_count_sgn;
	wire lzc_zeroes;
	reg [SHIFT_AMOUNT_WIDTH - 1:0] norm_shamt;
	reg signed [EXP_WIDTH - 1:0] normalized_exponent;
	wire [(3 * PRECISION_BITS) + 4:0] sum_shifted;
	reg [PRECISION_BITS:0] final_mantissa;
	reg [(2 * PRECISION_BITS) + 2:0] sum_sticky_bits;
	wire sticky_after_norm;
	reg signed [EXP_WIDTH - 1:0] final_exponent;
	assign sum_lower = sum_q[LOWER_SUM_WIDTH - 1:0];
	lzc #(
		.WIDTH(LOWER_SUM_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(sum_lower),
		.cnt_o(leading_zero_count),
		.empty_o(lzc_zeroes)
	);
	assign leading_zero_count_sgn = $signed({1'b0, leading_zero_count});
	always @(*) begin : norm_shift_amount
		if ((exponent_difference_q <= 0) || (effective_subtraction_q && (exponent_difference_q <= 2))) begin
			if ((((exponent_product_q - leading_zero_count_sgn) + 1) >= 0) && !lzc_zeroes) begin
				norm_shamt = (PRECISION_BITS + 2) + leading_zero_count;
				normalized_exponent = (exponent_product_q - leading_zero_count_sgn) + 1;
			end
			else begin
				norm_shamt = $unsigned(($signed(PRECISION_BITS) + 2) + exponent_product_q);
				normalized_exponent = 0;
			end
		end
		else begin
			norm_shamt = addend_shamt_q;
			normalized_exponent = tentative_exponent_q;
		end
	end
	assign sum_shifted = sum_q << norm_shamt;
	always @(*) begin : small_norm
		{final_mantissa[23:0], sum_sticky_bits} = sum_shifted;
		final_exponent = normalized_exponent;
		if (sum_shifted[(3 * PRECISION_BITS) + 4]) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted >> 1;
			final_exponent = normalized_exponent + 1;
		end
		else if (sum_shifted[(3 * PRECISION_BITS) + 3])
			;
		else if (normalized_exponent > 1) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted << 1;
			final_exponent = normalized_exponent - 1;
		end
		else
			final_exponent = {EXP_WIDTH {1'sb0}};
	end
	assign sticky_after_norm = |{sum_sticky_bits} | sticky_before_add_q;
	wire pre_round_sign;
	wire [EXP_BITS - 1:0] pre_round_exponent;
	wire [MAN_BITS - 1:0] pre_round_mantissa;
	wire [(EXP_BITS + MAN_BITS) - 1:0] pre_round_abs;
	wire [1:0] round_sticky_bits;
	wire of_before_round;
	wire of_after_round;
	wire uf_before_round;
	wire uf_after_round;
	wire result_zero;
	wire rounded_sign;
	wire [(EXP_BITS + MAN_BITS) - 1:0] rounded_abs;
	assign of_before_round = final_exponent >= ((2 ** EXP_BITS) - 1);
	assign uf_before_round = final_exponent == 0;
	assign pre_round_sign = final_sign_q;
	assign pre_round_exponent = (of_before_round ? (2 ** EXP_BITS) - 2 : $unsigned(final_exponent[EXP_BITS - 1:0]));
	assign pre_round_mantissa = (of_before_round ? {MAN_BITS {1'sb1}} : final_mantissa[MAN_BITS:1]);
	assign pre_round_abs = {pre_round_exponent, pre_round_mantissa};
	assign round_sticky_bits = (of_before_round ? 2'b11 : {final_mantissa[0], sticky_after_norm});
	fpnew_rounding #(.AbsWidth(EXP_BITS + MAN_BITS)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(pre_round_sign),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(effective_subtraction_q),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_zero)
	);
	assign uf_after_round = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb0}};
	assign of_after_round = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) {1'sb1}};
	wire [WIDTH - 1:0] regular_result;
	wire [4:0] regular_status;
	assign regular_result = {rounded_sign, rounded_abs};
	assign regular_status[4] = 1'b0;
	assign regular_status[3] = 1'b0;
	assign regular_status[2] = of_before_round | of_after_round;
	assign regular_status[1] = uf_after_round & regular_status[0];
	assign regular_status[0] = (|round_sticky_bits | of_before_round) | of_after_round;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (result_is_special_q ? special_result_q : regular_result);
	assign status_d = (result_is_special_q ? special_status_q : regular_status);
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_OUT_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] out_pipe_result_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	wire [0:NUM_OUT_REGS] out_pipe_tag_q;
	wire [0:NUM_OUT_REGS] out_pipe_aux_q;
	wire [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	assign out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = result_d;
	assign out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = status_d;
	assign out_pipe_tag_q[0] = mid_pipe_tag_q[NUM_MID_REGS];
	assign out_pipe_aux_q[0] = mid_pipe_aux_q[NUM_MID_REGS];
	assign out_pipe_valid_q[0] = mid_pipe_valid_q[NUM_MID_REGS];
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[NUM_OUT_REGS];
	assign aux_o = out_pipe_aux_q[NUM_OUT_REGS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_noncomp_6DFAC (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	class_mask_o,
	is_class_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	function automatic [1:0] sv2v_cast_F7742;
		input reg [1:0] inp;
		sv2v_cast_F7742 = inp;
	endfunction
	parameter [1:0] FpFormat = sv2v_cast_F7742(0);
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire clk_i;
	input wire rst_ni;
	input wire [(2 * WIDTH) - 1:0] operands_i;
	input wire [1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire tag_i;
	input wire aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [9:0] class_mask_o;
	output wire is_class_o;
	output wire tag_o;
	output wire aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [1:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [1:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	localparam [1:0] fpnew_pkg_DISTRIBUTED = 3;
	localparam [1:0] fpnew_pkg_INSIDE = 2;
	localparam NUM_INP_REGS = ((PipeConfig == fpnew_pkg_BEFORE) || (PipeConfig == fpnew_pkg_INSIDE) ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? (NumPipeRegs + 1) / 2 : 0));
	localparam [1:0] fpnew_pkg_AFTER = 1;
	localparam NUM_OUT_REGS = (PipeConfig == fpnew_pkg_AFTER ? NumPipeRegs : (PipeConfig == fpnew_pkg_DISTRIBUTED ? NumPipeRegs / 2 : 0));
	wire [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH)] inp_pipe_operands_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)] inp_pipe_is_boxed_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	wire [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	wire [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	wire [0:NUM_INP_REGS] inp_pipe_tag_q;
	wire [0:NUM_INP_REGS] inp_pipe_aux_q;
	wire [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	assign inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] = operands_i;
	assign inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2+:2] = is_boxed_i;
	assign inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = rnd_mode_i;
	assign inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = op_i;
	assign inp_pipe_op_mod_q[0] = op_mod_i;
	assign inp_pipe_tag_q[0] = tag_i;
	assign inp_pipe_aux_q[0] = aux_i;
	assign inp_pipe_valid_q[0] = in_valid_i;
	assign in_ready_o = inp_pipe_ready[0];
	generate
		genvar i;
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
		end
	endgenerate
	wire [15:0] info_q;
	fpnew_classifier #(
		.FpFormat(FpFormat),
		.NumOperands(2)
	) i_class_a(
		.operands_i(inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2]),
		.is_boxed_i(inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2+:2]),
		.info_o(info_q)
	);
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_a;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_b;
	wire [7:0] info_a;
	wire [7:0] info_b;
	assign operand_a = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1))) * WIDTH+:WIDTH];
	assign operand_b = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1))) * WIDTH+:WIDTH];
	assign info_a = info_q[0+:8];
	assign info_b = info_q[8+:8];
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	assign any_operand_inf = |{info_a[4], info_b[4]};
	assign any_operand_nan = |{info_a[3], info_b[3]};
	assign signalling_nan = |{info_a[2], info_b[2]};
	wire operands_equal;
	wire operand_a_smaller;
	assign operands_equal = (operand_a == operand_b) || (info_a[5] && info_b[5]);
	assign operand_a_smaller = (operand_a < operand_b) ^ (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] || operand_b[1 + (EXP_BITS + (MAN_BITS - 1))]);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] sgnj_result;
	wire [4:0] sgnj_status;
	wire sgnj_extension_bit;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	localparam [2:0] fpnew_pkg_RDN = 3'b010;
	localparam [2:0] fpnew_pkg_RNE = 3'b000;
	localparam [2:0] fpnew_pkg_RTZ = 3'b001;
	localparam [2:0] fpnew_pkg_RUP = 3'b011;
	function automatic [EXP_BITS - 1:0] sv2v_cast_92F9C;
		input reg [EXP_BITS - 1:0] inp;
		sv2v_cast_92F9C = inp;
	endfunction
	function automatic [MAN_BITS - 1:0] sv2v_cast_5145F;
		input reg [MAN_BITS - 1:0] inp;
		sv2v_cast_5145F = inp;
	endfunction
	always @(*) begin : sign_injections
		reg sign_a;
		reg sign_b;
		sgnj_result = operand_a;
		if (!info_a[0])
			sgnj_result = {1'b0, sv2v_cast_92F9C(1'sb1), sv2v_cast_5145F(2 ** (MAN_BITS - 1))};
		sign_a = operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] & info_a[0];
		sign_b = operand_b[1 + (EXP_BITS + (MAN_BITS - 1))] & info_b[0];
		case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
			fpnew_pkg_RNE: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = sign_b;
			fpnew_pkg_RTZ: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = ~sign_b;
			fpnew_pkg_RDN: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = sign_a ^ sign_b;
			fpnew_pkg_RUP: sgnj_result = operand_a;
			default: sgnj_result = {fpnew_pkg_DONT_CARE, sv2v_cast_92F9C(fpnew_pkg_DONT_CARE), sv2v_cast_5145F(fpnew_pkg_DONT_CARE)};
		endcase
	end
	assign sgnj_status = {5 {1'sb0}};
	assign sgnj_extension_bit = (inp_pipe_op_mod_q[NUM_INP_REGS] ? sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] : 1'b1);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] minmax_result;
	reg [4:0] minmax_status;
	wire minmax_extension_bit;
	always @(*) begin : min_max
		minmax_status = {5 {1'sb0}};
		minmax_status[4] = signalling_nan;
		if (info_a[3] && info_b[3])
			minmax_result = {1'b0, sv2v_cast_92F9C(1'sb1), sv2v_cast_5145F(2 ** (MAN_BITS - 1))};
		else if (info_a[3])
			minmax_result = operand_b;
		else if (info_b[3])
			minmax_result = operand_a;
		else
			case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
				fpnew_pkg_RNE: minmax_result = (operand_a_smaller ? operand_a : operand_b);
				fpnew_pkg_RTZ: minmax_result = (operand_a_smaller ? operand_b : operand_a);
				default: minmax_result = {fpnew_pkg_DONT_CARE, sv2v_cast_92F9C(fpnew_pkg_DONT_CARE), sv2v_cast_5145F(fpnew_pkg_DONT_CARE)};
			endcase
	end
	assign minmax_extension_bit = 1'b1;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] cmp_result;
	reg [4:0] cmp_status;
	wire cmp_extension_bit;
	always @(*) begin : comparisons
		cmp_result = {(1 + EXP_BITS) + MAN_BITS {1'sb0}};
		cmp_status = {5 {1'sb0}};
		if (signalling_nan)
			cmp_status[4] = 1'b1;
		else
			case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
				fpnew_pkg_RNE:
					if (any_operand_nan)
						cmp_status[4] = 1'b1;
					else
						cmp_result = (operand_a_smaller | operands_equal) ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				fpnew_pkg_RTZ:
					if (any_operand_nan)
						cmp_status[4] = 1'b1;
					else
						cmp_result = (operand_a_smaller & ~operands_equal) ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				fpnew_pkg_RDN:
					if (any_operand_nan)
						cmp_result = inp_pipe_op_mod_q[NUM_INP_REGS];
					else
						cmp_result = operands_equal ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				default: cmp_result = {fpnew_pkg_DONT_CARE, sv2v_cast_92F9C(fpnew_pkg_DONT_CARE), sv2v_cast_5145F(fpnew_pkg_DONT_CARE)};
			endcase
	end
	assign cmp_extension_bit = 1'b0;
	wire [4:0] class_status;
	wire class_extension_bit;
	reg [9:0] class_mask_d;
	localparam [9:0] fpnew_pkg_NEGINF = 10'b0000000001;
	localparam [9:0] fpnew_pkg_NEGNORM = 10'b0000000010;
	localparam [9:0] fpnew_pkg_NEGSUBNORM = 10'b0000000100;
	localparam [9:0] fpnew_pkg_NEGZERO = 10'b0000001000;
	localparam [9:0] fpnew_pkg_POSINF = 10'b0010000000;
	localparam [9:0] fpnew_pkg_POSNORM = 10'b0001000000;
	localparam [9:0] fpnew_pkg_POSSUBNORM = 10'b0000100000;
	localparam [9:0] fpnew_pkg_POSZERO = 10'b0000010000;
	localparam [9:0] fpnew_pkg_QNAN = 10'b1000000000;
	localparam [9:0] fpnew_pkg_SNAN = 10'b0100000000;
	always @(*) begin : classify
		if (info_a[7])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? fpnew_pkg_NEGNORM : fpnew_pkg_POSNORM);
		else if (info_a[6])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? fpnew_pkg_NEGSUBNORM : fpnew_pkg_POSSUBNORM);
		else if (info_a[5])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? fpnew_pkg_NEGZERO : fpnew_pkg_POSZERO);
		else if (info_a[4])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? fpnew_pkg_NEGINF : fpnew_pkg_POSINF);
		else if (info_a[3])
			class_mask_d = (info_a[2] ? fpnew_pkg_SNAN : fpnew_pkg_QNAN);
		else
			class_mask_d = fpnew_pkg_QNAN;
	end
	assign class_status = {5 {1'sb0}};
	assign class_extension_bit = 1'b0;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] result_d;
	reg [4:0] status_d;
	reg extension_bit_d;
	wire is_class_d;
	localparam [3:0] fpnew_pkg_CLASSIFY = 9;
	localparam [3:0] fpnew_pkg_CMP = 8;
	localparam [3:0] fpnew_pkg_MINMAX = 7;
	localparam [3:0] fpnew_pkg_SGNJ = 6;
	always @(*) begin : select_result
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			fpnew_pkg_SGNJ: begin
				result_d = sgnj_result;
				status_d = sgnj_status;
				extension_bit_d = sgnj_extension_bit;
			end
			fpnew_pkg_MINMAX: begin
				result_d = minmax_result;
				status_d = minmax_status;
				extension_bit_d = minmax_extension_bit;
			end
			fpnew_pkg_CMP: begin
				result_d = cmp_result;
				status_d = cmp_status;
				extension_bit_d = cmp_extension_bit;
			end
			fpnew_pkg_CLASSIFY: begin
				result_d = {fpnew_pkg_DONT_CARE, sv2v_cast_92F9C(fpnew_pkg_DONT_CARE), sv2v_cast_5145F(fpnew_pkg_DONT_CARE)};
				status_d = class_status;
				extension_bit_d = class_extension_bit;
			end
			default: begin
				result_d = {fpnew_pkg_DONT_CARE, sv2v_cast_92F9C(fpnew_pkg_DONT_CARE), sv2v_cast_5145F(fpnew_pkg_DONT_CARE)};
				status_d = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				extension_bit_d = fpnew_pkg_DONT_CARE;
			end
		endcase
	end
	assign is_class_d = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == fpnew_pkg_CLASSIFY;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_OUT_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] out_pipe_result_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	wire [0:NUM_OUT_REGS] out_pipe_extension_bit_q;
	wire [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 10) + ((NUM_OUT_REGS * 10) - 1) : ((NUM_OUT_REGS + 1) * 10) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 10 : 0)] out_pipe_class_mask_q;
	wire [0:NUM_OUT_REGS] out_pipe_is_class_q;
	wire [0:NUM_OUT_REGS] out_pipe_tag_q;
	wire [0:NUM_OUT_REGS] out_pipe_aux_q;
	wire [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	assign out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = result_d;
	assign out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = status_d;
	assign out_pipe_extension_bit_q[0] = extension_bit_d;
	assign out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 10+:10] = class_mask_d;
	assign out_pipe_is_class_q[0] = is_class_d;
	assign out_pipe_tag_q[0] = inp_pipe_tag_q[NUM_INP_REGS];
	assign out_pipe_aux_q[0] = inp_pipe_aux_q[NUM_INP_REGS];
	assign out_pipe_valid_q[0] = inp_pipe_valid_q[NUM_INP_REGS];
	assign inp_pipe_ready[NUM_INP_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = out_pipe_extension_bit_q[NUM_OUT_REGS];
	assign class_mask_o = out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 10+:10];
	assign is_class_o = out_pipe_is_class_q[NUM_OUT_REGS];
	assign tag_o = out_pipe_tag_q[NUM_OUT_REGS];
	assign aux_o = out_pipe_aux_q[NUM_OUT_REGS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, out_pipe_valid_q};
endmodule
/*
module fpnew_opgroup_block_BE2AB (
	clk_i,
	rst_ni,
	IS_FIRST_MERGED,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [1:0] fpnew_pkg_ADDMUL = 0;
	parameter [1:0] OpGroup = fpnew_pkg_ADDMUL;
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtMask = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtMask = 1'sb1;
	parameter [127:0] FmtPipeRegs = {fpnew_pkg_NUM_FP_FORMATS {32'd0}};
	localparam [1:0] fpnew_pkg_PARALLEL = 1;
	parameter [7:0] FmtUnitTypes = {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}};
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	localparam [1:0] fpnew_pkg_CONV = 3;
	localparam [1:0] fpnew_pkg_DIVSQRT = 1;
	localparam [1:0] fpnew_pkg_NONCOMP = 2;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL: fpnew_pkg_num_operands = 3;
			fpnew_pkg_DIVSQRT: fpnew_pkg_num_operands = 2;
			fpnew_pkg_NONCOMP: fpnew_pkg_num_operands = 2;
			fpnew_pkg_CONV: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire IS_FIRST_MERGED;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	wire [3:0] fmt_in_ready;
	wire [3:0] fmt_out_valid;
	wire [3:0] fmt_out_ready;
	wire [3:0] fmt_busy;
	wire [((Width + 6) >= 0 ? (4 * (Width + 7)) - 1 : (4 * (1 - (Width + 6))) + (Width + 5)):((Width + 6) >= 0 ? 0 : Width + 6)] fmt_outputs;
	assign in_ready_o = in_valid_i & fmt_in_ready[dst_fmt_i];
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	localparam [1:0] fpnew_pkg_MERGED = 2;
	function automatic fpnew_pkg_any_enabled_multi;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_115
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED)) begin
							fpnew_pkg_any_enabled_multi = 1'b1;
							_sv2v_jump = 2'b11;
						end
					end
			end
			if (_sv2v_jump != 2'b11)
				_sv2v_jump = 2'b00;
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_any_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic [1:0] sv2v_cast_F6DD6;
		input reg [1:0] inp;
		sv2v_cast_F6DD6 = inp;
	endfunction
	function automatic [1:0] fpnew_pkg_get_first_enabled_multi;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_116
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED)) begin
							fpnew_pkg_get_first_enabled_multi = sv2v_cast_F6DD6(i);
							_sv2v_jump = 2'b11;
						end
					end
			end
			if (_sv2v_jump != 2'b11)
				_sv2v_jump = 2'b00;
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_get_first_enabled_multi = sv2v_cast_F6DD6(0);
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic fpnew_pkg_is_first_enabled_multi;
		input reg [1:0] fmt;
		input reg [7:0] types;
		input reg [0:3] cfg;
		//reg [0:1] _sv2v_jump;
		reg temp;
		reg [1:0] check;
		reg [31:0] i;
		begin: checking
			check[0]=00;
			check[1]=01;
			check[2]=10;
			check[3]=11;
		end
		begin: func
			check[0]=00;
                        check[1]=01;
                        check[2]=10;
                        check[3]=11;
			//_sv2v_jump = 2'b00;
			//begin : sv2v_autoblock_117
				//reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1) begin
					//if (_sv2v_jump < 2'b10) begin
						//_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED)) begin
							temp = check[i]==fmt; // (sv2v_cast_F6DD6(i) == fmt);
							//_sv2v_jump = 2'b11;
						end else begin
							temp = 1'b0;
						end
					//end
				end
				fpnew_pkg_is_first_enabled_multi = temp;
			//end
			//if (_sv2v_jump != 2'b11)
				//_sv2v_jump = 2'b00;
			//if (_sv2v_jump == 2'b00) begin
				//fpnew_pkg_is_first_enabled_multi = 1'b0;
				//_sv2v_jump = 2'b11;
			//end
		end
	endfunction
	localparam [1:0] fpnew_pkg_DISABLED = 0;
	function automatic signed [31:0] sv2v_cast_32_signed;
                input reg signed [31:0] inp;
        	sv2v_cast_32_signed = inp;
        endfunction
	generate
		genvar fmt;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_parallel_slices
			localparam [0:0] ANY_MERGED = fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask);
			function automatic [1:0] sv2v_cast_F6DD6;
				input reg [1:0] inp;
				sv2v_cast_F6DD6 = inp;
			endfunction
			//localparam [0:0] IS_FIRST_MERGED = fpnew_pkg_is_first_enabled_multi(sv2v_cast_F6DD6(fmt), FmtUnitTypes, FpFmtMask);
			if (FpFmtMask[fmt] && (FmtUnitTypes[(3 - fmt) * 2+:2] == fpnew_pkg_PARALLEL)) begin : active_format
				wire in_valid;
				assign in_valid = in_valid_i & (dst_fmt_i == fmt);
				function automatic [1:0] sv2v_cast_F6DD6;
					input reg [1:0] inp;
					sv2v_cast_F6DD6 = inp;
				endfunction
				fpnew_opgroup_fmt_slice_30528 #(
					.OpGroup(OpGroup),
					.FpFormat(sv2v_cast_F6DD6(fmt)),
					.Width(Width),
					.EnableVectors(EnableVectors),
					.NumPipeRegs(FmtPipeRegs[(3 - fmt) * 32+:32]),
					.PipeConfig(PipeConfig)
				) i_fmt_slice(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.operands_i(operands_i),
					.is_boxed_i(is_boxed_i[fmt * NUM_OPERANDS+:NUM_OPERANDS]),
					.rnd_mode_i(rnd_mode_i),
					.op_i(op_i),
					.op_mod_i(op_mod_i),
					.vectorial_op_i(vectorial_op_i),
					.tag_i(tag_i),
					.in_valid_i(in_valid),
					.in_ready_o(fmt_in_ready[fmt]),
					.flush_i(flush_i),
					.result_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))]),
					.status_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5]),
					.extension_bit_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
					.tag_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
					.out_valid_o(fmt_out_valid[fmt]),
					.out_ready_i(fmt_out_ready[fmt]),
					.busy_o(fmt_busy[fmt])
				);
			end
			else if ((FpFmtMask[fmt] && ANY_MERGED) && !IS_FIRST_MERGED) begin : merged_unused
				localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
				function automatic signed [31:0] sv2v_cast_32_signed;
					input reg signed [31:0] inp;
					sv2v_cast_32_signed = inp;
				endfunction
				assign fmt_in_ready[fmt] = fmt_in_ready[sv2v_cast_32_signed(FMT)];
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
			else if (!FpFmtMask[fmt] || (FmtUnitTypes[(3 - fmt) * 2+:2] == fpnew_pkg_DISABLED)) begin : disable_fmt
				assign fmt_in_ready[fmt] = 1'b0;
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
		end
	endgenerate
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [31:0] fpnew_pkg_get_num_regs_multi;
		input reg [127:0] regs;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_118
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED))
						res = fpnew_pkg_maximum(res, regs[(3 - i) * 32+:32]);
			end
			fpnew_pkg_get_num_regs_multi = res;
		end
	endfunction
	generate
		if (fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask)) begin : gen_merged_slice
			localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam REG = fpnew_pkg_get_num_regs_multi(FmtPipeRegs, FmtUnitTypes, FpFmtMask);
			wire in_valid;
			assign in_valid = in_valid_i & (FmtUnitTypes[(3 - dst_fmt_i) * 2+:2] == fpnew_pkg_MERGED);
			fpnew_opgroup_multifmt_slice_7C482 #(
				.OpGroup(OpGroup),
				.Width(Width),
				.FpFmtConfig(FpFmtMask),
				.IntFmtConfig(IntFmtMask),
				.EnableVectors(EnableVectors),
				.NumPipeRegs(REG),
				.PipeConfig(PipeConfig)
			) i_multifmt_slice(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i),
				.is_boxed_i(is_boxed_i),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(fmt_in_ready[FMT]),
				.flush_i(flush_i),
				.result_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))]),
				.status_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5]),
				.extension_bit_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
				.tag_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
				.out_valid_o(fmt_out_valid[FMT]),
				.out_ready_i(fmt_out_ready[FMT]),
				.busy_o(fmt_busy[FMT])
			);
		end
	endgenerate
	wire [Width + 6:0] arbiter_output;
	rr_arb_tree_252F1_F315E #(
		.DataType_Width(Width),
		.NumIn(NUM_FORMATS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i({$unsigned(2) {1'sb0}}),
		.req_i(fmt_out_valid),
		.gnt_o(fmt_out_ready),
		.data_i(fmt_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output),
		.idx_o()
	);
	assign result_o = arbiter_output[Width + 6-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))];
	assign status_o = arbiter_output[6-:5];
	assign extension_bit_o = arbiter_output[1];
	assign tag_o = arbiter_output[0];
	assign busy_o = |fmt_busy;
endmodule*/
module fpnew_opgroup_block_BE2AB (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [1:0] fpnew_pkg_ADDMUL = 0;
	parameter [1:0] OpGroup = fpnew_pkg_ADDMUL;
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtMask = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtMask = 1'sb1;
	parameter [127:0] FmtPipeRegs = {fpnew_pkg_NUM_FP_FORMATS {32'd0}};
	localparam [1:0] fpnew_pkg_PARALLEL = 1;
	parameter [7:0] FmtUnitTypes = {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}};
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	localparam [1:0] fpnew_pkg_CONV = 3;
	localparam [1:0] fpnew_pkg_DIVSQRT = 1;
	localparam [1:0] fpnew_pkg_NONCOMP = 2;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL: fpnew_pkg_num_operands = 3;
			fpnew_pkg_DIVSQRT: fpnew_pkg_num_operands = 2;
			fpnew_pkg_NONCOMP: fpnew_pkg_num_operands = 2;
			fpnew_pkg_CONV: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	wire [3:0] fmt_in_ready;
	wire [3:0] fmt_out_valid;
	wire [3:0] fmt_out_ready;
	wire [3:0] fmt_busy;
	wire [((Width + 6) >= 0 ? (4 * (Width + 7)) - 1 : (4 * (1 - (Width + 6))) + (Width + 5)):((Width + 6) >= 0 ? 0 : Width + 6)] fmt_outputs;
	assign in_ready_o = in_valid_i & fmt_in_ready[dst_fmt_i];
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	localparam [1:0] fpnew_pkg_MERGED = 2;
	function automatic fpnew_pkg_any_enabled_multi;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_115
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED)) begin
							fpnew_pkg_any_enabled_multi = 1'b1;
							_sv2v_jump = 2'b11;
						end
					end
			end
			if (_sv2v_jump != 2'b11)
				_sv2v_jump = 2'b00;
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_any_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic [1:0] sv2v_cast_F6DD6;
		input reg [1:0] inp;
		sv2v_cast_F6DD6 = inp;
	endfunction
	function automatic [1:0] fpnew_pkg_get_first_enabled_multi;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_116
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED)) begin
							fpnew_pkg_get_first_enabled_multi = sv2v_cast_F6DD6(i);
							_sv2v_jump = 2'b11;
						end
					end
			end
			if (_sv2v_jump != 2'b11)
				_sv2v_jump = 2'b00;
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_get_first_enabled_multi = sv2v_cast_F6DD6(0);
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic [31:0] fpnew_pkg_merged_gen;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL, fpnew_pkg_NONCOMP: fpnew_pkg_merged_gen = 0;
			fpnew_pkg_DIVSQRT, fpnew_pkg_CONV: fpnew_pkg_merged_gen = 1;
			default: fpnew_pkg_merged_gen = 0;
		endcase
	endfunction
	localparam [1:0] fpnew_pkg_DISABLED = 0;
	generate
		genvar fmt;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_parallel_slices
			localparam [0:0] ANY_MERGED = fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam [0:0] IS_FIRST_MERGED = fpnew_pkg_merged_gen(OpGroup);
			if (FpFmtMask[fmt] && (FmtUnitTypes[(3 - fmt) * 2+:2] == fpnew_pkg_PARALLEL)) begin : active_format
				wire in_valid;
				assign in_valid = in_valid_i & (dst_fmt_i == fmt);
				function automatic [1:0] sv2v_cast_F6DD6;
					input reg [1:0] inp;
					sv2v_cast_F6DD6 = inp;
				endfunction
				fpnew_opgroup_fmt_slice_30528 #(
					.OpGroup(OpGroup),
					.FpFormat(sv2v_cast_F6DD6(fmt)),
					.Width(Width),
					.EnableVectors(EnableVectors),
					.NumPipeRegs(FmtPipeRegs[(3 - fmt) * 32+:32]),
					.PipeConfig(PipeConfig)
				) i_fmt_slice(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.operands_i(operands_i),
					.is_boxed_i(is_boxed_i[fmt * NUM_OPERANDS+:NUM_OPERANDS]),
					.rnd_mode_i(rnd_mode_i),
					.op_i(op_i),
					.op_mod_i(op_mod_i),
					.vectorial_op_i(vectorial_op_i),
					.tag_i(tag_i),
					.in_valid_i(in_valid),
					.in_ready_o(fmt_in_ready[fmt]),
					.flush_i(flush_i),
					.result_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))]),
					.status_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5]),
					.extension_bit_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
					.tag_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
					.out_valid_o(fmt_out_valid[fmt]),
					.out_ready_i(fmt_out_ready[fmt]),
					.busy_o(fmt_busy[fmt])
				);
			end
			else if ((FpFmtMask[fmt] && ANY_MERGED) && !IS_FIRST_MERGED) begin : merged_unused
				localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
				function automatic signed [31:0] sv2v_cast_32_signed;
					input reg signed [31:0] inp;
					sv2v_cast_32_signed = inp;
				endfunction
				assign fmt_in_ready[fmt] = fmt_in_ready[sv2v_cast_32_signed(FMT)];
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
			else if (!FpFmtMask[fmt] || (FmtUnitTypes[(3 - fmt) * 2+:2] == fpnew_pkg_DISABLED)) begin : disable_fmt
				assign fmt_in_ready[fmt] = 1'b0;
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
		end
	endgenerate
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [31:0] fpnew_pkg_get_num_regs_multi;
		input reg [127:0] regs;
		input reg [7:0] types;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_117
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i] && (types[(3 - i) * 2+:2] == fpnew_pkg_MERGED))
						res = fpnew_pkg_maximum(res, regs[(3 - i) * 32+:32]);
			end
			fpnew_pkg_get_num_regs_multi = res;
		end
	endfunction
	generate
		if (fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask)) begin : gen_merged_slice
			localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam REG = fpnew_pkg_get_num_regs_multi(FmtPipeRegs, FmtUnitTypes, FpFmtMask);
			wire in_valid;
			assign in_valid = in_valid_i & (FmtUnitTypes[(3 - dst_fmt_i) * 2+:2] == fpnew_pkg_MERGED);
			fpnew_opgroup_multifmt_slice_7C482 #(
				.OpGroup(OpGroup),
				.Width(Width),
				.FpFmtConfig(FpFmtMask),
				.IntFmtConfig(IntFmtMask),
				.EnableVectors(EnableVectors),
				.NumPipeRegs(REG),
				.PipeConfig(PipeConfig)
			) i_multifmt_slice(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i),
				.is_boxed_i(is_boxed_i),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(fmt_in_ready[FMT]),
				.flush_i(flush_i),
				.result_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))]),
				.status_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width) : ((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width)) + 4)-:5]),
				.extension_bit_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
				.tag_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
				.out_valid_o(fmt_out_valid[FMT]),
				.out_ready_i(fmt_out_ready[FMT]),
				.busy_o(fmt_busy[FMT])
			);
		end
	endgenerate
	wire [Width + 6:0] arbiter_output;
	rr_arb_tree_252F1_F315E #(
		.DataType_Width(Width),
		.NumIn(NUM_FORMATS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i({$unsigned(2) {1'sb0}}),
		.req_i(fmt_out_valid),
		.gnt_o(fmt_out_ready),
		.data_i(fmt_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output),
		.idx_o()
	);
	assign result_o = arbiter_output[Width + 6-:((Width + 6) >= 7 ? Width : 8 - (Width + 6))];
	assign status_o = arbiter_output[6-:5];
	assign extension_bit_o = arbiter_output[1];
	assign tag_o = arbiter_output[0];
	assign busy_o = |fmt_busy;
endmodule
module fpnew_opgroup_fmt_slice_30528 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [1:0] fpnew_pkg_ADDMUL = 0;
	parameter [1:0] OpGroup = fpnew_pkg_ADDMUL;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	function automatic [1:0] sv2v_cast_CA66C;
		input reg [1:0] inp;
		sv2v_cast_CA66C = inp;
	endfunction
	parameter [1:0] FpFormat = sv2v_cast_CA66C(0);
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [1:0] fpnew_pkg_CONV = 3;
	localparam [1:0] fpnew_pkg_DIVSQRT = 1;
	localparam [1:0] fpnew_pkg_NONCOMP = 2;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL: fpnew_pkg_num_operands = 3;
			fpnew_pkg_DIVSQRT: fpnew_pkg_num_operands = 2;
			fpnew_pkg_NONCOMP: fpnew_pkg_num_operands = 2;
			fpnew_pkg_CONV: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [NUM_OPERANDS - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output reg [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(FpFormat);
	function automatic [31:0] fpnew_pkg_num_lanes;
		input reg [31:0] width;
		input reg [1:0] fmt;
		input reg vec;
		fpnew_pkg_num_lanes = (vec ? width / fpnew_pkg_fp_width(fmt) : 1);
	endfunction
	localparam [31:0] NUM_LANES = fpnew_pkg_num_lanes(Width, FpFormat, EnableVectors);
	wire [NUM_LANES - 1:0] lane_in_ready;
	wire [NUM_LANES - 1:0] lane_out_valid;
	wire vectorial_op;
	wire [(NUM_LANES * FP_WIDTH) - 1:0] slice_result;
	wire [Width - 1:0] slice_regular_result;
	wire [Width - 1:0] slice_class_result;
	wire [Width - 1:0] slice_vec_class_result;
	wire [(NUM_LANES * 5) - 1:0] lane_status;
	wire [NUM_LANES - 1:0] lane_ext_bit;
	wire [(NUM_LANES * 10) - 1:0] lane_class_mask;
	wire [NUM_LANES - 1:0] lane_tags;
	wire [NUM_LANES - 1:0] lane_vectorial;
	wire [NUM_LANES - 1:0] lane_busy;
	wire [NUM_LANES - 1:0] lane_is_class;
	wire result_is_vector;
	wire result_is_class;
	assign in_ready_o = lane_in_ready[0];
	assign vectorial_op = vectorial_op_i & EnableVectors;
	localparam [9:0] fpnew_pkg_NEGINF = 10'b0000000001;
	localparam [9:0] fpnew_pkg_NEGNORM = 10'b0000000010;
	localparam [9:0] fpnew_pkg_NEGSUBNORM = 10'b0000000100;
	localparam [9:0] fpnew_pkg_NEGZERO = 10'b0000001000;
	localparam [9:0] fpnew_pkg_POSINF = 10'b0010000000;
	localparam [9:0] fpnew_pkg_POSNORM = 10'b0001000000;
	localparam [9:0] fpnew_pkg_POSSUBNORM = 10'b0000100000;
	localparam [9:0] fpnew_pkg_POSZERO = 10'b0000010000;
	localparam [9:0] fpnew_pkg_QNAN = 10'b1000000000;
	localparam [9:0] fpnew_pkg_SNAN = 10'b0100000000;
	generate
		genvar lane;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (lane = 0; lane < sv2v_cast_32_signed(NUM_LANES); lane = lane + 1) begin : gen_num_lanes
			wire [FP_WIDTH - 1:0] local_result;
			wire local_sign;
			if ((lane == 0) || EnableVectors) begin : active_lane
				wire in_valid;
				wire out_valid;
				wire out_ready;
				reg [(NUM_OPERANDS * FP_WIDTH) - 1:0] local_operands;
				wire [FP_WIDTH - 1:0] op_result;
				wire [4:0] op_status;
				assign in_valid = in_valid_i & ((lane == 0) | vectorial_op);
				function automatic signed [31:0] sv2v_cast_32_signed;
					input reg signed [31:0] inp;
					sv2v_cast_32_signed = inp;
				endfunction
				always @(*) begin : prepare_input
					begin : sv2v_autoblock_119
						reg signed [31:0] i;
						for (i = 0; i < sv2v_cast_32_signed(NUM_OPERANDS); i = i + 1)
							local_operands[i * FP_WIDTH+:FP_WIDTH] = operands_i[(i * Width) + (((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (($unsigned(lane) + 1) * FP_WIDTH) - 1 : (((($unsigned(lane) + 1) * FP_WIDTH) - 1) + (((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (((($unsigned(lane) + 1) * FP_WIDTH) - 1) - ($unsigned(lane) * FP_WIDTH)) + 1 : (($unsigned(lane) * FP_WIDTH) - ((($unsigned(lane) + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:(((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (((($unsigned(lane) + 1) * FP_WIDTH) - 1) - ($unsigned(lane) * FP_WIDTH)) + 1 : (($unsigned(lane) * FP_WIDTH) - ((($unsigned(lane) + 1) * FP_WIDTH) - 1)) + 1)];
					end
				end
				if (OpGroup == fpnew_pkg_ADDMUL) begin : lane_instance
					fpnew_fma_B2D03 #(
						.FpFormat(FpFormat),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fma(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i[NUM_OPERANDS - 1:0]),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.tag_i(tag_i),
						.aux_i(vectorial_op),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane]),
						.aux_o(lane_vectorial[lane]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
					assign lane_is_class[lane] = 1'b0;
					assign lane_class_mask[lane * 10+:10] = fpnew_pkg_NEGINF;
				end
				else if (OpGroup == fpnew_pkg_DIVSQRT) ;
				else if (OpGroup == fpnew_pkg_NONCOMP) begin : lane_instance
					fpnew_noncomp_6DFAC #(
						.FpFormat(FpFormat),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_noncomp(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i[NUM_OPERANDS - 1:0]),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.tag_i(tag_i),
						.aux_i(vectorial_op),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.class_mask_o(lane_class_mask[lane * 10+:10]),
						.is_class_o(lane_is_class[lane]),
						.tag_o(lane_tags[lane]),
						.aux_o(lane_vectorial[lane]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				assign out_ready = out_ready_i & ((lane == 0) | result_is_vector);
				assign lane_out_valid[lane] = out_valid & ((lane == 0) | result_is_vector);
				assign local_result = (lane_out_valid[lane] ? op_result : {FP_WIDTH {lane_ext_bit[0]}});
				assign lane_status[lane * 5+:5] = (lane_out_valid[lane] ? op_status : {5 {1'sb0}});
			end
			else begin
				assign lane_out_valid[lane] = 1'b0;
				assign lane_in_ready[lane] = 1'b0;
				assign local_result = {FP_WIDTH {lane_ext_bit[0]}};
				assign lane_status[lane * 5+:5] = {5 {1'sb0}};
				assign lane_busy[lane] = 1'b0;
				assign lane_is_class[lane] = 1'b0;
			end
			assign slice_result[(($unsigned(lane) + 1) * FP_WIDTH) - 1:$unsigned(lane) * FP_WIDTH] = local_result;
			if (((lane + 1) * 8) <= Width) begin : vectorial_class
				assign local_sign = (((lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGINF) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGNORM)) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGSUBNORM)) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGZERO);
				assign slice_vec_class_result[((lane + 1) * 8) - 1:lane * 8] = {local_sign, ~local_sign, lane_class_mask[lane * 10+:10] == fpnew_pkg_QNAN, lane_class_mask[lane * 10+:10] == fpnew_pkg_SNAN, (lane_class_mask[lane * 10+:10] == fpnew_pkg_POSZERO) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGZERO), (lane_class_mask[lane * 10+:10] == fpnew_pkg_POSSUBNORM) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGSUBNORM), (lane_class_mask[lane * 10+:10] == fpnew_pkg_POSNORM) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGNORM), (lane_class_mask[lane * 10+:10] == fpnew_pkg_POSINF) || (lane_class_mask[lane * 10+:10] == fpnew_pkg_NEGINF)};
			end
		end
	endgenerate
	assign result_is_vector = lane_vectorial[0];
	assign result_is_class = lane_is_class[0];
	assign slice_regular_result = $signed({extension_bit_o, slice_result});
	localparam [31:0] CLASS_VEC_BITS = ((NUM_LANES * 8) > Width ? 8 * (Width / 8) : NUM_LANES * 8);
	generate
		if (CLASS_VEC_BITS < Width) begin : pad_vectorial_class
			assign slice_vec_class_result[Width - 1:CLASS_VEC_BITS] = {((Width - 1) >= CLASS_VEC_BITS ? ((Width - 1) - CLASS_VEC_BITS) + 1 : (CLASS_VEC_BITS - (Width - 1)) + 1) {1'sb0}};
		end
	endgenerate
	assign slice_class_result = (result_is_vector ? slice_vec_class_result : lane_class_mask[0+:10]);
	assign result_o = (result_is_class ? slice_class_result : slice_regular_result);
	assign extension_bit_o = lane_ext_bit[0];
	assign tag_o = lane_tags[0];
	assign busy_o = |lane_busy;
	assign out_valid_o = lane_out_valid[0];
	always @(*) begin : output_processing
		reg [4:0] temp_status;
		temp_status = {5 {1'sb0}};
		begin : sv2v_autoblock_120
			reg signed [31:0] i;
			for (i = 0; i < sv2v_cast_32_signed(NUM_LANES); i = i + 1)
				temp_status = temp_status | lane_status[i * 5+:5];
		end
		status_o = temp_status;
	end
endmodule
module fpnew_opgroup_multifmt_slice_7C482 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [1:0] fpnew_pkg_CONV = 3;
	parameter [1:0] OpGroup = fpnew_pkg_CONV;
	parameter [31:0] Width = 64;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	parameter [0:3] FpFmtConfig = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtConfig = 1'sb1;
	parameter [0:0] EnableVectors = 1'b1;
	parameter [31:0] NumPipeRegs = 0;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	parameter [1:0] PipeConfig = fpnew_pkg_BEFORE;
	localparam [1:0] fpnew_pkg_ADDMUL = 0;
	localparam [1:0] fpnew_pkg_DIVSQRT = 1;
	localparam [1:0] fpnew_pkg_NONCOMP = 2;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL: fpnew_pkg_num_operands = 3;
			fpnew_pkg_DIVSQRT: fpnew_pkg_num_operands = 2;
			fpnew_pkg_NONCOMP: fpnew_pkg_num_operands = 2;
			fpnew_pkg_CONV: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output reg [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [1:0] sv2v_cast_38622;
		input reg [1:0] inp;
		sv2v_cast_38622 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_121
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_38622(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] MAX_FP_WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	localparam [1:0] fpnew_pkg_INT16 = 1;
	localparam [1:0] fpnew_pkg_INT32 = 2;
	localparam [1:0] fpnew_pkg_INT64 = 3;
	localparam [1:0] fpnew_pkg_INT8 = 0;
	function automatic [31:0] fpnew_pkg_int_width;
		input reg [1:0] ifmt;
		case (ifmt)
			fpnew_pkg_INT8: fpnew_pkg_int_width = 8;
			fpnew_pkg_INT16: fpnew_pkg_int_width = 16;
			fpnew_pkg_INT32: fpnew_pkg_int_width = 32;
			fpnew_pkg_INT64: fpnew_pkg_int_width = 64;
		endcase
	endfunction
	function automatic [1:0] sv2v_cast_E880F;
		input reg [1:0] inp;
		sv2v_cast_E880F = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_int_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_122
				reg signed [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					if (cfg[ifmt])
						res = fpnew_pkg_maximum(res, fpnew_pkg_int_width(sv2v_cast_E880F(ifmt)));
			end
			fpnew_pkg_max_int_width = res;
		end
	endfunction
	localparam [31:0] MAX_INT_WIDTH = fpnew_pkg_max_int_width(IntFmtConfig);
	function automatic signed [31:0] fpnew_pkg_minimum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_minimum = (a < b ? a : b);
	endfunction
	function automatic [31:0] fpnew_pkg_min_fp_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = fpnew_pkg_max_fp_width(cfg);
			begin : sv2v_autoblock_123
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_minimum(res, fpnew_pkg_fp_width(sv2v_cast_38622(i))));
			end
			fpnew_pkg_min_fp_width = res;
		end
	endfunction
	function automatic [31:0] fpnew_pkg_max_num_lanes;
		input reg [31:0] width;
		input reg [0:3] cfg;
		input reg vec;
		fpnew_pkg_max_num_lanes = (vec ? width / fpnew_pkg_min_fp_width(cfg) : 1);
	endfunction
	localparam [31:0] NUM_LANES = fpnew_pkg_max_num_lanes(Width, FpFmtConfig, 1'b1);
	localparam [31:0] NUM_INT_FORMATS = fpnew_pkg_NUM_INT_FORMATS;
	localparam [31:0] FMT_BITS = fpnew_pkg_maximum(2, 2);
	localparam [31:0] AUX_BITS = FMT_BITS + 2;
	wire [NUM_LANES - 1:0] lane_in_ready;
	wire [NUM_LANES - 1:0] lane_out_valid;
	wire vectorial_op;
	wire [FMT_BITS - 1:0] dst_fmt;
	wire [AUX_BITS - 1:0] aux_data;
	wire dst_fmt_is_int;
	wire dst_is_cpk;
	wire [1:0] dst_vec_op;
	wire [2:0] target_aux_d;
	wire [2:0] target_aux_q;
	wire is_up_cast;
	wire is_down_cast;
	wire [(NUM_FORMATS * Width) - 1:0] fmt_slice_result;
	wire [(NUM_INT_FORMATS * Width) - 1:0] ifmt_slice_result;
	wire [Width - 1:0] conv_slice_result;
	wire [Width - 1:0] conv_target_d;
	wire [Width - 1:0] conv_target_q;
	wire [(NUM_LANES * 5) - 1:0] lane_status;
	wire [NUM_LANES - 1:0] lane_ext_bit;
	wire [NUM_LANES - 1:0] lane_tags;
	wire [(NUM_LANES * AUX_BITS) - 1:0] lane_aux;
	wire [NUM_LANES - 1:0] lane_busy;
	wire result_is_vector;
	wire [FMT_BITS - 1:0] result_fmt;
	wire result_fmt_is_int;
	wire result_is_cpk;
	wire [1:0] result_vec_op;
	assign in_ready_o = lane_in_ready[0];
	assign vectorial_op = vectorial_op_i & EnableVectors;
	localparam [3:0] fpnew_pkg_F2I = 11;
	assign dst_fmt_is_int = (OpGroup == fpnew_pkg_CONV) & (op_i == fpnew_pkg_F2I);
	localparam [3:0] fpnew_pkg_CPKAB = 13;
	localparam [3:0] fpnew_pkg_CPKCD = 14;
	assign dst_is_cpk = (OpGroup == fpnew_pkg_CONV) & ((op_i == fpnew_pkg_CPKAB) || (op_i == fpnew_pkg_CPKCD));
	assign dst_vec_op = (OpGroup == fpnew_pkg_CONV) & {op_i == fpnew_pkg_CPKCD, op_mod_i};
	assign is_up_cast = fpnew_pkg_fp_width(dst_fmt_i) > fpnew_pkg_fp_width(src_fmt_i);
	assign is_down_cast = fpnew_pkg_fp_width(dst_fmt_i) < fpnew_pkg_fp_width(src_fmt_i);
	assign dst_fmt = (dst_fmt_is_int ? int_fmt_i : dst_fmt_i);
	assign aux_data = {dst_fmt_is_int, vectorial_op, dst_fmt};
	assign target_aux_d = {dst_vec_op, dst_is_cpk};
	generate
		if (OpGroup == fpnew_pkg_CONV) begin : conv_target
			assign conv_target_d = (dst_is_cpk ? operands_i[2 * Width+:Width] : operands_i[Width+:Width]);
		end
	endgenerate
	reg [3:0] is_boxed_1op;
	reg [7:0] is_boxed_2op;
	always @(*) begin : boxed_2op
		begin : sv2v_autoblock_124
			reg signed [31:0] fmt;
			for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1)
				begin
					is_boxed_1op[fmt] = is_boxed_i[fmt * NUM_OPERANDS];
					is_boxed_2op[fmt * 2+:2] = is_boxed_i[(fmt * NUM_OPERANDS) + 1-:2];
				end
		end
	end
	localparam [0:3] fpnew_pkg_CPK_FORMATS = 5'b11000;
	function automatic [0:3] fpnew_pkg_get_conv_lane_formats;
		input reg [31:0] width;
		input reg [0:3] cfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [31:0] fmt;
		begin
			for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
				res[fmt] = cfg[fmt] && (((width / fpnew_pkg_fp_width(sv2v_cast_38622(fmt))) > lane_no) || (fpnew_pkg_CPK_FORMATS[fmt] && (lane_no < 2)));
			fpnew_pkg_get_conv_lane_formats = res;
		end
	endfunction
	function automatic [0:3] fpnew_pkg_get_conv_lane_int_formats;
		input reg [31:0] width;
		input reg [0:3] cfg;
		input reg [0:3] icfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [0:3] lanefmts;
		begin
			res = {4 {1'sb0}};
			lanefmts = fpnew_pkg_get_conv_lane_formats(width, cfg, lane_no);
			begin : sv2v_autoblock_125
				reg [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					begin : sv2v_autoblock_126
						reg [31:0] fmt;
						for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
							res[ifmt] = res[ifmt] | ((icfg[ifmt] && lanefmts[fmt]) && (fpnew_pkg_fp_width(sv2v_cast_38622(fmt)) == fpnew_pkg_int_width(sv2v_cast_E880F(ifmt))));
					end
			end
			fpnew_pkg_get_conv_lane_int_formats = res;
		end
	endfunction
	function automatic [0:3] fpnew_pkg_get_lane_formats;
		input reg [31:0] width;
		input reg [0:3] cfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [31:0] fmt;
		begin
			for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
				res[fmt] = cfg[fmt] & ((width / fpnew_pkg_fp_width(sv2v_cast_38622(fmt))) > lane_no);
			fpnew_pkg_get_lane_formats = res;
		end
	endfunction
	function automatic [0:3] fpnew_pkg_get_lane_int_formats;
		input reg [31:0] width;
		input reg [0:3] cfg;
		input reg [0:3] icfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [0:3] lanefmts;
		begin
			res = {4 {1'sb0}};
			lanefmts = fpnew_pkg_get_lane_formats(width, cfg, lane_no);
			begin : sv2v_autoblock_127
				reg [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					begin : sv2v_autoblock_128
						reg [31:0] fmt;
						for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
							if (fpnew_pkg_fp_width(sv2v_cast_38622(fmt)) == fpnew_pkg_int_width(sv2v_cast_E880F(ifmt)))
								res[ifmt] = res[ifmt] | (icfg[ifmt] && lanefmts[fmt]);
					end
			end
			fpnew_pkg_get_lane_int_formats = res;
		end
	endfunction
	localparam [3:0] fpnew_pkg_F2F = 10;
	localparam [3:0] fpnew_pkg_I2F = 12;
	generate
		genvar lane;
		function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction
		for (lane = 0; lane < sv2v_cast_32_signed(NUM_LANES); lane = lane + 1) begin : gen_num_lanes
			localparam [31:0] LANE = $unsigned(lane);
			localparam [0:3] ACTIVE_FORMATS = fpnew_pkg_get_lane_formats(Width, FpFmtConfig, LANE);
			localparam [0:3] ACTIVE_INT_FORMATS = fpnew_pkg_get_lane_int_formats(Width, FpFmtConfig, IntFmtConfig, LANE);
			localparam [31:0] MAX_WIDTH = fpnew_pkg_max_fp_width(ACTIVE_FORMATS);
			localparam [0:3] CONV_FORMATS = fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, LANE);
			localparam [0:3] CONV_INT_FORMATS = fpnew_pkg_get_conv_lane_int_formats(Width, FpFmtConfig, IntFmtConfig, LANE);
			localparam [31:0] CONV_WIDTH = fpnew_pkg_max_fp_width(CONV_FORMATS);
			localparam [0:3] LANE_FORMATS = (OpGroup == fpnew_pkg_CONV ? CONV_FORMATS : ACTIVE_FORMATS);
			localparam [31:0] LANE_WIDTH = (OpGroup == fpnew_pkg_CONV ? CONV_WIDTH : MAX_WIDTH);
			wire [LANE_WIDTH - 1:0] local_result;
			if ((lane == 0) || EnableVectors) begin : active_lane
				wire in_valid;
				wire out_valid;
				wire out_ready;
				reg [(NUM_OPERANDS * LANE_WIDTH) - 1:0] local_operands;
				wire [LANE_WIDTH - 1:0] op_result;
				wire [4:0] op_status;
				assign in_valid = in_valid_i & ((lane == 0) | vectorial_op);
				function automatic [31:0] sv2v_cast_32;
					input reg [31:0] inp;
					sv2v_cast_32 = inp;
				endfunction
				function automatic [3:0] sv2v_cast_4;
					input reg [3:0] inp;
					sv2v_cast_4 = inp;
				endfunction
				always @(*) begin : prepare_input
					begin : sv2v_autoblock_129
						reg [31:0] i;
						for (i = 0; i < NUM_OPERANDS; i = i + 1)
							local_operands[i * sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))] = operands_i[i * Width+:Width] >> (LANE * fpnew_pkg_fp_width(src_fmt_i));
					end
					if (OpGroup == fpnew_pkg_CONV)
						if (op_i == fpnew_pkg_I2F)
							local_operands[0+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))] = operands_i[0+:Width] >> (LANE * fpnew_pkg_int_width(int_fmt_i));
						else if (op_i == fpnew_pkg_F2F) begin
							if ((vectorial_op && op_mod_i) && is_up_cast)
								local_operands[0+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))] = operands_i[0+:Width] >> ((LANE * fpnew_pkg_fp_width(src_fmt_i)) + (MAX_FP_WIDTH / 2));
						end
						else if (dst_is_cpk)
							if (lane == 1)
								local_operands[0+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))] = operands_i[Width + (LANE_WIDTH - 1)-:LANE_WIDTH];
				end
				if (OpGroup == fpnew_pkg_ADDMUL) begin : lane_instance
					fpnew_fma_multi_E4D0A_BE123 #(
						.AuxType_AUX_BITS(AUX_BITS),
						.FpFmtConfig(LANE_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_fma_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.src_fmt_i(src_fmt_i),
						.dst_fmt_i(dst_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				else if (OpGroup == fpnew_pkg_DIVSQRT) begin : lane_instance
					function automatic [31:0] sv2v_cast_32;
						input reg [31:0] inp;
						sv2v_cast_32 = inp;
					endfunction
					function automatic [3:0] sv2v_cast_4;
						input reg [3:0] inp;
						sv2v_cast_4 = inp;
					endfunction
					fpnew_divsqrt_multi_28154_735ED #(
						.AuxType_AUX_BITS(AUX_BITS),
						.FpFmtConfig(LANE_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_divsqrt_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands[0+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))))) * 2]),
						.is_boxed_i(is_boxed_2op),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.dst_fmt_i(dst_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				else if (OpGroup == fpnew_pkg_NONCOMP) ;
				else if (OpGroup == fpnew_pkg_CONV) begin : lane_instance
					function automatic [31:0] sv2v_cast_32;
						input reg [31:0] inp;
						sv2v_cast_32 = inp;
					endfunction
					function automatic [3:0] sv2v_cast_4;
						input reg [3:0] inp;
						sv2v_cast_4 = inp;
					endfunction
					fpnew_cast_multi_8A35C_87530 #(
						.AuxType_AUX_BITS(AUX_BITS),
						.FpFmtConfig(LANE_FORMATS),
						.IntFmtConfig(CONV_INT_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_cast_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands[0+:sv2v_cast_32((OpGroup == fpnew_pkg_CONV ? sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) : sv2v_cast_32(fpnew_pkg_max_fp_width(sv2v_cast_4(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))))))]),
						.is_boxed_i(is_boxed_1op),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.src_fmt_i(src_fmt_i),
						.dst_fmt_i(dst_fmt_i),
						.int_fmt_i(int_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				assign out_ready = out_ready_i & ((lane == 0) | result_is_vector);
				assign lane_out_valid[lane] = out_valid & ((lane == 0) | result_is_vector);
				function automatic [3:0] sv2v_cast_18C91;
					input reg [3:0] inp;
					sv2v_cast_18C91 = inp;
				endfunction
				assign local_result = (lane_out_valid[lane] ? op_result : {(OpGroup == fpnew_pkg_CONV ? fpnew_pkg_max_fp_width(sv2v_cast_18C91(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))) : fpnew_pkg_max_fp_width(sv2v_cast_18C91(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) {lane_ext_bit[0]}});
				assign lane_status[lane * 5+:5] = (lane_out_valid[lane] ? op_status : {5 {1'sb0}});
			end
			else begin : inactive_lane
				assign lane_out_valid[lane] = 1'b0;
				assign lane_in_ready[lane] = 1'b0;
				function automatic [3:0] sv2v_cast_18C91;
					input reg [3:0] inp;
					sv2v_cast_18C91 = inp;
				endfunction
				function automatic [31:0] sv2v_cast_32;
					input reg [31:0] inp;
					sv2v_cast_32 = inp;
				endfunction
				assign local_result = {(OpGroup == fpnew_pkg_CONV ? fpnew_pkg_max_fp_width(sv2v_cast_18C91(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))) : fpnew_pkg_max_fp_width(sv2v_cast_18C91(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) {lane_ext_bit[0]}};
				assign lane_status[lane * 5+:5] = {5 {1'sb0}};
				assign lane_busy[lane] = 1'b0;
			end
			genvar fmt;
			for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1) begin : pack_fp_result
				function automatic [1:0] sv2v_cast_38622;
					input reg [1:0] inp;
					sv2v_cast_38622 = inp;
				endfunction
				localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_38622(fmt));
				if (ACTIVE_FORMATS[fmt]) begin
					assign fmt_slice_result[(fmt * Width) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((LANE + 1) * FP_WIDTH) - 1 : ((((LANE + 1) * FP_WIDTH) - 1) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)] = local_result[FP_WIDTH - 1:0];
				end
				else if (((LANE + 1) * FP_WIDTH) <= Width) begin
					assign fmt_slice_result[(fmt * Width) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((LANE + 1) * FP_WIDTH) - 1 : ((((LANE + 1) * FP_WIDTH) - 1) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)] = {((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1) {lane_ext_bit[LANE]}};
				end
				else if ((LANE * FP_WIDTH) < Width) assign fmt_slice_result[(fmt * Width) + ((Width - 1) >= (LANE * FP_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1)] = {((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1) {lane_ext_bit[LANE]}};
			end
			if (OpGroup == fpnew_pkg_CONV) begin : int_results_enabled
				genvar ifmt;
				for (ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt = ifmt + 1) begin : pack_int_result
					function automatic [1:0] sv2v_cast_E880F;
						input reg [1:0] inp;
						sv2v_cast_E880F = inp;
					endfunction
					localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_E880F(ifmt));
					if (ACTIVE_INT_FORMATS[ifmt]) begin
						assign ifmt_slice_result[(ifmt * Width) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((LANE + 1) * INT_WIDTH) - 1 : ((((LANE + 1) * INT_WIDTH) - 1) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)] = local_result[INT_WIDTH - 1:0];
					end
					else if (((LANE + 1) * INT_WIDTH) <= Width) begin
						assign ifmt_slice_result[(ifmt * Width) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((LANE + 1) * INT_WIDTH) - 1 : ((((LANE + 1) * INT_WIDTH) - 1) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)] = {((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1) {1'sb0}};
					end
					else if ((LANE * INT_WIDTH) < Width) assign ifmt_slice_result[(ifmt * Width) + ((Width - 1) >= (LANE * INT_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (LANE * INT_WIDTH) ? ((Width - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (LANE * INT_WIDTH) ? ((Width - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (Width - 1)) + 1)] = {((Width - 1) >= (LANE * INT_WIDTH) ? ((Width - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (Width - 1)) + 1) {1'sb0}};
				end
			end
		end
	endgenerate
	generate
		genvar fmt;
		for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1) begin : extend_fp_result
			function automatic [1:0] sv2v_cast_38622;
				input reg [1:0] inp;
				sv2v_cast_38622 = inp;
			endfunction
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_38622(fmt));
			if ((NUM_LANES * FP_WIDTH) < Width) assign fmt_slice_result[(fmt * Width) + ((Width - 1) >= (NUM_LANES * FP_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1)] = {((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1) {lane_ext_bit[0]}};
		end
	endgenerate
	generate
		genvar ifmt;
		for (ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt = ifmt + 1) begin : int_results_disabled
			if (OpGroup != fpnew_pkg_CONV) begin : mute_int_result
				assign ifmt_slice_result[ifmt * Width+:Width] = {Width {1'sb0}};
			end
		end
	endgenerate
	generate
		if (OpGroup == fpnew_pkg_CONV) begin : target_regs
			wire [(0 >= NumPipeRegs ? ((1 - NumPipeRegs) * Width) + ((NumPipeRegs * Width) - 1) : ((NumPipeRegs + 1) * Width) - 1):(0 >= NumPipeRegs ? NumPipeRegs * Width : 0)] byp_pipe_target_q;
			wire [(0 >= NumPipeRegs ? ((1 - NumPipeRegs) * 3) + ((NumPipeRegs * 3) - 1) : ((NumPipeRegs + 1) * 3) - 1):(0 >= NumPipeRegs ? NumPipeRegs * 3 : 0)] byp_pipe_aux_q;
			wire [0:NumPipeRegs] byp_pipe_valid_q;
			wire [0:NumPipeRegs] byp_pipe_ready;
			assign byp_pipe_target_q[(0 >= NumPipeRegs ? 0 : NumPipeRegs) * Width+:Width] = conv_target_d;
			assign byp_pipe_aux_q[(0 >= NumPipeRegs ? 0 : NumPipeRegs) * 3+:3] = target_aux_d;
			assign byp_pipe_valid_q[0] = in_valid_i & vectorial_op;
			genvar i;
			for (i = 0; i < NumPipeRegs; i = i + 1) begin : gen_bypass_pipeline
				wire reg_ena;
				assign byp_pipe_ready[i] = byp_pipe_ready[i + 1] | ~byp_pipe_valid_q[i + 1];
				assign reg_ena = byp_pipe_ready[i] & byp_pipe_valid_q[i];
			end
			assign byp_pipe_ready[NumPipeRegs] = out_ready_i & result_is_vector;
			assign conv_target_q = byp_pipe_target_q[(0 >= NumPipeRegs ? NumPipeRegs : NumPipeRegs - NumPipeRegs) * Width+:Width];
			assign {result_vec_op, result_is_cpk} = byp_pipe_aux_q[(0 >= NumPipeRegs ? NumPipeRegs : NumPipeRegs - NumPipeRegs) * 3+:3];
		end
		else begin : no_conv
			assign {result_vec_op, result_is_cpk} = {3 {1'sb0}};
		end
	endgenerate
	assign {result_fmt_is_int, result_is_vector, result_fmt} = lane_aux[0+:AUX_BITS];
	assign result_o = (result_fmt_is_int ? ifmt_slice_result[result_fmt * Width+:Width] : fmt_slice_result[result_fmt * Width+:Width]);
	assign extension_bit_o = lane_ext_bit[0];
	assign tag_o = lane_tags[0];
	assign busy_o = |lane_busy;
	assign out_valid_o = lane_out_valid[0];
	always @(*) begin : output_processing
		reg [4:0] temp_status;
		temp_status = {5 {1'sb0}};
		begin : sv2v_autoblock_130
			reg signed [31:0] i;
			for (i = 0; i < sv2v_cast_32_signed(NUM_LANES); i = i + 1)
				temp_status = temp_status | lane_status[i * 5+:5];
		end
		status_o = temp_status;
	end
endmodule
module fpnew_rounding (
	abs_value_i,
	sign_i,
	round_sticky_bits_i,
	rnd_mode_i,
	effective_subtraction_i,
	abs_rounded_o,
	sign_o,
	exact_zero_o
);
	parameter [31:0] AbsWidth = 2;
	input wire [AbsWidth - 1:0] abs_value_i;
	input wire sign_i;
	input wire [1:0] round_sticky_bits_i;
	input wire [2:0] rnd_mode_i;
	input wire effective_subtraction_i;
	output wire [AbsWidth - 1:0] abs_rounded_o;
	output wire sign_o;
	output wire exact_zero_o;
	reg round_up;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	localparam [2:0] fpnew_pkg_RDN = 3'b010;
	localparam [2:0] fpnew_pkg_RMM = 3'b100;
	localparam [2:0] fpnew_pkg_RNE = 3'b000;
	localparam [2:0] fpnew_pkg_RTZ = 3'b001;
	localparam [2:0] fpnew_pkg_RUP = 3'b011;
	always @(*) begin : rounding_decision
		case (rnd_mode_i)
			fpnew_pkg_RNE:
				case (round_sticky_bits_i)
					2'b00, 2'b01: round_up = 1'b0;
					2'b10: round_up = abs_value_i[0];
					2'b11: round_up = 1'b1;
				endcase
			fpnew_pkg_RTZ: round_up = 1'b0;
			fpnew_pkg_RDN: round_up = (|round_sticky_bits_i ? sign_i : 1'b0);
			fpnew_pkg_RUP: round_up = (|round_sticky_bits_i ? ~sign_i : 1'b0);
			fpnew_pkg_RMM: round_up = round_sticky_bits_i[1];
			default: round_up = fpnew_pkg_DONT_CARE;
		endcase
	end
	assign abs_rounded_o = abs_value_i + round_up;
	assign exact_zero_o = (abs_value_i == {AbsWidth {1'sb0}}) && (round_sticky_bits_i == {2 {1'sb0}});
	assign sign_o = (exact_zero_o && effective_subtraction_i ? rnd_mode_i == fpnew_pkg_RDN : sign_i);
endmodule
module fpnew_top_F1920 (
	clk_i,
	rst_ni,
	operands_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 4;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	localparam [41:0] fpnew_pkg_RV64D_Xsflt = {34'b0000000000000000000000000100000011, sv2v_cast_4(5'b11111), 4'b1111};
	parameter [41:0] Features = fpnew_pkg_RV64D_Xsflt;
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	localparam [1:0] fpnew_pkg_BEFORE = 0;
	localparam [1:0] fpnew_pkg_MERGED = 2;
	localparam [1:0] fpnew_pkg_PARALLEL = 1;
	function automatic [127:0] sv2v_cast_33F2F;
		input reg [127:0] inp;
		sv2v_cast_33F2F = inp;
	endfunction
	function automatic [511:0] sv2v_cast_512;
		input reg [511:0] inp;
		sv2v_cast_512 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [545:0] fpnew_pkg_DEFAULT_NOREGS = {sv2v_cast_512({fpnew_pkg_NUM_OPGROUPS {sv2v_cast_33F2F(0)}}), sv2v_cast_32({{fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_MERGED}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_PARALLEL}}, {fpnew_pkg_NUM_FP_FORMATS {fpnew_pkg_MERGED}}}), fpnew_pkg_BEFORE};
	parameter [545:0] Implementation = fpnew_pkg_DEFAULT_NOREGS;
	localparam [31:0] WIDTH = Features[41-:32];
	localparam [31:0] NUM_OPERANDS = 3;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * WIDTH) - 1:0] operands_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 2;
	input wire [1:0] src_fmt_i;
	input wire [1:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [31:0] NUM_OPGROUPS = fpnew_pkg_NUM_OPGROUPS;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	wire [3:0] opgrp_in_ready;
	wire [3:0] opgrp_out_valid;
	wire [3:0] opgrp_out_ready;
	wire [3:0] opgrp_ext;
	wire [3:0] opgrp_busy;
	wire [((WIDTH + 5) >= 0 ? (4 * (WIDTH + 6)) - 1 : (4 * (1 - (WIDTH + 5))) + (WIDTH + 4)):((WIDTH + 5) >= 0 ? 0 : WIDTH + 5)] opgrp_outputs;
	wire [11:0] is_boxed;
	localparam [3:0] fpnew_pkg_ADD = 2;
	localparam [1:0] fpnew_pkg_ADDMUL = 0;
	localparam [3:0] fpnew_pkg_CLASSIFY = 9;
	localparam [3:0] fpnew_pkg_CMP = 8;
	localparam [1:0] fpnew_pkg_CONV = 3;
	localparam [3:0] fpnew_pkg_CPKAB = 13;
	localparam [3:0] fpnew_pkg_CPKCD = 14;
	localparam [3:0] fpnew_pkg_DIV = 4;
	localparam [1:0] fpnew_pkg_DIVSQRT = 1;
	localparam [3:0] fpnew_pkg_F2F = 10;
	localparam [3:0] fpnew_pkg_F2I = 11;
	localparam [3:0] fpnew_pkg_FMADD = 0;
	localparam [3:0] fpnew_pkg_FNMSUB = 1;
	localparam [3:0] fpnew_pkg_I2F = 12;
	localparam [3:0] fpnew_pkg_MINMAX = 7;
	localparam [3:0] fpnew_pkg_MUL = 3;
	localparam [1:0] fpnew_pkg_NONCOMP = 2;
	localparam [3:0] fpnew_pkg_SGNJ = 6;
	localparam [3:0] fpnew_pkg_SQRT = 5;
	function automatic [1:0] fpnew_pkg_get_opgroup;
		input reg [3:0] op;
		case (op)
			fpnew_pkg_FMADD, fpnew_pkg_FNMSUB, fpnew_pkg_ADD, fpnew_pkg_MUL: fpnew_pkg_get_opgroup = fpnew_pkg_ADDMUL;
			fpnew_pkg_DIV, fpnew_pkg_SQRT: fpnew_pkg_get_opgroup = fpnew_pkg_DIVSQRT;
			fpnew_pkg_SGNJ, fpnew_pkg_MINMAX, fpnew_pkg_CMP, fpnew_pkg_CLASSIFY: fpnew_pkg_get_opgroup = fpnew_pkg_NONCOMP;
			fpnew_pkg_F2F, fpnew_pkg_F2I, fpnew_pkg_I2F, fpnew_pkg_CPKAB, fpnew_pkg_CPKCD: fpnew_pkg_get_opgroup = fpnew_pkg_CONV;
			default: fpnew_pkg_get_opgroup = fpnew_pkg_NONCOMP;
		endcase
	endfunction
	assign in_ready_o = in_valid_i & opgrp_in_ready[fpnew_pkg_get_opgroup(op_i)];
	localparam [255:0] fpnew_pkg_FP_ENCODINGS = 256'h00000008000000170000000b00000034000000050000000a0000000500000002;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [1:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((3 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
                input reg signed [31:0] inp;
	        sv2v_cast_32_signed = inp;
        endfunction
	function automatic [1:0] sv2v_cast_B5DD5;
                input reg [1:0] inp;
        	sv2v_cast_B5DD5 = inp;
        endfunction
	generate
		genvar fmt;
		/*function automatic signed [31:0] sv2v_cast_32_signed;
			input reg signed [31:0] inp;
			sv2v_cast_32_signed = inp;
		endfunction*/
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_nanbox_check
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_B5DD5(fmt));
			if (Features[8] && (FP_WIDTH < WIDTH)) begin : check
				genvar op;
				for (op = 0; op < sv2v_cast_32_signed(NUM_OPERANDS); op = op + 1) begin : operands
					assign is_boxed[(fmt * NUM_OPERANDS) + op] = (!vectorial_op_i ? operands_i[(op * WIDTH) + ((WIDTH - 1) >= FP_WIDTH ? WIDTH - 1 : ((WIDTH - 1) + ((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)) - 1)-:((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)] == {((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1) {1'sb1}} : 1'b1);
				end
			end
			else begin : no_check
				assign is_boxed[fmt * NUM_OPERANDS+:NUM_OPERANDS] = {3 {1'sb1}};
			end
		end
	endgenerate
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			fpnew_pkg_ADDMUL: fpnew_pkg_num_operands = 3;
			fpnew_pkg_DIVSQRT: fpnew_pkg_num_operands = 2;
			fpnew_pkg_NONCOMP: fpnew_pkg_num_operands = 2;
			fpnew_pkg_CONV: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	generate
		genvar opgrp;
		for (opgrp = 0; opgrp < sv2v_cast_32_signed(NUM_OPGROUPS); opgrp = opgrp + 1) begin : gen_operation_groups
			function automatic [1:0] sv2v_cast_2;
				input reg [1:0] inp;
				sv2v_cast_2 = inp;
			endfunction
			localparam [31:0] NUM_OPS = fpnew_pkg_num_operands(sv2v_cast_2(opgrp));
			wire in_valid;
			reg [(NUM_FORMATS * NUM_OPS) - 1:0] input_boxed;
			assign in_valid = in_valid_i & (fpnew_pkg_get_opgroup(op_i) == sv2v_cast_2(opgrp));
			function automatic [31:0] sv2v_cast_32;
				input reg [31:0] inp;
				sv2v_cast_32 = inp;
			endfunction
			always @(*) begin : slice_inputs
				begin : sv2v_autoblock_131
					reg [31:0] fmt;
					for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1)
						input_boxed[fmt * sv2v_cast_32(fpnew_pkg_num_operands(sv2v_cast_2(opgrp)))+:sv2v_cast_32(fpnew_pkg_num_operands(sv2v_cast_2(opgrp)))] = is_boxed[(fmt * 3) + (NUM_OPS - 1)-:NUM_OPS];
				end
			end
			
			fpnew_opgroup_block_BE2AB #(
				.OpGroup(sv2v_cast_2(opgrp)),
				.Width(WIDTH),
				.EnableVectors(Features[9]),
				.FpFmtMask(Features[7-:4]),
				.IntFmtMask(Features[3-:4]),
				.FmtPipeRegs(Implementation[34 + (32 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS))+:128]),
				.FmtUnitTypes(Implementation[2 + (2 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS))+:8]),
				.PipeConfig(Implementation[1-:2])
			) i_opgroup_block(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i[WIDTH * ((NUM_OPS - 1) - (NUM_OPS - 1))+:WIDTH * NUM_OPS]),
				.is_boxed_i(input_boxed),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(opgrp_in_ready[opgrp]),
				.flush_i(flush_i),
				.result_o(opgrp_outputs[((WIDTH + 5) >= 0 ? (opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? WIDTH + 5 : (WIDTH + 5) - (WIDTH + 5)) : (((opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? WIDTH + 5 : (WIDTH + 5) - (WIDTH + 5))) + ((WIDTH + 5) >= 6 ? WIDTH : 7 - (WIDTH + 5))) - 1)-:((WIDTH + 5) >= 6 ? WIDTH : 7 - (WIDTH + 5))]),
				.status_o(opgrp_outputs[((WIDTH + 5) >= 0 ? (opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 5 : WIDTH) : ((opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 5 : WIDTH)) + 4)-:5]),
				.extension_bit_o(opgrp_ext[opgrp]),
				.tag_o(opgrp_outputs[(opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 0 : WIDTH + 5)]),
				.out_valid_o(opgrp_out_valid[opgrp]),
				.out_ready_i(opgrp_out_ready[opgrp]),
				.busy_o(opgrp_busy[opgrp])
			);
		end
	endgenerate
	wire [WIDTH + 5:0] arbiter_output;
	rr_arb_tree_CBEBF_6E668 #(
		.DataType_WIDTH(WIDTH),
		.NumIn(NUM_OPGROUPS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i({$unsigned(2) {1'sb0}}),
		.req_i(opgrp_out_valid),
		.gnt_o(opgrp_out_ready),
		.data_i(opgrp_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output),
		.idx_o()
	);
	assign result_o = arbiter_output[WIDTH + 5-:((WIDTH + 5) >= 6 ? WIDTH : 7 - (WIDTH + 5))];
	assign status_o = arbiter_output[5-:5];
	assign tag_o = arbiter_output[0];
	assign busy_o = |opgrp_busy;
endmodule
module gpio_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire [458:0] reg2hw;
	input wire [257:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] AW = 6;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire reg_we;
	wire reg_re;
	wire [5:0] reg_addr;
	wire [31:0] reg_wdata;
	wire [3:0] reg_be;
	wire [31:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [31:0] reg_rdata_next;
	wire [85:0] tl_reg_h2d;
	wire [51:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire [31:0] intr_state_qs;
	wire [31:0] intr_state_wd;
	wire intr_state_we;
	wire [31:0] intr_enable_qs;
	wire [31:0] intr_enable_wd;
	wire intr_enable_we;
	wire [31:0] intr_test_wd;
	wire intr_test_we;
	wire [31:0] data_in_qs;
	wire [31:0] direct_out_qs;
	wire [31:0] direct_out_wd;
	wire direct_out_we;
	wire direct_out_re;
	wire [15:0] masked_out_lower_data_qs;
	wire [15:0] masked_out_lower_data_wd;
	wire masked_out_lower_data_we;
	wire masked_out_lower_data_re;
	wire [15:0] masked_out_lower_mask_wd;
	wire masked_out_lower_mask_we;
	wire [15:0] masked_out_upper_data_qs;
	wire [15:0] masked_out_upper_data_wd;
	wire masked_out_upper_data_we;
	wire masked_out_upper_data_re;
	wire [15:0] masked_out_upper_mask_wd;
	wire masked_out_upper_mask_we;
	wire [31:0] direct_oe_qs;
	wire [31:0] direct_oe_wd;
	wire direct_oe_we;
	wire direct_oe_re;
	wire [15:0] masked_oe_lower_data_qs;
	wire [15:0] masked_oe_lower_data_wd;
	wire masked_oe_lower_data_we;
	wire masked_oe_lower_data_re;
	wire [15:0] masked_oe_lower_mask_qs;
	wire [15:0] masked_oe_lower_mask_wd;
	wire masked_oe_lower_mask_we;
	wire masked_oe_lower_mask_re;
	wire [15:0] masked_oe_upper_data_qs;
	wire [15:0] masked_oe_upper_data_wd;
	wire masked_oe_upper_data_we;
	wire masked_oe_upper_data_re;
	wire [15:0] masked_oe_upper_mask_qs;
	wire [15:0] masked_oe_upper_mask_wd;
	wire masked_oe_upper_mask_we;
	wire masked_oe_upper_mask_re;
	wire [31:0] intr_ctrl_en_rising_qs;
	wire [31:0] intr_ctrl_en_rising_wd;
	wire intr_ctrl_en_rising_we;
	wire [31:0] intr_ctrl_en_falling_qs;
	wire [31:0] intr_ctrl_en_falling_wd;
	wire intr_ctrl_en_falling_we;
	wire [31:0] intr_ctrl_en_lvlhigh_qs;
	wire [31:0] intr_ctrl_en_lvlhigh_wd;
	wire intr_ctrl_en_lvlhigh_we;
	wire [31:0] intr_ctrl_en_lvllow_qs;
	wire [31:0] intr_ctrl_en_lvllow_wd;
	wire intr_ctrl_en_lvllow_we;
	wire [31:0] ctrl_en_input_filter_qs;
	wire [31:0] ctrl_en_input_filter_wd;
	wire ctrl_en_input_filter_we;
	prim_subreg #(
		.DW(32),
		.SWACCESS("W1C"),
		.RESVAL(32'h00000000)
	) u_intr_state(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_we),
		.wd(intr_state_wd),
		.de(hw2reg[225]),
		.d(hw2reg[257-:32]),
		.qe(),
		.q(reg2hw[458-:32]),
		.qs(intr_state_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_enable(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_we),
		.wd(intr_enable_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[426-:32]),
		.qs(intr_enable_qs)
	);
	prim_subreg_ext #(.DW(32)) u_intr_test(
		.re(1'b0),
		.we(intr_test_we),
		.wd(intr_test_wd),
		.d({32 {1'sb0}}),
		.qre(),
		.qe(reg2hw[362]),
		.q(reg2hw[394-:32]),
		.qs()
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RO"),
		.RESVAL(32'h00000000)
	) u_data_in(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd({32 {1'sb0}}),
		.de(hw2reg[192]),
		.d(hw2reg[224-:32]),
		.qe(),
		.q(),
		.qs(data_in_qs)
	);
	prim_subreg_ext #(.DW(32)) u_direct_out(
		.re(direct_out_re),
		.we(direct_out_we),
		.wd(direct_out_wd),
		.d(hw2reg[191-:32]),
		.qre(),
		.qe(reg2hw[329]),
		.q(reg2hw[361-:32]),
		.qs(direct_out_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_data(
		.re(masked_out_lower_data_re),
		.we(masked_out_lower_data_we),
		.wd(masked_out_lower_data_wd),
		.d(hw2reg[159-:16]),
		.qre(),
		.qe(reg2hw[312]),
		.q(reg2hw[328-:16]),
		.qs(masked_out_lower_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_mask(
		.re(1'b0),
		.we(masked_out_lower_mask_we),
		.wd(masked_out_lower_mask_wd),
		.d(hw2reg[143-:16]),
		.qre(),
		.qe(reg2hw[295]),
		.q(reg2hw[311-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_data(
		.re(masked_out_upper_data_re),
		.we(masked_out_upper_data_we),
		.wd(masked_out_upper_data_wd),
		.d(hw2reg[127-:16]),
		.qre(),
		.qe(reg2hw[278]),
		.q(reg2hw[294-:16]),
		.qs(masked_out_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_mask(
		.re(1'b0),
		.we(masked_out_upper_mask_we),
		.wd(masked_out_upper_mask_wd),
		.d(hw2reg[111-:16]),
		.qre(),
		.qe(reg2hw[261]),
		.q(reg2hw[277-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(32)) u_direct_oe(
		.re(direct_oe_re),
		.we(direct_oe_we),
		.wd(direct_oe_wd),
		.d(hw2reg[95-:32]),
		.qre(),
		.qe(reg2hw[228]),
		.q(reg2hw[260-:32]),
		.qs(direct_oe_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_data(
		.re(masked_oe_lower_data_re),
		.we(masked_oe_lower_data_we),
		.wd(masked_oe_lower_data_wd),
		.d(hw2reg[63-:16]),
		.qre(),
		.qe(reg2hw[211]),
		.q(reg2hw[227-:16]),
		.qs(masked_oe_lower_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_mask(
		.re(masked_oe_lower_mask_re),
		.we(masked_oe_lower_mask_we),
		.wd(masked_oe_lower_mask_wd),
		.d(hw2reg[47-:16]),
		.qre(),
		.qe(reg2hw[194]),
		.q(reg2hw[210-:16]),
		.qs(masked_oe_lower_mask_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_data(
		.re(masked_oe_upper_data_re),
		.we(masked_oe_upper_data_we),
		.wd(masked_oe_upper_data_wd),
		.d(hw2reg[31-:16]),
		.qre(),
		.qe(reg2hw[177]),
		.q(reg2hw[193-:16]),
		.qs(masked_oe_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_mask(
		.re(masked_oe_upper_mask_re),
		.we(masked_oe_upper_mask_we),
		.wd(masked_oe_upper_mask_wd),
		.d(hw2reg[15-:16]),
		.qre(),
		.qe(reg2hw[160]),
		.q(reg2hw[176-:16]),
		.qs(masked_oe_upper_mask_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_rising(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_rising_we),
		.wd(intr_ctrl_en_rising_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[159-:32]),
		.qs(intr_ctrl_en_rising_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_falling(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_falling_we),
		.wd(intr_ctrl_en_falling_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[127-:32]),
		.qs(intr_ctrl_en_falling_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvlhigh(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvlhigh_we),
		.wd(intr_ctrl_en_lvlhigh_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[95-:32]),
		.qs(intr_ctrl_en_lvlhigh_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvllow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvllow_we),
		.wd(intr_ctrl_en_lvllow_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[63-:32]),
		.qs(intr_ctrl_en_lvllow_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_ctrl_en_input_filter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_en_input_filter_we),
		.wd(ctrl_en_input_filter_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[31-:32]),
		.qs(ctrl_en_input_filter_qs)
	);
	reg [14:0] addr_hit;
	localparam signed [31:0] gpio_reg_pkg_BlockAw = 6;
	localparam [5:0] gpio_reg_pkg_GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 6'h38;
	localparam [5:0] gpio_reg_pkg_GPIO_DATA_IN_OFFSET = 6'h0c;
	localparam [5:0] gpio_reg_pkg_GPIO_DIRECT_OE_OFFSET = 6'h1c;
	localparam [5:0] gpio_reg_pkg_GPIO_DIRECT_OUT_OFFSET = 6'h10;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_FALLING_OFFSET = 6'h2c;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 6'h30;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 6'h34;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_RISING_OFFSET = 6'h28;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OE_LOWER_OFFSET = 6'h20;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OE_UPPER_OFFSET = 6'h24;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OUT_LOWER_OFFSET = 6'h14;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OUT_UPPER_OFFSET = 6'h18;
	always @(*) begin
		addr_hit = {15 {1'sb0}};
		addr_hit[0] = reg_addr == gpio_reg_pkg_GPIO_INTR_STATE_OFFSET;
		addr_hit[1] = reg_addr == gpio_reg_pkg_GPIO_INTR_ENABLE_OFFSET;
		addr_hit[2] = reg_addr == gpio_reg_pkg_GPIO_INTR_TEST_OFFSET;
		addr_hit[3] = reg_addr == gpio_reg_pkg_GPIO_DATA_IN_OFFSET;
		addr_hit[4] = reg_addr == gpio_reg_pkg_GPIO_DIRECT_OUT_OFFSET;
		addr_hit[5] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OUT_LOWER_OFFSET;
		addr_hit[6] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OUT_UPPER_OFFSET;
		addr_hit[7] = reg_addr == gpio_reg_pkg_GPIO_DIRECT_OE_OFFSET;
		addr_hit[8] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OE_LOWER_OFFSET;
		addr_hit[9] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OE_UPPER_OFFSET;
		addr_hit[10] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_RISING_OFFSET;
		addr_hit[11] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_FALLING_OFFSET;
		addr_hit[12] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET;
		addr_hit[13] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLLOW_OFFSET;
		addr_hit[14] = reg_addr == gpio_reg_pkg_GPIO_CTRL_EN_INPUT_FILTER_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [59:0] gpio_reg_pkg_GPIO_PERMIT = 60'b111111111111111111111111111111111111111111111111111111111111;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[56+:4] != (gpio_reg_pkg_GPIO_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[52+:4] != (gpio_reg_pkg_GPIO_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[48+:4] != (gpio_reg_pkg_GPIO_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[44+:4] != (gpio_reg_pkg_GPIO_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[40+:4] != (gpio_reg_pkg_GPIO_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[36+:4] != (gpio_reg_pkg_GPIO_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[32+:4] != (gpio_reg_pkg_GPIO_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[28+:4] != (gpio_reg_pkg_GPIO_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[24+:4] != (gpio_reg_pkg_GPIO_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[20+:4] != (gpio_reg_pkg_GPIO_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[16+:4] != (gpio_reg_pkg_GPIO_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[12+:4] != (gpio_reg_pkg_GPIO_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[8+:4] != (gpio_reg_pkg_GPIO_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[4+:4] != (gpio_reg_pkg_GPIO_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[0+:4] != (gpio_reg_pkg_GPIO_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign intr_state_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_wd = reg_wdata[31:0];
	assign intr_enable_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_wd = reg_wdata[31:0];
	assign intr_test_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_wd = reg_wdata[31:0];
	assign direct_out_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign direct_out_wd = reg_wdata[31:0];
	assign direct_out_re = addr_hit[4] && reg_re;
	assign masked_out_lower_data_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_data_wd = reg_wdata[15:0];
	assign masked_out_lower_data_re = addr_hit[5] && reg_re;
	assign masked_out_lower_mask_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_mask_wd = reg_wdata[31:16];
	assign masked_out_upper_data_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_data_wd = reg_wdata[15:0];
	assign masked_out_upper_data_re = addr_hit[6] && reg_re;
	assign masked_out_upper_mask_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_mask_wd = reg_wdata[31:16];
	assign direct_oe_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign direct_oe_wd = reg_wdata[31:0];
	assign direct_oe_re = addr_hit[7] && reg_re;
	assign masked_oe_lower_data_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_data_wd = reg_wdata[15:0];
	assign masked_oe_lower_data_re = addr_hit[8] && reg_re;
	assign masked_oe_lower_mask_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_mask_wd = reg_wdata[31:16];
	assign masked_oe_lower_mask_re = addr_hit[8] && reg_re;
	assign masked_oe_upper_data_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_data_wd = reg_wdata[15:0];
	assign masked_oe_upper_data_re = addr_hit[9] && reg_re;
	assign masked_oe_upper_mask_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_mask_wd = reg_wdata[31:16];
	assign masked_oe_upper_mask_re = addr_hit[9] && reg_re;
	assign intr_ctrl_en_rising_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign intr_ctrl_en_rising_wd = reg_wdata[31:0];
	assign intr_ctrl_en_falling_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign intr_ctrl_en_falling_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvlhigh_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvlhigh_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvllow_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvllow_wd = reg_wdata[31:0];
	assign ctrl_en_input_filter_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign ctrl_en_input_filter_wd = reg_wdata[31:0];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: reg_rdata_next[31:0] = intr_state_qs;
			addr_hit[1]: reg_rdata_next[31:0] = intr_enable_qs;
			addr_hit[2]: reg_rdata_next[31:0] = {32 {1'sb0}};
			addr_hit[3]: reg_rdata_next[31:0] = data_in_qs;
			addr_hit[4]: reg_rdata_next[31:0] = direct_out_qs;
			addr_hit[5]: begin
				reg_rdata_next[15:0] = masked_out_lower_data_qs;
				reg_rdata_next[31:16] = {16 {1'sb0}};
			end
			addr_hit[6]: begin
				reg_rdata_next[15:0] = masked_out_upper_data_qs;
				reg_rdata_next[31:16] = {16 {1'sb0}};
			end
			addr_hit[7]: reg_rdata_next[31:0] = direct_oe_qs;
			addr_hit[8]: begin
				reg_rdata_next[15:0] = masked_oe_lower_data_qs;
				reg_rdata_next[31:16] = masked_oe_lower_mask_qs;
			end
			addr_hit[9]: begin
				reg_rdata_next[15:0] = masked_oe_upper_data_qs;
				reg_rdata_next[31:16] = masked_oe_upper_mask_qs;
			end
			addr_hit[10]: reg_rdata_next[31:0] = intr_ctrl_en_rising_qs;
			addr_hit[11]: reg_rdata_next[31:0] = intr_ctrl_en_falling_qs;
			addr_hit[12]: reg_rdata_next[31:0] = intr_ctrl_en_lvlhigh_qs;
			addr_hit[13]: reg_rdata_next[31:0] = intr_ctrl_en_lvllow_qs;
			addr_hit[14]: reg_rdata_next[31:0] = ctrl_en_input_filter_qs;
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
module gpio (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	cio_gpio_i,
	cio_gpio_o,
	cio_gpio_en_o,
	intr_gpio_o
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	input wire [31:0] cio_gpio_i;
	output wire [31:0] cio_gpio_o;
	output wire [31:0] cio_gpio_en_o;
	output wire [31:0] intr_gpio_o;
	wire [458:0] reg2hw;
	wire [257:0] hw2reg;
	reg [31:0] cio_gpio_q;
	reg [31:0] cio_gpio_en_q;
	wire [31:0] data_in_d;
	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin : gen_filter
			prim_filter_ctr #(.Cycles(16)) filter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.enable_i(reg2hw[i]),
				.filter_i(cio_gpio_i[i]),
				.filter_o(data_in_d[i])
			);
		end
	endgenerate
	assign hw2reg[192] = 1'b1;
	assign hw2reg[224-:32] = data_in_d;
	assign cio_gpio_o = cio_gpio_q;
	assign cio_gpio_en_o = cio_gpio_en_q;
	assign hw2reg[191-:32] = cio_gpio_q;
	assign hw2reg[127-:16] = cio_gpio_q[31:16];
	assign hw2reg[111-:16] = 16'h0000;
	assign hw2reg[159-:16] = cio_gpio_q[15:0];
	assign hw2reg[143-:16] = 16'h0000;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			cio_gpio_q <= {32 {1'sb0}};
		else if (reg2hw[329])
			cio_gpio_q <= reg2hw[361-:32];
		else if (reg2hw[278])
			cio_gpio_q[31:16] <= (reg2hw[277-:16] & reg2hw[294-:16]) | (~reg2hw[277-:16] & cio_gpio_q[31:16]);
		else if (reg2hw[312])
			cio_gpio_q[15:0] <= (reg2hw[311-:16] & reg2hw[328-:16]) | (~reg2hw[311-:16] & cio_gpio_q[15:0]);
	assign hw2reg[95-:32] = cio_gpio_en_q;
	assign hw2reg[31-:16] = cio_gpio_en_q[31:16];
	assign hw2reg[15-:16] = 16'h0000;
	assign hw2reg[63-:16] = cio_gpio_en_q[15:0];
	assign hw2reg[47-:16] = 16'h0000;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			cio_gpio_en_q <= {32 {1'sb0}};
		else if (reg2hw[228])
			cio_gpio_en_q <= reg2hw[260-:32];
		else if (reg2hw[177])
			cio_gpio_en_q[31:16] <= (reg2hw[176-:16] & reg2hw[193-:16]) | (~reg2hw[176-:16] & cio_gpio_en_q[31:16]);
		else if (reg2hw[211])
			cio_gpio_en_q[15:0] <= (reg2hw[210-:16] & reg2hw[227-:16]) | (~reg2hw[210-:16] & cio_gpio_en_q[15:0]);
	reg [31:0] data_in_q;
	always @(posedge clk_i) data_in_q <= data_in_d;
	wire [31:0] event_intr_rise;
	wire [31:0] event_intr_fall;
	wire [31:0] event_intr_actlow;
	wire [31:0] event_intr_acthigh;
	wire [31:0] event_intr_combined;
	prim_intr_hw #(.Width(32)) intr_hw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_intr_combined),
		.reg2hw_intr_enable_q_i(reg2hw[426-:32]),
		.reg2hw_intr_test_q_i(reg2hw[394-:32]),
		.reg2hw_intr_test_qe_i(reg2hw[362]),
		.reg2hw_intr_state_q_i(reg2hw[458-:32]),
		.hw2reg_intr_state_de_o(hw2reg[225]),
		.hw2reg_intr_state_d_o(hw2reg[257-:32]),
		.intr_o(intr_gpio_o)
	);
	assign event_intr_rise = (~data_in_q & data_in_d) & reg2hw[159-:32];
	assign event_intr_fall = (data_in_q & ~data_in_d) & reg2hw[127-:32];
	assign event_intr_acthigh = data_in_d & reg2hw[95-:32];
	assign event_intr_actlow = ~data_in_d & reg2hw[63-:32];
	assign event_intr_combined = ((event_intr_rise | event_intr_fall) | event_intr_actlow) | event_intr_acthigh;
	gpio_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule

module iccm_controller (
	clk_i,
	rst_ni,
	prog_i,
	rx_dv_i,
	rx_byte_i,
	we_o,
	addr_o,
	wdata_o,
	reset_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire prog_i;
	input wire rx_dv_i;
	input wire [7:0] rx_byte_i;
	output wire we_o;
	output wire [11:0] addr_o;
	output wire [31:0] wdata_o;
	output wire reset_o;
	reg [1:0] ctrl_fsm_cs;
	reg [1:0] ctrl_fsm_ns;
	wire [7:0] rx_byte_d;
	reg [7:0] rx_byte_q0;
	reg [7:0] rx_byte_q1;
	reg [7:0] rx_byte_q2;
	reg [7:0] rx_byte_q3;
	reg we_q;
	reg we_d;
	reg [11:0] addr_q;
	reg [11:0] addr_d;
	reg reset_q;
	reg reset_d;
	reg [1:0] byte_count;
	localparam [1:0] DONE = 3;
	localparam [1:0] LOAD = 1;
	localparam [1:0] PROG = 2;
	localparam [1:0] RESET = 0;
	always @(*) begin
		we_d    = we_q;
		addr_d  = addr_q;
		reset_d = reset_q;
		ctrl_fsm_ns = ctrl_fsm_cs;
		case (ctrl_fsm_cs)
			RESET: begin
				we_d = 1'b0;
				reset_d = 1'b0;
				if (rx_dv_i)
					ctrl_fsm_ns = LOAD;
				else
					ctrl_fsm_ns = RESET;
			end
			LOAD:
				if (((byte_count == 2'b11) && (rx_byte_q2 != 8'h0f)) && (rx_byte_d != 8'hff)) begin
					we_d = 1'b1;
					ctrl_fsm_ns = PROG;
				end
				else
					ctrl_fsm_ns = DONE;
			PROG: begin
				we_d = 1'b0;
				ctrl_fsm_ns = DONE;
			end
			DONE:
				if (wdata_o == 32'h00000fff || (!rst_ni)) begin
					ctrl_fsm_ns = DONE;
					reset_d = 1'b1;
				end
				else if (rx_dv_i)
					ctrl_fsm_ns = LOAD;
				else
					ctrl_fsm_ns = DONE;
		//	default: ctrl_fsm_ns = RESET;
		endcase
	end
	assign rx_byte_d = rx_byte_i;
	assign we_o = we_q;
	assign addr_o = addr_q;
	assign wdata_o = {rx_byte_q0, rx_byte_q1, rx_byte_q2, rx_byte_q3};
	assign reset_o = reset_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			we_q <= 1'b0;
			addr_q <= 12'b000000000000;
			rx_byte_q0 <= 8'b00000000;
			rx_byte_q1 <= 8'b00000000;
			rx_byte_q2 <= 8'b00000000;
			rx_byte_q3 <= 8'b00000000;
			reset_q <= 1'b1;
			byte_count <= 2'b00;
			ctrl_fsm_cs <= DONE;
		end 
		else if (prog_i) begin
            we_q <= 1'b0;
            addr_q <= 12'b000000000000;
            rx_byte_q0 <= 8'b00000000;
            rx_byte_q1 <= 8'b00000000;
            rx_byte_q2 <= 8'b00000000;
            rx_byte_q3 <= 8'b00000000;
            reset_q <= 1'b0;
            byte_count <= 2'b00;
            ctrl_fsm_cs <= RESET;
		end
		else begin
			we_q <= we_d;
			if (ctrl_fsm_cs == LOAD) begin
				if (byte_count == 2'b00) begin
					rx_byte_q0 <= rx_byte_d;
					byte_count <= 2'b01;
				end
				else if (byte_count == 2'b01) begin
					rx_byte_q1 <= rx_byte_d;
					byte_count <= 2'b10;
				end
				else if (byte_count == 2'b10) begin
					rx_byte_q2 <= rx_byte_d;
					byte_count <= 2'b11;
				end
				else begin
					rx_byte_q3 <= rx_byte_d;
					byte_count <= 2'b00;
				end
				addr_q <= addr_d;
			end
			if (ctrl_fsm_cs == PROG)
				addr_q <= addr_d + 1'b1;
			reset_q <= reset_d;
			ctrl_fsm_cs <= ctrl_fsm_ns;
		end
endmodule
module instr_mem_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	iccm_ctrl_addr,
	iccm_ctrl_wdata,
	iccm_ctrl_we,
	prog_rst_ni,
	csb,
	addr_o,
	wdata_o,
	wmask_o,
	we_o,
	rdata_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	input [11:0] iccm_ctrl_addr;
	input [31:0] iccm_ctrl_wdata;
	input wire iccm_ctrl_we;
	input wire prog_rst_ni;
	output wire csb;
	output wire [11:0] addr_o;
	output wire [31:0] wdata_o;
	output wire [3:0] wmask_o;
	output wire we_o;
	input wire [31:0] rdata_i;
	reg rvalid;
	wire tl_we;
	wire [31:0] tl_wmask;
	wire [31:0] tl_wdata;
	wire [11:0] tl_addr;
	wire tl_req;
	wire [3:0] mask_sel;
	assign mask_sel[0] = (tl_wmask[7:0] != 8'b00000000 ? 1'b1 : 1'b0);
	assign mask_sel[1] = (tl_wmask[15:8] != 8'b00000000 ? 1'b1 : 1'b0);
	assign mask_sel[2] = (tl_wmask[23:16] != 8'b00000000 ? 1'b1 : 1'b0);
	assign mask_sel[3] = (tl_wmask[31:24] != 8'b00000000 ? 1'b1 : 1'b0);
	assign csb = ~1'b1;
	assign addr_o = (prog_rst_ni ? tl_addr : iccm_ctrl_addr);
	assign wdata_o = (prog_rst_ni ? tl_wdata : iccm_ctrl_wdata);
	assign we_o = ~(prog_rst_ni ? tl_we : iccm_ctrl_we);
	assign wmask_o = (prog_rst_ni ? mask_sel : 4'b1111);
	tlul_sram_adapter #(
		.SramAw(12),
		.SramDw(32),
		.Outstanding(2),
		.ByteAccess(1),
		.ErrOnWrite(0),
		.ErrOnRead(0)
	) inst_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.req_o(tl_req),
		.gnt_i(1'b1),
		.we_o(tl_we),
		.addr_o(tl_addr),
		.wdata_o(tl_wdata),
		.wmask_o(tl_wmask),
		.rdata_i((rst_ni ? rdata_i : {32 {1'sb0}})),
		.rvalid_i(rvalid),
		.rerror_i(2'b00)
	);
	always @(posedge clk_i)
		if (!rst_ni)
			rvalid <= 1'b0;
		else if (iccm_ctrl_we | tl_we)
			rvalid <= 1'b0;
		else
			rvalid <= tl_req;
endmodule
module iteration_div_sqrt_mvp (
	A_DI,
	B_DI,
	Div_enable_SI,
	Div_start_dly_SI,
	Sqrt_enable_SI,
	D_DI,
	D_DO,
	Sum_DO,
	Carry_out_DO
);
	parameter WIDTH = 25;
	input wire [WIDTH - 1:0] A_DI;
	input wire [WIDTH - 1:0] B_DI;
	input wire Div_enable_SI;
	input wire Div_start_dly_SI;
	input wire Sqrt_enable_SI;
	input wire [1:0] D_DI;
	output wire [1:0] D_DO;
	output wire [WIDTH - 1:0] Sum_DO;
	output wire Carry_out_DO;
	wire D_carry_D;
	wire Sqrt_cin_D;
	wire Cin_D;
	assign D_DO[0] = ~D_DI[0];
	assign D_DO[1] = ~(D_DI[1] ^ D_DI[0]);
	assign D_carry_D = D_DI[1] | D_DI[0];
	assign Sqrt_cin_D = Sqrt_enable_SI && D_carry_D;
	assign Cin_D = (Div_enable_SI ? 1'b0 : Sqrt_cin_D);
	assign {Carry_out_DO, Sum_DO} = (A_DI + B_DI) + Cin_D;
endmodule
module lzc (
	in_i,
	cnt_o,
	empty_o
);
	parameter [31:0] WIDTH = 2;
	parameter [0:0] MODE = 1'b0;
	function automatic [31:0] cf_math_pkg_idx_width;
		input reg [31:0] num_idx;
		cf_math_pkg_idx_width = (num_idx > 32'd1 ? $unsigned($clog2(num_idx)) : 32'd1);
	endfunction
	parameter [31:0] CNT_WIDTH = cf_math_pkg_idx_width(WIDTH);
	input wire [WIDTH - 1:0] in_i;
	output wire [CNT_WIDTH - 1:0] cnt_o;
	output wire empty_o;
	generate
		if (WIDTH == 1) begin : gen_degenerate_lzc
			assign cnt_o[0] = !in_i[0];
			assign empty_o = !in_i[0];
		end
		else begin : gen_lzc
			localparam [31:0] NumLevels = $clog2(WIDTH);
			wire [(WIDTH * NumLevels) - 1:0] index_lut;
			wire [(2 ** NumLevels) - 1:0] sel_nodes;
			wire [((2 ** NumLevels) * NumLevels) - 1:0] index_nodes;
			reg [WIDTH - 1:0] in_tmp;
			always @(*) begin : flip_vector
				begin : sv2v_autoblock_132
					reg [31:0] i;
					for (i = 0; i < WIDTH; i = i + 1)
						in_tmp[i] = (MODE ? in_i[(WIDTH - 1) - i] : in_i[i]);
				end
			end
			genvar j;
			for (j = 0; $unsigned(j) < WIDTH; j = j + 1) begin : g_index_lut
				function automatic [NumLevels - 1:0] sv2v_cast_4C5E6;
					input reg [NumLevels - 1:0] inp;
					sv2v_cast_4C5E6 = inp;
				endfunction
				assign index_lut[j * NumLevels+:NumLevels] = sv2v_cast_4C5E6($unsigned(j));
			end
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : g_levels
				if ($unsigned(level) == (NumLevels - 1)) begin : g_last_level
					genvar k;
					for (k = 0; k < (2 ** level); k = k + 1) begin : g_level
						if (($unsigned(k) * 2) < (WIDTH - 1)) begin : g_reduce
							assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2] | in_tmp[(k * 2) + 1];
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = (in_tmp[k * 2] == 1'b1 ? index_lut[(k * 2) * NumLevels+:NumLevels] : index_lut[((k * 2) + 1) * NumLevels+:NumLevels]);
						end
						if (($unsigned(k) * 2) == (WIDTH - 1)) begin : g_base
							assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2];
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = index_lut[(k * 2) * NumLevels+:NumLevels];
						end
						if (($unsigned(k) * 2) > (WIDTH - 1)) begin : g_out_of_range
							assign sel_nodes[((2 ** level) - 1) + k] = 1'b0;
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = {NumLevels {1'sb0}};
						end
					end
				end
				else begin : g_not_last_level
					genvar l;
					for (l = 0; l < (2 ** level); l = l + 1) begin : g_level
						assign sel_nodes[((2 ** level) - 1) + l] = sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] | sel_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) + 1];
						assign index_nodes[(((2 ** level) - 1) + l) * NumLevels+:NumLevels] = (sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] == 1'b1 ? index_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) * NumLevels+:NumLevels] : index_nodes[((((2 ** (level + 1)) - 1) + (l * 2)) + 1) * NumLevels+:NumLevels]);
					end
				end
			end
			assign cnt_o = (NumLevels > $unsigned(0) ? index_nodes[0+:NumLevels] : {$clog2(WIDTH) {1'b0}});
			assign empty_o = (NumLevels > $unsigned(0) ? ~sel_nodes[0] : ~(|in_i));
		end
	endgenerate
endmodule
module norm_div_sqrt_mvp (
	Mant_in_DI,
	Exp_in_DI,
	Sign_in_DI,
	Div_enable_SI,
	Sqrt_enable_SI,
	Inf_a_SI,
	Inf_b_SI,
	Zero_a_SI,
	Zero_b_SI,
	NaN_a_SI,
	NaN_b_SI,
	SNaN_SI,
	RM_SI,
	Full_precision_SI,
	FP32_SI,
	FP64_SI,
	FP16_SI,
	FP16ALT_SI,
	Result_DO,
	Fflags_SO
);
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [56:0] Mant_in_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire signed [12:0] Exp_in_DI;
	input wire Sign_in_DI;
	input wire Div_enable_SI;
	input wire Sqrt_enable_SI;
	input wire Inf_a_SI;
	input wire Inf_b_SI;
	input wire Zero_a_SI;
	input wire Zero_b_SI;
	input wire NaN_a_SI;
	input wire NaN_b_SI;
	input wire SNaN_SI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	input wire Full_precision_SI;
	input wire FP32_SI;
	input wire FP64_SI;
	input wire FP16_SI;
	input wire FP16ALT_SI;
	output reg [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	reg Sign_res_D;
	reg NV_OP_S;
	reg Exp_OF_S;
	reg Exp_UF_S;
	reg Div_Zero_S;
	wire In_Exact_S;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_res_norm_D;
	reg [10:0] Exp_res_norm_D;
	wire [12:0] Exp_Max_RS_FP64_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP32 = 8;
	wire [9:0] Exp_Max_RS_FP32_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16 = 5;
	wire [6:0] Exp_Max_RS_FP16_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16ALT = 8;
	wire [9:0] Exp_Max_RS_FP16ALT_D;
	assign Exp_Max_RS_FP64_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] + defs_div_sqrt_mvp_C_MANT_FP64) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	assign Exp_Max_RS_FP32_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32:0] + defs_div_sqrt_mvp_C_MANT_FP32) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	assign Exp_Max_RS_FP16_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16:0] + defs_div_sqrt_mvp_C_MANT_FP16) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	assign Exp_Max_RS_FP16ALT_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT:0] + defs_div_sqrt_mvp_C_MANT_FP16ALT) + 1;
	wire [12:0] Num_RS_D;
	assign Num_RS_D = ~Exp_in_DI + 2;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_RS_D;
	wire [56:0] Mant_forsticky_D;
	assign {Mant_RS_D, Mant_forsticky_D} = {Mant_in_DI, {53 {1'b0}}} >> Num_RS_D;
	wire [12:0] Exp_subOne_D;
	assign Exp_subOne_D = Exp_in_DI - 1;
	reg [1:0] Mant_lower_D;
	reg Mant_sticky_bit_D;
	reg [56:0] Mant_forround_D;
	localparam defs_div_sqrt_mvp_C_EXP_ONE_FP64 = 13'h0001;
	localparam defs_div_sqrt_mvp_C_MANT_NAN_FP64 = 52'h8000000000000;
	always @(*)
		if (NaN_a_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = {11 {1'sb1}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (NaN_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = {11 {1'sb1}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (Inf_a_SI) begin
			if (Div_enable_SI && Inf_b_SI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else if (Sqrt_enable_SI && Sign_in_DI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {53 {1'sb0}};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Inf_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {53 {1'sb0}};
			Exp_res_norm_D = {11 {1'sb0}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Zero_a_SI) begin
			if (Div_enable_SI && Zero_b_SI) begin
				Div_Zero_S = 1'b1;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {53 {1'sb0}};
				Exp_res_norm_D = {11 {1'sb0}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Zero_b_SI) begin
			Div_Zero_S = 1'b1;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {53 {1'sb0}};
			Exp_res_norm_D = {11 {1'sb1}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Sign_in_DI && Sqrt_enable_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = {11 {1'sb1}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = 1'b0;
			NV_OP_S = 1'b1;
		end
		else if (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == {12 {1'sb0}}) begin
			if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b1;
				Mant_res_norm_D = {1'b0, Mant_in_DI[56:5]};
				Exp_res_norm_D = {11 {1'sb0}};
				Mant_forround_D = {Mant_in_DI[4:0], {defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {53 {1'sb0}};
				Exp_res_norm_D = {11 {1'sb0}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if ((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == defs_div_sqrt_mvp_C_EXP_ONE_FP64) && ~Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b1;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = {11 {1'sb0}};
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Exp_in_DI[12]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b1;
			Mant_res_norm_D = {Mant_RS_D[defs_div_sqrt_mvp_C_MANT_FP64:0]};
			Exp_res_norm_D = {11 {1'sb0}};
			Mant_forround_D = {Mant_forsticky_D[56:0]};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if ((((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32] && FP32_SI) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64] && FP64_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16] && FP16_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT] && FP16ALT_SI)) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {53 {1'sb0}};
			Exp_res_norm_D = {11 {1'sb1}};
			Mant_forround_D = {57 {1'sb0}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (((((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP32_SI) | ((Exp_in_DI[10:0] == {11 {1'sb1}}) && FP64_SI)) | ((Exp_in_DI[4:0] == {5 {1'sb1}}) && FP16_SI)) | ((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP16ALT_SI)) begin
			if (~Mant_in_DI[56]) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = Mant_in_DI[55:3];
				Exp_res_norm_D = Exp_subOne_D;
				Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {53 {1'sb0}};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {53 {1'sb0}};
				Exp_res_norm_D = {11 {1'sb1}};
				Mant_forround_D = {57 {1'sb0}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = Exp_in_DI[10:0];
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[55:3];
			Exp_res_norm_D = Exp_subOne_D;
			Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_upper_D;
	wire [53:0] Mant_upperRounded_D;
	reg Mant_roundUp_S;
	wire Mant_rounded_S;
	always @(*)
		if (FP32_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:29], {29 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[28:27];
			Mant_sticky_bit_D = |Mant_res_norm_D[26:0];
		end
		else if (FP64_SI) begin
			Mant_upper_D = Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:0];
			Mant_lower_D = Mant_forround_D[56:55];
			Mant_sticky_bit_D = |Mant_forround_D[55:0];
		end
		else if (FP16_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:42], {42 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[41:40];
			Mant_sticky_bit_D = |Mant_res_norm_D[39:30];
		end
		else begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:45], {45 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[44:43];
			Mant_sticky_bit_D = |Mant_res_norm_D[42:30];
		end
	assign Mant_rounded_S = |Mant_lower_D | Mant_sticky_bit_D;
	localparam defs_div_sqrt_mvp_C_RM_MINUSINF = 3'h3;
	localparam defs_div_sqrt_mvp_C_RM_NEAREST = 3'h0;
	localparam defs_div_sqrt_mvp_C_RM_PLUSINF = 3'h2;
	localparam defs_div_sqrt_mvp_C_RM_TRUNC = 3'h1;
	always @(*) begin
		Mant_roundUp_S = 1'b0;
		case (RM_SI)
			defs_div_sqrt_mvp_C_RM_NEAREST: Mant_roundUp_S = Mant_lower_D[1] && ((Mant_lower_D[0] | Mant_sticky_bit_D) | ((((FP32_SI && Mant_upper_D[29]) | (FP64_SI && Mant_upper_D[0])) | (FP16_SI && Mant_upper_D[42])) | (FP16ALT_SI && Mant_upper_D[45])));
			defs_div_sqrt_mvp_C_RM_TRUNC: Mant_roundUp_S = 0;
			defs_div_sqrt_mvp_C_RM_PLUSINF: Mant_roundUp_S = Mant_rounded_S & ~Sign_in_DI;
			defs_div_sqrt_mvp_C_RM_MINUSINF: Mant_roundUp_S = Mant_rounded_S & Sign_in_DI;
			default: Mant_roundUp_S = 0;
		endcase
	end
	wire Mant_renorm_S;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_roundUp_Vector_S;
	assign Mant_roundUp_Vector_S = {7'h00, FP16ALT_SI && Mant_roundUp_S, 2'h0, FP16_SI && Mant_roundUp_S, 12'h000, FP32_SI && Mant_roundUp_S, 28'h0000000, FP64_SI && Mant_roundUp_S};
	assign Mant_upperRounded_D = Mant_upper_D + Mant_roundUp_Vector_S;
	assign Mant_renorm_S = Mant_upperRounded_D[53];
	wire [51:0] Mant_res_round_D;
	wire [10:0] Exp_res_round_D;
	assign Mant_res_round_D = (Mant_renorm_S ? Mant_upperRounded_D[defs_div_sqrt_mvp_C_MANT_FP64:1] : Mant_upperRounded_D[51:0]);
	assign Exp_res_round_D = Exp_res_norm_D + Mant_renorm_S;
	wire [51:0] Mant_before_format_ctl_D;
	wire [10:0] Exp_before_format_ctl_D;
	assign Mant_before_format_ctl_D = (Full_precision_SI ? Mant_res_round_D : Mant_res_norm_D);
	assign Exp_before_format_ctl_D = (Full_precision_SI ? Exp_res_round_D : Exp_res_norm_D);
	always @(*)
		if (FP32_SI)
			Result_DO = {32'hffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:29]};
		else if (FP64_SI)
			Result_DO = {Sign_res_D, Exp_before_format_ctl_D[10:0], Mant_before_format_ctl_D[51:0]};
		else if (FP16_SI)
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[4:0], Mant_before_format_ctl_D[51:42]};
		else
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:45]};
	assign In_Exact_S = ~Full_precision_SI | Mant_rounded_S;
	assign Fflags_SO = {NV_OP_S, Div_Zero_S, Exp_OF_S, Exp_UF_S, In_Exact_S};
endmodule
module nrbd_nrsc_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Start_SI,
	Kill_SI,
	Special_case_SBI,
	Special_case_dly_SBI,
	Precision_ctl_SI,
	Format_sel_SI,
	Mant_a_DI,
	Mant_b_DI,
	Exp_a_DI,
	Exp_b_DI,
	Div_enable_SO,
	Sqrt_enable_SO,
	Full_precision_SO,
	FP32_SO,
	FP64_SO,
	FP16_SO,
	FP16ALT_SO,
	Ready_SO,
	Done_SO,
	Mant_z_DO,
	Exp_z_DO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Start_SI;
	input wire Kill_SI;
	input wire Special_case_SBI;
	input wire Special_case_dly_SBI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	input wire [1:0] Format_sel_SI;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_DI;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_DI;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_DI;
	output wire Div_enable_SO;
	output wire Sqrt_enable_SO;
	output wire Full_precision_SO;
	output wire FP32_SO;
	output wire FP64_SO;
	output wire FP16_SO;
	output wire FP16ALT_SO;
	output wire Ready_SO;
	output wire Done_SO;
	output wire [56:0] Mant_z_DO;
	output wire [12:0] Exp_z_DO;
	wire Div_start_dly_S;
	wire Sqrt_start_dly_S;
	control_mvp control_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Start_SI(Start_SI),
		.Kill_SI(Kill_SI),
		.Special_case_SBI(Special_case_SBI),
		.Special_case_dly_SBI(Special_case_dly_SBI),
		.Precision_ctl_SI(Precision_ctl_SI),
		.Format_sel_SI(Format_sel_SI),
		.Numerator_DI(Mant_a_DI),
		.Exp_num_DI(Exp_a_DI),
		.Denominator_DI(Mant_b_DI),
		.Exp_den_DI(Exp_b_DI),
		.Div_start_dly_SO(Div_start_dly_S),
		.Sqrt_start_dly_SO(Sqrt_start_dly_S),
		.Div_enable_SO(Div_enable_SO),
		.Sqrt_enable_SO(Sqrt_enable_SO),
		.Full_precision_SO(Full_precision_SO),
		.FP32_SO(FP32_SO),
		.FP64_SO(FP64_SO),
		.FP16_SO(FP16_SO),
		.FP16ALT_SO(FP16ALT_SO),
		.Ready_SO(Ready_SO),
		.Done_SO(Done_SO),
		.Mant_result_prenorm_DO(Mant_z_DO),
		.Exp_result_prenorm_DO(Exp_z_DO)
	);
endmodule
module preprocess_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Ready_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Format_sel_SI,
	Start_SO,
	Exp_a_DO_norm,
	Exp_b_DO_norm,
	Mant_a_DO_norm,
	Mant_b_DO_norm,
	RM_dly_SO,
	Sign_z_DO,
	Inf_a_SO,
	Inf_b_SO,
	Zero_a_SO,
	Zero_b_SO,
	NaN_a_SO,
	NaN_b_SO,
	SNaN_SO,
	Special_case_SBO,
	Special_case_dly_SBO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Ready_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	output wire Start_SO;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_DO_norm;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_DO_norm;
	output wire [2:0] RM_dly_SO;
	output wire Sign_z_DO;
	output wire Inf_a_SO;
	output wire Inf_b_SO;
	output wire Zero_a_SO;
	output wire Zero_b_SO;
	output wire NaN_a_SO;
	output wire NaN_b_SO;
	output wire SNaN_SO;
	output wire Special_case_SBO;
	output reg Special_case_dly_SBO;
	wire Hb_a_D;
	wire Hb_b_D;
	reg [10:0] Exp_a_D;
	reg [10:0] Exp_b_D;
	reg [51:0] Mant_a_NonH_D;
	reg [51:0] Mant_b_NonH_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_D;
	reg Sign_a_D;
	reg Sign_b_D;
	wire Start_S;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	localparam defs_div_sqrt_mvp_C_OP_FP16 = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP16ALT = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP32 = 32;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Sign_a_D = Operand_a_DI[31];
				Sign_b_D = Operand_b_DI[31];
				Exp_a_D = {3'h0, Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Exp_b_D = {3'h0, Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Mant_a_NonH_D = {Operand_a_DI[22:0], 29'h00000000};
				Mant_b_NonH_D = {Operand_b_DI[22:0], 29'h00000000};
			end
			2'b01: begin
				Sign_a_D = Operand_a_DI[63];
				Sign_b_D = Operand_b_DI[63];
				Exp_a_D = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Exp_b_D = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Mant_a_NonH_D = Operand_a_DI[51:0];
				Mant_b_NonH_D = Operand_b_DI[51:0];
			end
			2'b10: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {6'h00, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Exp_b_D = {6'h00, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Mant_a_NonH_D = {Operand_a_DI[9:0], 42'h00000000000};
				Mant_b_NonH_D = {Operand_b_DI[9:0], 42'h00000000000};
			end
			2'b11: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {3'h0, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Exp_b_D = {3'h0, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Mant_a_NonH_D = {Operand_a_DI[6:0], 45'h000000000000};
				Mant_b_NonH_D = {Operand_b_DI[6:0], 45'h000000000000};
			end
		endcase
	assign Mant_a_D = {Hb_a_D, Mant_a_NonH_D};
	assign Mant_b_D = {Hb_b_D, Mant_b_NonH_D};
	assign Hb_a_D = |Exp_a_D;
	assign Hb_b_D = |Exp_b_D;
	assign Start_S = Div_start_SI | Sqrt_start_SI;
	reg Mant_a_prenorm_zero_S;
	reg Mant_b_prenorm_zero_S;
	wire Exp_a_prenorm_zero_S;
	wire Exp_b_prenorm_zero_S;
	assign Exp_a_prenorm_zero_S = ~Hb_a_D;
	assign Exp_b_prenorm_zero_S = ~Hb_b_D;
	reg Exp_a_prenorm_Inf_NaN_S;
	reg Exp_b_prenorm_Inf_NaN_S;
	wire Mant_a_prenorm_QNaN_S;
	wire Mant_a_prenorm_SNaN_S;
	wire Mant_b_prenorm_QNaN_S;
	wire Mant_b_prenorm_SNaN_S;
	assign Mant_a_prenorm_QNaN_S = Mant_a_NonH_D[51] && ~(|Mant_a_NonH_D[50:0]);
	assign Mant_a_prenorm_SNaN_S = ~Mant_a_NonH_D[51] && |Mant_a_NonH_D[50:0];
	assign Mant_b_prenorm_QNaN_S = Mant_b_NonH_D[51] && ~(|Mant_b_NonH_D[50:0]);
	assign Mant_b_prenorm_SNaN_S = ~Mant_b_NonH_D[51] && |Mant_b_NonH_D[50:0];
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16 = 5'h1f;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16ALT = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP32 = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP64 = 11'h7ff;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16 = 10'h000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT = 7'h00;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP32 = 23'h000000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP64 = 52'h0000000000000;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Mant_b_prenorm_zero_S = Operand_b_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
			end
			2'b01: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Mant_b_prenorm_zero_S = Operand_b_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
			end
			2'b10: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Mant_b_prenorm_zero_S = Operand_b_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
			end
			2'b11: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Mant_b_prenorm_zero_S = Operand_b_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
			end
		endcase
	wire Zero_a_SN;
	reg Zero_a_SP;
	wire Zero_b_SN;
	reg Zero_b_SP;
	wire Inf_a_SN;
	reg Inf_a_SP;
	wire Inf_b_SN;
	reg Inf_b_SP;
	wire NaN_a_SN;
	reg NaN_a_SP;
	wire NaN_b_SN;
	reg NaN_b_SP;
	wire SNaN_SN;
	reg SNaN_SP;
	assign Zero_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_zero_S && Mant_a_prenorm_zero_S : Zero_a_SP);
	assign Zero_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_zero_S && Mant_b_prenorm_zero_S : Zero_b_SP);
	assign Inf_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && Mant_a_prenorm_zero_S : Inf_a_SP);
	assign Inf_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && Mant_b_prenorm_zero_S : Inf_b_SP);
	assign NaN_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && ~Mant_a_prenorm_zero_S : NaN_a_SP);
	assign NaN_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && ~Mant_b_prenorm_zero_S : NaN_b_SP);
	assign SNaN_SN = (Start_S && Ready_SI ? (Mant_a_prenorm_SNaN_S && NaN_a_SN) | (Mant_b_prenorm_SNaN_S && NaN_b_SN) : SNaN_SP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI) begin
			Zero_a_SP <= 1'b0;
			Zero_b_SP <= 1'b0;
			Inf_a_SP <= 1'b0;
			Inf_b_SP <= 1'b0;
			NaN_a_SP <= 1'b0;
			NaN_b_SP <= 1'b0;
			SNaN_SP <= 1'b0;
		end
		else begin
			Inf_a_SP <= Inf_a_SN;
			Inf_b_SP <= Inf_b_SN;
			Zero_a_SP <= Zero_a_SN;
			Zero_b_SP <= Zero_b_SN;
			NaN_a_SP <= NaN_a_SN;
			NaN_b_SP <= NaN_b_SN;
			SNaN_SP <= SNaN_SN;
		end
	assign Special_case_SBO = ~{(Div_start_SI ? ((((Zero_a_SN | Zero_b_SN) | Inf_a_SN) | Inf_b_SN) | NaN_a_SN) | NaN_b_SN : ((Zero_a_SN | Inf_a_SN) | NaN_a_SN) | Sign_a_D)} && (Start_S && Ready_SI);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Special_case_dly_SBO <= 1'b0;
		else if (Start_S && Ready_SI)
			Special_case_dly_SBO <= Special_case_SBO;
		else if (Special_case_dly_SBO)
			Special_case_dly_SBO <= 1'b1;
		else
			Special_case_dly_SBO <= 1'b0;
	reg Sign_z_DN;
	reg Sign_z_DP;
	always @(*)
		if (Div_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D ^ Sign_b_D;
		else if (Sqrt_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D;
		else
			Sign_z_DN = Sign_z_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sign_z_DP <= 1'b0;
		else
			Sign_z_DP <= Sign_z_DN;
	reg [2:0] RM_DN;
	reg [2:0] RM_DP;
	always @(*)
		if (Start_S && Ready_SI)
			RM_DN = RM_SI;
		else
			RM_DN = RM_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			RM_DP <= {3 {1'sb0}};
		else
			RM_DP <= RM_DN;
	assign RM_dly_SO = RM_DP;
	wire [5:0] Mant_leadingOne_a;
	wire [5:0] Mant_leadingOne_b;
	wire Mant_zero_S_a;
	wire Mant_zero_S_b;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ua(
		.in_i(Mant_a_D),
		.cnt_o(Mant_leadingOne_a),
		.empty_o(Mant_zero_S_a)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DP;
	assign Mant_a_norm_DN = (Start_S && Ready_SI ? Mant_a_D << Mant_leadingOne_a : Mant_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_a_norm_DP <= {53 {1'sb0}};
		else
			Mant_a_norm_DP <= Mant_a_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DP;
	assign Exp_a_norm_DN = (Start_S && Ready_SI ? (Exp_a_D - Mant_leadingOne_a) + |Mant_leadingOne_a : Exp_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_a_norm_DP <= {12 {1'sb0}};
		else
			Exp_a_norm_DP <= Exp_a_norm_DN;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ub(
		.in_i(Mant_b_D),
		.cnt_o(Mant_leadingOne_b),
		.empty_o(Mant_zero_S_b)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DP;
	assign Mant_b_norm_DN = (Start_S && Ready_SI ? Mant_b_D << Mant_leadingOne_b : Mant_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_b_norm_DP <= {53 {1'sb0}};
		else
			Mant_b_norm_DP <= Mant_b_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DP;
	assign Exp_b_norm_DN = (Start_S && Ready_SI ? (Exp_b_D - Mant_leadingOne_b) + |Mant_leadingOne_b : Exp_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_b_norm_DP <= {12 {1'sb0}};
		else
			Exp_b_norm_DP <= Exp_b_norm_DN;
	assign Start_SO = Start_S;
	assign Exp_a_DO_norm = Exp_a_norm_DP;
	assign Exp_b_DO_norm = Exp_b_norm_DP;
	assign Mant_a_DO_norm = Mant_a_norm_DP;
	assign Mant_b_DO_norm = Mant_b_norm_DP;
	assign Sign_z_DO = Sign_z_DP;
	assign Inf_a_SO = Inf_a_SP;
	assign Inf_b_SO = Inf_b_SP;
	assign Zero_a_SO = Zero_a_SP;
	assign Zero_b_SO = Zero_b_SP;
	assign NaN_a_SO = NaN_a_SP;
	assign NaN_b_SO = NaN_b_SP;
	assign SNaN_SO = SNaN_SP;
endmodule

module prim_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	sky130_fd_sc_hd__dlclkp_1 CG(
		.CLK(clk_i),
		.GCLK(clk_o),
		.GATE(en_i | test_en_i)
	);
  /*reg en_latch;
  always @(*) begin
    if (!clk_i) begin
      en_latch = en_i | test_en_i;
    end
  end
  assign clk_o = en_latch & clk_i;*/
endmodule
module prim_filter_ctr (
	clk_i,
	rst_ni,
	enable_i,
	filter_i,
	filter_o
);
	parameter [31:0] Cycles = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire enable_i;
	input wire filter_i;
	output wire filter_o;
	localparam [31:0] CTR_WIDTH = $clog2(Cycles);
	function automatic [CTR_WIDTH - 1:0] sv2v_cast_FC6F8;
		input reg [CTR_WIDTH - 1:0] inp;
		sv2v_cast_FC6F8 = inp;
	endfunction
	localparam [CTR_WIDTH - 1:0] CYCLESM1 = sv2v_cast_FC6F8(Cycles - 1);
	reg [CTR_WIDTH - 1:0] diff_ctr_q;
	wire [CTR_WIDTH - 1:0] diff_ctr_d;
	reg filter_q;
	reg stored_value_q;
	wire update_stored_value;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			filter_q <= 1'b0;
		else
			filter_q <= filter_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			stored_value_q <= 1'b0;
		else if (update_stored_value)
			stored_value_q <= filter_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			diff_ctr_q <= {CTR_WIDTH {1'sb0}};
		else
			diff_ctr_q <= diff_ctr_d;
	assign diff_ctr_d = (filter_i != filter_q ? {CTR_WIDTH {1'sb0}} : (diff_ctr_q == CYCLESM1 ? CYCLESM1 : diff_ctr_q + 1'b1));
	assign update_stored_value = diff_ctr_d == CYCLESM1;
	assign filter_o = (enable_i ? stored_value_q : filter_i);
endmodule
module prim_generic_clock_inv (
	clk_i,
	scanmode_i,
	clk_no
);
	parameter [0:0] HasScanMode = 1'b1;
	input wire clk_i;
	input wire scanmode_i;
	output wire clk_no;
	generate
		if (HasScanMode) begin : gen_scan
			prim_generic_clock_mux2 i_dft_tck_mux(
				.clk0_i(~clk_i),
				.clk1_i(clk_i),
				.sel_i(scanmode_i),
				.clk_o(clk_no)
			);
		end
		else begin : gen_noscan
			wire unused_scanmode;
			assign unused_scanmode = scanmode_i;
			assign clk_no = ~clk_i;
		end
	endgenerate
endmodule
module prim_generic_clock_mux2 (
	clk0_i,
	clk1_i,
	sel_i,
	clk_o
);
	parameter [0:0] NoFpgaBufG = 1'b0;
	input wire clk0_i;
	input wire clk1_i;
	input wire sel_i;
	output wire clk_o;
	assign clk_o = (sel_i ? clk1_i : clk0_i);
endmodule
module prim_generic_flop_2sync (
	clk_i,
	rst_ni,
	d_i,
	q_o
);
	parameter signed [31:0] Width = 16;
	localparam signed [31:0] WidthSubOne = Width - 1;
	parameter [WidthSubOne:0] ResetValue = 1'sb0;
	input wire clk_i;
	input wire rst_ni;
	input wire [Width - 1:0] d_i;
	output wire [Width - 1:0] q_o;
	wire [Width - 1:0] intq;
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(d_i),
		.q_o(intq)
	);
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(intq),
		.q_o(q_o)
	);
endmodule
module prim_generic_flop (
	clk_i,
	rst_ni,
	d_i,
	q_o
);
	parameter signed [31:0] Width = 1;
	localparam signed [31:0] WidthSubOne = Width - 1;
	parameter [WidthSubOne:0] ResetValue = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire [Width - 1:0] d_i;
	output reg [Width - 1:0] q_o;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			q_o <= ResetValue;
		else
			q_o <= d_i;
endmodule
module prim_intr_hw (
	clk_i,
	rst_ni,
	event_intr_i,
	reg2hw_intr_enable_q_i,
	reg2hw_intr_test_q_i,
	reg2hw_intr_test_qe_i,
	reg2hw_intr_state_q_i,
	hw2reg_intr_state_de_o,
	hw2reg_intr_state_d_o,
	intr_o
);
	parameter [31:0] Width = 1;
	parameter [0:0] FlopOutput = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire [Width - 1:0] event_intr_i;
	input wire [Width - 1:0] reg2hw_intr_enable_q_i;
	input wire [Width - 1:0] reg2hw_intr_test_q_i;
	input wire reg2hw_intr_test_qe_i;
	input wire [Width - 1:0] reg2hw_intr_state_q_i;
	output wire hw2reg_intr_state_de_o;
	output wire [Width - 1:0] hw2reg_intr_state_d_o;
	output reg [Width - 1:0] intr_o;
	wire [Width - 1:0] new_event;
	assign new_event = ({Width {reg2hw_intr_test_qe_i}} & reg2hw_intr_test_q_i) | event_intr_i;
	assign hw2reg_intr_state_de_o = |new_event;
	assign hw2reg_intr_state_d_o = new_event | reg2hw_intr_state_q_i;
	generate
		if (FlopOutput == 1) begin : gen_flop_intr_output
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					intr_o <= 1'b0;
				else
					intr_o <= reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
		end
		else begin : gen_intr_passthrough_output
			wire unused_clk;
			wire unused_rst_n;
			assign unused_clk = clk_i;
			assign unused_rst_n = rst_ni;
			wire [Width:1] sv2v_tmp_BA45F;
			assign sv2v_tmp_BA45F = reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
			always @(*) intr_o = sv2v_tmp_BA45F;
		end
	endgenerate
endmodule
module prim_subreg_arb (
	we,
	wd,
	de,
	d,
	q,
	wr_en,
	wr_data
);
	parameter signed [31:0] DW = 32;
	parameter SWACCESS = "RW";
	input wire we;
	input wire [DW - 1:0] wd;
	input wire de;
	input wire [DW - 1:0] d;
	input wire [DW - 1:0] q;
	output wire wr_en;
	output wire [DW - 1:0] wr_data;
	generate
		if ((SWACCESS == "RW") || (SWACCESS == "WO")) begin : gen_w
			assign wr_en = we | de;
			assign wr_data = (we == 1'b1 ? wd : d);
			wire [DW - 1:0] unused_q;
			assign unused_q = q;
		end
		else if (SWACCESS == "RO") begin : gen_ro
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
		else if (SWACCESS == "W1S") begin : gen_w1s
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) | (we ? wd : {DW {1'sb0}});
		end
		else if (SWACCESS == "W1C") begin : gen_w1c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? ~wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "W0C") begin : gen_w0c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "RC") begin : gen_rc
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? {DW {1'sb0}} : {DW {1'sb1}});
			wire [DW - 1:0] unused_wd;
			assign unused_wd = wd;
		end
		else begin : gen_hw
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
	endgenerate
endmodule
module prim_subreg_ext (
	re,
	we,
	wd,
	d,
	qe,
	qre,
	q,
	qs
);
	parameter [31:0] DW = 32;
	input wire re;
	input wire we;
	input wire [DW - 1:0] wd;
	input wire [DW - 1:0] d;
	output wire qe;
	output wire qre;
	output wire [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	assign qs = d;
	assign q = wd;
	assign qe = we;
	assign qre = re;
endmodule
module prim_subreg (
	clk_i,
	rst_ni,
	we,
	wd,
	de,
	d,
	qe,
	q,
	qs
);
	parameter signed [31:0] DW = 32;
	parameter SWACCESS = "RW";
	parameter [DW - 1:0] RESVAL = 1'sb0;
	input wire clk_i;
	input wire rst_ni;
	input wire we;
	input wire [DW - 1:0] wd;
	input wire de;
	input wire [DW - 1:0] d;
	output reg qe;
	output reg [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	wire wr_en;
	wire [DW - 1:0] wr_data;
	prim_subreg_arb #(
		.DW(DW),
		.SWACCESS(SWACCESS)
	) wr_en_data_arb(
		.we(we),
		.wd(wd),
		.de(de),
		.d(d),
		.q(q),
		.wr_en(wr_en),
		.wr_data(wr_data)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			qe <= 1'b0;
		else
			qe <= we;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			q <= RESVAL;
		else if (wr_en)
			q <= wr_data;
	assign qs = q;
endmodule
module pwm_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	pwm_o,
	pwm_o_2,
	pwm1_oe,
	pwm2_oe
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire pwm_o;
	output wire pwm_o_2;
	output wire pwm1_oe;
	output wire pwm2_oe;
	localparam signed [31:0] AW = 8;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire re;
	wire we;
	wire [7:0] addr;
	wire [31:0] wdata;
	wire [3:0] be;
	wire [31:0] rdata;
	wire err;
	pwm pwm_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.re_i(re),
		.we_i(we),
		.addr_i(addr),
		.wdata_i(wdata),
		.be_i(be),
		.rdata_o(rdata),
		.o_pwm(pwm_o),
		.o_pwm_2(pwm_o_2),
		.oe_pwm1(pwm1_oe),
		.oe_pwm2(pwm2_oe)
	);
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.we_o(we),
		.re_o(re),
		.addr_o(addr),
		.wdata_o(wdata),
		.be_o(be),
		.rdata_i(rdata),
		.error_i(1'b0)
	);
endmodule
module pwm (
	clk_i,
	rst_ni,
	re_i,
	we_i,
	addr_i,
	wdata_i,
	be_i,
	rdata_o,
	o_pwm,
	o_pwm_2,
	oe_pwm1,
	oe_pwm2
);
	input wire clk_i;
	input wire rst_ni;
	input wire re_i;
	input wire we_i;
	input wire [7:0] addr_i;
	input wire [31:0] wdata_i;
	input wire [3:0] be_i;
	output wire [31:0] rdata_o;
	output wire o_pwm;
	output wire o_pwm_2;
	output reg oe_pwm1;
	output reg oe_pwm2;
	parameter adr_ctrl_1 = 0;
	parameter adr_divisor_1 = 4;
	parameter adr_period_1 = 8;
	parameter adr_DC_1 = 12;
	parameter adr_ctrl_2 = 16;
	parameter adr_divisor_2 = 20;
	parameter adr_period_2 = 24;
	parameter adr_DC_2 = 28;
	reg [7:0] ctrl;
	reg [15:0] period;
	reg [15:0] DC_1;
	reg [15:0] divisor;
	reg [7:0] ctrl_2;
	reg [15:0] period_2;
	reg [15:0] DC_2;
	reg [15:0] divisor_2;
	wire write;
	assign write = we_i & ~re_i;
	always @(posedge clk_i)
		if (~rst_ni) begin
			ctrl[4:2] <= 3'b000;
			ctrl[0] <= 1'b0;
			ctrl[1] <= 1'b0;
			ctrl[7:5] <= 3'b000;
			DC_1 <= 16'b0000000000000000;
			period <= 16'b0000000000000000;
			divisor <= 16'b0000000000000000;
			ctrl_2[4:2] <= 3'b000;
			ctrl_2[0] <= 1'b0;
			ctrl_2[7:5] <= 3'b000;
			ctrl_2[1] <= 1'b0;
			DC_2 <= 16'b0000000000000000;
			period_2 <= 16'b0000000000000000;
			divisor_2 <= 16'b0000000000000000;
		end
		else if (write)
			case (addr_i)
				adr_ctrl_1: begin
					ctrl[0] <= wdata_i[0];
					ctrl[1] <= 1'b1;
					ctrl[4:2] <= wdata_i[4:2];
					ctrl[7:5] <= wdata_i[7:5];
				end
				adr_ctrl_2: begin
					ctrl_2[0] <= wdata_i[0];
					ctrl_2[1] <= 1'b1;
					ctrl_2[4:2] <= wdata_i[4:2];
					ctrl_2[7:5] <= wdata_i[7:5];
				end
				adr_divisor_1: divisor <= wdata_i[15:0];
				adr_period_1: period <= wdata_i[15:0];
				adr_DC_1: DC_1 <= wdata_i[15:0];
				adr_divisor_2: divisor_2 <= wdata_i[15:0];
				adr_period_2: period_2 <= wdata_i[15:0];
				adr_DC_2: DC_2 <= wdata_i[15:0];
			endcase
	wire pwm_1;
	assign pwm_1 = ctrl[1];
	wire pwm_2;
	assign pwm_2 = ctrl_2[1];
	reg clock_p1;
	reg clock_p2;
	reg [15:0] counter_p1;
	reg [15:0] counter_p2;
	reg [15:0] period_counter1;
	reg [15:0] period_counter2;
	reg pts;
	reg pts_2;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			clock_p1 <= 1'b0;
			clock_p2 <= 1'b0;
			counter_p1 <= 16'b0000000000000000;
			counter_p2 <= 16'b0000000000000000;
		end
		else begin
			if (pwm_1) begin
				counter_p1 <= counter_p1 + 16'b0000000000000001;
				if (counter_p1 == (divisor - 1)) begin
					counter_p1 <= 16'b0000000000000000;
					clock_p1 <= ~clock_p1;
				end
			end
			if (pwm_2) begin
				counter_p2 <= counter_p2 + 16'b0000000000000001;
				if (counter_p2 == (divisor_2 - 1)) begin
					counter_p2 <= 16'b0000000000000000;
					clock_p2 <= ~clock_p2;
				end
			end
		end
	always @(posedge clock_p1)
		if (~rst_ni) begin
			pts <= 1'b0;
			period_counter1 <= 16'b0000000000000000;
		end
		else if (ctrl[2]) begin
			if (pwm_1) begin
				oe_pwm1 <= 1'b1;
				if (period_counter1 >= period)
					period_counter1 <= 16'b0000000000000000;
				else
					period_counter1 <= period_counter1 + 16'b0000000000000001;
				if (period_counter1 < DC_1)
					pts <= 1'b1;
				else
					pts <= 1'b0;
			end
		end
		else begin
			pts <= 1'b0;
			period_counter1 <= 16'b0000000000000000;
			oe_pwm1 <= 1'b0;
		end
	always @(posedge clock_p2)
		if (~rst_ni) begin
			pts_2 <= 1'b0;
			period_counter2 <= 16'b0000000000000000;
		end
		else if (ctrl_2[2]) begin
			if (pwm_2) begin
				oe_pwm2 <= 1'b1;
				if (period_counter2 >= period_2)
					period_counter2 <= 16'b0000000000000000;
				else
					period_counter2 <= period_counter2 + 16'b0000000000000001;
				if (period_counter2 < DC_2)
					pts_2 <= 1'b1;
				else
					pts_2 <= 1'b0;
			end
		end
		else begin
			pts_2 <= 1'b0;
			period_counter2 <= 16'b0000000000000000;
			oe_pwm2 <= 1'b0;
		end
	assign o_pwm = (ctrl[4] ? pts : 1'b0);
	assign o_pwm_2 = (ctrl_2[4] ? pts_2 : 1'b0);
	assign rdata_o = (addr_i == adr_ctrl_1 ? {8'h00, ctrl} : (addr_i == adr_divisor_1 ? divisor : (addr_i == adr_period_1 ? period : (addr_i == adr_DC_1 ? DC_1 : (addr_i == adr_DC_2 ? DC_2 : (addr_i == adr_period_2 ? period_2 : (addr_i == adr_divisor_2 ? divisor_2 : (addr_i == adr_ctrl_2 ? {8'h00, ctrl_2} : 32'b00000000000000000000000000000000))))))));
endmodule
module rr_arb_tree_252F1_F315E (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	req_o,
	gnt_i,
	data_o,
	idx_o
);
	parameter [31:0] DataType_Width = 0;
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	parameter [0:0] FairArb = 1'b1;
	parameter [31:0] IdxWidth = (NumIn > 32'd1 ? $unsigned($clog2(NumIn)) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [IdxWidth - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [((DataType_Width + 6) >= 0 ? (NumIn * (DataType_Width + 7)) - 1 : (NumIn * (1 - (DataType_Width + 6))) + (DataType_Width + 5)):((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6)] data_i;
	output wire req_o;
	input wire gnt_i;
	output wire [DataType_Width + 6:0] data_o;
	output wire [IdxWidth - 1:0] idx_o;
	generate
		if (NumIn == $unsigned(1)) begin : gen_pass_through
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6)+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))];
			assign idx_o = {IdxWidth {1'sb0}};
		end
		else begin : gen_arbiter
			localparam [31:0] NumLevels = $unsigned($clog2(NumIn));
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * IdxWidth) - 1 : ((3 - (2 ** NumLevels)) * IdxWidth) + ((((2 ** NumLevels) - 2) * IdxWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * IdxWidth)] index_nodes;
			wire [(((2 ** NumLevels) - 2) >= 0 ? ((DataType_Width + 6) >= 0 ? (((2 ** NumLevels) - 1) * (DataType_Width + 7)) - 1 : (((2 ** NumLevels) - 1) * (1 - (DataType_Width + 6))) + (DataType_Width + 5)) : ((DataType_Width + 6) >= 0 ? ((3 - (2 ** NumLevels)) * (DataType_Width + 7)) + ((((2 ** NumLevels) - 2) * (DataType_Width + 7)) - 1) : ((3 - (2 ** NumLevels)) * (1 - (DataType_Width + 6))) + (((DataType_Width + 6) + (((2 ** NumLevels) - 2) * (1 - (DataType_Width + 6)))) - 1))):(((2 ** NumLevels) - 2) >= 0 ? ((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) : ((DataType_Width + 6) >= 0 ? ((2 ** NumLevels) - 2) * (DataType_Width + 7) : (DataType_Width + 6) + (((2 ** NumLevels) - 2) * (1 - (DataType_Width + 6)))))] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [IdxWidth - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * IdxWidth+:IdxWidth];
			if (ExtPrio) begin : gen_ext_rr
				wire [IdxWidth:1] sv2v_tmp_48DE0;
				assign sv2v_tmp_48DE0 = rr_i;
				always @(*) rr_q = sv2v_tmp_48DE0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [IdxWidth - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'b0;
						else if (flush_i)
							lock_q <= 1'b0;
						else
							lock_q <= lock_d;
					end
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= {NumIn {1'sb0}};
						else if (flush_i)
							req_q <= {NumIn {1'sb0}};
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				if (FairArb) begin : gen_fair_arb
					wire [NumIn - 1:0] upper_mask;
					wire [NumIn - 1:0] lower_mask;
					wire [IdxWidth - 1:0] upper_idx;
					wire [IdxWidth - 1:0] lower_idx;
					wire [IdxWidth - 1:0] next_idx;
					wire upper_empty;
					wire lower_empty;
					genvar i;
					for (i = 0; i < NumIn; i = i + 1) begin : gen_mask
						assign upper_mask[i] = (i > rr_q ? req_d[i] : 1'b0);
						assign lower_mask[i] = (i <= rr_q ? req_d[i] : 1'b0);
					end
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_upper(
						.in_i(upper_mask),
						.cnt_o(upper_idx),
						.empty_o(upper_empty)
					);
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_lower(
						.in_i(lower_mask),
						.cnt_o(lower_idx),
						.empty_o()
					);
					assign next_idx = (upper_empty ? lower_idx : upper_idx);
					assign rr_d = (gnt_i && req_o ? next_idx : rr_q);
				end
				else begin : gen_unfair_arb
					function automatic [IdxWidth - 1:0] sv2v_cast_40B81;
						input reg [IdxWidth - 1:0] inp;
						sv2v_cast_40B81 = inp;
					endfunction
					assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_40B81(NumIn - 1) ? {IdxWidth {1'sb0}} : rr_q + 1'b1) : rr_q);
				end
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= {IdxWidth {1'sb0}};
					else if (flush_i)
						rr_q <= {IdxWidth {1'sb0}};
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] Idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] Idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : gen_reduce
							assign req_nodes[Idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							function automatic [IdxWidth - 1:0] sv2v_cast_40B81;
								input reg [IdxWidth - 1:0] inp;
								sv2v_cast_40B81 = inp;
							endfunction
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_40B81(sel);
							assign data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] = (sel ? data_i[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + (((l * 2) + 1) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] : data_i[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((l * 2) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))]);
							assign gnt_o[l * 2] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : gen_first
							assign req_nodes[Idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = {IdxWidth {1'sb0}};
							assign data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] = data_i[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((l * 2) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))];
							assign gnt_o[l * 2] = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : gen_out_of_range
							assign req_nodes[Idx0] = 1'b0;
							function automatic [IdxWidth - 1:0] sv2v_cast_40B81;
								input reg [IdxWidth - 1:0] inp;
								sv2v_cast_40B81 = inp;
							endfunction
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_40B81(1'sb0);
							function automatic [((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)) - 1:0] sv2v_cast_69F84;
								input reg [((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)) - 1:0] inp;
								sv2v_cast_69F84 = inp;
							endfunction
							assign data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] = sv2v_cast_69F84(1'sb0);
						end
					end
					else begin : gen_other_levels
						assign req_nodes[Idx0] = req_nodes[Idx1] | req_nodes[Idx1 + 1];
						assign sel = ~req_nodes[Idx1] | (req_nodes[Idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						function automatic [IdxWidth - 1:0] sv2v_cast_40B81;
							input reg [IdxWidth - 1:0] inp;
							sv2v_cast_40B81 = inp;
						endfunction
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = (sel ? sv2v_cast_40B81({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_40B81({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] = (sel ? data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))] : data_nodes[((DataType_Width + 6) >= 0 ? 0 : DataType_Width + 6) + ((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * ((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6)))+:((DataType_Width + 6) >= 0 ? DataType_Width + 7 : 1 - (DataType_Width + 6))]);
						assign gnt_nodes[Idx1] = gnt_nodes[Idx0] & ~sel;
						assign gnt_nodes[Idx1 + 1] = gnt_nodes[Idx0] & sel;
					end
				end
			end
		end
	endgenerate
endmodule
module rr_arb_tree_CBEBF_6E668 (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	req_o,
	gnt_i,
	data_o,
	idx_o
);
	parameter [31:0] DataType_WIDTH = 0;
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	parameter [0:0] FairArb = 1'b1;
	parameter [31:0] IdxWidth = (NumIn > 32'd1 ? $unsigned($clog2(NumIn)) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [IdxWidth - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [((DataType_WIDTH + 5) >= 0 ? (NumIn * (DataType_WIDTH + 6)) - 1 : (NumIn * (1 - (DataType_WIDTH + 5))) + (DataType_WIDTH + 4)):((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5)] data_i;
	output wire req_o;
	input wire gnt_i;
	output wire [DataType_WIDTH + 5:0] data_o;
	output wire [IdxWidth - 1:0] idx_o;
	generate
		if (NumIn == $unsigned(1)) begin : gen_pass_through
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5)+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))];
			assign idx_o = {IdxWidth {1'sb0}};
		end
		else begin : gen_arbiter
			localparam [31:0] NumLevels = $unsigned($clog2(NumIn));
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * IdxWidth) - 1 : ((3 - (2 ** NumLevels)) * IdxWidth) + ((((2 ** NumLevels) - 2) * IdxWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * IdxWidth)] index_nodes;
			wire [(((2 ** NumLevels) - 2) >= 0 ? ((DataType_WIDTH + 5) >= 0 ? (((2 ** NumLevels) - 1) * (DataType_WIDTH + 6)) - 1 : (((2 ** NumLevels) - 1) * (1 - (DataType_WIDTH + 5))) + (DataType_WIDTH + 4)) : ((DataType_WIDTH + 5) >= 0 ? ((3 - (2 ** NumLevels)) * (DataType_WIDTH + 6)) + ((((2 ** NumLevels) - 2) * (DataType_WIDTH + 6)) - 1) : ((3 - (2 ** NumLevels)) * (1 - (DataType_WIDTH + 5))) + (((DataType_WIDTH + 5) + (((2 ** NumLevels) - 2) * (1 - (DataType_WIDTH + 5)))) - 1))):(((2 ** NumLevels) - 2) >= 0 ? ((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) : ((DataType_WIDTH + 5) >= 0 ? ((2 ** NumLevels) - 2) * (DataType_WIDTH + 6) : (DataType_WIDTH + 5) + (((2 ** NumLevels) - 2) * (1 - (DataType_WIDTH + 5)))))] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [IdxWidth - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * IdxWidth+:IdxWidth];
			if (ExtPrio) begin : gen_ext_rr
				wire [IdxWidth:1] sv2v_tmp_48DE0;
				assign sv2v_tmp_48DE0 = rr_i;
				always @(*) rr_q = sv2v_tmp_48DE0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [IdxWidth - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'b0;
						else if (flush_i)
							lock_q <= 1'b0;
						else
							lock_q <= lock_d;
					end
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= {NumIn {1'sb0}};
						else if (flush_i)
							req_q <= {NumIn {1'sb0}};
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				if (FairArb) begin : gen_fair_arb
					wire [NumIn - 1:0] upper_mask;
					wire [NumIn - 1:0] lower_mask;
					wire [IdxWidth - 1:0] upper_idx;
					wire [IdxWidth - 1:0] lower_idx;
					wire [IdxWidth - 1:0] next_idx;
					wire upper_empty;
					wire lower_empty;
					genvar i;
					for (i = 0; i < NumIn; i = i + 1) begin : gen_mask
						assign upper_mask[i] = (i > rr_q ? req_d[i] : 1'b0);
						assign lower_mask[i] = (i <= rr_q ? req_d[i] : 1'b0);
					end
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_upper(
						.in_i(upper_mask),
						.cnt_o(upper_idx),
						.empty_o(upper_empty)
					);
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_lower(
						.in_i(lower_mask),
						.cnt_o(lower_idx),
						.empty_o()
					);
					assign next_idx = (upper_empty ? lower_idx : upper_idx);
					assign rr_d = (gnt_i && req_o ? next_idx : rr_q);
				end
				else begin : gen_unfair_arb
					function automatic [IdxWidth - 1:0] sv2v_cast_15989;
						input reg [IdxWidth - 1:0] inp;
						sv2v_cast_15989 = inp;
					endfunction
					assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_15989(NumIn - 1) ? {IdxWidth {1'sb0}} : rr_q + 1'b1) : rr_q);
				end
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= {IdxWidth {1'sb0}};
					else if (flush_i)
						rr_q <= {IdxWidth {1'sb0}};
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] Idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] Idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : gen_reduce
							assign req_nodes[Idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							function automatic [IdxWidth - 1:0] sv2v_cast_15989;
								input reg [IdxWidth - 1:0] inp;
								sv2v_cast_15989 = inp;
							endfunction
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_15989(sel);
							assign data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] = (sel ? data_i[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + (((l * 2) + 1) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] : data_i[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((l * 2) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))]);
							assign gnt_o[l * 2] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : gen_first
							assign req_nodes[Idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = {IdxWidth {1'sb0}};
							assign data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] = data_i[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((l * 2) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))];
							assign gnt_o[l * 2] = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : gen_out_of_range
							assign req_nodes[Idx0] = 1'b0;
							function automatic [IdxWidth - 1:0] sv2v_cast_15989;
								input reg [IdxWidth - 1:0] inp;
								sv2v_cast_15989 = inp;
							endfunction
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_15989(1'sb0);
							function automatic [((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)) - 1:0] sv2v_cast_FF7FF;
								input reg [((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)) - 1:0] inp;
								sv2v_cast_FF7FF = inp;
							endfunction
							assign data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] = sv2v_cast_FF7FF(1'sb0);
						end
					end
					else begin : gen_other_levels
						assign req_nodes[Idx0] = req_nodes[Idx1] | req_nodes[Idx1 + 1];
						assign sel = ~req_nodes[Idx1] | (req_nodes[Idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						function automatic [IdxWidth - 1:0] sv2v_cast_15989;
							input reg [IdxWidth - 1:0] inp;
							sv2v_cast_15989 = inp;
						endfunction
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = (sel ? sv2v_cast_15989({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_15989({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] = (sel ? data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))] : data_nodes[((DataType_WIDTH + 5) >= 0 ? 0 : DataType_WIDTH + 5) + ((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * ((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5)))+:((DataType_WIDTH + 5) >= 0 ? DataType_WIDTH + 6 : 1 - (DataType_WIDTH + 5))]);
						assign gnt_nodes[Idx1] = gnt_nodes[Idx0] & ~sel;
						assign gnt_nodes[Idx1 + 1] = gnt_nodes[Idx0] & sel;
					end
				end
			end
		end
	endgenerate
endmodule

module rv_plic_gateway (
	clk_i,
	rst_ni,
	src_i,
	le_i,
	claim_i,
	complete_i,
	ip_o
);
	parameter signed [31:0] N_SOURCE = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire [N_SOURCE - 1:0] src_i;
	input wire [N_SOURCE - 1:0] le_i;
	input wire [N_SOURCE - 1:0] claim_i;
	input wire [N_SOURCE - 1:0] complete_i;
	output reg [N_SOURCE - 1:0] ip_o;
	reg [N_SOURCE - 1:0] ia;
	reg [N_SOURCE - 1:0] set;
	reg [N_SOURCE - 1:0] src_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			src_q <= {N_SOURCE {1'sb0}};
		else
			src_q <= src_i;
	always @(*) begin : sv2v_autoblock_136
		reg signed [31:0] i;
		for (i = 0; i < N_SOURCE; i = i + 1)
			set[i] = (le_i[i] ? src_i[i] & ~src_q[i] : src_i[i]);
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ip_o <= {N_SOURCE {1'sb0}};
		else
			ip_o <= (ip_o | ((set & ~ia) & ~ip_o)) & ~(ip_o & claim_i);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ia <= {N_SOURCE {1'sb0}};
		else
			ia <= (ia | (set & ~ia)) & ~((ia & complete_i) & ~ip_o);
endmodule
module rv_plic_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire [154:0] reg2hw;
	input wire [77:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] AW = 10;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire reg_we;
	wire reg_re;
	wire [9:0] reg_addr;
	wire [31:0] reg_wdata;
	wire [3:0] reg_be;
	wire [31:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [31:0] reg_rdata_next;
	wire [85:0] tl_reg_h2d;
	wire [51:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire ip_0_p_0_qs;
	wire ip_0_p_1_qs;
	wire ip_0_p_2_qs;
	wire ip_0_p_3_qs;
	wire ip_0_p_4_qs;
	wire ip_0_p_5_qs;
	wire ip_0_p_6_qs;
	wire ip_0_p_7_qs;
	wire ip_0_p_8_qs;
	wire ip_0_p_9_qs;
	wire ip_0_p_10_qs;
	wire ip_0_p_11_qs;
	wire ip_0_p_12_qs;
	wire ip_0_p_13_qs;
	wire ip_0_p_14_qs;
	wire ip_0_p_15_qs;
	wire ip_0_p_16_qs;
	wire ip_0_p_17_qs;
	wire ip_0_p_18_qs;
	wire ip_0_p_19_qs;
	wire ip_0_p_20_qs;
	wire ip_0_p_21_qs;
	wire ip_0_p_22_qs;
	wire ip_0_p_23_qs;
	wire ip_0_p_24_qs;
	wire ip_0_p_25_qs;
	wire ip_0_p_26_qs;
	wire ip_0_p_27_qs;
	wire ip_0_p_28_qs;
	wire ip_0_p_29_qs;
	wire ip_0_p_30_qs;
	wire ip_0_p_31_qs;
	wire ip_1_p_32_qs;
	wire ip_1_p_33_qs;
	wire ip_1_p_34_qs;
	wire ip_1_p_35_qs;
	wire ip_1_p_36_qs;
	wire ip_1_p_37_qs;
	wire ip_1_p_38_qs;
	wire ip_1_p_39_qs;
	wire ip_1_p_40_qs;
	wire ip_1_p_41_qs;
	wire ip_1_p_42_qs;
	wire ip_1_p_43_qs;
	wire le_0_le_0_qs;
	wire le_0_le_0_wd;
	wire le_0_le_0_we;
	wire le_0_le_1_qs;
	wire le_0_le_1_wd;
	wire le_0_le_1_we;
	wire le_0_le_2_qs;
	wire le_0_le_2_wd;
	wire le_0_le_2_we;
	wire le_0_le_3_qs;
	wire le_0_le_3_wd;
	wire le_0_le_3_we;
	wire le_0_le_4_qs;
	wire le_0_le_4_wd;
	wire le_0_le_4_we;
	wire le_0_le_5_qs;
	wire le_0_le_5_wd;
	wire le_0_le_5_we;
	wire le_0_le_6_qs;
	wire le_0_le_6_wd;
	wire le_0_le_6_we;
	wire le_0_le_7_qs;
	wire le_0_le_7_wd;
	wire le_0_le_7_we;
	wire le_0_le_8_qs;
	wire le_0_le_8_wd;
	wire le_0_le_8_we;
	wire le_0_le_9_qs;
	wire le_0_le_9_wd;
	wire le_0_le_9_we;
	wire le_0_le_10_qs;
	wire le_0_le_10_wd;
	wire le_0_le_10_we;
	wire le_0_le_11_qs;
	wire le_0_le_11_wd;
	wire le_0_le_11_we;
	wire le_0_le_12_qs;
	wire le_0_le_12_wd;
	wire le_0_le_12_we;
	wire le_0_le_13_qs;
	wire le_0_le_13_wd;
	wire le_0_le_13_we;
	wire le_0_le_14_qs;
	wire le_0_le_14_wd;
	wire le_0_le_14_we;
	wire le_0_le_15_qs;
	wire le_0_le_15_wd;
	wire le_0_le_15_we;
	wire le_0_le_16_qs;
	wire le_0_le_16_wd;
	wire le_0_le_16_we;
	wire le_0_le_17_qs;
	wire le_0_le_17_wd;
	wire le_0_le_17_we;
	wire le_0_le_18_qs;
	wire le_0_le_18_wd;
	wire le_0_le_18_we;
	wire le_0_le_19_qs;
	wire le_0_le_19_wd;
	wire le_0_le_19_we;
	wire le_0_le_20_qs;
	wire le_0_le_20_wd;
	wire le_0_le_20_we;
	wire le_0_le_21_qs;
	wire le_0_le_21_wd;
	wire le_0_le_21_we;
	wire le_0_le_22_qs;
	wire le_0_le_22_wd;
	wire le_0_le_22_we;
	wire le_0_le_23_qs;
	wire le_0_le_23_wd;
	wire le_0_le_23_we;
	wire le_0_le_24_qs;
	wire le_0_le_24_wd;
	wire le_0_le_24_we;
	wire le_0_le_25_qs;
	wire le_0_le_25_wd;
	wire le_0_le_25_we;
	wire le_0_le_26_qs;
	wire le_0_le_26_wd;
	wire le_0_le_26_we;
	wire le_0_le_27_qs;
	wire le_0_le_27_wd;
	wire le_0_le_27_we;
	wire le_0_le_28_qs;
	wire le_0_le_28_wd;
	wire le_0_le_28_we;
	wire le_0_le_29_qs;
	wire le_0_le_29_wd;
	wire le_0_le_29_we;
	wire le_0_le_30_qs;
	wire le_0_le_30_wd;
	wire le_0_le_30_we;
	wire le_0_le_31_qs;
	wire le_0_le_31_wd;
	wire le_0_le_31_we;
	wire le_1_le_32_qs;
	wire le_1_le_32_wd;
	wire le_1_le_32_we;
	wire le_1_le_33_qs;
	wire le_1_le_33_wd;
	wire le_1_le_33_we;
	wire le_1_le_34_qs;
	wire le_1_le_34_wd;
	wire le_1_le_34_we;
	wire le_1_le_35_qs;
	wire le_1_le_35_wd;
	wire le_1_le_35_we;
	wire [1:0] prio0_qs;
	wire [1:0] prio0_wd;
	wire prio0_we;
	wire [1:0] prio1_qs;
	wire [1:0] prio1_wd;
	wire prio1_we;
	wire [1:0] prio2_qs;
	wire [1:0] prio2_wd;
	wire prio2_we;
	wire [1:0] prio3_qs;
	wire [1:0] prio3_wd;
	wire prio3_we;
	wire [1:0] prio4_qs;
	wire [1:0] prio4_wd;
	wire prio4_we;
	wire [1:0] prio5_qs;
	wire [1:0] prio5_wd;
	wire prio5_we;
	wire [1:0] prio6_qs;
	wire [1:0] prio6_wd;
	wire prio6_we;
	wire [1:0] prio7_qs;
	wire [1:0] prio7_wd;
	wire prio7_we;
	wire [1:0] prio8_qs;
	wire [1:0] prio8_wd;
	wire prio8_we;
	wire [1:0] prio9_qs;
	wire [1:0] prio9_wd;
	wire prio9_we;
	wire [1:0] prio10_qs;
	wire [1:0] prio10_wd;
	wire prio10_we;
	wire [1:0] prio11_qs;
	wire [1:0] prio11_wd;
	wire prio11_we;
	wire [1:0] prio12_qs;
	wire [1:0] prio12_wd;
	wire prio12_we;
	wire [1:0] prio13_qs;
	wire [1:0] prio13_wd;
	wire prio13_we;
	wire [1:0] prio14_qs;
	wire [1:0] prio14_wd;
	wire prio14_we;
	wire [1:0] prio15_qs;
	wire [1:0] prio15_wd;
	wire prio15_we;
	wire [1:0] prio16_qs;
	wire [1:0] prio16_wd;
	wire prio16_we;
	wire [1:0] prio17_qs;
	wire [1:0] prio17_wd;
	wire prio17_we;
	wire [1:0] prio18_qs;
	wire [1:0] prio18_wd;
	wire prio18_we;
	wire [1:0] prio19_qs;
	wire [1:0] prio19_wd;
	wire prio19_we;
	wire [1:0] prio20_qs;
	wire [1:0] prio20_wd;
	wire prio20_we;
	wire [1:0] prio21_qs;
	wire [1:0] prio21_wd;
	wire prio21_we;
	wire [1:0] prio22_qs;
	wire [1:0] prio22_wd;
	wire prio22_we;
	wire [1:0] prio23_qs;
	wire [1:0] prio23_wd;
	wire prio23_we;
	wire [1:0] prio24_qs;
	wire [1:0] prio24_wd;
	wire prio24_we;
	wire [1:0] prio25_qs;
	wire [1:0] prio25_wd;
	wire prio25_we;
	wire [1:0] prio26_qs;
	wire [1:0] prio26_wd;
	wire prio26_we;
	wire [1:0] prio27_qs;
	wire [1:0] prio27_wd;
	wire prio27_we;
	wire [1:0] prio28_qs;
	wire [1:0] prio28_wd;
	wire prio28_we;
	wire [1:0] prio29_qs;
	wire [1:0] prio29_wd;
	wire prio29_we;
	wire [1:0] prio30_qs;
	wire [1:0] prio30_wd;
	wire prio30_we;
	wire [1:0] prio31_qs;
	wire [1:0] prio31_wd;
	wire prio31_we;
	wire [1:0] prio32_qs;
	wire [1:0] prio32_wd;
	wire prio32_we;
	wire [1:0] prio33_qs;
	wire [1:0] prio33_wd;
	wire prio33_we;
	wire [1:0] prio34_qs;
	wire [1:0] prio34_wd;
	wire prio34_we;
	wire [1:0] prio35_qs;
	wire [1:0] prio35_wd;
	wire prio35_we;
	wire ie0_0_e_0_qs;
	wire ie0_0_e_0_wd;
	wire ie0_0_e_0_we;
	wire ie0_0_e_1_qs;
	wire ie0_0_e_1_wd;
	wire ie0_0_e_1_we;
	wire ie0_0_e_2_qs;
	wire ie0_0_e_2_wd;
	wire ie0_0_e_2_we;
	wire ie0_0_e_3_qs;
	wire ie0_0_e_3_wd;
	wire ie0_0_e_3_we;
	wire ie0_0_e_4_qs;
	wire ie0_0_e_4_wd;
	wire ie0_0_e_4_we;
	wire ie0_0_e_5_qs;
	wire ie0_0_e_5_wd;
	wire ie0_0_e_5_we;
	wire ie0_0_e_6_qs;
	wire ie0_0_e_6_wd;
	wire ie0_0_e_6_we;
	wire ie0_0_e_7_qs;
	wire ie0_0_e_7_wd;
	wire ie0_0_e_7_we;
	wire ie0_0_e_8_qs;
	wire ie0_0_e_8_wd;
	wire ie0_0_e_8_we;
	wire ie0_0_e_9_qs;
	wire ie0_0_e_9_wd;
	wire ie0_0_e_9_we;
	wire ie0_0_e_10_qs;
	wire ie0_0_e_10_wd;
	wire ie0_0_e_10_we;
	wire ie0_0_e_11_qs;
	wire ie0_0_e_11_wd;
	wire ie0_0_e_11_we;
	wire ie0_0_e_12_qs;
	wire ie0_0_e_12_wd;
	wire ie0_0_e_12_we;
	wire ie0_0_e_13_qs;
	wire ie0_0_e_13_wd;
	wire ie0_0_e_13_we;
	wire ie0_0_e_14_qs;
	wire ie0_0_e_14_wd;
	wire ie0_0_e_14_we;
	wire ie0_0_e_15_qs;
	wire ie0_0_e_15_wd;
	wire ie0_0_e_15_we;
	wire ie0_0_e_16_qs;
	wire ie0_0_e_16_wd;
	wire ie0_0_e_16_we;
	wire ie0_0_e_17_qs;
	wire ie0_0_e_17_wd;
	wire ie0_0_e_17_we;
	wire ie0_0_e_18_qs;
	wire ie0_0_e_18_wd;
	wire ie0_0_e_18_we;
	wire ie0_0_e_19_qs;
	wire ie0_0_e_19_wd;
	wire ie0_0_e_19_we;
	wire ie0_0_e_20_qs;
	wire ie0_0_e_20_wd;
	wire ie0_0_e_20_we;
	wire ie0_0_e_21_qs;
	wire ie0_0_e_21_wd;
	wire ie0_0_e_21_we;
	wire ie0_0_e_22_qs;
	wire ie0_0_e_22_wd;
	wire ie0_0_e_22_we;
	wire ie0_0_e_23_qs;
	wire ie0_0_e_23_wd;
	wire ie0_0_e_23_we;
	wire ie0_0_e_24_qs;
	wire ie0_0_e_24_wd;
	wire ie0_0_e_24_we;
	wire ie0_0_e_25_qs;
	wire ie0_0_e_25_wd;
	wire ie0_0_e_25_we;
	wire ie0_0_e_26_qs;
	wire ie0_0_e_26_wd;
	wire ie0_0_e_26_we;
	wire ie0_0_e_27_qs;
	wire ie0_0_e_27_wd;
	wire ie0_0_e_27_we;
	wire ie0_0_e_28_qs;
	wire ie0_0_e_28_wd;
	wire ie0_0_e_28_we;
	wire ie0_0_e_29_qs;
	wire ie0_0_e_29_wd;
	wire ie0_0_e_29_we;
	wire ie0_0_e_30_qs;
	wire ie0_0_e_30_wd;
	wire ie0_0_e_30_we;
	wire ie0_0_e_31_qs;
	wire ie0_0_e_31_wd;
	wire ie0_0_e_31_we;
	wire ie0_1_e_32_qs;
	wire ie0_1_e_32_wd;
	wire ie0_1_e_32_we;
	wire ie0_1_e_33_qs;
	wire ie0_1_e_33_wd;
	wire ie0_1_e_33_we;
	wire ie0_1_e_34_qs;
	wire ie0_1_e_34_wd;
	wire ie0_1_e_34_we;
	wire ie0_1_e_35_qs;
	wire ie0_1_e_35_wd;
	wire ie0_1_e_35_we;
	wire [1:0] threshold0_qs;
	wire [1:0] threshold0_wd;
	wire threshold0_we;
	wire [5:0] cc0_qs;
	wire [5:0] cc0_wd;
	wire cc0_we;
	wire cc0_re;
	wire msip0_qs;
	wire msip0_wd;
	wire msip0_we;
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[6]),
		.d(hw2reg[7]),
		.qe(),
		.q(),
		.qs(ip_0_p_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[8]),
		.d(hw2reg[9]),
		.qe(),
		.q(),
		.qs(ip_0_p_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[10]),
		.d(hw2reg[11]),
		.qe(),
		.q(),
		.qs(ip_0_p_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[12]),
		.d(hw2reg[13]),
		.qe(),
		.q(),
		.qs(ip_0_p_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[14]),
		.d(hw2reg[15]),
		.qe(),
		.q(),
		.qs(ip_0_p_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[16]),
		.d(hw2reg[17]),
		.qe(),
		.q(),
		.qs(ip_0_p_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[18]),
		.d(hw2reg[19]),
		.qe(),
		.q(),
		.qs(ip_0_p_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[20]),
		.d(hw2reg[21]),
		.qe(),
		.q(),
		.qs(ip_0_p_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[22]),
		.d(hw2reg[23]),
		.qe(),
		.q(),
		.qs(ip_0_p_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[24]),
		.d(hw2reg[25]),
		.qe(),
		.q(),
		.qs(ip_0_p_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[26]),
		.d(hw2reg[27]),
		.qe(),
		.q(),
		.qs(ip_0_p_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[28]),
		.d(hw2reg[29]),
		.qe(),
		.q(),
		.qs(ip_0_p_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[30]),
		.d(hw2reg[31]),
		.qe(),
		.q(),
		.qs(ip_0_p_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[32]),
		.d(hw2reg[33]),
		.qe(),
		.q(),
		.qs(ip_0_p_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[34]),
		.d(hw2reg[35]),
		.qe(),
		.q(),
		.qs(ip_0_p_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[36]),
		.d(hw2reg[37]),
		.qe(),
		.q(),
		.qs(ip_0_p_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[38]),
		.d(hw2reg[39]),
		.qe(),
		.q(),
		.qs(ip_0_p_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[40]),
		.d(hw2reg[41]),
		.qe(),
		.q(),
		.qs(ip_0_p_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[42]),
		.d(hw2reg[43]),
		.qe(),
		.q(),
		.qs(ip_0_p_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[44]),
		.d(hw2reg[45]),
		.qe(),
		.q(),
		.qs(ip_0_p_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[46]),
		.d(hw2reg[47]),
		.qe(),
		.q(),
		.qs(ip_0_p_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[48]),
		.d(hw2reg[49]),
		.qe(),
		.q(),
		.qs(ip_0_p_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[50]),
		.d(hw2reg[51]),
		.qe(),
		.q(),
		.qs(ip_0_p_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[52]),
		.d(hw2reg[53]),
		.qe(),
		.q(),
		.qs(ip_0_p_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[54]),
		.d(hw2reg[55]),
		.qe(),
		.q(),
		.qs(ip_0_p_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[56]),
		.d(hw2reg[57]),
		.qe(),
		.q(),
		.qs(ip_0_p_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[58]),
		.d(hw2reg[59]),
		.qe(),
		.q(),
		.qs(ip_0_p_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[60]),
		.d(hw2reg[61]),
		.qe(),
		.q(),
		.qs(ip_0_p_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[62]),
		.d(hw2reg[63]),
		.qe(),
		.q(),
		.qs(ip_0_p_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[64]),
		.d(hw2reg[65]),
		.qe(),
		.q(),
		.qs(ip_0_p_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[66]),
		.d(hw2reg[67]),
		.qe(),
		.q(),
		.qs(ip_0_p_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_0_p_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[68]),
		.d(hw2reg[69]),
		.qe(),
		.q(),
		.qs(ip_0_p_31_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_1_p_32(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[70]),
		.d(hw2reg[71]),
		.qe(),
		.q(),
		.qs(ip_1_p_32_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_1_p_33(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[72]),
		.d(hw2reg[73]),
		.qe(),
		.q(),
		.qs(ip_1_p_33_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_1_p_34(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[74]),
		.d(hw2reg[75]),
		.qe(),
		.q(),
		.qs(ip_1_p_34_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_1_p_35(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'b0),
		.de(hw2reg[76]),
		.d(hw2reg[77]),
		.qe(),
		.q(),
		.qs(ip_1_p_35_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_0_we),
		.wd(le_0_le_0_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[119]),
		.qs(le_0_le_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_1_we),
		.wd(le_0_le_1_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[120]),
		.qs(le_0_le_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_2_we),
		.wd(le_0_le_2_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[121]),
		.qs(le_0_le_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_3_we),
		.wd(le_0_le_3_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[122]),
		.qs(le_0_le_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_4_we),
		.wd(le_0_le_4_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[123]),
		.qs(le_0_le_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_5_we),
		.wd(le_0_le_5_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[124]),
		.qs(le_0_le_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_6_we),
		.wd(le_0_le_6_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[125]),
		.qs(le_0_le_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_7_we),
		.wd(le_0_le_7_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[126]),
		.qs(le_0_le_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_8_we),
		.wd(le_0_le_8_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[127]),
		.qs(le_0_le_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_9_we),
		.wd(le_0_le_9_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[128]),
		.qs(le_0_le_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_10_we),
		.wd(le_0_le_10_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[129]),
		.qs(le_0_le_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_11_we),
		.wd(le_0_le_11_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[130]),
		.qs(le_0_le_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_12_we),
		.wd(le_0_le_12_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[131]),
		.qs(le_0_le_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_13_we),
		.wd(le_0_le_13_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[132]),
		.qs(le_0_le_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_14_we),
		.wd(le_0_le_14_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[133]),
		.qs(le_0_le_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_15_we),
		.wd(le_0_le_15_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[134]),
		.qs(le_0_le_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_16_we),
		.wd(le_0_le_16_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[135]),
		.qs(le_0_le_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_17_we),
		.wd(le_0_le_17_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[136]),
		.qs(le_0_le_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_18_we),
		.wd(le_0_le_18_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[137]),
		.qs(le_0_le_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_19_we),
		.wd(le_0_le_19_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[138]),
		.qs(le_0_le_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_20_we),
		.wd(le_0_le_20_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[139]),
		.qs(le_0_le_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_21_we),
		.wd(le_0_le_21_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[140]),
		.qs(le_0_le_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_22_we),
		.wd(le_0_le_22_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[141]),
		.qs(le_0_le_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_23_we),
		.wd(le_0_le_23_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[142]),
		.qs(le_0_le_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_24_we),
		.wd(le_0_le_24_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[143]),
		.qs(le_0_le_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_25_we),
		.wd(le_0_le_25_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[144]),
		.qs(le_0_le_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_26_we),
		.wd(le_0_le_26_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[145]),
		.qs(le_0_le_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_27_we),
		.wd(le_0_le_27_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[146]),
		.qs(le_0_le_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_28_we),
		.wd(le_0_le_28_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[147]),
		.qs(le_0_le_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_29_we),
		.wd(le_0_le_29_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[148]),
		.qs(le_0_le_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_30_we),
		.wd(le_0_le_30_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[149]),
		.qs(le_0_le_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_0_le_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_0_le_31_we),
		.wd(le_0_le_31_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[150]),
		.qs(le_0_le_31_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_1_le_32(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_1_le_32_we),
		.wd(le_1_le_32_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[151]),
		.qs(le_1_le_32_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_1_le_33(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_1_le_33_we),
		.wd(le_1_le_33_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[152]),
		.qs(le_1_le_33_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_1_le_34(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_1_le_34_we),
		.wd(le_1_le_34_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[153]),
		.qs(le_1_le_34_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_1_le_35(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_1_le_35_we),
		.wd(le_1_le_35_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[154]),
		.qs(le_1_le_35_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio0_we),
		.wd(prio0_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[118-:2]),
		.qs(prio0_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio1_we),
		.wd(prio1_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[116-:2]),
		.qs(prio1_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio2_we),
		.wd(prio2_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[114-:2]),
		.qs(prio2_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio3_we),
		.wd(prio3_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[112-:2]),
		.qs(prio3_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio4_we),
		.wd(prio4_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[110-:2]),
		.qs(prio4_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio5_we),
		.wd(prio5_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[108-:2]),
		.qs(prio5_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio6_we),
		.wd(prio6_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[106-:2]),
		.qs(prio6_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio7_we),
		.wd(prio7_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[104-:2]),
		.qs(prio7_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio8_we),
		.wd(prio8_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[102-:2]),
		.qs(prio8_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio9_we),
		.wd(prio9_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[100-:2]),
		.qs(prio9_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio10_we),
		.wd(prio10_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[98-:2]),
		.qs(prio10_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio11_we),
		.wd(prio11_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[96-:2]),
		.qs(prio11_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio12_we),
		.wd(prio12_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[94-:2]),
		.qs(prio12_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio13_we),
		.wd(prio13_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[92-:2]),
		.qs(prio13_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio14_we),
		.wd(prio14_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[90-:2]),
		.qs(prio14_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio15_we),
		.wd(prio15_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[88-:2]),
		.qs(prio15_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio16_we),
		.wd(prio16_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[86-:2]),
		.qs(prio16_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio17_we),
		.wd(prio17_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[84-:2]),
		.qs(prio17_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio18_we),
		.wd(prio18_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[82-:2]),
		.qs(prio18_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio19_we),
		.wd(prio19_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[80-:2]),
		.qs(prio19_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio20_we),
		.wd(prio20_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[78-:2]),
		.qs(prio20_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio21_we),
		.wd(prio21_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[76-:2]),
		.qs(prio21_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio22_we),
		.wd(prio22_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[74-:2]),
		.qs(prio22_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio23_we),
		.wd(prio23_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[72-:2]),
		.qs(prio23_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio24_we),
		.wd(prio24_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[70-:2]),
		.qs(prio24_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio25_we),
		.wd(prio25_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[68-:2]),
		.qs(prio25_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio26_we),
		.wd(prio26_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[66-:2]),
		.qs(prio26_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio27_we),
		.wd(prio27_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[64-:2]),
		.qs(prio27_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio28_we),
		.wd(prio28_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[62-:2]),
		.qs(prio28_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio29_we),
		.wd(prio29_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[60-:2]),
		.qs(prio29_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio30_we),
		.wd(prio30_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[58-:2]),
		.qs(prio30_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio31_we),
		.wd(prio31_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[56-:2]),
		.qs(prio31_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio32(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio32_we),
		.wd(prio32_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[54-:2]),
		.qs(prio32_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio33(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio33_we),
		.wd(prio33_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[52-:2]),
		.qs(prio33_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio34(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio34_we),
		.wd(prio34_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[50-:2]),
		.qs(prio34_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_prio35(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio35_we),
		.wd(prio35_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[48-:2]),
		.qs(prio35_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_0_we),
		.wd(ie0_0_e_0_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[11]),
		.qs(ie0_0_e_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_1_we),
		.wd(ie0_0_e_1_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[12]),
		.qs(ie0_0_e_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_2_we),
		.wd(ie0_0_e_2_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[13]),
		.qs(ie0_0_e_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_3_we),
		.wd(ie0_0_e_3_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[14]),
		.qs(ie0_0_e_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_4_we),
		.wd(ie0_0_e_4_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[15]),
		.qs(ie0_0_e_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_5_we),
		.wd(ie0_0_e_5_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[16]),
		.qs(ie0_0_e_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_6_we),
		.wd(ie0_0_e_6_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[17]),
		.qs(ie0_0_e_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_7_we),
		.wd(ie0_0_e_7_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[18]),
		.qs(ie0_0_e_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_8_we),
		.wd(ie0_0_e_8_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[19]),
		.qs(ie0_0_e_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_9_we),
		.wd(ie0_0_e_9_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[20]),
		.qs(ie0_0_e_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_10_we),
		.wd(ie0_0_e_10_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[21]),
		.qs(ie0_0_e_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_11_we),
		.wd(ie0_0_e_11_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[22]),
		.qs(ie0_0_e_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_12_we),
		.wd(ie0_0_e_12_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[23]),
		.qs(ie0_0_e_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_13_we),
		.wd(ie0_0_e_13_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[24]),
		.qs(ie0_0_e_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_14_we),
		.wd(ie0_0_e_14_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[25]),
		.qs(ie0_0_e_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_15_we),
		.wd(ie0_0_e_15_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[26]),
		.qs(ie0_0_e_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_16_we),
		.wd(ie0_0_e_16_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[27]),
		.qs(ie0_0_e_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_17_we),
		.wd(ie0_0_e_17_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[28]),
		.qs(ie0_0_e_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_18_we),
		.wd(ie0_0_e_18_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[29]),
		.qs(ie0_0_e_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_19_we),
		.wd(ie0_0_e_19_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[30]),
		.qs(ie0_0_e_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_20_we),
		.wd(ie0_0_e_20_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[31]),
		.qs(ie0_0_e_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_21_we),
		.wd(ie0_0_e_21_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[32]),
		.qs(ie0_0_e_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_22_we),
		.wd(ie0_0_e_22_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[33]),
		.qs(ie0_0_e_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_23_we),
		.wd(ie0_0_e_23_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[34]),
		.qs(ie0_0_e_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_24_we),
		.wd(ie0_0_e_24_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[35]),
		.qs(ie0_0_e_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_25_we),
		.wd(ie0_0_e_25_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[36]),
		.qs(ie0_0_e_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_26_we),
		.wd(ie0_0_e_26_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[37]),
		.qs(ie0_0_e_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_27_we),
		.wd(ie0_0_e_27_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[38]),
		.qs(ie0_0_e_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_28_we),
		.wd(ie0_0_e_28_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[39]),
		.qs(ie0_0_e_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_29_we),
		.wd(ie0_0_e_29_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[40]),
		.qs(ie0_0_e_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_30_we),
		.wd(ie0_0_e_30_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[41]),
		.qs(ie0_0_e_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_0_e_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_0_e_31_we),
		.wd(ie0_0_e_31_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[42]),
		.qs(ie0_0_e_31_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_1_e_32(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_1_e_32_we),
		.wd(ie0_1_e_32_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[43]),
		.qs(ie0_1_e_32_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_1_e_33(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_1_e_33_we),
		.wd(ie0_1_e_33_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[44]),
		.qs(ie0_1_e_33_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_1_e_34(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_1_e_34_we),
		.wd(ie0_1_e_34_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[45]),
		.qs(ie0_1_e_34_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_1_e_35(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_1_e_35_we),
		.wd(ie0_1_e_35_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[46]),
		.qs(ie0_1_e_35_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_threshold0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(threshold0_we),
		.wd(threshold0_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[10-:2]),
		.qs(threshold0_qs)
	);
	prim_subreg_ext #(.DW(6)) u_cc0(
		.re(cc0_re),
		.we(cc0_we),
		.wd(cc0_wd),
		.d(hw2reg[5-:6]),
		.qre(reg2hw[1]),
		.qe(reg2hw[2]),
		.q(reg2hw[8-:6]),
		.qs(cc0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_msip0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(msip0_we),
		.wd(msip0_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[-0]),
		.qs(msip0_qs)
	);
	reg [44:0] addr_hit;
	localparam signed [31:0] rv_plic_reg_pkg_BlockAw = 10;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_CC0_OFFSET = 10'h0ac;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_IE0_0_OFFSET = 10'h0a0;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_IE0_1_OFFSET = 10'h0a4;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_IP_0_OFFSET = 10'h000;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_IP_1_OFFSET = 10'h004;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_LE_0_OFFSET = 10'h008;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_LE_1_OFFSET = 10'h00c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_MSIP0_OFFSET = 10'h0b0;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO0_OFFSET = 10'h010;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO10_OFFSET = 10'h038;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO11_OFFSET = 10'h03c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO12_OFFSET = 10'h040;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO13_OFFSET = 10'h044;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO14_OFFSET = 10'h048;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO15_OFFSET = 10'h04c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO16_OFFSET = 10'h050;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO17_OFFSET = 10'h054;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO18_OFFSET = 10'h058;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO19_OFFSET = 10'h05c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO1_OFFSET = 10'h014;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO20_OFFSET = 10'h060;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO21_OFFSET = 10'h064;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO22_OFFSET = 10'h068;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO23_OFFSET = 10'h06c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO24_OFFSET = 10'h070;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO25_OFFSET = 10'h074;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO26_OFFSET = 10'h078;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO27_OFFSET = 10'h07c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO28_OFFSET = 10'h080;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO29_OFFSET = 10'h084;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO2_OFFSET = 10'h018;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO30_OFFSET = 10'h088;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO31_OFFSET = 10'h08c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO32_OFFSET = 10'h090;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO33_OFFSET = 10'h094;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO34_OFFSET = 10'h098;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO35_OFFSET = 10'h09c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO3_OFFSET = 10'h01c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO4_OFFSET = 10'h020;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO5_OFFSET = 10'h024;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO6_OFFSET = 10'h028;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO7_OFFSET = 10'h02c;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO8_OFFSET = 10'h030;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_PRIO9_OFFSET = 10'h034;
	localparam [9:0] rv_plic_reg_pkg_RV_PLIC_THRESHOLD0_OFFSET = 10'h0a8;
	always @(*) begin
		addr_hit = {45 {1'sb0}};
		addr_hit[0] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IP_0_OFFSET;
		addr_hit[1] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IP_1_OFFSET;
		addr_hit[2] = reg_addr == rv_plic_reg_pkg_RV_PLIC_LE_0_OFFSET;
		addr_hit[3] = reg_addr == rv_plic_reg_pkg_RV_PLIC_LE_1_OFFSET;
		addr_hit[4] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO0_OFFSET;
		addr_hit[5] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO1_OFFSET;
		addr_hit[6] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO2_OFFSET;
		addr_hit[7] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO3_OFFSET;
		addr_hit[8] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO4_OFFSET;
		addr_hit[9] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO5_OFFSET;
		addr_hit[10] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO6_OFFSET;
		addr_hit[11] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO7_OFFSET;
		addr_hit[12] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO8_OFFSET;
		addr_hit[13] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO9_OFFSET;
		addr_hit[14] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO10_OFFSET;
		addr_hit[15] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO11_OFFSET;
		addr_hit[16] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO12_OFFSET;
		addr_hit[17] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO13_OFFSET;
		addr_hit[18] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO14_OFFSET;
		addr_hit[19] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO15_OFFSET;
		addr_hit[20] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO16_OFFSET;
		addr_hit[21] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO17_OFFSET;
		addr_hit[22] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO18_OFFSET;
		addr_hit[23] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO19_OFFSET;
		addr_hit[24] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO20_OFFSET;
		addr_hit[25] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO21_OFFSET;
		addr_hit[26] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO22_OFFSET;
		addr_hit[27] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO23_OFFSET;
		addr_hit[28] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO24_OFFSET;
		addr_hit[29] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO25_OFFSET;
		addr_hit[30] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO26_OFFSET;
		addr_hit[31] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO27_OFFSET;
		addr_hit[32] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO28_OFFSET;
		addr_hit[33] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO29_OFFSET;
		addr_hit[34] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO30_OFFSET;
		addr_hit[35] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO31_OFFSET;
		addr_hit[36] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO32_OFFSET;
		addr_hit[37] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO33_OFFSET;
		addr_hit[38] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO34_OFFSET;
		addr_hit[39] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO35_OFFSET;
		addr_hit[40] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IE0_0_OFFSET;
		addr_hit[41] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IE0_1_OFFSET;
		addr_hit[42] = reg_addr == rv_plic_reg_pkg_RV_PLIC_THRESHOLD0_OFFSET;
		addr_hit[43] = reg_addr == rv_plic_reg_pkg_RV_PLIC_CC0_OFFSET;
		addr_hit[44] = reg_addr == rv_plic_reg_pkg_RV_PLIC_MSIP0_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [179:0] rv_plic_reg_pkg_RV_PLIC_PERMIT = 180'b111111111111111100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000111111111000100010001;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[176+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[176+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[172+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[172+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[168+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[168+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[164+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[164+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[160+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[160+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[156+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[156+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[152+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[152+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[148+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[148+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[144+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[144+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[140+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[140+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[136+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[136+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[132+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[132+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[128+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[128+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[124+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[124+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[120+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[120+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[15] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[116+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[116+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[16] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[112+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[112+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[17] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[108+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[108+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[18] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[104+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[104+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[19] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[100+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[100+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[20] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[96+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[96+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[21] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[92+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[92+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[22] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[88+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[88+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[23] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[84+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[84+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[24] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[80+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[80+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[25] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[76+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[76+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[26] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[72+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[72+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[27] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[68+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[68+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[28] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[64+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[64+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[29] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[60+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[60+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[30] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[56+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[31] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[52+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[32] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[48+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[33] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[44+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[34] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[40+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[35] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[36+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[36] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[32+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[37] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[28+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[38] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[24+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[39] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[20+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[40] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[16+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[41] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[12+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[42] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[8+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[43] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[4+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[44] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[0+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign le_0_le_0_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_0_wd = reg_wdata[0];
	assign le_0_le_1_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_1_wd = reg_wdata[1];
	assign le_0_le_2_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_2_wd = reg_wdata[2];
	assign le_0_le_3_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_3_wd = reg_wdata[3];
	assign le_0_le_4_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_4_wd = reg_wdata[4];
	assign le_0_le_5_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_5_wd = reg_wdata[5];
	assign le_0_le_6_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_6_wd = reg_wdata[6];
	assign le_0_le_7_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_7_wd = reg_wdata[7];
	assign le_0_le_8_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_8_wd = reg_wdata[8];
	assign le_0_le_9_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_9_wd = reg_wdata[9];
	assign le_0_le_10_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_10_wd = reg_wdata[10];
	assign le_0_le_11_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_11_wd = reg_wdata[11];
	assign le_0_le_12_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_12_wd = reg_wdata[12];
	assign le_0_le_13_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_13_wd = reg_wdata[13];
	assign le_0_le_14_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_14_wd = reg_wdata[14];
	assign le_0_le_15_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_15_wd = reg_wdata[15];
	assign le_0_le_16_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_16_wd = reg_wdata[16];
	assign le_0_le_17_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_17_wd = reg_wdata[17];
	assign le_0_le_18_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_18_wd = reg_wdata[18];
	assign le_0_le_19_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_19_wd = reg_wdata[19];
	assign le_0_le_20_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_20_wd = reg_wdata[20];
	assign le_0_le_21_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_21_wd = reg_wdata[21];
	assign le_0_le_22_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_22_wd = reg_wdata[22];
	assign le_0_le_23_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_23_wd = reg_wdata[23];
	assign le_0_le_24_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_24_wd = reg_wdata[24];
	assign le_0_le_25_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_25_wd = reg_wdata[25];
	assign le_0_le_26_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_26_wd = reg_wdata[26];
	assign le_0_le_27_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_27_wd = reg_wdata[27];
	assign le_0_le_28_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_28_wd = reg_wdata[28];
	assign le_0_le_29_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_29_wd = reg_wdata[29];
	assign le_0_le_30_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_30_wd = reg_wdata[30];
	assign le_0_le_31_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign le_0_le_31_wd = reg_wdata[31];
	assign le_1_le_32_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign le_1_le_32_wd = reg_wdata[0];
	assign le_1_le_33_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign le_1_le_33_wd = reg_wdata[1];
	assign le_1_le_34_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign le_1_le_34_wd = reg_wdata[2];
	assign le_1_le_35_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign le_1_le_35_wd = reg_wdata[3];
	assign prio0_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign prio0_wd = reg_wdata[1:0];
	assign prio1_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign prio1_wd = reg_wdata[1:0];
	assign prio2_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign prio2_wd = reg_wdata[1:0];
	assign prio3_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign prio3_wd = reg_wdata[1:0];
	assign prio4_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign prio4_wd = reg_wdata[1:0];
	assign prio5_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign prio5_wd = reg_wdata[1:0];
	assign prio6_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign prio6_wd = reg_wdata[1:0];
	assign prio7_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign prio7_wd = reg_wdata[1:0];
	assign prio8_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign prio8_wd = reg_wdata[1:0];
	assign prio9_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign prio9_wd = reg_wdata[1:0];
	assign prio10_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign prio10_wd = reg_wdata[1:0];
	assign prio11_we = (addr_hit[15] & reg_we) & ~wr_err;
	assign prio11_wd = reg_wdata[1:0];
	assign prio12_we = (addr_hit[16] & reg_we) & ~wr_err;
	assign prio12_wd = reg_wdata[1:0];
	assign prio13_we = (addr_hit[17] & reg_we) & ~wr_err;
	assign prio13_wd = reg_wdata[1:0];
	assign prio14_we = (addr_hit[18] & reg_we) & ~wr_err;
	assign prio14_wd = reg_wdata[1:0];
	assign prio15_we = (addr_hit[19] & reg_we) & ~wr_err;
	assign prio15_wd = reg_wdata[1:0];
	assign prio16_we = (addr_hit[20] & reg_we) & ~wr_err;
	assign prio16_wd = reg_wdata[1:0];
	assign prio17_we = (addr_hit[21] & reg_we) & ~wr_err;
	assign prio17_wd = reg_wdata[1:0];
	assign prio18_we = (addr_hit[22] & reg_we) & ~wr_err;
	assign prio18_wd = reg_wdata[1:0];
	assign prio19_we = (addr_hit[23] & reg_we) & ~wr_err;
	assign prio19_wd = reg_wdata[1:0];
	assign prio20_we = (addr_hit[24] & reg_we) & ~wr_err;
	assign prio20_wd = reg_wdata[1:0];
	assign prio21_we = (addr_hit[25] & reg_we) & ~wr_err;
	assign prio21_wd = reg_wdata[1:0];
	assign prio22_we = (addr_hit[26] & reg_we) & ~wr_err;
	assign prio22_wd = reg_wdata[1:0];
	assign prio23_we = (addr_hit[27] & reg_we) & ~wr_err;
	assign prio23_wd = reg_wdata[1:0];
	assign prio24_we = (addr_hit[28] & reg_we) & ~wr_err;
	assign prio24_wd = reg_wdata[1:0];
	assign prio25_we = (addr_hit[29] & reg_we) & ~wr_err;
	assign prio25_wd = reg_wdata[1:0];
	assign prio26_we = (addr_hit[30] & reg_we) & ~wr_err;
	assign prio26_wd = reg_wdata[1:0];
	assign prio27_we = (addr_hit[31] & reg_we) & ~wr_err;
	assign prio27_wd = reg_wdata[1:0];
	assign prio28_we = (addr_hit[32] & reg_we) & ~wr_err;
	assign prio28_wd = reg_wdata[1:0];
	assign prio29_we = (addr_hit[33] & reg_we) & ~wr_err;
	assign prio29_wd = reg_wdata[1:0];
	assign prio30_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign prio30_wd = reg_wdata[1:0];
	assign prio31_we = (addr_hit[35] & reg_we) & ~wr_err;
	assign prio31_wd = reg_wdata[1:0];
	assign prio32_we = (addr_hit[36] & reg_we) & ~wr_err;
	assign prio32_wd = reg_wdata[1:0];
	assign prio33_we = (addr_hit[37] & reg_we) & ~wr_err;
	assign prio33_wd = reg_wdata[1:0];
	assign prio34_we = (addr_hit[38] & reg_we) & ~wr_err;
	assign prio34_wd = reg_wdata[1:0];
	assign prio35_we = (addr_hit[39] & reg_we) & ~wr_err;
	assign prio35_wd = reg_wdata[1:0];
	assign ie0_0_e_0_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_0_wd = reg_wdata[0];
	assign ie0_0_e_1_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_1_wd = reg_wdata[1];
	assign ie0_0_e_2_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_2_wd = reg_wdata[2];
	assign ie0_0_e_3_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_3_wd = reg_wdata[3];
	assign ie0_0_e_4_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_4_wd = reg_wdata[4];
	assign ie0_0_e_5_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_5_wd = reg_wdata[5];
	assign ie0_0_e_6_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_6_wd = reg_wdata[6];
	assign ie0_0_e_7_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_7_wd = reg_wdata[7];
	assign ie0_0_e_8_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_8_wd = reg_wdata[8];
	assign ie0_0_e_9_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_9_wd = reg_wdata[9];
	assign ie0_0_e_10_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_10_wd = reg_wdata[10];
	assign ie0_0_e_11_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_11_wd = reg_wdata[11];
	assign ie0_0_e_12_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_12_wd = reg_wdata[12];
	assign ie0_0_e_13_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_13_wd = reg_wdata[13];
	assign ie0_0_e_14_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_14_wd = reg_wdata[14];
	assign ie0_0_e_15_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_15_wd = reg_wdata[15];
	assign ie0_0_e_16_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_16_wd = reg_wdata[16];
	assign ie0_0_e_17_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_17_wd = reg_wdata[17];
	assign ie0_0_e_18_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_18_wd = reg_wdata[18];
	assign ie0_0_e_19_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_19_wd = reg_wdata[19];
	assign ie0_0_e_20_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_20_wd = reg_wdata[20];
	assign ie0_0_e_21_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_21_wd = reg_wdata[21];
	assign ie0_0_e_22_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_22_wd = reg_wdata[22];
	assign ie0_0_e_23_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_23_wd = reg_wdata[23];
	assign ie0_0_e_24_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_24_wd = reg_wdata[24];
	assign ie0_0_e_25_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_25_wd = reg_wdata[25];
	assign ie0_0_e_26_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_26_wd = reg_wdata[26];
	assign ie0_0_e_27_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_27_wd = reg_wdata[27];
	assign ie0_0_e_28_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_28_wd = reg_wdata[28];
	assign ie0_0_e_29_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_29_wd = reg_wdata[29];
	assign ie0_0_e_30_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_30_wd = reg_wdata[30];
	assign ie0_0_e_31_we = (addr_hit[40] & reg_we) & ~wr_err;
	assign ie0_0_e_31_wd = reg_wdata[31];
	assign ie0_1_e_32_we = (addr_hit[41] & reg_we) & ~wr_err;
	assign ie0_1_e_32_wd = reg_wdata[0];
	assign ie0_1_e_33_we = (addr_hit[41] & reg_we) & ~wr_err;
	assign ie0_1_e_33_wd = reg_wdata[1];
	assign ie0_1_e_34_we = (addr_hit[41] & reg_we) & ~wr_err;
	assign ie0_1_e_34_wd = reg_wdata[2];
	assign ie0_1_e_35_we = (addr_hit[41] & reg_we) & ~wr_err;
	assign ie0_1_e_35_wd = reg_wdata[3];
	assign threshold0_we = (addr_hit[42] & reg_we) & ~wr_err;
	assign threshold0_wd = reg_wdata[1:0];
	assign cc0_we = (addr_hit[43] & reg_we) & ~wr_err;
	assign cc0_wd = reg_wdata[7:0];
	assign cc0_re = addr_hit[43] && reg_re;
	assign msip0_we = (addr_hit[44] & reg_we) & ~wr_err;
	assign msip0_wd = reg_wdata[0];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: begin
				reg_rdata_next[0] = ip_0_p_0_qs;
				reg_rdata_next[1] = ip_0_p_1_qs;
				reg_rdata_next[2] = ip_0_p_2_qs;
				reg_rdata_next[3] = ip_0_p_3_qs;
				reg_rdata_next[4] = ip_0_p_4_qs;
				reg_rdata_next[5] = ip_0_p_5_qs;
				reg_rdata_next[6] = ip_0_p_6_qs;
				reg_rdata_next[7] = ip_0_p_7_qs;
				reg_rdata_next[8] = ip_0_p_8_qs;
				reg_rdata_next[9] = ip_0_p_9_qs;
				reg_rdata_next[10] = ip_0_p_10_qs;
				reg_rdata_next[11] = ip_0_p_11_qs;
				reg_rdata_next[12] = ip_0_p_12_qs;
				reg_rdata_next[13] = ip_0_p_13_qs;
				reg_rdata_next[14] = ip_0_p_14_qs;
				reg_rdata_next[15] = ip_0_p_15_qs;
				reg_rdata_next[16] = ip_0_p_16_qs;
				reg_rdata_next[17] = ip_0_p_17_qs;
				reg_rdata_next[18] = ip_0_p_18_qs;
				reg_rdata_next[19] = ip_0_p_19_qs;
				reg_rdata_next[20] = ip_0_p_20_qs;
				reg_rdata_next[21] = ip_0_p_21_qs;
				reg_rdata_next[22] = ip_0_p_22_qs;
				reg_rdata_next[23] = ip_0_p_23_qs;
				reg_rdata_next[24] = ip_0_p_24_qs;
				reg_rdata_next[25] = ip_0_p_25_qs;
				reg_rdata_next[26] = ip_0_p_26_qs;
				reg_rdata_next[27] = ip_0_p_27_qs;
				reg_rdata_next[28] = ip_0_p_28_qs;
				reg_rdata_next[29] = ip_0_p_29_qs;
				reg_rdata_next[30] = ip_0_p_30_qs;
				reg_rdata_next[31] = ip_0_p_31_qs;
			end
			addr_hit[1]: begin
				reg_rdata_next[0] = ip_1_p_32_qs;
				reg_rdata_next[1] = ip_1_p_33_qs;
				reg_rdata_next[2] = ip_1_p_34_qs;
				reg_rdata_next[3] = ip_1_p_35_qs;
			end
			addr_hit[2]: begin
				reg_rdata_next[0] = le_0_le_0_qs;
				reg_rdata_next[1] = le_0_le_1_qs;
				reg_rdata_next[2] = le_0_le_2_qs;
				reg_rdata_next[3] = le_0_le_3_qs;
				reg_rdata_next[4] = le_0_le_4_qs;
				reg_rdata_next[5] = le_0_le_5_qs;
				reg_rdata_next[6] = le_0_le_6_qs;
				reg_rdata_next[7] = le_0_le_7_qs;
				reg_rdata_next[8] = le_0_le_8_qs;
				reg_rdata_next[9] = le_0_le_9_qs;
				reg_rdata_next[10] = le_0_le_10_qs;
				reg_rdata_next[11] = le_0_le_11_qs;
				reg_rdata_next[12] = le_0_le_12_qs;
				reg_rdata_next[13] = le_0_le_13_qs;
				reg_rdata_next[14] = le_0_le_14_qs;
				reg_rdata_next[15] = le_0_le_15_qs;
				reg_rdata_next[16] = le_0_le_16_qs;
				reg_rdata_next[17] = le_0_le_17_qs;
				reg_rdata_next[18] = le_0_le_18_qs;
				reg_rdata_next[19] = le_0_le_19_qs;
				reg_rdata_next[20] = le_0_le_20_qs;
				reg_rdata_next[21] = le_0_le_21_qs;
				reg_rdata_next[22] = le_0_le_22_qs;
				reg_rdata_next[23] = le_0_le_23_qs;
				reg_rdata_next[24] = le_0_le_24_qs;
				reg_rdata_next[25] = le_0_le_25_qs;
				reg_rdata_next[26] = le_0_le_26_qs;
				reg_rdata_next[27] = le_0_le_27_qs;
				reg_rdata_next[28] = le_0_le_28_qs;
				reg_rdata_next[29] = le_0_le_29_qs;
				reg_rdata_next[30] = le_0_le_30_qs;
				reg_rdata_next[31] = le_0_le_31_qs;
			end
			addr_hit[3]: begin
				reg_rdata_next[0] = le_1_le_32_qs;
				reg_rdata_next[1] = le_1_le_33_qs;
				reg_rdata_next[2] = le_1_le_34_qs;
				reg_rdata_next[3] = le_1_le_35_qs;
			end
			addr_hit[4]: reg_rdata_next[1:0] = prio0_qs;
			addr_hit[5]: reg_rdata_next[1:0] = prio1_qs;
			addr_hit[6]: reg_rdata_next[1:0] = prio2_qs;
			addr_hit[7]: reg_rdata_next[1:0] = prio3_qs;
			addr_hit[8]: reg_rdata_next[1:0] = prio4_qs;
			addr_hit[9]: reg_rdata_next[1:0] = prio5_qs;
			addr_hit[10]: reg_rdata_next[1:0] = prio6_qs;
			addr_hit[11]: reg_rdata_next[1:0] = prio7_qs;
			addr_hit[12]: reg_rdata_next[1:0] = prio8_qs;
			addr_hit[13]: reg_rdata_next[1:0] = prio9_qs;
			addr_hit[14]: reg_rdata_next[1:0] = prio10_qs;
			addr_hit[15]: reg_rdata_next[1:0] = prio11_qs;
			addr_hit[16]: reg_rdata_next[1:0] = prio12_qs;
			addr_hit[17]: reg_rdata_next[1:0] = prio13_qs;
			addr_hit[18]: reg_rdata_next[1:0] = prio14_qs;
			addr_hit[19]: reg_rdata_next[1:0] = prio15_qs;
			addr_hit[20]: reg_rdata_next[1:0] = prio16_qs;
			addr_hit[21]: reg_rdata_next[1:0] = prio17_qs;
			addr_hit[22]: reg_rdata_next[1:0] = prio18_qs;
			addr_hit[23]: reg_rdata_next[1:0] = prio19_qs;
			addr_hit[24]: reg_rdata_next[1:0] = prio20_qs;
			addr_hit[25]: reg_rdata_next[1:0] = prio21_qs;
			addr_hit[26]: reg_rdata_next[1:0] = prio22_qs;
			addr_hit[27]: reg_rdata_next[1:0] = prio23_qs;
			addr_hit[28]: reg_rdata_next[1:0] = prio24_qs;
			addr_hit[29]: reg_rdata_next[1:0] = prio25_qs;
			addr_hit[30]: reg_rdata_next[1:0] = prio26_qs;
			addr_hit[31]: reg_rdata_next[1:0] = prio27_qs;
			addr_hit[32]: reg_rdata_next[1:0] = prio28_qs;
			addr_hit[33]: reg_rdata_next[1:0] = prio29_qs;
			addr_hit[34]: reg_rdata_next[1:0] = prio30_qs;
			addr_hit[35]: reg_rdata_next[1:0] = prio31_qs;
			addr_hit[36]: reg_rdata_next[1:0] = prio32_qs;
			addr_hit[37]: reg_rdata_next[1:0] = prio33_qs;
			addr_hit[38]: reg_rdata_next[1:0] = prio34_qs;
			addr_hit[39]: reg_rdata_next[1:0] = prio35_qs;
			addr_hit[40]: begin
				reg_rdata_next[0] = ie0_0_e_0_qs;
				reg_rdata_next[1] = ie0_0_e_1_qs;
				reg_rdata_next[2] = ie0_0_e_2_qs;
				reg_rdata_next[3] = ie0_0_e_3_qs;
				reg_rdata_next[4] = ie0_0_e_4_qs;
				reg_rdata_next[5] = ie0_0_e_5_qs;
				reg_rdata_next[6] = ie0_0_e_6_qs;
				reg_rdata_next[7] = ie0_0_e_7_qs;
				reg_rdata_next[8] = ie0_0_e_8_qs;
				reg_rdata_next[9] = ie0_0_e_9_qs;
				reg_rdata_next[10] = ie0_0_e_10_qs;
				reg_rdata_next[11] = ie0_0_e_11_qs;
				reg_rdata_next[12] = ie0_0_e_12_qs;
				reg_rdata_next[13] = ie0_0_e_13_qs;
				reg_rdata_next[14] = ie0_0_e_14_qs;
				reg_rdata_next[15] = ie0_0_e_15_qs;
				reg_rdata_next[16] = ie0_0_e_16_qs;
				reg_rdata_next[17] = ie0_0_e_17_qs;
				reg_rdata_next[18] = ie0_0_e_18_qs;
				reg_rdata_next[19] = ie0_0_e_19_qs;
				reg_rdata_next[20] = ie0_0_e_20_qs;
				reg_rdata_next[21] = ie0_0_e_21_qs;
				reg_rdata_next[22] = ie0_0_e_22_qs;
				reg_rdata_next[23] = ie0_0_e_23_qs;
				reg_rdata_next[24] = ie0_0_e_24_qs;
				reg_rdata_next[25] = ie0_0_e_25_qs;
				reg_rdata_next[26] = ie0_0_e_26_qs;
				reg_rdata_next[27] = ie0_0_e_27_qs;
				reg_rdata_next[28] = ie0_0_e_28_qs;
				reg_rdata_next[29] = ie0_0_e_29_qs;
				reg_rdata_next[30] = ie0_0_e_30_qs;
				reg_rdata_next[31] = ie0_0_e_31_qs;
			end
			addr_hit[41]: begin
				reg_rdata_next[0] = ie0_1_e_32_qs;
				reg_rdata_next[1] = ie0_1_e_33_qs;
				reg_rdata_next[2] = ie0_1_e_34_qs;
				reg_rdata_next[3] = ie0_1_e_35_qs;
			end
			addr_hit[42]: reg_rdata_next[1:0] = threshold0_qs;
			addr_hit[43]: reg_rdata_next[7:0] = cc0_qs;
			addr_hit[44]: reg_rdata_next[0] = msip0_qs;
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
module rv_plic (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_src_i,
	irq_o,
	msip_o
);
	localparam signed [31:0] rv_plic_reg_pkg_NumSrc = 36;
	localparam signed [31:0] SRCW = 6;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	input wire [35:0] intr_src_i;
	localparam signed [31:0] rv_plic_reg_pkg_NumTarget = 1;
	output wire [0:0] irq_o;
	output wire [0:0] msip_o;
	wire [154:0] reg2hw;
	wire [77:0] hw2reg;
	localparam signed [31:0] MAX_PRIO = 3;
	localparam signed [31:0] PRIOW = 2;
	wire [6:0] irq_id_o;
	wire [35:0] le;
	wire [35:0] ip;
	wire [35:0] ie [0:0];
	wire [0:0] claim_re;
	wire [5:0] claim_id [0:0];
	reg [35:0] claim;
	wire [0:0] complete_we;
	wire [5:0] complete_id [0:0];
	reg [35:0] complete;
	wire [6:0] cc_id;
	wire [71:0] prio;
	wire [1:0] threshold [0:0];
	assign cc_id = irq_id_o;
	always @(*) begin
		claim = {36 {1'sb0}};
		begin : sv2v_autoblock_137
			reg signed [31:0] i;
			for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1)
				if (claim_re[i])
					claim[claim_id[i]] = 1'b1;
		end
	end
	always @(*) begin
		complete = {36 {1'sb0}};
		begin : sv2v_autoblock_138
			reg signed [31:0] i;
			for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1)
				if (complete_we[i])
					complete[complete_id[i]] = 1'b1;
		end
	end
	assign prio[70+:PRIOW] = reg2hw[118-:2];
	assign prio[68+:PRIOW] = reg2hw[116-:2];
	assign prio[66+:PRIOW] = reg2hw[114-:2];
	assign prio[64+:PRIOW] = reg2hw[112-:2];
	assign prio[62+:PRIOW] = reg2hw[110-:2];
	assign prio[60+:PRIOW] = reg2hw[108-:2];
	assign prio[58+:PRIOW] = reg2hw[106-:2];
	assign prio[56+:PRIOW] = reg2hw[104-:2];
	assign prio[54+:PRIOW] = reg2hw[102-:2];
	assign prio[52+:PRIOW] = reg2hw[100-:2];
	assign prio[50+:PRIOW] = reg2hw[98-:2];
	assign prio[48+:PRIOW] = reg2hw[96-:2];
	assign prio[46+:PRIOW] = reg2hw[94-:2];
	assign prio[44+:PRIOW] = reg2hw[92-:2];
	assign prio[42+:PRIOW] = reg2hw[90-:2];
	assign prio[40+:PRIOW] = reg2hw[88-:2];
	assign prio[38+:PRIOW] = reg2hw[86-:2];
	assign prio[36+:PRIOW] = reg2hw[84-:2];
	assign prio[34+:PRIOW] = reg2hw[82-:2];
	assign prio[32+:PRIOW] = reg2hw[80-:2];
	assign prio[30+:PRIOW] = reg2hw[78-:2];
	assign prio[28+:PRIOW] = reg2hw[76-:2];
	assign prio[26+:PRIOW] = reg2hw[74-:2];
	assign prio[24+:PRIOW] = reg2hw[72-:2];
	assign prio[22+:PRIOW] = reg2hw[70-:2];
	assign prio[20+:PRIOW] = reg2hw[68-:2];
	assign prio[18+:PRIOW] = reg2hw[66-:2];
	assign prio[16+:PRIOW] = reg2hw[64-:2];
	assign prio[14+:PRIOW] = reg2hw[62-:2];
	assign prio[12+:PRIOW] = reg2hw[60-:2];
	assign prio[10+:PRIOW] = reg2hw[58-:2];
	assign prio[8+:PRIOW] = reg2hw[56-:2];
	assign prio[6+:PRIOW] = reg2hw[54-:2];
	assign prio[4+:PRIOW] = reg2hw[52-:2];
	assign prio[2+:PRIOW] = reg2hw[50-:2];
	assign prio[0+:PRIOW] = reg2hw[48-:2];
	generate
		genvar s;
		for (s = 0; s < 36; s = s + 1) begin : gen_ie0
			assign ie[0][s] = reg2hw[11 + s];
		end
	endgenerate
	assign threshold[0] = reg2hw[10-:2];
	assign claim_re[0] = reg2hw[1];
	assign claim_id[0] = irq_id_o[0+:7];
	assign complete_we[0] = reg2hw[2];
	assign complete_id[0] = reg2hw[8-:6];
	assign hw2reg[5-:6] = cc_id[0+:7];
	assign msip_o[0] = reg2hw[-0];
	generate
		for (s = 0; s < 36; s = s + 1) begin : gen_ip
			assign hw2reg[6 + (s * 2)] = 1'b1;
			assign hw2reg[6 + ((s * 2) + 1)] = ip[s];
		end
	endgenerate
	generate
		for (s = 0; s < 36; s = s + 1) begin : gen_le
			assign le[s] = reg2hw[119 + s];
		end
	endgenerate
	rv_plic_gateway #(.N_SOURCE(rv_plic_reg_pkg_NumSrc)) u_gateway(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.src_i(intr_src_i),
		.le_i(le),
		.claim_i(claim),
		.complete_i(complete),
		.ip_o(ip)
	);
	generate
		genvar i;
		for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1) begin : gen_target
			rv_plic_target #(
				.N_SOURCE(rv_plic_reg_pkg_NumSrc),
				.MAX_PRIO(MAX_PRIO)
			) u_target(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.ip_i(ip),
				.ie_i(ie[i]),
				.prio_i(prio),
				.threshold_i(threshold[i]),
				.irq_o(irq_o[i]),
				.irq_id_o(irq_id_o[i * 7+:7])
			);
		end
	endgenerate
	rv_plic_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
module rv_plic_target (
	clk_i,
	rst_ni,
	ip_i,
	ie_i,
	prio_i,
	threshold_i,
	irq_o,
	irq_id_o
);
	parameter signed [31:0] N_SOURCE = 32;
	parameter signed [31:0] MAX_PRIO = 7;
	localparam signed [31:0] SrcWidth = $clog2(N_SOURCE + 1);
	localparam signed [31:0] PrioWidth = $clog2(MAX_PRIO + 1);
	input wire clk_i;
	input wire rst_ni;
	input wire [N_SOURCE - 1:0] ip_i;
	input wire [N_SOURCE - 1:0] ie_i;
	input wire [(0 >= (N_SOURCE - 1) ? ((2 - N_SOURCE) * PrioWidth) + (((N_SOURCE - 1) * PrioWidth) - 1) : (N_SOURCE * PrioWidth) - 1):(0 >= (N_SOURCE - 1) ? (N_SOURCE - 1) * PrioWidth : 0)] prio_i;
	input wire [PrioWidth - 1:0] threshold_i;
	output wire irq_o;
	output wire [SrcWidth - 1:0] irq_id_o;
	localparam signed [31:0] NumLevels = $clog2(N_SOURCE);
	wire [(2 ** (NumLevels + 1)) - 2:0] is_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * SrcWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * SrcWidth) + ((((2 ** (NumLevels + 1)) - 2) * SrcWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * SrcWidth)] id_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * PrioWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * PrioWidth) + ((((2 ** (NumLevels + 1)) - 2) * PrioWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * PrioWidth)] max_tree;
	generate
		genvar level;
		for (level = 0; level < (NumLevels + 1); level = level + 1) begin : gen_tree
			localparam signed [31:0] Base0 = (2 ** level) - 1;
			localparam signed [31:0] Base1 = (2 ** (level + 1)) - 1;
			genvar offset;
			for (offset = 0; offset < (2 ** level); offset = offset + 1) begin : gen_level
				localparam signed [31:0] Pa = Base0 + offset;
				localparam signed [31:0] C0 = Base1 + (2 * offset);
				localparam signed [31:0] C1 = (Base1 + (2 * offset)) + 1;
				if (level == NumLevels) begin : gen_leafs
					if (offset < N_SOURCE) begin : gen_assign
						assign is_tree[Pa] = ip_i[offset] & ie_i[offset];
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = offset;
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = prio_i[(0 >= (N_SOURCE - 1) ? offset : (N_SOURCE - 1) - offset) * PrioWidth+:PrioWidth];
					end
					else begin : gen_tie_off
						assign is_tree[Pa] = 1'b0;
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = {SrcWidth {1'sb0}};
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = {PrioWidth {1'sb0}};
					end
				end
				else begin : gen_nodes
					wire sel;
					assign sel = (~is_tree[C0] & is_tree[C1]) | ((is_tree[C0] & is_tree[C1]) & (max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth] > max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]));
					assign is_tree[Pa] = (sel & is_tree[C1]) | (~sel & is_tree[C0]);
					assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = ({SrcWidth {sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * SrcWidth+:SrcWidth]) | ({SrcWidth {~sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * SrcWidth+:SrcWidth]);
					assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = ({PrioWidth {sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth]) | ({PrioWidth {~sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]);
				end
			end
		end
	endgenerate
	wire irq_d;
	reg irq_q;
	wire [SrcWidth - 1:0] irq_id_d;
	reg [SrcWidth - 1:0] irq_id_q;
	assign irq_d = (max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * PrioWidth+:PrioWidth] > threshold_i ? is_tree[0] : 1'b0);
	assign irq_id_d = (is_tree[0] ? id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * SrcWidth+:SrcWidth] : {SrcWidth {1'sb0}});
	always @(posedge clk_i or negedge rst_ni) begin : gen_regs
		if (!rst_ni) begin
			irq_q <= 1'b0;
			irq_id_q <= {SrcWidth {1'sb0}};
		end
		else begin
			irq_q <= irq_d;
			irq_id_q <= irq_id_d;
		end
	end
	assign irq_o = irq_q;
	assign irq_id_o = irq_id_q;
endmodule
module rv_timer_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire [154:0] reg2hw;
	input wire [67:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] AW = 9;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire reg_we;
	wire reg_re;
	wire [8:0] reg_addr;
	wire [31:0] reg_wdata;
	wire [3:0] reg_be;
	wire [31:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [31:0] reg_rdata_next;
	wire [85:0] tl_reg_h2d;
	wire [51:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire ctrl_qs;
	wire ctrl_wd;
	wire ctrl_we;
	wire [11:0] cfg0_prescale_qs;
	wire [11:0] cfg0_prescale_wd;
	wire cfg0_prescale_we;
	wire [7:0] cfg0_step_qs;
	wire [7:0] cfg0_step_wd;
	wire cfg0_step_we;
	wire [31:0] timer_v_lower0_qs;
	wire [31:0] timer_v_lower0_wd;
	wire timer_v_lower0_we;
	wire [31:0] timer_v_upper0_qs;
	wire [31:0] timer_v_upper0_wd;
	wire timer_v_upper0_we;
	wire [31:0] compare_lower0_0_qs;
	wire [31:0] compare_lower0_0_wd;
	wire compare_lower0_0_we;
	wire [31:0] compare_upper0_0_qs;
	wire [31:0] compare_upper0_0_wd;
	wire compare_upper0_0_we;
	wire intr_enable0_qs;
	wire intr_enable0_wd;
	wire intr_enable0_we;
	wire intr_state0_qs;
	wire intr_state0_wd;
	wire intr_state0_we;
	wire intr_test0_wd;
	wire intr_test0_we;
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_we),
		.wd(ctrl_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[154]),
		.qs(ctrl_qs)
	);
	prim_subreg #(
		.DW(12),
		.SWACCESS("RW"),
		.RESVAL(12'h000)
	) u_cfg0_prescale(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(cfg0_prescale_we),
		.wd(cfg0_prescale_wd),
		.de(1'b0),
		.d({12 {1'sb0}}),
		.qe(),
		.q(reg2hw[153-:12]),
		.qs(cfg0_prescale_qs)
	);
	prim_subreg #(
		.DW(8),
		.SWACCESS("RW"),
		.RESVAL(8'h01)
	) u_cfg0_step(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(cfg0_step_we),
		.wd(cfg0_step_wd),
		.de(1'b0),
		.d({8 {1'sb0}}),
		.qe(),
		.q(reg2hw[141-:8]),
		.qs(cfg0_step_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_timer_v_lower0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timer_v_lower0_we),
		.wd(timer_v_lower0_wd),
		.de(hw2reg[35]),
		.d(hw2reg[67-:32]),
		.qe(),
		.q(reg2hw[133-:32]),
		.qs(timer_v_lower0_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_timer_v_upper0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timer_v_upper0_we),
		.wd(timer_v_upper0_wd),
		.de(hw2reg[2]),
		.d(hw2reg[34-:32]),
		.qe(),
		.q(reg2hw[101-:32]),
		.qs(timer_v_upper0_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'hffffffff)
	) u_compare_lower0_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(compare_lower0_0_we),
		.wd(compare_lower0_0_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(reg2hw[37]),
		.q(reg2hw[69-:32]),
		.qs(compare_lower0_0_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'hffffffff)
	) u_compare_upper0_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(compare_upper0_0_we),
		.wd(compare_upper0_0_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(reg2hw[4]),
		.q(reg2hw[36-:32]),
		.qs(compare_upper0_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable0_we),
		.wd(intr_enable0_wd),
		.de(1'b0),
		.d(1'b0),
		.qe(),
		.q(reg2hw[3]),
		.qs(intr_enable0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state0_we),
		.wd(intr_state0_wd),
		.de(hw2reg[0]),
		.d(hw2reg[1]),
		.qe(),
		.q(reg2hw[2]),
		.qs(intr_state0_qs)
	);
	prim_subreg_ext #(.DW(1)) u_intr_test0(
		.re(1'b0),
		.we(intr_test0_we),
		.wd(intr_test0_wd),
		.d(1'b0),
		.qre(),
		.qe(reg2hw[0]),
		.q(reg2hw[1]),
		.qs()
	);
	reg [8:0] addr_hit;
	localparam signed [31:0] rv_timer_reg_pkg_BlockAw = 9;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_CFG0_OFFSET = 9'h100;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_COMPARE_LOWER0_0_OFFSET = 9'h10c;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_COMPARE_UPPER0_0_OFFSET = 9'h110;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_CTRL_OFFSET = 9'h000;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_INTR_ENABLE0_OFFSET = 9'h114;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_INTR_STATE0_OFFSET = 9'h118;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_INTR_TEST0_OFFSET = 9'h11c;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_TIMER_V_LOWER0_OFFSET = 9'h104;
	localparam [8:0] rv_timer_reg_pkg_RV_TIMER_TIMER_V_UPPER0_OFFSET = 9'h108;
	always @(*) begin
		addr_hit = {9 {1'sb0}};
		addr_hit[0] = reg_addr == rv_timer_reg_pkg_RV_TIMER_CTRL_OFFSET;
		addr_hit[1] = reg_addr == rv_timer_reg_pkg_RV_TIMER_CFG0_OFFSET;
		addr_hit[2] = reg_addr == rv_timer_reg_pkg_RV_TIMER_TIMER_V_LOWER0_OFFSET;
		addr_hit[3] = reg_addr == rv_timer_reg_pkg_RV_TIMER_TIMER_V_UPPER0_OFFSET;
		addr_hit[4] = reg_addr == rv_timer_reg_pkg_RV_TIMER_COMPARE_LOWER0_0_OFFSET;
		addr_hit[5] = reg_addr == rv_timer_reg_pkg_RV_TIMER_COMPARE_UPPER0_0_OFFSET;
		addr_hit[6] = reg_addr == rv_timer_reg_pkg_RV_TIMER_INTR_ENABLE0_OFFSET;
		addr_hit[7] = reg_addr == rv_timer_reg_pkg_RV_TIMER_INTR_STATE0_OFFSET;
		addr_hit[8] = reg_addr == rv_timer_reg_pkg_RV_TIMER_INTR_TEST0_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [35:0] rv_timer_reg_pkg_RV_TIMER_PERMIT = 36'b000101111111111111111111000100010001;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[32+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[28+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[24+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[20+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[16+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[12+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[8+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[4+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (rv_timer_reg_pkg_RV_TIMER_PERMIT[0+:4] != (rv_timer_reg_pkg_RV_TIMER_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign ctrl_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign ctrl_wd = reg_wdata[0];
	assign cfg0_prescale_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign cfg0_prescale_wd = reg_wdata[11:0];
	assign cfg0_step_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign cfg0_step_wd = reg_wdata[23:16];
	assign timer_v_lower0_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign timer_v_lower0_wd = reg_wdata[31:0];
	assign timer_v_upper0_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign timer_v_upper0_wd = reg_wdata[31:0];
	assign compare_lower0_0_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign compare_lower0_0_wd = reg_wdata[31:0];
	assign compare_upper0_0_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign compare_upper0_0_wd = reg_wdata[31:0];
	assign intr_enable0_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign intr_enable0_wd = reg_wdata[0];
	assign intr_state0_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign intr_state0_wd = reg_wdata[0];
	assign intr_test0_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign intr_test0_wd = reg_wdata[0];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: reg_rdata_next[0] = ctrl_qs;
			addr_hit[1]: begin
				reg_rdata_next[11:0] = cfg0_prescale_qs;
				reg_rdata_next[23:16] = cfg0_step_qs;
			end
			addr_hit[2]: reg_rdata_next[31:0] = timer_v_lower0_qs;
			addr_hit[3]: reg_rdata_next[31:0] = timer_v_upper0_qs;
			addr_hit[4]: reg_rdata_next[31:0] = compare_lower0_0_qs;
			addr_hit[5]: reg_rdata_next[31:0] = compare_upper0_0_qs;
			addr_hit[6]: reg_rdata_next[0] = intr_enable0_qs;
			addr_hit[7]: reg_rdata_next[0] = intr_state0_qs;
			addr_hit[8]: reg_rdata_next[0] = 1'b0;
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
module rv_timer (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_timer_expired_0_0_o
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire intr_timer_expired_0_0_o;
	localparam signed [31:0] N_HARTS = 1;
	localparam signed [31:0] N_TIMERS = 1;
	wire [154:0] reg2hw;
	wire [67:0] hw2reg;
	wire [0:0] active;
	wire [11:0] prescaler;
	wire [7:0] step;
	wire [0:0] tick;
	wire [63:0] mtime_d [0:0];
	wire [63:0] mtime [0:0];
	wire [63:0] mtimecmp;
	wire mtimecmp_update [0:0][0:0];
	wire [0:0] intr_timer_set;
	wire [0:0] intr_timer_en;
	wire [0:0] intr_timer_test_q;
	wire [0:0] intr_timer_test_qe;
	wire [0:0] intr_timer_state_q;
	wire [0:0] intr_timer_state_de;
	wire [0:0] intr_timer_state_d;
	wire [0:0] intr_out;
	assign active[0] = reg2hw[154];
	assign prescaler = {reg2hw[153-:12]};
	assign step = {reg2hw[141-:8]};
	assign hw2reg[2] = tick[0];
	assign hw2reg[35] = tick[0];
	assign hw2reg[34-:32] = mtime_d[0][63:32];
	assign hw2reg[67-:32] = mtime_d[0][31:0];
	assign mtime[0] = {reg2hw[101-:32], reg2hw[133-:32]};
	assign mtimecmp = {reg2hw[36-:32], reg2hw[69-:32]};
	assign mtimecmp_update[0][0] = reg2hw[4] | reg2hw[37];
	assign intr_timer_expired_0_0_o = intr_out[0];
	assign intr_timer_en = reg2hw[3];
	assign intr_timer_state_q = reg2hw[2];
	assign intr_timer_test_q = reg2hw[1];
	assign intr_timer_test_qe = reg2hw[0];
	assign hw2reg[0] = intr_timer_state_de | mtimecmp_update[0][0];
	assign hw2reg[1] = intr_timer_state_d & ~mtimecmp_update[0][0];
	generate
		genvar h;
		for (h = 0; h < N_HARTS; h = h + 1) begin : gen_harts
			prim_intr_hw #(.Width(N_TIMERS)) u_intr_hw(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.event_intr_i(intr_timer_set),
				.reg2hw_intr_enable_q_i(intr_timer_en[h * N_TIMERS+:N_TIMERS]),
				.reg2hw_intr_test_q_i(intr_timer_test_q[h * N_TIMERS+:N_TIMERS]),
				.reg2hw_intr_test_qe_i(intr_timer_test_qe[h]),
				.reg2hw_intr_state_q_i(intr_timer_state_q[h * N_TIMERS+:N_TIMERS]),
				.hw2reg_intr_state_de_o(intr_timer_state_de),
				.hw2reg_intr_state_d_o(intr_timer_state_d[h * N_TIMERS+:N_TIMERS]),
				.intr_o(intr_out[h * N_TIMERS+:N_TIMERS])
			);
			timer_core #(.N(N_TIMERS)) u_core(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.active(active[h]),
				.prescaler(prescaler[h * 12+:12]),
				.step(step[h * 8+:8]),
				.tick(tick[h]),
				.mtime_d(mtime_d[h]),
				.mtime(mtime[h]),
				.mtimecmp(mtimecmp[64 * h+:64]),
				.intr(intr_timer_set[h * N_TIMERS+:N_TIMERS])
			);
		end
	endgenerate
	rv_timer_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
module spi_clgen (
	clk_i,
	rst_ni,
	enable,
	go,
	last_clk,
	divider,
	clk_out,
	pos_edge,
	neg_edge
);
	input wire clk_i;
	input wire rst_ni;
	input wire enable;
	input wire go;
	input wire last_clk;
	input wire [15:0] divider;
	output reg clk_out;
	output reg pos_edge;
	output reg neg_edge;
	reg [15:0] cnt;
	wire cnt_zero;
	wire cnt_one;
	assign cnt_zero = cnt == {16 {1'b0}};
	assign cnt_one = cnt == {{15 {1'b0}}, 1'b1};
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			cnt <= {16 {1'b1}};
		else if (!enable || cnt_zero)
			cnt <= divider;
		else
			cnt <= cnt - {{15 {1'b0}}, 1'b1};
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			clk_out <= 1'b0;
		else
			clk_out <= ((enable && cnt_zero) && (!last_clk || clk_out) ? ~clk_out : clk_out);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			pos_edge <= 1'b0;
			neg_edge <= 1'b0;
		end
		else begin
			pos_edge <= (((enable && !clk_out) && cnt_one) || (!(|divider) && clk_out)) || ((!(|divider) && go) && !enable);
			neg_edge <= ((enable && clk_out) && cnt_one) || ((!(|divider) && !clk_out) && enable);
		end
endmodule
module spi_core (
	clk_i,
	rst_ni,
	addr_i,
	wdata_i,
	rdata_o,
	be_i,
	we_i,
	re_i,
	error_o,
	intr_rx_o,
	intr_tx_o,
	ss_o,
	sclk_o,
	sd_o,
	sd_oe,
	sd_i
);
	input wire clk_i;
	input wire rst_ni;
	input wire [7:0] addr_i;
	input wire [31:0] wdata_i;
	output reg [31:0] rdata_o;
	input wire [3:0] be_i;
	input wire we_i;
	input wire re_i;
	output reg error_o;
	output reg intr_rx_o;
	output reg intr_tx_o;
	output wire [3:0] ss_o;
	output wire sclk_o;
	output wire sd_o;
	output reg sd_oe;
	input wire sd_i;
	reg [15:0] divider;
	reg [15:0] ctrl;
	reg [3:0] ss;
	reg [31:0] wb_dat;
	wire [31:0] rx;
	wire rx_negedge;
	wire tx_negedge;
	wire [4:0] char_len;
	wire go;
	wire lsb;
	wire ie;
	wire ass;
	wire spi_divider_sel;
	wire spi_ctrl_sel;
	wire spi_tx_sel;
	wire spi_ss_sel;
	wire tip;
	wire pos_edge;
	wire neg_edge;
	wire last_bit;
	wire tx_en;
	wire rx_en;
	assign spi_divider_sel = (we_i & ~re_i) & (addr_i[6:2] == 5);
	assign spi_ctrl_sel = (we_i & ~re_i) & (addr_i[6:2] == 4);
	assign spi_tx_sel = ((we_i & ~re_i) & (addr_i[6:2] == 0)) & tx_en;
	assign spi_ss_sel = (we_i & ~re_i) & (addr_i[6:2] == 6);
	always @(addr_i or rx or ctrl or divider or ss)
		case (addr_i[6:2])
			8: wb_dat = rx[31:0];
			4: wb_dat = ctrl;
			5: wb_dat = divider;
			6: wb_dat = ss;
			default: wb_dat = 32'b00000000000000000000000000000000;
		endcase
	always @(posedge clk_i)
		if (~rst_ni)
			rdata_o <= 32'b00000000000000000000000000000000;
		else
			rdata_o <= wb_dat;
	wire [1:1] sv2v_tmp_46A40;
	assign sv2v_tmp_46A40 = 1'b0;
	always @(*) error_o = sv2v_tmp_46A40;
	always @(posedge clk_i)
		if (~rst_ni)
			intr_tx_o <= 1'b0;
		else if ((((ie && tip) && last_bit) && pos_edge) && tx_en)
			intr_tx_o <= 1'b1;
		else
			intr_tx_o <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			intr_rx_o <= 1'b0;
		else if ((((ie && tip) && last_bit) && pos_edge) && rx_en)
			intr_rx_o <= 1'b1;
		else
			intr_rx_o <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			divider <= {16 {1'b0}};
		else if ((spi_divider_sel && we_i) && !tip) begin
			if (be_i[0])
				divider[7:0] <= wdata_i[7:0];
			if (be_i[1])
				divider[15:8] <= wdata_i[15:8];
		end
	always @(posedge clk_i)
		if (~rst_ni)
			ctrl <= {16 {1'b0}};
		else if ((spi_ctrl_sel && we_i) && !tip) begin
			if (be_i[0])
				ctrl[7:0] <= wdata_i[7:0] | {7'b0000000, ctrl[0]};
			if (be_i[1])
				ctrl[15:8] <= wdata_i[15:8];
		end
		else if ((tip && last_bit) && pos_edge)
			ctrl[8] <= 1'b0;
	assign rx_negedge = ctrl[9];
	assign tx_negedge = ctrl[10];
	assign go = ctrl[8];
	assign char_len = ctrl[6:0];
	assign lsb = ctrl[11];
	assign ie = ctrl[12];
	assign ass = ctrl[13];
	assign rx_en = ctrl[15];
	assign tx_en = ctrl[14];
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			sd_oe <= 1'b0;
		else if (tx_en & !rx_en)
			sd_oe <= 1'b1;
		else
			sd_oe <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			ss <= {4 {1'b0}};
		else if ((spi_ss_sel && we_i) && !tip)
			if (be_i[0])
				ss <= wdata_i[3:0];
	assign ss_o = ~((ss & {4 {tip & ass}}) | (ss & {4 {!ass}}));
	spi_clgen clgen(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.go(go),
		.enable(tip),
		.last_clk(last_bit),
		.divider(divider),
		.clk_out(sclk_o),
		.pos_edge(pos_edge),
		.neg_edge(neg_edge)
	);
	spi_shift shift(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.len(char_len[4:0]),
		.latch(spi_tx_sel & we_i),
		.byte_sel(be_i),
		.lsb(lsb),
		.go(go),
		.pos_edge(pos_edge),
		.neg_edge(neg_edge),
		.rx_negedge(rx_negedge),
		.tx_negedge(tx_negedge),
		.tip(tip),
		.last(last_bit),
		.p_in(wdata_i),
		.p_out(rx),
		.s_clk(sclk_o),
		.s_in(sd_i),
		.s_out(sd_o),
		.rx_en(rx_en)
	);
endmodule
module spi_shift (
	clk_i,
	rst_ni,
	latch,
	byte_sel,
	len,
	lsb,
	go,
	pos_edge,
	neg_edge,
	rx_negedge,
	tx_negedge,
	tip,
	last,
	p_in,
	p_out,
	s_clk,
	s_in,
	s_out,
	rx_en
);
	input wire clk_i;
	input wire rst_ni;
	input wire latch;
	input wire [3:0] byte_sel;
	input wire [4:0] len;
	input wire lsb;
	input wire go;
	input wire pos_edge;
	input wire neg_edge;
	input wire rx_negedge;
	input wire tx_negedge;
	output reg tip;
	output wire last;
	input wire [31:0] p_in;
	output wire [31:0] p_out;
	input wire s_clk;
	input wire s_in;
	output reg s_out;
	input wire rx_en;
	reg [5:0] cnt;
	reg [31:0] data;
	reg [31:0] data_rx;
	wire [5:0] tx_bit_pos;
	wire [5:0] rx_bit_pos;
	wire rx_clk_i;
	wire tx_clk_i;
	assign p_out = data_rx;
	assign tx_bit_pos = (lsb ? {!(|len), len} - cnt : cnt - {{5 {1'b0}}, 1'b1});
	assign rx_bit_pos = (lsb ? {!(|len), len} - (rx_negedge ? cnt + {{5 {1'b0}}, 1'b1} : cnt) : (rx_negedge ? cnt : cnt - {{5 {1'b0}}, 1'b1}));
	assign last = !(|cnt);
	assign rx_clk_i = (rx_negedge ? neg_edge : pos_edge) && (!last || s_clk);
	assign tx_clk_i = (tx_negedge ? neg_edge : pos_edge) && !last;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			cnt <= {6 {1'b0}};
		else if (tip)
			cnt <= (pos_edge ? cnt - {{5 {1'b0}}, 1'b1} : cnt);
		else
			cnt <= (!(|len) ? {1'b1, {5 {1'b0}}} : {1'b0, len});
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			tip <= 1'b0;
		else if (go && ~tip)
			tip <= 1'b1;
		else if ((tip && last) && pos_edge)
			tip <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			s_out <= 1'b0;
		else
			s_out <= (tx_clk_i || !tip ? data[tx_bit_pos[4:0]] : s_out);
	always @(posedge clk_i)
		if (~rst_ni)
			data <= {32 {1'b0}};
		else if (latch && !tip) begin
			if (byte_sel[0])
				data[7:0] <= p_in[7:0];
			if (byte_sel[1])
				data[15:8] <= p_in[15:8];
			if (byte_sel[2])
				data[23:16] <= p_in[23:16];
			if (byte_sel[3])
				data[31:24] <= p_in[31:24];
		end
		else if (rx_en && tip)
			data_rx[rx_bit_pos[4:0]] <= (rx_clk_i ? s_in : data_rx[rx_bit_pos[4:0]]);
endmodule
module spi_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_rx_o,
	intr_tx_o,
	ss_o,
	sclk_o,
	sd_o,
	sd_oe,
	sd_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire intr_rx_o;
	output wire intr_tx_o;
	output wire [3:0] ss_o;
	output wire sclk_o;
	output wire sd_o;
	output wire sd_oe;
	input wire sd_i;
	localparam signed [31:0] AW = 8;
	localparam signed [31:0] DW = 32;
	wire re;
	wire we;
	wire [7:0] addr;
	wire [31:0] wdata;
	wire [3:0] be;
	wire [31:0] rdata;
	wire err;
	spi_core spi_host(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.addr_i(addr),
		.wdata_i(wdata),
		.rdata_o(rdata),
		.be_i(be),
		.we_i(we),
		.re_i(re),
		.error_o(err),
		.intr_rx_o(intr_rx_o),
		.intr_tx_o(intr_tx_o),
		.ss_o(ss_o),
		.sclk_o(sclk_o),
		.sd_o(sd_o),
		.sd_oe(sd_oe),
		.sd_i(sd_i)
	);
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.we_o(we),
		.re_o(re),
		.addr_o(addr),
		.wdata_o(wdata),
		.be_o(be),
		.rdata_i(rdata),
		.error_i(err)
	);
endmodule
module timer_core (
	clk_i,
	rst_ni,
	active,
	prescaler,
	step,
	tick,
	mtime_d,
	mtime,
	mtimecmp,
	intr
);
	parameter signed [31:0] N = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire active;
	input wire [11:0] prescaler;
	input wire [7:0] step;
	output wire tick;
	output wire [63:0] mtime_d;
	input wire [63:0] mtime;
	input wire [(0 >= (N - 1) ? ((2 - N) * 64) + (((N - 1) * 64) - 1) : (N * 64) - 1):(0 >= (N - 1) ? (N - 1) * 64 : 0)] mtimecmp;
	output wire [N - 1:0] intr;
	reg [11:0] tick_count;
	always @(posedge clk_i or negedge rst_ni) begin : generate_tick
		if (!rst_ni)
			tick_count <= 12'h000;
		else if (!active)
			tick_count <= 12'h000;
		else if (tick_count == prescaler)
			tick_count <= 12'h000;
		else
			tick_count <= tick_count + 1'b1;
	end
	assign tick = active & (tick_count >= prescaler);
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	assign mtime_d = mtime + sv2v_cast_64(step);
	generate
		genvar t;
		for (t = 0; t < N; t = t + 1) begin : gen_intr
			assign intr[t] = active & (mtime >= mtimecmp[(0 >= (N - 1) ? t : (N - 1) - t) * 64+:64]);
		end
	endgenerate
endmodule
module tlul_adapter_reg (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	re_o,
	we_o,
	addr_o,
	wdata_o,
	be_o,
	rdata_i,
	error_i
);
	parameter signed [31:0] RegAw = 8;
	parameter signed [31:0] RegDw = 32;
	localparam signed [31:0] RegBw = RegDw / 8;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire re_o;
	output wire we_o;
	output wire [RegAw - 1:0] addr_o;
	output wire [RegDw - 1:0] wdata_o;
	output wire [RegBw - 1:0] be_o;
	input wire [RegDw - 1:0] rdata_i;
	input wire error_i;
	localparam signed [31:0] IW = 8;
	localparam signed [31:0] SZW = 2;
	reg outstanding;
	wire a_ack;
	wire d_ack;
	reg [RegDw - 1:0] rdata;
	reg error;
	wire err_internal;
	reg addr_align_err;
	wire tl_err;
	reg [7:0] reqid;
	reg [1:0] reqsz;
	reg [2:0] rspop;
	wire rd_req;
	wire wr_req;
	assign a_ack = tl_i[85] & tl_o[0];
	assign d_ack = tl_o[51] & tl_i[0];
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	assign wr_req = a_ack & ((tl_i[84-:3] == tlul_pkg_PutFullData) | (tl_i[84-:3] == tlul_pkg_PutPartialData));
	localparam [2:0] tlul_pkg_Get = 3'h4;
	assign rd_req = a_ack & (tl_i[84-:3] == tlul_pkg_Get);
	assign we_o = wr_req & ~err_internal;
	assign re_o = rd_req & ~err_internal;
	assign addr_o = {tl_i[36 + RegAw:39], 2'b00};
	assign wdata_o = tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
	assign be_o = tl_i[36-:4];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			outstanding <= 1'b0;
		else if (a_ack)
			outstanding <= 1'b1;
		else if (d_ack)
			outstanding <= 1'b0;
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			reqid <= {8 {1'sb0}};
			reqsz <= {2 {1'sb0}};
			rspop <= tlul_pkg_AccessAck;
		end
		else if (a_ack) begin
			reqid <= tl_i[76-:8];
			reqsz <= tl_i[78-:2];
			rspop <= (rd_req ? tlul_pkg_AccessAckData : tlul_pkg_AccessAck);
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata <= {RegDw {1'sb0}};
			error <= 1'b0;
		end
		else if (a_ack) begin
			rdata <= (err_internal ? {RegDw {1'sb1}} : rdata_i);
			error <= error_i | err_internal;
		end
	function automatic [1:0] sv2v_cast_87F6B;
		input reg [1:0] inp;
		sv2v_cast_87F6B = inp;
	endfunction
	function automatic [7:0] sv2v_cast_89DD5;
		input reg [7:0] inp;
		sv2v_cast_89DD5 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_4D96F;
		input reg [0:0] inp;
		sv2v_cast_4D96F = inp;
	endfunction
	function automatic [31:0] sv2v_cast_F21A2;
		input reg [31:0] inp;
		sv2v_cast_F21A2 = inp;
	endfunction
	assign tl_o = {outstanding, rspop, 3'b000, sv2v_cast_87F6B(reqsz), sv2v_cast_89DD5(reqid), sv2v_cast_4D96F(1'sb0), sv2v_cast_F21A2(rdata), error, ~outstanding};
	assign err_internal = addr_align_err | tl_err;
	always @(*)
		if (wr_req)
			addr_align_err = |tl_i[38:37];
		else
			addr_align_err = 1'b0;
	tlul_err u_err(
		.tl_i(tl_i),
		.err_o(tl_err)
	);
endmodule
module tlul_err_resp (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_h_o;
	reg [2:0] err_opcode;
	reg [7:0] err_source;
	reg [1:0] err_size;
	reg err_req_pending;
	reg err_rsp_pending;
	localparam [2:0] tlul_pkg_Get = 3'h4;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			err_req_pending <= 1'b0;
			err_source <= {tlul_pkg_TL_AIW {1'b0}};
			err_opcode <= tlul_pkg_Get;
			err_size <= {2 {1'sb0}};
		end
		else if (tl_h_i[85] && tl_h_o[0]) begin
			err_req_pending <= 1'b1;
			err_source <= tl_h_i[76-:8];
			err_opcode <= tl_h_i[84-:3];
			err_size <= tl_h_i[78-:2];
		end
		else if (!err_rsp_pending)
			err_req_pending <= 1'b0;
	assign tl_h_o[0] = ~err_rsp_pending & ~(err_req_pending & ~tl_h_i[0]);
	assign tl_h_o[51] = err_req_pending | err_rsp_pending;
	assign tl_h_o[33-:tlul_pkg_TL_DW] = {32 {1'sb1}};
	assign tl_h_o[42-:8] = err_source;
	assign tl_h_o[34-:1] = 1'b0;
	assign tl_h_o[47-:3] = {3 {1'sb0}};
	assign tl_h_o[44-:2] = err_size;
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	assign tl_h_o[50-:3] = (err_opcode == tlul_pkg_Get ? tlul_pkg_AccessAckData : tlul_pkg_AccessAck);
	assign tl_h_o[1] = 1'b1;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			err_rsp_pending <= 1'b0;
		else if ((err_req_pending || err_rsp_pending) && !tl_h_i[0])
			err_rsp_pending <= 1'b1;
		else
			err_rsp_pending <= 1'b0;
endmodule
module tlul_err (
	tl_i,
	err_o
);
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	output wire err_o;
	localparam signed [31:0] IW = 8;
	localparam signed [31:0] SZW = 2;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] MW = 4;
	localparam signed [31:0] SubAW = 2;
	wire opcode_allowed;
	wire a_config_allowed;
	wire op_full;
	wire op_partial;
	wire op_get;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	assign op_full = tl_i[84-:3] == tlul_pkg_PutFullData;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	assign op_partial = tl_i[84-:3] == tlul_pkg_PutPartialData;
	localparam [2:0] tlul_pkg_Get = 3'h4;
	assign op_get = tl_i[84-:3] == tlul_pkg_Get;
	assign err_o = ~(opcode_allowed & a_config_allowed);
	assign opcode_allowed = ((tl_i[84-:3] == tlul_pkg_PutFullData) | (tl_i[84-:3] == tlul_pkg_PutPartialData)) | (tl_i[84-:3] == tlul_pkg_Get);
	reg addr_sz_chk;
	reg mask_chk;
	reg fulldata_chk;
	wire [3:0] mask;
	assign mask = 1 << tl_i[38:37];
	always @(*) begin
		addr_sz_chk = 1'b0;
		mask_chk = 1'b0;
		fulldata_chk = 1'b0;
		if (tl_i[85])
			case (tl_i[78-:2])
				'h0: begin
					addr_sz_chk = 1'b1;
					mask_chk = ~|(tl_i[36-:4] & ~mask);
					fulldata_chk = |(tl_i[36-:4] & mask);
				end
				'h1: begin
					addr_sz_chk = ~tl_i[37];
					mask_chk = (tl_i[38] ? ~|(tl_i[36-:4] & 4'b0011) : ~|(tl_i[36-:4] & 4'b1100));
					fulldata_chk = (tl_i[38] ? &tl_i[36:35] : &tl_i[34:33]);
				end
				'h2: begin
					addr_sz_chk = ~|tl_i[38:37];
					mask_chk = 1'b1;
					fulldata_chk = &tl_i[36:33];
				end
				default: begin
					addr_sz_chk = 1'b0;
					mask_chk = 1'b0;
					fulldata_chk = 1'b0;
				end
			endcase
		else begin
			addr_sz_chk = 1'b0;
			mask_chk = 1'b0;
			fulldata_chk = 1'b0;
		end
	end
	assign a_config_allowed = (addr_sz_chk & mask_chk) & ((op_get | op_partial) | fulldata_chk);
endmodule
module tlul_fifo_sync (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	spare_req_i,
	spare_req_o,
	spare_rsp_i,
	spare_rsp_o
);
	parameter [0:0] ReqPass = 1'b1;
	parameter [0:0] RspPass = 1'b1;
	parameter [31:0] ReqDepth = 0;
	parameter [31:0] RspDepth = 0;
	parameter [31:0] SpareReqW = 1;
	parameter [31:0] SpareRspW = 1;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_h_o;
	output wire [85:0] tl_d_o;
	input wire [51:0] tl_d_i;
	input [SpareReqW - 1:0] spare_req_i;
	output [SpareReqW - 1:0] spare_req_o;
	input [SpareRspW - 1:0] spare_rsp_i;
	output [SpareRspW - 1:0] spare_rsp_o;
	localparam [31:0] REQFIFO_WIDTH = 84 + SpareReqW;
	fifo_sync #(
		.Width(REQFIFO_WIDTH),
		.Pass(ReqPass),
		.Depth(ReqDepth)
	) reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_h_i[85]),
		.wready_o(tl_h_o[0]),
		.wdata_i({tl_h_i[84-:3], tl_h_i[81-:3], tl_h_i[78-:2], tl_h_i[76-:8], tl_h_i[68-:32], tl_h_i[36-:4], tl_h_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW], spare_req_i}),
		.depth_o(),
		.rvalid_o(tl_d_o[85]),
		.rready_i(tl_d_i[0]),
		.rdata_o({tl_d_o[84-:3], tl_d_o[81-:3], tl_d_o[78-:2], tl_d_o[76-:8], tl_d_o[68-:32], tl_d_o[36-:4], tl_d_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW], spare_req_o})
	);
	localparam [31:0] RSPFIFO_WIDTH = 50 + SpareRspW;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	fifo_sync #(
		.Width(RSPFIFO_WIDTH),
		.Pass(RspPass),
		.Depth(RspDepth)
	) rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_d_i[51]),
		.wready_o(tl_d_o[0]),
		.wdata_i({tl_d_i[50-:3], tl_d_i[47-:3], tl_d_i[44-:2], tl_d_i[42-:8], tl_d_i[34-:1], (tl_d_i[50-:3] == tlul_pkg_AccessAckData ? tl_d_i[33-:tlul_pkg_TL_DW] : {tlul_pkg_TL_DW {1'b0}}), tl_d_i[1], spare_rsp_i}),
		.depth_o(),
		.rvalid_o(tl_h_o[51]),
		.rready_i(tl_h_i[0]),
		.rdata_o({tl_h_o[50-:3], tl_h_o[47-:3], tl_h_o[44-:2], tl_h_o[42-:8], tl_h_o[34-:1], tl_h_o[33-:tlul_pkg_TL_DW], tl_h_o[1], spare_rsp_o})
	);
endmodule
module tlul_host_adapter (
	clk_i,
	rst_ni,
	req_i,
	gnt_o,
	addr_i,
	we_i,
	wdata_i,
	be_i,
	valid_o,
	rdata_o,
	err_o,
	tl_h_c_a,
	tl_h_c_d
);
	parameter [31:0] MAX_REQS = 1;
	input wire clk_i;
	input wire rst_ni;
	input req_i;
	output wire gnt_o;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	input wire [31:0] addr_i;
	input wire we_i;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	input wire [31:0] wdata_i;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	input wire [3:0] be_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire err_o;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	output wire [85:0] tl_h_c_a;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	input wire [51:0] tl_h_c_d;
	localparam signed [31:0] WordSize = 2;
	wire [7:0] tl_source;
	wire [3:0] tl_be;
	 function automatic [7:0] sv2v_cast_8;
                                input reg [7:0] inp;
                                sv2v_cast_8 = inp;
                        endfunction
	generate
		if (MAX_REQS == 1) begin
			assign tl_source = {8 {1'sb0}};
		end
		else begin
			localparam signed [31:0] ReqNumW = $clog2(MAX_REQS);
			reg [ReqNumW - 1:0] source_d;
			reg [ReqNumW - 1:0] source_q;
			always @(posedge clk_i)
				if (!rst_ni)
					source_q <= {ReqNumW {1'sb0}};
				else
					source_q <= source_d;
			always @(*) begin
				source_d = source_q;
				if (req_i && gnt_o)
					if (source_q == (MAX_REQS - 1))
						source_d = {ReqNumW {1'sb0}};
					else
						source_d = source_q + 1;
			end
			/*function automatic [7:0] sv2v_cast_8;
				input reg [7:0] inp;
				sv2v_cast_8 = inp;
			endfunction*/
			assign tl_source = sv2v_cast_8(source_q);
		end
	endgenerate
	assign tl_be = (~we_i ? {tlul_pkg_TL_DBW {1'b1}} : be_i);
	localparam [2:0] tlul_pkg_Get = 3'h4;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	function automatic signed [1:0] sv2v_cast_6CB2A_signed;
		input reg signed [1:0] inp;
		sv2v_cast_6CB2A_signed = inp;
	endfunction
	function automatic [1:0] sv2v_cast_C1DF5;
		input reg [1:0] inp;
		sv2v_cast_C1DF5 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_FABF2;
		input reg [31:0] inp;
		sv2v_cast_FABF2 = inp;
	endfunction
	assign tl_h_c_a = {req_i, (~we_i ? tlul_pkg_Get : (&be_i ? tlul_pkg_PutFullData : tlul_pkg_PutPartialData)), 3'h0, sv2v_cast_C1DF5(sv2v_cast_6CB2A_signed(WordSize)), tl_source, sv2v_cast_FABF2({addr_i[31:WordSize], {WordSize {1'b0}}}), tl_be, wdata_i, 1'b1};
	assign gnt_o = tl_h_c_d[0];
	assign err_o = tl_h_c_d[1];
	assign valid_o = tl_h_c_d[51];
	wire [31:0] rddata;
	assign rddata = tl_h_c_d[33-:tlul_pkg_TL_DW];
	assign rdata_o = rddata;
endmodule
module tlul_socket_1n (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	dev_select_i
);
	parameter [31:0] N = 4;
	parameter [0:0] HReqPass = 1'b1;
	parameter [0:0] HRspPass = 1'b1;
	parameter [N - 1:0] DReqPass = {N {1'b1}};
	parameter [N - 1:0] DRspPass = {N {1'b1}};
	parameter [3:0] HReqDepth = 4'h2;
	parameter [3:0] HRspDepth = 4'h2;
	parameter [(N * 4) - 1:0] DReqDepth = {N {4'h2}};
	parameter [(N * 4) - 1:0] DRspDepth = {N {4'h2}};
	localparam [31:0] NWD = $clog2(N + 1);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_h_o;
	output wire [(0 >= (N - 1) ? ((2 - N) * 86) + (((N - 1) * 86) - 1) : (N * 86) - 1):(0 >= (N - 1) ? (N - 1) * 86 : 0)] tl_d_o;
	input wire [(0 >= (N - 1) ? ((2 - N) * 52) + (((N - 1) * 52) - 1) : (N * 52) - 1):(0 >= (N - 1) ? (N - 1) * 52 : 0)] tl_d_i;
	input wire [NWD - 1:0] dev_select_i;
	wire [NWD - 1:0] dev_select_t;
	wire [85:0] tl_t_o;
	wire [51:0] tl_t_i;
	tlul_fifo_sync #(
		.ReqPass(HReqPass),
		.RspPass(HRspPass),
		.ReqDepth(HReqDepth),
		.RspDepth(HRspDepth),
		.SpareReqW(NWD)
	) fifo_h(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_h_i),
		.tl_h_o(tl_h_o),
		.tl_d_o(tl_t_o),
		.tl_d_i(tl_t_i),
		.spare_req_i(dev_select_i),
		.spare_req_o(dev_select_t),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	localparam signed [31:0] MaxOutstanding = 65536;
	localparam signed [31:0] OutstandingW = 17;
	reg [16:0] num_req_outstanding;
	reg [NWD - 1:0] dev_select_outstanding;
	wire hold_all_requests;
	wire accept_t_req;
	wire accept_t_rsp;
	assign accept_t_req = tl_t_o[85] & tl_t_i[0];
	assign accept_t_rsp = tl_t_i[51] & tl_t_o[0];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			num_req_outstanding <= {17 {1'sb0}};
			dev_select_outstanding <= {NWD {1'sb0}};
		end
		else if (accept_t_req) begin
			if (!accept_t_rsp)
				num_req_outstanding <= num_req_outstanding + 1'b1;
			dev_select_outstanding <= dev_select_t;
		end
		else if (accept_t_rsp)
			num_req_outstanding <= num_req_outstanding - 1'b1;
	assign hold_all_requests = (num_req_outstanding != {17 {1'sb0}}) & (dev_select_t != dev_select_outstanding);
	wire [85:0] tl_u_o [0:N];
	wire [51:0] tl_u_i [0:N];
	generate
		genvar i;
		for (i = 0; i < N; i = i + 1) begin : gen_u_o
			function automatic signed [NWD - 1:0] sv2v_cast_BB804_signed;
				input reg signed [NWD - 1:0] inp;
				sv2v_cast_BB804_signed = inp;
			endfunction
			assign tl_u_o[i][85] = (tl_t_o[85] & (dev_select_t == sv2v_cast_BB804_signed(i))) & ~hold_all_requests;
			assign tl_u_o[i][84-:3] = tl_t_o[84-:3];
			assign tl_u_o[i][81-:3] = tl_t_o[81-:3];
			assign tl_u_o[i][78-:2] = tl_t_o[78-:2];
			assign tl_u_o[i][76-:8] = tl_t_o[76-:8];
			assign tl_u_o[i][68-:32] = tl_t_o[68-:32];
			assign tl_u_o[i][36-:4] = tl_t_o[36-:4];
			assign tl_u_o[i][tlul_pkg_TL_DW-:tlul_pkg_TL_DW] = tl_t_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
		end
	endgenerate
	reg [51:0] tl_t_p;
	reg hfifo_reqready;
	function automatic signed [NWD - 1:0] sv2v_cast_BB804_signed;
		input reg signed [NWD - 1:0] inp;
		sv2v_cast_BB804_signed = inp;
	endfunction
	always @(*) begin
		hfifo_reqready = tl_u_i[N][0];
		begin : sv2v_autoblock_139
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_t == sv2v_cast_BB804_signed(idx))
					hfifo_reqready = tl_u_i[idx][0];
		end
		if (hold_all_requests)
			hfifo_reqready = 1'b0;
	end
	assign tl_t_i[0] = tl_t_o[85] & hfifo_reqready;
	always @(*) begin
		tl_t_p = tl_u_i[N];
		begin : sv2v_autoblock_140
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_outstanding == sv2v_cast_BB804_signed(idx))
					tl_t_p = tl_u_i[idx];
		end
	end
	assign tl_t_i[51] = tl_t_p[51];
	assign tl_t_i[50-:3] = tl_t_p[50-:3];
	assign tl_t_i[47-:3] = tl_t_p[47-:3];
	assign tl_t_i[44-:2] = tl_t_p[44-:2];
	assign tl_t_i[42-:8] = tl_t_p[42-:8];
	assign tl_t_i[34-:1] = tl_t_p[34-:1];
	assign tl_t_i[33-:tlul_pkg_TL_DW] = tl_t_p[33-:tlul_pkg_TL_DW];
	assign tl_t_i[1] = tl_t_p[1];
	generate
		for (i = 0; i < (N + 1); i = i + 1) begin : gen_u_o_d_ready
			assign tl_u_o[i][0] = tl_t_o[0];
		end
	endgenerate
	generate
		for (i = 0; i < N; i = i + 1) begin : gen_dfifo
			tlul_fifo_sync #(
				.ReqPass(DReqPass[i]),
				.RspPass(DRspPass[i]),
				.ReqDepth(DReqDepth[i * 4+:4]),
				.RspDepth(DRspDepth[i * 4+:4])
			) fifo_d(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(tl_u_o[i]),
				.tl_h_o(tl_u_i[i]),
				.tl_d_o(tl_d_o[(0 >= (N - 1) ? i : (N - 1) - i) * 86+:86]),
				.tl_d_i(tl_d_i[(0 >= (N - 1) ? i : (N - 1) - i) * 52+:52]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	function automatic [NWD - 1:0] sv2v_cast_BB804;
		input reg [NWD - 1:0] inp;
		sv2v_cast_BB804 = inp;
	endfunction
	assign tl_u_o[N][85] = (tl_t_o[85] & (dev_select_t == sv2v_cast_BB804(N))) & ~hold_all_requests;
	assign tl_u_o[N][84-:3] = tl_t_o[84-:3];
	assign tl_u_o[N][81-:3] = tl_t_o[81-:3];
	assign tl_u_o[N][78-:2] = tl_t_o[78-:2];
	assign tl_u_o[N][76-:8] = tl_t_o[76-:8];
	assign tl_u_o[N][68-:32] = tl_t_o[68-:32];
	assign tl_u_o[N][36-:4] = tl_t_o[36-:4];
	assign tl_u_o[N][tlul_pkg_TL_DW-:tlul_pkg_TL_DW] = tl_t_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
	tlul_err_resp err_resp(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_u_o[N]),
		.tl_h_o(tl_u_i[N])
	);
endmodule
module tlul_socket_m1 (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i
);
	parameter [31:0] M = 4;
	parameter [M - 1:0] HReqPass = {M {1'b1}};
	parameter [M - 1:0] HRspPass = {M {1'b1}};
	parameter [(M * 4) - 1:0] HReqDepth = {M {4'h2}};
	parameter [(M * 4) - 1:0] HRspDepth = {M {4'h2}};
	parameter [0:0] DReqPass = 1'b1;
	parameter [0:0] DRspPass = 1'b1;
	parameter [3:0] DReqDepth = 4'h2;
	parameter [3:0] DRspDepth = 4'h2;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [(0 >= (M - 1) ? ((2 - M) * 86) + (((M - 1) * 86) - 1) : (M * 86) - 1):(0 >= (M - 1) ? (M - 1) * 86 : 0)] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [(0 >= (M - 1) ? ((2 - M) * 52) + (((M - 1) * 52) - 1) : (M * 52) - 1):(0 >= (M - 1) ? (M - 1) * 52 : 0)] tl_h_o;
	output wire [85:0] tl_d_o;
	input wire [51:0] tl_d_i;
	localparam [31:0] IDW = tlul_pkg_TL_AIW;
	localparam [31:0] STIDW = $clog2(M);
	wire [(0 >= (M - 1) ? ((2 - M) * 86) + (((M - 1) * 86) - 1) : (M * 86) - 1):(0 >= (M - 1) ? (M - 1) * 86 : 0)] hreq_fifo_o;
	wire [51:0] hrsp_fifo_i [0:M - 1];
	wire [M - 1:0] hrequest;
	wire [M - 1:0] hgrant;
	wire [85:0] dreq_fifo_i;
	wire [51:0] drsp_fifo_o;
	wire arb_valid;
	wire arb_ready;
	wire [85:0] arb_data;
	generate
		genvar i;
		for (i = 0; i < M; i = i + 1) begin : gen_host_fifo
			wire [85:0] hreq_fifo_i;
			wire [STIDW - 1:0] reqid_sub;
			wire [7:0] shifted_id;
			assign reqid_sub = i;
			assign shifted_id = {tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 69+:IDW - STIDW], reqid_sub};
			wire [7:IDW - STIDW] unused_tl_h_source;
			assign unused_tl_h_source = tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 76-:STIDW];
			function automatic [2:0] sv2v_cast_3;
				input reg [2:0] inp;
				sv2v_cast_3 = inp;
			endfunction
			function automatic [1:0] sv2v_cast_539D2;
				input reg [1:0] inp;
				sv2v_cast_539D2 = inp;
			endfunction
			function automatic [7:0] sv2v_cast_F6BCE;
				input reg [7:0] inp;
				sv2v_cast_F6BCE = inp;
			endfunction
			function automatic [31:0] sv2v_cast_C6CCE;
				input reg [31:0] inp;
				sv2v_cast_C6CCE = inp;
			endfunction
			function automatic [3:0] sv2v_cast_45434;
				input reg [3:0] inp;
				sv2v_cast_45434 = inp;
			endfunction
			function automatic [31:0] sv2v_cast_486C6;
				input reg [31:0] inp;
				sv2v_cast_486C6 = inp;
			endfunction
			assign hreq_fifo_i = {tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 85], sv2v_cast_3(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 84-:3]), sv2v_cast_3(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 81-:3]), sv2v_cast_539D2(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 78-:2]), sv2v_cast_F6BCE(shifted_id), sv2v_cast_C6CCE(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 68-:32]), sv2v_cast_45434(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 36-:4]), sv2v_cast_486C6(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + tlul_pkg_TL_DW-:tlul_pkg_TL_DW]), tl_h_i[(0 >= (M - 1) ? i : (M - 1) - i) * 86]};
			tlul_fifo_sync #(
				.ReqPass(HReqPass[i]),
				.RspPass(HRspPass[i]),
				.ReqDepth(HReqDepth[i * 4+:4]),
				.RspDepth(HRspDepth[i * 4+:4]),
				.SpareReqW(1)
			) u_hostfifo(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(hreq_fifo_i),
				.tl_h_o(tl_h_o[(0 >= (M - 1) ? i : (M - 1) - i) * 52+:52]),
				.tl_d_o(hreq_fifo_o[(0 >= (M - 1) ? i : (M - 1) - i) * 86+:86]),
				.tl_d_i(hrsp_fifo_i[i]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	tlul_fifo_sync #(
		.ReqPass(DReqPass),
		.RspPass(DRspPass),
		.ReqDepth(DReqDepth),
		.RspDepth(DRspDepth),
		.SpareReqW(1)
	) u_devicefifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(dreq_fifo_i),
		.tl_h_o(drsp_fifo_o),
		.tl_d_o(tl_d_o),
		.tl_d_i(tl_d_i),
		.spare_req_i(1'b0),
		.spare_req_o(),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_arbreqgnt
			assign hrequest[i] = hreq_fifo_o[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 85];
		end
	endgenerate
	assign arb_ready = drsp_fifo_o[0];
	localparam tlul_pkg_ArbiterImpl = "PPC";
	generate
		if (tlul_pkg_ArbiterImpl == "PPC") begin : gen_arb_ppc
			prim_arbiter_ppc #(
				.N(M),
				.DW(86),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
		else if (tlul_pkg_ArbiterImpl == "BINTREE") begin : gen_tree_arb
			prim_arbiter_tree #(
				.N(M),
				.DW(86),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
	endgenerate
	wire [M - 1:0] hfifo_rspvalid;
	wire [M - 1:0] dfifo_rspready;
	wire [7:0] hfifo_rspid;
	wire dfifo_rspready_merged;
	assign dfifo_rspready_merged = |dfifo_rspready;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_539D2;
		input reg [1:0] inp;
		sv2v_cast_539D2 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_F6BCE;
		input reg [7:0] inp;
		sv2v_cast_F6BCE = inp;
	endfunction
	function automatic [31:0] sv2v_cast_C6CCE;
		input reg [31:0] inp;
		sv2v_cast_C6CCE = inp;
	endfunction
	function automatic [3:0] sv2v_cast_45434;
		input reg [3:0] inp;
		sv2v_cast_45434 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_486C6;
		input reg [31:0] inp;
		sv2v_cast_486C6 = inp;
	endfunction
	assign dreq_fifo_i = {arb_valid, sv2v_cast_3(arb_data[84-:3]), sv2v_cast_3(arb_data[81-:3]), sv2v_cast_539D2(arb_data[78-:2]), sv2v_cast_F6BCE(arb_data[76-:8]), sv2v_cast_C6CCE(arb_data[68-:32]), sv2v_cast_45434(arb_data[36-:4]), sv2v_cast_486C6(arb_data[tlul_pkg_TL_DW-:tlul_pkg_TL_DW]), dfifo_rspready_merged};
	assign hfifo_rspid = {{STIDW {1'b0}}, drsp_fifo_o[42:35 + STIDW]};
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_idrouting
			assign hfifo_rspvalid[i] = drsp_fifo_o[51] & (drsp_fifo_o[35+:STIDW] == i);
			assign dfifo_rspready[i] = (hreq_fifo_o[(0 >= (M - 1) ? i : (M - 1) - i) * 86] & (drsp_fifo_o[35+:STIDW] == i)) & drsp_fifo_o[51];
			function automatic [2:0] sv2v_cast_3;
				input reg [2:0] inp;
				sv2v_cast_3 = inp;
			endfunction
			function automatic [1:0] sv2v_cast_539D2;
				input reg [1:0] inp;
				sv2v_cast_539D2 = inp;
			endfunction
			function automatic [7:0] sv2v_cast_F6BCE;
				input reg [7:0] inp;
				sv2v_cast_F6BCE = inp;
			endfunction
			function automatic [0:0] sv2v_cast_D8FDD;
				input reg [0:0] inp;
				sv2v_cast_D8FDD = inp;
			endfunction
			function automatic [31:0] sv2v_cast_486C6;
				input reg [31:0] inp;
				sv2v_cast_486C6 = inp;
			endfunction
			assign hrsp_fifo_i[i] = {hfifo_rspvalid[i], sv2v_cast_3(drsp_fifo_o[50-:3]), sv2v_cast_3(drsp_fifo_o[47-:3]), sv2v_cast_539D2(drsp_fifo_o[44-:2]), sv2v_cast_F6BCE(hfifo_rspid), sv2v_cast_D8FDD(drsp_fifo_o[34-:1]), sv2v_cast_486C6(drsp_fifo_o[33-:tlul_pkg_TL_DW]), drsp_fifo_o[1], hgrant[i]};
		end
	endgenerate
endmodule
module tlul_sram_adapter (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	req_o,
	gnt_i,
	we_o,
	addr_o,
	wdata_o,
	wmask_o,
	rdata_i,
	rvalid_i,
	rerror_i
);
	parameter signed [31:0] SramAw = 12;
	parameter signed [31:0] SramDw = 32;
	parameter signed [31:0] Outstanding = 1;
	parameter [0:0] ByteAccess = 1;
	parameter [0:0] ErrOnWrite = 0;
	parameter [0:0] ErrOnRead = 0;
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire req_o;
	input wire gnt_i;
	output wire we_o;
	output wire [SramAw - 1:0] addr_o;
	output wire [SramDw - 1:0] wdata_o;
	output wire [SramDw - 1:0] wmask_o;
	input wire [SramDw - 1:0] rdata_i;
	input wire rvalid_i;
	input wire [1:0] rerror_i;
	localparam signed [31:0] SramByte = SramDw / 8;
	function automatic integer tlul_pkg_vbits;
		input integer value;
		tlul_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DataBitWidth = tlul_pkg_vbits(SramByte);
	localparam signed [31:0] WidthMult = SramDw / tlul_pkg_TL_DW;
	localparam signed [31:0] WoffsetWidth = (SramByte == tlul_pkg_TL_DBW ? 1 : DataBitWidth - tlul_pkg_vbits(tlul_pkg_TL_DBW));
	localparam signed [31:0] SramReqFifoWidth = tlul_pkg_TL_DBW + WoffsetWidth;
	localparam signed [31:0] ReqFifoWidth = 13;
	localparam signed [31:0] RspFifoWidth = (SramDw >= 0 ? SramDw + 1 : 1 - SramDw);
	wire reqfifo_wvalid;
	wire reqfifo_wready;
	wire reqfifo_rvalid;
	wire reqfifo_rready;
	wire [12:0] reqfifo_wdata;
	wire [12:0] reqfifo_rdata;
	wire sramreqfifo_wvalid;
	wire sramreqfifo_wready;
	wire sramreqfifo_rready;
	wire [(tlul_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_wdata;
	wire [(tlul_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_rdata;
	wire rspfifo_wvalid;
	wire rspfifo_wready;
	wire rspfifo_rvalid;
	wire rspfifo_rready;
	wire [SramDw:0] rspfifo_wdata;
	wire [SramDw:0] rspfifo_rdata;
	wire error_internal;
	wire wr_attr_error;
	wire wr_vld_error;
	wire rd_vld_error;
	wire tlul_error;
	wire a_ack;
	wire d_ack;
	wire sram_ack;
	assign a_ack = tl_i[85] & tl_o[0];
	assign d_ack = tl_o[51] & tl_i[0];
	assign sram_ack = req_o & gnt_i;
	reg d_valid;
	reg d_error;
	localparam [1:0] OpRead = 1;
	always @(*) begin
		d_valid = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[10])
				d_valid = 1'b1;
			else if (reqfifo_rdata[12-:2] == OpRead)
				d_valid = rspfifo_rvalid;
			else
				d_valid = 1'b1;
		end
		else
			d_valid = 1'b0;
	end
	always @(*) begin
		d_error = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[12-:2] == OpRead)
				d_error = rspfifo_rdata[0] | reqfifo_rdata[10];
			else
				d_error = reqfifo_rdata[10];
		end
		else
			d_error = 1'b0;
	end
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	function automatic [1:0] sv2v_cast_373C7;
		input reg [1:0] inp;
		sv2v_cast_373C7 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_E8620;
		input reg [7:0] inp;
		sv2v_cast_E8620 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_AF840;
		input reg [0:0] inp;
		sv2v_cast_AF840 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_D61D5;
		input reg [31:0] inp;
		sv2v_cast_D61D5 = inp;
	endfunction
	assign tl_o = {d_valid, (d_valid && (reqfifo_rdata[12-:2] != OpRead) ? tlul_pkg_AccessAck : tlul_pkg_AccessAckData), 3'b000, sv2v_cast_373C7((d_valid ? reqfifo_rdata[9-:2] : {2 {1'sb0}})), sv2v_cast_E8620((d_valid ? reqfifo_rdata[7-:8] : {8 {1'sb0}})), sv2v_cast_AF840(1'b0), sv2v_cast_D61D5(((d_valid && rspfifo_rvalid) && (reqfifo_rdata[12-:2] == OpRead) ? rspfifo_rdata[SramDw-:(SramDw >= 1 ? SramDw : 2 - SramDw)] : {(SramDw >= 1 ? SramDw : 2 - SramDw) {1'sb0}})), d_valid && d_error, ((gnt_i | error_internal) & reqfifo_wready) & sramreqfifo_wready};
	assign req_o = (tl_i[85] & reqfifo_wready) & ~error_internal;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	assign we_o = tl_i[85] & sv2v_cast_1(|{tl_i[84-:3] == tlul_pkg_PutFullData, tl_i[84-:3] == tlul_pkg_PutPartialData});
	assign addr_o = (tl_i[85] ? tl_i[37 + DataBitWidth+:SramAw] : {SramAw {1'sb0}});
	wire [WoffsetWidth - 1:0] woffset;
	generate
		if (tlul_pkg_TL_DW != SramDw) begin : gen_wordwidthadapt
			assign woffset = tl_i[36 + DataBitWidth:37 + tlul_pkg_vbits(tlul_pkg_TL_DBW)];
		end
		else begin : gen_no_wordwidthadapt
			assign woffset = {WoffsetWidth {1'sb0}};
		end
	endgenerate
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] wmask_int;
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] wdata_int;
	always @(*) begin
		wmask_int = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		wdata_int = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		if (tl_i[85]) begin : sv2v_autoblock_141
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				begin
					wmask_int[(woffset * 32) + (8 * i)+:8] = {8 {tl_i[33 + i]}};
					wdata_int[(woffset * 32) + (8 * i)+:8] = (tl_i[33 + i] && we_o ? tl_i[tlul_pkg_TL_DW - (31 - (8 * i))+:8] : {8 {1'sb0}});
				end
		end
	end
	assign wmask_o = wmask_int;
	assign wdata_o = wdata_int;
	assign wr_attr_error = ((tl_i[84-:3] == tlul_pkg_PutFullData) || (tl_i[84-:3] == tlul_pkg_PutPartialData) ? (ByteAccess == 0 ? (tl_i[36-:4] != {4 {1'sb1}}) || (tl_i[78-:2] != 2'h2) : 1'b0) : 1'b0);
	localparam [2:0] tlul_pkg_Get = 3'h4;
	generate
		if (ErrOnWrite == 1) begin : gen_no_writes
			assign wr_vld_error = tl_i[84-:3] != tlul_pkg_Get;
		end
		else begin : gen_writes_allowed
			assign wr_vld_error = 1'b0;
		end
	endgenerate
	generate
		if (ErrOnRead == 1) begin : gen_no_reads
			assign rd_vld_error = tl_i[84-:3] == tlul_pkg_Get;
		end
		else begin : gen_reads_allowed
			assign rd_vld_error = 1'b0;
		end
	endgenerate
	tlul_err u_err(
		.tl_i(tl_i),
		.err_o(tlul_error)
	);
	assign error_internal = ((wr_attr_error | wr_vld_error) | rd_vld_error) | tlul_error;
	assign reqfifo_wvalid = a_ack;
	localparam [1:0] OpWrite = 0;
	assign reqfifo_wdata = {(tl_i[84-:3] != tlul_pkg_Get ? OpWrite : OpRead), error_internal, sv2v_cast_373C7(tl_i[78-:2]), sv2v_cast_E8620(tl_i[76-:8])};
	assign reqfifo_rready = d_ack;
	function automatic [3:0] sv2v_cast_43A59;
		input reg [3:0] inp;
		sv2v_cast_43A59 = inp;
	endfunction
	assign sramreqfifo_wdata = {sv2v_cast_43A59(tl_i[36-:4]), woffset};
	assign sramreqfifo_wvalid = sram_ack & ~we_o;
	assign sramreqfifo_rready = rspfifo_wvalid;
	assign rspfifo_wvalid = rvalid_i & reqfifo_rvalid;
	wire [(WidthMult * tlul_pkg_TL_DW) - 1:0] rdata;
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] rmask;
	wire [31:0] rdata_tlword;
	always @(*) begin
		rmask = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		begin : sv2v_autoblock_142
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				rmask[(sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * 32) + (8 * i)+:8] = {8 {sramreqfifo_rdata[(tlul_pkg_TL_DBW + (WoffsetWidth - 1)) - (3 - i)]}};
		end
	end
	assign rdata = rdata_i & rmask;
	assign rdata_tlword = rdata[sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * tlul_pkg_TL_DW+:tlul_pkg_TL_DW];
	function automatic [SramDw - 1:0] sv2v_cast_1F998;
		input reg [SramDw - 1:0] inp;
		sv2v_cast_1F998 = inp;
	endfunction
	assign rspfifo_wdata = {sv2v_cast_1F998(rdata_tlword), rerror_i[1]};
	assign rspfifo_rready = ((reqfifo_rdata[12-:2] == OpRead) & ~reqfifo_rdata[10] ? reqfifo_rready : 1'b0);
	wire unused_rerror;
	assign unused_rerror = rerror_i[0];
	fifo_sync #(
		.Width(ReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(reqfifo_wvalid),
		.wready_o(reqfifo_wready),
		.wdata_i(reqfifo_wdata),
		.depth_o(),
		.rvalid_o(reqfifo_rvalid),
		.rready_i(reqfifo_rready),
		.rdata_o(reqfifo_rdata)
	);
	fifo_sync #(
		.Width(SramReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_sramreqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(sramreqfifo_wvalid),
		.wready_o(sramreqfifo_wready),
		.wdata_i(sramreqfifo_wdata),
		.depth_o(),
		.rvalid_o(),
		.rready_i(sramreqfifo_rready),
		.rdata_o(sramreqfifo_rdata)
	);
	fifo_sync #(
		.Width(RspFifoWidth),
		.Pass(1'b1),
		.Depth(Outstanding)
	) u_rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(rspfifo_wvalid),
		.wready_o(rspfifo_wready),
		.wdata_i(rspfifo_wdata),
		.depth_o(),
		.rvalid_o(rspfifo_rvalid),
		.rready_i(rspfifo_rready),
		.rdata_o(rspfifo_rdata)
	);
endmodule
module uart_core (
	clk_i,
	rst_ni,
	ren,
	we,
	wdata,
	rdata,
	addr,
	tx_o,
	rx_i,
	intr_tx
);
	input wire clk_i;
	input wire rst_ni;
	input wire ren;
	input wire we;
	input wire [31:0] wdata;
	output wire [31:0] rdata;
	input wire [3:0] addr;
	output wire tx_o;
	input wire rx_i;
	output wire intr_tx;
	localparam ADDR_CTRL = 0;
	localparam ADDR_TX = 4;
	localparam ADDR_RX = 8;
	reg [18:0] control;
	reg [7:0] tx;
	wire [7:0] rx;
	wire rx_status;
	always @(posedge clk_i)
		if (~rst_ni) begin
			control <= 0;
			tx <= 0;
		end
		else if (~ren & we)
			if (addr == ADDR_CTRL) begin
				control[1:0] <= wdata[1:0];
				control[18:3] <= wdata[18:3];
				control[2] <= rx_status;
			end
			else if (addr == ADDR_TX)
				tx <= wdata[7:0];
			else if (addr == ADDR_RX)
				;
			else begin
				control <= 0;
				tx <= 0;
			end
	uart_tx u_tx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tx_en(control[0]),
		.i_TX_Byte(tx),
		.CLKS_PER_BIT(control[18:3]),
		.o_TX_Serial(tx_o),
		.o_TX_Done(intr_tx)
	);
	uart_rx u_rx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.i_Rx_Serial(rx_i),
		.o_Rx_DV(rx_status),
		.rx_en(control[1]),
		.CLKS_PER_BIT(control[18:3]),
		.o_Rx_Byte(rx)
	);
	assign rdata = (addr == 0 ? control : (addr == 8 ? rx : 0));
endmodule
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx_prog (
   input  wire       clk_i,
   input  wire       rst_ni,
   input  wire       i_Rx_Serial,
   input  wire [15:0] CLKS_PER_BIT,
   output wire        o_Rx_DV,
   output wire  [7:0] o_Rx_Byte
   );
    
  parameter s_IDLE         = 3'b000;
  parameter s_RX_START_BIT = 3'b001;
  parameter s_RX_DATA_BITS = 3'b010;
  parameter s_RX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg           r_Rx_Data_R ;
  reg           r_Rx_Data   ;
   
  reg [15:0]     r_Clock_Count ;
  reg [2:0]     r_Bit_Index  ; //8 bits total
  reg [7:0]     r_Rx_Byte   ;
  reg           r_Rx_DV     ;
  reg [2:0]     r_SM_Main   ;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge clk_i)
    begin
    if (~rst_ni) begin
      r_Rx_Data_R <= 1'b1;
      r_Rx_Data   <= 1'b1;
    end else begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
  end
   
   
  // Purpose: Control RX state machine
  always @(posedge clk_i or negedge rst_ni)
    begin
      if (~rst_ni) begin
        r_SM_Main <= s_IDLE;
        r_Rx_DV       <= 1'b0;
        r_Clock_Count <= 16'b0;
        r_Bit_Index   <= 3'b0;
	r_Rx_Byte     <= 8'b0;
      end else begin       
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 16'b0;
            r_Bit_Index   <= 3'b0;
            r_Rx_Byte     <= 8'b0; 
            if (r_Rx_Data == 1'b0)          // Start bit detected
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == ((CLKS_PER_BIT-1)>>1))
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 16'b0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 16'b1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 16'b1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 16'b0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 3'b1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 3'b0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 16'b1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 16'b0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
      end
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule
module uart_rx (
	clk_i,
	rst_ni,
	rx_en,
	i_Rx_Serial,
	CLKS_PER_BIT,
	o_Rx_DV,
	o_Rx_Byte
);
	input wire clk_i;
	input wire rst_ni;
	input wire rx_en;
	input wire i_Rx_Serial;
	input wire [15:0] CLKS_PER_BIT;
	output wire o_Rx_DV;
	output wire [7:0] o_Rx_Byte;
	parameter s_IDLE = 3'b000;
	parameter s_RX_START_BIT = 3'b001;
	parameter s_RX_DATA_BITS = 3'b010;
	parameter s_RX_STOP_BIT = 3'b011;
	parameter s_CLEANUP = 3'b100;
	reg r_Rx_Data_R;
	reg r_Rx_Data;
	reg [15:0] r_Clock_Count;
	reg [2:0] r_Bit_Index;
	reg [7:0] r_Rx_Byte;
	reg r_Rx_DV;
	reg [2:0] r_SM_Main;
	always @(posedge clk_i)
		if (~rst_ni) begin
			r_Rx_Data_R <= 1'b1;
			r_Rx_Data <= 1'b1;
		end
		else begin
			r_Rx_Data_R <= i_Rx_Serial;
			r_Rx_Data <= r_Rx_Data_R;
		end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			r_SM_Main <= s_IDLE;
			r_Rx_DV <= 1'b0;
			r_Clock_Count <= 16'b0000000000000000;
			r_Bit_Index <= 3'b000;
		end
		else
			case (r_SM_Main)
				s_IDLE: begin
					r_Rx_DV <= 1'b0;
					r_Clock_Count <= 16'b0000000000000000;
					r_Bit_Index <= 3'b000;
					if (r_Rx_Data == 1'b0) begin
						if (rx_en == 1'b1)
							r_SM_Main <= s_RX_START_BIT;
						else
							r_SM_Main <= s_IDLE;
					end
					else
						r_SM_Main <= s_IDLE;
				end
				s_RX_START_BIT:
					if (r_Clock_Count == ((CLKS_PER_BIT - 1) >> 1)) begin
						if (r_Rx_Data == 1'b0) begin
							r_Clock_Count <= 16'b0000000000000000;
							r_SM_Main <= s_RX_DATA_BITS;
						end
						else
							r_SM_Main <= s_IDLE;
					end
					else begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= s_RX_START_BIT;
					end
				s_RX_DATA_BITS:
					if (r_Clock_Count < (CLKS_PER_BIT - 16'b0000000000000001)) begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= s_RX_DATA_BITS;
					end
					else begin
						r_Clock_Count <= 16'b0000000000000000;
						r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
						if (r_Bit_Index < 7) begin
							r_Bit_Index <= r_Bit_Index + 3'b001;
							r_SM_Main <= s_RX_DATA_BITS;
						end
						else begin
							r_Bit_Index <= 3'b000;
							r_SM_Main <= s_RX_STOP_BIT;
						end
					end
				s_RX_STOP_BIT:
					if (r_Clock_Count < (CLKS_PER_BIT - 16'b0000000000000001)) begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= s_RX_STOP_BIT;
					end
					else begin
						r_Rx_DV <= 1'b1;
						r_Clock_Count <= 16'b0000000000000000;
						r_SM_Main <= s_CLEANUP;
					end
				s_CLEANUP: begin
					r_SM_Main <= s_IDLE;
					r_Rx_DV <= 1'b0;
				end
				default: r_SM_Main <= s_IDLE;
			endcase
	assign o_Rx_DV = r_Rx_DV;
	assign o_Rx_Byte = r_Rx_Byte;
endmodule
module uart_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	tx_o,
	rx_i,
	intr_tx
);
	input wire clk_i;
	input wire rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire tx_o;
	input wire rx_i;
	output wire intr_tx;
	wire [31:0] wdata;
	wire [3:0] addr;
	wire we;
	wire re;
	wire [31:0] rdata;
	wire [3:0] be;
	uart_core u_uart_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ren(re),
		.we(we),
		.wdata(wdata),
		.rdata(rdata),
		.addr(addr),
		.tx_o(tx_o),
		.rx_i(rx_i),
		.intr_tx(intr_tx)
	);
	tlul_adapter_reg #(
		.RegAw(4),
		.RegDw(32)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.we_o(we),
		.re_o(re),
		.addr_o(addr),
		.wdata_o(wdata),
		.be_o(be),
		.rdata_i(rdata),
		.error_i(1'b0)
	);
endmodule
module uart_tx (
	clk_i,
	rst_ni,
	tx_en,
	i_TX_Byte,
	CLKS_PER_BIT,
	o_TX_Serial,
	o_TX_Done
);
	input wire clk_i;
	input wire rst_ni;
	input wire tx_en;
	input wire [7:0] i_TX_Byte;
	input wire [15:0] CLKS_PER_BIT;
	output reg o_TX_Serial;
	output wire o_TX_Done;
	localparam IDLE = 3'b000;
	localparam TX_START_BIT = 3'b001;
	localparam TX_DATA_BITS = 3'b010;
	localparam TX_STOP_BIT = 3'b011;
	localparam CLEANUP = 3'b100;
	reg [2:0] r_SM_Main;
	reg [15:0] r_Clock_Count;
	reg [2:0] r_Bit_Index;
	reg [7:0] r_TX_Data;
	reg r_TX_Done;
	always @(posedge clk_i)
		if (~rst_ni) begin
			r_SM_Main <= 3'b000;
			r_Clock_Count <= 16'b0000000000000000;
			r_Bit_Index <= 3'b000;
			r_TX_Data <= 8'b00000000;
			r_TX_Done <= 1'b0;
		end
		else
			case (r_SM_Main)
				IDLE: begin
					o_TX_Serial <= 1'b1;
					r_TX_Done <= 1'b0;
					r_Clock_Count <= 16'b0000000000000000;
					r_Bit_Index <= 3'b000;
					if (tx_en == 1'b1) begin
						r_TX_Data <= i_TX_Byte;
						r_SM_Main <= TX_START_BIT;
					end
					else
						r_SM_Main <= IDLE;
				end
				TX_START_BIT: begin
					o_TX_Serial <= 1'b0;
					if (r_Clock_Count < (CLKS_PER_BIT - 1)) begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= TX_START_BIT;
					end
					else begin
						r_Clock_Count <= 16'b0000000000000000;
						r_SM_Main <= TX_DATA_BITS;
					end
				end
				TX_DATA_BITS: begin
					o_TX_Serial <= r_TX_Data[r_Bit_Index];
					if (r_Clock_Count < (CLKS_PER_BIT - 16'b0000000000000001)) begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= TX_DATA_BITS;
					end
					else begin
						r_Clock_Count <= 3'b000;
						if (r_Bit_Index < 7) begin
							r_Bit_Index <= r_Bit_Index + 3'b001;
							r_SM_Main <= TX_DATA_BITS;
						end
						else begin
							r_Bit_Index <= 3'b000;
							r_SM_Main <= TX_STOP_BIT;
						end
					end
				end
				TX_STOP_BIT: begin
					o_TX_Serial <= 1'b1;
					if (r_Clock_Count < (CLKS_PER_BIT - 16'b0000000000000001)) begin
						r_Clock_Count <= r_Clock_Count + 16'b0000000000000001;
						r_SM_Main <= TX_STOP_BIT;
					end
					else begin
						r_TX_Done <= 1'b1;
						r_Clock_Count <= 16'b0000000000000000;
						r_SM_Main <= CLEANUP;
					end
				end
				CLEANUP: begin
					r_TX_Done <= 1'b1;
					r_SM_Main <= IDLE;
				end
				default: r_SM_Main <= IDLE;
			endcase
	assign o_TX_Done = r_TX_Done;
endmodule

(* blackbox *)
module sky130_sram_4kbyte_1rw1r_32x1024_8 (clk0, csb0, web0, wmask0, addr0, din0, dout0, clk1, csb1, addr1, dout1);
        parameter NUM_WMASKS = 4;
        parameter DATA_WIDTH = 32;
        parameter ADDR_WIDTH = 10;
        parameter RAM_DEPTH = 1 << ADDR_WIDTH;
        parameter DELAY = 3;
        parameter VERBOSE = 1;
        parameter T_HOLD = 1;
			`ifdef USE_POWER_PINS
  	  	inout vccd1;	
				inout vssd1;	
  		`endif
        input clk0;
        input csb0;
        input web0;
        input [NUM_WMASKS - 1:0] wmask0;
        input [ADDR_WIDTH - 1:0] addr0;
        input [DATA_WIDTH - 1:0] din0;
        output [DATA_WIDTH - 1:0] dout0;
        input clk1;
        input csb1;
        input [ADDR_WIDTH - 1:0] addr1;
        output [DATA_WIDTH - 1:0] dout1;
endmodule
