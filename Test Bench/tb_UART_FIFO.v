`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2026 11:04:51 PM
// Design Name: 
// Module Name: tb_UART_FIFO
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
`timescale 1ns/1ps

module tb_UART_FIFO;

    // -------- DUT signals --------
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg data_valid;

    wire [7:0] data_out;

    // -------- Create 50 MHz clock (20 ns period) --------
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // -------- Instantiate your design --------
    UART_FIFO DUT (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_valid(data_valid),
        .data_out(data_out)
    );

    // -------- Monitor clocks for debugging --------
    always #1 begin
        $display("time=%0t  clk=%b  tx_clk=%b  rx_clk=%b",
                  $time, clk,
                  DUT.tx_clk,
                  DUT.rx_clk);
    end

    // -------- Test procedure --------
    initial begin

        $display("\n===== SINGLE BYTE UART_FIFO TEST =====\n");

        // Reset
        reset = 1;
        data_in = 8'h00;
        data_valid = 0;

        #200;
        reset = 0;
        #200;

        // -------- Send ONE byte --------
        $display("Sending 0xA5 ...");

        data_in = 8'hA5;   // 1010_0101
        data_valid = 1;    // write to TX FIFO
        #20;
        data_valid = 0;

        // -------- Wait long enough for UART transfer --------
        #5_000_000;   // 5 ms (plenty for 9600 baud)

        // -------- Check result --------
        $display("Received = %h", data_out);

        if (data_out === 8'hA5)
            $display("✅ PASS: Correct byte received!");
        else
            $display("❌ FAIL: Expected A5 but got %h", data_out);

        $finish;
    end

endmodule



