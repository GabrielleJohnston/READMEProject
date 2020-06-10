%% Function to remove the background noise of the signal 
% Takes in a pre-recorded background noise signal, the signal to be
% analysed, the sampling frequency (fs) of the signal to be analysed, and
% the generated  x-axis (frequency axis) of the signal to be analysed 


% is able to return the background noise signal that has the same length as
% the signal to be analysed, in addition to a 'noiseless' copy of the
% signal to be analysed

function [noise, noiselessSignal] = removeNoise (backgroundNoiseFile, signal, signal_fs, signalAxis)
    bgNoise = backgroundNoiseFile;  % use for testing while there is no background noise file
%     [bgNoise, ~] = audioread(backgroundNoiseFile);
   
    noise_faxis = signal_fs*(0:length(bgNoise)-1)/length(bgNoise); %   create 
%   frequency axis for the background noise signal - will be same length 
%   as background noise signal 
    
    noise_ft = 20*log10(abs(fft(bgNoise)));   % magnitude of background noise
    noise = interp1(noise_faxis, noise_ft, signalAxis);     % interpolate 
%   background noise signal to  be same length as the signal to be analysed

    [noise, noiseAxis] = rlogbarkrangedv2(signalAxis, noise);   % filter the noise 
%   signal
    noise = interp1(noiseAxis, noise, signalAxis);  % interpolate the 
%   smoothed noise signal to be the same length as the signal to be
%   analysed  - this is the noise signal that will be plotted on any
%   displays
    
    abs_signalNoise = abs(bgNoise);
    
    signalNoise = mean(abs_signalNoise);  % find the mean magnitude of 
%   background noise

    Nplus = signal > 0;     % create array with 1 in the indexes where the 
%   signal is positive in magnitude, and 0 otherwise

    Nplus = Nplus .* signalNoise; % give these indexes a magnitude of 
%   the mean background noise value

    Nminus = signal < 0;    % create array with 1 in the indexes where the 
%   signal is negative in magnitude, and 0 otherwise

    Nminus = Nminus .* signalNoise;   % give these indexes a magnitude of 
%   the mean background noise value

    noiselessSignal = signal - Nplus + Nminus;  % adjust the signal to 
%   remove the background noise to create a 'pure' signal free from 
%   background noise

end 