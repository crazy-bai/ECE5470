//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================


`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "vc/trace.v"
`include "vc/arithmetic.v"


// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module lab1_imul_IntMulBase
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,
  output logic        istream_rdy,
  input  logic [63:0] istream_msg,

  output logic        ostream_val,
  input  logic        ostream_rdy,
  output logic [31:0] ostream_msg
);

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiate datapath and control models here and then connect them
  // together.
  typedef enum logic [1:0] {IDLE, CALC, DONE} statetype;
  statetype state, nextstate;

  logic [31:0] a;
  logic [31:0] b;
  logic [7:0]  counter;
  logic [31:0] next_a;
  logic [31:0] next_b;
  logic [31:0] next_ostream_msg;
  logic        next_ostream_val;

  logic [31:0] add_result;
  vc_SimpleAdder #(32) Add(ostream_msg, a, add_result);
  

  //state_register
  always_ff@(posedge clk) begin
    if(reset) begin
      state <= IDLE;
    end
    else      begin 
      if(state == IDLE) begin
          istream_rdy <= 1;
          a <= next_a;
          b <= next_b;
          ostream_msg <= next_ostream_msg;
          ostream_val <= next_ostream_val;
          counter <= 0;
      end
      else if(state == CALC) begin     
          a <= next_a;
          b <= next_b;
          ostream_msg <= next_ostream_msg;
          ostream_val <= next_ostream_val;
          counter <= counter + 1;
          if(next_ostream_val) istream_rdy <= 0;
      end
      else if(state == DONE) begin
        ostream_val <= next_ostream_val;
      end
      state <= nextstate;
    end
  end

  //next_state_logic
  always_comb
    case(state)
      IDLE: if(istream_val)                 nextstate = CALC;
            else                            nextstate = IDLE;
      CALC: if(counter == 8'd32)            nextstate = DONE;
            else                            nextstate = CALC;
      DONE: if(ostream_rdy)  nextstate = IDLE;
            else                            nextstate = DONE;
      default:                              nextstate = IDLE;
    endcase

  //output_logic

  always_comb begin
        next_a = a;
        next_b = b;
        next_ostream_msg = ostream_msg;
        next_ostream_val = ostream_val;

      if(istream_val && istream_rdy) begin
        next_a = istream_msg[63:32];
        next_b = istream_msg[31:0];
        next_ostream_msg = 0;
        next_ostream_val = 0;
      end 
      else if(counter != 32)begin
        next_a = a << 1;
        next_b = b >> 1;
        if(b[0]) begin
          next_ostream_msg = add_result;
        end
        else begin
          next_ostream_msg = ostream_msg;
        end
          next_ostream_val = 0;
      end
      else if(!(ostream_val && ostream_rdy))
          next_ostream_val = 1;
      else 
          next_ostream_val = 0;
   end


  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", istream_msg );
    vc_trace.append_val_rdy_str( trace_str, istream_val, istream_rdy, str );

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add additional line tracing using the helper tasks for
    if(state == 0) $sformat(str, "IDLE");
    else if(state == 1) $sformat(str, "CALC");
    else if(state == 2) $sformat(str, "DONE");
    else $sformat(str, "UNKNOWN");
    vc_trace.append_str( trace_str, str);

    // internal state including the current FSM state.
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", ostream_msg );
    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_BASE_V */
