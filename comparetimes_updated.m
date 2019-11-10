[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
NoSamples = info.TotalSamples;
[freq, mag] = getmag(data, fs, NoSamples);

tsmooth = fastsmooth(mag, 25);
sgolaysmooth = sgolayfilt(mag, 9, 25);

N = 10;
elapsedTimeT = zeros(N, 1);
elapsedTimeSG = zeros(N, 1);

for n = 1:N
    tic;
    tsmooth = fastsmooth(mag, 25);
    elapsedTimeT(n) = toc;
    tic;
    sgolaysmooth = sgolayfilt(mag, 9, 25);
    elapsedTimeSG(n) = toc;
end
elapsedTimeTAvg = mean(elapsedTimeT);
elapsedTimeSGAvg = mean(elapsedTimeSG);

%% With erb downsampling
N = 10;
elapsedTimeERBDown = zeros(N, 1);
elapsedTimeSGERB = zeros(N, 1);
elapsedTimeTERB = zeros(N, 1);

for i = 1:N
    tic;
    erb = hz2erb(freq);
    no_bands = round(erb(end));
    sample_indx = zeros(no_bands, 1);
    for n = 1:no_bands-1
        sample_indx(n) = find(round(erb) == n, 1);
    end
    sample_indx(end) = length(erb);

    % In the smallest band can tell about 1 Hz apart - for safety do 0.5 Hz
    % Use same number of samples in each band
    samplesPerBand = round(freq(sample_indx(1)) - freq(1))*2;
    band_spacing = zeros(no_bands, 1);
    freq_range = zeros(no_bands, 1);
    for n = 1:no_bands
        if n == 1
            freq_range(n) = sample_indx(n) - 1;
        else
            freq_range(n) = sample_indx(n) - sample_indx(n - 1);
        end
        band_spacing(n) = round(freq_range(n)/samplesPerBand);
    end

    new_freq = erb_space(freq, no_bands, samplesPerBand, band_spacing, sample_indx);
    new_mag = erb_space(mag', no_bands, samplesPerBand, band_spacing, sample_indx);
    elapsedTimeERBDown(i) = toc;
    tic; 
    sgolaysmootherb = sgolayfilt(new_mag, 9, 25);
    elapsedTimeSGERB(i) = toc;
    tic; 
    tsmootherb = fastsmooth(new_mag, 25);
    elapsedTimeTERB(i) = toc;
end
elapsedTimeERBDownAvg = mean(elapsedTimeERBDown);
elapsedTimeSGERBAvg = mean(elapsedTimeSGERB);
elapsedTimeTERBAvg = mean(elapsedTimeTERB);
%% With bark downsampling
N = 10;
elapsedTimeBarkDown = zeros(N, 1);
elapsedTimeSGBark = zeros(N, 1);
elapsedTimeTBark = zeros(N, 1);

for n = 1:N
    tic;
    barkScale = hz2bark(freq);
    barkScaleBands = 25; % 24 + 1 for rest of band
    start_freq_indx = find(round(barkScale) == 0, 1);
    end_freq_indx = zeros(barkScaleBands, 1);
    for i = 1:barkScaleBands-1
        end_freq_indx(i) = find(round(barkScale) == i, 1);
    end

    end_freq_indx(barkScaleBands) = find(round(freq) == 48000, 1);

    % extra 6 for rest of band
    idealNoPoints = [24 22 20 18 18 18 19 18 17 18 18 17 17 16 15 14 13 12 10 7 4 5 5 6 6];

    band_spacing = zeros(barkScaleBands, 1);
    for i = 1:barkScaleBands
        if i == 1
            band_spacing(i) = round((end_freq_indx(i) - start_freq_indx)/idealNoPoints(i));
        else
            band_spacing(i) = round((end_freq_indx(i) - end_freq_indx(i - 1))/idealNoPoints(i));
        end
    end

    new_freq = bark_space(freq, barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
    new_mag = bark_space(mag', barkScaleBands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing);
 
    elapsedTimeBarkDown(n) = toc;
    tic; 
    sgolaysmoothbark = sgolayfilt(new_mag, 9, 25);
    elapsedTimeSGBark(n) = toc;
    tic; 
    tsmoothbark = fastsmooth(new_mag, 25);
    elapsedTimeTBark(n) = toc;
end
elapsedTimeBarkDownAvg = mean(elapsedTimeBarkDown);
elapsedTimeSGBarkAvg = mean(elapsedTimeSGBark);
elapsedTimeTBarkAvg = mean(elapsedTimeTBark);