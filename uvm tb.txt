// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;
class my_trans extends uvm_sequence_item;
  localparam N=2;
  localparam WIDTH=8;
  rand logic [7:0] a[N*N];
  rand logic [7:0] b[N*N];
  logic [15:0] c[N*N];
  logic [15:0] y[N*N];
  logic error_detected;
  logic ready_data;
  logic fault_response;
  logic golden;
  logic vaild_data;
  logic fault_error;
  logic signal_error;
  // constraints
  constraint non_zero_inputs{
    foreach(a[k]) a[k]   inside {[1:20]};
    foreach (b[k]) b[k] inside {[1:20]};
  }
  `uvm_object_utils_begin(my_trans)
  `uvm_field_sarray_int(a,UVM_DEFAULT)
  `uvm_field_sarray_int(b,UVM_DEFAULT)
  `uvm_field_sarray_int(c,UVM_DEFAULT)
  `uvm_field_sarray_int(y,UVM_DEFAULT)
  `uvm_object_utils_end
  function new (string path = "my_trans");
    super.new(path);
  endfunction
endclass
class my_gen extends uvm_sequence#(my_trans);
  `uvm_object_utils(my_gen)
  my_trans tg;
  function new(string path ="my_gen");
    super.new(path);
  endfunction
  virtual task body();
    repeat(10)begin
tg=my_trans::type_id::create("tg");
      start_item(tg);
      tg.randomize();
      finish_item(tg);
      `uvm_info("my_gen",$sformatf("Data is send to driver a=%0d,b=%0d",tg.a,tg.b),UVM_NONE);
    end
  endtask
endclass
  
class my_driver extends uvm_driver#(my_trans);
  `uvm_component_utils(my_driver)
  virtual mac_if aif;
  my_trans td; 
  function new(string path = "my_driver", uvm_component parent);
    super.new(path,parent);
  endfunction
  task reset_dut();
    foreach(aif.a[i,j])
    aif.rst<=1'b1;
    aif.a[i][j]<=0;
    aif.b[i][j]<=0;
    aif.c[i][j]<=0;
    repeat(10) @(posedge aif.clk);
    aif.rst<=1'b0;
    perv_y<=0;
  endtask
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    td=my_trans::type_id::create("td",this);
    if(!uvm_config_db#(virtual mac_if)::get(this,"","aif",aif))
      `uvm_error("my_driver","unable to access");
  endfunction
  bit[2*8-1:0] perv_y[2][2];
  int i,j;
  virtual task run_phase(uvm_phase phase);
    reset_dut();
    forever begin
      seq_item_port.get_next_item(td);
      int i=k/N;
      int j=k%N;
      foreach(td.k)
      aif.a[i][j]<=td.a[k];
      aif.b[i][j]<=td.b[k];
      aif.c[i][j]<=td,c[k];
      aif.error_detected=td.error_detected;
      aif.fault_response=td.fault_response;
      aif.vaild_data_response=td.vaild_data;
      aif.fault_error=td.fault_error;
      aif.signal_error=td.signal_error;
      seq_item_port.item_done();
      @(posedge aif.clk);
      @(posedge aif.clk);
      int i=k/N;
      int j=k%N;
      perv_y[i][j]<=aif.y[k];
      `uvm_info("my_driver",$sformatf("Trigger DUT a=%0d,b=%0d,c=%0d,y=%0d",td.a,td.b,perv_y,aif.y),UVM_NONE);
    end
  endtask
endclass
class my_mon extends uvm_component;
  `uvm_component_utils(my_mon)
  uvm_analysis_port#(my_trans) send;
  virtual mac_if aif;
  my_trans tm;
  function new(string path ="my_mon",uvm_component parent);
    super.new( path,parent);
    send=new("send",this);
  endfunction
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    tm=my_trans::type_id::create("tm",this);
    if(!uvm_config_db#(virtual mac_if)::get(this,"","aif",aif))
    `uvm_error("my_mon","unable to access")
  endfunction
  virtual task run_phase(uvm_phase phase);
    int i,j;
    int i=K/N;
    int j=K%N;
    @(posedge aif.rst);
    forever begin
      repeat(2)@(posedge aif.clk);
      foreach(td.k)
      tm.a[k]=aif.a[i][j];
      tm.b[k]=aif.b[i][j];
      tm.c[k]=aif.c[i][j];
      tm.y[k]=aif.y[i][j];
      tm.error_detected=aif.error_detected;
      tm.fault_response=aif.fault_response;
      tm.vaild_data_response=aif.vaild_data;
      tm.fault_error=aif.fault_error;
      tm.signal_error=aif.signal_error;
      
      `uvm_info("my_mon",$sformatf("Trigger DUT a=%0d,b=%0d,c=%0d,y=%0d",tm.a,tm.b,tm.c,tm.y),UVM_NONE);
      send.write(tm);
    end
  endtask
endclass

class my_score extends uvm_component;
  `uvm_component_utils(my_score)
  uvm_analysis_imp#(my_trans,my_score) rec;
  my_trans ts;
  function new(string path="my_score",uvm_component parent);
    super.new(path,parent);
    rec=new("rec",this);
  endfunction
  bit[15:0] expected;
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    expected=0;
    ts=my_trans::type_id::create("ts",this);
  endfunction
  virtual function void write(my_trans t);
    int i=k/N;
    int j=k%N;
    foreach(ts.k)
      expected =((ts.a[k]*ts.b[k])+ts.c[k]);
    if(ts.y!=expected)begin
      `uvm_info("my_score",$sformatf("Mismatch got  [%0d %0d], expected %0d",k,t.y[k],expected),UVM_NONE)
    end
    else
      `uvm_info("my_score",$sformatf("Match got %0d, expected %0d",t.y,expected),UVM_NONE)
      ts=t;
                endfunction
endclass
class my_agent extends uvm_component;
  `uvm_component_utils(my_agent)
  my_mon m;
  my_driver d;
  uvm_sequencer#(my_trans) seq;
  function new(string path="my_agent",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    m=my_mon::type_id::create("m",this);
    d=my_driver::type_id::create("d",this);
    seq=uvm_sequencer#(my_trans)::type_id::create("seq",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class my_env extends uvm_component;
  `uvm_component_utils(my_env)
  my_agent a;
  my_score s;
  function new (string path="my_env",uvm_component parent);
    super.new(path,parent);
  endfunction
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    a=my_agent::type_id::create("a",this);
    s=my_score::type_id::create("s",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.rec);
  endfunction
endclass

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  my_env e;
  my_gen g;
  function new(string path ="my_test",uvm_component parent);
    super.new(path,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=my_env::type_id::create("e",this);
    g=my_gen::type_id::create("g");
  endfunction
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    g.start(e.a.seq);
    #100;
    phase.drop_objection(this);
  endtask
endclass
module tb;
  logic clk;
  initial clk=0;
  always #5 clk=~clk;
  mac_if aif(clk);
  mac_arry#(2,8) dut(
    .a(aif.a),
    .b(aif.b),
    .c(aif.c),
    .y(aif.y),
    .clk(aif.clk),
    .rst(aif.rst)
  );
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb);
    uvm_config_db#(virtual mac_if)::set(null,"*","aif",aif);
    run_test("my_test");
  end
endmodule