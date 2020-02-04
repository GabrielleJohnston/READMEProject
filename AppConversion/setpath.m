% This file defines all the required paths and directories for the programme
% --------------------------------------------------------------------------
 
%{
currentdirectory= pwd;
[root_path,~]=fileparts(currentdirectory);
root_path = strcat(root_path,filesep);
%}
%%
currentdirectory= pwd;
[root_path,~]=fileparts(currentdirectory);
root_path = strcat(root_path,filesep);
assignin('base','root_path',root_path);
 
root_path = evalin('base','root_path'); %Read in the current working space which should be created when AS.m was called.
%%
% global AS_CODE;
% AS_CODE = strcat(root_path,'AS_code',filesep);
global AppConversion;
AppConversion = strcat(root_path,'AppConversion',filesep);
 
% AppConversion
 
%Defining directories
% addpath(AS_CODE);
addpath(AppConversion);
 
%Directory containing the "test" files
global TEST_PATH;
% TEST_PATH = strcat(root_path,'AS_code',filesep,'Test_Signals',filesep);
TEST_PATH = strcat(root_path,'AppConversion',filesep,'Test_Signals',filesep);
 
% Directory containing MATLAB script files
global SCRIPTS_PATH;
SCRIPTS_PATH = strcat(root_path,'AppConversion',filesep);
 
%Directory containing "sine sweep" Measurements
global MEASURES_SWEEP_PATH;
MEASURES_SWEEP_PATH = strcat(root_path,filesep,'Measurements',filesep);
 
%Directory containing reference SineSweep
global SWEEP_PATH;
SWEEP_PATH = strcat(root_path,'AppConversion',filesep,'Reference_SineSweep',filesep);
 
%Directory containing equalized reference SineSweep
global SWEEP_EQ_PATH;
SWEEP_EQ_PATH = strcat(root_path,'AppConversion',filesep,'Reference_SineSweepEQ',filesep);
 
%Directory containing the impulse response of the chain of Measurements (will be used in the process of equalization)
global FREEFIELD_PATH;
FREEFIELD_PATH = strcat(root_path,'AppConversion',filesep,'FreeField',filesep);
 
%Directory containing the spatialized impulse response
global LOCATION_PATH;
LOCATION_PATH = strcat(root_path,'AppConversion',filesep,'LocationIR',filesep);
 
%Directory containing the spatialized impulse response
global COLOR_PATH;
COLOR_PATH = strcat(root_path,'AppConversion',filesep,'ColorIR',filesep);
 
%Directory containing the saved audio
global SAVED_PATH;
SAVED_PATH = strcat(root_path,'AppConversion',filesep,'SavedAudio',filesep);
 
%Directory containing the test signals
global TEST_SIGNALS;
TEST_SIGNALS = strcat(root_path,'AppConversion',filesep,'Test_Signals',filesep);
 
%Directory containing impulse responses of different rooms
global RIR_PATH;
RIR_PATH = strcat(root_path,'Measurements',filesep,'RIR',filesep);
 
%Directory containing impulse responses of different rooms (equalized)
global RIREQ_PATH;
RIREQ_PATH = strcat(root_path,'Measurements',filesep,'RIREQ',filesep);
 
%Directory containing recordings
global RECORD_PATH
RECORD_PATH = strcat(root_path,'Measurements',filesep,'RECORDEDfiles',filesep);