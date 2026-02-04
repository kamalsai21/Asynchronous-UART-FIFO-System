`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IISc
// Engineer: Malla Kamal Sai
// 
// Create Date: 02/03/2026 12:36:35 AM
// Design Name: 
// Module Name: Baud_Rate_Generator
// Project Name: UART_Protocol
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


module Baud_Rate_Generator(
    input clk,
    input reset,
    output reg tx_clk,
    output reg rx_clk
    );
    //Baud rate = 9600 bits/sec
    //clk = 50MHz
    //Over sampling Rate = 16
    //Counter_tx = 50MHz/(9600 bits/sec) = 5208 cycles
    //Counter_rx = 50MHz/16 X (9600 bits/sec) = 325 cycles
    reg [12:0] Counter_tx;
    reg [8:0] Counter_rx;
    always@(posedge clk)
    begin
        if(reset)
        begin
            Counter_tx <= 0;
            tx_clk <= 0;
        end
        else
        begin
            if(Counter_tx == 13'd5208)
            begin
                Counter_tx <= 0;
                tx_clk <= 1;
            end
            else
            begin
                Counter_tx <= Counter_tx + 1;
                tx_clk <= 0;
            end
        end
    end
    always@(posedge clk)
    begin
        if(reset)
        begin
            Counter_rx <= 0;
            rx_clk <= 0;
        end
        else
        begin
            if(Counter_rx == 9'd324)
            begin
                Counter_rx <= 0;
                rx_clk <= 1;
            end
            else
            begin
                Counter_rx <= Counter_rx + 1;
                rx_clk <= 0;
            end
        end
    end
endmodule
