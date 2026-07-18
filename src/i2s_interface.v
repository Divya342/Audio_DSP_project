module i2s_interface (
    input  wire        bclk,         // Bit Clock from Codec (e.g., 3.072 MHz)
    input  wire        reset,        // Reset
    input  wire        adcdat,       // Serial data in from Codec Microphone/Line-In
    output reg         dacdat,       // Serial data out to Codec Headphones/Line-Out
    input  wire        lrclk,        // Left/Right Channel Select (e.g., 48 kHz)
    
    // Interface to DSP core
    output reg  [23:0] rx_left,
    output reg  [23:0] rx_right,
    input  wire [23:0] tx_left,
    input  wire [23:0] tx_right,
    output reg         sample_ready  // High for 1 bclk cycle when new data arrives
);

    reg [4:0]  bit_count;
    reg [23:0] shift_rx;
    reg [23:0] shift_tx_left, shift_tx_right;
    reg        lrclk_delayed;

    // Detect edges on Left/Right clock to sync audio frames
    always @(posedge bclk or posedge reset) begin
        if (reset) begin
            lrclk_delayed <= 1'b0;
        end else begin
            lrclk_delayed <= lrclk;
        end
    end

    wire frame_start = (lrclk ^ lrclk_delayed);

    // Serial Shifting Logic
    always @(posedge bclk or posedge reset) begin
        if (reset) begin
            bit_count    <= 0;
            shift_rx     <= 0;
            rx_left      <= 0;
            rx_right     <= 0;
            dacdat       <= 1'b0;
            sample_ready <= 1'b0;
        end else begin
            sample_ready <= 1'b0;
            
            if (frame_start) begin
                bit_count <= 0;
                // Latch parallel DSP data into shift registers at start of frame
                shift_tx_left  <= tx_left;
                shift_tx_right <= tx_right;
            end else begin
                bit_count <= bit_count + 1'b1;
            end

            // Read incoming bits (MSB first)
            if (bit_count < 24) begin
                shift_rx <= {shift_rx[22:0], adcdat};
            end

            // Transmit outgoing bits depending on channel
            if (lrclk == 1'b0) begin // Left Channel active
                dacdat <= shift_tx_left[23 - bit_count];
            end else begin           // Right Channel active
                dacdat <= shift_tx_right[23 - bit_count];
            end

            // When 24 bits are fully loaded, push to parallel outputs
            if (bit_count == 24) begin
                sample_ready <= 1'b1;
                if (lrclk == 1'b0) rx_left  <= shift_rx;
                else               rx_right <= shift_rx;
            end
        end
    end
endmodule
