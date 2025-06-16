`timescale 1ns/1ns
module matmul_tb;

    reg clk;
    reg resetn;
    reg pe_resetn;
    reg start;
    wire done;

    //DUT
    matrix_multiplication u_matmul(
        .clk(clk), 
        .resetn(resetn), 
        .pe_resetn(pe_resetn), 
        .address_mat_a(10'b0),
        .address_mat_b(10'b0),
        .address_mat_c(10'b0),
        .address_stride_a(8'd1),
        .address_stride_b(8'd1),
        .address_stride_c(8'd1),
        .start(start),
	.done(done)
        );
    
    //Clock Generation  
    initial 
    begin
        clk = 0;
        forever 
        begin
            #10 clk = ~clk;
        end
    end
    
    //Reset
    initial 
    begin
        resetn = 0;
        pe_resetn = 0;
        #55;
        resetn = 1;
        pe_resetn = 1;
    end
    
    //Perform test    
    initial 
    begin
        start = 0;
        #115 start = 1;
        @(posedge done);
        start = 0;
        #100;         
 
        $finish;
    end
    

// Sample test case
//  A           B       Output   Output in hex
// 1 1 1 1   1 1 1 1   4 4 4 4    4 4 4 4
// 1 1 1 1   1 1 1 1   4 4 4 4    4 4 4 4
// 1 1 1 1   1 1 1 1   4 4 4 4    4 4 4 4
// 1 1 1 1   1 1 1 1   4 4 4 4    4 4 4 4

//    integer i;
//    
//    initial 
//    begin
//        for (i=0; i<4; i = i + 1) 
//        begin
//            u_matmul.matrix_A.ram[i] = {8'h01, 8'h01, 8'h01, 8'h01};
//            u_matmul.matrix_B.ram[i] = {8'h01, 8'h01, 8'h01, 8'h01};
//        end
//    end
    

//Actual test case
//  A           B        Output       Output in hex
// 8 4 6 8   1 1 3 0   98 90 82 34    62 5A 52 22
// 3 3 3 7   0 1 4 3   75 63 51 26    4B 3F 33 1A
// 5 2 1 6   3 5 3 1   62 48 44 19    3E 30 2C 13
// 9 1 0 5   9 6 3 2   54 40 46 13    36 28 2E 0D


initial begin
   //A is stored in ROW MAJOR format
   //A[0][0] (8'h08) should be the least significant byte of ram[0]
   //The first column of A should be read together. So, it needs to be 
   //placed in the first matrix_A ram location.
   //This is due to Verilog conventions declaring {MSB, ..., LSB}
        u_matmul.matrix_A.ram[3]  = {8'h05, 8'h06, 8'h07, 8'h08}; 
        u_matmul.matrix_A.ram[2]  = {8'h00, 8'h01, 8'h03, 8'h06};
        u_matmul.matrix_A.ram[1]  = {8'h01, 8'h02, 8'h03, 8'h04};
        u_matmul.matrix_A.ram[0]  = {8'h09, 8'h05, 8'h03, 8'h08};

  //B is stored in COL MAJOR format
   //B[0][0] (8'h01) should be the least significant of ram[0]
   //The first row of B should be read together. So, it needs to be 
   //placed in the first matrix_B ram location. 
        u_matmul.matrix_B.ram[3]  = {8'h02, 8'h03, 8'h06, 8'h09};
        u_matmul.matrix_B.ram[2]  = {8'h01, 8'h03, 8'h05, 8'h03};
        u_matmul.matrix_B.ram[1]  = {8'h03, 8'h04, 8'h01, 8'h00};
        u_matmul.matrix_B.ram[0]  = {8'h00, 8'h03, 8'h01, 8'h01};
end

initial begin
	$fsdbDumpvars;
end

endmodule
