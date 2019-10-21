% should convert this into function
% need to start out with period without any signal, just noise - e.g. no speech
% default value = 0.25
% Load in audio
[data, fs] = audioread('OSR_us_000_0010_8k.wav');
info = audioinfo('OSR_us_000_0010_8k.wav');
NoSamples = info.TotalSamples;

% Parameters
alpha = 0.98; % standard value in literature
initialSilence = 0.05;
windowLength = floor(0.025*fs); % 0.025 * sampling frequency (in # of points)
% 0.025 gives time taken in s
overlap = .5; % windows overlap by 50 percent (12.5ms)
noverlap = windowLength*overlap; % number of overlapped samples
shiftPercent = 1 - overlap; % how much the window is shifted by each time
window = hamming(windowLength); % creates hamming window

% calculate spectrogram - computes short-time Fourier transform
[s, w, t] = spectrogram(data, window, noverlap);
absS = abs(s);
% s = spectrogram
% w = vector of normalised frequencies
% t = vector of time instants at which the spectrogram is computed

% we want to find the part of the spectogram where it is only noise
initialSilenceSegments = floor((initialSilence*fs-windowLength)/(shiftPercent*windowLength) + 1);
noisePowerMean = mean(absS(:,1:initialSilenceSegments)')';
noisePowerVariance = mean((absS(:,1:initialSilenceSegments)').^2)';

X = zeros(size(s)); % initialise smoothed signal
gain1 = ones(size(noisePowerMean));
gainNew = gain1;
numberOfFrames = size(s, 2);

NoiseCounter = 0;
NoiseLength = 9; % Smoothing factor for the noise updating

for i=1:numberOfFrames
    % Speech detection and Noise Estimation
    if i<=initialSilenceSegments % If initial silence ignore speech detection
        SpeechFlag = 0;
        NoiseCounter=100;
    else % Else test for speech
        [NoiseFlag, SpeechFlag, NoiseCounter, Dist] = detectSpeech(absS(:,i),noisePowerMean, NoiseCounter); % Speech detection
    end

    if SpeechFlag == 0 % If no speech found
        noisePowerMean = (NoiseLength*noisePowerMean + absS(:,i))/(NoiseLength + 1); % Update and smooth noise mean
        noisePowerVariance = (NoiseLength*noisePowerVariance + (absS(:,i).^2))./(1 + NoiseLength); % Update and smooth noise variance
    end

    % Estimate a priori and a posteriori SNR
    Rpost = (absS(:,i).^2)./noisePowerVariance;
    Rprio = alpha*(gain1.^2).*gain1 + (1-alpha).*max(Rpost - 1, 0);

    % Calculate gain
    gainNew = gainFunc(Rprio, Rpost);

    % Replace NaN values for gainNew 
    Indx = find(isnan(gainNew) | isinf(gainNew)); 
    gainNew(Indx) = Rprio(Indx)./(1+Rprio(Indx)); %Wiener Filter
    
    % Get cleaned value
    X(:,i)=gainNew.*absS(:,i); 
end

% Need to reconstruct signal from spectogram
% Use overlap add technique
NFreq = size(s, 1);
ind = mod((1:windowLength)-1,NFreq)+1;
reconstructedSignal = zeros((numberOfFrames-1)*noverlap + windowLength,1);
p = ceil(log2(windowLength));
NFFT = max(256,2^p);

for indice = 1:numberOfFrames
    leftIndex=((indice-1)*noverlap) ;
    index = leftIndex + [1:windowLength];
    temp_ifft=real(ifft(X(:,indice),NFFT));
    reconstructedSignal(index) = reconstructedSignal(index)+temp_ifft(ind).*window;
end

figure(1)
T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector
tnew = (0:length(reconstructedSignal) - 1)*T;
title('Original Signal')
subplot(2,1,1);
plot(t, data)
subplot(2,1,2);
plot(tnew, reconstructedSignal)
title('Cleaned signal')

audiowrite('clean_OSR_us_000_0010_8k.wav', reconstructedSignal, fs);
% In the case of the signal used, there was too much attenuation