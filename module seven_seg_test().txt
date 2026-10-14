module seven_seg_test(
    input clk,                   // System clock (10 MHz)
    input reset,                 // Reset signal
    input button1,               // Push button for Player 1 score
    input button2,               // Push button for Player 2 score
    output reg [7:0] segments,   // Segment control (A to DP)
    output reg [2:0] cathode_sel // Common cathode control (DE1, DE2, DE3)
);

    // Score counters (4-bit for 0-9)
    reg [3:0] score1 = 0;  // Player 1 score
    reg [3:0] score2 = 0;  // Player 2 score

    // Clock divider for 60 Hz refresh rate
    reg [19:0] clk_div;          // 20-bit counter for dividing 10 MHz
    wire multiplex_clk = clk_div[19]; // 60 Hz clock (20-bit divider for ~166,667)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
        end else if (clk_div == 20'd166666) begin
            clk_div <= 0; // Reset counter after division factor
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // Multiplexing logic
    reg current_display; // 0 = Player 1 (C1), 1 = Player 2 (C6)

    always @(posedge multiplex_clk or posedge reset) begin
        if (reset) begin
            current_display <= 0;
        end else begin
            current_display <= ~current_display; // Switch between displays
        end
    end

    // Increment scores on button presses
    always @(posedge button1 or posedge reset) begin
        if (reset) begin
            score1 <= 0;
        end else begin
            if (score1 == 4'd9) // Roll over score1 after 9
                score1 <= 0;
            else
                score1 <= score1 + 1;
        end
    end

    always @(posedge button2 or posedge reset) begin
        if (reset) begin
            score2 <= 0;
        end else begin
            if (score2 == 4'd9) // Roll over score2 after 9
                score2 <= 0;
            else
                score2 <= score2 + 1;
        end
    end

    // Cathode control and segment display
    always @(*) begin
        case (current_display)
            1'b0: begin
                // Player 1 (1st display)
                cathode_sel = 3'b000;        // Select C1 (1st display)
                segments = score_to_segments(score1); // Player 1 score
            end
            1'b1: begin
                // Player 2 (6th display)
                cathode_sel = 3'b101;        // Select C6 (6th display)
                segments = score_to_segments(score2); // Player 2 score
            end
        endcase
    end

    // Function to convert score to 7-segment encoding (common cathode)
    function [7:0] score_to_segments;
        input [3:0] score;
        case (score)
            4'd0: score_to_segments = 8'b00111111; // Display 0
            4'd1: score_to_segments = 8'b00000110; // Display 1
            4'd2: score_to_segments = 8'b01011011; // Display 2
            4'd3: score_to_segments = 8'b01001111; // Display 3
            4'd4: score_to_segments = 8'b01100110; // Display 4
            4'd5: score_to_segments = 8'b01101101; // Display 5
            4'd6: score_to_segments = 8'b01111101; // Display 6
            4'd7: score_to_segments = 8'b00000111; // Display 7
            4'd8: score_to_segments = 8'b01111111; // Display 8
            4'd9: score_to_segments = 8'b01101111; // Display 9
            default: score_to_segments = 8'b00000000; // Blank display
        endcase
    endfunction

endmodule
