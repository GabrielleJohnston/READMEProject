function RI = convlin(signal_1, signal_2, msg)
% RI is the result of the linear convolution of signal_1 and signal_2 
% implemented through product of the fast fourier transforms of the two signals
% -----------------------------------------------------------------------------
% The linear convolution is actually carried out through the frequency domain.
% Therefore, carried out a circular convolution and linear convolution is
% approximated by the circular convolution calculated here
% This approximation is very good, however, provided that the input signals
% are of finite length and that the length of the FFT used is at least M + N -1
% where M and N are the respective lengths of the arguments given
% RI = convlin(signal_1, signal_2)
% i.e. RI = real(ifft(fft(signal_1).*fft(signal_2)))

if nargin<3
    msg = '';
end

h = waitbar(0,strcat('Linear Convolution ',msg));

lconvlin = 2^nextpow2(length(signal_2)+length(signal_1)-1); %resulting length of linear convolution
%Number of samples in convolution result = N1 + N2 - 1

waitbar(0.10);

signal_2f = fft(signal_2,lconvlin); %N-point fft, where N is length of linear convolution

waitbar(0.30);

signal_1f = fft(signal_1,lconvlin); %N-point fft, where N is length of linear convolution

waitbar(0.50);

RIf = signal_2f.*signal_1f;

waitbar(0.70);

RI = real(ifft(RIf));

waitbar(1);

close(h);

return
