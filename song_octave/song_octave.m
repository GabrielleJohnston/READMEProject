clear all
close all
clc

load IR_smoothed_Base10_Oct.mat

%   Getting input signal and IR signal

[z1,fs1]=audioread('Counting.m4a');% fs = sample rate
info1 = audioinfo('Counting.m4a');
NoSamples1 = info1.TotalSamples;

[temp2,fs2]=audioread('IR.wav');% fs = sample rate
% info2 = audioinfo('IR.wav');
% NoSamples2 = info2.TotalSamples;
y2 = abs(ifft(filt_sig10)); %get it in the time domain
NoSamples2 = length(y2);
%%
freq1 = fs1*(0:NoSamples1-1)/NoSamples1;
freq2 = fs2*(0:NoSamples2-1)/NoSamples2;

%%

y1=z1(:,1)+z1(:,2);
figure(1);
subplot(5,1,1);
plot(1:length(y1),y1);
subplot(5,1,2);
plot(1:length(y2),y2);
% sound(y1,fs1);



resp=conv(y1,y2,'full');
norm_resp=resp/(max(resp));
subplot(5,1,3);
plot(1:length(norm_resp),norm_resp);
% sound(norm_resp,fs1);
% audiowrite('Conv_Counting.m4A',norm_resp,fs1);