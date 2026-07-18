@echo off
REM Step 1: Compile all source and testbench files into a simulation binary
iverilog -o sim_out.vvp ..\src\*.v ..\tb\*.v

REM Step 2: Execute the simulation to generate the log and dump waveforms
vvp sim_out.vvp

REM Step 3: Open the waveform viewer automatically (if configured in your testbench)
if exist waveform.vcd (
    gtkwave waveform.vcd
) else (
    echo [ERROR] No waveform.vcd file found. Ensure your testbench uses $dumpfile.
)
pause
