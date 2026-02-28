task fill_mem;
    reg [7:0] addr;
    begin
        for(addr=255;addr>0;addr=addr-'d1)
        begin
            mem[addr] = $random;
        end
    end
endtask

task wr_mem;
    input [7:0] addr;
    input [7:0] data;
    begin
        mem[addr] = data;
    end
endtask

task rd_mem;
    input [7:0] addr;
    output [7:0] data;
    begin
        data = mem[addr];
    end
endtask

task check_rd_data;
    input [7:0] addr;
    input [7:0] spi_rd_data;
    begin
        check_cnt = check_cnt + 1;
        if (spi_rd_data !== dut_rd_data)
        begin
            error_cnt = error_cnt + 1;
            $display("incorrect READ at addr %H! expected %H got %H",addr,dut_rd_data,spi_rd_data);
        end
    end
endtask

task check_wr_data;
    input [7:0] addr;
    input [7:0] spi_wr_data;
    begin
        check_cnt = check_cnt + 1;
        if (spi_wr_data !== dut_wr_data)
        begin
            error_cnt = error_cnt + 1;
            $display("incorrect WRITE at addr %H! expected %H got %H",addr,spi_wr_data,dut_wr_data);
        end
    end
endtask