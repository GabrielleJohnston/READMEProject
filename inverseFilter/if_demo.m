%% Theoretical demonstration
[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
dur = info.Duration;
NoSamples = info.TotalSamples;

range_start = 522400;
range_end = 559600;
data_abv = data(range_start:range_end);
NoSamples_abv = length(data_abv);
T = 1/fs; %sampling period
t_abv = (0:NoSamples_abv-1)*T; %time vector

trans_abv = fft(data_abv);
freq_abv = fs*(0:NoSamples_abv-1)/NoSamples_abv;

mag_abv = 20*log10(abs(trans_abv));
phase_abv = unwrap(angle(trans_abv));
group_delay_abv = -diff(phase_abv)./(diff(freq_abv')*360);

[mag_abv_rlog_mean_bark, freq_abv_bark] = rlogbark(freq_abv, mag_abv);
[phase_abv_geo_mean_bark, freq_abv_bark] = rgeobark(freq_abv, phase_abv);
[grp_abv_geo_mean_bark, freq_abv_bark] = rgeobark(freq_abv, group_delay_abv);

mag_bark_adj = mag_abv_rlog_mean_bark - max(mag_abv_rlog_mean_bark);

Re_trans_bark = 10.^(mag_bark_adj./20);
trans_bark = Re_trans_bark.*(exp(1i*wrapToPi(phase_abv_geo_mean_bark)));

[MP_inv, AP_inv] = inverseFilter(trans_bark);

signal_equalised_MP_only = trans_bark.*MP_inv;
mag_equalised_MP_only = 20.*log10(abs(signal_equalised_MP_only));
phase_equalised_MP_only = unwrap(angle(signal_equalised_MP_only));
group_delay_equalised_MP_only= -diff(phase_equalised_MP_only)./(diff(freq_abv_bark')*360);

signal_equalised_MP_halfAP = signal_equalised_MP_only.*(0.5.*AP_inv);
mag_equalised_MP_halfAP = 20.*log10(abs(signal_equalised_MP_halfAP));
phase_equalised_MP_halfAP = unwrap(angle(signal_equalised_MP_halfAP));
group_delay_equalised_MP_halfAP = -diff(phase_equalised_MP_halfAP)./(diff(freq_abv_bark')*360);

signal_equalised_MP_and_AP = signal_equalised_MP_only.*AP_inv;
mag_equalised_MP_and_AP = 20.*log10(abs(signal_equalised_MP_and_AP));
phase_equalised_MP_and_AP = unwrap(angle(signal_equalised_MP_and_AP));
group_delay_equalised_MP_and_AP = -diff(phase_equalised_MP_and_AP)./(diff(freq_abv_bark')*360);

phase_MP_inv = unwrap(angle(MP_inv));
phase_AP_inv = unwrap(angle(AP_inv));
group_delay_MP_inv= -diff(phase_MP_inv)./(diff(freq_abv_bark')*360);
group_delay_AP_inv= -diff(phase_AP_inv)./(diff(freq_abv_bark')*360);

figure(1)
subplot(3, 1, 1)
semilogx(freq_abv_bark, mag_equalised_MP_only)
title('Minimum phase equalised only');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(3, 1, 2)
semilogx(freq_abv_bark, mag_equalised_MP_halfAP)
title('Minimum phase and 50% allpass equalised');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
subplot(3, 1, 3)
semilogx(freq_abv_bark, mag_equalised_MP_and_AP)
title('Minimum phase and allpass equalised');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')

figure(2)
subplot(3, 1, 1)
semilogx(freq_abv_bark, phase_equalised_MP_only)
title('Minimum phase equalised only');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')
subplot(3, 1, 2)
semilogx(freq_abv_bark, phase_equalised_MP_halfAP)
title('Minimum phase and 50% allpass equalised');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')
subplot(3, 1, 3)
semilogx(freq_abv_bark, phase_equalised_MP_and_AP)
title('Minimum phase and allpass equalised');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')

figure(3)
subplot(2, 1, 1)
semilogx(freq_abv_bark(2:end), group_delay_MP_inv)
title('Minimum phase inverse filter applied group delay');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Group delay (s)')
subplot(2, 1, 2)
semilogx(freq_abv_bark(2:end), group_delay_AP_inv)
title('Allpass inverse filter applied group delay');
grid on
xlim([10 40000])
xlabel('Frequency (Hz)')
ylabel('Group delay (s)')

