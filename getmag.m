function [freq, mag] = getmag(inputSignal, fs, NoSamples)
%GETMAG Gets the magnitude spectrum and frequency of a signal
%   Detailed explanation goes here
trans = fft(inputSignal);
Retrans = abs(trans);
freq = fs*(0:NoSamples-1)/NoSamples;
mag = 20.*log10(Retrans);
end