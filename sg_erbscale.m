[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
NoSamples = info.TotalSamples;
[freq, mag] = getmag(data, fs, NoSamples);
erb = hz2erb(freq);
no_bands = round(erb(end));

sample_indx = zeros(no_bands, 1);
for n = 1:no_bands-1
    sample_indx(n) = find(round(erb) == n, 1);
end
sample_indx(end) = length(erb);

% In the smallest band can tell about 1 Hz apart - for safety go to 0.5
% Use same number of samples in each band
samplesPerBand = round(freq(sample_indx(1)) - freq(1))*2;
band_spacing = zeros(no_bands, 1);
freq_range = zeros(no_bands, 1);
for n = 1:no_bands
    if n == 1
        freq_range(n) = sample_indx(n) - 1;
    else
        freq_range(n) = sample_indx(n) - sample_indx(n - 1);
    end
    band_spacing(n) = round(freq_range(n)/samplesPerBand);
end

new_freq = erb_space(freq, no_bands, samplesPerBand, band_spacing, sample_indx);
new_mag = erb_space(mag', no_bands, samplesPerBand, band_spacing, sample_indx);

mag_smoothed_sgf_erb = sgolayfilt(new_mag, 9, 25, hamming(25));
figure(1)
subplot(2, 1, 1);
semilogx(freq, mag)
grid on
xlim([10 100000])
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
semilogx(new_freq, mag_smoothed_sgf_erb)
grid on
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 100000])

figure(2)
subplot(2, 1, 1);
plot(erb, mag)
grid on
xlabel('Equivalent rectangular bandwidth')
ylabel('Magnitude (dB)')
ylim([-100 50])
subplot(2, 1, 2);
new_freq_erb = hz2erb(new_freq);
plot(new_freq_erb, mag_smoothed_sgf_erb)
grid on
xlabel('Equivalent rectangular bandwidth')
ylabel('Magnitude (dB)')
ylim([-100 50])

