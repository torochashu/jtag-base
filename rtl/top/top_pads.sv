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

module top_pads (
  // I/O pins
  input                 SRST_N,
  input                 TRST_N,
  input                 TMS,
  input                 TCK,
  input                 TDI,
  output                TDO,
  output                LED0,
  output                LED1,
  output                LED2,
  output                LED3,
  // system
  output                srst_n,
  output                trst_n,
  output                tms,
  output                tck,
  output                tdi,
  input                 tdo_oe,
  input                 tdo,
  input [3:0]           led
);

`ifdef MICROZED
  // Zynq uses 7 Series SelectIO cells.
  IBUF pad_srst_n
    (.I   (SRST_N),
     .O   (srst_n));

  IBUF pad_trst_n
    (.I   (TRST_N),
     .O   (trst_n));

  IBUF pad_tms
    (.I   (TMS),
     .O   (tms));

  IBUF pad_tck
    (.I   (TCK),
     .O   (tck));

  IBUF pad_tdi
    (.I   (TDI),
     .O   (tdi));

  OBUFT pad_tdo
    (.T   (~tdo_oe),
     .I   (tdo),
     .O   (TDO));

  OBUF pad_led0
    (.I   (led[0]),
     .O   (LED0));

  OBUF pad_led1
    (.I   (led[1]),
     .O   (LED1));

  OBUF pad_led2
    (.I   (led[2]),
     .O   (LED2));

  OBUF pad_led3
    (.I   (led[3]),
     .O   (LED3));
`elsif DE10
  `DIE_TODO
`else
  `DIE_UNSUPPORTED_PLATFORM
`endif

endmodule
