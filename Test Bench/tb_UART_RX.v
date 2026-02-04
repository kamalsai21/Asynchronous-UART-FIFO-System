`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2026 07:15:54 PM
// Design Name: 
// Module Name: tb_UART_RX
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
module tb_UART_RX;

    // -------- Parameters --------
    parameter BAUD_PERIOD = 8680;   // ~115200 baud @ 1ns timescale

    // -------- DUT signals --------
    reg        rx_clk;
    reg        reset;
    reg  rx_serial;
    wire       rx_busy;
    wire [7:0] rx_data;
    wire       rx_done;

    integer i;
    integer errors;
    reg parity;

    // -------- Instantiate YOUR receiver --------
    UART_RX DUT (
        .rx_clk   (rx_clk),
        .reset    (reset),
        .rx_serial(rx_serial),
        .rx_busy  (rx_busy),
        .rx_data  (rx_data),
        .rx_done  (rx_done)
    );

    // -------- Baud clock generation --------
    initial begin
        rx_clk = 0;
        forever #(BAUD_PERIOD/2) rx_clk = ~rx_clk;
    end

    // ----------------------------------------------------
    // MAIN TEST
    // ----------------------------------------------------
    initial begin
        $display("\n===== UART_RX SELF-CHECKING TEST (Verilog) =====");

        errors = 0;
        reset = 1;
        
        rx_serial = 1;   // idle line is high

        #(5*BAUD_PERIOD);
        reset = 0;
        #(1*BAUD_PERIOD);
        // ================= TEST 1: Send 0x3C =================
        $display("Sending 0x3C...");

        parity = ^8'hA5;   // compute even parity

        // START bit
        rx_serial = 0;
        #(BAUD_PERIOD);

        // DATA bits (LSB first)
        rx_serial = 0;  // bit 0
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 1
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 2
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 3
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 4
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 5
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 6
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 7
        #(BAUD_PERIOD);

        // PARITY bit
        rx_serial = parity;
        #(BAUD_PERIOD);

        // STOP bit
        rx_serial = 1;
        #(BAUD_PERIOD);

        // Wait for receiver to finish
        wait(rx_done);

        if (rx_data !== 8'h3C) begin
            $display("ERROR: Expected 3C, got %h", rx_data);
            errors = errors + 1;
        end else begin
            $display("OK: Byte 3C received correctly.");
        end

        // ================= TEST 2: Send 0x9D =================
        $display("Sending 0x9D...");

        parity = ^8'h3C;

        // START
        rx_serial = 0;
        #(BAUD_PERIOD);

        // DATA bits (LSB first)
        rx_serial = 1;  // bit 0
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 1
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 2
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 3
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 4
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 5
        #(BAUD_PERIOD);
        rx_serial = 0;  // bit 6
        #(BAUD_PERIOD);
        rx_serial = 1;  // bit 7
        #(BAUD_PERIOD);

        // PARITY
        rx_serial = ~parity;//To check parity
        #(BAUD_PERIOD);

        // STOP
        rx_serial = 1;
        #(BAUD_PERIOD);
        

        if (rx_data !== 8'h9D) begin
            $display("ERROR: Expected 9D, got %h", rx_data);
            errors = errors + 1;
        end else begin
            $display("OK: Byte 9D received correctly.");
        end

        // ================= FINAL RESULT =================
        if (errors == 0)
            $display("\nTEST PASSED!");
        else
            $display("\nTEST FAILED: %0d errors", errors);

        $finish;
    end

endmodule





