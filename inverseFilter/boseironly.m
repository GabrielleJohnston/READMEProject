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
audiowrite('FIRequalised_bose.wav', FIRequalised, fs);
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