// MIT License
//
// Copyright (c) 2022 by Lloyd Gomez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// JTAG CSR Demonstration Example
//
// Supported platforms:
// - Avnet MicroZed SOM 7Z020-G REV-F01 and FMC Carrier Card AES-MBCC-FMC-G
//   (the Carrier Card is required for the PMOD and LEDs)
// - Terasic DE10-Nano
module top (
  // The following AUTOs must be empty!
  /*AUTOINPUT*/
  /*AUTOOUTPUT*/
  /*AUTOINOUT*/

  input                 REFCLK,
  input                 SRST_N,
  input                 TRST_N,
  input                 TMS,
  input                 TCK,
  input                 TDI,
  output                TDO,
  output                LED0,
  output                LED1,
  output                LED2,
  output                LED3
);

  /*AUTOLOGIC*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [2:0]           csr_addr;               // From csr_u0 of csr.v
  logic [31:0]          csr_data;               // From csr_u0 of csr.v
  logic [2:0]           dr_csr_addr;            // From jtag_top_u0 of jtag_top.v
  logic                 dr_csr_addr_valid;      // From jtag_top_u0 of jtag_top.v
  logic [31:0]          dr_csr_data;            // From jtag_top_u0 of jtag_top.v
  logic                 dr_csr_data_valid;      // From jtag_top_u0 of jtag_top.v
  logic [3:0]           led;                    // From csr_u0 of csr.v
  logic                 srst_n;                 // From top_pads_u0 of top_pads.v
  logic                 sys_clk;                // From clkrst_u0 of clkrst.v
  logic                 sys_rst_n;              // From clkrst_u0 of clkrst.v
  logic                 tck;                    // From top_pads_u0 of top_pads.v
  logic                 tdi;                    // From top_pads_u0 of top_pads.v
  logic                 tdo;                    // From jtag_top_u0 of jtag_top.v
  logic                 tdo_oe;                 // From jtag_top_u0 of jtag_top.v
  logic                 tms;                    // From top_pads_u0 of top_pads.v
  logic                 trst_n;                 // From top_pads_u0 of top_pads.v
  // End of automatics

  top_pads top_pads_u0
    (/*AUTOINST*/
     // Outputs
     .TDO                               (TDO),
     .LED0                              (LED0),
     .LED1                              (LED1),
     .LED2                              (LED2),
     .LED3                              (LED3),
     .srst_n                            (srst_n),
     .trst_n                            (trst_n),
     .tms                               (tms),
     .tck                               (tck),
     .tdi                               (tdi),
     // Inputs
     .SRST_N                            (SRST_N),
     .TRST_N                            (TRST_N),
     .TMS                               (TMS),
     .TCK                               (TCK),
     .TDI                               (TDI),
     .tdo_oe                            (tdo_oe),
     .tdo                               (tdo),
     .led                               (led[3:0]));

  clkrst clkrst_u0
    (/*AUTOINST*/
     // Outputs
     .sys_clk                           (sys_clk),
     .sys_rst_n                         (sys_rst_n),
     // Inputs
     .REFCLK                            (REFCLK),
     .srst_n                            (srst_n));

  /*
  jtag_top AUTO_TEMPLATER
    (.dbg_fsm                           (),
    );
  */
  jtag_top jtag_top_u0
    (// TODO: add a JTAG instruction to read dbg_fsm.
     // verilator lint_off PINCONNECTEMPTY
     .dbg_fsm                           (),
     // verilator lint_on PINCONNECTEMPTY
     /*AUTOINST*/
     // Outputs
     .tdo_oe                            (tdo_oe),
     .tdo                               (tdo),
     .dr_csr_addr                       (dr_csr_addr[2:0]),
     .dr_csr_addr_valid                 (dr_csr_addr_valid),
     .dr_csr_data                       (dr_csr_data[31:0]),
     .dr_csr_data_valid                 (dr_csr_data_valid),
     // Inputs
     .trst_n                            (trst_n),
     .tms                               (tms),
     .tck                               (tck),
     .tdi                               (tdi),
     .csr_addr                          (csr_addr[2:0]),
     .csr_data                          (csr_data[31:0]));

  csr csr_u0
    (/*AUTOINST*/
     // Outputs
     .csr_addr                          (csr_addr[2:0]),
     .csr_data                          (csr_data[31:0]),
     .led                               (led[3:0]),
     // Inputs
     .sys_rst_n                         (sys_rst_n),
     .sys_clk                           (sys_clk),
     .dr_csr_addr_valid                 (dr_csr_addr_valid),
     .dr_csr_addr                       (dr_csr_addr[2:0]),
     .dr_csr_data_valid                 (dr_csr_data_valid),
     .dr_csr_data                       (dr_csr_data[31:0]));

endmodule
// Local Variables:
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-y ./ -y ../clkrst/ -y ../csr/ -y ../jtag/")
// End:
