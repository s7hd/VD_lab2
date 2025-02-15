module mem_test (input clk, mem_interface mif);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking
logic [7:0] written_data[31:0];  // Array to track the random data written to memory

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
  end

initial begin
	@(negedge mif.clk)
	mif.write<=1;
end


initial
  begin: memtest
  int error_status;
  $display("==================================================");
  $display("                Random Data Test");
  $display("==================================================");

  // Generate and write random data to memory
  for (int i = 0; i < 32; i++) begin
    // Generate random 8-bit data
    written_data[i] = $random;  
    write_mem(i, written_data[i], debug);
  end
  
  // Read back the data and check for correctness
  for (int i = 0; i < 32; i++) begin 
    read_mem(i, rdata, debug);
    // Compare the read data with the written data
    error_status = checkit(i, rdata, written_data[i]);
  end

  printstatus(error_status);  // Print test status (Passed/Failed)
  $display("==================================================");
  $finish;
  end

// Write memory task
task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
  @(negedge clk);
  mif.write <= 1;
  mif.read  <= 0;
  mif.adder <= waddr;
  mif.data_in <= wdata;
  @(negedge clk);
  mif.write <= 0;
  if (debug == 1)
    $display("Write - Address:%d  Data:%h", waddr, wdata);
endtask

// Read memory task
task read_mem (input [4:0] raddr, output [7:0] rdata, input debug = 0);
   @(negedge clk);
   mif.write <= 0;
   mif.read  <= 1;
   mif.adder <= raddr;
   @(negedge clk);
   mif.read <= 0;
   rdata = mif.data_out;
   if (debug == 1) 
     $display("Read  - Address:%d  Data:%h", raddr, rdata);
endtask

// Check function to compare data
function int checkit (input [4:0] address, input [7:0] actual, input [7:0] expected);
  static int error_status;
  if (actual !== expected) begin
    $display("ERROR:  Address:%h  Data:%h  Expected:%h", address, actual, expected);
    error_status++;
  end
  return (error_status);
endfunction: checkit

// Print status of the test
function void printstatus(input int status);
  if (status == 0) begin
    $display("\n");
    $display("                                  _\\|/_");
    $display("                                  (o o)");
    $display(" ______________________________oOO-{_}-OOo______________________________");
    $display("|                                                                       |");
    $display("|                              TEST PASSED                              |");
    $display("|_______________________________________________________________________|");
    $display("\n");
  end
  else begin
    $display("Test Failed with %d Errors", status);
    $display("\n");
    $display("                              _ ._  _ , _ ._");
    $display("                            (_ ' ( `  )_  .__)");
    $display("                          ( (  (    )   `)  ) _)");
    $display("                         (__ (_   (_ . _) _) ,__)");
    $display("                             `~~`\ ' . /`~~`");
    $display("                             ,::: ;   ; :::,");
    $display("                            ':::::::::::::::'");
    $display(" ______________________________/_  \\________________________________");
    $display("|                                                                       |");
    $display("|                              TEST FAILED                              |");
    $display("|_______________________________________________________________________|");
    $display("\n");
  end
endfunction: printstatus

endmodule
