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

// Standard two flip-flop Clock Domain Crossing (CDC) module
module cdc_2ff_sync (
  input logic           rst_n,
  input logic           clk,
  input logic           async_in,
  output logic          sync_out
);

  logic [1:0]           sync_ff;

  always_ff @ (posedge clk or negedge rst_n)
    if (~rst_n) begin
      sync_ff <= '0;
    end
    else begin
      sync_ff <= { sync_ff[0], async_in };
    end

  assign sync_out = sync_ff[1];

endmodule
