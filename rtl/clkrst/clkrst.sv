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

// System clock and reset generator
module clkrst (
  // I/O pads
  input                 REFCLK,
  input                 srst_n,
  // system
  output                sys_clk,
  output                sys_rst_n
);

`ifdef MICROZED
  // 100 MHz REFCLK comes from PS.
  assign sys_clk = REFCLK;
`elsif DE10
  `DIE_TBD
`else
  `DIE_UNSUPPORTED_PLATFORM
`endif

  // srst_n is active-low and comes from JTAG debugger.
  rst_sync rst_sync_u0
    (.rst_n             (srst_n),
     .clk               (sys_clk),
     .rst_sync_n        (sys_rst_n));

endmodule
