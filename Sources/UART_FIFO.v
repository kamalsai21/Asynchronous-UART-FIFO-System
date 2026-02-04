`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IISc
// Engineer: Malla Kamal Sai
// 
// Create Date: 02/04/2026 10:18:15 PM
// Design Name: 
// Module Name: UART_FIFO
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


module UART_FIFO(
    input clk,
    input reset,
    input [7:0] data_in,
    input data_valid,
    output [7:0] data_out
    );
    wire tx_clk, rx_clk;
    wire tx_fifo_full, tx_fifo_empty;
    wire rx_fifo_full, rx_fifo_empty;
    wire tx_busy,rx_busy;//rx_busy useless
    wire rx_done;
    reg rx_reset_garbage;//reset garbage value emmission
    wire [7:0] tx_fifo_data_out;
    wire [7:0] rx_data;
    wire serial_data;
    reg rx_read_enable;
    reg tx_start;
    reg tx_fifo_wr_en,tx_fifo_rd_en;
    reg rx_fifo_wr_en;
    wire rx_fifo_rd_en;
    reg [7:0] tx_data;
    
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            tx_fifo_wr_en <= 0;
            rx_read_enable <= 0;
        end
        else
        begin
            tx_fifo_wr_en <= data_valid;
        end
    end
    assign rx_fifo_rd_en = ~rx_fifo_empty;
    always@(posedge tx_clk or posedge reset)
    begin
        if(reset)
        begin
            tx_start <= 0;
            tx_data <= 0;
            tx_fifo_rd_en <= 0;
        end
        else
        begin
            if((tx_fifo_empty==0)&&(tx_busy==0))
            begin
                tx_start =1'b1;
                tx_fifo_rd_en = 1'b1;
            end
            else
            begin
                tx_start =1'b0;
                tx_fifo_rd_en = 1'b0;
            end
            tx_data <= tx_fifo_data_out;
        end
    end
    always@(posedge rx_clk or posedge reset)
    begin
        if(reset)
        begin
            rx_fifo_wr_en <= 0;
            rx_reset_garbage <= 0;
        end
        else
        begin
            if(rx_done)
                rx_reset_garbage <= 1;
            rx_fifo_wr_en <= ~rx_fifo_full & rx_done;
        end
    end
    
    Baud_Rate_Generator m0 (.clk(clk), .reset(reset), 
                .tx_clk(tx_clk), .rx_clk(rx_clk));
                
    UART_TX m1 (.tx_clk(tx_clk), .reset(reset), 
                .tx_start(tx_start), .tx_data(tx_data), 
                .tx_busy(tx_busy), .tx_serial(serial_data));
                
    FIFO m2 (.wr_clk(clk), .rd_clk(tx_clk), //FIFO_TX
                .wr_reset(reset), .rd_reset(reset), 
                .wr_en(tx_fifo_wr_en), .rd_en(tx_fifo_rd_en),
                .data_in(data_in), 
                .full(tx_fifo_full), .empty(tx_fifo_empty),
                .data_out(tx_fifo_data_out));
                
    UART_RX m3 (.rx_clk(rx_clk), .reset(reset),
                .rx_serial(serial_data),
                .rx_busy(rx_busy), .rx_data(rx_data),
                .rx_done(rx_done));
                
    FIFO m4 (.wr_clk(rx_clk), .rd_clk(clk), //FIFO_RX
                .wr_reset(reset), .rd_reset(reset), 
                .wr_en(rx_fifo_wr_en), .rd_en(rx_fifo_rd_en),
                .data_in(rx_data), 
                .full(rx_fifo_full), .empty(rx_fifo_empty),
                .data_out(data_out));                     
endmodule
