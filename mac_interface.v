interface mac_if#(parameter WIDTH=8, parameter N=2);
      logic clk;
      logic rst;
  logic [WIDTH-1:0] a[N][N];
  logic [WIDTH-1:0] b[N][N];
  logic [2*WIDTH-1:0] c[N][N];
  logic [2*WIDTH-1:0] y[N][N];
   endinterface