module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;
bit         clk;

always #5 clk = ~clk;

//added/////
mem_interface mem (.clk(clk));
mem mmm (.clk(clk) , .mif(mem));
mem_test TEST (.clk(clk) , .mif(mem));

endmodule
