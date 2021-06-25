# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag 20th_june_fully_synthesized -overwrite
set save_path $script_dir/../..	

run_yosys
run_sta
init_floorplan
place_io_ol
tap_decap_or
run_power_grid_generation
set ::env(YOSYS_REWRITE_VERILOG) 1
global_placement_or
detailed_placement_or
run_cts
run_routing
write_powered_verilog -power vccd1 -ground vssd1
set_netlist $::env(lvs_result_file_tag).powered.v
run_magic
run_magic_drc
puts $::env(CURRENT_NETLIST)
run_magic_spice_export

save_views 	-lef_path $::env(magic_result_file_tag).lef \
		-def_path $::env(tritonRoute_result_file_tag).def \
		-gds_path $::env(magic_result_file_tag).gds \
		-mag_path $::env(magic_result_file_tag).mag \
		-maglef_path $::env(magic_result_file_tag).lef.mag \
		-spice_path $::env(magic_result_file_tag).spice \
		-verilog_path $::env(CURRENT_NETLIST)\
	        -save_path $save_path \
                -tag $::env(RUN_TAG)	
	
run_lvs
run_antenna_check
calc_total_runtime
generate_final_summary_report
puts_success "Flow Completed Without Fatal Errors."


