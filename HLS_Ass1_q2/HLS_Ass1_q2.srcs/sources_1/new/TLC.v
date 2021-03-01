`timescale 1ms / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2021 14:11:11
// Design Name: 
// Module Name: TLC
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


module TLC #(
parameter SENSOR_DATA_WIDTH = 8,
parameter NUM_LANES = 4,
parameter NUM_LANE_BITS = 2*NUM_LANES)
(
input[SENSOR_DATA_WIDTH -1 : 0] in1p1,in1p2,in2in,in3in,
input day,clk,rst,
output reg[NUM_LANE_BITS -1 : 0] TrafficOut
    );
    
reg[3:0] state,next_state;
reg counter_green_en = 0,counter_orange_en = 0,counter_green_exten_en = 0;
wire counter_green_done,counter_orange_done,counter_green_exten_done;
//next state generation
localparam COUNTER_LENGTH = 5; 
counter #(COUNTER_LENGTH) mycounter (
clk,rst,counter_green_en,counter_orange_en,counter_green_exten_en,counter_green_done,counter_orange_done,counter_green_exten_done
);
//output assignment
reg temp = 0;
always@(posedge clk)
if(rst)begin
    counter_green_en <= 0;
    counter_orange_en <= 0;
    counter_green_exten_en <= 0;end
    
    
always@(posedge clk)
    state <= next_state;    
    
    
always@(posedge clk)
begin    
//    state <= next_state;
   
    if(~day || rst)
    begin
        TrafficOut <= 8'b01_01_01_01;
        state <= 4'b0000;
        next_state <= 4'b0000;     
    end
    
    else
    begin
        case(state)
            //1st tl
            4'b0000:
            begin
                TrafficOut <= 8'b11_00_00_00;
                next_state <= 4'b0001;
                counter_green_en <= 1'b1;    
            end
            //check for empty obstructing lanes and increase count
            4'b0001:
            begin
                if(counter_green_done || counter_green_exten_done)
                begin
                    counter_green_en <= 1'b0;
//                    counter_green_exten_en <= 1'b0;
                    if(~((in2in < in1p1 ) || (in2in < in1p2) || (in2in < in3in)))
                    begin
                        next_state <= 4'b0001;   //count another green or we one can have custom count here
                        temp <= 1'b1;
                        counter_green_exten_en <= temp;        //check for every 3 seconds if the traffic in this lane is more than others.                
                    end
                    else 
                    begin
                        counter_green_exten_en <= 1'b0;        //check for every 3 seconds if the traffic in this lane is more than others.                                                                
                        next_state <= 4'b0010;   //moveon to orange
                    end
                end
                else
                begin
                    next_state <= 4'b0001;                    
                end
                TrafficOut <= 8'b11_00_00_00;
            end
            //orange
            4'b0010: 
            begin
                counter_orange_en <= 1'b1;
                if(counter_orange_done)
                begin
                    if(in1p1 == 0)
                    begin
                        if(in1p2 == 0)
                            next_state <= 4'b1100;
                        else
                            next_state <= 4'b0110;
                    end
                    else    
                        next_state <= 4'b0011;
                    counter_orange_en <= 1'b0;
                end
                else
                    next_state <= 4'b0010;    
                TrafficOut <= 8'b01_00_00_00;            
            end
            //red
            4'b0011: 
            begin
                TrafficOut <= 8'b00_11_00_00;
                next_state <= 4'b0100;
                counter_green_en <= 1'b1;    
            end
            //check for empty obstructing lanes and increase count
            4'b0100:
            begin
                if(counter_green_done || counter_green_exten_done)
                begin
                    counter_green_en <= 1'b0;
                    counter_green_exten_en <= 1'b0;
                    if(~((in1p1 < in2in ) || (in1p1 < in1p2) || (in1p1 < in3in)))
                    begin
                        next_state <= 4'b0100;   //count another green or we one can have custom count here
                        temp <= 1'b1;
                        counter_green_exten_en <= temp;        //check for every 3 seconds if the traffic in this lane is more than others.                
                    end
                    else 
                        next_state <= 4'b0101;   //moveon to orange
                end
                else
                begin
                    next_state <= 4'b0100;                    
                end
                TrafficOut <= 8'b00_11_00_00;
            end
            //orange
            4'b0101:
            begin
                counter_orange_en <= 1'b1;
                if(counter_orange_done)
                begin
                    if(in1p2 == 0)
                    begin
                        if(in3in == 0)
                            next_state <= 4'b0000;
                        else
                            next_state <= 4'b1001;  //3rd red
                    end
                    else
                        next_state <= 4'b0110;
                    counter_orange_en <= 1'b0;
                end
                else
                    next_state <= 4'b0101;    
                TrafficOut <= 8'b00_01_00_00;            
            end
            //red
            4'b0110: 
            begin
                TrafficOut <= 8'b00_00_11_00;
                next_state <= 4'b0111;
                counter_green_en <= 1'b1;    
            end
            //check for empty obstructing lanes and increase count
            4'b0111:
            begin
                if(counter_green_done || counter_green_exten_done)
                begin
                    counter_green_en <= 1'b0;
                    counter_green_exten_en <= 1'b0;
                    if(~((in1p2 < in1p1 ) || (in1p2 < in2in) || (in1p2 < in3in)))
                    begin
                        next_state <= 4'b0111;   //count another green or we one can have custom count here
                        temp <= 1'b1;
                        counter_green_exten_en <= temp;        //check for every 3 seconds if the traffic in this lane is more than others.                
                    end
                    else 
                        next_state <= 4'b1000;   //moveon to orange
                end
                else
                begin
                    next_state <= 4'b0111;                    
                end
                TrafficOut <= 8'b00_00_11_00;
            end
            
            //orange
            4'b1000:
            begin
                counter_orange_en <= 1'b1;
                if(counter_orange_done)
                begin
                    if(in3in == 0)
                    begin
                        if(in2in == 0)
                            next_state <= 4'b0011;
                        else
                            next_state <= 4'b0000;
                    end
                    else
                        next_state <= 4'b1001;
                    counter_orange_en <= 1'b0;
                end
                else
                    next_state <= 4'b1000;    
                TrafficOut <= 8'b00_00_01_00;            
            end
            //red
            4'b1001: 
            begin
                TrafficOut <= 8'b00_00_00_11;
                next_state <= 4'b1010;
                counter_green_en <= 1'b1;    
            end
            //3rd tl
            //check for empty obstructing lanes and increase count
            4'b1010:
            begin
                 if(counter_green_done || counter_green_exten_done)
                begin
                    counter_green_en <= 1'b0;
                    counter_green_exten_en <= 1'b0;
                    if(~((in3in < in1p1 ) || (in3in < in1p2) || (in3in < in2in)))
                    begin
                        next_state <= 4'b1010;   //count another green or we one can have custom count here
                        temp <= 1'b1;
                        counter_green_exten_en <= temp;        //check for every 3 seconds if the traffic in this lane is more than others.                
                    end
                    else 
                        next_state <= 4'b1011;   //moveon to orange
                end
                else
                begin
                    next_state <= 4'b1010;                    
                end
                TrafficOut <= 8'b00_00_00_11;
            end
            
            //orange
            4'b1011:
            begin
                counter_orange_en <= 1'b1;
                if(counter_orange_done)
                begin
                    if(in2in == 0)
                    begin
                        if(in1p1 == 0)
                            next_state <= 4'b0110;
                        else
                            next_state <= 4'b0011;
                    end
                    else
                        next_state <= 4'b0000;
                    counter_orange_en <= 1'b0;
                end
                else
                    next_state <= 4'b1011;    
                TrafficOut <= 8'b00_00_00_01;            
            end
            //red
//            4'b1100: 
//            begin
//                TrafficOut <= 8'b00_00_00_00;
//                next_state <= 4'b0000;
//                counter_green_en <= 1'b1;    
//            end
            
            
            
            
        endcase
    end
end  
endmodule



module counter #(parameter COUNTER_LENGTH = 5)(
input clk,rst,counter_green_en,counter_orange_en,counter_green_exten_en,
output reg counter_green_done,counter_orange_done,counter_green_exten_done
);

reg[3:0] count = 0;
always@(posedge clk)
begin
    if(rst)
    begin
        counter_green_done <= 0;
        counter_orange_done <= 0;
        counter_green_exten_done <= 0;
        count <= 0;
    end
    else
    begin
        if(counter_green_en || counter_orange_en || counter_green_exten_en)
        begin
            count <= count +1;
            if((count == 6) && counter_green_en)
                counter_green_done <= 1;
            else if((count == 1) && counter_green_exten_en)  
                counter_green_exten_done <= 1; 
            else if((count == 0) && counter_orange_en)  
                counter_orange_done <= 1;         
        end     
        else
        begin
            counter_green_done <= 0;
            counter_orange_done <= 0;
            count <= 0;
        end  
     end
end
endmodule