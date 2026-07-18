# Audio_DSP_project

# 24-Bit I2S Audio Loopback Core & DSP Audio Processor

A robust, hardware-ready Verilog RTL design featuring an **I2S (Inter-IC Sound) protocol controller** interfaced with a **signed DSP audio arithmetic core**. The architecture implements runtime digital volume scaling and hardware-level saturation clipping logic to eliminate overflow distortion.

## 🚀 System Architecture
The core system captures asynchronous, high-fidelity serial audio bitstreams from an external audio codec, deserializes the signal into parallel words for hardware-level DSP execution, and re-serializes the processed data for clean audio reproduction.

```text
       ┌────────────────────────────────────────────────────────┐
       │                 top_audio_loopback.v                   │
       │                                                        │
┌────────────┐   Serial Bits   ┌──────────────────┐             │
│            ├────────────────►│  i2s_interface   │             │
│ Physical   │                 │ (Serial-Parallel)│             │
│ Audio Codec│                 └────────┬─────────┘             │
│ Chip       │                          │ 24-Bit Parallel Bus   │
│            │                 ┌────────▼─────────┐             │
│            │                 │    audio_dsp     │             │
│            │                 │(Volume/Mute Math)│             │
│            │                 └────────┬─────────┘             │
│            │                          │ 24-Bit Processed Bus  │
│            │                 ┌────────▼─────────┐             │
│            │   Serial Bits   │  i2s_interface   │             │
│            │◄────────────────┤ (Parallel-Serial)│             │
└────────────┘                 └──────────────────┘             │
       │                                                        │
       └────────────────────────────────────────────────────────┘
```

## 🛠️ Key Hardware Engineering Highlights
* **I2S Protocol Synchronization:** Handles frame-start edge alignment tracking to cleanly capture 24-bit audio formats across slow, variable external bit clocks (`AUD_BCLK`).
* **Signed Multiplier DSP Core:** Implements parameterizable signed hardware arithmetic (`$signed`) to scale audio gain linearly relative to 4-bit physical board slide switches.
* **Anti-Clipping Saturation Logic:** Bypasses standard digital wrap-around noise. Implements strict positive (`24'h7FFFFF`) and negative (`24'h800000`) saturation boundaries to keep audio outputs smooth under extreme gain.
* **Deterministic Verification Suite:** Uses structural hardware status loops (`sample_ready`) instead of absolute simulation time delays, preventing clock-edge race conditions across multiple domains.

## 📁 Repository Structure
* `src/`: Core hardware RTL design modules (`top_audio_loopback.v`, `audio_dsp.v`, `i2s_interface.v`).
* `tb/`: Self-checking structural testbench verification environment (`tb_top_audio_loopback.v`).
* `sim/`: Windows shell compilation automation scripts (`run_sim.bat`).

## 🧪 Simulation Run & Verification Logs
The hardware logic was fully compiled and dynamically verified using **Icarus Verilog** and **GTKWave**. The verification suite executes forced multi-cycle test vectors to validate baseline data routing, digital multipliers, and absolute mute functionality.

```text
[STATUS] Injecting data directly to bypass clock timing dependencies...
[STATUS] Testing volume scaling (x2)...
[STATUS] Testing mute switch functionality...

========================================================================
  SIMULATION RESULT: [PASSED] 🎉  
========================================================================
```
