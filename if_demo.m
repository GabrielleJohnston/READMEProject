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

lambda = barkwarp(22000); % Use function provided by toolbox to get lambda
MP_time = real(ifft(MP_interp)); 
MP_time_warped = warpImpulseResponse(MP_time, lambda); % warp impulse response

% Get coefficients for all-pole approximation of MP_time_warped
[a_MP_warped, g_MP_warped] = lpc(MP_time_warped, 128);
[a_MP_warped1, g_MP_warped1] = lpc(MP_time_warped, 64);
[a_MP_warped2, g_MP_warped2] = lpc(MP_time_warped, 32);
[a_MP_warped256, g_MP_warped256] = lpc(MP_time_warped, 256);
[a_MP_warped512, g_MP_warped512] = lpc(MP_time_warped, 512);
[a_MP_warped3, g_MP_warped3] = lpc(MP_time_warped, 16);

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
figure(6)
for alex = 1:5
 % warp impulse response
[b_IIR, a_IIR] = prony(MP_time_warped, alex, alex+1);
%a_AP_norm = a_AP./b_AP(1);
%b_AP_norm = b_AP./b_AP(1);
[sigma0, sigma_coef] = alphaToSigma(b_IIR, lambda); % b_IIR not a_IIR as we flip coef to get inverse
[in, MP_filt] = warpedIIR(MP_time, a_IIR, sigma_coef, sigma0, lambda);

semilogx(freq_long, 20*log10(abs(fft(MP_filt))))
hold on
end
legend('1', '2', '3', '4', '5')

%% Test equaliser
trans_MP_filt_FIR = warpedFIR(data_abv, a_MP_warped2(2:end), lambda);
[~, trans_MP_filt_IIR] = warpedIIR(data_abv, a_IIR, sigma_coef, sigma0, lambda);
figure(7)
%subplot(2, 1, 1)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR))))
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR))))
hold on
semilogx(freq_abv, mag_abv)
legend('MP WFIR', 'MP WIIR', 'Unfiltered', 'fontsize', 14, 'Location', 'southwest')
xlabel('Frequency (Hz)', 'fontsize', 14)
ylabel('Magnitude (dB)', 'fontsize', 14)
title('Comparing Equalisation Using: WFIR, WIIR, None', 'fontsize', 16)
grid on
fig1=figure(7);
fig1.Renderer='Painters';
xlim([10 24000])
%subplot(2, 1, 2)
%semilogx(freq_abv, unwrap(angle(fft(trans_MP_filt_FIR))))
%hold on
%semilogx(freq_abv, unwrap(angle(fft(trans_MP_filt_IIR))))
%hold on
%semilogx(freq_abv, phase_interp)
%xlabel('Frequency')
%ylabel('Phase (radians)')
%xlim([10 40000])

%% Make comparisons - WFIR
trans_MP_filt_FIR32 = warpedFIR(data_abv, a_MP_warped2(2:end), lambda);
trans_MP_filt_FIR64 = warpedFIR(data_abv, a_MP_warped1(2:end), lambda);
trans_MP_filt_FIR128 = warpedFIR(data_abv, a_MP_warped(2:end), lambda);
trans_MP_filt_FIR256 = warpedFIR(data_abv, a_MP_warped256(2:end), lambda);
trans_MP_filt_FIR512 = warpedFIR(data_abv, a_MP_warped512(2:end), lambda);
trans_MP_filt_FIR16 = warpedFIR(data_abv, a_MP_warped3(2:end), lambda);

figure(8)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR512))))
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR256)))-20)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR128)))-40)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR64)))-60)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR32)))-80)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_FIR16)))-100)
xlabel('Frequency (Hz)', 'fontsize', 12)
ylabel('Magnitude (dB)', 'fontsize', 12)
title('WFIR equalisation with different taps', 'fontsize', 14)
grid on
xlim([10 20000])
ylim([-150 30])
fig2=figure(8);
fig2.Renderer='Painters';

%% Make comparisons - WIIR

[b_IIR1, a_IIR1] = prony(MP_time_warped, 1, 2);
[b_IIR2, a_IIR2] = prony(MP_time_warped, 2, 3);
[b_IIR3, a_IIR3] = prony(MP_time_warped, 3, 4);
[b_IIR4, a_IIR4] = prony(MP_time_warped, 4, 5);
[b_IIR5, a_IIR5] = prony(MP_time_warped, 5, 6);

[sigma01, sigma_coef1] = alphaToSigma(b_IIR1, lambda);
[sigma02, sigma_coef2] = alphaToSigma(b_IIR2, lambda);
[sigma03, sigma_coef3] = alphaToSigma(b_IIR3, lambda);
[sigma04, sigma_coef4] = alphaToSigma(b_IIR4, lambda);
[sigma05, sigma_coef5] = alphaToSigma(b_IIR5, lambda);

[~, trans_MP_filt_IIR1] = warpedIIR(data_abv, a_IIR1, sigma_coef1, sigma01, lambda);
[~, trans_MP_filt_IIR2] = warpedIIR(data_abv, a_IIR2, sigma_coef2, sigma02, lambda);
[~, trans_MP_filt_IIR3] = warpedIIR(data_abv, a_IIR3, sigma_coef3, sigma03, lambda);
[~, trans_MP_filt_IIR4] = warpedIIR(data_abv, a_IIR4, sigma_coef4, sigma04, lambda);
[~, trans_MP_filt_IIR5] = warpedIIR(data_abv, a_IIR5, sigma_coef5, sigma05, lambda);

figure(9)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR5))))
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR4)))-20)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR3)))-40)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR2)))-60)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR1)))-80)
xlabel('Frequency (Hz)', 'fontsize', 14)
ylabel('Magnitude (dB)', 'fontsize', 14)
title('WIIR equalisation with different numbers of coefficients', 'fontsize', 16)
grid on
xlim([10 20000])
ylim([-120 40])
fig3=figure(9);
fig3.Renderer='Painters';

%% Show WIIR higher coefficient numbers 
[b_IIR7, a_IIR7] = prony(MP_time_warped, 7, 8);
[b_IIR6, a_IIR6] = prony(MP_time_warped, 6, 7);
[b_IIR8, a_IIR8] = prony(MP_time_warped, 8, 9);
[b_IIR9, a_IIR9] = prony(MP_time_warped, 9, 10);
[sigma07, sigma_coef7] = alphaToSigma(b_IIR7, lambda);
[sigma06, sigma_coef6] = alphaToSigma(b_IIR6, lambda);
[sigma08, sigma_coef8] = alphaToSigma(b_IIR8, lambda);
[sigma09, sigma_coef9] = alphaToSigma(b_IIR9, lambda);
[~, trans_MP_filt_IIR6] = warpedIIR(data_abv, a_IIR6, sigma_coef6, sigma06, lambda);
[~, trans_MP_filt_IIR7] = warpedIIR(data_abv, a_IIR7, sigma_coef7, sigma07, lambda);
[~, trans_MP_filt_IIR8] = warpedIIR(data_abv, a_IIR8, sigma_coef8, sigma08, lambda);
[~, trans_MP_filt_IIR9] = warpedIIR(data_abv, a_IIR9, sigma_coef9, sigma09, lambda);
figure(10)
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR5))))
%hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR6))))
plot(1:length(trans_MP_filt_IIR6), trans_MP_filt_IIR6)
hold on
plot(1:length(trans_MP_filt_IIR7), trans_MP_filt_IIR7)
hold on
plot(1:length(trans_MP_filt_IIR8), trans_MP_filt_IIR8)
hold on
plot(1:length(trans_MP_filt_IIR9), trans_MP_filt_IIR9)
grid on
legend('7 poles, 7 zeros', '8 poles, 8 zeros', '9 poles, 9 zeros', '10 poles, 10 zeros', 'fontsize', 14, 'Location', 'southwest')
xlabel('Signal index', 'fontsize', 14)
ylabel('Time-domain signal', 'fontsize', 14)
title('WIIR equalisation with more than 5 coefficients', 'fontsize', 16)
fig4=figure(10);
fig4.Renderer='Painters';

%% Show WIIR more zeros than poles
[b_IIR48, a_IIR48] = prony(MP_time_warped, 4, 8);
[sigma048, sigma_coef48] = alphaToSigma(b_IIR48, lambda);
[~, trans_MP_filt_IIR48] = warpedIIR(data_abv, a_IIR48, sigma_coef48, sigma048, lambda);

[b_IIR416, a_IIR416] = prony(MP_time_warped, 4, 16);
[sigma0416, sigma_coef416] = alphaToSigma(b_IIR416, lambda);
[~, trans_MP_filt_IIR416] = warpedIIR(data_abv, a_IIR416, sigma_coef416, sigma0416, lambda);

[b_IIR432, a_IIR432] = prony(MP_time_warped, 4, 32);
[sigma0432, sigma_coef432] = alphaToSigma(b_IIR432, lambda);
[~, trans_MP_filt_IIR432] = warpedIIR(data_abv, a_IIR432, sigma_coef432, sigma0432, lambda);

[b_IIR464, a_IIR464] = prony(MP_time_warped, 4, 64);
[sigma0464, sigma_coef464] = alphaToSigma(b_IIR464, lambda);
[~, trans_MP_filt_IIR464] = warpedIIR(data_abv, a_IIR464, sigma_coef464, sigma0464, lambda);

figure(11)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR464))))
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR432)))-20)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR416)))-40)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR48)))-60)
hold on
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR4)))-80)
xlabel('Frequency (Hz)', 'fontsize', 14)
ylabel('Magnitude (dB)', 'fontsize', 14)
title('WIIR equalisation with different numbers of zeros and 5 poles', 'fontsize', 16)
grid on
xlim([10 20000])
ylim([-120 40])
fig5=figure(11);
fig5.Renderer='Painters';