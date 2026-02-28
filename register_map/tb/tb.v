`timescale 1ns/1ns

module tb();

// clock generation
reg clk, resetb;

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

reg wr_req, rd_req;
reg [7:0] data_in, addr_in;

wire [7:0] data_out;
reg [7:0] dut_data;
reg [7:0] expected_data;
reg check_ok;
reg [7:0] reg_mask;

reg pll_locked;
reg pll_in_range;
reg pga_saturate;
reg [1:0] vco_gear;
reg rx_status_packet_detected;
reg rx_infoframe_detected;
reg rx_color_correct_detected;
reg rx_content_protection_detected;
reg rx_video_id_detected;
reg rx_audio_id_detected;
reg rx_aux_data_detected;

wire master_powerdown;
wire afe_powerdown;
wire aaf_powerdown;
wire pga_powerdown;
wire pll_powerdown;
wire pads_powerdown;
wire rx_clk_gen_enable;
wire video_path_enable;
wire audio_path_enable;
wire adc_gain_correct_enable;
wire tx_enable;
wire tx_clk_gen_enable;
wire tx_despreader_enable;
wire tx_freq_diversity_enable;
wire [1:0] tx_lane_sel;
wire [2:0] tx_slew_rate;
wire [1:0] tx_phase_interpolation;
wire [3:0] rx_audio_out_enable;
wire [1:0] rx_audio_out_format;

integer check_cnt;
integer error_cnt;

`include "../tb/tb_tasks.v"
`include "../tb/regmap_tasks.v"

initial
begin
    check_cnt = 0;
    error_cnt = 0;
end

initial
begin

     // init reg map i/f
     init_interface;
     force_reg_10;
     force_reg_48;

    // reseat and wait
     @(posedge resetb);
     repeat(20)
        @(posedge clk);

     // read-only registers
     repeat(100)
     begin
        test_read_only_reg(8'h10);
        test_read_only_reg(8'h48);
     end

    // read-write defaults
    test_read_write_defaults(8'h00);
    test_read_write_defaults(8'h34);
    test_read_write_defaults(8'h52);
    test_read_write_defaults(8'h68);

    // read-write registers
    repeat(100)
    begin
        test_read_write_reg(8'h00);
        test_read_write_reg(8'h34);
        test_read_write_reg(8'h52);
        test_read_write_reg(8'h68);
    end
    repeat(20)
        @(negedge clk);

    finish_sim;
end

register_map dut(

    .clk(clk),
    .resetb(resetb),

    .wr_req(wr_req),
    .rd_req(rd_req),
    .data_in(data_in),
    .addr_in(addr_in),

    .data_out(data_out),

    .pll_locked(pll_locked),
    .pll_in_range(pll_in_range),
    .pga_saturate(pga_saturate),
    .vco_gear(vco_gear),
    .rx_status_packet_detected(rx_status_packet_detected),
    .rx_infoframe_detected(rx_infoframe_detected),
    .rx_color_correct_detected(rx_color_correct_detected),
    .rx_content_protection_detected(rx_content_protection_detected),
    .rx_video_id_detected(rx_video_id_detected),
    .rx_audio_id_detected(rx_audio_id_detected),
    .rx_aux_data_detected(rx_aux_data_detected),

    .master_powerdown(master_powerdown),
    .afe_powerdown(afe_powerdown),
    .aaf_powerdown(aaf_powerdown),
    .pga_powerdown(pga_powerdown),
    .pll_powerdown(pll_powerdown),
    .pads_powerdown(pads_powerdown),
    //.rx_clk_gen_enable(rx_clk_gen_enable),
    //.video_path_enable(video_path_enable),
    //.audio_path_enable(audio_path_enable),
    //.adc_gain_correct_enable(adc_gain_correct_enable),
    .tx_enable(tx_enable),
    .tx_clk_gen_enable(tx_clk_gen_enable),
    .tx_despreader_enable(tx_despreader_enable),
    .tx_freq_diversity_enable(tx_freq_diversity_enable),
    .tx_lane_sel(tx_lane_sel),
    .tx_slew_rate(tx_slew_rate),
    .tx_phase_interpolation(tx_phase_interpolation),
    .rx_audio_out_enable(rx_audio_out_enable),
    .rx_audio_out_format(rx_audio_out_format)

);


endmodule
