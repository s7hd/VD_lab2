interface mem_interface (input clk);
logic		read; 
logic		write; 
logic [4:0]	adder;
logic [7:0]	data_in;
logic [7:0]	data_out;
modport MEM (input read, input write, input adder, input data_in, output data_out);
modport TEST (output read, output write, output adder, output data_in, input data_out);
//tasks 

//read task

task read_mem (input [4:0] raddr, output [7:0] rdata, input debug = 0);
   @(negedge clk); // changing inputs on the negedge of the clk, so that these inputs are stable at posedge of the clk
                   // design will respond to those inputs on the posedge of the clk
   write <= 0;
   read  <= 1;
   adder  <= raddr;
   @(negedge clk);
   read <= 0;
   rdata = data_out;    // Capturing design responce on the next negedge of the clk
                        // as design responce will be stable there
   if (debug == 1) 
     $display("Read  - Address:%d  Data:%h", raddr, rdata);
endtask


//write task 
task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
  @(negedge clk);
  write <= 1;
  read  <= 0;
  adder  <= waddr;
  data_in  <= wdata;
  @(negedge clk);
  write <= 0;
  if (debug == 1)
    $display("Write - Address:%d  Data:%h", waddr, wdata);
endtask

endinterface