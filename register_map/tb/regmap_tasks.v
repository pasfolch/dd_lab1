task init_interface;
    begin
        addr_in = 'd0;
        data_in = 'd0;
        {wr_req, rd_req} = 'd0;
    end
endtask

task write_reg;
    input [7:0] wr_addr;
    input [7:0] wr_data;
    begin

        @(negedge clk);
        addr_in = wr_addr;
        data_in = wr_data;
        wr_req = 1'b1;

        @(negedge clk);
        wr_req = 1'b0;
    end
endtask

task read_reg;
    input [7:0] rd_addr;
    output [7:0] rd_data;
    begin

        @(negedge clk);
        addr_in = rd_addr;
        rd_req = 1'b1;

        @(posedge clk);

        @(negedge clk);
        rd_req = 1'b0;

        @(posedge clk);
        rd_data = data_out;

    end
endtask

task check_reg;
    input [7:0] check_addr;
    begin
        read_reg(check_addr, dut_data);
        check_ok = dut_data === expected_data;
        check_cnt = check_cnt + 1;
        if (!check_ok)
        begin
            error_cnt = error_cnt + 1;
            $display("ERROR! register %H failed read check! Expected %H(%b) got %H(%b)",
                check_addr, expected_data, expected_data, dut_data, dut_data);
        end
    end
endtask

task check_data;
    input [7:0] check_addr;
    begin
        check_ok = dut_data === expected_data;
        check_cnt = check_cnt + 1;
        if (!check_ok)
        begin
            $display("ERROR! register %H failed data check! Expected %H(%b) got %H(%b)",
                check_addr, expected_data, expected_data, dut_data, dut_data);
            error_cnt = error_cnt + 1;
        end
    end
endtask


// read-only registers

task force_reg_10;
    begin
        {pll_locked,pll_in_range,pga_saturate,vco_gear} = $random;
    end
endtask

task check_reg_10;
    begin
        expected_data = {pll_locked,pll_in_range,pga_saturate,vco_gear,3'd0};
        check_reg(8'h10);
    end
endtask

task force_reg_48;
    begin
        {rx_status_packet_detected,rx_infoframe_detected,rx_color_correct_detected,rx_content_protection_detected,
        rx_video_id_detected,rx_audio_id_detected,rx_aux_data_detected} = $random;
    end
endtask

task check_reg_48;
    begin
        expected_data = {1'b0,rx_status_packet_detected,rx_infoframe_detected,rx_color_correct_detected,
        rx_content_protection_detected,rx_video_id_detected,rx_audio_id_detected,rx_aux_data_detected};
        check_reg(8'h48);
    end
endtask

task test_read_only_reg;
    input [7:0] addr_in;
    begin
        case(addr_in)
            8'h10:
            begin
                force_reg_10;
                check_reg_10;
            end
            8'h48:
            begin
                force_reg_48;
                check_reg_48;
            end
        endcase
    end
endtask

// read-write registers

task get_reg_mask;
    input [7:0] addr_in;
    output [7:0] mask_out;
    begin
        case(addr_in)
            8'h00:mask_out=8'hFC;
            8'h34:mask_out=8'hF8;
            8'h52:mask_out=8'hF8;
            8'h68:mask_out=8'hFC;
        endcase
    end
endtask

task check_reg_34;
    begin
        check_reg(8'h34);
        dut_data = {tx_enable,tx_clk_gen_enable,tx_despreader_enable,tx_freq_diversity_enable,tx_lane_sel,1'b0,1'b0};
        check_data(8'h34);
    end
endtask

task test_read_write_reg;
    input [7:0] addr_in;
    begin
        expected_data = $random;
        get_reg_mask(addr_in, reg_mask);
        expected_data = expected_data & reg_mask;

        write_reg(addr_in, expected_data);

        check_reg(addr_in);
        case(addr_in)
            8'h34:dut_data = {tx_enable,tx_clk_gen_enable,tx_despreader_enable,tx_freq_diversity_enable,tx_lane_sel,1'b0,1'b0};
            8'h52:dut_data = {tx_slew_rate,tx_phase_interpolation,1'b0,1'b0,1'b0};
            8'h68:dut_data = {rx_audio_out_enable,rx_audio_out_format,1'b0,1'b0};
        endcase
        check_data(addr_in);
    end
endtask

task test_read_write_defaults;
    input [7:0] addr_in;
    begin

        case(addr_in)
            8'h00:expected_data = 8'h80;
            8'h34:expected_data = 8'h84;
            8'h52:expected_data = 8'hF0;
            8'h68:expected_data = 8'hFC;
        endcase

        check_reg(addr_in);
        check_data(addr_in);
    end
endtask
