create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from * -to [get_ports UART_TX]
set_false_path -from [get_ports UART_RX] -to [all_clocks]

set_false_path -from [get_ports RSTN] -to [all_clocks]