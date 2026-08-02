`timescale 1ns/1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2026 20:14:41
// Design Name: 
// Module Name: FIFO_top_module_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO_top_module_tb;
    parameter width = 8;
    reg clk,rst,en;
    reg [width - 1:0] din;
    wire [width - 1:0] d_out;
    wire overflow, underflow;
    
    
    FIFO_top_module #(.width(width)) uut(.clk(clk),.rst(rst),.en(en),.d_in(din),.d_out_top(d_out),.overflow(overflow),.underflow(underflow));
    
    initial clk = 0;
    
    always #5 clk = ~clk;
    
    initial begin
            {rst,en,din} = 0;
            
            rst = 1'b1;
            en= 1'b0;
            din = 8'd0;
            
            @(posedge clk) ; #1;
            @(posedge clk) ; #1;

            rst = 0;
            @(posedge clk) ; #1;
            
            en=1;
            
            
            @(posedge clk) ; #1;
            en= 1;
             din =8'hAA;
            
            @(posedge clk) ; #1;
             din =8'h8A;
             
             @(posedge clk) ; #1;
            
             din =8'h94;    
             
             @(posedge clk) ; #1;
             din =8'hF4;    
             
             @(posedge clk) ; #1;
             din =8'hA;
             
             @(posedge clk) ; #1;
             din =8'hF2;
             
             @(posedge clk) ; #1;
             
             din =8'hFA;
             
             @(posedge clk) ; #1;
            en= 1;
             din =8'hAA;
            
            @(posedge clk) ; #1;
             din =8'h8A;
             
             @(posedge clk) ; #1;
            
             din =8'h94;    
             
             @(posedge clk) ; #1;
            en= 1;
             din =8'hF4;    
             
             @(posedge clk) ; #1;
             din =8'hA;
             
             @(posedge clk) ; #1;
             din =8'hF2;
             
             @(posedge clk) ; #1;
             din =8'hFA;
                 

            @(posedge clk) ; #1;
            en= 0;            
            
            repeat(30) @(posedge clk) ;
              $finish;
            
            end
           initial begin
        $monitor("TIME=%0t | rst=%b en=%b d_in=0x%0h | d_out=0x%0h",
        $time, rst, en, din
        , d_out);
    end


endmodule
