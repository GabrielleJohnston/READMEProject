clear all, close all, clc
[y, fs] = audioread('IR.wav');
L = length(y);
time_ax = [0:L-1]./fs;

%   Plotting the signal in time domain
figure(1)
plot(time_ax, y);
xlabel('Time (s)')
title(['Unsmoothed signal'])
ylabel('Amplitude IR (Arbitrary Units)')
xlim([4.5, 6])

%Generating the third octave filter bank values
%center values
for i=1:33
    k=i-20;
    center(i) = 2^(k/3)*1000;
end

%upper and lower limits
upper(1) = 14.1;
lower(1) = 11.2;
for i=2:32
    upper(i) = sqrt(center(i)*center(i+1));  
    lower(i) = upper(i-1);
end
upper(33) = 22390;
lower(33) = 117780;

%fft of the original signal
Nfft = 2^nextpow2(length(y));
ydft = fft(y, Nfft);
amp = 20*log(abs(ydft)); % amp is the fft of original signal
f = fs*((0:Nfft-1)/Nfft);

%   Plotting the unsmoothed signal
figure(2)
subplot(2,1,1)
plot(f, amp);
xlabel('Frequency(Hz)')
title(['Unsmoothed signal'])
ylabel('Amplitude IR (dB)')
set(gca, 'XScale', 'log')
xlim([10, 20000])

%   Filtering the signal - only for center values
for i=1:33%2:66
%     for k = 1:32
    filt_sig(i) =  sum(amp(find(f >= lower(i) & f <= upper(i))))/length(find(f >= lower(i) & f <= upper(i)));
%     filt_sig(i+1) = sum(amp(find(f >= center(k) & f <= center(k+1))))/length(find(f >= center(k) & f <= center(k+1)));
%     end
end

%   Plotting the smoothed signal
subplot(2,1,2)
plot(center,filt_sig)
xlabel('Frequency(Hz)')
title(['Smoothed signal'])
ylabel('Amplitude IR (dB)')
set(gca, 'XScale', 'log')
xlim([10, 20000])
ylim([-100, 100])