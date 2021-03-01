`timescale 1ns / 1ps


module counter_tb;

reg clk,rst,counter_green_en,counter_orange_en,counter_green_exten_en;
wire counter_green_done,counter_orange_done,counter_green_exten_done;

parameter COUNTER_LENGTH = 5;

counter #(COUNTER_LENGTH) mycounter(
clk,rst,counter_green_en,counter_orange_en,counter_green_exten_en,
counter_green_done,counter_orange_done,counter_green_exten_done
);
reg temp = 0;
initial begin
    clk = 0;
    rst = 1;
    #10
    rst = 0;
    counter_green_en <= 0;
    counter_orange_en <= 0;
    counter_green_exten_en <= 0;
    #2
    counter_green_en = 1;
end

always@(posedge clk)
begin
    if(counter_green_done)
    begin
        counter_green_en <= 0;
        temp <= 1;
        counter_green_exten_en <= temp;
    end
end
always
    #1 clk = ~clk;
    
endmodule
