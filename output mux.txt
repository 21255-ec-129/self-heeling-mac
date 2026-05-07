module output_mux #(
  parameter M_WIDTH=8,
  parameter N=2
) (
  input logic [2*M_WIDTH-1:0] MUX_IN[N],
  input logic [$clog2(N)-1:0] SEL,
  output logic [2*M_WIDTH-1:0] MUX_OUT
);
  assign MUX_OUT=MUX_IN[SEL];
endmodule