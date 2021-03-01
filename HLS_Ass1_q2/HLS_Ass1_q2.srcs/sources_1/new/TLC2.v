`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2021 17:20:39
// Design Name: 
// Module Name: TLC2
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


module TLC2 #(
parameter SENSOR_DATA_WIDTH = 8,
parameter NUM_LANES = 4,
parameter NUM_LANE_BITS = 2*NUM_LANES-1)
(
input[SENSOR_DATA_WIDTH -1 : 0] in1p1,in1p2,in2in,in3in,
input day,clk,rst,
output reg[NUM_LANE_BITS -1 : 0] TrafficOut
    );
    
reg[2:0] state,next_state;
reg counter_green_en,counter_orange_en;
wire counter_green_done,counter_orange_done;
//next state generation


always@(posedge clk)
begin
    state <= next_state;
   
    if(~day || rst)
    begin
        TrafficOut <= 8'b01_01_01_01;
        state <= 00;     
    end
    else
    begin
        case(state)
            //1st tl
            4'b000:
            begin
                TrafficOut <= 8'b11_00_00_00;
                next_state <= 3'b001;
                counter_green_en <= 1'b1;                  
                if(counter_green_done)
                begin
                    counter_green_en <= 1'b0;
                    if( (in2in < in1p1 ) || (in2in < in1p2) || (in2in < in3in) )
                        next_state <= 3'b000;   //count another green or we one can have custom count here
                    else 
                        next_state <= 3'b010;   //moveon to orange
                end
                else
                begin
                    next_state <= 3'b001;                    
                end
                TrafficOut <= 8'b11_00_00_00;
            end
            
        endcase
    end
end





endmodule
