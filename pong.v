module pong_game(
    input clk,                 // System clock (10 MHz)
    input reset,               // Reset signal
    input up_player1,          // Player 1 paddle up
    input down_player1,        // Player 1 paddle down
    input up_player2,          // Player 2 paddle up
    input down_player2,        // Player 2 paddle down
    output [7:0] rows,         // Dot matrix row control
    output [7:0] cols,         // Dot matrix column control
    output [7:0] segment_pins, // 7-segment display segment pins (A to DP)
    output [2:0] cathode_pins  // 7-segment display cathode pins (C1 to C6)
);

    // Game state variables
    reg [2:0] ball_x, ball_y;        // Ball position
    reg ball_speed_x, ball_speed_y;  // Ball speed (direction)
    reg [2:0] player1_pos;           // Player1 paddle position (column 0)
    reg [2:0] player2_pos;           // Player2 paddle position (column 7)

    // Scoring variables
    reg [3:0] player1_score, player2_score; //upto 9
    
    // Signals for 7-segment display
    wire [7:0] segments;         // Segment lines (A to DP)
    wire [2:0] cathode_sel;      // Common cathode selection (C1 to C6)

    // Randomization counter
    wire counter_0; // Random bit for ball_speed_x
    wire counter_1; // Random bit for ball_speed_y

    // 10Hz Game Clock
    wire game_clk;
    clock_divider clock_gen(clk, game_clk, counter_0, counter_1);

    // Initialize game state
    initial begin
        ball_x = 4;
        ball_y = 4;
        ball_speed_x = 1; //may need to update
        ball_speed_y = 1; //may need to update
        player1_pos = 3;
        player2_pos = 3;
        player1_score = 0;
        player2_score = 0;
    end

    // Game logic
    always @(posedge game_clk or posedge reset) begin
        if (reset) begin
            // Reset game state
            ball_x <= 4;
            ball_y <= 4;

            // Randomize ball direction using counter_0 and counter_1
            ball_speed_x <= counter_0; // Randomize horizontal direction
            ball_speed_y <= counter_1; // Randomize vertical direction

            player1_pos <= 3;
            player2_pos <= 3;
            player1_score <= 0;
            player2_score <= 0;
        end else begin
        
            // Ball movement
            ball_x <= ball_x + (ball_speed_x ? 1 : -1);
            ball_y <= ball_y + (ball_speed_y ? 1 : -1);

            // Ball collision with top and bottom edges
            if (ball_y == 0 || ball_y == 7) begin
                ball_speed_y <= ~ball_speed_y;
            end

            // Ball collision with paddles or scoring
            if (ball_x == 0) begin
                if (ball_y < player1_pos || ball_y > player1_pos + 2) begin
                    // Player2 scores
                    player2_score <= player2_score + 1;
                    ball_x <= 4;
                    ball_y <= 4;
                    ball_speed_x <= counter_0; // Randomize direction
                    ball_speed_y <= counter_1;
                end else begin
                    // Ball bounces back
                    ball_speed_x <= ~ball_speed_x;
                end
            end else if (ball_x == 7) begin
                if (ball_y < player2_pos || ball_y > player2_pos + 2) begin
                    // Player1 scores
                    player1_score <= player1_score + 1;
                    ball_x <= 4;
                    ball_y <= 4;
                    ball_speed_x <= counter_0; // Randomize direction
                    ball_speed_y <= counter_1;
                end else begin
                    // Ball bounces back
                    ball_speed_x <= ~ball_speed_x;
                end
            end

            // Player1 paddle movement
            if (up_player1 && player1_pos > 0) begin
                player1_pos <= player1_pos - 1;
            end else if (down_player1 && player1_pos < 5) begin
                player1_pos <= player1_pos + 1;
            end

            // Player2 paddle movement
            if (up_player2 && player2_pos > 0) begin
                player2_pos <= player2_pos - 1;
            end else if (down_player2 && player2_pos < 5) begin
                player2_pos <= player2_pos + 1;
            end
        end
    end

    // Dot Matrix Display logic
    always @(*) begin
        // Clear display
        rows = 8'b00000000;
        cols = 8'b00000000;

        // Display ball
        rows[ball_y] = 1;
        cols[ball_x] = 1;

        // Display player1 paddle (column 0)
        rows[player1_pos] = 1;
        rows[player1_pos + 1] = 1;
        rows[player1_pos + 2] = 1;
        cols[0] = 1;

        // Display player2 paddle (column 7)
        rows[player2_pos] = 1;
        rows[player2_pos + 1] = 1;
        rows[player2_pos + 2] = 1;
        cols[7] = 1;
    end

	// Display score to 7-seg display
    seven_seg_score_display score_display(clk, reset, player1_score, player2_score, segments, cathode_sel);

    // Map the outputs to physical pins
    assign segment_pins = segments;       // Connect `segments` to physical pins
    assign cathode_pins = cathode_sel;    // Connect `cathode_sel` to physical pins

endmodule

	