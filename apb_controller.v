module apb_controller(
    input hclk,
    input hresetn,
    input hwrite,
    input hwritereg,
    input valid,
    input [31:0] haddr,
    input [31:0] haddr1,
    input [31:0] haddr2,
    input [31:0] hwdata,
    input [31:0] hwdata1,
    input [31:0] hwdata2,
    input [31:0] prdata,
    input [2:0] tempselx,
    output reg pwrite,
    output reg penable,
    output reg hreadyout,
    output reg [2:0] psel,
    output reg [31:0] paddr,
    output reg [31:0] pwdata
);

// temp signals
reg penable_temp, pwrite_temp, hreadyout_temp;
reg [2:0] psel_temp;
reg [31:0] paddr_temp, pwdata_temp;

// state encoding
parameter idle     = 3'b000,
          read     = 3'b001,
          renable  = 3'b010,
          wwait    = 3'b011,
          write    = 3'b100,
          wenable  = 3'b101,
          writep   = 3'b110,
          wenablep = 3'b111;

reg [2:0] present, next;

// block 1 - present state register
always @(posedge hclk)
begin
    if(!hresetn)
        present <= idle;
    else
        present <= next;
end

// block 2 - next state logic
always @(*)
begin
    next = idle;
    case(present)

    idle:
    begin
        if(valid && hwrite)
            next = wwait;
        else if(valid && !hwrite)
            next = read;
        else
            next = idle;
    end

    read:
        next = renable;

    renable:
    begin
        if(valid && hwrite)
            next = wwait;
        else if(valid && !hwrite)
            next = read;
        else
            next = idle;
    end

    wwait:
    begin
        if(!valid)
            next = write;
        else
            next = writep;
    end

    write:
    begin
        if(!valid)
            next = wenable;
        else
            next = wenablep;
    end

    wenable:
    begin
        if(valid && hwrite)
            next = wwait;
        else if(valid && !hwrite)
            next = read;
        else
            next = idle;
    end

    writep:
        next = wenablep;

    wenablep:
    begin
        if(valid && hwritereg)
            next = writep;
        else if(!valid && hwritereg)
            next = write;
        else
            next = read;
    end

    default: next = idle;

    endcase
end

// block 3 - output temp logic (combinational)
always @(*)
begin
    // defaults to avoid latches
    paddr_temp     = paddr;
    pwdata_temp    = pwdata;
    pwrite_temp    = pwrite;
    psel_temp      = 3'b000;
    penable_temp   = 1'b0;
    hreadyout_temp = 1'b1;

    case(present)

    idle:
    begin
        if(valid && !hwrite)
        begin
            paddr_temp     = haddr;
            pwrite_temp    = hwrite;
            psel_temp      = tempselx;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b0;
        end
        else
        begin
            psel_temp      = 3'b000;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b1;
        end
    end

    read:
    begin
        penable_temp   = 1'b1;
        hreadyout_temp = 1'b1;
        psel_temp      = psel;
    end

    renable:
    begin
        if(valid && !hwrite)
        begin
            paddr_temp     = haddr;
            pwrite_temp    = hwrite;
            psel_temp      = tempselx;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b0;
        end
        else if(valid && hwrite)
        begin
            psel_temp      = 3'b000;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b1;
        end
        else
        begin
            psel_temp      = 3'b000;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b1;
        end
    end

    wwait:
    begin
        paddr_temp     = haddr1;
        pwdata_temp    = hwdata;
        pwrite_temp    = hwrite;
        psel_temp      = tempselx;
        penable_temp   = 1'b0;
        hreadyout_temp = 1'b0;
    end

    write:
    begin
        penable_temp   = 1'b1;
        hreadyout_temp = 1'b1;
        psel_temp      = psel;
    end

    wenable:
    begin
        if(valid && !hwrite)
        begin
            paddr_temp     = haddr;
            pwrite_temp    = hwrite;
            psel_temp      = tempselx;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b0;
        end
        else if(valid && hwrite)
        begin
            paddr_temp     = haddr1;
            pwrite_temp    = hwritereg;
            psel_temp      = tempselx;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b0;
        end
        else
        begin
            psel_temp      = 3'b000;
            penable_temp   = 1'b0;
            hreadyout_temp = 1'b1;
        end
    end

    writep:
    begin
        penable_temp   = 1'b1;
        hreadyout_temp = 1'b1;
        psel_temp      = psel;
    end

    wenablep:
    begin
        paddr_temp     = haddr1;
        pwdata_temp    = hwdata;
        pwrite_temp    = hwrite;
        psel_temp      = tempselx;
        penable_temp   = 1'b0;
        hreadyout_temp = 1'b0;
    end

    default:
    begin
        psel_temp      = 3'b000;
        penable_temp   = 1'b0;
        hreadyout_temp = 1'b1;
    end

    endcase
end

// block 4 - register outputs
always @(posedge hclk)
begin
    if(!hresetn)
    begin
        paddr     <= 32'd0;
        pwdata    <= 32'd0;
        pwrite    <= 1'b0;
        psel      <= 3'b000;
        penable   <= 1'b0;
        hreadyout <= 1'b1;
    end
    else
    begin
        paddr     <= paddr_temp;
        pwdata    <= pwdata_temp;
        pwrite    <= pwrite_temp;
        psel      <= psel_temp;
        penable   <= penable_temp;
        hreadyout <= hreadyout_temp;
    end
end

endmodule
