function [ y_out ] = trimoff( y_in,fs )

%[ y_out ] = trimoff( y_in,fs )
%
% This function reduces the length of a vector (y_in) representing an audio
% file if silence lasted for over 10 seconds, which the number of deleted 
% values equal to sampling frequency (fs) x10. The end product is outputted as y_out. 
% Default fs = 44100.
if nargin <2
    fs = 44100;
end

if length(y_in)>(fs*10)
    count = 0;
    position = 0;

    for i = 1:length(y_in)
        if y_in(i) < 1e-10
            count = count +1;
        else
            count = 0;
        end

        if count>(fs*10)
            position = i;
            break
        end   
    end
    y_out = y_in(1:(position-(fs*10)));         %This would also run if position = 0 i.e. no silence of 10s?
else
    y_out = y_in;
end
    
end


