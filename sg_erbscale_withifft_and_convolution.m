%% Downsampling and smoothing signal
[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
NoSamples = info.TotalSamples;
dur = info.Duration;
trans = fft(data);
Retrans = abs(trans);
freq = fs*(0:NoSamples-1)/NoSamples;
mag = 20.*log10(Retrans);
phase = angle(trans);
erb = hz2erb(freq);
no_bands = round(erb(end));
T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector

sample_indx = zeros(no_bands, 1);
for n = 1:no_bands-1
    sample_indx(n) = find(round(erb) == n, 1);
end
sample_indx(end) = length(erb);

% In the smallest band can tell about 1 Hz apart - for safety do 0.5 Hz
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
new_phase = erb_space(phase', no_bands, samplesPerBand, band_spacing, sample_indx);

mag_smoothed_sgf_erb = sgolayfilt(new_mag, 9, 25);
phase_smoothed_sgf_erb = sgolayfilt(new_phase, 9, 25);
figure(1)
subplot(2, 1, 1);
semilogx(freq, mag)
grid on
xlim([10 100000])
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Unsmoothed magnitude spectrum')
subplot(2, 1, 2);
semilogx(new_freq, mag_smoothed_sgf_erb)
grid on
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 100000])
title('Smoothed magnitude spectrum')

figure(2)
subplot(2, 1, 1);
plot(erb, mag)
grid on
title('Unsmoothed magnitude spectrum')
xlabel('Equivalent rectangular bandwidth')
ylabel('Magnitude (dB)')
ylim([-100 50])
subplot(2, 1, 2);
new_freq_erb = hz2erb(new_freq);
plot(new_freq_erb, mag_smoothed_sgf_erb)
grid on
title('Smoothed magnitude spectrum')
xlabel('Equivalent rectangular bandwidth')
ylabel('Magnitude (dB)')
ylim([-100 50])

%% Interpolating so that frequencies are evenly spaced
finer_freq = 0:0.5:95999.5; % 0.5 freq throughout rather than varying spacing
interpol_phase_smoothed = interp1(new_freq, phase_smoothed_sgf_erb, finer_freq);
interpol_mag_smoothed = interp1(new_freq, mag_smoothed_sgf_erb, finer_freq);

% interpolate with original spacing
original_interpol_mag_smoothed = interp1(new_freq, mag_smoothed_sgf_erb, freq);
figure(3)
subplot(2, 1, 1);
semilogx(freq, mag)
grid on
xlim([10 100000])
ylim([-100 50])
title('Original magnitude plot')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
semilogx(finer_freq, interpol_mag_smoothed)
xlim([10 100000])
title('Smoothed and interpolated magnitude plot')
ylim([-100 50])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on

figure(4)
subplot(2, 1, 1);
semilogx(freq, phase)
grid on
xlim([10 100000])
title('Original phase plot')
xlabel('Frequency (Hz)')
ylabel('Phase')
subplot(2, 1, 2);
semilogx(finer_freq, interpol_phase_smoothed)
xlim([10 100000])
xlabel('Frequency (Hz)')
title('Smoothed and interpolated phase plot')
ylabel('Phase')
grid on

%% Caclculated the IFFT (not using smoothed phase)
Re_smoothed_sgf_erb = 10.^(interpol_mag_smoothed/20);
Spec = Re_smoothed_sgf_erb.*exp(1i*interpol_phase_smoothed);
Spec(isnan(Spec))=0;
smoothed_data = real(ifft(Spec)); % innacurate, don't use

Re_smoothed_sgf_erb_original = 10.^(original_interpol_mag_smoothed/20);
Spec_original = Re_smoothed_sgf_erb_original.*exp(1i*phase'); 
Spec_original(isnan(Spec_original))=0;
smoothed_data_original = real(ifft(Spec_original)); % accurate

figure(5)
subplot(2, 1, 1);
plot(t, data)
title('Original signal')
grid on
xlabel('time (s)')
subplot(2, 1, 2);
plot(t, smoothed_data_original)
title('Reconstructed smoothed signal')
xlabel('time (s)')
grid on


%% Multiplying with another signal
[data2, fs2] = audioread('car.wav');
info2 = audioinfo('car.wav');
NoSamples2 = info2.TotalSamples;
dur2 = info2.Duration;
trans2 = fft(data2);
mag2 = 20.*log10(abs(trans));
freq2 = fs*(0:NoSamples2-1)/NoSamples2;
T2 = 1/fs2;
t2 = (0:NoSamples2-1)*T2; %time vector

% Interpolating smoothed signals such that they have same fs as data2
interpol_mag_smoothed2 = interp1(new_freq, mag_smoothed_sgf_erb, freq2);
interpol_phase_smoothed2 = interp1(new_freq, phase_smoothed_sgf_erb, freq2);
Re_mag_smoothed2 = 10.^(interpol_mag_smoothed2/20);
Spec2 = Re_mag_smoothed2.*exp(1i*interpol_phase_smoothed2); 
%Spec2 = reconstructed Fourier transform with smoothed signals
mult2 = Spec2.*trans2';
mult2(isnan(mult2)) = 0;
mult_time = real(ifft(mult2));

figure(6)
subplot(2, 1, 1);
semilogx(freq2, mag2)
grid on
xlim([10 100000])
title('Original magnitude 2 plot')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
semilogx(freq2, mag_mult)
xlim([10 100000])
title('Magnitude 2 multiplied by magnitude 1 plot')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on

figure(7)
subplot(2, 1, 1);
plot(t2, data2)
title('Original signal')
grid on
xlabel('time (s)')
subplot(2, 1, 2);
plot(t2, mult_time)
title('Reconstructed signal multiplied in the frequency domain')
xlabel('time (s)')
grid on
