%Read wav file, plot in frequency domain

[y,fs]=audioread('signal.wav');% fs = sample rate
info = audioinfo('signal.wav');
NoSamples = info.TotalSamples;

Y = fft(y);
freq = fs*(0:NoSamples-1)/NoSamples;

%plot frequency f against positive value of Y

Mag = 20*log10(abs(Y));
figure;

plot(freq ,Mag,'r');
xlabel('frequency(Hz)');
ylabel('magnitude(dB)');
xlim([10 100000])
ylim([-100 50]);
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'linear');
%=================================================================
%% plot smoothed version
hold on;
s = fastsmooth(Mag, 10, 2); %a function from Mathwork
%figure(2);
plot(freq,s,'b');
legend('Original','Smooth');
title('Frequency response of data');
%% plot smooth (Alex)
hold on;

s = Trig_Smooth(Mag, 5); %a function from Mathwork
plot(freq,s,'b');
legend('Original','Smooth');
