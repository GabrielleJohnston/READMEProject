function [sigma0, sigma_coef] = alphaToSigma(alpha_coef, lambda)
%ALPHATOSIGMA Converts feedback coefficients to sigma form for warped IIR
R = length(alpha_coef);
sigma_coef = zeros(R + 1, 1);
S = zeros(R, 1);
sigma_coef(R + 1) = lambda*alpha_coef(R);
S(R) = alpha_coef(R);
for i = 0:R-2
    j = R - i; % R, R - 1, ..., 2
    S(j - 1) = alpha_coef(j - 1) - lambda*S(j);
    sigma_coef(j) = lambda*S(j - 1) + S(j);
end
sigma_coef(1) = S(1);
sigma0 = 1 - lambda*S(1);
end

