task spi_init;
    begin
        sclk = 0;
        csb = 1;
        mosi = 0;
    end
endtask

task spi_start;
    begin
        #(SPI_PERIOD/2);
        csb = 0;
    end
endtask

task spi_stop;
    begin
        csb = 1;
        #(SPI_PERIOD/2);
    end
endtask

task spi_put_byte;
    input [7:0] data;
    integer i;
    begin
        sclk = 0;

        for (i=7;i>=0;i=i-1)
        begin
            mosi = data[i];
            #(SPI_PERIOD/2);
            sclk = 1;
            #(SPI_PERIOD/2);
            sclk = 0;
        end
    end
endtask


task spi_get_byte;
    output [7:0] data;
    integer i;
    begin
        #(SPI_PERIOD/2);
        sclk = 0;

        for (i=7;i>=0;i=i-1)
        begin
            #(SPI_PERIOD/2);
            sclk = 1;
            #(SPI_PERIOD/2);
            sclk = 0;
            data[i] = miso;
        end
    end
endtask

task spi_read;
    input [7:0] rd_addr;
    output [7:0] rd_data;

    begin
        spi_start;
        spi_put_byte(SPI_READ_BYTE);
        #(SPI_PERIOD*3);
        spi_put_byte(rd_addr);
        check_rd_req(1'b1);
        #(SPI_PERIOD*3);
        spi_get_byte(rd_data);
        check_rd_req(1'b0);
        #(SPI_PERIOD*3);
        spi_stop;
    end
endtask

task check_wr_req;
    input wr_req_expected;
    begin
        check_cnt = check_cnt + 1;
        if (wr_req !== wr_req_expected)
        begin
            error_cnt = error_cnt + 1;
            $display("incorrect wr_req value! expected %b got %b",wr_req_expected,wr_req);
        end
    end
endtask

task check_rd_req;
    input rd_req_expected;
    begin
        check_cnt = check_cnt + 1;
        if (rd_req !== rd_req_expected)
        begin
            error_cnt = error_cnt + 1;
            $display("incorrect rd_req value! expected %b got %b",rd_req_expected,rd_req);
        end
    end
endtask



task spi_write_check;
    input [7:0] wr_addr;
    input [7:0] wr_data;

    begin
        spi_start;
        spi_put_byte(SPI_WRITE_BYTE);
        #(SPI_PERIOD*3);
        spi_put_byte(wr_addr);
        #(SPI_PERIOD*3);
        spi_put_byte(wr_data);

        check_wr_data(wr_addr, wr_data);
        check_wr_req(1'b1);
        #(SPI_PERIOD*3);
        spi_stop;
        check_wr_req(1'b0);
    end
endtask

task test_spi_read;
    begin
        spi_addr = $random;
        rd_mem(spi_addr, dut_rd_data);
        spi_read(spi_addr, spi_rd_data);
        check_rd_data(spi_addr, spi_rd_data);
    end
endtask

task test_spi_write;
    begin
        spi_addr = $random;
        spi_wr_data = $random;
        spi_write_check(spi_addr, spi_wr_data);
        spi_read(spi_addr, spi_rd_data);
        check_rd_data(spi_addr, spi_rd_data);
    end
endtask
