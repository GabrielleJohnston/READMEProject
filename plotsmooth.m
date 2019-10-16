%Read wav file, plot in frequency domain

[y fs]=audioread('signal.wav');% fs = sample rate
nf=1024; %number of point in DTFT
Y = fft(y,nf);
% generate nf/2+1 points from 0-1 

f = fs/2 * linspace(0,1,nf/2+1); 

%plot frequency f against positive value of Y
YY = Y(1:nf/2+1);
plot(f,abs(YY));
xlabel('frequency');
ylabel('magnitude');
%=================================================================
%plot smoothed version
hold on;
s = fastsmooth(YY, 6, 2, 0); %a function from Mathwork
plot(f,s,'r');
legend('Original','Smooth');

