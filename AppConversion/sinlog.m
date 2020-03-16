function sinlog(f1,f2,time,number,silence,mode,fs,preequal,lin,lowfreqReg,highfreqReg,lowTB,highTB)
% This function generates the excitation "SineSweep" signal and its inverse filter
% for later use
% --------------------------------------------------------------------------------

%sinlog([f1] [, f2] [, time] [, number] [, silence] [, fs] [, preequal] [, lin] [, lowfreqReq] [, highfreqReg] [, lowTB] [, highTB])
    

%Note: the arguments 'lowfreqReg' and 'highfreqReg' define useful preequalisation variables.
%Both arguments are meaningless if preequalisation is unchecked.

setpath;

%should this be highTB, and next one lowTB?
if(nargin < 13)
   lowTB = 40;
end;

if (nargin < 12)
   highTB = 40;
end

if(nargin < 11)
   highfreqReg = 20000;  
end;

if (nargin < 10)
   lowfreqReg = 20;
end


if (preequal == 1)
   currentdir = pwd;
   cd(FREEFIELD_PATH);  %goes to FreeField folder for user to select a file, then reads this file
   [preeqfile,path] = uigetfile('*','Select a file to load for pre-equalisation');
   IRchain = audioread(strcat(path,preeqfile));
   lengthirchain = length(IRchain);
   fprintf('Length of the preequalization impulse response: %d samples', lengthirchain);
   cd(currentdir);
end;


%Applying an amplitude scaling factor at the ends to avoid the inclusion of sudden transitions in the measurement chain
%---------------------------------------------------------------------------------------------------------------------------------------------------------
omega1=2*pi*f1; %omega1: initial radian frequency of sweep
omega2=2*pi*f2; %omega2: final radian frequency of sweep
tol1 = 0.5; % tolerance setting compared to the initial pulse omega1
tol2 = 0.1; % 
% ATTENTION: tol1 and tol2 are defined in SWEEPmeasurement.m

omega1 = omega1-(tol1*omega1);
omega2 = omega2+(tol2*omega2);


%Generating a sinesweep whose frequency varies exponentially (lin == 0) or linearly (lin == 1) with time
%----------------------------------------------------------------------------------------------------------------------------------

fprintf('\nSinesweep generation in progress. Please wait.\n\n');
h = waitbar(0,'Generation of sinesweep');

nbEch = time*fs;
t=[0:nbEch]./fs;    %these 2 lines convert time into a vector from 0:time, to represent each point in time

if (lin == 0)

% see the 'Comparison...' paper for equation:
K1 = log(omega2/omega1);
K2 = (omega1*time)/K1;
K3=K1/time;

sineSw=0.95*sin(K2*(exp(K3*t)-1)); %normalisation to 95% 1
                                   %time (T) is sweep duration, t is each point in time

waitbar(0.10);

elseif (lin == 1)
   sineSw=0.95*sin(omega1*t + (omega2-omega1)/(time*2)*(t.^2)); %normalisation to 95% 2
end;


%Applying an amplitude scaling factor at the ends to avoid the inclusion of sudden transitions in the measurement chain 
%To minimise the influence of the transients introduced by the measurement system at the begining and the end of the emission 
%of the excitation signal, the ends of the SineSweep signal are exponentially attenuated
%(exponential growth at the begining and exponential decrease at the end).
%---------------------------------------------------------------------------------------------------------------------------------------------------------
AmpStartTime=(log(1+tol1)/log(omega2/omega1))*time; %0.032 0.05
nbEchAmpStart=ceil(AmpStartTime*fs);

dureeAmpEnd=(1-(1+(log(1-tol2)/log(omega2/omega1))))*time; % 0.02 0.002 ATTENTION (40/f2) < 1 => f2 > 40Hz
nbEchAmpEnd=ceil(dureeAmpEnd*fs);


K4 = nbEchAmpStart/pi;
for i=1:nbEchAmpStart
   sineSw(i)=(0.5*sin(((i-1)/K4)-(pi/2))+0.5)*sineSw(i);    %Apply the amplitude scaling factor to each point in the SineSweep wave
end

waitbar(0.20);

K5 = nbEchAmpEnd/pi;
for i=((nbEch+1)-nbEchAmpEnd):(nbEch+1)
   sineSw(i)=(0.5*sin(((nbEch-i)/K5)-(pi/2))+0.5)*sineSw(i);
end

waitbar(0.30);

resFreq = 2^nextpow2(nbEch+1);          %This is required for fft(), because the FFT algorithm requires that the sequence length be a power of 2.
sineSwf = fft(sineSw, resFreq);
waitbar(0.40);


%Implementation of the "time mirror filter" (inverse filter)
%-----------------------------------------------------------

sineSwRev = fliplr(sineSw);


%Correction of the curve's amplitude at frequencies (6dB/octave) for the logarithmc sweep
%----------------------------------------------------------------------------------------
%Don't quite get what's going on here

if (lin == 0)

sf    = fft(sineSwRev, resFreq);

boost1 = [1:resFreq/2];  %line of slope 1 (corresponding to doubling the amplitude whenever the frequency doubles)
boost2 = [(resFreq/2)+1:-1:2]; %According to the frequency representation of MATLAB , this step is necessary to
%get a real time signal (because its frequency spectrum is symmetrical)

boost  = [boost1 boost2];

sf1 = sf .* boost;

waitbar(0.50);

sf2 = sf1 .* sineSwf; %Horizontal amplitude (ATTENTION: this curve
%is well beyond 0dB => introducing a correction factor called "correc" in what follows)

waitbar(0.60);

lengsf2 = length(sf2);
correc = max(abs( sf2(ceil(0.15*lengsf2):ceil(0.2*lengsf2)) )); %necessary step to normalize
%everything and thus obtain a curve whose amplitude fluctuates slightly around 0 dB
sf2 = sf2 ./ correc; %Ideal signal "deconvolved" in frequency

waitbar(0.70);

sf1 = sf1 ./ correc; %Inverse filter deconvolved in the frequency domain

waitbar(0.80);

end;

% =========================================
% Added: Preequalization of Sweep frequency 
% =========================================

if (preequal == 1)
   
   ir_rev = flipud(IRchain);

	IRchainf = fft(ir_rev.',resFreq); % ATTENTION, Normally for a linear convolution 
	%lconvlin = 2^nextpow2(length(signal)+length(ir)-1)
   %However here because ir_rev is very short (~200 samples) and x*44100 is never close 
   %to a power of 2 -> it's fine that way
   
   sineSwf = sineSwf .* IRchainf ./ (abs(IRchainf).^2);
   
   %Regularisation
   %--------------
   
   M1=round(4/(highTB/fs)); % before M1=round(6/(4000/fs))
   
   if (mod(M1,2) ~= 0)
      M1=M1+1;
   end;
   
   lowpass = WSlowpass(highfreqReg, M1);  %(before M1 was equal to 70 assuming fs = 44100)
                                        % done to meet Nyquist criteria (fmax <= fs/2) to prevent aliasing
	lowpassf = fft(lowpass.', resFreq);
      
   M2=round(4/(lowTB/fs)); % before M2=round(6/(45/fs))
   
   if (mod(M2,2) ~= 0)
      M2=M2+1;
   end;
   
   highpass = WSlowpass(lowfreqReg, M2);
      
   highpassf = fft(highpass.',resFreq);
   highpassf = abs(highpassf);
   highpassf = 1-highpassf;
   
   filtref = abs(lowpassf) .* highpassf;
   
   sineSwf = sineSwf .* filtref;
   
   sineSwf = sineSwf./filtref(floor(resFreq/4));
   
   sineSw = real(ifft(sineSwf));
   sineSw = 0.95*(sineSw/(max(max(abs(sineSw))))); %ATTENTION, before sineSw(1:nbEch+1)   % normalisation to 95% 3
   
end;

% ==============
% Final addition 
% ==============


%Signal generation with the desired number of repetitions of the sweep (required for averaging)
%----------------------------------------------------------------------------------------------

if(lin == 0)
sineSwRev = real(ifft(sf1));
sineSwRev = 0.95*sineSwRev(1:nbEch+1)/max(sineSwRev); % The 0.95 factor is necessary to avoid "clipping" the data when writing to the .WAV file
%normalisation to 95% 4
end;

sineSw2 = [sineSw, zeros(1,silence*fs)]; %addition at the end of a number of zeros corresponding to a duration of "silence" seconds
exit = zeros(1, floor(fs/2));

for i=1:number
   exit = [exit, sineSw2];
end


if mode==1
    exit = [exit;zeros(1,length(exit))]';    % If mono-left, fill right channel with 0s
elseif mode==0
    exit = [zeros(1,length(exit));exit]';    % If mono-right, fill left channel with 0s
elseif mode==2
    exit = [exit;exit]'; % If stereo, same sweep on both channels
end

waitbar(0.90);

if (preequal == 1) && (lin == 1)
   s = sprintf('%slin-EQ%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_EQ_PATH,f1,f2,time,number,silence,fs,mode);
elseif (preequal == 0) && (lin == 1)
   s = sprintf('%slin%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_PATH,f1,f2,time,number,silence,fs,mode);
elseif (preequal == 1) && (lin == 0)
   s = sprintf('%slog-EQ%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_EQ_PATH,f1,f2,time,number,silence,fs,mode);
elseif (preequal == 0) && (lin == 0)
   s = sprintf('%slog%d-%d-%d-%d-%d-%d-%d.wav',SWEEP_PATH,f1,f2,time,number,silence,fs,mode);
end;

audiowrite(s, exit, fs);        % generate the SineSweep file

if (lin == 1)
   r = sprintf('%slinRev%d-%d-%d-%d.wav',SWEEP_PATH,f1,f2,time,fs);
elseif (lin == 0)
   r = sprintf('%slogRev%d-%d-%d-%d.wav',SWEEP_PATH,f1,f2,time,fs);
end;


audiowrite(r, sineSwRev, fs);    % generate the inverse filter file, only saved in non-preeq folder unlike SineSweep file
                                % on testing python version: for lin=1, preequal=0, read(r) differs slightly from sineSwRev at (1:3) and (end-2:end)
                                
waitbar(1);
close(h);

fprintf('Generation of the sinesweep and its inverse filter performed successfully! :)\n\n') ;

%*********
%*REMARKS*
%*********

%REMARK 1
%--------

%Contrary to what one might think, the three-step generation (see below)
%takes longer than the generation I use.

%K6=AmpStartTime/log(2);
%tStart=[0:nbEchAmpStart]./fs;
%sineStart = (exp(tStart/K6)-1).*sin(K2*(exp(K3*tStart)-1));

%tMid=[nbEchAmpStart+1:nbEch-nbEchAmpEnd-1]./fs;
%sineMid = sin(K2*(exp(K3*tMid)-1));

%K7=-AmpStartTime/log(2);
%tEnd=[nbEch-nbEchAmpEnd:nbEch]./fs;
%sineEnd = (exp((tEnd-duree)/K7)-1).*sin(K2*(exp(K3*tEnd)-1));

%sineSw=[sineStart, sineMid, sineEnd];  %This method takes 5 times longer!!!

%REMARK 2
%--------

%test = conv(sineSwrev,sineSw2); %Far too slow!!!->> Using the Cooledit convolution or method 
%frequency (CoolEdit does not convolve with a signal sampled at 44100 Hz for more than 4 seconds)
%plot(test);

%REMARK 3
%--------

	%IRchain = fft(irchain',resFreq);
   %PhaseTot_IRchain = angle(IRchain);
   
   % Extraction of the minimum phase component of irchain

   %[a, irchain_min]  = rceps(irchain);
	%IRchain_min       = fft(irchain_min', resFreq);
   
   % Calculate the excess of the phase. This equalization algorithm is only
   % valid if the irchain phase is linear.

	%PhaseLag_IRchain  = PhaseTot_IRchain - angle(IRchain_min);
   
   %Estimated time of excess Group phase
   
   %grp = -diff(unwrap(PhaseLag_IRchain));
   %figure;
	%plot(grp);
	
	% Equalisation
  
  	%sineSwf = sineSwf./IRchain_min;
  
 	% Passage of the inverse response in the low-pass filter
	%lowpass = WSlowpass(18000, 50);
	%lowpassf = fft(lowpass, resFreq);
      
   %n = round(40*resFreq/fs);
   
   %if (mod(n,2) ~= 0)
   %   n = n+1;
   %end      
   
   % black = blackman(4*n);
   
   % highpass = [zeros(0,1) ; black(1:n/2); ones(resFreq - 1*n,1); black((n/2)+1:n) ; zeros(0,1)];
   %sineSwf = abs(lowpassf').* sineSwf;
   %figure;
   %plot(20*log10(abs(sineSwf)));
   
      
%REMARK 4 (hilbert)
%----------

	%IRchain = fft(irchain.', resFreq);
   %PhaseTot_IRchain = unwrap(angle(IRchain));
    
   %module = abs(IRchain);
   
   % Calculation of the minimum phase component corresponding to the amplitude
	%phase_min = -imag(hilbert(log(module)));
      
   %IRchain_min = module .* exp(j*phase_min);
      
	% Compensation of the minimum phase component

	%correction = 10^(0.25)*ones(1,resFreq);
   %sineSwf = sineSwf ./ correction;
   
   % The correction factor was added because
   %I see an equalization of the spectrum around 5dB and not around 0dB.

   %PhaseLag_IRchain = PhaseTot_IRchain - unwrap(phase_min);
   
   %IReq = exp(j*PhaseLag_IRchain);
   
   %ireq = real(ifft(IReq));

	%ireq_inv = flipud(ireq);
	
	%lconvlin = 2^nextpow2((nbEch+1) + length(ireq_inv) - 1);   %length of result of the linear convolution
   %lconvlin = resFreq;
   
	%IReq_inv = fft(ireq_inv,lconvlin);

	%sineSwf = sineSwf .* IReq_inv;
   
%REMARK 5 (high pass filter regularisation)
%----------

   
   %n = round(40*resFreq/fs);
   %l = round(10*resFreq/fs);
   
   %if (mod(n,2) ~= 0)
   %   n = n+1;
   %end      
   
   %n= 2*n;
   %black = blackman(n);
   
   %highpassf = [zeros(l,1); black(1:n/2); ones(resFreq - n - 2*l,1); black((n/2)+1:n); zeros(l,1)];
   
   %highpassf = highpassf.';
