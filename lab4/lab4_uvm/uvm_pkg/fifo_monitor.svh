class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  // virtual interface comes from config-db
  virtual write_if #(8,4) w_vif;
  virtual read_if  #(8,4) r_vif;

  uvm_analysis_port #(fifo_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    m_cg = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual write_if#(8,4))::get(this,"","w_vif", w_vif))
      `uvm_fatal("NOVIF","Write interface not set")
    if(!uvm_config_db#(virtual read_if#(8,4))::get(this,"","r_vif", r_vif))
      `uvm_fatal("NOVIF","Read interface not set")
  endfunction

  // -------------------------------------------------------------------------
  //  FIFO functional coverage – addresses, pointers, flags, depth
  // -------------------------------------------------------------------------
  covergroup fifo_cg_t;

    // Write / read address coverage (lower 4 bits)
    cp_waddr : coverpoint w_vif.addr[3:0] { bins all_addr[] = {[0:15]}; }
    cp_raddr : coverpoint r_vif.addr[3:0] { bins all_addr[] = {[0:15]}; }
    cross_addr : cross cp_waddr, cp_raddr;

    // Gray pointer coverage (ptr assumed gray-coded)
    cp_wptr_gray : coverpoint w_vif.ptr     { bins all[] = {[0:31]}; }
    cp_rptr_gray : coverpoint r_vif.ptr     { bins all[] = {[0:31]}; }
    cross_gray : cross cp_wptr_gray, cp_rptr_gray;

    // Depth / flag coverage (kept from original)
    cp_depth  : coverpoint (w_vif.full  ? 16 :
                             r_vif.empty ? 0  :
                             8 ) { bins empty = {0};
                                   bins mid[] = {[1:15]};
                                   bins full  = {16}; }
    cp_flags  : coverpoint {w_vif.full, r_vif.empty};
    cross_depth_flags : cross cp_depth, cp_flags;

    // Flag vs address corner cases
    cp_full_flag  : coverpoint w_vif.full         { bins off = {0}; bins on = {1}; }
    cp_af_flag    : coverpoint w_vif.almost_full  { bins off = {0}; bins on = {1}; }
    full_x_addr   : cross cp_full_flag, cp_waddr;
    af_x_addr     : cross cp_af_flag,  cp_waddr;

    cp_empty_flag : coverpoint r_vif.empty        { bins off = {0}; bins on = {1}; }
    cp_ae_flag    : coverpoint r_vif.almost_empty { bins off = {0}; bins on = {1}; }
    empty_x_addr  : cross cp_empty_flag, cp_raddr;
    ae_x_addr     : cross cp_ae_flag,    cp_raddr;

  endgroup : fifo_cg_t;

  fifo_cg_t m_cg;

  task run_phase(uvm_phase phase);
    fifo_seq_item txn;
    forever begin
      // --- write side ------------------------------------------------------
      @(posedge w_vif.clk);
      if (w_vif.en && !w_vif.full) begin
        txn = fifo_seq_item::type_id::create("txn");
        txn.is_write = 1;
        txn.data     = w_vif.data;
        txn.timestamp= $time;
        ap.write(txn);
        m_cg.sample();
      end

      // --- read side -------------------------------------------------------
      @(posedge r_vif.clk);
      if (r_vif.en && !r_vif.empty) begin
        txn = fifo_seq_item::type_id::create("txn");
        txn.is_write = 0;
        txn.data     = r_vif.data;
        txn.timestamp= $time;
        ap.write(txn);
        m_cg.sample();
      end
    end
  endtask
endclass 