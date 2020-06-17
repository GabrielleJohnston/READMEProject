% function metric = AmpAQM_v2(measuredSignalinWav, measuredSignalinMat,app_db,freq)
function metric = AmpAQM_v2(app_db,freq)  
    %If the measured signal is in a .wav format, leave measuredSignalMat as
    %0. 
    %If the measured signal is in a .mat format, leave measuredSignalinWav 
    %as 0.

    %Extracting the tolerance tube from the toleranceTube.mat file
    upperTol = load('toleranceTube.mat', 'upperTol');
    upperTol = upperTol.upperTol;
    lowerTol = load('toleranceTube.mat', 'lowerTol');
    lowerTol = lowerTol.lowerTol;
    freqUp = load('toleranceTube.mat', 'freqUp');
    freqUp = freqUp.freqUp;
    freqLow = load('toleranceTube.mat', 'freqLow');
    freqLow = freqLow.freqLow;
    upperLimit = upperTol + 20;
    lowerLimit = lowerTol - 70;
% %     %Plotting the tolerance tube for reference - can comment out
%     figure
%     hold on 
%     X1 = [freqLow, fliplr(freqLow)];
%     X2 = [freqUp, fliplr(freqUp)];
%     inBetween1 = [lowerTol, fliplr(zeros(1,length(lowerTol)))];
%     inBetween2 = [zeros(1,length(upperTol)), fliplr(upperTol)];
%     fill(X1,inBetween1,'g','FaceAlpha',0.05,'LineStyle','none','HandleVisibility','off');
%     fill(X2,inBetween2,'g','FaceAlpha',0.05,'LineStyle','none','HandleVisibility','off');
%     plot(freqUp, upperTol, 'b')
%     plot(freqLow, lowerTol, 'r')
%     yline(0)
%     plot(freqUp, upperLimit, 'k')
%     plot(freqLow, lowerLimit, 'm')
%     hold off
%     set(gca, 'XScale', 'log')
%     xlabel('Frequency (Hz)')
%     ylabel('Amplitude (dB)')
%     legend('Upper tolerance values', 'Lower tolerance values', 'Desired signal', 'Upper limit', 'Lower limit','Location','SouthWest')
%     grid on
%     title('Tolerance tube and upper/lower limits for the amplitude metric')
%     xlim([20 16000])
    %% Audioreading the measured signal
%     if measuredSignalinWav ~= 0
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

    %% Preparing the measured signal and tolerance tube for the metric in the human hearing, high fidelity and high resolution
    %Using the rectangular smooth with the bark scale to match the
    %frequency and measured signals vectors with the human ear sensitivity
    
    %These are the smoothed frequency and amplitude values. The smoothing
    %has been doing using the rectangular smooth with bark scale
    [ampR fR] = rlogbarkrangedv2(f, amp, 20, 16000);
    
    %These are the frequencies within the human hearing range and their upper
    %and lower tolerance values. Note: freqUp, upperTol and lowerTol have
    %been loaded from the .mat file specifying the tolerance tube
    huFreq = freqUp(find(freqUp>19 & freqUp<21):find(freqUp>15999 & freqUp<16001));
    huUpTol = upperTol(find(freqUp>19 & freqUp<21):find(freqUp>15999 & freqUp<16001));
    huLowTol = lowerTol(find(freqLow>19 & freqLow<21):find(freqLow>15999 & freqLow<16001));
    %% Calculating the energy average of the response using the logarithmic average

    avgEnergyLevel = 10*log10(sum(10.^(0.1*ampR))/length(fR));
    
    AmpHuAdj = (ampR - avgEnergyLevel)';
%      %Plot of the measured and desired signal, along with the tolerance tube
%     figure
%     hold on
%     plot(fR, ampR', 'b') %Measured signal that has been stripped off certain indices
%     plot(fR, AmpHuAdj', 'x') %Measured signal that has been stripped off certain indices and adjusted with its power
%     yline(0) %Desired signal
%     plot(freqUp, upperTol, 'g') %Upper tolerance level
%     plot(freqLow, lowerTol, 'k') %Lower tolerance level
%     hold off
%     title("Plot of the smoothed, pre-equalized IR before and after average level adjustment")
%     xlabel("Frequency (Hz)")
%     ylabel("Amplitude (dB)")
%     legend("Measured IR - smoothed","Measured IR - smoothed and adjusted", "Desired IR", "Upper tolerance level", "Lower tolerance level")
%     set(gca, 'XScale', 'log')
%     grid on
%     xlim([20 16000])
%     ylim([-70 20])

    fHuRound = round(fR); % These are the frequency 
    %values of the signal in human hearing range
    
    [~, strippedFreq] = ismember(fHuRound,huFreq);
    TU = huUpTol(strippedFreq); %Upper Tolerance Levels
    TL = huLowTol(strippedFreq); %Lower Tolerance Levels
    %% Metric calculation
    metricArray = zeros(size(AmpHuAdj));
    
    indInTol = find(AmpHuAdj <= TU & AmpHuAdj >= TL); %Indices of signal points within the tolerance tube
    indPos = find(AmpHuAdj > TU); %Indices of signal points greater than the upper tolerance level
    indNeg = find (AmpHuAdj < TL); %Indices of signal points smaller than the lower tolerance level
    
     %Below are the corresponding tolerance tube values for each point outside the tolerance tuve. If a
    %signal is positive, its corresponding tolerance tube value is the
    %upper tolerance level. Vice versa for negative
    tolUpIndVal = TU(indPos);
    tolLowIndVal = TL(indNeg);
    
    metricArray(indInTol) = 10; %All signal points within tolerance tube has a perfect score of 10
    metricArray(indPos) = 10 - ( 10*( 1 - exp(-0.12 * (AmpHuAdj(indPos)- tolUpIndVal ) ) ) );
    metricArray(indNeg) = 10 - ( 10*( 1 - exp(-0.05 * (abs(AmpHuAdj(indNeg))- abs(tolLowIndVal)) ) ) );  
    
    metric = mean(metricArray, 'all')
    
    string = strcat('The Amplitude AQM for the inputted signal is: ',num2str(metric),'/10')
end