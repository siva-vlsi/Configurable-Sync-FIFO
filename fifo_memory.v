`timescale 1ns / 1ps

module fifo_memory #(parameter width = 8,
    parameter depth = 8
    )( 
    
    input clk,rst,w_en,r_en,
    input [width-1:0] din,
    output full,empty,
    output reg [width-1:0] d_out,
    output reg overflow_flag,underflow_flag
    
    );
    localparam ptr_width = $clog2(depth);
    reg [width-1:0] mem [0:depth-1];
    reg [ptr_width:0] r_ptr;
    reg [ptr_width:0] w_ptr;
    integer i;
    
    always @(posedge clk) begin 
        if(rst) begin
                for(i= 0 ; i<depth; i= i+1) begin
                    mem[i] <= 0;
                    end
                    w_ptr <= 0;
                    r_ptr <= 0;
                    d_out <= 0;
                    overflow_flag <= 1'b0;
                    underflow_flag <= 1'b0;
                    end
        else 
            begin
            
                 if(w_en && !full) begin
                 
                    mem[w_ptr[ptr_width-1:0]] <= din;
                    w_ptr <= w_ptr + 1'b1;
                    overflow_flag <= 1'b0;
                    
                end
                
                else if(w_en && full) begin
                    overflow_flag <= 1'b1;
                    end
                    
                else if(!w_en) 
                    overflow_flag <= 1'b0;
       
                 if(r_en && !empty) begin
                 
                    d_out <= mem[r_ptr[ptr_width-1:0]];
                    r_ptr <= r_ptr + 1'b1;
                    underflow_flag <= 1'b0;
                    
                    end
                    
                 else if(r_en && empty) begin
                    underflow_flag <= 1'b1;
                    end
                    
                 else if(!r_en) 
                    underflow_flag <= 1'b0;
                end
     end   
     
     assign full = (w_ptr[ptr_width-1:0] == r_ptr[ptr_width-1:0]) && (w_ptr[ptr_width] != r_ptr[ptr_width]);
     assign empty = (w_ptr == r_ptr) ? 1'b1 : 1'b0;      
           
endmodule
