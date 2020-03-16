function GDmetric = GDAQM(measuredSignalinWav, measuredSignalinMat, bits)
    %Before equalization - 16 bits
    %After equalization - 32 bits
    %If the measured signal is in a .wav format, leave measuredSignalMat as
    %0. If the measured signal is in a .mat format, leave
    %measuredSignalinWav as 0.

    %Extracting the tolerance tube from the toleranceTube.mat file
    %Blauert curve data
    blauert = load('Blauert');
    blauert_freq = blauert.xnew;
    blauert_max_gd = blauert.ynew;

    % Adjustments so metric is calculated from 20 to 16000Hz only
    % The human ear sensitivity

    % Blauert curve
    min_idx = find(blauert_freq > 20,1);
    max_idx = find(blauert_freq > 16000,1);

    new_freq = blauert_freq(min_idx:max_idx);
    blauert_max_gd = blauert_max_gd(min_idx:max_idx);
    
    %% Measured signal
    if measuredSignalinWav ~= 0
        [y, fs] = audioread(measuredSignalinWav);
        L = length(y);
        time_ax = [0:L-1]./fs;
        Nfft = 2^nextpow2(length(y));
        ydft = fft(y);
        amp = 20*log10(abs(ydft)); % amp is the fft of original signal
        f = fs*((0:length(y)-1)/length(y));
        if length(amp)<400
            %The code below extends the frequency vector so that it can be used
            %in the interpolation function
            fNew = [];
            fNew = [fNew f(1)];
            numPoints = 2000;
            for i = 2:length(f) 
               fBandLength = f(i) - f(i-1);
               diff = fBandLength/numPoints; %There should be 10 points between each band
               fNewTemp = f(i-1);
               for j = 1:numPoints
                   fNewTemp = fNewTemp + diff;
                   fNew = [fNew fNewTemp];
               end
            end
            amp = interp1(f, amp, fNew); %This interpolates the amplitude vector
            f = fNew;
        end       
    else
        load(measuredSignalinMat);
        time = newA(:,1);
        y = newA(:,2);
        L = length(y);
        fs = 44100;
        time_ax = [0:L-1]./fs;
        Nfft = 2^nextpow2(length(y));
        ydft = fft(y, Nfft);
        amp = 20*log10(abs(ydft)); % amp is the fft of original signal
        f = fs*((0:Nfft-1)/Nfft);
        if length(amp)<400
            %The code below extends the frequency vector so that it can be used
            %in the interpolation function to extend the amplitude vector
            fNew = [];
            fNew = [fNew f(1)];
            numPoints = 2000;
            for i = 2:length(f) 
               fBandLength = f(i) - f(i-1);
               diff = fBandLength/numPoints; %There should be 10 points between each band
               fNewTemp = f(i-1);
               for j = 1:numPoints
                   fNewTemp = fNewTemp + diff;
                   fNew = [fNew fNewTemp];
               end
            end
            amp = interp1(f, amp, fNew); %This interpolates the amplitude vector
            f = fNew;
        end
    end
    

    %% Bark smoothing the measured signal in the human hearing range
    %Using the rectangular smooth with the bark scale to match the
    %frequency and measured signals vectors with the human ear sensitivity
    [ampHu fHu] = rlogbarkranged(f, amp, 20, 16000);
    
    %% Creating upper and lower limits
    N = length(ampHu);

    lower_limit = zeros(1,N); % 0ms
    upper_limit = lower_limit + 80; % 80ms

    % Area between the upper and lower limit = 80ms * N points, fixed
    Area_80_0 = trapz(fHu, upper_limit);

    % Area between the Blauert curve and lower limit, fixed
    Area_Blauert_0 = trapz(new_freq, blauert_max_gd);

    % Area between measured and 0ms
    Area_M_0 = abs(trapz(fHu, ampHu));

    %% Use Piecewise linear functions to calculate the metric

    % Step 1: initialise x (area) and y (rating)
    x = [0 Area_Blauert_0 Area_80_0];
    func = zeros(size(x));

    % Step 2: selective processing
    % For rating between 10 and 7
    for x=1:round(Area_Blauert_0)
        func(x) = (7-10)*x/(Area_Blauert_0)+10;
    end
    % For rating between 7 and 0
    for x=round(Area_Blauert_0):round(Area_80_0)
        func(x) = -0.000005438800*x+7.17; 
    end

    %% Calculating the rating
    gd_metric = func(round(Area_M_0));
    disp(['The group delay metric is out of 10.']);
    disp(['The maximum is 10/10 for a group delay of 0ms.']);
    disp(['The minimum is 0/10 for a group delay of 80ms.']);
    disp(['The Blauert curve corresponds to 7/10.']);
    disp(['For the given measured data, the group delay metric is ', num2str(gd_metric),'/10.'])

    %% Visualization - Plotting the GD AQM function
    areas = [0 Area_Blauert_0 Area_80_0];
    ratings=[10 7 0];

    figure(1)
    hold on
    %From the theoretical hardcoded values
    plot(areas, ratings, 'DisplayName', 'Theoretical piecewise functions')
    xline(175370, 'DisplayName', 'Example of a measured Area');
    %example of a measured Area. The intersect is the rating

    %From the picewise linear functions
    plot(func,'-r', 'DisplayName', 'Experimental piecewise functions')

    ylim([0 10])
    grid on
    title('Rating vs Area (AU)')
    xlabel('Area (AU)')
    ylabel('Resulting metric (AU)')
    legend('show')

    %% Plotting the GD curves

    figure(2)
    hold on
    plot(fHu, ampHu)
    plot(fHu,upper_limit)
    plot(fHu,lower_limit)
    plot(new_freq, blauert_max_gd)
    legend('Measured signal','80ms','0ms','Blauert Curve', 'location', 'best')
    set(gca, 'XScale', 'log')
    ylim([-40 90]);
    xlim([20 16000]);
    % Set axis label
    xlabel('Frequency (Hz)')
    ylabel('Group Delay (ms)')
    title('Group Delay Curves')
    grid minor
end