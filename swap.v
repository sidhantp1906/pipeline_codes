`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:01:04 05/27/2021 
// Design Name: 
// Module Name:    swap 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module swap(
     input   we,
     input [7:0]w_data,
    input [7:0]b_addr,
    input [7:0]a_addr,
    input [7:0]r_addr,
    input [7:0]w_addr,
    input clk1,
    input clk2,
	 input swap,
	 input reset,
    output [7:0]r_data
    );
	 
	 
	 reg [1:0]cur_state,next_state;
	 parameter so = 0,s1 = 1, s2 = 2, s3  = 4;
	 reg w;
	 reg [1:0]sel;
	 
	 reg [7:0]Reg[0:255];
	 
	  
	  wire we1;
	  wire [7:0]w_data1;
	  
	  
	  reg l12_we,l23_we,l12_w,l23_w;
	  reg [1:0]l12_sel;
	  reg [7:0]l12_w_addr,l12_w_data,l12_a_addr,l12_b_addr,l12_r_addr;
     reg [7:0]l23_w_data,l23_w_addr,l23_r_addr;
	  reg [7:0]l34_r_data;
	  
	  
	  always @(posedge clk1 or negedge reset) //fsm reset
	  begin
	  if(~reset)
	  cur_state <= so;
	  else
	  cur_state <= next_state;
	  end
	 
	 always @(swap) //fsm next state logic
	  begin
	  next_state = cur_state;
	  case(cur_state)
	  so : if(~swap)
	       next_state = so;
			 else
			 next_state = s1;
	  s1: next_state = s2;
	  s2: next_state = s3;
	  s3: next_state = so;
 	  default : next_state = so;
	  endcase
	   w = (cur_state == so)?1'b0:1'b1; //moore o/p
	   sel = cur_state;
	  end

			 always @(posedge clk2) //stage1
			 begin
			 l12_we <= we;
			 l12_w_data <= w_data;
			 l12_w <= w;
			 l12_sel <= sel;
			 l12_b_addr <= b_addr;
			 l12_a_addr <= a_addr;
			 l12_r_addr <= r_addr;
			 l12_w_addr <= w_addr;
			 end
			 
			 always @(posedge clk1) //stage2
			 begin
			 case(l12_sel)
			 2'b00 :begin l23_w_addr <= l12_w_addr;
			         l23_r_addr <= l12_r_addr;
			         end
			 2'b01 : begin l23_w_addr <= 8'b0;
			         l23_r_addr <= l12_a_addr;
						end
			 2'b10 : begin l23_w_addr <= l12_a_addr;
                  l23_r_addr <= l12_b_addr;
						end
          2'b11 : begin l23_w_addr <= l12_b_addr; 
                  l23_r_addr <= 8'b0;   
						end
			default : begin end
       endcase
		  l23_w <= l12_w;
		  l23_w_data <= l12_w_data;
		  l23_we <= l12_we;
		  end
		 
      assign we1 = (l23_w==0)?l23_we:1'b1;
		assign w_data1 = (l23_w==0)?l23_w_data:l34_r_data;
		  
		
		  always @(posedge clk2)//stage 3
		  begin
		  
		if(we1)
		Reg[l23_w_addr] <= w_data1;
		else
		l34_r_data <= Reg[l23_r_addr];
			end
			
			assign r_data = l34_r_data; //output
endmodule
