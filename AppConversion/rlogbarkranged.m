function [log_means, freq_out] = rlogbarkranged(freq, signal, min_freq, max_freq)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 17 17 16 15 14 13 12 10 7 4 5 5 6 6];
    barkScaleBands = 25; % 24 + 1 for 15500 to 48000 Hz
    bark_freq = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 48000];
    if min_freq < 0.01
        min_freq = 0.01; % reasonable minimum value
    end
    if max_freq > 48000
        max_freq = 48000; % more than enough, can change later if need be
    end
    for i = 1:length(bark_freq)
        if i == 1
            if bark_freq(i) > min_freq
                min_freq_bark_band = i;
                break;
            end
        else
            if bark_freq(i) > min_freq
                if bark_freq(i - 1) < min_freq
                    min_freq_bark_band = i;
                break;
                end
            end
        end
    end
    for i = 1:length(bark_freq)
        if bark_freq(i) > max_freq
            max_freq_bark_band = i;
            break;
        elseif max_freq > bark_freq(end)
            max_freq = bark_freq(end);
            max_freq_bark_band = length(bark_freq);
        end
    end
    bark_freq_ranged = bark_freq(min_freq_bark_band:max_freq_bark_band); % removes unnneeded bands
    idealNoPoints_ranged = idealNoPoints(min_freq_bark_band:max_freq_bark_band);
    bark_freq_ranged(end) = max_freq;
    start_freq_indx = find(round(freq) == min_freq, 1);
    if isempty(start_freq_indx)
        sf1 = find(freq > min_freq, 1);
        sf2 = find(freq < min_freq, 1);
        if isempty(sf2)
            start_freq_indx = sf1;
        elseif (abs(freq(sf1) - min_freq) < abs(freq(sf2) - min_freq))
            start_freq_indx = sf1;
        else
            start_freq_indx = sf2;
        end
    end
    end_freq_indx = zeros(length(bark_freq_ranged), 1); % freq indexes closest to bark freq
    for i = 1:length(bark_freq_ranged)
        if i < length(bark_freq_ranged)
            endf = find(round(freq) == bark_freq(i), 1);
            if isempty(endf)
                endf1 = find(freq > bark_freq(i), 1);
                endf2 = find(freq < bark_freq(i), 1);
                if (abs(freq(endf1) - bark_freq(i)) < abs(freq(endf2) - bark_freq(i)))
                    endf = endf1;
                else
                    endf = end2;
                end
            end
            end_freq_indx(i) = endf;
        else
            endf = find(round(freq) == max_freq, 1);
            if isempty(endf)
                endf1 = find(freq > bark_freq(i), 1);
                endf2 = find(freq < bark_freq(i), 1);
                if isempty(endf1)
                    endf = endf2;
                elseif (abs(freq(endf1) - max_freq) < abs(freq(endf2) - max_freq))
                    endf = endf1;
                else
                    endf = end2;
                end
            end
            end_freq_indx(i) = endf;
        end
    end
    band_spacing = zeros(length(bark_freq_ranged), 1); % # of indices between samples in each band
    for i = 1:length(bark_freq_ranged)
        if i == 1
            band_spacing(i) = round((end_freq_indx(i) - start_freq_indx)/idealNoPoints_ranged(i));
        else
            band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints_ranged(i));
        end
    end
    freq_indx = start_freq_indx:band_spacing(1):(band_spacing(1)*(idealNoPoints_ranged(1)-1) + start_freq_indx); % samples in 1st band
    for n = 2:length(bark_freq_ranged)
        freq_indx_temp = (end_freq_indx(n - 1)):band_spacing(n):(band_spacing(n)*(idealNoPoints_ranged(n) - 1) + end_freq_indx(n - 1));
        freq_indx_temp2 = horzcat(freq_indx, freq_indx_temp); % concatenate 
        if n < length(bark_freq_ranged)
            freq_indx = freq_indx_temp2;
        else
            freq_indx_temp3 = horzcat(freq_indx_temp2, end_freq_indx(n)); % appends max_freq index
            freq_indx = freq_indx_temp3;
        end
    end
    
    avg_spacing = zeros(length(freq_indx) - 1, 1); % avg spacing between samples, used for avging, no avging on 1st sample
    avg_spacing_count = 0;
    for i = 1:length(idealNoPoints_ranged)
        if i == 1
            for j = 2:idealNoPoints_ranged(i)
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        else
            for j = 1:idealNoPoints_ranged(i)
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        end
    end
    log_means = zeros(length(freq_indx), 1);
    log_means(1) = signal(freq_indx(1));
    for n = 2:length(freq_indx)-1
        log_means(n) = 10*log10(sum(10.^(0.1*signal((freq_indx(n) - floor(avg_spacing(n - 1)/2)):(freq_indx(n) + floor(avg_spacing(n - 1)/2)))))/(avg_spacing(n - 1))); % logarithmic mean
    end
    % replace max_freq Hz avg with avg over smaller range
    log_means(end) = 10*log10(sum(10.^(0.1*signal((freq_indx(end) - round(band_spacing(end)/2)):(freq_indx(end)))))/(round(band_spacing(end)/2) + 1));
    freq_out = freq(freq_indx);
    for n = 2:length(freq_out)
        if freq_out(n) <= freq_out(n - 1)
            freq_out(n) = freq_out(n - 1);
            log_means(n) = log_means(n - 1);
        end
    end
end



