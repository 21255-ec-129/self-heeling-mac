module sram_controller #(
  parameter WIDTH=8,
  parameter ADDR_WIDTH=32
) (
  input logic clk,
  input logic rst,
  input logic[2*WIDTH-1:0] sram_data_in,
  input logic[ADDR_WIDTH-1:0] sram_addr,
  input logic sram_rd_en,
  input logic sram_wr_en,
  output logic sram_data_out
);
  reg[WIDTH-1:0] men[(1<<ADDR_WIDTH)-1:0];
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      sram_data_out<=0;
    end
  if(sram_wr_en)begin
    men[sram_addr]<=sram_data_in;
  end
  if(sram_rd_en)begin
    sram_data_out<=men[sram_addr];
  end
  end
endmodule