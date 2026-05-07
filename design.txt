// Code your design here
// Code your design here
// Simple MAC (Multiply-Accumulate) Unit

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
       //WEIGTH BUFFERS FIFO       
   module weight_buffer_fifo #(
  parameter WIDTH=8,
  parameter DEPTH=16
) (
  input logic clk,
  input logic rst,
     input logic [2*WIDTH-1:0]weight_data_in,
  input logic wr_en,
  input logic rd_en,
     output logic [2*WIDTH-1:0] weight_data_out,
  output logic full,
  output logic empty
);
     reg[2*WIDTH-1:0] men [DEPTH-1:0];
     reg[$clog2(DEPTH)-1:0] wrptr,rdptr;
         reg[$clog2(DEPTH):0] count;
      always@(posedge clk or negedge rst)begin
        if(!rst)begin
          rdptr<=0;
          wrptr<=0;
         // full<=0;
         // empty<=0;
          count<=0;
          weight_data_out<=0;
        end
        else
          begin
            if(wr_en && !full)begin
              men[wrptr]<=weight_data_in;
              wrptr<=wrptr+1;
              count<=count+1;
            end
            if(rd_en && !empty)begin
              weight_data_out<=men[rdptr];
              rdptr<=rdptr+1;
              count<=count-1;
            end
          end
      end
        // status flags
        assign full=(count==DEPTH);
        assign empty=(count==0);
        endmodule
                     
  
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
  
// FAULT DETECTION UNIT
// encoder
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
 

//mac_unity-interface
interface mac_if#(parameter WIDTH=8, parameter N=2);
      logic clk;
      logic rst;
  logic [WIDTH-1:0] a[N][N];
  logic [WIDTH-1:0] b[N][N];
  logic [2*WIDTH-1:0] c[N][N];
  logic [2*WIDTH-1:0] y[N][N];
  logic error_detected;
  logic ready_data;
  logic fault_response;
  logic golden;
  logic vaild_data;
  logic fault_error;
  logic signal_error;
endinterface
