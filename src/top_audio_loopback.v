module top_audio_loopback (
    input  wire        clk,       // Main Oscillator Board Clock
    input  wire        reset_n,   // Push button reset (Active Low)
    
    // Physical Codec Pins
    input  wire        AUD_BCLK,   // Audio Bit Clock
    input  wire        AUD_ADCDAT, // Audio ADC Data
    output wire        AUD_DACDAT, // Audio DAC Data
    input  wire        AUD_ADCLRCK,// ADC Left/Right Clock
    
    // Hardware Board Switches
    input  wire [3:0]  sw_volume,  // 4 switches for digital volume
    input  wire        sw_mute     // 1 switch for mute
);

    wire reset = !reset_n;
    wire [23:0] audio_in_l, audio_in_r;
    wire [23:0] audio_out_l, audio_out_r;
    wire sample_ready;

    // Instantiate I2S hardware driver
    i2s_interface codec_io (
        .bclk(AUD_BCLK),
        .reset(reset),
        .adcdat(AUD_ADCDAT),
        .dacdat(AUD_DACDAT),
        .lrclk(AUD_ADCLRCK),
        .rx_left(audio_in_l),
        .rx_right(audio_in_r),
        .tx_left(audio_out_l),
        .tx_right(audio_out_r),
        .sample_ready(sample_ready)
    );

    // Instantiate Left Channel DSP Filter
    audio_dsp dsp_left (
        .clk(AUD_BCLK),
        .reset(reset),
        .sample_in(audio_in_l),
        .volume(sw_volume),
        .mute(sw_mute),
        .sample_out(audio_out_l)
    );

    // Instantiate Right Channel DSP Filter
    audio_dsp dsp_right (
        .clk(AUD_BCLK),
        .reset(reset),
        .sample_in(audio_in_r),
        .volume(sw_volume),
        .mute(sw_mute),
        .sample_out(audio_out_r)
    );

endmodule