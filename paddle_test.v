module paddle_test(clk,reset,up_p1,down_p1,up_p2,down_p2,rows,cols);

	input clk,reset,up_p1,up_p2,down_p1,down_p2;
	output reg [0:7] rows, cols;
	reg [2:0] p1_pos, p2_pos;
	
	initial begin
		
		p1_pos = 2;
		p2_pos = 2;
		rows = 8'b00000000;
		cols = 8'b10000001;
	end
	
	always@(posedge clk or posedge reset)begin
		
		if(reset)begin
			p1_pos = 2;
			p2_pos = 2;
		end
		
		if(up_p1 && p1_pos>0)
			p1_pos<=p1_pos+1;
		if(down_p1 && p1_pos<6)
			p1_pos<=p1_pos-1;
		if(up_p2 && p1_pos>0)
			p2_pos<=p2_pos+1;
		if(down_p2 && p2_pos<6)
			p2_pos<=p2_pos-1;
			
		rows[p1_pos]=1;
		rows[p1_pos+1]=1;
		rows[p1_pos+2]=1;
		cols[p2_pos]=1;
		cols[p2_pos+1]=1;
		cols[p2_pos+2]=1;			
	end		

endmodule
