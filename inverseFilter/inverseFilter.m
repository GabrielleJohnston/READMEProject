function [minimumPhase, allPass] = inverseFilter(originalFFT)
%INVERSE FILTER Returns minimum phase and allpass components of IF
original_cepstrum = real(ifft(log(abs(originalFFT))));
MP_original = exp(fft(original_cepstrum)); % minimum phase part of signal
AP_original = originalFFT./MP_original; % allpass part of signal
minimumPhase = ones(size(MP_original))./MP_original; % minimum phase IF
allPass = ones(size(AP_original))./AP_original; % allpass IF
end

