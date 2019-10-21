function M = MFunc(theta)
M1 = exp(-0.5*theta);
I0 = besseli(0, (0.5*theta));
I1 = besseli(1, (0.5*theta));
M2 = (1 + theta).*I0 + theta.*I1;
M = M1.*M2;
end