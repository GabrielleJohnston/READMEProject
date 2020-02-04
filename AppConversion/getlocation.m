function varargout = getlocation(varargin)
% GETLOCATION MATLAB code for getlocation.fig
%      GETLOCATION, by itself, creates a new GETLOCATION or raises the existing
%      singleton*.
%
%      H = GETLOCATION returns the handle to a new GETLOCATION or the handle to
%      the existing singleton*.
%
%      GETLOCATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETLOCATION.M with the given input arguments.
%
%      GETLOCATION('Property','Value',...) creates a new GETLOCATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before getlocation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to getlocation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help getlocation

% Last Modified by GUIDE v2.5 29-Jul-2016 17:17:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @getlocation_OpeningFcn, ...
                   'gui_OutputFcn',  @getlocation_OutputFcn, ...
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


% --- Executes just before getlocation is made visible.
function getlocation_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for getlocation
handles.output = hObject;
ele = evalin('base','elevation');
ang = evalin('base','angle');
elevation = sprintf('Elevation Angle: %.f°',ele);
set(handles.Elevationtext,'string',elevation);
set(handles.slider1,'value',ele);
angle = sprintf('Azimuth Angle: %.f°',ang);
set(handles.Angletext,'string',angle);
set(handles.slider2,'value',ang);
handles.ele = ele;
handles.ang = ang;
sh2 = plotsphere(ele,ang,0);
handles.sh2 = sh2;
% Update handles structure
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
ele = get(handles.slider1,'value');
ele = round(ele/15)*15;
elevation = sprintf('Elevation Angle: %.f°',ele);
set(handles.Elevationtext,'string',elevation);
handles.ele = ele;
sh2 = handles.sh2;
sh2 = plotsphere(ele,handles.ang,1,sh2);
handles.sh2 = sh2;
guidata(hObject, handles);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
ang = get(handles.slider2,'value');
ang = round(ang/15)*15;
angle = sprintf('Azimuth Angle: %.f°',ang);
set(handles.Angletext,'string',angle);
handles.ang = ang;
sh2 = handles.sh2;
sh2 = plotsphere(handles.ele,ang,1,sh2);
handles.sh2 = sh2;
guidata(hObject, handles);

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
ele = handles.ele;
assignin('base','elevation',ele);
ang = handles.ang;
assignin('base','angle',ang);
guidata(hObject, handles);
close(handles.figure1);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = getlocation_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



