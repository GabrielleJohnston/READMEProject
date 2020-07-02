function [minimumPhase, allPass, varargout] = inverseFilterv3(originalFFT)
%INVERSE FILTER Returns minimum phase and allpass components of IF
n = length(originalFFT);
original_cepstrum = real(ifft(log(abs(originalFFT))));
odd = fix(rem(n,2));
wn = [1; 2*ones((n+odd)/2-1,1) ; ones(1-rem(n,2),1); zeros((n+odd)/2-1,1)];
MP_original = zeros(size(originalFFT));
MP_original(:) = exp(fft(wn.*original_cepstrum(:))); % minimum phase part of signal
AP_original = originalFFT./MP_original; % allpass part of signal
minimumPhase = ones(size(MP_original))./MP_original; % minimum phase IF
allPass = ones(size(AP_original))./AP_original; % allpass IF
if nargout > 2
    varargout{1} = MP_original;
    if nargout > 3
        varargout{2} = AP_original;
    end
end
end

