% Currently hardcoded for input file GBSTest.wav
function Harmonics(callmode)
    %% Opens audio file
    % file = 'IR2005281484044-1.wav';   % New IR recorded by Marcella - doesn't work with
    % algorithm which could be due to noise?
%     file = 'GBSTest.wav';   % Original IR
    setpath;
    current = AppConversion;
    cd(MEASURES_SWEEP_PATH);

    if strcmpi(callmode,'main')
        [file,path] = uigetfile('*.wav','Select a wav file to load');
%         audio = strcat(path,file);

    elseif strcmpi(callmode,'plotfig')
        file = evalin('base','IR_file');
        path = evalin('base','IR_path');
%         audio = strcat(path,file);
    end
    cd(current)
    file = 'GBSTest.wav';
    if not (file == 0) 
        [z,zfs]=audioread(file);
        % z = [zeros(1e5, 1); z; zeros(1e7, 1)];    % padding added to check if
        % works with different length signals
        unsmooth_faxis =  zfs*(0:length(z)-1)/length(z);
        backgroundNoiseFile = z(110000:end); %In the app this will be a seperate file that will have to be opened with audrioread. Christophe wants to record a signal to use as background noise.
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ft_wins_hann_noise = 0; %Plots noise harmonics
        if num_peaks_view_noise > num_peaks_view
            for i = num_peaks_view+1:num_peaks_view_noise
                ft_wins_hann_noise = ft_wins_hann_noise + 10.^(ft_wins_hann{i}./20);
            end
        end
        ft_wins_hann_noise = ft_wins_hann_noise + 10.^(noise./20);
        ft_wins_hann_noise = 20*log10(ft_wins_hann_noise);
        
        %% THD
        [THD, max_THD, freq_of_max_THD, min_THD, freq_of_min_THD] = calculateTHD(noiseless_z, zfs, ft_wins_hann);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        assignin('base','THD',THD);
        assignin('base','ft_wins_hann_noise',ft_wins_hann_noise);
        assignin('base','num_peaks_view',num_peaks_view);
        assignin('base','highlight_harmonic',highlight_harmonic);
        assignin('base','unsmooth_faxis',unsmooth_faxis);
        assignin('base','ft_wins_hann',ft_wins_hann);

        if strcmpi(callmode,'main')
            hold on
            figure(1);%Plots all the harmonics that is determined by user (num_peaks_view)
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
            
            semilogx(THD);
            label(length(label)+1)="THD (dB)";
            
            semilogx(unsmooth_faxis, ft_wins_hann_noise,'LineStyle','--'); %'Color','#808080',
            label(num_peaks_view+1) = "THD";
            
            title(['Harmonics for file ', file]); %Edits graph
            xlabel('Frequency (Hz)');
            ylabel('Amplitude (dB)');
            legend(label');
            xlim([15 40000]);
            grid on;
            hold off
        end

    else
        fprintf('Operation cancelled.\n');
    end
    cd(current)
end
%% IGNORE
% % clear all
% % close all
% 
% %% Opens audio file
% % file = 'IR2005281484044-1.wav';   % New IR recorded by Marcella - doesn't work with
% % algorithm which could be due to noise?
% file = 'GBS_Project.wav';   % Original IR
% % setpath;
% % current = AppConversion;
% % cd(MEASURES_SWEEP_PATH);
% % [file,path] = uigetfile('*.wav','Select a wav file to load');
% % 
% % assignin('base','file',file);
% % file = evalin('base','file');
% % 
% % cd(path);
% 
% [z,zfs]=audioread(file);
% % z = [zeros(1e5, 1); z; zeros(1e7, 1)];    % padding added to check if
% % works with different length signals
% unsmooth_faxis =  zfs*(0:length(z)-1)/length(z);
% backgroundNoiseFile = z(110000:end); %In the app this will be a seperate file that will have to be opened with audrioread. Christophe wants to record a signal to use as background noise.
% %% Variables to be in the User Interface
% num_peaks = 15; %Number of harmonics to remove from the signal, this needs to be specified by the user.
% num_peaks_view = 4;%Number of harmonics to view individually
% num_peaks_view_noise = 9; %number of harmonics to view as noise
% highlight_harmonic = 1; %Variable that determines which harmonic to make bold, if 0 then higlight none
% 
% if (num_peaks_view > num_peaks); num_peaks_view = num_peaks; end
% if (num_peaks_view_noise > num_peaks); num_peaks_view_noise = num_peaks; end
% if (highlight_harmonic > num_peaks); highlight_harmonic = 0; end
% 
% %% Remove noise
% [noise, noiseless_z] = removeNoise (backgroundNoiseFile, z, zfs, unsmooth_faxis);
% 
% %% Find Peaks
% ClearSignal=PeakRemover(noiseless_z,zfs,num_peaks); %This is the time domain signal without peaks
% ThreeP = AutoPeak(noiseless_z,zfs); %This finds the first three peaks of the first three harmonics (including fundamental)
% m=MidFinder(ThreeP,num_peaks);%This finds the midpoint between all the harmonics
% m2=round(m(2)*zfs); %Finds the midpoint between the fundamental and the first harmonic in seconds
% mend=round(m(end)*zfs); %Finds the last midpoint between harmonics in seconds
% 
% %% Filter and plots harmonics
% 
% ft_wins_hann = HarmonicFilt(z, zfs, num_peaks, m, unsmooth_faxis);% Function returns all the harmonics that have been windowed
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;%Plots all the harmonics that is determined by user (num_peaks_view)
% for i = 1:num_peaks_view
%     if i == highlight_harmonic 
%         semilogx(unsmooth_faxis, ft_wins_hann{i},'LineWidth',1.5); %This plots the Emphasised harmonic
%     else
%        semilogx(unsmooth_faxis, ft_wins_hann{i}); %This plots the rest of the harmonics
%     end
%     hold on
% end
% 
% label(1) = "Fundamental"; %Creates a legend for graph
% label(2:num_peaks_view) = char("H"+(2:num_peaks_view));
% 
% ft_wins_hann_noise = 0; %Plots noise harmonics
% if num_peaks_view_noise > num_peaks_view
%     for i = num_peaks_view+1:num_peaks_view_noise
%         ft_wins_hann_noise = ft_wins_hann_noise + 10.^(ft_wins_hann{i}./20);
%     end
% end
% ft_wins_hann_noise = ft_wins_hann_noise + 10.^(noise./20);
% ft_wins_hann_noise = 20*log10(ft_wins_hann_noise);
% semilogx(unsmooth_faxis, ft_wins_hann_noise,'LineStyle','--'); %'Color','#808080',
% label(num_peaks_view+1) = "THD";
% 
% %% THD
% [THD, max_THD, freq_of_max_THD, min_THD, freq_of_min_THD] = calculateTHD(noiseless_z, zfs, ft_wins_hann);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semilogx(THD);
% label(length(label)+1)="THD (dB)";
%     
% title('Harmonics'); %Edits graph
% xlabel('Frequency (Hz)');
% ylabel('Amplitude (dB)');
% legend(label');
% xlim([15 40000]);
% grid on;
% cd(current)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%