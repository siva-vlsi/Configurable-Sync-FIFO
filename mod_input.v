`timescale 1ns/1ps 


module mod_input #(parameter  width= 8)( 
    input clk,
    input rst,
    input en,
    input flag,
    input [width-1:0] din,
    output reg [width-1:0] out,
    output reg w_en
    );
    
    
    always @(posedge clk ) begin
        if(rst) begin
            out <= 8'b0;
            w_en <= 1'b0; 
            end
        else begin
            if(en && !flag) begin
                out <= din;
                w_en <= 1'b1;
                end
             else 
                    begin
                out <= 8'd0;               
                w_en <= 1'b0;
                end
         end
    end
    
endmodule
