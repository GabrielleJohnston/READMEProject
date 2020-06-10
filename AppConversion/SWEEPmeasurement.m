function SWEEPmeasurement(name, f1, f2, time, number, silence, mode, fs, verbose, preequal, lin, smoothing)
% This function is the main function that calls on all other functions.
% ---------------------------------------------------------------------
% SWEEPmeasurement(name [,f1] [,f2] [,time] [,number] [,silence] [,mode] [,fs] [,verbose] [, preequal] [,lin])
% 
% name     is part of the file name that will be created to contain the measurements.
%          This file will automatically be placed in the 'measurespath/current_date/'
%
% f1      is the initial frequency of the frequency sweep: default = 10 Hz
%
% f2      is the final frequency of the frequency sweep: default = 22000 Hz
%
% time   is the duration of sweep that is desired: default = 1 sec
% 
% number  is the number of averaging that is desired: default = 1
%
% silence is the duration in sec of periods of silences (0 amplitude signal) that are inserted at the end of the sinesweeps: default = 1 sec
%
% mode    specifies the type of measurement ("0" for mono-right; "1" for mono-left; "2" for stereo) that is desired: default = 0
%
% fs      specifies the sampling frequency: default = 44100
%
% verbose allows the display of dialogs (= 1) or not (= 0): default = 0
%
% preequal specifies whether the signal being sent is a preequalized signal (= 1) or not (= 0): default = 0
%
% lin specifies whether this is a linear (= 1) or logarithmic (= 0) "sweep": default = 0
% 
% smoothing specifies what smoothing technique to use ("0": None, "1": Base 2 1/3 Octave smoothing, "2": Base 10 1/3 Octave smoothing, "3": Bark smoothing)
%
%clc;
setpath;
current = AppConversion;
tic;

if(nargin < 11)
   lin = 0;
end;

if (nargin < 10)
   preequal = 0;
end

if (nargin < 9)
   verbose = 0;
end

if (nargin < 8)
   fs = 44100;
end

if (nargin < 7)
   mode = 0;
end

if (nargin < 6)
   silence = 1;
end

if (nargin < 5)
   number = 1;
end

if(nargin < 4)
   time = 1;
end

if(nargin < 3)
   f2 = 22000;
end

if(nargin < 2)
   f1 = 10;
end

if (mode == 0)
   mORs = 'mono-right';
elseif (mode == 1)
    mORs = 'mono-left';
elseif (mode == 2)
   mORs = 'stereo';
else
   errordlg('The specified recording mode is incorrect');
   return;
end

if (preequal == 1)
   eq = 'Yes';
elseif (preequal == 0)
   eq = 'No';
else
   errordlg('The specified equalization mode is incorrect');
   return;
end

if (lin == 0)
   genre = 'log';
elseif (lin == 1)
   genre = 'lin';
else
   errordlg('The specified sweep type is incorrect');
   return;
end


fprintf('Measurement of the impulse response by the "exponential sine sweep" method\n');
fprintf('==========================================================================\n\n');
fprintf('Sinesweep type: %s\nInitial frequency: %dHz\nFinal frequency: %dHz\nSignal duration: %gs\nNumber of "sweep": %d\nDuration of zones of silence: %gs\nMeasurement carried out in: %s\nFrequency of sampling: %dHz\n\n',...
   genre,f1,f2,time,number,silence,mORs,fs);

%Creation of a new directory with today's date
%---------------------------------------------
% cd(MEASURES_SWEEP_PATH);
newpath = strcat(date);
if exist(newpath, 'dir')

else
   mkdir(newpath);
end
cd(newpath);

% Generation of "number" sweeps followed by periods of silence of duration "silence" and generation of the inverse filter
% Taking multiple averages of the measured output signal before IR deconvolution improves signal-to-noise ratio
%------------------------------------------------------------------------------------------------------------------------
tol1 = 0.5; % tolerance setting compared to the initial pulse omega1
tol2 = 0.1; % 
% ATTENTION: tol1 and tol2 are also defined in sinlog.m

fprintf('\nYou asked a sinesweep measurement from %dHz to %dHz.\n',f1,f2);
fprintf('\nWARNING: The sinesweep generated will actually go from %dHz to %dHz.\n',f1-(tol1*f1),f2+(tol2*f2));

if (preequal == 1)
   if not(exist(sprintf('%s%s-EQ%d-%d-%d-%d-%d-%d-%d.',SWEEP_EQ_PATH,genre,f1,f2,time,number,silence,fs,mode),'file'))
       % Only generate the SineSweep file using sinlog if does not yet exist
       % Originally %sss%sEQ%d-%d_%f_%d_%d_%d.wav - error
   	RegWindowParams; % Creating an interface to set the value of the arguments 'lowfreqReg', 'highfreqReg', 'lowTB', 'highTB' which are used by sinlog
   	sinlog(f1,f2,time,number,silence,mode,fs,preequal,lin,lowfreqReg,highfreqReg,lowTB,highTB);
   end
   s = sprintf('%s%s-EQ%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_EQ_PATH,genre,f1,f2,time,number,silence,fs,mode);
else
   if not(exist(sprintf('%s%s%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_PATH,genre,f1,f2,time,number,silence,fs,mode),'file'))
      sinlog(f1,f2,time,number,silence,mode,fs,preequal,lin);
   end
   s = sprintf('%s%s%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_PATH,genre,f1,f2,time,number,silence,fs,mode);
end

measure = acquisition(s, 2, fs);
% s is the SineSweep file generated by sinlog
% Mode is 2 first, then get rid of data from 1 channel if don't need - because can't specify which channel to use for recording
% The acquisition is always performed as stereo, monaural. measure is a vector that contains the signal resulting from the sum of
% the input channels L and R from the sound card. The residual noise entering the sound card input channel 
% then disturbs the measurement performed. So make sure to use the correct channel (here the right channel)

if (mode == 0)      % Original code mixed up channels: left channel should be on column 1 and right on 2
   measure = measure(:,2); % The right channel should be used in mono-right
elseif (mode == 1)
   measure = measure(:,1); % The left channel is used in mono-left
end

% Averaging "number" measures. where "number" is number of avging desired
%--------------------------------

AvgResponse = AvgSWEEP(measure, time, number, silence, fs, preequal);


%Obtaining the impulse response
%------------------------------
file1=sprintf('%sRev%d-%d-%d-%d.wav',genre, f1, f2, time,fs);   %Inverse filter file generated by sinlog

[y_1,~] = audioread(strcat(SWEEP_PATH, file1));

%The impulse response deconvolution process is realised by linear convolution (convlin)
%of the measured output with the analytical inverse filter preprocessed from the excitation signal
IR = convlin(AvgResponse(:,1),y_1);

if (mode == 2)
   RI_R = convlin(AvgResponse(:,2), y_1);
   IR = [IR RI_R];
end

IR = 0.95*IR/max(max(abs(IR)));

c = fix(clock);
c(1') = c(1) - 2000; 
fs1 = round(fs/1000);

if c(2) < 10
    output_file = sprintf('%s%d%02d%d%d%d%d%d-%d.wav',name,c(1'),c(2),c(3),c(4),c(5),c(6),fs1,number);
else
    output_file = sprintf('%s%d%d%d%d%d%d%d-%d.wav',name,c(1'),c(2),c(3),c(4),c(5),c(6),fs1,number); 
end

details = sprintf('\nFile Name:\t\t\t %s\nLin or Log:\t\t %s\nPre-Equalization:\t\t %s\nChannel Mode:\t\t %s\nInitial Frequency:\t\t %.f\nFinal Frequency:\t\t %.f\nLength of Sweep:\t\t %g\nNumber of Average:\t\t %d\nLength of Silence:\t\t %g\nDate and Time:\t\t %s\n',name,genre, eq, mORs, f1, f2, time, number, silence,datetime);
audiowrite(output_file,IR,fs,'Comment',details);
%Saves IR with output_file as file name

assignin ('base','IR_path',strcat(MEASURES_SWEEP_PATH,newpath,filesep));
assignin ('base','IR_file',output_file);

info = audioinfo(output_file);
audiobit = info.BitsPerSample; 
assignin ('base','audiobit',audiobit);


if (verbose ~= 0)
   s = sprintf('Impulse response calculated successfully. You''ll find it under the name %s%d%d%d%d%d%d%d%d%d-%d.wav.\n\nTime elapsed: %f seconds.',name,c(1'),c(2'),c(3),c(4),c(5),c(6),fs1,audiobit,number, toc); 
   Data=1:64; Data=(Data'*Data)/64;
   msgbox (s, 'Information', 'custom', Data, hot(64));
end

% plotspectlogf_modified(IR,fs,f1,f2, smoothing, mORs);
plotspectlogf_modified(IR,fs,f1,f2, mORs);
% legend(sprintf('%s-%dh-%dm',name,c(4),c(5)),'Location','Best');
zoom on;



cd(current);