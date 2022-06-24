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

// Control and Status Register (CSR) module accessible through JTAG
module csr (
  // reset and clock
  input logic           sys_rst_n,
  input logic           sys_clk,
  // JTAG data
  input logic           dr_csr_addr_valid,
  input logic [2:0]     dr_csr_addr,
  output logic [2:0]    csr_addr,
  input logic           dr_csr_data_valid,
  input logic [31:0]    dr_csr_data,
  output logic [31:0]   csr_data,
  // system
  output logic [3:0]    led
);

  localparam            WR = 1'b0,
                        RD = 1'b1;

  logic                 addr_valid;
  logic                 data_valid;

  logic [31:0]          csr0;
  logic [31:0]          csr1;
  logic [31:0]          csr2;
  logic [31:0]          csr3;

  logic [1:0]           addr;
  logic                 rw;

  // Generate enable pulses in the sys_clk domain.
  cdc_edge_det cdc_edge_det_u0
    (.rst_n             (sys_rst_n),
     .clk               (sys_clk),
     .async_in          (dr_csr_addr_valid),
     // verilator lint_off PINCONNECTEMPTY
     .sync_out          (),
     .sync_posedge      (),
     // verilator lint_on PINCONNECTEMPTY
     .sync_negedge      (addr_valid));

  cdc_edge_det cdc_edge_det_u1
    (.rst_n             (sys_rst_n),
     .clk               (sys_clk),
     .async_in          (dr_csr_data_valid),
     // verilator lint_off PINCONNECTEMPTY
     .sync_out          (),
     .sync_posedge      (),
     // verilator lint_on PINCONNECTEMPTY
     .sync_negedge      (data_valid));

  // CSR address and read/write control signals.
  always_ff @ (posedge sys_clk or negedge sys_rst_n)
    if (~sys_rst_n) begin
      addr <= '0;
      rw <= RD;
    end
    else if (addr_valid) begin
      addr <= dr_csr_addr[2:1];
      rw <= dr_csr_addr[0];
    end

  // Register updates.
  always_ff @ (posedge sys_clk or negedge sys_rst_n)
    if (~sys_rst_n) begin
      csr0 <= '0;
      csr1 <= '0;
      csr2 <= '0;
      csr3 <= '0;
    end
    else if (data_valid && (rw == WR)) begin
      case (addr)
        2'h0: csr0 <= dr_csr_data;
        2'h1: csr1 <= dr_csr_data;
        2'h2: csr2 <= dr_csr_data;
        2'h3: csr3 <= dr_csr_data;
      endcase
    end

  // These outputs will be stable and can be safely read during Capture-DR.
  assign csr_addr = { addr, rw };

  always_comb begin
    case (addr)
      2'h0: csr_data = csr0;
      2'h1: csr_data = csr1;
      2'h2: csr_data = csr2;
      default: csr_data = csr3;
    endcase
  end

  // Register functions.
  assign led = csr0[3:0];

endmodule
