module bridge_top(
    input hclk,
    input hresetn,
    input hwrite,
    input hreadyin,
    input [1:0]  htrans,
    input [31:0] hwdata,
    input [31:0] haddr,
    input [31:0] prdata,
    output penable,
    output pwrite,
    output hreadyout,
    output [2:0]  psel,
    output [1:0]  hresp,
    output [31:0] paddr,
    output [31:0] pwdata,
    output [31:0] hrdata
);

wire [31:0] hwdata1, hwdata2;
wire [31:0] haddr1,  haddr2;
wire [2:0]  tempselx;
wire hwritereg, hwritereg1;
wire valid;

ahb_slave_interface A1(
    .hclk      (hclk),
    .hresetn   (hresetn),
    .hwrite    (hwrite),
    .hreadyin  (hreadyin),
    .hwdata    (hwdata),
    .haddr     (haddr),
    .prdata    (prdata),
    .htrans    (htrans),
    .hrdata    (hrdata),
    .haddr1    (haddr1),
    .haddr2    (haddr2),
    .hwdata1   (hwdata1),
    .hwdata2   (hwdata2),
    .hwritereg (hwritereg),
    .hwritereg1(hwritereg1),
    .valid     (valid),
    .tempselx  (tempselx)
);

apb_controller A2(
    .hclk      (hclk),
    .hresetn   (hresetn),
    .hwrite    (hwrite),
    .hwritereg (hwritereg),
    .valid     (valid),
    .haddr     (haddr),
    .haddr1    (haddr1),
    .haddr2    (haddr2),
    .hwdata    (hwdata),
    .hwdata1   (hwdata1),
    .hwdata2   (hwdata2),
    .prdata    (prdata),
    .tempselx  (tempselx),
    .pwrite    (pwrite),
    .penable   (penable),
    .hreadyout (hreadyout),
    .psel      (psel),
    .paddr     (paddr),
    .pwdata    (pwdata)
);

assign hresp = 2'b00;

endmodule
