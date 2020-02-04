function varargout = Transform(varargin)
% TRANSFORM MATLAB code for Transform.fig
%      TRANSFORM, by itself, creates a new TRANSFORM or raises the existing
%      singleton*.
%
%      H = TRANSFORM returns the handle to a new TRANSFORM or the handle to
%      the existing singleton*.
%
%      TRANSFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRANSFORM.M with the given input arguments.
%
%      TRANSFORM('Property','Value',...) creates a new TRANSFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Transform_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Transform_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Transform

% Last Modified by GUIDE v2.5 08-Aug-2016 17:09:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Transform_OpeningFcn, ...
                   'gui_OutputFcn',  @Transform_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Transform is made visible.
function Transform_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Transform
handles.output = hObject;
handles.ele = 0;
handles.ang = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Transform wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Transform_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function audio_Callback(hObject, eventdata, handles)
guidata(hObject,handles);

% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
setpath;
current = pwd;
cd(TEST_SIGNALS);
[file_1, path_1] = uigetfile('*','Select the sound or music to be transformed');
cd(current);
set(handles.audio,'String',strcat(path_1,file_1));
guidata(hObject,handles);

function colorfile_Callback(hObject, eventdata, handles)
guidata(hObject,handles);


% --- Executes on button press in browse2.
function browse2_Callback(hObject, eventdata, handles)
setpath;
current = pwd;
cd(COLOR_PATH);
[file_2, path_2] = uigetfile('*','Select the Impulse Response for the room');
cd(current);
set(handles.colorfile,'String',strcat(path_2,file_2));
guidata(hObject,handles);


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
clear sound;
path1 = get(handles.audio,'String');
[y_1,Fs_1] = audioread(path1);
sound(y_1,Fs_1);


% --- Executes on button press in stop1.
function stop_Callback(hObject, eventdata, handles)
clear sound;

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
clear sound;
close(handles.figure1);
AS;

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
y_out = handles.y_out;
fs = handles.Fs_1;
setpath;
current = pwd;
cd(SAVED_PATH);
[file,path] = uiputfile('*.wav;*.flac;*.m4a;*.mp4;*.ogg','Save transformed audio');
audiowrite(strcat(path,file),y_out,fs);
cd(current);
h = msgbox('Transformed audio Saved','Success');


% --- Executes on button press in location.
function location_Callback(hObject, eventdata, handles)
h = getlocation;
uiwait(h);
set(handles.anglebox,'value',1);
ele = evalin('base','elevation');
ang = evalin('base','angle');
text = sprintf('Elevation Angle: %.f°\nAzimuth Angle: %.f°',ele,ang);
set(handles.Angletext,'string',text);
handles.ele = ele;
handles.ang = ang;
guidata(hObject,handles);


% --- Executes on button press in colorbox.
function colorbox_Callback(hObject, eventdata, handles)
guidata(hObject,handles);

% --- Executes on button press in anglebox.
function anglebox_Callback(hObject, eventdata, handles)
guidata(hObject,handles);

% --- Executes on button press in transformbutton.
function transformbutton_Callback(hObject, eventdata, handles)
clear sound;
path1 = get(handles.audio,'String');
[y_1,Fs_1] = audioread(path1); %original audio;
handles.Fs_1 = Fs_1;
if min(size(y_1)) == 2
    k = 2;
else
    k =1;
end
convoluted = 0;

if get(handles.anglebox,'Value') == 1
    ele = handles.ele;
    ang = handles.ang;
    [leftir,rightir] = givelocationwav(ele,ang);
    y_left = audioread(leftir);
    y_right = audioread(rightir);
    Conv_result = [convlin(y_1(:,1),y_left(:,1),' (location - left)') convlin(y_1(:,k),y_right(:,1),' (location - right)')];
    convoluted = 1;
end

if get(handles.colorbox,'Value') == 1
    path2 = get(handles.colorfile,'String');
    y_2 = audioread(path2); %coloring IR
    
    if min(size(y_2)) == 2
    m = 2;
    else
    m = 1;
    end
    
    if convoluted == 1
        k = 2;
    else
        Conv_result = y_1;
    end
    
    Conv_result = [convlin(Conv_result(:,1),y_2(:,1),' (scenery - left)') convlin(Conv_result(:,k),y_2(:,m),' (scenery - right)')];
    convoluted = 1;
end

if convoluted ~= 1
    h = msgbox('No convolution operation was selected','error');
    return
end

Conv_result = trimmatch(Conv_result);
maximum = max(Conv_result);
Conv_result_normalised(:,1) = 0.95*(Conv_result(:,1)/maximum(1));
Conv_result_normalised(:,2) = 0.95*(Conv_result(:,2)/maximum(2));

handles.y_out = Conv_result_normalised;
guidata(hObject,handles);
sound(Conv_result_normalised,Fs_1)
