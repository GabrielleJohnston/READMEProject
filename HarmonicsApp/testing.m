clear all
close all
file = 'signal.wav'
[z,zfs]=audioread(file);
xaxis=transpose([0:1/zfs:(length(z)-1)/zfs]);

ClearSignal=PeakRemover(file,11);

figure(1);
plot(xaxis,z,'r');
hold on;
plot(xaxis,ClearSignal,'b');
xlabel('time(sec)');
ylabel('AU magnitude');
legend('Original singal', 'Signal with no harmonics');
title('Signal impulse with and without harmonics removed');


