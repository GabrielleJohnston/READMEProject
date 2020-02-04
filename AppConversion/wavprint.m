function wavprint(callmode)
% This file lets you choose a '.wav' file then plots it for you!
% --------------------------------------------------------------

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
   y = audioread(audio);
   fprintf('File successfully loaded.\n');
   plottime(y);
   legend(file,'Location','Best');
   Details = irinfo(audio)          %Output not suppressed, so prints checkIR.comment
   
else
   fprintf('Operation cancelled.\n');
end

cd(current);

