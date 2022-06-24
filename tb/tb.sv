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

`timescale 1ps/1ps

module tb (
  /*AUTOINPUT*/
  /*AUTOOUTPUT*/
  // Beginning of automatic outputs (from unused autoinst outputs)
  output                LED0,                   // From dut of top.v
  output                LED1,                   // From dut of top.v
  output                LED2,                   // From dut of top.v
  output                LED3                    // From dut of top.v
  // End of automatics
  /*AUTOINOUT*/
);

  //-----------------------------------
  // localparams
  //-----------------------------------
`ifdef MICROZED
  localparam            REFCLK_PERIOD = 10000;  // 100 MHz
`elsif DE10_NANO
  `DIE_TBD
`else
  `DIE_UNSUPPORTED_PLATFORM
`endif

  localparam            TCK_PERIOD = 100000;  // 10 MHz

  localparam            NUM_ITERATIONS = 100;

  // From jtag_pkg.sv
  // TODO: import the package into this testbench.
  localparam            IR_LEN = 6;

  localparam            IDCODE_INST   = 6'h3c,
                        CSR_ADDR_INST = 6'h06,
                        CSR_DATA_INST = 6'h19;

  localparam            IDCODE = 32'hcba3e6fd;

  // From csr.sv
  // TODO: implement this some other way.
  localparam            WR = 1'b0,
                        RD = 1'b1;

  // From jtag_debugger.sv
  // TODO: implement this some other way.
  localparam            MAX_DRLEN = 256;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  SRST_N;                 // To/From dbg of jtag_debugger.v
  wire                  TCK;                    // To/From dbg of jtag_debugger.v
  wire                  TDI;                    // To/From dbg of jtag_debugger.v
  wire                  TDO;                    // From dut of top.v
  wire                  TMS;                    // To/From dbg of jtag_debugger.v
  wire                  TRST_N;                 // To/From dbg of jtag_debugger.v
  // End of automatics

  logic                 REFCLK;

  logic [31:0]          idcode;

  logic [31:0]          csr_ref[0:3];
  logic [1:0]           csr_addr;
  logic [31:0]          csr_wr_data;
  logic [31:0]          csr_rd_data;
  bit                   csr_rw;

  //-----------------------------------
  // clock and reset generation
  //-----------------------------------
  initial begin
    REFCLK <= 1'b0;

    forever begin
      #(REFCLK_PERIOD/2) REFCLK = ~REFCLK;
    end
  end

  //-----------------------------------
  // testbench control
  //-----------------------------------
  initial begin
    // You must pass the "-lxt2" switch to vvp to dump LXT2.
    $dumpfile("dump.lxt2");
    $dumpvars(0, tb);
  end

  initial begin
`ifdef MICROZED
    $display("%0t [%m] Platform is Avnet MicroZed", $time);
`elsif DE10_NANO
    $display("%0t [%m] Platform is terasIC DE10-Nano", $time);
`else
  `DIE_UNSUPPORTED_PLATFORM
`endif

    // Assert SRST_N.
    repeat (100) @ (posedge REFCLK);
    dbg.pad_srst_n = 1'b0;
    $display("%0t [%m] SRST_N asserted", $time);
    repeat (100) @ (posedge REFCLK);
    dbg.pad_srst_n = 1'bz;
    $display("%0t [%m] SRST_N deasserted", $time);

    // Initialize CSR reference.  Should be 0 after SRST_N.
    csr_ref[0] = '0;
    csr_ref[1] = '0;
    csr_ref[2] = '0;
    csr_ref[3] = '0;

    // Put debugger in known state.
    $display("%0t [%m] Putting DUT in Run-Test/Idle", $time);
    dbg.test_logic_reset;
    dbg.run_test_idle;

    // Read DUT IDCODE.
    $display("%0t [%m] Reading DUT IDCODE", $time);
    dbg.irscan(IR_LEN, IDCODE_INST);
    dbg.drscan(32, 0);

    idcode = dbg.shiftreg_dr[MAX_DRLEN-1:MAX_DRLEN-32];

    if (idcode === IDCODE) begin
      $display("%0t [%m] SUCCESS: IDCODE = 0x%08x", $time, idcode);
    end
    else begin
      $display("%0t [%m] ERROR: IDCODE = 0x%08x (expected 0x%08x)",
        $time, idcode, IDCODE);
    end

    // Do randomized testing of 32-bit CSRs in DUT.
    repeat (NUM_ITERATIONS) begin
      csr_addr = $random;
      csr_rw = $random;
      csr_wr_data = $random;

      if (csr_rw == RD) begin
        $display("%0t [%m] Reading CSR%0d",
          $time, csr_addr);
      end
      else begin
        $display("%0t [%m] Writing 0x%08x to CSR%0d",
          $time, csr_wr_data, csr_addr);
      end

      dbg.irscan(IR_LEN, CSR_ADDR_INST);
      dbg.drscan(3, { csr_addr, csr_rw });
      dbg.irscan(IR_LEN, CSR_DATA_INST);
      // csr_wr_data must be ignored by DUT if csr_rw == RD.
      dbg.drscan(32, csr_wr_data);

      // Capture-DR-Scan always returns previous value of DUT CSR.
      csr_rd_data = dbg.shiftreg_dr[MAX_DRLEN-1:MAX_DRLEN-32];

      if (csr_rd_data !== csr_ref[csr_addr]) begin
        $display("%0t [%m] ERROR: CSR%0d = 0x%08x (expected 0x%08x)",
          $time, csr_addr, csr_rd_data, csr_ref[csr_addr]);
        repeat (10) @ (posedge REFCLK);
        $finish;
      end
      else begin
        if (csr_rw == RD) begin
          $display("%0t [%m] SUCCESS: CSR%0d = 0x%08x",
            $time, csr_addr, csr_rd_data);
        end
      end

      // Update reference.
      if (csr_rw == WR) begin
        csr_ref[csr_addr] = csr_wr_data;
      end
    end

    // Run for a few more cycles and then quit.
    repeat (100) @ (posedge REFCLK);
    $display("%0t [%m] Simulation finished", $time);
    $finish;
  end

  //-----------------------------------
  // stimulus
  //-----------------------------------
  pullup(SRST_N);
  pullup(TRST_N);
  pullup(TMS);
  pullup(TCK);
  pullup(TDI);
  pullup(TDO);

  jtag_debugger dbg
    (/*AUTOINST*/
     // Inouts
     .SRST_N                            (SRST_N),
     .TRST_N                            (TRST_N),
     .TMS                               (TMS),
     .TCK                               (TCK),
     .TDI                               (TDI),
     .TDO                               (TDO));

  initial begin
    dbg.TCK_PERIOD = TCK_PERIOD;
  end

  //-----------------------------------
  // DUT
  //-----------------------------------
  top dut
    (/*AUTOINST*/
     // Outputs
     .TDO                               (TDO),
     .LED0                              (LED0),
     .LED1                              (LED1),
     .LED2                              (LED2),
     .LED3                              (LED3),
     // Inputs
     .REFCLK                            (REFCLK),
     .SRST_N                            (SRST_N),
     .TRST_N                            (TRST_N),
     .TMS                               (TMS),
     .TCK                               (TCK),
     .TDI                               (TDI));

endmodule
// Local Variables:
// verilog-library-flags:("-y ./ -y ../rtl/top/")
// End:
