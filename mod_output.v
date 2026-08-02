`timescale 1ns / 1ps

module mod_output #(parameter width = 8)(

    input clk,
    input rst,
    input empty,
    input [width -1:0] din,
    output reg [width - 1:0] d_out,
    output reg w_en
    
    );
    
    localparam idle = 2'b00;
    localparam s1 = 2'b01;
    localparam transmit_data = 2'b10;
    
    reg [1:0] ns,ps;
    
    
    always @(posedge clk) begin
        if(rst) begin
            ps <= idle; 
            d_out <= 0;
            w_en <= 0;
            end
        else  begin
            ps <= ns;
            if(ps==transmit_data)
                     d_out <= din;
                end

    end
    
    always @(*) begin
        ns    = idle;
        w_en  = 1'b0;
        case(ps) 
            idle   : begin 
                            ns = empty ? idle : s1;
                            w_en = 0;
                            
                     end
                            
            s1   : begin 
                   ns = empty ? idle : transmit_data ;
                   w_en = 0;
                   end
                   
            
            transmit_data   : begin
                         ns = idle;
                         w_en = 1'b1;
                         end
            default : begin 
                         ns = idle;
                         w_en = 0;
                         end
           endcase 
           end 
    
    
    
endmodule
