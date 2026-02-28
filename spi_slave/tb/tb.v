`timescale 1ns/1ns

module tb();

parameter SPI_PERIOD = 22;

parameter   SPI_READ_BYTE   = 8'h80,
            SPI_WRITE_BYTE  = 8'h00;

// tb
reg clk, resetb;

// SPI
reg sclk, csb, mosi;
wire miso;
reg [7:0] spi_wr_data, spi_rd_data, dut_rd_data;
reg [7:0] spi_addr;
wire rd_req, wr_req;

// DUT
wire [7:0] dut_addr_out, dut_wr_data;

// mem
reg [7:0] mem [255:0];

// checks
integer error_cnt, check_cnt;

// clock generation
initial
begin
    clk = 0;

    forever
    begin
        # 10;
        clk = !clk;
    end
end

// reset generation
initial
begin

    resetb = 1'b1;
    repeat(5) @(negedge clk);
    resetb = 1'b0;
    repeat(5) @(negedge clk);
    resetb = 1'b1;
end

// SPI control
`include "../tb/spi_tasks.v"
`include "../tb/mem_tasks.v"
`include "../tb/tb_tasks.v"

initial
begin

    fill_mem;
    spi_init;

    @(posedge resetb);
    repeat(10) @(posedge clk);

    repeat(100)
    begin
        test_spi_read;
    end

    repeat(100)
    begin
        test_spi_write;
    end

    repeat(100) @(posedge clk);
    finish_sim;
end

initial
begin
    error_cnt = 0;
    check_cnt = 0;
end

spi_slave dut
(
    .resetb     (resetb),

    .sclk       (sclk),
    .csb        (csb),
    .mosi       (mosi),
    .miso       (miso),

    .rd_data    (dut_rd_data),
    .addr_out   (dut_addr_out),
    .wr_data    (dut_wr_data),
    .wr_req     (wr_req),
    .rd_req     (rd_req)
);

endmodule
