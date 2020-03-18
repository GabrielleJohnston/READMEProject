load bose_qc20_ir.mat
y = newA(:, 2);
fs = 24000;
NoSamples = length(y);
freq = fs.*(0:NoSamples - 1)/NoSamples; 
freq_long = 0:1:freq(end);
trans = fft(y);
mag = 20*log10(abs(trans));
phase = unwrap(angle(trans));
mag_interp = interp1(freq, mag, freq_long);
phase_interp = interp1(freq, phase, freq_long);

[mag_bark, freq_out] = rlogbarkranged(freq_long, mag_interp, 10, 22100);
[phase_bark, freq_out] = rgeobarkranged(freq_long, phase_interp, 10, 22100);

[freq_out_unique, freq_out_unique_index] = unique(freq_out);

freq_final = 10:5:22100;
mag_final = interp1(freq_out_unique, mag_bark(freq_out_unique_index), freq_final);
phase_final = interp1(freq_out_unique, phase_bark(freq_out_unique_index), freq_final);
Re_final = 10.^(mag_final./20);
trans_final = Re_final.*(exp(1i*wrapToPi(phase_final)));

MP = exp(fft(real(ifft(log(abs(trans_final))))));

MP_time = real(ifft(MP));
trans_time = real(ifft(trans_final));

lambda = barkwarp(22100);

MP_time_warped = warpImpulseResponse(MP_time, lambda); % warp impulse response

[a_MP_warped g_MP_warped] = lpc(MP_time_warped, 32);
[b_IIR, a_IIR] = prony(MP_time_warped, 4, 12);
%[b_IIR, a_IIR] = prony(MP_time_warped, 80, 80);
b_IIR = b_IIR./b_IIR(1);
a_IIR = a_IIR./b_IIR(1);
[sigma0, sigma_coef] = alphaToSigma(b_IIR(2:end), lambda); % b_IIR not a_IIR as we flip coef to get inverse

FIRequalised = warpedFIR(y, a_MP_warped(2:end), lambda);
[~, IIRequalised] = warpedIIR(y, a_IIR, sigma_coef, sigma0, lambda);
%audiowrite('FIRequalised_bose.wav', FIRequalised, fs);
%audiowrite('IIRequalised_bose.wav', IIRequalised, fs);
figure(1)
%subplot(2, 1, 1)
semilogx(freq, 20*log10(abs(fft(FIRequalised))))
hold on
semilogx(freq, 20*log10(abs(fft(IIRequalised))))
hold on
%semilogx(freq_final, 20*log10(abs(fft(trans_time))))
semilogx(freq, mag)
legend('MP FIR', 'MP IIR', 'Unfiltered', 'Location', 'southwest', 'fontsize', 12)
xlabel('Frequency (Hz)', 'fontsize', 12)
ylabel('Magnitude (dB)', 'fontsize', 12)
grid on
title('Comparing Equalisation Using: WFIR, WIIR, None', 'fontsize', 14)
fig1=figure(1);
fig1.Renderer='Painters';
%subplot(2, 1, 2)
%semilogx(freq, unwrap(angle(fft(FIRequalised))))
%hold on
%semilogx(freq, unwrap(angle(fft(IIRequalised))))
%hold on
%semilogx(freq, phase)
%xlabel('Frequency')
%ylabel('Phase (radians)')
%legend('MP FIR', 'MP IIR', 'Unfiltered')

%% test

[filt_FIR, fsfilt_FIR] = audioread('FIRequalised_bose.wav');
[filt_IIR, fsfilt_IIR] = audioread('IIRequalised_bose.wav');
mag_filt_FIR = 20*log10(abs(fft(filt_FIR)));
[mag_bark, freq_out] = rlogbarkranged(freq_long, mag_interp, 10, 22100);

%% Make comparisons - WFIR
data_abv = y;
freq_abv = freq;
[a_MP_warped, g_MP_warped] = lpc(MP_time_warped, 128);
[a_MP_warped1, g_MP_warped1] = lpc(MP_time_warped, 64);
[a_MP_warped2, g_MP_warped2] = lpc(MP_time_warped, 32);
[a_MP_warped256, g_MP_warped256] = lpc(MP_time_warped, 256);
[a_MP_warped512, g_MP_warped512] = lpc(MP_time_warped, 512);
[a_MP_warped3, g_MP_warped3] = lpc(MP_time_warped, 16);
trans_MP_filt_FIR32 = warpedFIR(data_abv, a_MP_warped2(2:end), lambda);
trans_MP_filt_FIR64 = warpedFIR(data_abv, a_MP_warped1(2:end), lambda);
trans_MP_filt_FIR128 = warpedFIR(data_abv, a_MP_warped(2:end), lambda);
trans_MP_filt_FIR256 = warpedFIR(data_abv, a_MP_warped256(2:end), lambda);
trans_MP_filt_FIR512 = warpedFIR(data_abv, a_MP_warped512(2:end), lambda);
trans_MP_filt_FIR16 = warpedFIR(data_abv, a_MP_warped3(2:end), lambda);

figure(2)
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
xlim([100 20000])
ylim([-160 -10])
fig2=figure(2);
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

figure(3)
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
xlim([100 20000])
ylim([-140 -10])
fig3=figure(3);
fig3.Renderer='Painters';

%% IIR higher coef numbers
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
figure(4)
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR5))))
%hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR6))))
%plot(1:length(trans_MP_filt_IIR5), trans_MP_filt_IIR5)
%hold on
plot(1:length(trans_MP_filt_IIR6), trans_MP_filt_IIR6)
%hold on
%plot(1:length(trans_MP_filt_IIR7), trans_MP_filt_IIR7)
%hold on
%plot(1:length(trans_MP_filt_IIR8), trans_MP_filt_IIR8)
%hold on
%plot(1:length(trans_MP_filt_IIR9), trans_MP_filt_IIR9)
grid on
legend('7 poles, 7 zeros', '8 poles, 8 zeros', '9 poles, 9 zeros', '10 poles, 10 zeros', 'fontsize', 14, 'Location', 'southwest')
xlabel('Signal index', 'fontsize', 14)
ylabel('Time-domain signal', 'fontsize', 14)
title('WIIR equalisation with more than 5 coefficients', 'fontsize', 16)
fig4=figure(4);
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
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR464))))
%hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR432)))-20)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR432))))
hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR416)))-40)
%hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR48)))-60)
%hold on
%semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR4)))-80)
semilogx(freq_abv, 20*log10(abs(fft(trans_MP_filt_IIR4))))
hold on
semilogx(freq, mag)
xlabel('Frequency (Hz)', 'fontsize', 14)
ylabel('Magnitude (dB)', 'fontsize', 14)
title('WIIR equalisation with different numbers of zeros and 5 poles', 'fontsize', 16)
grid on
xlim([100 20000])
legend('32 zeros', '5 zeros', 'Unfiltered', 'Location', 'southwest', 'fontsize', 14)
%ylim([-140 -10])
fig5=figure(11);
fig5.Renderer='Painters';
