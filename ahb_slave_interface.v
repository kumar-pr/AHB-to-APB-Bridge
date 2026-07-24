module ahb_slave_interface(
    input hclk,
    input hresetn,
    input hwrite,
    input hreadyin,
    input [31:0] hwdata,
    input [31:0] haddr,
    input [31:0] prdata,
    input [1:0] htrans,
    output wire [31:0] hrdata,
    output reg [31:0] haddr1,
    output reg [31:0] haddr2,
    output reg [31:0] hwdata1,
    output reg [31:0] hwdata2,
    output reg hwritereg,
    output reg hwritereg1,
    output reg valid,
    output reg [2:0] tempselx
);

// address pipeline
always @(posedge hclk)
begin
    if(!hresetn)
    begin
        haddr1 <= 32'd0;
        haddr2 <= 32'd0;
    end
    else
    begin
        haddr1 <= haddr;
        haddr2 <= haddr1;
    end
end

// data pipeline
always @(posedge hclk)
begin
    if(!hresetn)
    begin
        hwdata1 <= 32'd0;
        hwdata2 <= 32'd0;
    end
    else
    begin
        hwdata1 <= hwdata;
        hwdata2 <= hwdata1;
    end
end

// write signal pipeline
always @(posedge hclk)
begin
    if(!hresetn)
    begin
        hwritereg  <= 1'b0;
        hwritereg1 <= 1'b0;
    end
    else
    begin
        hwritereg  <= hwrite;
        hwritereg1 <= hwritereg;
    end
end

// valid signal
always @(*)
begin
    if(hreadyin == 1'b1 &&
       haddr >= 32'h80000000 &&
       haddr <  32'h8C000000 &&
       (htrans == 2'b10 || htrans == 2'b11))
        valid = 1'b1;
    else
        valid = 1'b0;
end

// slave select
always @(*)
begin
    if(haddr >= 32'h80000000 && haddr < 32'h84000000)
        tempselx = 3'b001;
    else if(haddr >= 32'h84000000 && haddr < 32'h88000000)
        tempselx = 3'b010;
    else if(haddr >= 32'h88000000 && haddr < 32'h8C000000)
        tempselx = 3'b100;
    else
        tempselx = 3'b000;
end

assign hrdata = prdata;

endmodule
