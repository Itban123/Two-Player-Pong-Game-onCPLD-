module ball_movement_test(clk,reset,rows,cols);

	input clk,reset;
	output reg [0:7] rows, cols;

	reg[2:0] ball_x,ball_y;
	reg ball_speed_x, ball_speed_y;
	
	initial begin
	ball_x = 4;
	ball_y = 4;
	
	ball_speed_x = 1;
	ball_speed_y = 1;
	
	rows = 8'b00000000;
	cols = 8'b10000001;
	end
	
	always@(posedge clk or posedge reset)begin
	
		if(reset)begin
			ball_x = 4;
			ball_y = 4;
			
			ball_speed_x = 1;
			ball_speed_y = 1;
		end   
		
		ball_x <= ball_x + (ball_speed_x ? 1 : -1);
		ball_y <= ball_y + (ball_speed_y ? 1 : -1);

		if (ball_x == 0 || ball_x == 7) begin
			ball_speed_x <= ~ball_speed_x;
		end
		
		if (ball_y == 0 || ball_y == 7) begin
			ball_speed_y <= ~ball_speed_y;
			end
			
		rows[ball_y] = 1;
        cols[ball_x] = 1;
	end

endmodule
		
									