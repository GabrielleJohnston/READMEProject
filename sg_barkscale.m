[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
NoSamples = info.TotalSamples;
[freq, mag] = getmag(data, fs, NoSamples);
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

mag_smoothed_sgf_bark = sgolayfilt(new_mag, 9, 25, hamming(25));
new_freq_bark = hz2bark(new_freq);

figure(1)
subplot(2, 1, 1);
semilogx(freq(1:end_freq_indx(end)), mag(1:end_freq_indx(end)))
title('Unsmoothed magnitude spectrum')
grid on
xlim([10 16000])
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
semilogx(new_freq, mag_smoothed_sgf_bark)
grid on
ylim([-100 50])
title('Smoothed magnitude spectrum')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 16000])

figure(2)
subplot(2, 1, 1);
plot(barkScale(1:end_freq_indx(end)), mag(1:end_freq_indx(end)))
grid on
title('Unsmoothed magnitude spectrum')
ylim([-100 50])
xlim([0 24])
xlabel('Bark')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
plot(new_freq_bark, mag_smoothed_sgf_bark)
grid on
ylim([-100 50])
title('Smoothed magnitude spectrum')
xlim([0 24])
xlabel('Bark')
ylabel('Magnitude (dB)')