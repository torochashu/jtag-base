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

// JTAG 1149.1-2001 debugger that emulates the OpenOCD irscan/drscan commands.
// The testbench must call the irscan/drscan tasks directly.
module jtag_debugger (
  inout                 SRST_N,
  inout                 TRST_N,
  inout                 TMS,
  inout                 TCK,
  inout                 TDI,
  inout                 TDO
);

  parameter             MAX_STRLEN = 32 * 8;

  parameter             MAX_IRLEN = 256,
                        MAX_DRLEN = 256;

  logic                 pad_srst_n;
  logic                 pad_trst_n;
  logic                 pad_tms;
  logic                 pad_tck;
  logic                 pad_tdi;

  logic [MAX_IRLEN-1:0] shiftreg_ir;
  logic [MAX_DRLEN-1:0] shiftreg_dr;

  logic [MAX_STRLEN-1:0] dbg_state;
  bit                   dbg_en;

  int                   TCK_PERIOD; // defined in tb.sv

  initial begin
    pad_srst_n = 1'bz;
    pad_trst_n = 1'bz;
    pad_tms = 1'bz;
    pad_tck = 1'bz;
    pad_tdi = 1'bz;

    dbg_state = "X";

    // TODO: Add command line option to modify this bit.
    dbg_en = 1'b0;
  end

  // Connect these signals to pullups in the testbench.
  assign SRST_N = pad_srst_n;
  assign TRST_N = pad_trst_n;
  assign TMS = pad_tms;
  assign TCK = pad_tck;
  assign TDI = pad_tdi;

  initial begin
    forever begin
      @ (negedge TCK);

      // Add small delay to avoid race condition and properly capture TDO.
      #2;

      if (dbg_state == "Shift-IR") begin
        shiftreg_ir = { TDO, shiftreg_ir[MAX_IRLEN-1:1] };
      end
      else if (dbg_state == "Shift-DR") begin
        shiftreg_dr = { TDO, shiftreg_dr[MAX_DRLEN-1:1] };
      end
    end
  end

  task enter_dbg_state;
    input [MAX_STRLEN-1:0] state;
    input               tms;
    input               tdi;

    begin
      // Change TMS/TDI on negedge TCK to provide ample setup time.
      pad_tck = 1'b0;

      if (tms === 1'b0) begin
        pad_tms = tms;
      end
      else begin
        pad_tms = 1'bz;
      end

      if (tdi === 1'b0) begin
        pad_tdi = tdi;
      end
      else begin
        pad_tdi = 1'bz;
      end

      #(TCK_PERIOD/2);
      pad_tck = 1'bz;

      dbg_state = state;

      if (dbg_en) begin
        $display("%0t [%m] %0s", $time, dbg_state);
      end

      #(TCK_PERIOD/2);
    end
  endtask

  task test_logic_reset;
    begin
      repeat (5) begin
        enter_dbg_state("Test-Logic-Reset", 1'b1, 1'bx);
      end
    end
  endtask

  task run_test_idle;
    begin
      enter_dbg_state("Run-Test/Idle", 1'b0, 1'bx);
    end
  endtask

  task select_dr_scan;
    begin
      enter_dbg_state("Select-DR-Scan", 1'b1, 1'bx);
    end
  endtask

  task capture_dr;
    begin
      enter_dbg_state("Capture-DR", 1'b0, 1'bx);
    end
  endtask

  task shift_dr;
    input               tdi;

    begin
      enter_dbg_state("Shift-DR", 1'b0, tdi);
    end
  endtask

  task exit1_dr;
    input               tdi;  // MSB from Shift-DR

    begin
      enter_dbg_state("Exit1-DR", 1'b1, tdi);
    end
  endtask

  task pause_dr;
    begin
      enter_dbg_state("Pause-DR", 1'b0, 1'bx);
    end
  endtask

  task exit2_dr;
    begin
      enter_dbg_state("Exit2-DR", 1'b1, 1'bx);
    end
  endtask

  task update_dr;
    begin
      enter_dbg_state("Update-DR", 1'b1, 1'bx);
    end
  endtask

  task select_ir_scan;
    begin
      enter_dbg_state("Select-IR-Scan", 1'b1, 1'bx);
    end
  endtask

  task capture_ir;
    begin
      enter_dbg_state("Capture-IR", 1'b0, 1'bx);
    end
  endtask

  task shift_ir;
    input               tdi;

    begin
      enter_dbg_state("Shift-IR", 1'b0, tdi);
    end
  endtask

  task exit1_ir;
    input               tdi;  // MSB from Shift-IR

    begin
      enter_dbg_state("Exit1-IR", 1'b1, tdi);
    end
  endtask

  task pause_ir;
    begin
      enter_dbg_state("Pause-IR", 1'b0, 1'bx);
    end
  endtask

  task exit2_ir;
    begin
      enter_dbg_state("Exit2-IR", 1'b1, 1'bx);
    end
  endtask

  task update_ir;
    begin
      enter_dbg_state("Update-IR", 1'b1, 1'bx);
    end
  endtask

  task irscan;
    input integer       length;
    input [MAX_IRLEN-1:0] inst;

    logic [MAX_IRLEN:0] shiftreg;

    begin
      if (dbg_en) begin
        $display("%0t [%m] irscan <tap> %0d 0x%x", $time, length, inst);
      end

      shiftreg = { inst, 1'bx };

      // We must start from Run-Test/Idle!
      select_dr_scan;
      select_ir_scan;
      capture_ir;

      repeat (length) begin
        // The first bit shifted in to TDI has to occur 1 cycle later.
        // This is why the first bit shifted in to this task is 1'bx.
        shift_ir(shiftreg[0]);
        shiftreg = { 1'b0, shiftreg[MAX_IRLEN-1:1] };
      end

      exit1_ir(shiftreg[0]);
      update_ir;
      run_test_idle;
    end
  endtask

  task drscan;
    input integer       length;
    input [MAX_DRLEN-1:0] data;

    logic [MAX_DRLEN:0] shiftreg;

    begin
      if (dbg_en) begin
        $display("%0t [%m] drscan <tap> %0d 0x%x", $time, length, data);
      end

      shiftreg = { data, 1'bx };

      // We must start from Run-Test/Idle!
      select_dr_scan;
      capture_dr;

      repeat (length) begin
        // The first bit shifted in to TDI has to occur 1 cycle later.
        // This is why the first bit shifted in to this task is 1'bx.
        shift_dr(shiftreg[0]);
        shiftreg = { 1'b0, shiftreg[MAX_DRLEN-1:1] };
      end

      exit1_dr(shiftreg[0]);
      update_dr;
      run_test_idle;
    end
  endtask

endmodule
