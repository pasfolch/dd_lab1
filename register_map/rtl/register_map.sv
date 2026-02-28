module register_map
#(   
    parameter NB_DATA = 8,
    parameter NB_ADDR = 8
) (
    input   wire                    clk,
    input   wire                    resetb,
    input   wire                    wr_req,
    input   wire                    rd_req,
    input   wire  [NB_DATA - 1 : 0] data_in,
    input   wire  [NB_ADDR - 1 : 0] addr_in,
    
    // status bits
    input   wire                    pll_locked,
    input   wire                    pll_in_range,
    input   wire                    pga_saturate,
    input   wire  [1 : 0]           vco_gear,
    input   wire                    rx_status_packet_detected,
    input   wire                    rx_infoframe_detected,
    input   wire                    rx_color_correct_detected,
    input   wire                    rx_content_protection_detected,
    input   wire                    rx_video_id_detected,
    input   wire                    rx_audio_id_detected,
    input   wire                    rx_aux_data_detected,

    output  wire  [NB_DATA - 1 : 0] data_out,
    
    // control bits
    output  wire                    master_powerdown,
    output  wire                    afe_powerdown,
    output  wire                    aaf_powerdown,
    output  wire                    pga_powerdown,
    output  wire                    pll_powerdown,
    output  wire                    pads_powerdown,
    output  wire                    tx_enable,
    output  wire                    tx_clk_gen_enable,
    output  wire                    tx_despreader_enable,
    output  wire                    tx_freq_diversity_enable,
    output  wire [1 : 0]            tx_lane_sel,
    output  wire [2 : 0]            tx_slew_rate,
    output  wire [1 : 0]            tx_phase_interpolation,
    output  wire [3 : 0]            rx_audio_out_enable,
    output  wire [1 : 0]            rx_audio_out_format
    //.rx_clk_gen_enable(rx_clk_gen_enable),
    //.video_path_enable(video_path_enable),
    //.audio_path_enable(audio_path_enable),
    //.adc_gain_correct_enable(adc_gain_correct_enable),
);

reg [NB_DATA - 1 : 0] power_down;
reg [NB_DATA - 1 : 0] status;
reg [NB_DATA - 1 : 0] tx_controls;
reg [NB_DATA - 1 : 0] rx_packets;
reg [NB_DATA - 1 : 0] tx_serdes_controls;
reg [NB_DATA - 1 : 0] rx_audio_out;

// write operation and default values

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        power_down          <= 8'h80;
        tx_controls         <= 8'h84;
        tx_serdes_controls  <= 8'hF0;
        rx_audio_out        <= 8'hFC;
    end else begin
        if (wr_req) begin
            case (addr_in)
                8'h00: power_down           <= data_in; 
                8'h34: tx_controls          <= data_in;
                8'h52: tx_serdes_controls   <= data_in; 
                8'h68: rx_audio_out         <= data_in; 
                // default: 
            endcase 
        end
    end
end

// read operation

reg [NB_DATA - 1 : 0] rd_data;

always @(*) begin
    if (rd_req) begin
        case (addr_in)
            8'h00: rd_data = power_down;
            8'h10: rd_data = {pll_locked, pll_in_range, pga_saturate, vco_gear[1], vco_gear[0], 1'b0, 1'b0, 1'b0};
            8'h34: rd_data = tx_controls;
            8'h48: rd_data = {1'b0, rx_status_packet_detected, rx_infoframe_detected, rx_color_correct_detected, rx_content_protection_detected, rx_video_id_detected, rx_audio_id_detected, rx_aux_data_detected};
            8'h52: rd_data = tx_serdes_controls;
            8'h68: rd_data = rx_audio_out;
            // default: 
        endcase
    end
end

// read/write control bits

assign master_powerdown               = power_down[7];
assign afe_powerdown                  = power_down[6];
assign aaf_powerdown                  = power_down[5];
assign pga_powerdown                  = power_down[4];
assign pll_powerdown                  = power_down[3];
assign pads_powerdown                 = power_down[2];

assign tx_enable                      = tx_controls[7];
assign tx_clk_gen_enable              = tx_controls[6];
assign tx_despreader_enable           = tx_controls[5];
assign tx_freq_diversity_enable       = tx_controls[4];
assign tx_lane_sel                    = tx_controls[3:2];

assign tx_slew_rate                   = tx_serdes_controls[7:5];
assign tx_phase_interpolation         = tx_serdes_controls[4:3];

assign rx_audio_out_enable            = rx_audio_out[7:4];
assign rx_audio_out_format            = rx_audio_out[3:2];

// output assignments

assign data_out = rd_data;

endmodule