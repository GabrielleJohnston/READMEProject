function metric = AmpAQM(measuredSignalinWav, measuredSignalinMat, bits, app_db, freq)
    %Before equalization - 16 bits
    %After equalization - 32 bits
    %If the measured signal is in a .wav format, leave measuredSignalMat as
    %0. If the measured signal is in a .mat format, leave
    %measuredSignalinWav as 0.

    %Extracting the tolerance tube from the toleranceTube.mat file
    upperTol = load('toleranceTube.mat', 'upperTol');
    upperTol = upperTol.upperTol;
    lowerTol = load('toleranceTube.mat', 'lowerTol');
    lowerTol = lowerTol.lowerTol;
    freqUp = load('toleranceTube.mat', 'freqUp');
    freqUp = freqUp.freqUp;
    freqLow = load('toleranceTube.mat', 'freqLow');
    freqLow = freqLow.freqLow;
    
    %% Plotting the tolerance tube for reference - can comment out
%     figure()
%     hold on
%     plot(freqUp, upperTol)
%     plot(freqLow, lowerTol)
%     yline(0)
%     hold off
%     set(gca, 'XScale', 'log')
%     xlabel('Frequency (Hz)')
%     ylabel('Amplitude (dB)')
%     legend('Upper tolerance values', 'Lower tolerance values', 'Desired signal')
%     grid on
%     title('Tolerance tube for the amplitude metric')
    %% ~~Not Needed for App~~
    % Audioreading the measured signal
%     if measuredSignalinWav ~= 0
%     if ~strcmp(measuredSignalinWav,0)
%         [y, fs] = audioread(measuredSignalinWav);
%         L = length(y);
%         time_ax = [0:L-1]./fs;
%         Nfft = 2^nextpow2(length(y));
%         ydft = fft(y);
%         amp = 20*log10(abs(ydft)); % amp is the fft of original signal
%         f = fs*((0:length(y)-1)/length(y));
%         if length(amp)<400
%             %The code below extends the frequency vector so that it can be used
%             %in the interpolation function
%             fNew = [];
%             fNew = [fNew f(1)];
%             numPoints = 2000;
%             for i = 2:length(f) 
%                fBandLength = f(i) - f(i-1);
%                diff = fBandLength/numPoints; %There should be 10 points between each band
%                fNewTemp = f(i-1);
%                for j = 1:numPoints
%                    fNewTemp = fNewTemp + diff;
%                    fNew = [fNew fNewTemp];
%                end
%             end
%             amp = interp1(f, amp, fNew); %This interpolates the amplitude vector
%             f = fNew;
%         end       
%     else
%         load(measuredSignalinMat);
%         time = newA(:,1);
%         y = newA(:,2);
%         L = length(y);
%         fs = 44100;
%         time_ax = [0:L-1]./fs;
%         Nfft = 2^nextpow2(length(y));
%         ydft = fft(y, Nfft);
%         amp = 20*log10(abs(ydft)); % amp is the fft of original signal
%         f = fs*((0:Nfft-1)/Nfft);
%         if length(amp)<400
%             %The code below extends the frequency vector so that it can be used
%             %in the interpolation function to extend the amplitude vector
%             fNew = [];
%             fNew = [fNew f(1)];
%             numPoints = 2000;
%             for i = 2:length(f) 
%                fBandLength = f(i) - f(i-1);
%                diff = fBandLength/numPoints; %There should be 10 points between each band
%                fNewTemp = f(i-1);
%                for j = 1:numPoints
%                    fNewTemp = fNewTemp + diff;
%                    fNew = [fNew fNewTemp];
%                end
%             end
%             amp = interp1(f, amp, fNew); %This interpolates the amplitude vector
%             f = fNew;
%         end
%     end
    amp = app_db;
    f = freq;
    

    %% Preparing the measured signal and tolerance tube for the metric in the human hearing range
    %Using the rectangular smooth with the bark scale to match the
    %frequency and measured signals vectors with the human ear sensitivity
    [ampHu fHu] = rlogbarkranged(f, amp, 20, 16000);

    %These are the frequencies within the human hearing range and their upper
    %and lower tolerance values
    huFreq = freqUp(find(freqUp>19 & freqUp<21):find(freqUp>15999 & freqUp<16001));
    huUpTol = upperTol(find(freqUp>19 & freqUp<21):find(freqUp>15999 & freqUp<16001));
    huLowTol = lowerTol(find(freqLow>19 & freqLow<21):find(freqLow>15999 & freqLow<16001));

    %% Calculating the energy average of the response using the logarithmic average

    avgEnergyLevel = 10*log10(sum(10.^(0.1*ampHu))/length(fHu));
    
    AmpHuAdj = (ampHu - avgEnergyLevel)';
     %Plot of the measured and desired signal, along with the tolerance tube
%     figure()
%     hold on
%     plot(f, amp) %Measured signal that has been stripped off certain indices
%     plot(fHu, AmpHuAdj') %Measured signal that has been stripped off certain indices and adjusted with its power
%     yline(0) %Desired signal
%     plot(freqUp, upperTol) %Upper tolerance level
%     plot(freqLow, lowerTol) %Lower tolerance level
%     hold off
%     title("Plot of the measured smoothed signal before and after average level adjustment")
%     xlabel("Frequency (Hz)")
%     ylabel("Amplitude (dB)")
%     legend("Measured IR - smoothed", "Measured IR - smoothed and adjusted", "Desired IR", "Upper tolerance level", "Lower tolerance level")
%     set(gca, 'XScale', 'log')
%     grid on
%     xlim([20 16000])
    
    %The code below searches for the frequency indices in huFreq where
    %the corresponding value is equal to the value in fHuRound. Those
    %indices are then stored in the index position in fHuRound of the
    %value...
    fHuRound = round(fHu);
    [~, strippedFreq] = ismember(fHuRound,huFreq);
     %The below two lines of code work for the unsmoothed version
%     strippedFreq = strippedFreq(2:171); %This is to get the freq in the human hearing range
%     AmpHuAdj = AmpHuAdj(2:171);
    %% Finding the cost per dB for the cases when the measured signal is either above or below the desired signal
    costUpTol = 3./abs(huUpTol(strippedFreq));
    costDownTol = 3./abs(huLowTol(strippedFreq));
    limit = bits*6;
    costUp = 7./(limit-abs(huUpTol(strippedFreq)));
    costDown = 7./(limit-abs(huLowTol(strippedFreq)));
    
    %% The amplitude metric calculation
    metricArray = zeros(size(AmpHuAdj));
    measuredUpTolInd = find(AmpHuAdj >= 0 & AmpHuAdj <= huUpTol(strippedFreq));
    measuredUpInd = find(AmpHuAdj > huUpTol(strippedFreq));
    measuredDownTolInd = find(AmpHuAdj  < 0 & AmpHuAdj >= huLowTol(strippedFreq));
    measuredDownInd = find(AmpHuAdj < huLowTol(strippedFreq));
    
    %Populate the metric vector with the amplitude metric values for each
    %bark frequency in the smoothed curve
    if AmpHuAdj <= -96 | AmpHuAdj >= 96
        metricArray = 0;
    else
        metricArray(measuredUpTolInd) = 10 - (abs(AmpHuAdj(measuredUpTolInd)).*costUpTol(measuredUpTolInd));
        metricArray(measuredDownTolInd) = 10 - (abs(AmpHuAdj(measuredDownTolInd)).*costDownTol(measuredDownTolInd));
        metricArray(measuredUpInd) = 7 - (abs(AmpHuAdj(measuredUpInd)).*costUp(measuredUpInd));
        metricArray(measuredDownInd) = 7 - (abs(AmpHuAdj(measuredDownInd)).*costDown(measuredDownInd));
    end
    metric = mean(metricArray, 'all');
%     string = strcat('The Amplitude AQM for the inputted signal is: ',num2str(metric),'/10')

    %% Assign values to base workspace for App usage'
    
    assignin('base','amp_metric_freqUp',freqUp);
    assignin('base','amp_metric_freqLow',freqLow);
    assignin('base', 'upperTol', upperTol);
    assignin('base', 'lowerTol', lowerTol);
end