module rate_divider(clk, resetn, rate_in, q);
    input clk, resetn;
    input [27:0] rate_in;
    output q;

    reg [27:0] rate;
    always @(posedge clk) begin
        if (!resetn)
            rate <= rate_in;
        else begin
            if (rate == 28'd0)
                rate <= rate_in;
            else
                rate <= rate - 1'd1;
        end
    end

    assign q = (rate == 28'd0) ? 1'd1 : 1'd0;

endmodule // rate_divider
