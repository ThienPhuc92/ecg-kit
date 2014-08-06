function b = design_downsample_filter( downsample_factor )
%DESIGN_DOWNSAMPLE_FILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the Signal Processing Toolbox 6.20.
% Generated on: 23-Jun-2014 10:45:52

% FIR least-squares Lowpass filter designed using the FIRLS function.

% All frequency values are normalized to 1.

N     = 60;   % Order
Fpass = 1/downsample_factor;  % Passband Frequency
Fstop = min(1, Fpass + 0.1);  % Stopband Frequency
Wpass = 1;    % Passband Weight
Wstop = 100;  % Stopband Weight

% Calculate the coefficients using the FIRLS function.
b  = firls(N, [0 Fpass Fstop 1], [1 1 0 0], [Wpass Wstop]);

% [EOF]
