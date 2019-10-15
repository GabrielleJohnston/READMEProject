%Exercise - reading and plotting a wav file in
%the frequency doman - magnitude curve according to the frequency
clear all
close all
clc
[y, fs] = audioread('IR.wav');

Nfft = 2^nextpow2(length(y));
ydft = fft(y, Nfft);
amp = 20*log(abs(ydft));
f = fs*((0:Nfft-1)/Nfft);

span = 13;
d = (span-1)/2; %Difference to go back to the smoothed point
filtered = amp;    

for n = span:length(amp)
    filtered(n-d)=sum(amp(n-(span-1):n))/span;       %filtered[n] is the filtered signal in frequency domain
end
tic
figure
% plot(f,filtered)
% hold;
plot(f, amp-1000, 'r')
set(gca, 'XScale', 'log')
xlim([0, 40000])
elapsed = toc

% filtered_sound = ifft(filtered);
% sound(real(filtered_sound), fs)