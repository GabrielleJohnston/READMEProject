function [THD, max_THD, freq_of_max_THD, min_THD, freq_of_min_THD] = calculateTHD(signal, signal_fs, windowedHarmonics)

final_harmonic = 10;
distortion_at = cell(40000, 10);
for frequency = 1:40000
    
    frequency_index = round(frequency.*length(signal)/signal_fs);   % find 
%   the index in the signal of each integer value of frequency from 1Hz to 
%   40kHz  

    distortion_at{frequency}(1) = 0;    % set the distortion due to the 
%   first harmonic to 0 for every frequency 

    for harmonic = 2:final_harmonic
       
        distortion_at{frequency}(harmonic) = 10^((windowedHarmonics{harmonic}(frequency_index) - windowedHarmonics{1}(frequency_index))/20);
%       calculate the distortion due to each harmonic at every frequency 
%       Note: distortion is given in decibels
    end
end

THD = zeros(1, 40000);
for frequency = 1:40000
    THD(frequency) = 20*log10(sum(distortion_at{frequency})); % Create an array of
%   the THD calculated at each frequency between 1Hz and 40kHz
end

% finding minimum THD
freq_of_min_THD = find(THD(15:20000) == min(THD(15:20000)));
min_THD = THD(freq_of_min_THD);

% finding maximum THD
freq_of_max_THD = find(THD(15:20000) == max(THD(15:20000)));
max_THD = THD(freq_of_max_THD);
end



