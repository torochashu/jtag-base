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

// Asynchronous rising/falling edge detector
module cdc_edge_det (
  input logic           rst_n,
  input logic           clk,
  input logic           async_in,
  output logic          sync_out,
  output logic          sync_posedge,
  output logic          sync_negedge
);

  logic                 sync_out_1q;

  cdc_2ff_sync cdc_2ff_sync_u0
    (.rst_n             (rst_n),
     .clk               (clk),
     .async_in          (async_in),
     .sync_out          (sync_out));

  always_ff @ (posedge clk or negedge rst_n)
    if (~rst_n) begin
      sync_out_1q <= 1'b0;
    end
    else begin
      sync_out_1q <= sync_out;
    end

  // Generate a pulse indicating the edge type in the destination clock domain.
  assign sync_posedge = sync_out & ~sync_out_1q;
  assign sync_negedge = ~sync_out & sync_out_1q;

endmodule
