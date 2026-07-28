module apb_interface(
    input  pwrite,
    input  penable,
    input  [2:0]  psel,
    input  [31:0] paddr,
    input  [31:0] pwdata,
    output pwrite_out,
    output penable_out,
    output [2:0]  psel_out,
    output [31:0] paddr_out,
    output [31:0] pwdata_out,
    output reg [31:0] prdata
);

assign pwrite_out  = pwrite;
assign penable_out = penable;
assign psel_out    = psel;
assign paddr_out   = paddr;
assign pwdata_out  = pwdata;

// simulate slave returning random read data
always @(*)
begin
    if(!pwrite && penable && (psel != 3'b000))
        prdata = $random % 256;
    else
        prdata = 32'd0;
end

endmodule
