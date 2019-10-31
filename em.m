% Download VOICEBOX from
% http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html and add to
% path
% Ephraim Malah algorithm - best implementation
[data, fs] = audioread('car.wav');
info = audioinfo('car.wav');
NoSamples = info.TotalSamples;
tic;
[ss,gg,tt,ff,zo]=v_ssubmmse(data,fs);
toc
T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector
tnew = (0:length(ss) - 1)*T;

figure(1)
subplot(2,1,1);
plot(t, data)
title('Original Signal')
xlabel('Time (s)')
ylabel('Amplitude')
grid on
subplot(2,1,2);
plot(tnew, ss)
title('Cleaned signal')
xlabel('Time (s)')
ylabel('Amplitude')
grid on
