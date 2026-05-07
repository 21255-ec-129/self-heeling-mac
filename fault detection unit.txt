//Fault_logic Detections
module fault_detection (
  input logic rst,
  input logic clk,
 input logic r_fault_response,
  input logic m_error_detected,
  output logic fault_status,
  output logic signal_error
);
  always@(posedge clk or negedge rst) begin
    if(!rst)begin
      fault_status<=0;
      signal_error<=0;
    end
    else
      begin
        if(r_fault_response)
          signal_error<=1;
          else if(m_error_detected)
            fault_status<=1;
            else
              signal_error<=0;
             fault_status<=0;
      end
  end
endmodule