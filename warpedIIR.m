function [v, filteredSignal] = warpedIIR(signal, b_coef, sigma_coef, sigma0, lambda)
%WARPEDIIR Summary of this function goes here
%   Detailed explanation goes here
nsigma = length(sigma_coef);
nb = length(b_coef);
g = 1/sigma0;


% feedbackward part
svcoef_b = [-lambda 1]; 
svcoef_a = [1 -lambda]; 
H1 = tf(svcoef_b,svcoef_a);
in = signal;

H3  = g*(sigma_coef(1))  +  g*(sigma_coef(2)*(H1^(1)));
for i = 3:nsigma
   H3  = H3 + g*(sigma_coef(i)*(H1^(i-1)));
end
H2 = g/(1+ H3*tf(1, [1 0]));

num = [H2.Numerator{1,1}]';
den = [H2.Denominator{1,1}]';

v = filter(den, num, in);


% feedforward part
filteredSignal = warpedFIR(v, b_coef, lambda);
end

