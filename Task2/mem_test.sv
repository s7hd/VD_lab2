module mem_test (input clk , mem_interface mif);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

////added//////////


initial begin
	@(negedge mif.clk)
	mif.write<=1;
end


initial
  begin: memtest
  int error_status;
    $display("==================================================");
    $display("                Clear Memory Test");
    $display("==================================================");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
       write_mem (i, 0, debug);
    for (int i = 0; i<32; i++)
      begin 
       read_mem (i, rdata, debug);
       // check each memory location for data = 'h00
       error_status = checkit (i, rdata, 8'h00);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);
    $display("==================================================");
    $display("             Data = Address Test");
    $display("==================================================");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
       write_mem (i, i, debug);
    for (int i = 0; i<32; i++)
      begin
       read_mem (i, rdata, debug);
       // check each memory location for data = address
       error_status = checkit (i, rdata, i);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);

    $finish;
  end

// SYSTEMVERILOG: default task input argument values
task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
  @(negedge clk);
  mif.write <= 1;
  mif.read  <= 0;
  mif.adder  <= waddr;
  mif.data_in  <= wdata;
  @(negedge clk);
  mif.write <= 0;
  if (debug == 1)
    $display("Write - Address:%d  Data:%h", waddr, wdata);
endtask

// SYSTEMVERILOG: default task input argument values
task read_mem (input [4:0] raddr, output [7:0] rdata, input debug = 0);
   @(negedge clk); // changing inputs on the negedge of the clk, so that these inputs are stable at posedge of the clk
                   // design will respond to those inputs on the posedge of the clk
   mif.write <= 0;
   mif.read  <= 1;
   mif.adder  <= raddr;
   @(negedge clk);
   mif.read <= 0;
   rdata = mif.data_out;    // Capturing design responce on the next negedge of the clk
                        // as design responce will be stable there
   if (debug == 1) 
     $display("Read  - Address:%d  Data:%h", raddr, rdata);
endtask

function int checkit (input [4:0] address,
                      input [7:0] actual, expected);
  static int error_status;   // static variable
  if (actual !== expected) begin
    $display("ERROR:  Address:%h  Data:%h  Expected:%h",
                address, actual, expected);
// SYSTEMVERILOG: post-increment
     error_status++;
   end
// SYSTEMVERILOG: function return
   return (error_status);
endfunction: checkit


// SYSTEMVERILOG: void function
function void printstatus(input int status);
if (status == 0)
begin
    $display("\n");
    $display("                                  _\\|/_");
    $display("                                  (o o)");
    $display(" ______________________________oOO-{_}-OOo______________________________");
    $display("|                                                                       |");
    $display("|                              TEST PASSED                              |");
    $display("|_______________________________________________________________________|");
    $display("\n");
end
else
begin
    $display("Test Failed with %d Errors", status);
    $display("\n");
    $display("                              _ ._  _ , _ ._");
    $display("                            (_ ' ( `  )_  .__)");
    $display("                          ( (  (    )   `)  ) _)");
    $display("                         (__ (_   (_ . _) _) ,__)");
    $display("                             `~~`\ ' . /`~~`");
    $display("                             ,::: ;   ; :::,");
    $display("                            ':::::::::::::::'");
    $display(" ______________________________/_  \________________________________");
    $display("|                                                                       |");
    $display("|                              TEST FAILED                              |");
    $display("|_______________________________________________________________________|");
    $display("\n");
end
endfunction : printstatus

endmodule