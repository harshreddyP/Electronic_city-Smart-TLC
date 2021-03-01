`timescale 1ms / 1us


module TLC_tb;
parameter SENSOR_DATA_WIDTH = 8;
parameter NUM_LANES = 4;
parameter NUM_LANE_BITS = 2*NUM_LANES;

reg[SENSOR_DATA_WIDTH -1 : 0] in1p1,in1p2,in2in,in3in;
reg day,clk,rst;
wire [NUM_LANE_BITS -1 : 0] TrafficOut;

TLC #(SENSOR_DATA_WIDTH,NUM_LANES,NUM_LANE_BITS) uut(in1p1,in1p2,in2in,in3in,day,clk,rst,TrafficOut);


initial begin
    clk = 0;
    rst = 1;
    day = 0;
    #5
    in1p1 <= 20;    in1p2<= 20;    in2in <= 20;    in3in <= 20;
    #2
    rst = 0;
    day = 1;
    
    #10
    in1p1 <= 20;    in1p2<= 20;    in2in <= 10;    in3in <= 20;
    
    #10
    in1p1 <= 20;    in1p2<= 20;    in2in <= 5;    in3in <= 10;
    
    #10
    in1p1 <= 8;    in1p2<= 20;    in2in <= 5;    in3in <= 10;
    
    #60
    in1p1 <= 28; in1p2 <= 12; in2in <= 15 ; in3in <= 20;
    #100
    in1p1 <= 18; in1p2 <= 0; in2in <= 15 ; in3in <= 20;
end

always
    #1 clk = ~clk;
    
endmodule
