[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
dur = info.Duration;
NoSamples = info.TotalSamples;
trans = fft(data);
Retrans = abs(trans);
freq = fs*(0:NoSamples-1)/NoSamples;
mag = 20.*log10(Retrans);
phase = unwrap(angle(trans));
%barkScale = hz2bark(freq);
barkScaleBands = 25; % 24 + 1 for rest of band
T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector
mag_smooth = sgolayfilt(mag, 9, 25);

center_freq = [50 150 250 350 455 570 700 845 1000 1175 1375 1600 1860 2160 2510 2925 3425 4050 4850 5850 7050 8600 10750 13750];
bandwidths = [100 100 100 100 110 120 140 150 160 190 210 240 280 320 380 450 550 700 900 1100 1300 1800 2500 3500];

center_freq_indx = zeros(length(center_freq), 1);
flower = zeros(length(center_freq), 1);
fupper = zeros(length(center_freq), 1);
log_means = zeros(length(center_freq), 1);
for n = 1:length(center_freq)
    center_freq_indx(n) = find(round(freq) == center_freq(n), 1);
    lower_freq = center_freq(n) - (bandwidths(n)/2);
    upper_freq = center_freq(n) + (bandwidths(n)/2);
    flower(n) = find(round(freq) == lower_freq, 1);
    fupper(n) = find(round(freq) == upper_freq, 1);
    log_means(n) =  10*log(sum(10.^(0.1*mag_smooth(find(freq >= lower_freq & freq <= upper_freq))))/length(find(freq >= lower_freq & freq <= upper_freq))); % logarithmic mean
end

%for n = 1:length(center_freq)
    %lower_val = mag_smooth(flower(n));
    %upper_val = mag_smooth(fupper(n));
    %log_means(n) = (upper_val - lower_val)/(log(abs(upper_val/lower_val)));
%end

log_means1 = log_means - max(log_means);
figure(1)
subplot(2, 1, 1)
semilogx(freq, (mag - max(mag)))
xlim([50 13750])
ylim([-100 0])
title('Magnitude of unsmoothed IR')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on
subplot(2, 1, 2)
semilogx(center_freq, log_means1)
xlim([50 13750])
ylim([-100 0])
title('Logarithmic mean of magnitude of smoothed IR')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on

