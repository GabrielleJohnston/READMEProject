function [filteredSignal, order] = savitzkyGolayFilter(timeSignal, samplingRate, cutoffFreq, windowSize)
%SAVITZKYGOLAYFILTER Applies the Savitzky Golay filter to a time signal 
%   Cutoff frequency, sampling rate, and window size are specified to
%   calculate polynomial order
M = (windowSize - 1)/2;
cutoffRatio = cutoffFreq/samplingRate;
order = round(cutoffRatio*(3.2*M - 4.6) - 1);
filteredSignal = sgolayfilt(timeSignal, order, windowSize);
end

