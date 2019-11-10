clear all, close all, clc

[y, fs] = audioread('IR.wav');

L = length(y);

time_ax = [0:L-1]./fs;



% %   Plotting the signal in time domain

figure(1)

plot(time_ax, y);

xlabel('Time (s)')

title(['Unsmoothed signal'])

ylabel('Amplitude IR (Arbitrary Units)')

xlim([4.5, 6])

% fft of the original signal

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

grid on

set(gca, 'XScale', 'log')

xlim([10, 20000])

% Testing the formula gotten from Wikipedia
% One-third Octave band with base 2


% Calculating the fcentre, fupper and flower values
for j = 1:20
    tic;
    fcenter2  = 10^3 * (2 .^ ([-18:13]/3));
    fd = 2^(1/6);
    fupper2 = fcenter2 * fd;
    flower2 = fcenter2 / fd;
    elapsed2val(j) = toc;
end
meanElapsed2val = mean(elapsed2val)
for j = 1:20
    tic;
    % Filtering the signal
    for i=1:length(fcenter2)
        filt_sig2(i) =  sum(amp(find(f >= flower2(i) & f <= fupper2(i))))/length(find(f >= flower2(i) & f <= fupper2(i)));
    end
    elapsed2(j) = toc;
end
mean_base2 = mean(elapsed2)
subplot(2,1,2)
hold on

% %Plotting the signal smoothed by the Base 2 One-Third Octave Band smoothing
plot(fcenter2 , filt_sig2);

%Wikipedia formula for Base 10 1/3 Octave Band Smoothing

%Calculating the fcentre, fupper and flower values
for j = 1:20
    tic;
    fcenter10 = 10.^(0.1.*[12:43]);
    fd = 10^0.05;
    fupper10 = fcenter10 * fd;
    flower10 = fcenter10 / fd;
    elapsed10val(j) = toc;
end
meanElapsed10val = mean(elapsed10val)
for j = 1:20
    tic;
    for i=1:length(fcenter10)
        filt_sig10(i) =  sum(amp(find(f >= flower10(i) & f <= fupper10(i))))/length(find(f >= flower10(i) & f <= fupper10(i)));
    end
    elapsed10(j) = toc;
    
end
mean_base10 = mean(elapsed10)
plot(fcenter10 , filt_sig10);

legend('Base 2 1/3 Octave Smoothing filter', 'Base 10 1/3 Octave Smoothing filter');

xlabel('Frequency(Hz)')

title(['Signal Smoothed by Base 2 and Base 10 1/3 Octave Smoothing'])

ylabel('Amplitude IR (dB)')

set(gca, 'XScale', 'log')

grid on

xlim([10, 20000])

ylim([-100, 100])

hold off
