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

// JTAG subsystem top-level
module jtag_top
  import jtag_pkg::*;
  (
  /*AUTOINPUT*/
  /*AUTOOUTPUT*/
  /*AUTOINOUT*/

  // I/O pads
  input logic           trst_n,
  input logic           tms,
  input logic           tck,
  input logic           tdi,
  output logic          tdo_oe,
  output logic          tdo,
  // system
  input logic [2:0]     csr_addr,
  output logic [2:0]    dr_csr_addr,
  output logic          dr_csr_addr_valid,
  input logic [31:0]    csr_data,
  output logic [31:0]   dr_csr_data,
  output logic          dr_csr_data_valid,
  output logic [3:0]    dbg_fsm
);

  /*AUTOLOGIC*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic                 capdr;                  // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic                 capir;                  // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic [IR_LEN-1:0]    curr_inst;              // From jtag_ir_u0 of jtag_ir.v
  logic                 dr_tdo;                 // From jtag_dr_u0 of jtag_dr.v
  logic                 ir_tdo;                 // From jtag_ir_u0 of jtag_ir.v
  logic                 reset;                  // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic                 shiftdr;                // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic                 shiftir;                // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic                 updatedr;               // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  logic                 updateir;               // From jtag_tap_ctrl_u0 of jtag_tap_ctrl.v
  // End of automatics

  jtag_tap_ctrl jtag_tap_ctrl_u0
    (/*AUTOINST*/
     // Outputs
     .tdo_oe                            (tdo_oe),
     .reset                             (reset),
     .capir                             (capir),
     .shiftir                           (shiftir),
     .updateir                          (updateir),
     .capdr                             (capdr),
     .shiftdr                           (shiftdr),
     .updatedr                          (updatedr),
     .dbg_fsm                           (dbg_fsm[3:0]),
     // Inputs
     .trst_n                            (trst_n),
     .tms                               (tms),
     .tck                               (tck));

  /*
  jtag_ir AUTO_TEMPLATE
    (.tdo                               (ir_tdo),
    );
  */
  jtag_ir jtag_ir_u0
    (/*AUTOINST*/
     // Outputs
     .tdo                               (ir_tdo),                // Templated
     .curr_inst                         (curr_inst[IR_LEN-1:0]),
     // Inputs
     .trst_n                            (trst_n),
     .tck                               (tck),
     .tdi                               (tdi),
     .reset                             (reset),
     .capir                             (capir),
     .shiftir                           (shiftir),
     .updateir                          (updateir));

  /*
  jtag_dr AUTO_TEMPLATE
    (.tdo                               (dr_tdo),
    );
  */
  jtag_dr jtag_dr_u0
    (/*AUTOINST*/
     // Outputs
     .tdo                               (dr_tdo),                // Templated
     .dr_csr_addr_valid                 (dr_csr_addr_valid),
     .dr_csr_addr                       (dr_csr_addr[2:0]),
     .dr_csr_data_valid                 (dr_csr_data_valid),
     .dr_csr_data                       (dr_csr_data[31:0]),
     // Inputs
     .tck                               (tck),
     .tdi                               (tdi),
     .capdr                             (capdr),
     .shiftdr                           (shiftdr),
     .updatedr                          (updatedr),
     .curr_inst                         (curr_inst[IR_LEN-1:0]),
     .csr_addr                          (csr_addr[2:0]),
     .csr_data                          (csr_data[31:0]));

  jtag_tdo jtag_tdo_u0
    (/*AUTOINST*/
     // Outputs
     .tdo                               (tdo),
     // Inputs
     .ir_tdo                            (ir_tdo),
     .dr_tdo                            (dr_tdo),
     .shiftdr                           (shiftdr));

endmodule
// Local Variables:
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-y ./")
// End:
