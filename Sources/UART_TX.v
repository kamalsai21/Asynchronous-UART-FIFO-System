`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 11:52:38 PM
// Design Name: 
// Module Name: UART_TX
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


module UART_TX #(   parameter Width = 8,
                    parameter Depth = 16,
                    parameter Addr = 5)(
    input tx_clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output tx_busy,
    output reg tx_serial
    );
    localparam  IDLE = 3'b000,
                START = 3'b001,
                DATA = 3'b010,
  				PARITY = 3'b011,
                STOP = 3'b100;
    reg [2:0] state, next_state;
    reg [2:0] count;
    reg [7:0] data_reg;
  	wire parity_bit;
    always@(posedge tx_clk or posedge reset)
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
            IDLE:   next_state = tx_start ? START : IDLE;
            START:  next_state = DATA;
          	DATA:   next_state = (count == 7) ? PARITY : DATA;
          	PARITY:	next_state = STOP;
            STOP:   next_state = IDLE; 
            default:next_state = IDLE;
        endcase
    end
    always@(posedge tx_clk or posedge reset)
    begin
        if(reset)
        begin
            count <= 0;
        end
        else
        begin
            case(state)
                IDLE:   begin
                            count <= 0;
                            data_reg <= 0;
                        end
                START:  begin
                            count <= 0;
                            data_reg <= tx_data;
                        end
                DATA:   begin
                            count <= count + 1'b1;                            
                        end
                STOP:   begin
                            count <= 0;
                        end                        
                default:count <= 0;
            endcase
        end
    end
    always@(posedge tx_clk or posedge reset)
    begin
        if(reset)
        begin
            tx_serial <= 1;
        end
        else
        begin
            case(state)
                IDLE:   begin
                            tx_serial <= 1'b1;
                        end
                START:  begin
                            tx_serial <= 1'b0;//Start Bit
                        end
                DATA:   begin
                            tx_serial <= data_reg[count];//Data                            
                        end
              	PARITY:	begin
                  			tx_serial <= parity_bit;//Parity Bit
                		end
                STOP:   begin
                            tx_serial <= 1'b1;//Stop Bit
                        end                        
                default:tx_serial <= 1'b1;
            endcase
        end
    end
    assign parity_bit = ^tx_data;//Bit wise XOR to generate Parity Bit    
    assign tx_busy = (state != IDLE);                           
endmodule
