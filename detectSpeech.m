function [NoiseFlag, SpeechFlag, NoiseCounter, Dist] = detectSpeech(signal, noise, NoiseCounter)
specDistThresh = 3; % default spectral distance threshold
permittedNoiseAmount = 8;

% Calculate distances in spectrogram
specDist= 20*(log10(signal)-log10(noise));
specDist(find(specDist<0)) = 0; % replace negatives with 0

Dist = mean(specDist); 
if (Dist < specDistThresh) 
    NoiseFlag = 1; 
    NoiseCounter = NoiseCounter + 1;
else
    NoiseFlag = 0;
    NoiseCounter = 0;
end

% Detect noise only periods   
if (NoiseCounter > permittedNoiseAmount) 
    SpeechFlag = 0;    
else 
    SpeechFlag = 1; 
end 
