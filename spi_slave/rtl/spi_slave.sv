module spi_slave
#(   
    parameter NB_DATA = 8,
    parameter NB_ADDR = 8
) (
    input   wire                    resetb  ,
    input   wire                    sclk    ,
    input   wire                    csb     , // Chip select signal (active low)
    input   wire                    mosi    , // Master Out Slave In data line
    input   wire [NB_DATA - 1 : 0]  rd_data , // Data read from memory

    output  wire                    miso    , // Master In Slave Out data line
    output  wire [NB_ADDR - 1 : 0]  addr_out, // Address output for memory access
    output  wire [NB_DATA - 1 : 0]  wr_data , // Data to be written to memory.
    output  wire                    wr_req  , // Write request signal. Must rise on the last SCLK pulse of the data word on SPI write frame to trigger the memory write operation
    output  wire                    rd_req  , // Read request signal. Must rise on the last SCLK pulse of the address word on the SPI read frame to trigger the memory read operation
);


    // byte counter

    localparam NB_COUNT = $clog2(NB_DATA);
    reg [NB_COUNT - 1 : 0] count;
    always @() begin
        
    end

    reg [NB_DATA - 1 : 0] sr;


    // fsm

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_HEAD,
        STATE_ADDR,
        STATE_EXEC
    } state_t;

    state_t current_state, next_state;

    always @() begin
        
    end


endmodule