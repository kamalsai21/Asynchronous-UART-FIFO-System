`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IISc
// Engineer: Malla Kamal Sai
// 
// Create Date: 02/04/2026 01:23:56 AM
// Design Name: 
// Module Name: tb_UART_TX
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


module tb_UART_TX;

    // -------- Parameters --------
    localparam BAUD_PERIOD = 8680;   // ~115200 baud @ 1ns timescale

    // -------- DUT signals --------
    reg        tx_clk;
    reg        reset;
    reg        tx_start;
    reg [7:0]  tx_data;
    wire       tx_busy;
    wire       tx_serial;

    integer i;
    integer errors = 0;

    // Expected bit stream (LSB first)
    reg [10:0] expected_bits;
    reg [10:0] captured_bits;

    // -------- Instantiate DUT --------
    UART_TX DUT (
        .tx_clk   (tx_clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_busy  (tx_busy),
        .tx_serial(tx_serial)
    );

    // -------- Baud clock generation --------
    initial begin
        tx_clk = 0;
        forever #(BAUD_PERIOD/2) tx_clk = ~tx_clk;
    end

    // -------- Build expected UART frame --------
    task build_expected_frame(input [7:0] data);
        reg parity;
        begin
            parity = ^data;   // even parity (change if needed)

            expected_bits = {
                1'b1,        // STOP bit
                parity,      // PARITY bit
                data,        // 8 data bits (LSB first in transmission)
                1'b0         // START bit
            };
        end
    endtask

    // -------- Test procedure --------
    initial begin
        $display("\n===== BIT-ACCURATE UART_TX TEST =====");

        reset    = 1;
        tx_start = 0;
        tx_data  = 8'hA5;   // 1010_0101

        #(BAUD_PERIOD*2);
        reset = 0;

        repeat(3) @(posedge tx_clk);

        // Build what we EXPECT to see on tx_serial
        build_expected_frame(tx_data);

        // Pulse tx_start for one baud cycle
        @(posedge tx_clk);
        tx_start <= 1;
        @(posedge tx_clk);
        tx_start <= 0;

        $display("Sending 0xA5...");

        // -------- Capture the transmitted bits --------
        i = 0;
        captured_bits = 0;

        // Wait for START bit to appear
        wait(tx_serial === 1'b0);

        // Sample exactly 11 bit times (start + 8 data + parity + stop)
        for (i = 0; i < 11; i = i + 1) begin
            @(posedge tx_clk);
            captured_bits[i] = tx_serial;
        end

        // -------- Compare expected vs captured --------
        $display("Expected bits : %b", expected_bits);
        $display("Captured bits : %b", captured_bits);

        if (captured_bits !== expected_bits) begin
            $error("ERROR: UART bitstream mismatch!");
            errors = errors + 1;
        end else begin
            $display("✔ Bitstream correct!");
        end

        // Check idle after transmission
        @(posedge tx_clk);
        if (tx_serial !== 1'b1) begin
            $error("ERROR: TX not high in IDLE after transmission");
            errors = errors + 1;
        end

        // -------- Final result --------
        # (BAUD_PERIOD);
        if (errors == 0)
            $display("\n TEST PASSED - all bits correct.");
        else
            $display("\n TEST FAILED - %0d errors detected.", errors);

        $finish;
    end

endmodule


