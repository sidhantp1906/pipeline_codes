`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:45:35 05/24/2021 
// Design Name: 
// Module Name:    pipe2 
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
module pipe2(
    output [15:0]zout,
    input [3:0]rs,
    input [3:0]rs1,
    input [3:0]rd,
    input [3:0]func,
    input [7:0]addr,
    input clk1,
    input clk2
    );
	reg [15:0]l12_a,l12_b,l23_z,l34_z; //creating pipelined inputs/outputs
 reg [3:0]l12_rd,l12_func,l23_rd;
  reg [15:0]l12_addr,l23_addr,l34_addr;
  
	reg [15:0]Reg[15:0]; //initialising reg 
	reg [15:0]mem[0:255]; //initialising memory
  assign zout = l34_z; //output
 
 always @(posedge clk1) //s1
begin
l12_a <= #2 Reg[rs];
l12_b <= #2 Reg[rs1];
l12_rd <= rd;
l12_func <= func;
l12_addr <= addr;
end

always @(posedge clk2) //s2
begin
	case(func)                   //ALU operations
4'b0000 : l23_z <= #2 l12_a + l12_b;
4'b0001 : l23_z <= #2 l12_a - l12_b;
4'b0010 : l23_z <= #2 l12_a * l12_b;
4'b0011 : l23_z <= #2 l12_a & l12_b;
4'b0100 : l23_z <= #2 l12_a | l12_b;
default : l23_z <= #2 16'hxx;
endcase
l23_rd <= l12_rd;
l23_addr <= l12_addr;
end
always @(posedge clk1) //s3
begin
Reg[l23_rd] <= #2 l23_z;
l34_z <= l23_z;
l34_addr <= l23_addr;
end
always @(posedge clk2) //s4
begin
mem[l34_addr] <= #2 l34_z;
end
endmodule
