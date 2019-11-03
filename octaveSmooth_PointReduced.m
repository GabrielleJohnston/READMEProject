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

% %Generating the third octave filter bank values
% 
% %center values
% 
% for i=1:33
% 
%     k=i-20;
% 
%     center(i) = 2^(k/3)*1000;
% 
% end
% 
% %upper and lower limits
% 
% upper(1) = 14.1;
% 
% lower(1) = 11.2;
% 
% for i=2:32
% 
%     upper(i) = sqrt(center(i)*center(i+1));  
% 
%     lower(i) = upper(i-1);
% 
% end
% 
% upper(33) = 22390;
% 
% lower(33) = 117780;
% 
% %   Filtering the signal - only for center values
% 
% for i=1:33%2:66
% 
% %     for k = 1:32
% 
%     filt_sig(i) =  sum(amp(find(f >= lower(i) & f <= upper(i))))/length(find(f >= lower(i) & f <= upper(i)));
% 
% %     filt_sig(i+1) = sum(amp(find(f >= center(k) & f <= center(k+1))))/length(find(f >= center(k) & f <= center(k+1)));
% 
% %     end
% 
% end
% 
% %   Plotting the smoothed signal
% 
% subplot(2,1,2)
% 
% plot(center,filt_sig)
% 
% xlabel('Frequency(Hz)')
% 
% title(['Smoothed signal'])
% 
% ylabel('Amplitude IR (dB)')
% 
% set(gca, 'XScale', 'log')
% 
% grid on
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% 
% %Linear regression
% mdl = fitlm(center, filt_sig, 'linear');          %for all of the smoothed points
% 
% %Plotting the Linear Regression Model
% 
% figure(3)
% 
% subplot(2,1,1)
% 
% plot(mdl)
% 
% xlabel('Frequency(Hz)')
% 
% title(['Linear Regression Model for Smoothed Data'])
% 
% ylabel('Amplitude IR (dB)')
% 
% set(gca, 'XScale', 'log')
% 
% grid on
% 
% xlim([0, 25000])
% 
% ylim([-100, 100])
% 
% 
% 
% %   Centering the linear fit at 0dB
% 
% slope = mdl.Coefficients.Estimate(2);
% 
% mdl_eq_0db = center.*slope;
% 
% 
% 
% %   Centering the smoothed curve at 0dB (substracting y-intercept of linear model)
% 
% y_intercept = mdl.Coefficients.Estimate(1);
% 
% filt_sig_0db = filt_sig - y_intercept;
% 
% 
% 
% subplot(2,1,2)
% 
% hold on
% 
% plot(center,mdl_eq_0db , center,filt_sig_0db);
% 
% legend('Linear fit at 0dB', 'Smoothed curve at 0dB');
% 
% xlabel('Frequency(Hz)')
% 
% title(['Smoothed data and Linear Regression Model Centered at 0dB'])
% 
% ylabel('Amplitude IR (dB)')
% 
% set(gca, 'XScale', 'log')
% 
% grid on
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% hold off
% 
% %%
% % Testing the formula gotten from Wikipedia
% % One-third Octave band with base 2
% 
% 
% % Calculating the fcentre, fupper and flower values
% fcenter2  = 10^3 * (2 .^ ([-18:13]/3));
% fd = 2^(1/6);
% fupper2 = fcenter2 * fd;
% flower2 = fcenter2 / fd;
% 
% % Filtering the signal
% for i=1:length(fcenter2)
%     filt_sig2(i) =  sum(amp(find(f >= flower2(i) & f <= fupper2(i))))/length(find(f >= flower2(i) & f <= fupper2(i)));
% end
% 
% figure(4)
% subplot(2,1,1)
% hold on
% % Plotting the unsmoothed signal at the top
% 
% plot(f, amp);
% xlabel('Frequency(Hz)')
% 
% title(['Unsmoothed signal'])
% 
% ylabel('Amplitude IR (dB)')
% 
% grid on
% 
% set(gca, 'XScale', 'log')
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% 
% %Plotting the signal smoothed by the Base 2 One-Third Octave Band smoothing
% subplot(2,1,2)
% plot(fcenter2 , filt_sig2);
% xlabel('Frequency(Hz)')
% 
% title(['Base 2 1/3 Octave Band smoothed signal vs Frequency'])
% 
% ylabel('Base 2 1/3 Octave Band smoothed signal (dB)')
% 
% grid on
% 
% set(gca, 'XScale', 'log')
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% %Fit a linear regression to the unsmoothed curve
% mdl2 = fitlm(fcenter2, filt_sig2);          %for all of the smoothed points
% 
% figure(5)
% 
% subplot(2,1,1)
% 
% plot(mdl2);
% 
% xlabel('Frequency(Hz)')
% 
% title(['Linear Regression Model for Data Smoothed by Base 2 1/3 Octave'])
% 
% ylabel('Amplitude IR (dB)')
% 
% set(gca, 'XScale', 'log')
% 
% grid on
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% 
% 
% 
% %   Centering the linear fit at 0dB
% 
% slope = mdl2.Coefficients.Estimate(2);
% 
% mdl2_eq_0db = fcenter2.*slope;
% 
% 
% 
% %   Centering the smoothed curve at 0dB (substracting y-intercept of linear model)
% 
% y_intercept = mdl2.Coefficients.Estimate(1);
% 
% filt_sig2_0db = filt_sig2 - y_intercept;
% 
% %Plotting the smoothed centred curve
% 
% subplot(2,1,2)
% 
% hold on
% 
% plot(fcenter2,mdl2_eq_0db , fcenter2,filt_sig2_0db);
% 
% legend('Linear fit at 0dB', 'Smoothed curve at 0dB');
% 
% xlabel('Frequency(Hz)')
% 
% title(['Smoothed data and Linear Regression Model Centered at 0dB for Base 2 1/3 Octave Smoothing'])
% 
% ylabel('Amplitude IR (dB)')
% 
% set(gca, 'XScale', 'log')
% 
% grid on
% 
% xlim([10, 20000])
% 
% ylim([-100, 100])
% 
% hold off
%%
%Wikipedia formula for Base 10 1/3 Octave Band Smoothing

%Calculating the fcentre, fupper and flower values
fcenter10 = 10.^(0.1.*[12:43]);
fd = 10^0.05;
fupper10 = fcenter10 * fd;
flower10 = fcenter10 / fd;

for i=1:length(fcenter10)
    filt_sig10(i) =  sum(amp(find(f >= flower10(i) & f <= fupper10(i))))/length(find(f >= flower10(i) & f <= fupper10(i)));
end

figure(6)
subplot(2,1,1)
hold on
%Plotting the unsmoothed signal at the top
plot(f, amp);

xlabel('Frequency(Hz)')

title(['Unsmoothed signal'])

ylabel('Amplitude IR (dB)')

grid on

set(gca, 'XScale', 'log')

xlim([10, 20000])

ylim([-100, 100])

%Plotting the signal smoothed by the Base 2 One-Third Octave Band smoothing
subplot(2,1,2)

plot(fcenter10 , filt_sig10);

xlabel('Frequency(Hz)')

title(['Base 2 1/3 Octave Band smoothed signal vs Frequency'])

ylabel('Base 2 1/3 Octave Band smoothed signal (dB)')

grid on

set(gca, 'XScale', 'log')

xlim([10, 20000])

ylim([-100, 100])

%Fit a linear regression to the unsmoothed curve
mdl10 = fitlm(fcenter10, filt_sig10);          %for all of the smoothed points

figure(7)

subplot(2,1,1)

plot(mdl10);

xlabel('Frequency(Hz)')

title(['Linear Regression Model for Data Smoothed by Base 2 1/3 Octave'])

ylabel('Amplitude IR (dB)')

set(gca, 'XScale', 'log')

grid on

xlim([10, 20000])

ylim([-100, 100])



%   Centering the linear fit at 0dB

slope = mdl10.Coefficients.Estimate(2);

mdl10_eq_0db = fcenter10.*slope;



%   Centering the smoothed curve at 0dB (substracting y-intercept of linear model)

y_intercept = mdl10.Coefficients.Estimate(1);

filt_sig10_0db = filt_sig10 - y_intercept;

subplot(2,1,2)

hold on

plot(fcenter10,mdl10_eq_0db , fcenter10,filt_sig10_0db);


legend('Linear fit at 0dB', 'Smoothed curve at 0dB');

xlabel('Frequency(Hz)')

title(['Smoothed data and Linear Regression Model Centered at 0dB for Base 2 1/3 Octave Smoothing'])

ylabel('Amplitude IR (dB)')

set(gca, 'XScale', 'log')

grid on

xlim([10, 20000])

ylim([-100, 100])

hold off

%%
%   Applying Octave Smoothing to the downsampled input signal in accordance
%   with the bark scale
[data, fs] = audioread('IR.wav');
info = audioinfo('IR.wav');
NoSamples = info.TotalSamples;
[freq, mag] = getmag(data, fs, NoSamples);

%   Creating the Bark Scale
barkScale = hz2bark(freq);
barkScaleBands = 24;

start_freq_indx = find(round(barkScale) == 0, 1);
end_freq_indx = zeros(barkScaleBands, 1);
for i = 1:barkScaleBands
    end_freq_indx(i) = find(round(barkScale) == i, 1);
end

idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 20 24 27 32 38 46 59 76 92 109 151 210 294];

band_spacing = zeros(barkScaleBands, 1);
for i = 1:barkScaleBands
    if i == 1
        band_spacing(i) = round((end_freq_indx(i) - start_freq_indx)/idealNoPoints(i));
    else
        band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints(i));
    end
end

new_freq = bark_space(freq, barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
new_mag = bark_space(mag', barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);

%   Third Octave Smoothing
%   Calculating the fcentre, fupper and flower values
fcenter10 = 10.^(0.1.*[12:43]);
fd = 10^0.05;
fupper10 = fcenter10 * fd;
flower10 = fcenter10 / fd;

%   Third Octave Smoothing the signal
for i=1:length(fcenter10)
    mag_smoothed_bark(i) =  sum(amp(find(f >= flower10(i) & f <= fupper10(i))))/length(find(f >= flower10(i) & f <= fupper10(i)));
end
new_freq_bark = hz2bark(new_freq);

%   Plotting
figure(8)
plot(fcenter10, mag_smoothed_bark)
set(gca, 'XScale', 'log')
grid on
ylim([-100 50])
title('Smoothed magnitude spectrum')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 16000])

%%
%   Convolving IR.wav signal (point reduced and smoothed in frequency domain) with test
%   signal
[mario, fs_mario] = audioread('mario.mp3');
% sound(mario, fs_mario)

%fft of the original signal
mNfft = 2^nextpow2(length(mario));
mdft = fft(mario, mNfft);
fft_mario = 20*log(abs(mdft)); % fft of original signal
f_mario = fs_mario*((0:mNfft-1)/mNfft);


%   Octave smoothing the test signal for octave smoothing
for i=1:length(fcenter10)
    oct_smoothed_mario(i) =  sum(fft_mario(find(f_mario >= flower10(i) & f_mario <= fupper10(i))))/length(find(f_mario >= flower10(i) & f_mario <= fupper10(i)));
end

%   Convolving the impulse reponse smoothed in the frequency domain
%   with the test acoustic signal (Mario)
%   mag_smoothed_bark is the point reduced and octave smoothed IR
conv1 = conv(oct_smoothed_mario, mag_smoothed_bark);

ifft_IR = ifft(mag_smoothed_bark);
conv2 = conv( conv1,ifft_IR);

deconv = abs(ifft(conv2));
sound(deconv, fs_mario)

%   Plotting fft of mario and the smoothed fft
figure(9)
hold on
plot(fft_mario, 'r')
plot(fcenter10, oct_smoothed_mario, 'b')
legend('FFT of noisy Mario signal', 'Third Octave Smoothed Mario signal');
set(gca, 'XScale', 'log')
title('Smoothed magnitude spectrum of the input signal')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 16000])

figure(10)
plot(fcenter10, output(1:32))
title('Convolution Output')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
set(gca, 'XScale', 'log')
