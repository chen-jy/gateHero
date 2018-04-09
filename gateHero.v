// 2018-04-02
module gateHero(CLOCK_50, KEY, SW, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N,
    VGA_SYNC_N, VGA_R, VGA_G, VGA_B, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    PS2_CLK, PS2_DAT);

    input CLOCK_50;
    input [9:0] SW;
    input [3:0] KEY;

    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    output [9:0] VGA_R, VGA_G, VGA_B, LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    inout PS2_CLK, PS2_DAT;

    wire resetn, start;
    assign resetn = KEY[0];
    assign start = ~KEY[3];

    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;

    vga_adapter VGA(
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(colour),
        .x(x),
        .y(y),
        .plot(writeEn),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK_N),
        .VGA_SYNC(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "background.mif";

    reg [27:0] scroll_rate, refresh_rate;
    localparam SCROLL_SLOW = 28'd249999999,
        SCROLL_NORMAL = 28'd12499999,
        SCROLL_FAST = 28'd6249999;

    always @(*) begin
        case (SW[1:0])
            2'b00: scroll_rate = SCROLL_SLOW;
            2'b11: scroll_rate = SCROLL_FAST;
            default: scroll_rate = SCROLL_NORMAL;
        endcase
    end

    wire slow_clk, move_clk;
    rate_divider r0(CLOCK_50, resetn, scroll_rate, slow_clk);
    rate_divider r1(CLOCK_50, resetn, 28'd60000, move_clk);
	 
	localparam SONG1LANE1 = 105'b000000000000000000000000100000000000100000000000100100010001001000000001000000001001001000000000000000000,
				SONG1LANE2 = 105'b000000000000000000000000001000000010001000000010000100010001000000010000000100001001000001000000000000000,
				SONG1LANE3 = 105'b000000000000000000000000000010001000000010001000000001000100000000000100000001001000001001000000000000000,
				SONG1LANE4 = 105'b000000000000000000000000000000100000000000100000000001000100000001000000010000000001001001000000000000000;

	localparam SONG2LANE1 = 105'b000000000000000000000000000000100000000000100000000001000100000001000000010000000001001001000000000000000,
				SONG2LANE2 = 105'b000000000000000000000000000000100000000000100000000001000100000001000000010000001000001001000000000000000,
				SONG2LANE3 = 105'b000000000000000000000000001000000010001000000010000100010001000000010000000100001001000001000000000000000,
				SONG2LANE4 = 105'b000000000000000000000000100000000000100000000000100100010001001000000001000000001001001000000000000000000;

	localparam SONG3LANE1 = 105'b000000000000000000000000100010001001000100001010101010101001010101000000001010101011111010100001000100010,
				SONG3LANE2 = 105'b000000000000000000000000001000010100100010000000010000101001001001010101010000000000000111110010001000010,
				SONG3LANE3 = 105'b000000000000000000000000100000010100010001001010101010010000110110001010100000000001010001001111100010000,
				SONG3LANE4 = 105'b000000000000000000000000001010001000001000100100101000101001010101000000000101010100100000000100011111010;

    reg [104:0] s_lane1, s_lane2, s_lane3, s_lane4;

    always @(*) begin
        case (SW[9:8])
            2'b00: begin
                s_lane1 = SONG1LANE1;
                s_lane2 = SONG1LANE2;
                s_lane3 = SONG1LANE3;
                s_lane4 = SONG1LANE4;
                end
            2'b01: begin
                s_lane1 = SONG2LANE1;
                s_lane2 = SONG2LANE2;
                s_lane3 = SONG2LANE3;
                s_lane4 = SONG2LANE4;
                end
            default: begin
                s_lane1 = SONG3LANE1;
                s_lane2 = SONG3LANE2;
                s_lane3 = SONG3LANE3;
                s_lane4 = SONG3LANE4;
                end
        endcase
    end

    wire load, run;
    wire [7:0] x_temp;
    wire [6:0] y_temp;
    wire [2:0] c_temp;

    wire [7:0] score, combo, max_combo;
    wire key_d, key_f, key_j, key_k;

    control c0(CLOCK_50, resetn, start, writeEn, load, run);
    datapath d0(move_clk, slow_clk, load, run, s_lane1, s_lane2, s_lane3,
        s_lane4, x_temp, y_temp, c_temp, score, combo, max_combo, key_d, key_f,
        key_j, key_k, LEDR[9:6]);
    draw_note dn(CLOCK_50, x_temp, y_temp, c_temp, x, y, colour);

    hex_decoder h0(score[3:0], HEX0);
    hex_decoder h1(score[7:4], HEX1);
    hex_decoder h2(combo[3:0], HEX2);
    hex_decoder h3(combo[7:4], HEX3);
    hex_decoder h4(max_combo[3:0], HEX4);
    hex_decoder h5(max_combo[7:4], HEX5);

    keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
        .clock(CLOCK_50),
        .reset(resetn),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .d(key_d),
        .f(key_f),
        .j(key_j),
        .k(key_k),
        .enter()
    );

    assign LEDR[3] = key_d;
    assign LEDR[2] = key_f;
    assign LEDR[1] = key_j;
    assign LEDR[0] = key_k;
    
    assign LEDR[5:4] = 2'b00;

endmodule // gateHero

module control(input clk, input resetn, input start, output reg plot,
    output reg load, output reg run);

    reg [2:0] curr_state, next_state;
    localparam S_INITIAL = 3'd0,
        S_START = 3'd1,
        S_START_WAIT = 3'd2,
        S_RUN = 3'd3;
    initial curr_state = S_INITIAL;

    always @(*) begin
        case (curr_state)
            S_INITIAL: next_state = S_START;
            S_START: next_state = start ? S_START_WAIT : S_START;
            S_START_WAIT: next_state = start ? S_START_WAIT : S_RUN;
            S_RUN: next_state = S_RUN;
            default: next_state = S_INITIAL;
        endcase
    end

    always @(*) begin
        plot = 1'b0;
        load = 1'b0;
        run = 1'b0;

        case (curr_state)
            S_START_WAIT:
                load = 1'b1;
            S_RUN: begin
                plot = 1'b1;
                run = 1'b1;
                end
            default: begin
                plot = 1'b0;
                load = 1'b0;
                run = 1'b0;
                end
        endcase
    end

    always @(posedge clk) begin
        if (!resetn)
            curr_state <= S_INITIAL;
        else
            curr_state <= next_state;
    end

endmodule // control

module datapath(clk, slow_clk, load, run, s_lane1, s_lane2, s_lane3, s_lane4,
    x_out, y_out, c_out, score_out, combo_out, max_out, key_d, key_f, key_j,
    key_k, LEDR);

    input clk, slow_clk, load, run, key_d, key_f, key_j, key_k;
    input [104:0] s_lane1, s_lane2, s_lane3, s_lane4;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] c_out;
    output [7:0] score_out, combo_out, max_out;
    output [3:0] LEDR;

    localparam BLACK = 3'b000, WHITE = 3'b111, RED = 3'b100, YELLOW = 3'b011,
        GREEN = 3'b010, BLUE = 3'b001;
    localparam FIRST_X = 8'd48, X_OFFSET = 8'd16, FIRST_Y = 7'd1,
        Y_OFFSET = 7'd8;
    localparam LANE1 = 2'd0, LANE2 = 2'd1, LANE3 = 2'd2, LANE4 = 2'd3;

    wire [14:0] lane1_next, lane2_next, lane3_next, lane4_next;
    note_shifter lane1_shifter(slow_clk, load, run, s_lane1, lane1_next);
    note_shifter lane2_shifter(slow_clk, load, run, s_lane2, lane2_next);
    note_shifter lane3_shifter(slow_clk, load, run, s_lane3, lane3_next);
    note_shifter lane4_shifter(slow_clk, load, run, s_lane4, lane4_next);
	
	assign LEDR[3] = lane1_next[14];
	assign LEDR[2] = lane2_next[14];
	assign LEDR[1] = lane3_next[14];
	assign LEDR[0] = lane4_next[14];

    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] c;

    reg [1:0] curr_lane = LANE1;
    reg [3:0] curr_note = 4'd0;
    wire next_lane = (curr_note == 4'd15) ? 1'd1 : 1'd0;

    always @(posedge clk) begin
        case (curr_lane)
            LANE1:   curr_lane = next_lane ? LANE2 : LANE1;
            LANE2:   curr_lane = next_lane ? LANE3 : LANE2;
            LANE3:   curr_lane = next_lane ? LANE4 : LANE3;
            LANE4:   curr_lane = next_lane ? LANE1 : LANE4;
            default: curr_lane = LANE1;
        endcase
    end

    always @(posedge clk) begin
        if (run) begin
            if (curr_note == 4'd15)
                curr_note <= 4'd0;
            else
                curr_note <= curr_note + 1'd1;
        end
    end

    always @(*) begin
        if (curr_note == 4'd15) begin
            x = 8'd0;
            y = 7'd0;
            c = BLACK;
            end
        else begin
            x = FIRST_X + curr_lane * X_OFFSET;
            y = FIRST_Y + curr_note * Y_OFFSET;

            case (curr_lane)
                LANE1:   c = lane1_next[curr_note] ? GREEN : BLACK;
                LANE2:   c = lane2_next[curr_note] ? BLUE : BLACK;
                LANE3:   c = lane3_next[curr_note] ? BLUE : BLACK;
                LANE4:   c = lane4_next[curr_note] ? GREEN : BLACK;
                default: c = BLACK;
            endcase
        end
    end

    assign x_out = x;
    assign y_out = y;
    assign c_out = c;

    wire [1:0] lane1_sa, lane2_sa, lane3_sa, lane4_sa;
    assign_score as1(slow_clk, lane1_next[14:13], key_d, lane1_sa);
    assign_score as2(slow_clk, lane2_next[14:13], key_f, lane2_sa);
    assign_score as3(slow_clk, lane3_next[14:13], key_j, lane3_sa);
    assign_score as4(slow_clk, lane4_next[14:13], key_k, lane4_sa);

    wire [7:0] lane1_score, lane2_score, lane3_score, lane4_score;
    score_counter sc1(slow_clk, ~load, run, lane1_sa, lane1_score);
    score_counter sc2(slow_clk, ~load, run, lane2_sa, lane2_score);
    score_counter sc3(slow_clk, ~load, run, lane3_sa, lane3_score);
    score_counter sc4(slow_clk, ~load, run, lane4_sa, lane4_score);

    combo_counter cc(slow_clk, ~load, run, lane1_sa, lane2_sa, lane3_sa,
        lane4_sa, combo_out, max_out);

    assign score_out = lane1_score + lane2_score + lane3_score + lane4_score;

endmodule // datapath
