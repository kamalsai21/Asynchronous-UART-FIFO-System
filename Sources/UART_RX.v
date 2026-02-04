`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IISc
// Engineer: Malla Kamal Sai
// 
// Create Date: 02/04/2026 04:50:20 PM
// Design Name: 
// Module Name: UART_RX
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

module UART_RX #(   parameter Width = 8,
                    parameter Depth = 16,
                    parameter Addr = 5)(
    input rx_clk,
    input reset,
    input rx_serial,
    output rx_busy,
    output [7:0] rx_data,
    output reg rx_done
    );
    localparam  IDLE = 3'b000,
                START = 3'b001,
                DATA = 3'b010,
                HOLD1 = 3'b011,
                HOLD2 = 3'b100,
  				PARITY = 3'b101,
                STOP = 3'b110;
    reg [2:0] state, next_state;
    reg [2:0] count;
    reg test;
    reg [7:0] data_reg;
    reg [7:0] sample_cnt;
  	wire parity_bit;
    always@(posedge rx_clk or posedge reset)
    begin
        if(reset)
        begin
            state <= IDLE;
        end
        else
        begin
            state <= next_state;
        end
    end
    always@(*)
    begin
        case(state)
            IDLE:   next_state = rx_serial ? IDLE : START;
            START:  next_state = (sample_cnt == 16) ? DATA : START; 
          	DATA:   next_state = ((count == 7) && (sample_cnt == 16)) ? PARITY : DATA;
          	PARITY:	next_state = (sample_cnt == 16) ? ((parity_bit != rx_serial) ? IDLE : STOP) : PARITY; //Parity Bit Check
            STOP:   next_state = (sample_cnt == 16) ? (rx_serial ? IDLE : STOP) : STOP; 
            default:next_state = IDLE;
        endcase
    end
    always@(posedge rx_clk or posedge reset)
    begin
        if(reset)
        begin
            data_reg <= 8'd0;
            rx_done <= 1'b0;
            count <= 0;
                        
        end
        else
        begin
            rx_done <= 0;                                               
            if((state == DATA || state == START) && sample_cnt == 16)
            begin
                count <= count + 1;
                test <= rx_serial;
                data_reg <= {rx_serial,data_reg[7:1]};
            end
            else if((state == STOP) && sample_cnt == 16)
            begin
                if(rx_serial) //Check Stop Bit
                begin
                    rx_done <= 1'b1; //Assert Done Signal
                end
                else
                begin
                    rx_done <= 1'b0;
                end
            end
        end
    end
    always@(posedge rx_clk or posedge reset)
    begin
        if(reset)
        begin
            sample_cnt <= 0;
        end
        else
        begin
            if(sample_cnt == 16)
            begin
                sample_cnt <= 0;
            end
            else if(state == IDLE)
                sample_cnt <= 0;
            else
            begin
                sample_cnt <= sample_cnt + 1;
            end
        end
    end
    assign parity_bit = ^data_reg;//Bit wise XOR to generate Parity Bit    
    assign rx_busy = (state != IDLE);
	assign rx_data = data_reg;	
endmodule
