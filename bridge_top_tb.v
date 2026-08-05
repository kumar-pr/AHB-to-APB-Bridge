module bridge_top_tb();

reg hclk;
reg hresetn;

wire [31:0] haddr, hwdata, hrdata;
wire [31:0] paddr, pwdata, prdata;
wire [31:0] paddr_out, pwdata_out;
wire hwrite, hreadyin;
wire [1:0] htrans, hresp;
wire penable, pwrite, hreadyout;
wire pwrite_out, penable_out;
wire [2:0] psel, psel_out;

initial hclk = 0;
always #10 hclk = ~hclk;

ahb_master ahb(
    .hclk     (hclk),
    .hresetn  (hresetn),
    .hreadyout(hreadyout),
    .hrdata   (hrdata),
    .hresp    (hresp),
    .hwrite   (hwrite),
    .hreadyin (hreadyin),
    .haddr    (haddr),
    .hwdata   (hwdata),
    .htrans   (htrans)
);

bridge_top BRIDGE(
    .hclk     (hclk),
    .hresetn  (hresetn),
    .hwrite   (hwrite),
    .hreadyin (hreadyin),
    .htrans   (htrans),
    .hwdata   (hwdata),
    .haddr    (haddr),
    .prdata   (prdata),
    .penable  (penable),
    .pwrite   (pwrite),
    .hreadyout(hreadyout),
    .psel     (psel),
    .hresp    (hresp),
    .paddr    (paddr),
    .pwdata   (pwdata),
    .hrdata   (hrdata)
);

apb_interface APB(
    .pwrite     (pwrite),
    .penable    (penable),
    .psel       (psel),
    .paddr      (paddr),
    .pwdata     (pwdata),
    .pwrite_out (pwrite_out),
    .penable_out(penable_out),
    .psel_out   (psel_out),
    .paddr_out  (paddr_out),
    .pwdata_out (pwdata_out),
    .prdata     (prdata)
);

task reset;
begin
    hresetn = 1'b0;
    @(negedge hclk);
    @(negedge hclk);
    hresetn = 1'b1;
end
endtask

initial
begin
    reset;
    #20;
    
    ahb.single_write;
    #40;
    
    ahb.single_read;
    #40;
    
    ahb.burst_incr4_write;
    #40;
    
    ahb.burst_incr4_read;
    #40;
    
    $finish;
end

initial
begin
    $dumpfile("ahb_apb_bridge.vcd");
    $dumpvars(0, bridge_top_tb);
end

endmodule
