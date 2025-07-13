class fifo_write_seq extends uvm_sequence #(fifo_seq_item);
  rand int unsigned burst_len;
  constraint c1 { burst_len inside {[1:32]}; }

  `uvm_object_utils(fifo_write_seq)

  // -------------------------------------------------------------
  //  Local cover-group to capture every randomized burst length
  // -------------------------------------------------------------
  covergroup g_burst;
    cp_burst_len : coverpoint burst_len { bins len[] = {[1:32]}; }
  endgroup

  task body();
    fifo_seq_item item;
    g_burst.sample();
    repeat (burst_len) begin
      `uvm_create(item)
      item.is_write = 1;
      assert(item.randomize() with { data dist {0  :=1, 255 :=1, [1:254]:=98}; });
      `uvm_send(item)
    end
  endtask
endclass 