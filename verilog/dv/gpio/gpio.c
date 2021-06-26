/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"

// --------------------------------------------------------

void main()
{   
    reg_spimaster_config = 0xa002;

    reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
    
    reg_la0_oenb = 0x00000000;
    reg_la0_data = 0x0000015C;
    reg_mprj_datah = 0x20;
}

