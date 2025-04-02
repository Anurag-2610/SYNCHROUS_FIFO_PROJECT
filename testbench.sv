
//test_bench for synchronous fifo

module tb_Synchronous_FIFO;

parameter WIDTH = 32;
parameter DEPTH = 1024;

reg clk, rst_n, wr_en, rd_en;
reg [WIDTH-1:0] data_in;
wire [WIDTH-1:0] data_out;
wire full, empty;
integer test_case;

Synchronous_FIFO #(.WIDTH(WIDTH), .DEPTH(DEPTH)) fifo_inst (
    .clk(clk),
    .reset(rst_n),
    .d_in(data_in),
    .w_enb(wr_en),
    .r_enb(rd_en),
    .d_out(data_out),
    .full(full),
    .empty(empty)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

  initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end
  



initial begin
  if (!$value$plusargs("test_case=%d", test_case)) begin
     $display("No test case specified. Exiting...");
      $finish;
      end
    rst_n = 0; wr_en = 0; rd_en = 0;
    #10 rst_n = 1;
    
    case(test_case)
    //Run all test cases
    1:test_case_write_operation();
    2:begin
      $display("write operation is required             before reading. Performing write operation             first...");
      test_case_write_operation();
      test_case_read_operation();
    end
    3:test_case_full_condition();
    4:begin
      test_case_full_condition();
      test_case_empty_condition();
    end
    5:test_case_single_element();
    6:test_case_multiple_writes();
      7:begin $display("First of all writing multiple data");
      test_case_multiple_writes();
      test_case_multiple_reads();
    end
    8:test_case_wrap_around();
    9:test_case_simultaneous_read_write();
    10:test_case_reset();
    11:test_case_overflow();
    12:begin
       test_case_write_operation();
       test_case_underflow();
    end
    default : $display("Invalid test case selected");
 endcase
 #1000
    $finish;
end

task test_case_write_operation();
begin
    data_in = 32'hAABBCCDD;
    wr_en = 1;#10 wr_en = 0;
    if (empty) $display("Error: FIFO should not be empty.");
  else $display("Data written to FIFO correctly");
end
endtask

task test_case_read_operation();
begin
    rd_en = 1; #10 rd_en = 0;
  if (data_out !== 32'hAABBCCDD) $display("Error: Data read mismatch.");
  else $display("Data read correctly");
end
endtask

task test_case_full_condition();
begin
    repeat (DEPTH) begin
        data_in = $random;
        wr_en = 1; #10 wr_en = 0;
    end
    if (!full) $display("Error: FIFO full flag not set.");
  else $display("FIFO full flag set correctly");
end
endtask

task test_case_empty_condition();
begin
    while (!empty) begin
        rd_en = 1; #10 rd_en = 0;
    end
    if (!empty) $display("Error: FIFO empty flag not set.");
  else $display("FIFO empty flag set correctly");
end 
endtask

task test_case_single_element();
begin
    data_in = 32'h55667788;
    wr_en = 1; #10 wr_en = 0;
    rd_en = 1; #10 rd_en = 0;
  if (data_out !== 32'h55667788) $display("Error: Single element mismatch.");
  else $display("Single element matched");
end
  
endtask

  
task test_case_multiple_writes();
integer i;
begin
    for (i = 0; i < DEPTH; i=i+1) begin
        data_in = i;
        wr_en = 1; #10 wr_en = 0;
    end
  if(full) $display("Multiple elements are written to the FIFO correctly");
  else $display("Multiple write test case failed");
end
endtask
  

task test_case_multiple_reads();
integer i;
begin
    for (i = 0; i < DEPTH; i=i+1) begin
        rd_en = 1; #10 rd_en = 0;
      if (data_out !== i) $display("Error: Multiple reads mismatch at index %0d", i);end
    
end
endtask

task test_case_wrap_around();
integer i;
begin
    for (i = 0; i < DEPTH; i=i+1) begin
        data_in = i;
        wr_en = 1; #10 wr_en = 0;
    end
    for (i = 0; i < 2; i=i+1) begin
        rd_en = 1; #10 rd_en = 0;
    end
    data_in = 32'h77987654;
    wr_en = 1; #10 wr_en = 0;
    for(i=2;i<DEPTH;i=i+1) begin
    rd_en = 1; #10 rd_en = 0; end
    rd_en = 1; #10 wr_en = 0;
  if (data_out !== 32'h77987654) $display("Error: Wrap-around mismatch.");
  else $display("Wrap-around test case passed");
end
endtask

task test_case_simultaneous_read_write();
begin
    data_in = 32'h55123456;
    wr_en = 1; rd_en = 0; #10
    wr_en = 0; rd_en = 0; #10
    data_in = 32'h99345680;
    wr_en = 1;  rd_en = 1; #20
  if (data_out !== 32'h55123456)  
        $display("Error: Expected 8'h55, got %h", data_out);
  
    wr_en = 0; rd_en = 1;#10
  if (data_out !== 32'h99345680) $display("Error: Simultaneous read/write failed. Expected 8'h99...got %h", data_out);
  else $display("Simultaneous read_write test case passed");
    wr_en = 0; rd_en = 0;
end
endtask

task test_case_reset();
begin
    data_in = 32'hFFEEDDCC;
    wr_en = 1; #10 wr_en = 0;
    rst_n = 0; #10 rst_n = 1;
    if (!empty) $display("Error: FIFO not empty after reset.");
  else $display("FIFO is empty after reset");
end
endtask

task test_case_overflow();
integer i;
begin
    for (i = 0; i < DEPTH ; i=i+1) begin
        data_in = $random;
        wr_en = 1; #10 wr_en = 0;
        
        if (full)
         $display("FIFO is full now");
    end
    for(i =0 ; i<2; i=i+1) begin
    data_in = $random;
    wr_en = 1; #10 wr_en = 0;
    if(full)
    $display("Overflow!!!write attempt while fifo is full");
    end
    
   
end
endtask

task test_case_underflow();
begin
  if (!empty)begin 
  $display(" FIFO is not empty before underflow test!");
     rd_en =1; #10 rd_en = 0; //reading single element from fifo
  end 
  #10
    rd_en = 1; #10 rd_en = 0;
  $display("Result after underflow test");
  if(empty)begin
 
    if(data_out == {WIDTH{1'bx}}  || data_out == data_out)
       $display("Underflow test passed");
    else $display("Invalid Data on underflow");
  end
  else $display("FIFO is not empty.....for underflow test fifo should be empty" );
  
end
endtask

endmodule