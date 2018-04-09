module draw_note(clk, x_in, y_in, c_in, x_out, y_out, c_out);
    input clk;
    input [7:0] x_in;
    input [6:0] y_in;
    input [2:0] c_in;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] c_out;

    reg [3:0] dx = 4'd0;
    always @(posedge clk) begin
        if (dx == 4'd14)
            dx <= 4'd0;
        else
            dx <= dx + 1'd1;
    end

    wire next_row = (dx == 4'd14) ? 1'd1 : 1'd0;

    reg [2:0] dy = 3'd0;
    always @(posedge clk) begin
        if (next_row) begin
            if (dy == 3'd6)
                dy <= 3'd0;
            else
                dy <= dy + 1'd1;
        end
    end

    assign x_out = x_in + dx;
    assign y_out = y_in + dy;
    assign c_out = c_in;

endmodule // draw_note
