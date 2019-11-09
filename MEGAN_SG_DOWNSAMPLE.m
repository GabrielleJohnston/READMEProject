close all
clear all
fclose('all')

filename = 'GBS_Project.wav';
[yIR, FsIR] = audioread(filename);    % Read in the audio file                  
[yfile, FsFile] = audioread('NoisySpeech-16-22p5-mono-5secs.wav');  % Read in the audio file                  
LFile = length(yfile);
LIR = length(yIR);
freqFile = FsFile*(0:LFile-1)/LFile;


n = 1;
Yfile = fft(yfile); % Take the real values of the FT of the signal (in this case impulse response): |H(jw)|
YIR = fft(yIR);





YdIR = downsample(YIR, n);
mag = 20*log10(abs(YdIR));
magFile = 20*log10(abs(Yfile));


freq = [10:(40000-10)/(length(mag)-1):40000];

% upperBandwidths = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 40000];
% frameLength = [100 100 100 100 110 120 140 150 160 190 210 240 280 320 380 450 550 700 900 1100 1300 1800 2500 3500 24500];
filteredIR = sgolayfilt(mag, 2, 3);


% magFilteredIR = 20*log10(abs(filteredIR));  % Magnitude for bode plot is 20*log10(|H(jw)|) dB
% LFIR = length(magFilteredIR);    % Number of sample points in the audio file - number of points on curve           

YnIR = interp(filteredIR,n);
magYnIR = 20*log10(abs(YnIR)); 

dsFreqFilt = FsIR*(0:length(mag) - 1)/length(mag);
freqFilt = FsIR*(0:length(magYnIR) - 1)/length(magYnIR);     % Set scale for x-axis: between 10 and 40kHz - ensure length is same as that of length of signal


ind_B1 = find(dsFreqFilt > 100, 1);
band1 = mag(1:ind_B1 - 1);
n1 = ceil(length(band1)/24);
dsBand1 = downsample(band1, n1);

ind_B2 = find(dsFreqFilt > 200, 1);
band2 = mag(ind_B1:ind_B2 - 1);
n2 = ceil(length(band2)/22);
dsBand2 = downsample(band2, n2);

ind_B3 = find(dsFreqFilt > 300, 1);
band3 = mag(ind_B2:ind_B3 - 1);
n3 = ceil(length(band3)/20);
dsBand3 = downsample(band3, n3);

ind_B4 = find(dsFreqFilt > 400, 1);
band4 = mag(ind_B3:ind_B4 - 1);
n4 = ceil(length(band4)/18);
dsBand4 = downsample(band4, n4);

ind_B5 = find(dsFreqFilt > 510, 1);
band5 = mag(ind_B4:ind_B5 - 1);
n5 = ceil(length(band5)/18);
dsBand5 = downsample(band5, n5);

ind_B6 = find(dsFreqFilt > 630, 1);
band6 = mag(ind_B5:ind_B6 - 1);
n6 = ceil(length(band6)/18);
dsBand6 = downsample(band6, n6);

ind_B7 = find(dsFreqFilt > 770, 1);
band7 = mag(ind_B6:ind_B7 - 1);
n7 = ceil(length(band7)/19);
dsBand7 = downsample(band7, n7);

ind_B8 = find(dsFreqFilt > 920, 1);
band8 = mag(ind_B7:ind_B8 - 1);
n8 = ceil(length(band8)/18);
dsBand8 = downsample(band8, n8);

ind_B9 = find(dsFreqFilt > 1080, 1);
band9 = mag(ind_B8:ind_B9 - 1);
n9 = ceil(length(band9)/17);
dsBand9 = downsample(band9, n9);

ind_B10 = find(dsFreqFilt > 1270, 1);
band10 = mag(ind_B9:ind_B10 - 1);
n10 = ceil(length(band10)/18);
dsBand10 = downsample(band10, n10);

ind_B11 = find(dsFreqFilt > 1480, 1);
band11 = mag(ind_B10:ind_B11 - 1);
n11 = ceil(length(band11)/18);
dsBand11 = downsample(band11, n11);

ind_B12 = find(dsFreqFilt > 1720, 1);
band12 = mag(ind_B11:ind_B12 - 1);
n12 = ceil(length(band12)/17);
dsBand12 = downsample(band12, n12);

ind_B13 = find(dsFreqFilt > 2000, 1);
band13 = mag(ind_B12:ind_B13 - 1);
n13 = ceil(length(band13)/17);
dsBand13 = downsample(band13, n13);

ind_B14 = find(dsFreqFilt > 2320, 1);
band14 = mag(ind_B13:ind_B14 - 1);
n14 = ceil(length(band14)/16);
dsBand14 = downsample(band14, n14);

ind_B15 = find(dsFreqFilt > 2700, 1);
band15 = mag(ind_B14:ind_B15 - 1);
n15 = ceil(length(band15)/15);
dsBand15 = downsample(band15, n15);

ind_B16 = find(dsFreqFilt > 3150, 1);
band16 = mag(ind_B15:ind_B16 - 1);
n16 = ceil(length(band16)/14);
dsBand16 = downsample(band16, n16);

ind_B17 = find(dsFreqFilt > 3700, 1);
band17 = mag(ind_B16:ind_B17 - 1);
n17 = ceil(length(band17)/13);
dsBand17 = downsample(band17, n17);

ind_B18 = find(dsFreqFilt > 4400, 1);
band18 = mag(ind_B17:ind_B18 - 1);
n18 = ceil(length(band18)/12);
dsBand18 = downsample(band18, n18);

ind_B19 = find(dsFreqFilt > 5300, 1);
band19 = mag(ind_B18:ind_B19 - 1);
n19 = ceil(length(band19)/10);
dsBand19 = downsample(band19, n19);

ind_B20 = find(dsFreqFilt > 6400, 1);
band20 = mag(ind_B19:ind_B20 - 1);
n20 = ceil(length(band20)/7);
dsBand20 = downsample(band20, n20);

ind_B21 = find(dsFreqFilt > 7700, 1);
band21 = mag(ind_B20:ind_B21 - 1);
n21 = ceil(length(band21)/4);
dsBand21 = downsample(band21, n21);

ind_B22 = find(dsFreqFilt > 9500, 1);
band22 = mag(ind_B21:ind_B22 - 1);
n22 = ceil(length(band22)/5);
dsBand22 = downsample(band22, n22);

ind_B23 = find(dsFreqFilt > 12000, 1);
band23 = mag(ind_B22:ind_B23 - 1);
n23 = ceil(length(band23)/5);
dsBand23 = downsample(band23, n23);

ind_B24 = find(dsFreqFilt > 15500, 1);
band24 = mag(ind_B23:ind_B24 - 1);
n24 = ceil(length(band24)/6);
dsBand24 = downsample(band24, n24);

band25 = mag(ind_B24:end);
n25 = ceil(length(band25)/6);
dsBand25 = downsample(band25, n25);

downsampledIR = cat(1, dsBand1, dsBand2, dsBand3, dsBand4, dsBand5, dsBand6, dsBand7, dsBand8, dsBand9, dsBand10, dsBand11, dsBand12, dsBand13, dsBand14, dsBand15, dsBand16, dsBand17, dsBand18, dsBand19, dsBand20, dsBand21, dsBand22, dsBand23, dsBand24, dsBand25);
filtDownsampledIR = sgolayfilt(downsampledIR, 3, 125);
% magFiltIR = 20*log10(abs(interp(filtDownsampledIR, round(length(freqFilt)/length(filtDownsampledIR)))));
magFiltIR = 20*log10(abs(interp(downsampledIR, floor(length(freqFilt)/length(downsampledIR)))));
magDownsampledIR = 20*log10(abs(downsampledIR));

freqFilt2 = FsIR*(0:length(magFiltIR) - 1)/length(magFiltIR);



semilogx(freq, mag)
hold on
semilogx(freqFilt2,magFiltIR)
% semilogx(freqFilt3, magDownsampledIR)
% semilogx(freqFilt, magYnIR)     % semilogx plots graph with log scale for x axis 

legend('original', 'downsampled')

title('Magnitude Response')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')

% tidy graph to show precise region 
ylim([-80 40]);   
xlim([10 40000]);




phases = angle(magFiltIR);
mags = 10.^(magFiltIR/20);

y2 = real(ifft(mags.*exp(1j*phases)));
% 
resp=conv(yfile,y2,'full'); %convolve signal with impulse
norm_resp=resp/(max(resp)); %normalise - scale between -1 and 1 
% subplot(5,1,3);
% % time_ax3 = (0:length(norm_resp) - 1)/fs1;
% % plot(time_ax3,norm_resp); % plot normalised convolution of y1 and y2
sound(norm_resp,FsFile); %play 
