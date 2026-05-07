// Response Monitor
module response_monitor#(
  parameter WIDTH=8,
  parameter DELAY=3
) (
  input logic clk,
  input logic rst,
  input logic a,b,c,
  input logic [2*WIDTH-1:0] R_data,
  output logic vaild_data,
  output logic ready_data,
  output logic fault_response,
  output logic golden
);
  integer cycle_count;
  always @(posedge clk or negedge rst)begin
    if(!rst)begin
      vaild_data<=0;
      ready_data<=0;
      fault_response<=0;
      golden<=0;
    end
    else
      begin
        golden<=(a*b)+c;
        if(vaild_data)
          cycle_count<=cycle_count+1;
        if(ready_data && vaild_data)begin
          if(R_data != golden)
            fault_response<=0;
            else if(cycle_count<=DELAY)
              fault_response<=0;
          else
            fault_response<=1;
        end
      end
  end
endmodule
  