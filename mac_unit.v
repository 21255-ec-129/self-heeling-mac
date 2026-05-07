module mac_unit #( 
  parameter WIDTH=8
)(
  input clk,
  input rst,
  input [WIDTH-1:0] a,
  input[WIDTH-1:0] b,
  input [2*WIDTH-1:0] c,
  output reg [2*WIDTH-1:0] y
);
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      y<=0;
    end
    else
      y<=(a*b)+c;
  end
endmodule

module mac_arry #(
  parameter N=2,
  parameter WIDTH=8
) (
  input logic clk,
  input logic rst,
  input logic [WIDTH-1:0] a[N][N],
  input logic [WIDTH-1:0] b[N][N],
  input logic [2*WIDTH-1:0] c[N][N],
  output reg[2*WIDTH-1:0]y[N][N]
);
  genvar i,j;
  generate
    for( i=0;i<N;i++)begin
      for(j=0;j<N;j++)begin
        mac_unit#(WIDTH) dut (
          .a(a[i][j]),
          .b(b[i][j]),
          .c(c[i][j]),
          .y(y[i][j])
        );
      end
    end
  endgenerate
endmodule