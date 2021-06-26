// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype wire

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "tbprog.v"

module gpio_tb;
    // Signals declaration
    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;
    reg power3, power4;
    reg prog;

    wire HIGH;
    wire LOW;
    wire TRI;
    assign HIGH = 1'b1;
    assign LOW = 1'b0;
    assign TRI = 1'bz;

    wire gpio;
    wire [37:0] mprj_io;
    wire r_Rx_Serial;
    wire mprj_ready;
    
	

    // Signals Assignment
    //assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;
    assign mprj_io[5] = r_Rx_Serial;
    assign mprj_io[7] = prog;
    assign mprj_ready = mprj_io[37];

    always #12.5 clock <= (clock === 1'b0);

    initial begin
        clock = 0;
    end

    initial begin
        $dumpfile("gpio.vcd");
        $dumpvars(0, gpio_tb);

        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (150) begin
            repeat (1000) @(posedge clock);
        end
        $display("%c[1;31m",27);
        $display ("Monitor: Timeout, Test Project IO Stimulus (RTL) Failed");
        $display("%c[0m",27);
        //$finish;
    end

    initial begin
        prog <= 1'b0;
        wait(mprj_ready == 1'b1);
        prog <= 1'b1;
        #100;
        prog <= 1'b0;
        $display("Monitor: gpio test Passed");
        //#10000;
        //$finish;
    end

   // Reset Operation
    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;       // Force CSB high
        #2000;
        RSTB <= 1'b1;       // Release reset
        #170000;
        CSB = 1'b0;         // CSB can be released
    end

    initial begin		// Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        #200;
        power1 <= 1'b1;
        #200;
        power2 <= 1'b1;
    end

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;


    wire VDD3V3 = power1;
    wire VDD1V8 = power2;
    wire VSS = 1'b0;

    caravel uut (
        .vddio	  (VDD3V3),
        .vssio	  (VSS),
        .vdda	  (VDD3V3),
        .vssa	  (VSS),
        .vccd	  (VDD1V8),
        .vssd	  (VSS),
        .vdda1    (VDD3V3),
        .vdda2    (VDD3V3),
        .vssa1	  (VSS),
        .vssa2	  (VSS),
        .vccd1	  (VDD1V8),
        .vccd2	  (VDD1V8),
        .vssd1	  (VSS),
        .vssd2	  (VSS),
        .clock	  (clock),
        .gpio     (gpio),
        .mprj_io  (mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb	  (RSTB)
    );


    spiflash #(
        .FILENAME("gpio.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),         // not used
        .io3()          // not used
    );

    tbprog #(
		.FILENAME("../hex/gpio.hex")
	) prog_uut (
		.mprj_ready (mprj_ready),
		.r_Rx_Serial (r_Rx_Serial)
	);


endmodule
`default_nettype wire
