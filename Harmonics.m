clear all
close all

%% Opens audio file
file = 'GBS_Project.wav';
[z,zfs]=audioread(file);
unsmooth_faxis =  zfs*(0:length(z)-1)/length(z);
backgroundNoiseFile = z(1:3e5); %In the app this will be a seperate file that will have to be opened with audrioread. Christophe wants to record a signal to use as background noise.
%% Variables to be in the User Interface
num_peaks = 15; %Number of harmonics to remove from the signal, this needs to be specified by the user.
num_peaks_view = 4;%Number of harmonics to view individually
num_peaks_view_noise = 9; %number of harmonics to view as noise
highlight_harmonic = 1; %Variable that determines which harmonic to make bold, if 0 then higlight none

if (num_peaks_view > num_peaks); num_peaks_view = num_peaks; end
if (num_peaks_view_noise > num_peaks); num_peaks_view_noise = num_peaks; end
if (highlight_harmonic > num_peaks); highlight_harmonic = 0; end

%% Remove noise
[noise, noiseless_z] = removeNoise (backgroundNoiseFile, z, zfs, unsmooth_faxis);

%% Find Peaks
ClearSignal=PeakRemover(noiseless_z,zfs,num_peaks); %This is the time domain signal without peaks
ThreeP = AutoPeak(noiseless_z,zfs); %This finds the first three peaks of the first three harmonics (including fundamental)
m=MidFinder(ThreeP,num_peaks);%This finds the midpoint between all the harmonics
m2=round(m(2)*zfs); %Finds the midpoint between the fundamental and the first harmonic in seconds
mend=round(m(end)*zfs); %Finds the last midpoint between harmonics in seconds

%% Filter and plots harmonics

ft_wins_hann = HarmonicFilt(z, zfs, num_peaks, m, unsmooth_faxis);% Function returns all the harmonics that have been windowed

figure;%Plots all the harmonics that is determined by user (num_peaks_view)
for i = 1:num_peaks_view
    if i == highlight_harmonic 
        semilogx(unsmooth_faxis, ft_wins_hann{i},'LineWidth',1.5); %This plots the Emphasised harmonic
    else
       semilogx(unsmooth_faxis, ft_wins_hann{i}); %This plots the rest of the harmonics
    end
    hold on
end

label(1) = "Fundamental"; %Creates a legend for graph
label(2:num_peaks_view) = char("H"+(2:num_peaks_view));

ft_wins_hann_noise = 0; %Plots noise harmonics
if num_peaks_view_noise > num_peaks_view
    for i = num_peaks_view+1:num_peaks_view_noise
        ft_wins_hann_noise = ft_wins_hann_noise + 10.^(ft_wins_hann{i}./20);
    end
end
ft_wins_hann_noise = ft_wins_hann_noise + 10.^(noise./20);
    ft_wins_hann_noise = 20*log10(ft_wins_hann_noise);
    semilogx(unsmooth_faxis, ft_wins_hann_noise,'Color','#808080','LineStyle','--');
    label(num_peaks_view+1) = "Background noise and H"+(num_peaks_view+1)+"-"+(num_peaks_view_noise);

title('Harmonics'); %Edits graph
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
legend(label');
xlim([15 20000]);
grid on;

%% THD
[THD, max_THD, freq_of_max_THD, min_THD, freq_of_min_THD] = calculateTHD(noiseless_z, zfs, ft_wins_hann);
figure;
semilogx(THD);
ylabel("THD (dB)"); xlabel("Frequency (Hz)");
grid on
xlim([15 20000]);
title('Total harmonic distortion');