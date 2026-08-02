`timescale 1ns /1ps

module FIFO_top_module #(parameter width = 8,
                    parameter depth = 8)(
    input rst,
    input clk,
    input en,
    input [width - 1:0] d_in,
    output [width - 1:0] d_out_top,
    output overflow , underflow
    );
    wire [width - 1:0] temp_data;
    wire [width - 1:0] fifo_out;
    wire wr_en,rd_en;
    wire full_flag,empty_flag;
    
    mod_input #(.width(width)) mod_in(.clk(clk),.en(en),.rst(rst),.flag(full_flag),.din(d_in),.out(temp_data),.w_en(wr_en));
    
    fifo_memory #(.width(width),.depth(depth))  fifo_1(.clk(clk),.rst(rst),.w_en(wr_en),.full(full_flag),
            .din(temp_data),.empty(empty_flag),.d_out(fifo_out),.r_en(rd_en),.overflow_flag(overflow),.underflow_flag(underflow));
            
    mod_output #(.width(width)) mod_out(.clk(clk), .rst(rst), .empty(empty_flag), .din(fifo_out), .w_en(rd_en), .d_out(d_out_top));
    
   
endmodule
