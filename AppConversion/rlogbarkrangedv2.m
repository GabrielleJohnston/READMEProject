function [log_means, freq_out] = rlogbarkrangedv2(freq, signal, min_freq, max_freq)
%RLOGBARKRANGEDV2 Rectangular logarithmic bark scale smoothing and downsampling
    idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 17 17 16 15 14 13 12 10 7 4 5 5 6 5 4 3 3 3 2 2];
    bark_freq = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 19000 22500 26000 29500 33000 36500 40000];
    if nargin == 2
        min_freq = freq(1);
        max_freq = freq(end);
    elseif nargin == 3
        max_freq = freq(end);
    end
    if min_freq < 0.01
        min_freq = 0.01; % reasonable minimum value
    end
    if max_freq > 40000
        max_freq = 40000; % more than enough, can change later if need be
    end
    % find band with min_freq in it
    for i = 1:length(bark_freq) 
        if i == 1 
            if bark_freq(i) > min_freq %min_freq in first band
                min_freq_bark_band = i;
                break; % exit loop
            end
        else
            if bark_freq(i) > min_freq
                if bark_freq(i - 1) < min_freq
                    min_freq_bark_band = i; % min_freq in band i
                break;
                end
            end
        end
    end
    
     % find band with max_freq in it
    for i = 1:length(bark_freq)
        if bark_freq(i) > max_freq
            max_freq_bark_band = i;
            break;
        elseif max_freq >= bark_freq(end) % if max_freq exceeds our maximum
            max_freq = bark_freq(end);
            max_freq_bark_band = length(bark_freq);
        end
    end
    bark_freq_ranged = bark_freq(min_freq_bark_band:max_freq_bark_band); % removes unnneeded bands
    idealNoPoints_ranged = idealNoPoints(min_freq_bark_band:max_freq_bark_band);
    bark_freq_ranged(end) = max_freq; % changes cutoff value to max_freq if max_freq < its band cutoff
    
    % find starting index 
    start_freq_indx = find(round(freq) == min_freq, 1);
    
    % if freq not fine-grained enough, find closest val
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
    
    end_freq_indx = zeros(length(bark_freq_ranged), 1); % freq indices closest to bark freq
    for i = 1:length(bark_freq_ranged)
        if i < length(bark_freq_ranged)
            endf = find(round(freq) == bark_freq_ranged(i), 1);
            if isempty(endf)
                endf1 = find(freq > bark_freq_ranged(i), 1);
                endf2 = find(freq < bark_freq_ranged(i), 1);
                if (abs(freq(endf1) - bark_freq_ranged(i)) < abs(freq(endf2) - bark_freq_ranged(i)))
                    endf = endf1;
                else
                    endf = end2;
                end
            end
            end_freq_indx(i) = endf;
        else
            endf = find(round(freq) == max_freq, 1);
            if isempty(endf)
                endf1 = find(freq > max_freq, 1);
                endf2 = find(freq < max_freq, 1);
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
    % get # of indices between samples in each band
    band_spacing = zeros(length(bark_freq_ranged), 1); 
    for i = 1:length(bark_freq_ranged)
        if i == 1 % first band
            band_spacing(i) = round((end_freq_indx(i) - start_freq_indx)/idealNoPoints_ranged(i));
        else
            band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints_ranged(i));
        end
    end
    
    % frequency indices in first band
    % go up to the index before the end index in the 1st band
    freq_indx = start_freq_indx:band_spacing(1):(band_spacing(1)*(idealNoPoints_ranged(1)-1) + start_freq_indx);
    
    % samples in rest of band - start at the end index of the last band
    % use temp variables to ensure horzcat operates correctly
    for n = 2:length(bark_freq_ranged)
        freq_indx_temp = (end_freq_indx(n - 1)):band_spacing(n):(band_spacing(n)*(idealNoPoints_ranged(n) - 1) + end_freq_indx(n - 1));
        freq_indx_temp2 = horzcat(freq_indx, freq_indx_temp); % concatenate 
        if n < length(bark_freq_ranged) % in-between bands
            freq_indx = freq_indx_temp2;
        else % last band
            freq_indx_temp3 = horzcat(freq_indx_temp2, end_freq_indx(n)); % appends max_freq index
            freq_indx = freq_indx_temp3;
        end
    end
    
    % average spacing tells us the range over which we should average for
    % each sample, and depends on the band spacing
    % no averaging on 1st sample (sample at min_freq)
    avg_spacing = zeros(length(freq_indx) - 1, 1); 
    avg_spacing_count = 0;
    for i = 1:length(idealNoPoints_ranged)
        if i == 1 % band 1, start at sample 2 in band 1
            for j = 2:idealNoPoints_ranged(i) % iterate through samples in band
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        else % other bands, start at sample 1
            for j = 1:idealNoPoints_ranged(i)
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        end
    end
    
    % logarithmic means
    log_means = zeros(length(freq_indx), 1);
    log_means(1) = signal(freq_indx(1)); % no averaging
    
    % iterate through indices except for final index
    for n = 2:length(freq_indx)-1
        log_means(n) = 10*log10(sum(10.^(0.1*signal((freq_indx(n) - floor(avg_spacing(n - 1)/2)):(freq_indx(n) + floor(avg_spacing(n - 1)/2)))))/(avg_spacing(n - 1))); % logarithmic mean
    end
    
    % find max_freq average differently - treat as no points past max_freq
    log_means(end) = 10*log10(sum(10.^(0.1*signal((freq_indx(end) - round(band_spacing(end)/2)):(freq_indx(end)))))/(round(band_spacing(end)/2) + 1));
    freq_out = freq(freq_indx);
    
    % this ensures frequencies are in the right order - just in case
    for n = 2:length(freq_out)
        if freq_out(n) <= freq_out(n - 1)
            freq_out(n) = freq_out(n - 1);
            log_means(n) = log_means(n - 1);
        end
    end
    if freq_out(end) > max_freq
        freq_out(end) = max_freq;
    end
end



