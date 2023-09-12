//========================================================================
// tb_IntMul
//========================================================================
// A basic Verilog test bench for the multiplier

`default_nettype none
`timescale 1ps/1ps

`ifndef DESIGN
  `define DESIGN IntMulBase
`endif

`include `"`DESIGN.v`"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );

  // DUT signals
  logic        reset;

  logic        istream_val;
  logic        istream_rdy;
  logic [63:0] istream_msg;

  logic signed      ostream_rdy;
  logic signed      ostream_val;
  logic signed [31:0] ostream_msg;

  // Testbench signals
  logic        istream_val_f;
  logic        ostream_rdy_f;
  logic signed [31:0] a;
  logic signed [31:0] b;

  logic [31:0] istream_msg_a;
  logic [31:0] istream_msg_b;

  // Form istream_msg
  always_comb begin
    istream_msg[63:32] = istream_msg_a;
    istream_msg[31: 0] = istream_msg_b;
  end

  //----------------------------------------------------------------------
  // Module instantiations
  //----------------------------------------------------------------------
  
  // Instantiate the multiplier

  lab1_imul_`DESIGN imul
  (
    .clk   (clk),
    .reset (reset),
    .istream_val(istream_val),
    .istream_rdy(istream_rdy),
    .istream_msg(istream_msg),
    .ostream_val   (ostream_val),
    .ostream_rdy   (ostream_rdy),
    .ostream_msg   (ostream_msg)
  );
  reg signed [31:0] signed_istream_msg_a;
  reg signed [31:0] signed_ostream_msg;
  reg signed [31:0] signed_istream_msg_b;
  initial begin 
    while(1) begin
      @(negedge clk);  
      if (linetrace) begin
           imul.display_trace;
      end
    end 
    $stop;
   end

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin

    $display("Start of Testbench");
    // Send reset and init values of all signals
    reset         = 1;
    istream_msg_a = 0;
    istream_msg_b = 0;
    istream_val   = 0;

    // After a moment, de-assert reset
    #10 
    reset = 0;

    //--------------------------------------------------------------------
    // Test cases
    //--------------------------------------------------------------------

    // Align test bench with negedge so that it looks better
    #10
    @(negedge clk); 

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Test #1
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    $display("Example Test #1");

    //Set inputs
    //istream_msg_a = 32'd2;
    istream_msg_a = 2;
    istream_msg_b = -3;
    istream_val   =  1'b1;
    ostream_rdy   =  1'b1;
    if (istream_msg_a[31]) begin
        signed_istream_msg_a = ~istream_msg_a + 1'b1;
        signed_istream_msg_a = -signed_istream_msg_a;
    end else begin
        signed_istream_msg_a = istream_msg_a;
    end

    if (istream_msg_b[31]) begin
        signed_istream_msg_b = ~istream_msg_b + 1'b1;
        signed_istream_msg_b = -signed_istream_msg_b;
    end else begin
        signed_istream_msg_b = istream_msg_b;
    end


    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    @(negedge clk); // Move to next cycle.
    
    istream_val = 1'b0; // Deassert ready input
    if(!ostream_val) @(ostream_val);// Wait for response
    @(negedge clk); // read at low clk

    if (ostream_msg[31]) begin
        signed_ostream_msg = ~ostream_msg + 1'b1;
        signed_ostream_msg = -signed_ostream_msg;
    end else begin
        signed_ostream_msg = ostream_msg;
    end
    
    // Check the result
    assert ( -6 == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", 
                signed_istream_msg_a, signed_istream_msg_b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", 
              istream_msg_a, istream_msg_b, ostream_msg );
    end
   
    #10
    @(negedge clk);

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Test #2
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    $display("Example Test #2");
    
    //Set inputs
    istream_msg_a = 32'd4;
    istream_msg_b = 32'd5;
    istream_val   =  1'b1;
    ostream_rdy   =  1'b1;

    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    @(negedge clk); // Move to next cycle.
    
    istream_val = 1'b0; // Deassert ready input
    if(!ostream_val) @(ostream_val);// Wait for response
    @(negedge clk); // read at low clk
    
    // Check the result
    assert ( 20 == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", 
                istream_msg_a, istream_msg_b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", 
              istream_msg_a, istream_msg_b, ostream_msg );
    end
   
    #10
    @(negedge clk);

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Test #3
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    $display("Example Test #3");

    //Set inputs
    istream_msg_a = 32'd3;
    istream_msg_b = 32'd4;
    istream_val   =  1'b1;
    ostream_rdy   =  1'b1;
    
    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    @(negedge clk); // Move to next cycle.
    
    istream_val = 1'b0; // Deassert ready input
    if(!ostream_val) @(ostream_val);// Wait for response
    @(negedge clk); // read at low clk
    
    // Check the result
    assert ( 12 == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", 
                istream_msg_a, istream_msg_b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", 
              istream_msg_a, istream_msg_b, ostream_msg );
    end
   
    #10
    @(negedge clk);

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Test #4
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    $display("Example Test #4");

    //Set inputs
    istream_msg_a = 32'd10;
    istream_msg_b = 32'd13;
    istream_val   =  1'b1;
    ostream_rdy   =  1'b1;
    
    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    
    @(negedge clk); // Move to next cycle.
    // This is the place the ostream_msg value changes
    
    istream_val = 1'b0; // Deassert ready input
    if(!ostream_val) @(ostream_val);// Wait for response
    @(negedge clk); // read at low clk
    
    
    // Check the result
    assert ( 130 == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", 
                istream_msg_a, istream_msg_b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", 
              istream_msg_a, istream_msg_b, ostream_msg );
    end
   
    #10
    @(negedge clk);

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Test #5
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    $display("Example Test #5");
    
    // We can simplify Testbench with tasks (declared below)
    test_task(8,7);

    #10;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Random Tests
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    $display("Random Test");
    for( integer x = 0; x < 5; x++ ) begin
      test_task( $random, $random );
    end

    // Multiply by zero
    a = 32'h00000000; b = 32'h12345678; 
    test_task(a,b);

    // Multiply by one
    a = 32'h00000001; b = 32'h12345678; 
    test_task(a,b);

    // Multiply by negative one
    a = 32'hFFFFFFFF; b = 32'h12345678; 
    test_task(a,b);

    // Mask off the low 16 bits of a and b
    a = 32'h12340000; b = 32'h56780000;
    test_task(a,b);

    // Mask off the middle 16 bits of a and b
    a = 32'h34000056; b = 32'h12000034;
    test_task(a,b);

    // Sparse numbers
    a = 32'h10000001; b = 32'h80000001;
    test_task(a,b);

    // Dense numbers
    a = 32'hFFFFFFFE; b = 32'h7FFFFFFF;
    test_task(a,b);

    // Finish the testbench
    
    @(negedge clk);
    $display("Testbench finished at %d cycles", ($time()-17)/2 );
    
    // Delay for a better waveform
    #10;
    $finish;

  end

  //--------------------------------------------------------------------
  // test_task definition
  //--------------------------------------------------------------------
  // Here is a tasks that test the DUT when given 2 numbers a and b 
  //
  // Notice that the functionality is identical to the examples above

  task test_task( signed [31:0] input_a,  signed [31:0] input_b );
  begin

    // Change inputs at the negedge
    @(negedge clk);

    // Set inputs
    istream_msg_a = input_a;
    istream_msg_b = input_b;
    istream_val   = 1'b1;
    ostream_rdy   = 1'b0;

    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    @(negedge clk); // Move to next cycle.
    $display("Right now the ostream_msg is %d", ostream_msg);
    istream_val = 1'b0; // No more ready input
    ostream_rdy = 1'b1; // Ready for output

    if(!ostream_val) @(ostream_val);// Wait for response
    
    // Check the result
    assert ( (input_a * input_b) == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", input_a, input_b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", input_a, input_b, ostream_msg );
    end

    @(negedge clk);
  end
  endtask
endmodule
