module encoder #(
  parameter WIDTH =8
) (
  input logic clk,
  input logic rst,
  input logic [2*WIDTH-1:0] data_in,
  input logic [11:0] code_in,
  output logic [11:0]code_out
);
  // encodering
  logic p1, p2, p4, p8;
  // map data bits into codeword positions
  assign code_out[2]=data_in[0];//postion3-1-0001 9-1001
  assign code_out[4]=data_in[1];//postion5-2-0010 10-1010
  assign code_out[5]=data_in[2];//postion6-3-0011 11-1011
  assign code_out[6]=data_in[3];//postion7-4-0100 12-1100
  assign code_out[8]=data_in[4];//postion 9-5-0101
  assign code_out[9]=data_in[5];//postion 10-6-0110
  assign code_out[10]=data_in[6];//postion 11-7-01110
  assign code_out[11]=data_in[7];//postion 12-8-1000
  //Parity bit genertor
  assign p1=code_out[2]^code_out[4]^code_out[6]^code_out[8]^code_out[10];
  assign p2=code_out[2]^code_out[5]^code_out[6]^code_out[9]^code_out[10];
  assign p4=code_out[4]^code_out[5]^code_out[6]^code_out[11];
  assign p8=code_out[8]^code_out[9]^code_out[10]^code_out[11];
  // Parity bits to  code_word
  assign code_out[0]=p1;
  assign code_out[1]=p2;
  assign code_out[3]=p4;
  assign code_out[7]=p8;
endmodule
  // decoder
  module decoder #(
    parameter WIDTH=8
  ) (
  input logic clk,
  input logic rst,
  input logic [2*WIDTH-1:0] data_in,
  input logic [11:0] code_in,
  output logic error_detected,
  output logic error_corrected,
  output logic [11:0] corrected
  );
  logic s1, s2, s3, s4;
  logic [3:0] syndrome;
    assign s1=code_in[0]^code_in[2]^code_in[4]^code_in[6]^code_in[8]^code_in[10];
    assign s2=code_in[1]^code_in[2]^code_in[5]^code_in[6]^code_in[9]^code_in[10];
    assign s3=code_in[3]^code_in[4]^code_in[5]^code_in[6]^code_in[11];
    assign s4=code_in[7]^code_in[8]^code_in[9]^code_in[10]^code_in[11];
  assign syndrome={ s1,s2,s3,s4};
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      corrected<=0;
      error_detected<=0;
      error_corrected<=0;
    end
      else
        corrected<=data_in;
    if(syndrome!=0)begin
      corrected[syndrome-1]=~corrected[syndrome-1];
      error_detected=1;
      error_corrected=1;
    end
      else
        error_detected=0;
      error_corrected=0;
    end
endmodule
      