function [geo_means, freq_out] = rgeobark(freq, signal)
    idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 17 17 16 15 14 13 12 10 7 4 5 5 6 6];
    barkScaleBands = 25; % 24 + 1 for 15500 to 48000 Hz
    bark_freq = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 48000];
    start_freq_indx = 1; % freq = 0
    end_freq_indx = zeros(barkScaleBands, 1); % freq indexes closest to bark freq
    for i = 1:barkScaleBands
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
    end
    band_spacing = zeros(barkScaleBands, 1); % # of indices between samples in each band
    for i = 1:barkScaleBands
        if i == 1
            band_spacing(i) = round((end_freq_indx(i) - start_freq_indx)/idealNoPoints(i));
        else
            band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints(i));
        end
    end
    freq_indx = start_freq_indx:band_spacing(1):(band_spacing(1)*(idealNoPoints(1)-1) + start_freq_indx);
    for n = 2:barkScaleBands
        freq_indx_temp = (end_freq_indx(n - 1)):band_spacing(n):(band_spacing(n)*(idealNoPoints(n) - 1) + end_freq_indx(n - 1));
        freq_indx_temp2 = horzcat(freq_indx, freq_indx_temp); % concantenate
        if n < barkScaleBands
            freq_indx = freq_indx_temp2;
        else
            freq_indx_temp3 = horzcat(freq_indx_temp2, end_freq_indx(n)); % appends 48000 Hz index
            freq_indx = freq_indx_temp3;
        end
    end
    avg_spacing = zeros(length(freq_indx) - 1, 1); % avg spacing between samples, used for avging, no avging on 1st sample

    avg_spacing_count = 0;
    for i = 1:length(idealNoPoints)
        if i == 1
            for j = 2:idealNoPoints(i)
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        else
            for j = 1:idealNoPoints(i)
                avg_spacing_count = avg_spacing_count + 1;
                avg_spacing(avg_spacing_count) = band_spacing(i);
            end
        end
    end
    geo_means = zeros(length(freq_indx), 1);
    geo_means(1) = signal(freq_indx(1));
    for n = 2:length(freq_indx)-1
        geo_means(n) = mean(signal((freq_indx(n) - floor(avg_spacing(n - 1)/2)):(freq_indx(n) + floor(avg_spacing(n - 1)/2)))); % geometric mean
    end
    % replace 48000 Hz avg with avg over smaller range
    geo_means(end) = mean(signal((freq_indx(end) - 1000):(freq_indx(end) + 1000)));
    freq_out = freq(freq_indx);
    for n = 2:length(freq_out)
        if freq_out(n) <= freq_out(n - 1)
            freq_out(n) = freq_out(n - 1);
            geo_means(n) = geo_means(n - 1);
        end
    end
end