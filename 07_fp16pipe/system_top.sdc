create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from [get_ports RSTN] -to [all_clocks]
set_false_path -from [get_ports {i_a[*] i_b[*]}] -to [all_clocks]
set_false_path -from [all_clocks] -to [get_ports {o_res[*]}]