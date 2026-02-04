# Asynchronous UART–FIFO Loopback System (Verilog)

## 1. Specifications  

This project implements a complete UART-based communication subsystem with the following specifications:  

- **Data width:** 8-bit  
- **UART frame format:**  
  - 1 Start bit (0)  
  - 8 Data bits (LSB first)  
  - 1 Even Parity bit  
  - 1 Stop bit (1)  
- **Baud rate:** 9600 bits per second  
- **System clock:** 50 MHz  
- **Receiver oversampling rate:** 16× baud (153.6 kHz)  
- **Transmit clock:** 1× baud (9600 Hz)  
- **FIFO depth:** 16 entries per FIFO  
- **Number of FIFOs used:** 2 (one on TX side, one on RX side)  
- **Clock domains:**  
  - System clock domain (50 MHz)  
  - UART TX clock domain (9600 Hz)  
  - UART RX clock domain (153.6 kHz)  

---

## 2. What is UART?  

UART (Universal Asynchronous Receiver Transmitter) is a serial communication protocol used for point-to-point data transfer between two devices without a shared clock. Instead of sending multiple bits in parallel, UART transmits data one bit at a time over a single wire.  

A UART transmission begins with a **start bit (0)**, followed by **data bits**, an optional **parity bit** for error detection, and ends with a **stop bit (1)**. Because it is asynchronous, both transmitter and receiver must agree on a common baud rate, but they do not share a clock.  

In this project, UART is used as the communication medium between two independent clock domains, demonstrating how serial communication can bridge different parts of a digital system.

---

## 3. What is an Asynchronous FIFO and how is it used here?  

An **asynchronous FIFO** is a memory buffer that allows data to be written in one clock domain and read in another clock domain safely. It uses separate read and write pointers, along with synchronization logic, to prevent metastability and data corruption across clock boundaries.  

In this system, two asynchronous FIFOs are used:  

- **FIFO_TX:**  
  - Write clock = system clock (50 MHz)  
  - Read clock = UART TX clock (9600 Hz)  
  - Purpose: Decouples fast system logic from slow UART transmission  

- **FIFO_RX:**  
  - Write clock = UART RX clock (153.6 kHz)  
  - Read clock = system clock (50 MHz)  
  - Purpose: Buffers received data before it is processed by the main system  

These FIFOs ensure reliable clock domain crossing (CDC) while allowing continuous data flow between different timing domains.

---

## 4. What exactly I did in this project  

### Module Integration  

I built and connected the following modules inside a top-level module named `UART_FIFO`:  

1. **Baud_Rate_Generator**  
   - Generates `tx_clk` (9600 Hz) and `rx_clk` (153.6 kHz) from a 50 MHz system clock.  

2. **FIFO_TX (asynchronous FIFO)**  
   - Receives parallel input data from the system clock domain.  
   - Feeds data to the UART transmitter at the baud clock rate.  

3. **UART_TX (Transmitter)**  
   - Reads data from FIFO_TX.  
   - Serializes it into a UART frame (start, data, parity, stop).  
   - Uses `tx_busy` to control when new data can be sent.  

4. **UART_RX (Receiver)**  
   - Receives serial data from UART_TX via a loopback connection.  
   - Uses 16× oversampling for robust bit recovery.  
   - Performs parity and stop-bit validation.  
   - Generates a single-cycle `rx_done` pulse when a valid byte is received.  

5. **FIFO_RX (asynchronous FIFO)**  
   - Stores received bytes from UART_RX in the UART RX clock domain.  
   - Makes them available to the system clock domain as `data_out`.  

### How UART connects the two FIFOs  

The two FIFOs are indirectly connected through the UART channel:  

- Data moves from **FIFO_TX → UART_TX → serial line → UART_RX → FIFO_RX**.  
- UART acts as the **communication bridge** between the two asynchronous FIFOs operating in different clock domains.  

### Validation of UART  

I validated the UART subsystem using a delay-based testbench (`tb_UART_FIFO.v`) that:  

- Writes a known byte (e.g., 0xA5) into FIFO_TX  
- Waits for serialization and deserialization  
- Reads back the received byte from FIFO_RX  
- Compares input and output to confirm correctness  

Additionally, I monitored `tx_clk`, `rx_clk`, `tx_busy`, `rx_done`, and the serial line to debug timing alignment and ensure correct sampling.

### Extensibility for future projects  

Because the transmitter and receiver are connected via a single serial line, **any external device** (e.g., Bluetooth module, microcontroller, FPGA board, or PC UART) can be inserted between them in the future. The system can then function as a real hardware communication link instead of a loopback test.

---

## 5. What I learned in this project  

Through this project, I gained hands-on experience in:  

- Designing and debugging multi-clock digital systems  
- Implementing and validating UART communication in RTL  
- Understanding oversampling and timing alignment in serial reception  
- Applying Clock Domain Crossing (CDC) techniques using asynchronous FIFOs  
- Designing finite state machines for both transmitter and receiver  
- Debugging real-world timing issues such as sampling errors, metastability, and reset artifacts  
- Integrating multiple modules into a cohesive system-level design  

This project strengthened my ability to build reliable communication interfaces in hardware.

---

## 6. Future Applications  

This design can be extended in several meaningful ways:  

- Interface with real hardware UART devices such as microcontrollers or PCs  
- Add multi-byte packet framing and checksum verification  
- Implement flow control using RTS/CTS signals  
- Increase baud rate for higher-speed communication  
- Replace loopback with wireless modules (Bluetooth, RF, or Wi-Fi)  
- Integrate with an FPGA SoC for real-time embedded communication  
- Expand to support multi-channel UART communication  

Overall, this project serves as a reusable foundation for advanced digital communication systems in FPGA and embedded platforms.


