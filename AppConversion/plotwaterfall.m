function plotwaterfall(callmode)
%Plots a waterfall to visualise the spectrum of frequencies of a signal as it varies with time

%Uses short-time Fourier transform on an impulse response file
%Left window: Hann window
%Right window: Tukey window (25% Hann)

%{
Settings to add:
- Smoothing (for each slice): 1/48th octav (min, recommended) to 1/3rd octave (max)
- Colour schemes: parula (default),jet,hsv,hot,cool,spring,summer,autumn,winter,gray,bone,copper,pink
%}

setpath;
current = AppConversion;
cd(MEASURES_SWEEP_PATH);

if strcmpi(callmode,'main')
    [file,path] = uigetfile('*.wav','Select a wav file to load');
    audio = strcat(path,file);
    
elseif strcmpi(callmode,'plotfig')
    file = evalin('base','IR_file');
    path = evalin('base','IR_path');
    audio = strcat(path,file);
end

if not (file == 0) 
    [x,fs] = audioread(audio);
    %start_index = min(find(x>1e-3));    % Find index where main IR starts (define start of IR as when value exceeds a certain threshold) - result not as good
    [~,start_index] = max(x);    % Find index where main IR starts (define start of IR using max value)
    x = x(start_index:end,:);   % Only save values from main IR onwards
    disp(start_index);
    fprintf('File successfully loaded.\n');
    
    % Script to set number of slices used for STFT calculation
    prompt = {'Slice duration, in ms: ', 'Time range, in ms: ', 'Left-hand window width, in ms (increase time range if increase this value):', 'Right-hand window width, in ms (increase time range if increase this value):'};
    defans = {'30', '300', '100', '10'};
    options = inputdlg(prompt, 'Waterfall settings', 1, defans);

    if isempty(options) == 1     % if cancelled
       fprintf('Operation cancelled.\n');
       cd(current);
       return;
    end

    slice_duration = str2num(options{1})/1000;  % convert ms to s
    duration = str2num(options{2})/1000;    % convert ms to s
    slices = duration / slice_duration;     % number of slices required
    left_win = str2num(options{3})/1000;    % convert ms to s
    right_win = str2num(options{4})/1000;    % convert ms to s

    if isempty(slice_duration) || isempty(duration) || isempty(left_win) || isempty(right_win)  % if not a number
        fprintf('Invalid selection.\n')
        cd(current);
        return
    elseif slices<0
        fprintf('Selection out of range.\n')
        cd(current);
        return
    end
    
    % Get duration of sweep + silences
    checkIR = audioinfo(audio);
    details = checkIR.Comment;
    nums = regexp(details,'\d*','Match');
    sweep_time = str2num(nums{3});
    silence_time = str2num(nums{5});
    measurement_time = sweep_time + silence_time;
    
    if duration > measurement_time
        fprintf('Selection out of range. Do not exceed sweep + silence time.\n')
        cd(current);
        return
    end
    
    figure;
    for i = 1:size(x,2)
        grid on
        subplot(size(x,2),1,i);
        hann_window = hann(left_win*fs);
        tukey_window = tukeywin(right_win*fs,0.25);
        window = [hann_window(1:end/2); tukey_window(end/2+1:end)];
        noverlap = round(length(window)- duration*fs/(slices)); % calculates overlap depending on number of slices desired
        spectrogram(x(:,i),window,noverlap,[],fs,'yaxis');     %'yaxis' displays frequency on the y-axis and time on the x-axis.
        % freqloc is ignored if spectrogram is called with output arguments
        
        axis tight
        view(80,20)
        xlim([0 duration])
        yticks([1e-2 1e-1 1e0 1e1])     % Spectrogram displays frequency in kHz by default, so manually relabel 10^-2 to 10^1kHz as 10^1 to 10^4Hz
        yticklabels({'10^1','10^2','10^3','10^4'})
        ylabel('Frequency (Hz)')
        zlabel('Magnitude (dB)')
        
        if (size(x,2) == 1)
            title('Waterfall');
        elseif (i == 1)
            title('Waterfall (left channel)');
        elseif (i==2)
            title('Waterfall (right channel)');
        end
        
        set(gca, 'YScale', 'log')
        pbaspect([5 2 1])       %Sets relative lengths of each axis (aspect ratio) - lengthens time axis for clearer visualisation
        rotate3d on
        colorbar off
        
        % Possible UI for waterfall settings on plot itself
        % https://uk.mathworks.com/help/matlab/ref/uicontrol.html
    end
   
   colormap parula
   legend(file,'Location','Best');
   rotate3d on
   Details = irinfo(audio);
   disp(Details)
   
else
   fprintf('Operation cancelled.\n');
end

cd(current);

end
