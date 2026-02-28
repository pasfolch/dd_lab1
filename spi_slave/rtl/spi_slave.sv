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

    output  reg                     miso    , // Master In Slave Out data line
    output  reg  [NB_ADDR - 1 : 0]  addr_out, // Address output for memory access
    output  reg  [NB_DATA - 1 : 0]  wr_data , // Data to be written to memory.
    output  reg                     wr_req  , // Write request signal. Must rise on the last SCLK pulse of the data word on SPI write frame to trigger the memory write operation
    output  reg                     rd_req    // Read request signal. Must rise on the last SCLK pulse of the address word on the SPI read frame to trigger the memory read operation
);


    // byte counter

    localparam NB_COUNT = $clog2(NB_DATA);

    reg  [NB_COUNT - 1 : 0] count;
    wire [NB_COUNT - 1 : 0] count_next;
    wire                    count_limit;

    assign count_next  =  count + 1'b1;   
    assign count_limit = (count >= NB_DATA);

    always @(posedge sclk or negedge resetb) begin
        if ((!resetb) | count_limit) begin
            count <= {NB_COUNT{1'b0}};
        end else begin
            count <= count_next;
        end
    end

    // shift register to store bytes

    reg  [NB_DATA - 1 : 0] sr;

    always @(posedge sclk or negedge resetb) begin
        if (!resetb) begin
            sr <= {NB_DATA{1'b0}};
        end else begin
            sr <= {sr[NB_DATA - 2 : 1], mosi};
        end
    end

    // fsm

    typedef enum logic [2:0] {
        STATE_IDLE  = 3'b000,
        STATE_HEAD  = 3'b001,
        STATE_ADDR  = 3'b010,
        STATE_READ  = 3'b011,
        STATE_WRITE = 3'b100
    } state_e;

    state_e state, next;

    always @(posedge sclk or negedge resetb) begin
        if ((!resetb) | csb) begin
            state <= STATE_IDLE;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        case (state)
            STATE_IDLE: begin
                next = (csb)? STATE_IDLE : STATE_HEAD;
            end 
            STATE_HEAD: begin
                next = (count_limit)? STATE_ADDR : STATE_HEAD;
            end
            STATE_ADDR: begin
                next = (count_limit & (sr == {NB_DATA{1'b0}}))? STATE_WRITE : STATE_READ;
            end
            STATE_READ: begin
                next = (count_limit)? STATE_IDLE : STATE_READ;
            end
            STATE_WRITE: begin
                next = (count_limit)? STATE_IDLE : STATE_WRITE;
            end
            default: next = STATE_IDLE;
        endcase
    end

    always @(*) begin
        case (state)
            STATE_IDLE: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
            STATE_HEAD: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
            STATE_ADDR: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
            STATE_READ: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
            STATE_WRITE: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
            default: begin
                miso     =          1'b0;
                addr_out = {NB_ADDR{1'b0}};
                wr_data  = {NB_DATA{1'b0}};
                wr_req   =          1'b0;
                rd_req   =          1'b0;
            end
        endcase
    end


endmodule