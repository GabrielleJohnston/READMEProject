function out = warpedFIR(signal, coef, lambda)
%WARPEDFIR Apply warped FIR filter using an IIR filter
%   Based on conformation from Loudspeaker Response Equalisation Using 
% Warped Digital Filters

ncoef = length(coef); % number of coefficients
out = coef(1)*signal;
feed = signal;
a = [1 -lambda]';
b = [-lambda 1]';
for i = 2:ncoef
    temp = filter(b, a, feed);
    feed = temp;
    out_temp = out + (coef(i)).*temp;
    out = out_temp;
end


