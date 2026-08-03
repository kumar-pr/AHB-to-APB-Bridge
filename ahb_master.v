module ahb_master(
    input  hclk,
    input  hresetn,
    input  hreadyout,
    input  [31:0] hrdata,
    input  [1:0]  hresp,
    output reg hwrite,
    output reg hreadyin,
    output reg [31:0] haddr,
    output reg [31:0] hwdata,
    output reg [1:0]  htrans
);

reg [2:0] hburst, hsize;
integer i;

task single_write;
begin
    @(posedge hclk) #1;
    hwrite   = 1'b1;
    htrans   = 2'd2;
    hsize    = 3'd0;
    hburst   = 3'd0;
    hreadyin = 1'b1;
    haddr    = 32'h8400_0000;

    @(posedge hclk) #1;
    hwdata = 32'h0000_0029;
    htrans = 2'd0;

    @(posedge hclk) #1;
end
endtask

task single_read;
begin
    @(posedge hclk) #1;
    hwrite   = 1'b0;
    htrans   = 2'd2;
    hsize    = 3'd0;
    hburst   = 3'd0;
    hreadyin = 1'b1;
    haddr    = 32'h8400_0000;

    @(posedge hclk) #1;
    htrans = 2'd0;

    @(posedge hclk) #1;
end
endtask

task burst_incr4_write;
begin
    @(posedge hclk) #1;
    hwrite   = 1'b1;
    htrans   = 2'd2;
    hsize    = 3'd0;
    hburst   = 3'd1;
    hreadyin = 1'b1;
    haddr    = 32'h8400_0000;
    hwdata   = 32'd0;

    for(i = 0; i < 3; i = i + 1)
    begin
        @(posedge hclk) #1;
        haddr  = haddr + 4;
        hwdata = $random % 256;
        htrans = 2'd3;
    end

    @(posedge hclk) #1;
    hwdata = $random % 256;
    htrans = 2'd0;

    @(posedge hclk) #1;
end
endtask

task burst_incr4_read;
begin
    @(posedge hclk) #1;
    hwrite   = 1'b0;
    htrans   = 2'd2;
    hsize    = 3'd0;
    hburst   = 3'd1;
    hreadyin = 1'b1;
    haddr    = 32'h8400_0000;

    for(i = 0; i < 3; i = i + 1)
    begin
        @(posedge hclk) #1;
        haddr  = haddr + 4;
        htrans = 2'd3;
    end

    @(posedge hclk) #1;
    htrans = 2'd0;

    @(posedge hclk) #1;
end
endtask

endmodule
