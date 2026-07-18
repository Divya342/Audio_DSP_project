`timescale 1ns / 1ps

module tb_top_audio_loopback;

    reg clk;
    reg reset_n;
    reg aud_bclk;
    reg aud_adcdat;
    reg aud_adclrck;
    reg [3:0] sw_volume;
    reg sw_mute;

    wire aud_dacdat;
    reg sim_failed;

    top_audio_loopback uut (
        .clk(clk),
        .reset_n(reset_n),
        .AUD_BCLK(aud_bclk),
        .AUD_DACDAT(aud_dacdat),
        .AUD_ADCDAT(aud_adcdat),
        .AUD_ADCLRCK(aud_adclrck),
        .sw_volume(sw_volume),
        .sw_mute(sw_mute)
    );

    // Clock Generators
    always #10 clk = ~clk;
    always #163 aud_bclk = ~aud_bclk;

    integer i;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top_audio_loopback);

        clk         = 0;
        aud_bclk    = 0;
        aud_adclrck = 0;
        aud_adcdat  = 0;
        sw_volume   = 4'd1; // Volume x1
        sw_mute     = 0;
        reset_n     = 0;
        sim_failed  = 0;

        // Apply Reset
        #1000;
        reset_n = 1;
        #1000;

        // Force baseline values directly into the processing registers to test the DSP
        $display("[STATUS] Injecting data directly to bypass clock timing dependencies...");
        
        // Test Case 1: Volume x1 (Pass-through)
        sw_volume = 4'd1;
        force uut.audio_in_l = 24'h123456;
        force uut.audio_in_r = 24'h654321;
        #1000; // Allow value propagation
        
        if (uut.audio_out_l !== 24'h123456) begin
            $display("[ERROR] Baseline Left mismatch! Got: %h", uut.audio_out_l);
            sim_failed = 1;
        end

        // Test Case 2: Volume x2
        $display("[STATUS] Testing volume scaling (x2)...");
        sw_volume = 4'd2;
        #1000;

        if (uut.audio_out_l !== 24'h2468ac) begin
            $display("[ERROR] Volume multiplier failed! Expected: 24'h2468ac, Got: %h", uut.audio_out_l);
            sim_failed = 1;
        end

        // Test Case 3: Mute Switch
        $display("[STATUS] Testing mute switch functionality...");
        sw_mute = 1;
        #1000;

        if (uut.audio_out_l !== 24'd0 || uut.audio_out_r !== 24'd0) begin
            $display("[ERROR] Mute logic failed!");
            sim_failed = 1;
        end

        // Release forced signals
        release uut.audio_in_l;
        release uut.audio_in_r;

        // Print final status
        if (sim_failed) begin
            $display("\n====================================");
            $display("  SIMULATION RESULT: [FAILED] ❌  ");
            $display("====================================\n");
        end else begin
            $display("\n====================================");
            $display("  SIMULATION RESULT: [PASSED] 🎉  ");
            $display("====================================\n");
        end

        $finish;
    end

endmodule
