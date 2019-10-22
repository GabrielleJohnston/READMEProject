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
xlabel('frequency');
ylabel('magnitude');
xlim([10 100000])
ylim([-100 50]);
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'linear');
%=================================================================
%% plot smoothed version
hold on;
s = fastsmooth(YY, 5, 2, 0); %a function from Mathwork
%figure(2);
plot(f,s,'b');
legend('Original','Smooth');
%% plot smooth (Alex)
hold on;

s = Trig_Smooth(YY, 5); %a function from Mathwork
plot(f,s,'b');
legend('Original','Smooth');
