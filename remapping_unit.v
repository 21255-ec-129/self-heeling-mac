//MAPPING UNIT
module remapping_unit #(
  parameter WIDTH=8,
  parameter N=2,
  parameter ADDRESS=32
) (
  input logic clk,
  input logic rst,
 input logic  mac_done,
 input logic  fault_signal,
 input logic  heart_beat,
  input logic [3:0]row_id,
  input logic [3:0]col_id,
  output logic spare_mac_unit_active,
  output logic fault_mac_unit_disactive,
  output logic [ADDRESS-1:0]fault_mac_unit_location
);
    reg [N-1:0] remap_table [0:N-1];
    integer i;
  initial begin
    for( i=0; i<N;i++)begin
      remap_table[i]=i;
    end
      remap_table[2]=N-1;
      remap_table[3]=N-1;
    end
  
        always@(posedge clk or negedge rst)begin
    if(!rst)begin
      fault_mac_unit_location<=0;
      fault_mac_unit_disactive<=0;
      spare_mac_unit_active<=0;
    end
    else begin
      if(fault_signal && heart_beat && !mac_done)begin
        fault_mac_unit_location<={row_id,col_id};
        fault_mac_unit_disactive<=1'b1;
        spare_mac_unit_active<=remap_table[{row_id , col_id}];
       // spare_mac_unit_active<=1'b1;

      end
    end
  end
endmodule
        
        
        
      //MAPPING UNIT
module remapping_unit #(
  parameter WIDTH=8,
  parameter N=4,
  parameter ADDRESS=32
) (
  input logic clk,
  input logic rst,
 input logic  mac_done,
 input logic  fault_signal,
 input logic  heart_beat,
  input logic [3:0]row_id,
  input logic [3:0]col_id,
  output logic spare_mac_unit_active,
  output logic fault_mac_unit_disactive,
  output logic [ADDRESS-1:0]fault_mac_unit_location
);
    reg [N-1:0] remap_table [0:N-1];
    integer i;
  initial begin
    for( i=0; i<N;i++)begin
      remap_table[i]=i;
    end
      remap_table[2]=N-1;
      remap_table[3]=N-1;
    end
  
        always@(posedge clk or negedge rst)begin
    if(!rst)begin
      fault_mac_unit_location<=0;
      fault_mac_unit_disactive<=0;
      spare_mac_unit_active<=0;
    end
    else begin
      if(fault_signal && heart_beat && !mac_done)begin
        fault_mac_unit_location<={row_id,col_id};
        fault_mac_unit_disactive<=1'b1;
       // spare_mac_unit_active_address<=remap_table[{row_id , col_id}];
        spare_mac_unit_active<=1'b1;

      end
    end
  end
endmodule
        
module spare_mac_unit #(
  parameter WIDTH=8,
  parameter S_ADDRESS=32,
  parameter N=2
) (
  input s_clk,
  input s_rst,
  input logic[N-1:0]a_spare,
  input logic[N-1:0]b_spare,
  input logic[N-1:0] c_spare,
  output logic[N-1:0] y_spare,mac_unit,
  input logic spare_active,
  input logic [ADDRESS-1:0]fault_locations_address,
  output logic[ADDRESS-1:0]spare_mac_address,
  output logic spare_done,
  output logic spare_busy,
  output logic spare_vaild
);
  always@(posedge s_clk or negedge s_rst)begin
    if(!s_rst)begin
      y_spare<=1'b0;
      mac_result<=1'b0;
      spare_mac_address<=1'b0;
      spare_busy<=1'b0;
      spare_done<=1'b0;
      spare_vaild<=1'b0;
      else if(spare_active)
        spare_busy<=1'b1;
      mac_result<=((a_spare*b_spare)+c_spare);
      y_spare<=mac_result;
      spare_mac_address<=fault_location_address;
      spare_done<=1'b1;
      spare_vaild<=1'b1;
      spare_busy<=1'b0;
      else
      spare_busy<=1'b0;
      spare_done<=1'b0;
      spare_vaild<=1'b0;
    end
  end
endmodule
module s_mac_array #(
  parameter WIDTH=8,
  parameter N=2
) (
  input logic [WIDTH-1:0]a_spare[N][N],
  input logic [WIDTH-1:0]b_spare[N][N],
  input logic [WIDTH-1:0]c_spare[N][N],
  output logic [WIDTH-1:0]y_spare[N][N]
);
  genvar row_id,col_id;
  generate 
    for(int row_id=0;row_id<N;row_id++)begin
      for(int col_id=0;col_id<N;col_id++)begin
        spare_mac_unit#(WIDTH) dut(
          .a_spare(a_spare[row_id][col_id]),
          .b_spare(b_spare[row_id][col_id]),
          .c_spare(c_spare[row_id][col_id]),
          .y_spare(y_spare[row_id][col_id])
        );
      end
    end
  endgenerate
endmodule

     
  
  
  
  
  
 
        
      