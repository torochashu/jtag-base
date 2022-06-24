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

package jtag_pkg;

  parameter             IR_LEN = 6;

  // Instruction
  //
  // Use CSR_ADDR_INST to select one of four 32-bit Control/Status Registers.
  //    CSR_ADDR[2:1] = CSR address
  //    CSR_ADDR[0]   = read/write control (0 = write, 1 = read)
  //
  // User CSR_DATA_INST to read (or write) the selected CSR.
  typedef enum logic [IR_LEN-1:0] {
                          BYPASS_INST   = '1,
                          IDCODE_INST   = 'h3c,
                          CSR_ADDR_INST = 'h06,
                          CSR_DATA_INST = 'h19
                        } inst_t;

  // Data
  // Note: Per Figure 12-1 of 1149.1, LSB of 32-bit IDCODE must be 1'b1.
  parameter             IDCODE_DATA = 32'hCBA3E6FD;

endpackage
