// Code your design here
module fsm_healing_mac_fsm_controller #(
  parameter WIDTH=4
) (
  input logic clk,
  input logic rst_n,
  input logic mac_done,
  input logic error_flag,
  input logic heart_beat,
  output logic fsm_error_detected,
  output logic fsm_error_corrected,
  output logic fsm_fault_response,
  output logic fsm_signal_error,
  output logic fsm_fault_status,
  output logic fsm_mac_spare_unit_active,
  output logic fsm_mac_fault_unit_disactive,
  output logic fsm_spare_done,
  output logic fsm_spare_busy,
  output logic fsm_spare_vaild,
  output logic fsm_spare_status
);
  parameter IDLE=3'b00;
  parameter NORMAL=3'b001; 
  parameter FAULT=3'b010;
  parameter RECOVER=3'b011; 
  parameter CORRECTED=3'b100;
  reg [WIDTH-1:0] CURRENT_STATE, NEXT_STATE;
  always@ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    end
    else
      begin 
        case(CURRENT_STATE)
     IDLE :begin
       if(mac_done && heart_beat && !error_flag)begin
          fsm_error_detected<=1'b0;
          fsm_fault_response<=1'b0;
        end
     end
        NORMAL:begin
          if( !heart_beat && error_flag && !mac_done)begin
            fsm_signal_error<=1'b1;
          end
        end
          FAULT:begin
            if(!error_flag && heart_beat && mac_done)begin
              fsm_mac_spare_unit_active<=1'b1;
              fsm_spare_done<=1'b1;
              fsm_spare_vaild<=1'b1;
              fsm_spare_busy<=1'b1;
            end
          end
          RECOVER:begin
            if(
        endcase
      end
  end
    always_comb begin
      NEXT_STATE = CURRENT_STATE;
      fsm_spare_status=1'b0;
      fsm_fault_status=1'b0;
      case (CURRENT_STATE)
        IDLE:begin
          if(mac_done && heart_beat && !error_flag)
            NEXT_STATE=NORMAL;
        end
        NORMAL:begin
          if(!heart_beat && error_flag)
            NEXT_STATE=FAULT;
        end
        FAULT:begin
          if(heart_beat && mac_done && !error_flag)
            NEXT_STATE=RECOVER;
          end
        RECOVER:begin
          if(
      endcase
    end
endmodule
            
          
            
          
         
          
              
        
    
  
  
    
      
    
    
      
      
      
  
  
  
