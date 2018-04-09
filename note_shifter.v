module note_shifter(slow_clk, load, enable, data_in, data_out);
    input slow_clk, load, enable;
    input [104:0] data_in;
    output [14:0] data_out;

    reg [104:0] data = 105'd0;
    always @(posedge slow_clk, posedge load) begin
        if (load)
            data <= data_in;
        else if (enable)
            data <= data << 1;
    end

    assign data_out = data[104:90];

endmodule // note_shifter
