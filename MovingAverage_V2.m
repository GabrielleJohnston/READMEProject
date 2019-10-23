% Moving Average Filter applied to IR.wav file
% Plots the magnitude spectrum of the filtered signal superimposed to the noisy signal
% Plots the sum of absolute differences vs window length to determine
% optimal window size

clear all
close all
clc
[y, fs] = audioread('IR.wav');

Nfft = 2^nextpow2(length(y));
ydft = fft(y, Nfft);
amp = 20*log(abs(ydft)); % amp is the fft of original signal
f = fs*((0:Nfft-1)/Nfft);

% TECHNIQUE 1 Using filter function
WindowSize = 13; %optmial window size for this case
kernel = ones(WindowSize, 1)/WindowSize;
filtered_signal = filter(kernel, 1,  y); %filtering the signal in the time domain

sdft = fft(filtered_signal, Nfft); %fft of the filtered signal
fft_filtered_signal_13 = 20*log(abs(sdft));

figure(1)
plot(f,amp, 'r', f,fft_filtered_signal_13, 'b' )
legend('Original Signal','Window Size 13');
set(legend,'location','best')
set(gca, 'XScale', 'log')
xlim([0, 40000])
xlabel('frequency (Hz)')
ylabel('Magnitude (dB)')
title('Moving Average Filter')
grid on

% Determining optimal window size
% Plotting Sum of absolute differences vs window size
windowSizes = 3 : 3 : 101;
for k = 1 : length(windowSizes)
  kernel = ones(windowSizes(k), 1)/windowSizes(k);
  filtered_signal = filter(kernel, 1,  y);
  
  sad(k) = sum(abs(filtered_signal - y));
end
figure(2)
plot(windowSizes, sad, 'b*-', 'LineWidth', 2);
grid on;
xlabel('Window Size');
ylabel('Sum of Absolute Differences');

%% TECHNIQUE 2
% span = 101;
% d = (span-1)/2; %Difference to go back to the smoothed point
% filtered = amp;    
% 
% for n = span:length(amp)
%     filtered(n-d)=sum(amp(n-(span-1):n))/span;       %filtered[n] is the filtered signal in frequency domain
% end
% tic
% figure(1)
% hold on
% plot(f,filtered, 'b', f, amp, 'r')
% set(gca, 'XScale', 'log')
% xlim([0, 40000])
% elapsed = toc