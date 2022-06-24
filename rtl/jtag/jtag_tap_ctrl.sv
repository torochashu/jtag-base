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

// JTAG TAP Controller (see Chapter 6 of IEEE Std 1149.1-2001)
module jtag_tap_ctrl (
  // I/O pads
  input logic           trst_n,
  input logic           tms,
  input logic           tck,
  output logic          tdo_oe,
  // system
  output logic          reset,
  output logic          capir,
  output logic          shiftir,
  output logic          updateir,
  output logic          capdr,
  output logic          shiftdr,
  output logic          updatedr,
  output logic [3:0]    dbg_fsm
);

  // From Table 6-3 of 1149.1.  Use short names for easier waveform viewing.
  typedef enum logic [3:0] {
                          EX2_DR  = 4'h0, // Exit2-DR
                          EX1_DR  = 4'h1, // Exit1-DR
                          SHF_DR  = 4'h2, // Shift-DR
                          PAS_DR  = 4'h3, // Pause-DR
                          SEL_IR  = 4'h4, // Select-IR Scan
                          UPD_DR  = 4'h5, // Update-DR
                          CAP_DR  = 4'h6, // Capture-DR
                          SEL_DR  = 4'h7, // Select-DR Scan
                          EX2_IR  = 4'h8, // Exit2-IR
                          EX1_IR  = 4'h9, // Exit1-IR
                          SHF_IR  = 4'ha, // Shift-IR
                          PAS_IR  = 4'hb, // Pause-IR
                          RT_IDL  = 4'hc, // Run-Test/Idle
                          UPD_IR  = 4'hd, // Update-IR,
                          CAP_IR  = 4'he, // Capture-IR
                          TL_RST  = 4'hf  // Test-Logic-Reset
                        } state_t;

  state_t               fsm_ps, fsm_ns;

  // TAP controller state machine, see Figure 6-1 of 1149.1.
  always_comb begin
    case (fsm_ps)
      TL_RST: begin
        if (tms == 1'b0) begin
          fsm_ns = RT_IDL;
        end
        else begin
          fsm_ns = TL_RST;
        end
      end
      RT_IDL: begin
        if (tms == 1'b1) begin
          fsm_ns = SEL_DR;
        end
        else begin
          fsm_ns = RT_IDL;
        end
      end
      SEL_DR: begin
        if (tms == 1'b1) begin
          fsm_ns = SEL_IR;
        end
        else begin
          fsm_ns = CAP_DR;
        end
      end
      CAP_DR: begin
        if (tms == 1'b0) begin
          fsm_ns = SHF_DR;
        end
        else begin
          fsm_ns = EX1_DR;
        end
      end
      SHF_DR: begin
        if (tms == 1'b1) begin
          fsm_ns = EX1_DR;
        end
        else begin
          fsm_ns = SHF_DR;
        end
      end
      EX1_DR: begin
        if (tms == 1'b0) begin
          fsm_ns = PAS_DR;
        end
        else begin
          fsm_ns = UPD_DR;
        end
      end
      PAS_DR: begin
        if (tms == 1'b1) begin
          fsm_ns = EX2_DR;
        end
        else begin
          fsm_ns = PAS_DR;
        end
      end
      EX2_DR: begin
        if (tms == 1'b1) begin
          fsm_ns = UPD_DR;
        end
        else begin
          fsm_ns = SHF_DR;
        end
      end
      UPD_DR: begin
        if (tms == 1'b1) begin
          fsm_ns = SEL_DR;
        end
        else begin
          fsm_ns = RT_IDL;
        end
      end
      SEL_IR: begin
        if (tms == 1'b1) begin
          fsm_ns = TL_RST;
        end
        else begin
          fsm_ns = CAP_IR;
        end
      end
      CAP_IR: begin
        if (tms == 1'b0) begin
          fsm_ns = SHF_IR;
        end
        else begin
          fsm_ns = EX1_IR;
        end
      end
      SHF_IR: begin
        if (tms == 1'b1) begin
          fsm_ns = EX1_IR;
        end
        else begin
          fsm_ns = SHF_IR;
        end
      end
      EX1_IR: begin
        if (tms == 1'b0) begin
          fsm_ns = PAS_IR;
        end
        else begin
          fsm_ns = UPD_IR;
        end
      end
      PAS_IR: begin
        if (tms == 1'b1) begin
          fsm_ns = EX2_IR;
        end
        else begin
          fsm_ns = PAS_IR;
        end
      end
      EX2_IR: begin
        if (tms == 1'b1) begin
          fsm_ns = UPD_IR;
        end
        else begin
          fsm_ns = SHF_IR;
        end
      end
      UPD_IR: begin
        if (tms == 1'b1) begin
          fsm_ns = SEL_IR;
        end
        else begin
          fsm_ns = RT_IDL;
        end
      end
      default: begin
        fsm_ns = RT_IDL;
      end
    endcase
  end

  always_ff @ (posedge tck or negedge trst_n)
    if (~trst_n) begin
      fsm_ps <= TL_RST;
    end
    else begin
      fsm_ps <= fsm_ns;
    end

  assign dbg_fsm = fsm_ps;

  // Generate the TDO control signal, see Table 6-2 of 1149.1.
  // Register this signal to avoid glitches on the output pin.
  always_ff @ (posedge tck or negedge trst_n)
    if (~trst_n) begin
      tdo_oe <= 1'b0;
    end
    else if ((fsm_ns == SHF_DR) || (fsm_ns == SHF_IR)) begin
      tdo_oe <= 1'b1; // Active
    end
    else begin
      tdo_oe <= 1'b0; // Inactive
    end

  // Generate the system control signals, see Figure 6-5 of 1149.1.
  assign reset = (fsm_ps == TL_RST);

  assign capir = (fsm_ps == CAP_IR);
  assign shiftir = (fsm_ps == SHF_IR);
  assign updateir = (fsm_ps == UPD_IR);

  assign capdr = (fsm_ps == CAP_DR);
  assign shiftdr = (fsm_ps == SHF_DR);
  assign updatedr = (fsm_ps == UPD_DR);

endmodule

