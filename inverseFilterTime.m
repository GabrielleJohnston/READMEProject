function [inv, flag, error] = inverseFilterTime(IR, Ninv, reg, tol, maxiter, hpstop, hppass, fs)
%INVERSEFILTERTIME: finds time domain inverse filter with least squares
% solution of linear equation
% see http://www.aes.org/e-lib/browse.cfm?elib=12098
if nargin == 2
    beta = 0;
else
    beta = reg;
end
if nargin < 6
    regmatrix = eye(Ninv);
else 
    hpfilt = designfilt('highpassfir', 'StopbandFrequency', hpstop, 'PassbandFrequency', hppass, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', fs, 'DesignMethod', 'kaiserwin');
    bcoef = hpfilt.Coefficients;
    rb = [bcoef zeros(1, (Ninv- 1))]; 
    cb = [bcoef(1) zeros(1, (Ninv- 1))]; 
    B = toeplitz(rb, cb);
    regmatrix = B'*B;
end
m = floor(Ninv/2); % modelling delay
[row,col] = size(IR);
if col == 1
    r = [IR' zeros(1, (Ninv- 1))]; 
elseif row == 1
    r = [IR zeros(1, (Ninv- 1))]; 
end
c = [IR(1) zeros(1, (Ninv- 1))]; 
C = toeplitz(r, c); % convolution matrix
am = zeros(length(r), 1);
am(m + 1) = 1; % delta delayed by m, indexing starts at 1
A = C'*C + beta.*regmatrix;
b = C'*am;
if nargin < 4
[inv, flag, error] = lsqr(A, b);
elseif nargin == 4
    [inv, flag, error] = lsqr(A, b, tol);
else
    [inv, flag, error] = lsqr(A, b, tol, maxiter);
end

