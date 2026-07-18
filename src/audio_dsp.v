module audio_dsp (
    input  wire        clk,        // System Clock
    input  wire        reset,      // Reset signal
    input  wire [23:0] sample_in,  // 24-bit Left or Right audio input
    input  wire [3:0]  volume,     // Volume control bits from FPGA switches
    input  wire        mute,       // Mute switch
    output reg  [23:0] sample_out  // Processed audio output
);

    reg signed [31:0] multiplied_sample;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_out <= 24'd0;
        end else if (mute) begin
            sample_out <= 24'd0;
        end else begin
            // Sign-extend 24-bit input to 32-bit and multiply by volume factor
            multiplied_sample <= $signed(sample_in) * $signed({1'b0, volume});
            
            // Saturation logic: Prevent overflow/underflow clipping distortion
            if (multiplied_sample > 32'sd8388607) begin          // Max positive 24-bit value
                sample_out <= 24'h7FFFFF;
            end else if (multiplied_sample < -32'sd8388608) begin // Max negative 24-bit value
                sample_out <= 24'h800000;
            end else begin
                sample_out <= multiplied_sample[23:0];          // Pass through truncated result
            end
        end
    end

endmodule
