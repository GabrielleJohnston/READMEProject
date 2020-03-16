function plotspectlogf_modified(x, fs, f1, f2, smoothing, n)
% This function plots the spectrum: magnitude and phase
% -----------------------------------------------------
% plotspectlogf_modified(x, fs, f1, f2, n)
%
% Modified from the original script from Bill Gardner
% Copyright 1995 MIT Media Lab. All rights reserved.
%

 if (nargin < 6)
    n = max(size(x));
   n = 2*2^nextpow2(n);
 end

if (nargin < 5)
   f2 = 10000;
end

if (nargin < 4)
   f1 = 100;
end

if (nargin < 3)
   fs = 44100;   
end

fx = fft(x,n);
assignin('base','fx',fx);
longfreq = ceil(n/2);
freq = (0 : longfreq) * fs / n;

figure('Position', [100 100 900 600]);

for i = 1:size(x,2)     %size(x,2) gets number of columns (2nd dimension). Either 1 or 2 depending on mono/stereo
   subplot(3,size(x,2),i); % subplot_1
   db = mag2db(abs(fx(1:(ceil(n/2) + 1), i)));
   semilogx(freq, db);
   %magnitude = db2mag(db);
   %assignin('base','magnitude',magnitude);
   % determines the graph window(low frequency - high frequency - low level in dB - high level in dB).
   grid;
   if (size(x,2) == 1)
      title('Frequency Response');
   elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
      title('RTF Left Channel');
   else
      title('RTF Right Channel');
   end
   xlabel('Frequency, Hz');
   ylabel('Amplitude, dB'); 
   xlim([f1 f2+(0.1*f2)]); 
   bits = evalin ('base','audiobit');
   annotation('textbox',[.9 .5 .1 .2],'String',sprintf('Audio bit depth: %d',bits),'EdgeColor','none')
   
   subplot(3,size(x,2),i+2*size(x,2)); % subplot_3, or 5 & 6
   myphase = unwrap(angle(fx(1:(ceil(n/2) + 1), i)));
   %assignin('base','myphase',myphase);
   % Calculation of group delay using the formula 1000*absolute value((absolute value(expressed in degrees of phase of the previous sample) - absolute value(expressed in degrees of phase of the sample))/(360*(frequency in Hz of the sample-frequency in Hz the previous sample)))
   myphase_1 = myphase(1:length(myphase)-1,1);
   myphase_2 = myphase(2:length(myphase),1);
   group_delay = 1000*(abs(abs(myphase_1)-abs(myphase_2)))/(360*(fs/n)); % 1000 is the factor used since we express the delay in ms
   group_delay = [group_delay(1); group_delay];
   %assignin('base','group_delay',group_delay)
   semilogx(freq,group_delay); % Scale logarithmic phase and logarithmic scale pulse
   grid;
   title('Group Delay');
   xlabel('Frequency, Hz');
   ylabel('ms');
   xlim([f1 f2+(0.1*f2)]); 
 
   
   % The phase curve is then rectified at best (depending on the values taken) horizontally for easier reading.
   subplot(3,size(x,2),i+size(x,2)); %subplot_2, or 3 & 4
   freqinit = f1;
   freqfinal = f2;
   limitinit = ceil(freqinit*n/fs);
   limitfinal = ceil(freqfinal*n/fs);
   [coefpoly, ~] = polyfit(freq(limitinit:limitfinal),myphase(limitinit:limitfinal)',1);
   myphase = -(coefpoly(1)*freq') - coefpoly(2) + myphase; 
   % lowering of the phase curve
   % to eliminate its slope and as close as possible to the horizontal axis
   myphase = myphase*180/pi;
   semilogx(freq,myphase); %logarithmic phase scale and logarithmic pulsations scale
   %assignin('base','myphase2',myphase);
   grid;
   title('Phase Response');
   ylabel('Phase, Degrees');
   xlabel('Frequency, Hz');
   xlim([f1 f2+(0.1*f2)]);
   ylim([-1000 1000]);
   zoom on;
  
   
 
end

%Plot impulse response button
IR_button = uicontrol('Style', 'pushbutton', 'String', 'Plot Impulse Response');
IR_button.Position = [5 5 150 25];
IR_button.String = 'Plot Impulse Response';
IR_button.Callback = @IR_Callback;

    function IR_Callback(src,event);
        wavprint('plotfig');
    end


%Plot distortion data button
distortion_button = uicontrol;
distortion_button.String = 'Plot Distortion Data';
distortion_button.Position = [157 5 150 25];
distortion_button.Callback = @distortion_Callback;

    function distortion_Callback(src,event)
        plotdist('plotfig');
    end

%Plot waterfall button
waterfall_button = uicontrol('Style', 'pushbutton', 'String', 'Plot Waterfall');
waterfall_button.Position = [307 5 150 25];
waterfall_button.Callback = @waterfall_Callback;

    function waterfall_Callback(src,event);
        plotwaterfall('plotfig');
    end

%Plot RT60 button
RT60_button = uicontrol('Style', 'pushbutton', 'String', 'Plot RT60');
RT60_button.Position = [457 5 150 25];
RT60_button.Callback = @RT60_Callback;
 
    function RT60_Callback(src,event);
        RT60('plotfig');
    end
 
%Plot A-weighting button
A_weighting_button = uicontrol('Style', 'pushbutton', 'String', 'A-weighting');
A_weighting_button.Position = [607 5 150 25];
A_weighting_button.Callback = @A_weighting_Callback;
 
    function A_weighting_Callback(src,event);
        plot_a_weight('plotfig');
    end

%Close button
close_button = uicontrol('Style','pushbutton','String','Close');
close_button.Position = [757 5 100 25];
close_button.Callback = @close_Callback;

    function close_Callback(src, event) ;
        close;
        AS;
    end


[m,lim1] = min(abs(freq-100));
[m,lim2] = min(abs(freq-1000));
[m,lim3] = min(abs(freq-50));
[m,lim4] = min(abs(freq-200));

figure(3);

%If there is no smoothing
if(smoothing == 0)
    semilogx(freq, db);
    xlim([f1 f2+(0.1*f2)]);
    ylim([-100 50]);
    if (size(x,2) == 1)
          title('Frequency Response');
    elseif (i == 1)
          title('RTF Left Channel');
    else
          title('RTF Right Channel');
    end
    xlabel('Frequency, Hz');
    ylabel('Amplitude, dB'); 
elseif(smoothing == 1) %Base 2 1/3 Octave Smooth
    [k2, fcenter2] = OctaveSmooth(db, freq, 2);
    semilogx(fcenter2,k2);
    xlim([f1 f2+(0.1*f2)*0.50]);
    ylim([-100 50]);
    xlabel('Frequency, Hz');
    ylabel('Amplitude, dB');
    title('Base 2 1/3 Octave Smoothing');
elseif(smoothing == 2) %Base 10 1/3 Octave Smooth
    [k10, fcenter10] = OctaveSmooth(db, freq, 10);
    semilogx(fcenter10,k10);
    xlim([f1 f2+(0.1*f2)*0.50]);
    ylim([-100 50]);
    xlabel('Frequency, Hz');
    ylabel('Amplitude, dB');
    title('Base 10 1/3 Octave Smoothing');
else %Bark Smoothing
    [mag_bark, freq_bark] = rlogbark_short(freq, db);
    semilogx(freq_bark, mag_bark);
    xlim([f1 f2+(0.1*f2)*0.50]);
    ylim([-100 50]);
    xlabel('Frequency, Hz');
    ylabel('Amplitude, dB');
    title('Bark Smoothing');
end

figure(2)
subplot(3,1,1);
[mag_bark, freq_bark] = rlogbark_short(freq, db);
semilogx(freq, db, 'Color',[0.7,0.7,0.7])
hold on
semilogx(freq_bark, mag_bark, 'Color','k')
title('Frequency Response');
xlim([f1 f2+(0.1*f2)*0.50]);
ylim([-100 50]);

[phase_bark, freq_bark] = rgeobark_short(freq, myphase);
subplot(3, 1, 2)
semilogx(freq, myphase, 'Color',[0.7,0.7,0.7])
hold on
semilogx(freq_bark, phase_bark, 'Color','k')
title('Phase Response');
ylabel('Phase, Degrees');
xlabel('Frequency, Hz');
xlim([f1 f2+(0.1*f2)*0.50]);

[group_delay_bark, freq_bark] = rgeobark_short(freq, group_delay);
subplot(3, 1, 3)
semilogx(freq, group_delay, 'Color',[0.7,0.7,0.7])
hold on
semilogx(freq_bark, group_delay_bark, 'Color','k')
title('Group Delay');
xlabel('Frequency, Hz');
ylabel('ms');
xlim([f1 f2+(0.1*f2)]); 
 
end

