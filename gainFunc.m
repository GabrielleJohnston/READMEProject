function gain = gainFunc(Rprio, Rpost)
theta = (1 + Rpost).*(Rprio./(1 + Rprio));
M = MFunc(theta);
gain = (sqrt(pi)/2).*sqrt((1./(1 + Rpost)).*(Rprio./(1 + Rprio))).*M;
end

