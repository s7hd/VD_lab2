module mem (input clk , mem_interface mif);

// SYSTEMVERILOG: timeunit and timeprecision specification


// SYSTEMVERILOG: logic data type
logic [7:0] memory [0:31] ;
  
  always @(posedge clk)
    if (mif.write && !mif.read)
// SYSTEMVERILOG: time literals
//(for simulation purposes).
      #1 memory[mif.adder] <= mif.data_in;
// SYSTEMVERILOG: always_ff and iff event control
  always_ff @(posedge clk iff ((mif.read == '1)&&(mif.write == '0)) )
       mif.data_out <= memory[mif.adder];

endmodule
