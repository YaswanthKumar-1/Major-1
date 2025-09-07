FIR Filter with Booth Multiplier radix 8 and CSKA Adder

Project Overview
This project implements a Finite Impulse Response (FIR) filter in Verilog. The design uses Radix-8 Booth multipliers for coefficient multiplication and Carry Skip Adders (CSKA) for adding the partial products. The goal is to create an efficient, modular, and scalable FIR filter.

Architecture

Shift Register
Stores the most recent N_TAPS input samples. At every clock cycle, the samples shift, and the new input value is loaded.

Booth Multipliers
Each delayed input is multiplied with its corresponding coefficient using a Radix-8 Booth multiplier. Each output is 2N bits wide (32 bits for N = 16).

Carry Skip Adder Chain
The multiplier outputs are added together using a chain of CSKA modules. Each CSKA is parameterized to handle 32-bit operands.

Output Register
The final accumulated sum is registered to provide the FIR output.

File Structure

fir_filter_booth_cska.v : Top-level FIR filter module

radix8_booth_multiplier.v : Radix-8 Booth multiplier

cska_top.v : Carry Skip Adder module

cla_block.v : Carry Lookahead block used in CSKA

tb_fir.v : Testbench



Simulation
The testbench generates a 100 MHz clock, initializes reset, and applies sample input values. The output shows the filtered result, which is the convolution of the input sequence with the filter coefficients.

Default coefficients in this project are:
1, 2, 3, 4, 3, 2, 1, 0

Parameters

N : Input bit width (default 16)

N_TAPS : Number of filter taps (default 8)

2N : Booth output width (32 bits when N = 16)

BLOCK_SIZE : Size of CLA block inside CSKA (default 4)


Example: FIR Filter Operation

To understand how the FIR filter works, let us take an example input sequence and show how the output is computed.

Filter Coefficients:
h = [1, 2, 3, 4, 3, 2, 1, 0]

Input Sequence:
x = [1, 2, 3, 4, 0, 0, 0, 0]

The FIR filter output at time n is given by the convolution:
y[n] = h[0]*x[n] + h[1]*x[n-1] + h[2]*x[n-2] + ... + h[7]*x[n-7]

Example Calculations:
n = 0 → y[0] = 11 = 1
n = 1 → y[1] = 12 + 21 = 4
n = 2 → y[2] = 13 + 22 + 31 = 10
n = 3 → y[3] = 14 + 23 + 32 + 41 = 20
n = 4 → y[4] = 24 + 33 + 42 + 31 = 25
n = 5 → y[5] = 34 + 43 + 32 + 21 = 28
n = 6 → y[6] = 44 + 33 + 22 + 11 = 30
n = 7 → y[7] = 34 + 23 + 1*2 = 20

Resulting Output Sequence:
y = [1, 4, 10, 20, 25, 28, 30, 20]

How This Maps to the Design:

Each multiplication (h[k] * x[n-k]) is performed by a Booth multiplier.

The results are added together by the chain of CSKA adders.

The final registered output corresponds to y[n].
