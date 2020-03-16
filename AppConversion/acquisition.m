function mesure = acquisition(source, mode, fq)
% This function plays the generated Sine Sweep into space, then records it instantaneously
% ----------------------------------------------------------------------------------------
%acquisition(source, mode, fq)
%
%The file "source[.wav]" is the signal that is sent to the default audio device.
%
%The "mode" parameter to specify whether the recording is mono or stereo.
%
%"fq" is the sampling frequency used for sending as well as for recording the data.


if nargin < 3
   fq = 44100;
end

if nargin < 2
   mode = 1;
end


tosend = audioread(source);
structure = audioinfo(source);
bits = structure.BitsPerSample;

ap = audioplayer(tosend, fq, bits);     %creates Audioplayer object with SineSweep file
ar = audiorecorder(fq, bits, mode);     %creates Audiorecorder object
play(ap)                                %plays audio samples in Audioplayer object
recordblocking(ar, length(tosend)/fq);  %Synchronous recording from audio device. Vars OBJ and T (time)
mesure = getaudiodata(ar);              %gets recorded audio data in Audiorecorder object


pause(2);


return;
