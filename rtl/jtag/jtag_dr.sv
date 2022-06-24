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

// JTAG Data Registers
module jtag_dr
  import jtag_pkg::*;
  (
  input logic           tck,
  input logic           tdi,
  input logic           capdr,
  input logic           shiftdr,
  input logic           updatedr,
  input logic [IR_LEN-1:0] curr_inst,
  output logic          tdo,
  // system
  input logic [2:0]     csr_addr,
  output logic          dr_csr_addr_valid,
  output logic [2:0]    dr_csr_addr,
  input logic [31:0]    csr_data,
  output logic          dr_csr_data_valid,
  output logic [31:0]   dr_csr_data
);

  inst_t                inst;

  logic                 dr_bypass;
  logic [31:0]          dr_idcode;

  logic                 shiftreg;

  // Unsupported instructions will select BYPASS as default.
  always_comb begin
    case (curr_inst)
      IDCODE_INST   : inst = IDCODE_INST;
      CSR_ADDR_INST : inst = CSR_ADDR_INST;
      CSR_DATA_INST : inst = CSR_DATA_INST;
      default       : inst = BYPASS_INST;
    endcase
  end

  // Bypass register, see Chapter 10 of 1149.1.
  always_ff @ (posedge tck)
    if (inst == BYPASS_INST) begin
      if (capdr) begin
        dr_bypass <= 1'b0;
      end
      else if (shiftdr) begin
        dr_bypass <= tdi;
      end
    end

  // Boundary scan register, see Chapter 11 of 1149.1.
  // TODO

  // Device identification register, see Chapter 12 of 1149.1.
  always_ff @ (posedge tck)
    if (inst == IDCODE_INST) begin
      if (capdr) begin
        dr_idcode <= IDCODE_DATA;
      end
      else if (shiftdr) begin
        dr_idcode <= { tdi, dr_idcode[31:1] };
      end
    end

  // User registers
  // Note: Data from the system comes from a different clock domain.
  always_ff @ (posedge tck)
    if (inst == CSR_ADDR_INST) begin
      if (capdr) begin
        dr_csr_addr <= csr_addr;
      end
      if (shiftdr) begin
        dr_csr_addr <= { tdi, dr_csr_addr[2:1] };
      end
    end

  always_ff @ (posedge tck)
    if (updatedr && (inst == CSR_ADDR_INST)) begin
      dr_csr_addr_valid <= 1'b1;
    end
    else begin
      dr_csr_addr_valid <= 1'b0;
    end

  always_ff @ (posedge tck)
    if (inst == CSR_DATA_INST) begin
      if (capdr) begin
        dr_csr_data <= csr_data;
      end
      if (shiftdr) begin
        dr_csr_data <= { tdi, dr_csr_data[31:1] };
      end
    end

  always_ff @ (posedge tck)
    if (updatedr && (inst == CSR_DATA_INST)) begin
      dr_csr_data_valid <= 1'b1;
    end
    else begin
      dr_csr_data_valid <= 1'b0;
    end

  // Serial output.
  // TODO: always_comb not fully supported by Icarus Verilog.
  //always_comb begin
  always @ (*) begin
    case (inst)
      IDCODE_INST   : shiftreg = dr_idcode[0];
      CSR_ADDR_INST : shiftreg = dr_csr_addr[0];
      CSR_DATA_INST : shiftreg = dr_csr_data[0];
      default       : shiftreg = dr_bypass;
    endcase
  end

  always_ff @ (negedge tck)
    if (shiftdr) begin
      tdo <= shiftreg;
    end

endmodule
