function Harmonics_app()
% This function asks for user to select which harmonic they wish to visualiza
% plots it with the Magnitude Response plot
% -----------------------------------------------------
% Harmonics_app(s)
% s is the recorded signal
%% Opens audio file
%IRwav is the recorded IR file
% setpath;
% current = AppConversion;
% file = evalin('base','IR_file');
% path = evalin('base','IR_path');
% cd(path);
% 
% audio_in = strcat(path,file);
% flipped = flip(audio_in);
% token = strtok(flipped,'\');
% wav = flip(token);
% [z,zfs]=audioread(wav);
% assignin('base', 'z', z);
% assignin('base', 'zfs', zfs);
% 
% cd(current);

z = load('IR_stereo.mat', 'IR_stereo');
z = z.IR_stereo;
assignin('base','z',z)
zfs = load('IR_stereo.mat', 'b');
zfs = zfs.b;
assignin('base','zfs',zfs)
% [z,zfs]=audioread('IR.wav');
unsmooth_faxis =  zfs*(0:length(z)-1)/length(z);
assignin('base','unsmooth_faxis',unsmooth_faxis);
backgroundNoiseFile = z(1:3e5); %In the app this will be a seperate file that will have to be opened with audrioread. Christophe wants to record a signal to use as background noise.
%% Variables to be in the User Interface
num_peaks = 15; %Number of harmonics to remove from the signal, this needs to be specified by the user.
num_peaks_view = 4;%Number of harmonics to view individually
num_peaks_view_noise = 9; %number of harmonics to view as noise
highlight_harmonic = 1; %Variable that determines which harmonic to make bold, if 0 then higlight none

if (num_peaks_view > num_peaks); num_peaks_view = num_peaks; end
if (num_peaks_view_noise > num_peaks); num_peaks_view_noise = num_peaks; end
if (highlight_harmonic > num_peaks); highlight_harmonic = 0; end
size(z)
for i=1:size(z,2)
    %% Remove noise
    [noise, noiseless_z] = removeNoise (backgroundNoiseFile, z(:,i), zfs, unsmooth_faxis);

    %% Find Peaks
    ClearSignal=PeakRemover(noiseless_z,zfs,num_peaks); %This is the time domain signal without peaks

    ThreeP = AutoPeak(noiseless_z,zfs); %This finds the first three peaks of the first three harmonics (including fundamental)

    m=MidFinder(ThreeP,num_peaks);%This finds the midpoint between all the harmonics
 
    m2=round(m(2)*zfs); %Finds the midpoint between the fundamental and the first harmonic in seconds
 
    mend=round(m(end)*zfs); %Finds the last midpoint between harmonics in seconds

    %% Filter and plots harmonics

    ft_wins_hann = HarmonicFilt(z(:,i), zfs, num_peaks, m, unsmooth_faxis);% Function returns all the harmonics that have been windowed

    ft_wins_hann_noise = 0; %Plots noise harmonics
    if num_peaks_view_noise > num_peaks_view
        for j = num_peaks_view+1:num_peaks_view_noise
            ft_wins_hann_noise = ft_wins_hann_noise + 10.^(ft_wins_hann{j}./20);
        end
    end
    ft_wins_hann_noise = ft_wins_hann_noise + 10.^(noise./20);
        ft_wins_hann_noise = 20*log10(ft_wins_hann_noise);
    

    %% THD
    [THD, max_THD, freq_of_max_THD, min_THD, freq_of_min_THD] = calculateTHD(noiseless_z, zfs, ft_wins_hann);
%%

    if i==1
        assignin('base','ft_wins_hann1',ft_wins_hann);
        assignin('base','ft_wins_hann_noise1',ft_wins_hann_noise);
        assignin('base','THD1',THD);
    else
        assignin('base','ft_wins_hann2',ft_wins_hann);
        assignin('base','ft_wins_hann_noise2',ft_wins_hann_noise);
        assignin('base','THD2',THD);
    end
    assignin('base','unsmooth_faxis',unsmooth_faxis);
end
return;