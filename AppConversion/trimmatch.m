function [ y ] = trimmatch( x )
%[ y ] = trimmatch( x )
%
% This function uses trimoff.m on a 2 column vector (x), and match their
% length by filling zeroes to the shorter column. The result is outputted as y.

x1 = trimoff(x(:,1))
x2 = trimoff(x(:,2));
x1len = length(x1);
x2len = length(x2);

if x1len ~= x2len
    
    maxlen = max([x1len x2len]);

    if x1len == maxlen
        y(:,1) = x1;
        y(:,2) = [x2;zeros(maxlen-x2len,1)];
    else
        y(:,1) = [x1;zeros(maxlen-x1len,1)];
        y(:,2) = x2;
    end
else
    y = x;
end

end

