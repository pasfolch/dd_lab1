# Lab 1: Coding for synthesis and basic blocks

In this lab, you will implement several of the fundamental digital design blocks discussed during the theory session, including a controller for an SPI configuration interface and a basic register map. For each block, you will run a simple simulation in which the testbench verifies that your design under test behaves according to the specified requirements.

# Evaluation

You are required to produce a lab report that documents the actions and experiments described in this guide. Present the results of your experiments using text, screenshots, or any other appropriate media.

## Evaluation rubric

The following breakdown shows how each section of this lab contributes to the overall marks:

- SPI compiles: 1 point
- SPI no write errors: 2 points
- SPI no read errors: 2 points
- Register map compiles: 1 point
- Register map no write errors: 2 points
- Register map no read errors: 2 points
  
# SPI slave
On this section we will create an SPI bus controller that will act as a slave, responding to write and read requests.

## Design description
You must create a design that implements an SPI (Serial Peripheral Interface) slave module. The module communicates with an SPI master device to read from or write to a memory location.

## SPI frame format
As we saw in the theory section there is no fixed specification for SPI frame format, so we will define our own.

We will define 2 frame types: write frames and read frames. In each of these types the transactions will be structured around 8 bit words in all cases. Addresses and data words will be 8 bits wide each.

In the write frame all the words will be sent from the SPI master to the SPI slave. Write frames contain a header with value 0x00. Then the 8 bits address will be transmitted, this address will determine which memory position the transactionm will write to. Finally an 8 bit write data word will be transmitted to completely define the write transaction.

In the read frame almost all words will be sent from the SPI master to the SPI slave, except for the read data word which will be sent from the SPI slave to the SPI master. Following the structure of the write frames the first word is a header to signal the read transaction, with the value 0x80. Next comes the address word that the SPI master wishes to read from the slave. Finally the SPI slave will respond with the byte contained in the memory position requested by the SPI master.

In all these transactions the CSb line will be zero since it is active low. Serial data will be launched and captured by the SPI master with the falling edge of SCLK. Data will be launched and captured by the SPI slave with the rising edge of SCLK.

- SPI write frame

|word type| header 	| address 	| write data 	|
|:---:|:---:|:---:|:---:|
|word size|8 bits|8 bits| 8 bits|
|direction|master to slave|master to slave|master to slave|

- SPI read frame

|word type| header 	| address 	| read data 	|
|:---:|:---:|:---:|:---:|
|word size|8 bits|8 bits| 8 bits|
|direction|master to slave|master to slave|slave to master|


## Design ports

This is a breakdown of the input and output ports that the design must contain. The testbench will connect to these signals to stimulate and analyze the design behavior. Your design must respond to the inputs and produce the expected outputs.

- Inputs: 

    - resetb: Active low reset signal.
    - sclk: Serial clock signal.
    - csb: Chip select signal (active low).
    - mosi: Master Out Slave In data line.
    - rd_data[7:0]: Data read from memory.

- Outputs:

    - miso: Master In Slave Out data line.
    - addr_out[7:0]: Address output for memory access.
    - wr_data[7:0]: Data to be written to memory.
    - wr_req: Write request signal. Must rise on the last SCLK pulse of the data word on SPI write frame to trigger the memory write operation.
    - rd_req: Read request signal. Must rise on the last SCLK pulse of the address word on the SPI read frame to trigger the memory read operation.

## Testbench and simulation

First of all execute the script to load the paths to Cadence simulator:

> source /eda/cdsenv.sh

Now you can kick off the simulation by running the script in spi_slave/sim/run_sim. This scripts expects that the RTL for the SPI slave design is placed in spi_slave/rtl/spi_slave.v

The testbench will produce all the stimulus required for the simulation like producing a reset pulse, toggling the SPI lines and updating the rd_data value when a read operation is requested. The testbench will also check that the SPI write and read operations are honoured by the design, producing an error message if any bad condition is detected.

After a few write and read operations the simulation will finish, and a summary message will be printed out to the terminal, reflecting how many checks the testbench performed, how many errors were detected. If no errors were detected the simulation will be marked as passed, otherwise it will be marked as fail. Creating a complete design that follows these specifications will allow you to pass the simulation.

# Register map

On this section you will create a simple register that will hold registers to control the operation of the IC and to monitor the status of some of its blocks.

## Register map content
The following table describes the registers present in the register map. Analyze it in detail and notice the type of each register, be it read-write, or read-only. Also notice how a default value is set for the read-write registers. This is the value at which each register will be updated following a reset pulse.


| address 	| register name 	| bit[7] 	| bit[6] 	| bit[5] 	| bit[4] 	| bit[3] 	| bit[2] 	| bit[1] 	| bit[0] 	| default value 	| type 	|
|---------	|---------------	|--------	|--------	|--------	|--------	|--------	|--------	|--------	|--------	|---------------	|------	|
|0x00|power down|master_powerdown|afe_powerdown|aaf_powerdown|pga_powerdown|pll_powerdown|pads_powerdown|0|0|0x80|read/write|
|0x10|status|pll_locked|pll_in_range|pga_saturate|vco_gear[1]|vco_gear[0]|0|0|0|NA|read-only|
|0x34|tx_controls|tx_enable|tx_clk_gen_enable|tx_despreader_enable|tx_freq_diversity_enable|tx_lane_sel[1]|tx_lane_sel[0]|0|0|0x84|read/write|
|0x48|rx_packets|0|rx_status_packet_detected|rx_infoframe_detected|rx_color_correct_detected|rx_content_protection_detected|rx_video_id_detected|rx_audio_id_detected|rx_aux_data_detected|NA|read-only|
|0x52|tx_serdes_controls|tx_slew_rate[2]|tx_slew_rate[1]|tx_slew_rate[0]|tx_phase_interpolation[1]|tx_phase_interpolation[0]|0|0|0|0xF0|read/write|
|0x68|rx_audio_out|rx_audio_out_enable[3]|rx_audio_out_enable[2]|rx_audio_out_enable[1]|rx_audio_out_enable[0]|rx_audio_out_format[1]|rx_audio_out_format[0]|0|0|0xFC|read/write|

## Design ports

This is a breakdown of the input and output ports that the design must contain. The testbench will connect to these signals to stimulate and analyze the design behavior. Your design must respond to the inputs and produce the expected outputs.

- Inputs

    - clk: Clock signal
    - resetb: Active low reset signal
    - wr_req: Write request signal
    - rd_req: Read request signal
    - data_in[7:0]: Data input bus
    - addr_in[7:0]: Address input bus
    - status bits: any bit in register map that belongs to a read-only register

- Outputs
    - data_out[7:0]: Data output bus
    - control bits: any bit in register map that belongs to a read-write register
    
## Testbench and simulation

You can kick off the simulation by running the script in register_map/sim/run_sim. This scripts expects that the RTL for the register map design is placed in register_map/rtl/register_map.v

The testbench will produce all the stimulus required for the simulation like producing a reset pulse, generating a free-running clock to clock the design and performing read and write requests to the register map to exercise the status and control bits. 

The testbench will also check that the register map write and read operations are honoured by the design, producing an error message if any bad condition is detected.

After a few write and read operations the simulation will finish, and a summary message will be printed out to the terminal, reflecting how many checks the testbench performed, how many errors were detected. If no errors were detected the simulation will be marked as passed, otherwise it will be marked as fail. Creating a complete design that follows these specifications will allow you to pass the simulation.
