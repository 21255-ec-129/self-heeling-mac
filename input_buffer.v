
module input_buffer_fifo #(
  parameter WIDTH=8,
  parameter DEPTH=16
) (
  input logic clk,
  input logic rst,
  input logic [2*WIDTH-1:0]data_in,
  input logic  wr_en,
  input logic rd_en,
  output logic [2*WIDTH-1:0] data_out,
  output logic full,
  output logic empty
);
  reg[2*WIDTH-1:0] men [DEPTH-1:0];
  reg[$clog2(DEPTH)-1:0] wrptr,rdptr;
  reg [$clog2(DEPTH):0] count;
      always@(posedge clk or negedge rst)begin
        if(!rst)begin
          rdptr<=0;
          wrptr<=0;
         // full<=0;
         // empty<=0;
          count<=0;
          data_out<=0;
        end
        else
          begin
            if(wr_en && !full)begin
              men[wrptr]<=data_in;
              wrptr<=wrptr+1;
              count<=count+1;
            end
            if(rd_en && !empty)begin
              data_out<=men[rdptr];
              rdptr<=rdptr+1;
              count<=count-1;
            end
          end
      end
        // status flags
        assign full=(count==DEPTH);
        assign empty=(count==0);
        endmodule