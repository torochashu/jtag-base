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

// JTAG Instruction Register
module jtag_ir
  import jtag_pkg::*;
  (
  input logic           trst_n,
  input logic           tck,
  input logic           tdi,
  input logic           reset,
  input logic           capir,
  input logic           shiftir,
  input logic           updateir,
  output logic          tdo,
  output logic [IR_LEN-1:0] curr_inst
);

  logic [IR_LEN-1:0]    shiftreg;

  // Instruction register, see Table 7-1 of 1149.1.
  always_ff @ (posedge tck)
    if (capir) begin
      shiftreg <= { {IR_LEN-2{1'b0}}, 2'b01 };
    end
    else if (shiftir) begin
      shiftreg <= { tdi, shiftreg[IR_LEN-1:1] };
    end

  always_ff @ (negedge tck or negedge trst_n)
    if (~trst_n) begin
      curr_inst <= IDCODE_INST;
    end
    else if (reset) begin
      curr_inst <= IDCODE_INST;
    end
    else if (updateir) begin
      curr_inst <= shiftreg;
    end

  // Serial output.
  always_ff @ (negedge tck)
    if (shiftir) begin
      tdo <= shiftreg[0];
    end

endmodule
