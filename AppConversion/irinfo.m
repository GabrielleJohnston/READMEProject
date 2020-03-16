function Details = irinfo( audio )
%Details = irinfo( [audio] )
%
%This function takes in the impulse response in the form of audio file
%(audio) and returns the setting details of the sweep performed(Details) to
%obtain that specific impulse response.
%Details include: 
% 1 - File Name
% 2 - Linear or Logarithmic sweep
% 3 - Was the sweep pre-equalized
% 4 - Was it mono or stereo mode
% 5 - Initial Frequency of sweep
% 6 - Final Frequency of sweep
% 7 - Number of Averages
% 8 - Length of Silence between sweep
% 9 - Date and time of obtaining the impulse response
%If no audio was input was provided, it will ask for the user to select the
%specific audio file for the impulse response.
if nargin == 0              %if run this on its own
    [file_1, path_1] = uigetfile('*','Select the impulse response for details in obtaining');
    select = strcat(path_1, file_1);
else                        %if this getes called from wavprint.m
    select = audio;
end
checkIR = audioinfo(select);
Details = checkIR.Comment;
end

%Whether just run on own or called from wavprint.m, will display Details
%(function return)
