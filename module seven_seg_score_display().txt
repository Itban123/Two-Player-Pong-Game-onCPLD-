module seven_seg_score_display(
    input clk,                   // System clock (10 MHz input clock)
    input reset,                 // Reset signal
    input [3:0] player1_score,   // Score for Player 1 (0-9)
    input [3:0] player2_score,   // Score for Player 2 (0-9)
    output reg [7:0] segments,   // Segment control (A to DP)
    output reg [2:0] cathode_sel // Common cathode control via 74138 (C1-C6)
);

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

    // Cathode control and score display
    always @(*) begin
        case (current_display)
            1'b0: begin
                // Player 1 (1st display)
                cathode_sel = 3'b000;        // Select C1 (1st display)
                segments = score_to_segments(player1_score); // Player 1 score
            end
            1'b1: begin
                // Player 2 (6th display)
                cathode_sel = 3'b101;        // Select C6 (6th display)
                segments = score_to_segments(player2_score); // Player 2 score
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
