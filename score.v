module assign_score(clk, note, key, score_out);
    input clk, key;
    input [1:0] note;
    output reg [1:0] score_out;

    always @(posedge clk) begin
        if (key) begin
            if (note[1])
                score_out <= 2'b01;
            else if (note[0])
                score_out <= 2'b10;
            else
                score_out <= 2'b00;
        end
        else begin
            if (note[1])
                score_out <= 2'b11;
            else
                score_out <= 2'b00;
        end
    end
    
endmodule // assign_score

module score_counter(clk, resetn, enable, score_in, score_out);
    input clk, resetn, enable;
    input [1:0] score_in;
    output reg [7:0] score_out;

    always @(posedge clk) begin
        if (!resetn)
            score_out <= 8'd0;
        else if (enable) begin
            if (score_in == 2'b01)
                score_out <= score_out + 2'd2;
            else if (score_in == 2'b10)
                score_out <= score_out + 1'd1;
        end
    end

endmodule // score_counter

module combo_counter(clk, resetn, enable, combo_in1, combo_in2, combo_in3, combo_in4, combo_out, max_out);
    input clk, resetn, enable;
    input [1:0] combo_in1, combo_in2, combo_in3, combo_in4;
    output reg [7:0] combo_out, max_out;

    reg note1, note2, note3, note4;
    reg [7:0] combo_1o, combo_2o, combo_3o, combo_4o;

    always @(posedge clk) begin
        if (!resetn) begin
            combo_out <= 8'd0;
            max_out <= 8'd0;
            note1 <= 1'd0;
            note2 <= 1'd0;
            note3 <= 1'd0;
            note4 <= 1'd0;
            combo_1o <= 8'd0;
            combo_2o <= 8'd0;
            combo_3o <= 8'd0;
            combo_4o <= 8'd0;
            end
        else if (enable) begin
            if (combo_in1 != 2'b11)
                note1 <= 1'd1;
            else if (combo_in1 == 2'b11 && note1 == 1'd1) begin
                combo_1o <= 8'd0;
                combo_2o <= 8'd0;
                combo_3o <= 8'd0;
                combo_4o <= 8'd0;
            end
            if (combo_in1 == 2'b01)
                combo_1o <= combo_1o + 1'd1;

            if (combo_in2 != 2'b11)
                note2 <= 1'd1;
            else if (combo_in2 == 2'b11 && note2 == 1'd1) begin
                combo_1o <= 8'd0;
                combo_2o <= 8'd0;
                combo_3o <= 8'd0;
                combo_4o <= 8'd0;
                end
            if (combo_in2 == 2'b01)
                combo_2o <= combo_2o + 1'd1;

            if (combo_in3 != 2'b11)
                note3 <= 1'd1;
            else if (combo_in3 == 2'b11 && note3 == 1'd1) begin
                combo_1o <= 8'd0;
                combo_2o <= 8'd0;
                combo_3o <= 8'd0;
                combo_4o <= 8'd0;
                end
            if (combo_in3 == 2'b01)
                combo_3o <= combo_3o + 1'd1;

            if (combo_in4 != 2'b11)
                note4 <= 1'd1;
            else if (combo_in4 == 2'b11 && note4 == 1'd1) begin
                combo_1o <= 8'd0;
                combo_2o <= 8'd0;
                combo_3o <= 8'd0;
                combo_4o <= 8'd0;
                end
            if (combo_in4 == 2'b01)
                combo_4o <= combo_4o + 1'd1;

            combo_out <= combo_1o + combo_2o + combo_3o + combo_4o;

            if (combo_out > max_out)
                max_out <= combo_out;
            end
    end

endmodule // combo_counter
