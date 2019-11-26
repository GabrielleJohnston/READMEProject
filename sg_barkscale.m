[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
dur = info.Duration;
NoSamples = info.TotalSamples;
trans = fft(data);
Retrans = abs(trans);
freq = fs*(0:NoSamples-1)/NoSamples;
mag = 20.*log10(Retrans);
phase = unwrap(angle(trans));
%phase = angle(trans);
barkScale = hz2bark(freq);
barkScaleBands = 25; % 24 + 1 for rest of band
T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector
group_delay = -diff(phase)./(diff(freq')*360);
phase_deg = phase*(180/pi);

bark_freq = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 48000];;
start_freq_indx = 1;
end_freq_indx = zeros(barkScaleBands, 1);
for i = 1:barkScaleBands
    endf = find(round(freq) == bark_freq(i), 1);
    end_freq_indx(i) = endf;
end

% extra 6 for rest of band
idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 17 17 16 15 14 13 12 10 7 4 5 5 6 6];

band_spacing = zeros(barkScaleBands, 1);
for i = 1:barkScaleBands
    if i == 1
        band_spacing(i) = round((end_freq_indx(i))/idealNoPoints(i));
    else
        band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints(i));
    end
end

new_freq = bark_space(freq, barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
new_mag = bark_space(mag', barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
new_phase = bark_space(phase', barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
new_group_delay = bark_space(group_delay', barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);

mag_smoothed_sgf_bark = sgolayfilt(new_mag, 9, 25);
phase_smoothed_sgf_bark = sgolayfilt(new_phase, 9, 25);
group_delay_smoothed_sgf_bark = sgolayfilt(new_group_delay, 9, 25);
new_freq_bark = hz2bark(new_freq);

mag0 = mag - max(mag);
mag_smoothed_sgf_bark0 = mag_smoothed_sgf_bark - max(mag_smoothed_sgf_bark);

figure(1)
subplot(2, 1, 1);
semilogx(freq(1:end_freq_indx(end)), mag0(1:end_freq_indx(end)))
title('Unsmoothed magnitude spectrum')
grid on
xlim([10 40000])
ylim([-120 0])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
semilogx(new_freq, mag_smoothed_sgf_bark0)
grid on
ylim([-120 0])
title('Smoothed magnitude spectrum')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([10 40000])

figure(2)
subplot(2, 1, 1);
plot(barkScale(1:end_freq_indx(end)), mag0(1:end_freq_indx(end)))
grid on
title('Unsmoothed magnitude spectrum')
ylim([-120 0])
xlabel('Bark')
ylabel('Magnitude (dB)')
subplot(2, 1, 2);
plot(new_freq_bark, mag_smoothed_sgf_bark0)
grid on
ylim([-120 0])
title('Smoothed magnitude spectrum')
xlabel('Bark')
ylabel('Magnitude (dB)')

figure(3)
subplot(2, 1, 1);
semilogx(freq(1:end_freq_indx(end)), phase(1:end_freq_indx(end)))
title('Unsmoothed phase spectrum')
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')
subplot(2, 1, 2);
semilogx(new_freq, phase_smoothed_sgf_bark)
grid on
title('Smoothed phase spectrum')
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')
xlim([10 40000])

%% Interpolating so that frequencies are evenly spaced
finer_freq = 0:2.5:47997.5; % 2.5 freq throughout rather than varying spacing
interpol_phase_smoothed = interp1(new_freq, phase_smoothed_sgf_bark, finer_freq);
interpol_mag_smoothed = interp1(new_freq, mag_smoothed_sgf_bark, finer_freq);

% interpolate with original spacing
original_interpol_mag_smoothed = interp1(new_freq, mag_smoothed_sgf_bark, freq(1:end_freq_indx(end)));

%% Caclculated the IFFT (not using smoothed phase)
Re_smoothed_sgf_bark = 10.^(interpol_mag_smoothed/20);
Spec = Re_smoothed_sgf_bark.*exp(1i*interpol_phase_smoothed);
Spec(isnan(Spec))=0;
smoothed_data = real(ifft(Spec)); % innacurate, don't use

Re_smoothed_sgf_bark_original = 10.^(original_interpol_mag_smoothed/20);
phase_shortened = phase(1:end_freq_indx(end));
Spec_original = Re_smoothed_sgf_bark_original.*exp(1i*phase_shortened'); 
Spec_original(isnan(Spec_original))=0;
smoothed_data_original = real(ifft(Spec_original)); % accurate

Tnew = dur/length(smoothed_data);
tnew = (0:length(smoothed_data) - 1).*Tnew;
Tnew_original = 1/48000; %sampling period
tnew_original = (0:length(smoothed_data_original)-1)*Tnew_original; %time vector
figure(5)
subplot(2, 1, 1);
plot(t, data)
title('Original signal')
grid on
xlabel('time (s)')
subplot(2, 1, 2);
plot(tnew_original, smoothed_data_original)
title('Reconstructed smoothed signal')
xlabel('time (s)')
grid on
smoothed_data_original1 = smoothed_data_original(1:round(end/2));
audiowrite('Signalbark.wav', smoothed_data_original1, 48000);

group_delay_smooth = -diff(new_phase)./(diff(new_freq)*360);
group_delay_orig = -diff(phase)./(diff(freq')*360);
group_delay_ms_smooth = 1000*group_delay_smooth;
new_phase_deg = new_phase*(180/pi);
phase_smoothed_sgf_bark_deg = phase_smoothed_sgf_bark*(180/pi);

figure(6)
subplot(3, 1, 1)
semilogx(freq, mag0)
hold on
semilogx(new_freq, mag_smoothed_sgf_bark0)
legend('Unsmoothed', 'Smoothed')
xlim([10 40000])
title('Magnitude of IR')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on
subplot(3, 1, 2)
semilogx(freq, phase_deg)
hold on
semilogx(new_freq, phase_smoothed_sgf_bark_deg)
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Phase (degrees)')
title('Phase of IR')
legend('Unsmoothed', 'Smoothed')
grid on
subplot(3, 1, 3)
semilogx(freq(2:end), 1000*group_delay)
hold on
semilogx(new_freq, 1000*group_delay_smoothed_sgf_bark)
%semilogx(freq(2:end), 1000*group_delay_orig)
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Group delay (ms)')
title('Group delay of IR')
legend('Unsmoothed', 'Smoothed')
grid on

%% Inverse filter
Re_smoothed_sgf_bark_notinterpol = 10.^(mag_smoothed_sgf_bark/20);
trans_bark = Re_smoothed_sgf_bark_notinterpol.*exp(1i*phase_smoothed_sgf_bark);
trans_bark_conj = Re_smoothed_sgf_bark_notinterpol.*exp(-1i*phase_smoothed_sgf_bark);
inverse_filter_freq = trans_bark_conj./((Re_smoothed_sgf_bark_notinterpol).^2);
inverse_filter_freq(isnan(inverse_filter_freq))=0;
% run the following to see that all values = 1
trans_bark.*inverse_filter_freq 
% could then interpolate/upsample if necessary