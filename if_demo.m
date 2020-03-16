clear all
close all
%% Theoretical demonstration
[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
dur = info.Duration;
NoSamples = info.TotalSamples;

% Take small portion of impulse response cutting zeros values and
% distortions
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

% rectangular bark smoothing
[mag_abv_rlog_mean_bark, freq_abv_bark] = rlogbark(freq_abv, mag_abv);
[phase_abv_geo_mean_bark, freq_abv_bark] = rgeobark(freq_abv, phase_abv);
[grp_abv_geo_mean_bark, freq_abv_bark] = rgeobark(freq_abv, group_delay_abv);

% shift so that max is at 0
%mag_bark_adj = mag_abv_rlog_mean_bark - max(mag_abv_rlog_mean_bark);
mag_bark_adj = mag_abv_rlog_mean_bark;
Re_trans_bark = 10.^(mag_bark_adj./20);
trans_bark = Re_trans_bark.*(exp(1i*wrapToPi(phase_abv_geo_mean_bark)));

% get inverse filter values
[MP_inv, AP_inv] = inverseFilter(trans_bark);

% minimum phase only equalising
signal_equalised_MP_only = trans_bark.*MP_inv;
mag_equalised_MP_only = 20.*log10(abs(signal_equalised_MP_only));
phase_equalised_MP_only = unwrap(angle(signal_equalised_MP_only));
group_delay_equalised_MP_only= -diff(phase_equalised_MP_only)./(diff(freq_abv_bark')*360);

% minimum phase + 50% of allpass equalising
signal_equalised_MP_halfAP = signal_equalised_MP_only.*(0.5.*AP_inv);
mag_equalised_MP_halfAP = 20.*log10(abs(signal_equalised_MP_halfAP));
phase_equalised_MP_halfAP = unwrap(angle(signal_equalised_MP_halfAP));
group_delay_equalised_MP_halfAP = -diff(phase_equalised_MP_halfAP)./(diff(freq_abv_bark')*360);

% minimum phase + allpass equalising
signal_equalised_MP_and_AP = signal_equalised_MP_only.*AP_inv;
mag_equalised_MP_and_AP = 20.*log10(abs(signal_equalised_MP_and_AP));
phase_equalised_MP_and_AP = unwrap(angle(signal_equalised_MP_and_AP));
group_delay_equalised_MP_and_AP = -diff(phase_equalised_MP_and_AP)./(diff(freq_abv_bark')*360);

% finding group delay applied by minimum phase and allpass filters
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

%% Designing FIR filter 
% Get and interpolate minimum phase response
MP = exp(fft(real(ifft(log(abs(trans_bark))))));
MP_mag = 20*log10(abs(MP));
MP_phase = unwrap(angle(MP));
spacing = 5*(48001/48000);
freq_long = 0:spacing:48000;
[freq_abv_bark_unique, freq_abv_bark_unique_index] = unique(freq_abv_bark);
MP_mag_interp = interp1(freq_abv_bark_unique, MP_mag(freq_abv_bark_unique_index), freq_long);
MP_phase_interp = interp1(freq_abv_bark_unique, MP_phase(freq_abv_bark_unique_index), freq_long);
Re_MP_interp = 10.^(MP_mag_interp./20);
MP_interp = Re_MP_interp.*(exp(1i*wrapToPi(MP_phase_interp)));

lambda = barkwarp(48000); % Use function provided by toolbox to get lambda
MP_time = real(ifft(MP_interp)); 
MP_time_warped = warpImpulseResponse(MP_time, lambda); % warp impulse response

% Get coefficients for all-pole approximation of MP_time_warped
[a_MP_warped, g_MP_warped] = lpc(MP_time_warped, 128)
[a_MP_warped1, g_MP_warped1] = lpc(MP_time_warped, 64)
[a_MP_warped2, g_MP_warped2] = lpc(MP_time_warped, 32)

% Flip coefficients to apply inverse filter with FIR filter (zeros only)
% First index of a_MP_warped is 1, not a coefficient (ignore when filtering)
y = warpedFIR(MP_time, a_MP_warped(2:end), lambda);
y1 = warpedFIR(MP_time, a_MP_warped1(2:end), lambda);
y2 = warpedFIR(MP_time, a_MP_warped2(2:end), lambda);

% Plot results
figure(5)
semilogx(freq_long, 20*log10(abs(fft(y))))
hold on
semilogx(freq_long, 20*log10(abs(fft(y1))))
hold on
semilogx(freq_long, 20*log10(abs(fft(y2))))
hold on
semilogx(freq_long, 20*log10(abs(MP_interp)))
legend('128', '64', '32', 'Unfiltered')
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Original and equalised minimum phase response')
%% Designing IIR filter 
AP = trans_bark./MP;
AP_mag = 20*log10(abs(AP));
AP_phase = unwrap(angle(AP));
AP_mag_interp = interp1(freq_abv_bark_unique, AP_mag(freq_abv_bark_unique_index), freq_long);
AP_phase_interp = interp1(freq_abv_bark_unique, AP_phase(freq_abv_bark_unique_index), freq_long);
Re_AP_interp = 10.^(AP_mag_interp./20);
AP_interp = Re_AP_interp.*(exp(1i*wrapToPi(AP_phase_interp)));

figure(6)
for alex = 1:5
AP_time = real(ifft(AP_interp)); 
AP_time_warped = warpImpulseResponse(AP_time, lambda); % warp impulse response
[b_AP, a_AP] = prony(AP_time_warped, alex, alex);
a_AP_norm = a_AP./b_AP(1);
b_AP_norm = b_AP./b_AP(1);
[sigma0, sigma_coef] = alphaToSigma(b_AP_norm, lambda); % b_AP not a_AP as we flip coef to get inverse
[in, AP_filt] = warpedIIR(AP_time, a_AP_norm, sigma_coef(2:end), sigma0, lambda);

semilogx(freq_long, 20*log10(abs(fft(AP_filt))))
hold on
end

