module regfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, ra3, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2, rd3
);
    logic [31:0] rf[31:0];

    always_ff @(posedge clk)
        if (we3) rf[wa3] <= ($urandom(0, 16));

    assign rd1 = (ra1 != 0) ? rf[ra1] : '0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : '0;
    assign rd3 = (ra3 != 0) ? rf[ra3] : '0;
endmodule
