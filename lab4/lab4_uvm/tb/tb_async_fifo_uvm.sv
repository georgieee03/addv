`timescale 1ns/1ps
module tb_async_fifo_uvm;
  import uvm_pkg::*;
  import fifo_uvm_pkg::*;

  // parameters identical to RTL
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 4;

  // clock + reset
  logic wclk = 0, rclk = 0, rst_n = 0;

  // programmable ratio from +WR_PER_RD
  int WR_PER_RD;
  initial begin
    if(!$value$plusargs("WR_PER_RD=%d", WR_PER_RD)) WR_PER_RD = 1;
  end
  always #5  wclk = ~wclk;                 // base 100 MHz
  always #5*WR_PER_RD rclk = ~rclk;        // variable read clock

  // interfaces
  write_if #(DATA_WIDTH,ADDR_WIDTH) w_if (.clk(wclk), .rst_n(rst_n));
  read_if  #(DATA_WIDTH,ADDR_WIDTH) r_if (.clk(rclk), .rst_n(rst_n));

  // DUT
  async_fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
             dut ( .w_if(w_if), .r_if(r_if) );

  // reset sequence (no run command!)
  initial begin
    rst_n = 0; repeat(4) @(posedge wclk); rst_n = 1;
  end

  // push interfaces into UVM config-db
  initial begin
    uvm_config_db#(virtual write_if #(DATA_WIDTH,ADDR_WIDTH))::set(null,"*","w_vif", w_if);
    uvm_config_db#(virtual read_if  #(DATA_WIDTH,ADDR_WIDTH))::set(null,"*","r_vif", r_if);
  end

  // kick UVM
  initial run_test();  // test selected via +UVM_TESTNAME
endmodule 